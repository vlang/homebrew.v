module test_bot

import ruby
import os

// Translated from Homebrew/brew `test_bot/formulae_detect.rb`.
pub const default_test_formulae = ['libdeflate', 'bats-core']

pub struct FormulaeDetectTap {
pub:
	full_name          string
	path               string
	formula_dir        string
	official           bool
	formula_file_names map[string]string
}

pub struct FormulaeDetectArgs {
pub:
	dry_run              bool
	debug                bool
	test_default_formula bool
	only_formulae_detect bool
}

pub struct FormulaeDetectConfig {
pub:
	tap                       ?FormulaeDetectTap
	git                       string = 'git'
	repository                string
	dry_run                   bool
	fail_fast                 bool
	verbose                   bool
	github_actions            bool
	environment               map[string]string
	canonical_formulae        map[string]string
	unavailable_formulae      []string
	command_outputs           map[string]string
	command_errors            map[string]string
	bottles_equal_at_revision map[string]bool
}

@[heap]
pub struct FormulaeDetect {
pub:
	argument   string
	tap        ?FormulaeDetectTap
	git        string
	repository string
	dry_run    bool
	fail_fast  bool
	verbose    bool
mut:
	github_actions            bool
	environment               map[string]string
	canonical_formulae        map[string]string
	unavailable_formulae      []string
	command_outputs           map[string]string
	command_errors            map[string]string
	bottles_equal_at_revision map[string]bool
pub mut:
	testing_formulae  []string
	added_formulae    []string
	deleted_formulae  []string
	formulae_to_fetch []string
	commands          [][]string
	diagnostics       []string
	output            []string
	core_tap_ensured  bool
}

pub fn formulae_detect_command_key(command []string) string {
	return command.join('\x1f')
}

pub fn new_formulae_detect(argument string, config FormulaeDetectConfig) &FormulaeDetect {
	mut repository := config.repository
	if repository == '' {
		if tap := config.tap {
			repository = tap.path
		}
	}
	return &FormulaeDetect{
		argument: argument
		tap: config.tap
		git: if config.git == '' { 'git' } else { config.git }
		repository: repository
		dry_run: config.dry_run
		fail_fast: config.fail_fast
		verbose: config.verbose
		github_actions: config.github_actions
		environment: config.environment.clone()
		canonical_formulae: config.canonical_formulae.clone()
		unavailable_formulae: config.unavailable_formulae.clone()
		command_outputs: config.command_outputs.clone()
		command_errors: config.command_errors.clone()
		bottles_equal_at_revision: config.bottles_equal_at_revision.clone()
	}
}

fn formulae_detect_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formulae_detect_error_value(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

pub fn formulae_detect_boundary(detector &FormulaeDetect) ruby.Value {
	return ruby.structured_value('Homebrew::TestBot::FormulaeDetect', detector.argument, {
		'formulae_detect_address': u64(voidptr(detector)).str()
	})
}

fn formulae_detect_receiver(args []ruby.Value) !&FormulaeDetect {
	if args.len == 0 || 'formulae_detect_address' !in args[0].attributes {
		return error('FormulaeDetect receiver is required')
	}
	address := args[0].attributes['formulae_detect_address'].u64()
	if address == 0 {
		return error('FormulaeDetect receiver is invalid')
	}
	return unsafe { &FormulaeDetect(voidptr(address)) }
}

fn formulae_detect_args_from_value(value ruby.Value) FormulaeDetectArgs {
	return FormulaeDetectArgs{
		dry_run: value.attributes['dry_run'] or { 'false' } == 'true'
		debug: value.attributes['debug'] or { 'false' } == 'true'
		test_default_formula: value.attributes['test_default_formula'] or { 'false' } == 'true'
		only_formulae_detect: value.attributes['only_formulae_detect'] or { 'false' } == 'true'
	}
}

fn unique_formulae(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

fn without_formulae(values []string, removed []string) []string {
	return values.filter(it !in removed)
}

fn all_portable_formulae(values []string) bool {
	if values.len == 0 {
		return false
	}
	for value in values {
		if !value.starts_with('portable-') {
			return false
		}
	}
	return true
}

fn pull_request_number(reference string) ?string {
	prefix := 'refs/pull/'
	suffix := '/merge'
	if !reference.starts_with(prefix) || !reference.ends_with(suffix) {
		return none
	}
	number := reference[prefix.len..reference.len - suffix.len]
	if number == '' || number.bytes().any(it < `0` || it > `9`) {
		return none
	}
	return number
}

fn (mut detector FormulaeDetect) command_output(command []string, allow_failure bool) !string {
	detector.commands << command.clone()
	key := formulae_detect_command_key(command)
	if message := detector.command_errors[key] {
		if allow_failure {
			return ''
		}
		return error(message)
	}
	if output := detector.command_outputs[key] {
		return output.trim_space()
	}
	if detector.dry_run && allow_failure {
		return ''
	}
	result := os.execute(command.map(os.quoted_path(it)).join(' '))
	if result.exit_code != 0 {
		if allow_failure {
			return result.output.trim_space()
		}
		return error('command failed (${result.exit_code}): ${command.join(' ')}\n${result.output.trim_space()}')
	}
	return result.output.trim_space()
}

pub fn (mut detector FormulaeDetect) safe_formula_canonical_name(formula_name string,
	args FormulaeDetectArgs) ?string {
	if formula_name == '' || formula_name in detector.unavailable_formulae {
		message := 'No available formula with the name "${formula_name}".'
		detector.diagnostics << message
		if args.debug {
			detector.output << 'FormulaUnavailableError: ${message}'
		}
		return none
	}
	return detector.canonical_formulae[formula_name] or { formula_name }
}

pub fn (mut detector FormulaeDetect) rev_parse(ref string) !string {
	return detector.command_output([detector.git, '-C', detector.repository, 'rev-parse', '--verify',
		ref], false)
}

pub fn (mut detector FormulaeDetect) current_sha1() !string {
	return detector.rev_parse('HEAD')
}

pub fn (mut detector FormulaeDetect) diff_formulae(start_revision string, end_revision string,
	path string, filter string) ![]string {
	tap := detector.tap or { return error('A tap is required to call diff_formulae') }
	contents := detector.command_output([detector.git, '-C', detector.repository, 'diff-tree', '-r',
		'--name-only', '--diff-filter=${filter}', start_revision, end_revision, '--', path], false)!
	mut formulae := []string{}
	for raw_file in contents.split_into_lines() {
		file := raw_file.trim_space()
		if file == '' {
			continue
		}
		if name := tap.formula_file_names[file] {
			formulae << name
			continue
		}
		formula_dir := tap.formula_dir.trim_string_right('/')
		if formula_dir != '' && file.starts_with('${formula_dir}/') && file.ends_with('.rb') {
			formulae << os.file_name(file).trim_string_right('.rb')
		}
	}
	return formulae
}

fn (detector FormulaeDetect) environment_value(name string) string {
	return detector.environment[name] or { '' }
}

fn (mut detector FormulaeDetect) append_detection_report(origin_ref string, url string,
	tap_origin_revision string, tap_revision string, diff_start string, diff_end string,
	modified []string) {
	detector.output << 'url               ${if url == '' { '(blank)' } else { url }}'
	detector.output << 'tap ${origin_ref} ${if tap_origin_revision == '' {
		'(blank)'
	} else {
		tap_origin_revision
	}}'
	detector.output << 'HEAD              ${if tap_revision == '' {
		'(blank)'
	} else {
		tap_revision
	}}'
	detector.output << 'diff_start_sha1   ${if diff_start == '' { '(blank)' } else { diff_start }}'
	detector.output << 'diff_end_sha1     ${if diff_end == '' { '(blank)' } else { diff_end }}'
	detector.output << 'testing_formulae  ${if detector.testing_formulae.len == 0 {
		'(none)'
	} else {
		detector.testing_formulae.join(' ')
	}}'
	detector.output << 'added_formulae    ${if detector.added_formulae.len == 0 {
		'(none)'
	} else {
		detector.added_formulae.join(' ')
	}}'
	detector.output << 'modified_formulae ${if modified.len == 0 {
		'(none)'
	} else {
		modified.join(' ')
	}}'
	detector.output << 'deleted_formulae  ${if detector.deleted_formulae.len == 0 {
		'(none)'
	} else {
		detector.deleted_formulae.join(' ')
	}}'
	detector.output << 'formulae_to_fetch ${if detector.formulae_to_fetch.len == 0 {
		'(none)'
	} else {
		detector.formulae_to_fetch.join(' ')
	}}'
}

pub fn (mut detector FormulaeDetect) detect_formulae(args FormulaeDetectArgs) ! {
	detector.output << 'Running FormulaeDetect#detect_formulae!'
	mut url := ''
	mut origin_ref := 'origin/main'
	github_repository := detector.environment_value('GITHUB_REPOSITORY')
	github_ref := detector.environment_value('GITHUB_REF')
	if detector.argument == 'HEAD' {
		detector.testing_formulae = []
		if github_repository != '' {
			if number := pull_request_number(github_ref) {
				url = 'https://github.com/${github_repository}/pull/${number}/checks'
			}
		}
	} else if canonical_name := detector.safe_formula_canonical_name(detector.argument, args) {
		if !canonical_name.contains('/') {
			detector.environment['HOMEBREW_NO_INSTALL_FROM_API'] = '1'
			detector.core_tap_ensured = true
		}
		detector.testing_formulae = [canonical_name]
	} else {
		return error('${detector.argument} is not detected from GitHub Actions or a formula name!')
	}

	github_sha := detector.environment_value('GITHUB_SHA')
	mut diff_start_sha1 := ''
	mut diff_end_sha1 := ''
	if github_repository == '' || github_sha == '' || github_ref == '' {
		if detector.github_actions {
			return error('We cannot find the needed GitHub Actions environment variables! Check you have e.g. exported them to a Docker container.')
		} else if detector.environment_value('CI') != '' {
			detector.diagnostics << 'No known CI provider detected! If you are using GitHub Actions then we cannot find the expected environment variables! Check you have e.g. exported them to a Docker container.'
		}
	} else if tap := detector.tap {
		if tap.full_name.to_lower() == github_repository.to_lower() {
			base_ref := detector.environment_value('GITHUB_BASE_REF')
			if base_ref != '' {
				if !tap.official {
					_ = detector.command_output([detector.git, '-C', detector.repository, 'fetch',
						'origin', '+refs/heads/${base_ref}'], false)!
				}
				origin_ref = 'origin/${base_ref}'
				diff_start_sha1 = detector.rev_parse(origin_ref)!
				diff_end_sha1 = github_sha
			} else if detector.environment_value('GITHUB_EVENT_NAME') == 'merge_group' {
				diff_start_sha1 = detector.rev_parse(origin_ref)!
				origin_ref = 'origin/${github_ref.trim_string_left('refs/heads/')}'
				diff_end_sha1 = github_sha
			} else {
				if !tap.official {
					_ = detector.command_output([detector.git, '-C', detector.repository, 'fetch',
						'origin', '+${github_ref}'], false)!
				}
				origin_ref = 'origin/${github_ref.trim_string_left('refs/heads/')}'
				diff_start_sha1 = github_sha
				diff_end_sha1 = github_sha
			}
		}
	}
	if diff_start_sha1 != '' && diff_end_sha1 != '' {
		merge_base := detector.command_output([detector.git, '-C', detector.repository, 'merge-base',
			diff_start_sha1, diff_end_sha1], false)!
		if merge_base != '' {
			diff_start_sha1 = merge_base
		}
	}
	if diff_start_sha1 == '' {
		diff_start_sha1 = detector.current_sha1()!
	}
	if diff_end_sha1 == '' {
		diff_end_sha1 = detector.current_sha1()!
	}
	if detector.testing_formulae.len > 0 {
		diff_start_sha1 = diff_end_sha1
	}

	mut tap_origin_revision := ''
	mut tap_revision := ''
	if tap := detector.tap {
		origin_command := [detector.git, '-C', tap.path, 'log', '-1', '--format=%h (%s)', origin_ref]
		tap_origin_revision = detector.command_output(origin_command, args.dry_run)!
		tap_revision = detector.command_output([detector.git, '-C', tap.path, 'log', '-1',
			'--format=%h (%s)'], false)!
	}

	mut modified_formulae := []string{}
	if diff_start_sha1 != diff_end_sha1 {
		if tap := detector.tap {
			detector.added_formulae << detector.diff_formulae(diff_start_sha1, diff_end_sha1, tap.formula_dir, 'A')!
			modified_formulae << detector.diff_formulae(diff_start_sha1, diff_end_sha1, tap.formula_dir, 'M')!
			detector.deleted_formulae << detector.diff_formulae(diff_start_sha1, diff_end_sha1, tap.formula_dir, 'D')!
		}
	}
	mut added_and_deleted := []string{}
	for formula in detector.added_formulae {
		if formula in detector.deleted_formulae {
			added_and_deleted << formula
		}
	}
	detector.added_formulae = without_formulae(detector.added_formulae, added_and_deleted)
	detector.deleted_formulae = without_formulae(detector.deleted_formulae, added_and_deleted)
	modified_formulae << added_and_deleted

	if args.test_default_formula {
		detector.added_formulae = detector.added_formulae.filter(!it.starts_with('portable-'))
		modified_formulae = modified_formulae.filter(!it.starts_with('portable-'))
		modified_formulae << default_test_formulae
	} else if all_portable_formulae(detector.added_formulae) {
		detector.added_formulae = ['portable-ruby']
	} else if all_portable_formulae(modified_formulae) {
		modified_formulae = ['portable-ruby']
	} else if modified_formulae.any(it.starts_with('portable-')) && !(detector.environment_value('GITHUB_EVENT_NAME') == 'merge_group' && args.only_formulae_detect) {
		return error('Portable Ruby (and related formulae) cannot be tested in the same job as other formulae!')
	}
	detector.testing_formulae << detector.added_formulae
	detector.testing_formulae << modified_formulae
	if detector.testing_formulae.len == 0 && detector.deleted_formulae.len == 0 && diff_start_sha1 == diff_end_sha1 && detector.environment_value('GITHUB_EVENT_NAME') != 'push' {
		return error('Did not find any formulae or commits to test!')
	}
	detector.testing_formulae = unique_formulae(detector.testing_formulae)
	detector.added_formulae = unique_formulae(detector.added_formulae)
	modified_formulae = unique_formulae(modified_formulae)
	detector.deleted_formulae = unique_formulae(detector.deleted_formulae)
	if diff_start_sha1 == diff_end_sha1 || detector.environment_value('GITHUB_EVENT_NAME') != 'merge_group' {
		detector.formulae_to_fetch = []
	} else {
		detector.formulae_to_fetch = detector.testing_formulae.filter(!(detector.bottles_equal_at_revision[it] or {
			false
		}))
	}
	detector.append_detection_report(origin_ref, url, tap_origin_revision, tap_revision, diff_start_sha1, diff_end_sha1, modified_formulae)
}

pub fn (mut detector FormulaeDetect) run(args FormulaeDetectArgs) ! {
	detector.detect_formulae(args)!
	if !detector.github_actions {
		return
	}
	output_path := detector.environment_value('GITHUB_OUTPUT')
	if output_path == '' {
		return error('GITHUB_OUTPUT is not set')
	}
	mut file := os.open_append(output_path)!
	defer {
		file.close()
	}
	file.write_string('testing_formulae=${detector.testing_formulae.join(',')}\n')!
	file.write_string('added_formulae=${detector.added_formulae.join(',')}\n')!
	file.write_string('deleted_formulae=${detector.deleted_formulae.join(',')}\n')!
	file.write_string('formulae_to_fetch=${detector.formulae_to_fetch.join(',')}\n')!
}
