module test_bot

import brew_runtime
import os

// Translated from Homebrew/brew `test_bot/formulae_detect.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn formulae_detect_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn formulae_detect_error_value(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

pub fn formulae_detect_boundary(detector &FormulaeDetect) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::TestBot::FormulaeDetect', detector.argument, {
		'formulae_detect_address': u64(voidptr(detector)).str()
	})
}

fn formulae_detect_receiver(args []brew_runtime.Value) !&FormulaeDetect {
	if args.len == 0 || 'formulae_detect_address' !in args[0].attributes {
		return error('FormulaeDetect receiver is required')
	}
	address := args[0].attributes['formulae_detect_address'].u64()
	if address == 0 {
		return error('FormulaeDetect receiver is invalid')
	}
	return unsafe { &FormulaeDetect(voidptr(address)) }
}

fn formulae_detect_args_from_value(value brew_runtime.Value) FormulaeDetectArgs {
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

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d1_testing_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	return brew_runtime.string_array_value(detector.testing_formulae)
}

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d2_added_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	return brew_runtime.string_array_value(detector.added_formulae)
}

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d3_deleted_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	return brew_runtime.string_array_value(detector.deleted_formulae)
}

// Ruby method `initialize(argument, tap:, git:, dry_run:, fail_fast:, verbose:)` at line 24.
pub fn ruby_formulae_detect_l24_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return formulae_detect_error_value('ArgumentError', 'initialize requires an argument')
	}
	detector := new_formulae_detect(args[0].as_string(), FormulaeDetectConfig{
		git: if args.len > 1 && args[1].as_string() != '' { args[1].as_string() } else { 'git' }
		repository: if args.len > 2 { args[2].as_string() } else { '' }
	})
	return formulae_detect_boundary(detector)
}

// Ruby method `run!(args:)` at line 35.
pub fn ruby_formulae_detect_l35_d5_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	options := if args.len > 1 {
		formulae_detect_args_from_value(args[1])
	} else {
		FormulaeDetectArgs{}
	}
	detector.run(options) or { return formulae_detect_error_value('UsageError', err.msg()) }
	return formulae_detect_nil_value()
}

// Ruby method `detect_formulae!(args:)` at line 51.
pub fn ruby_formulae_detect_l51_d6_detect_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	options := if args.len > 1 {
		formulae_detect_args_from_value(args[1])
	} else {
		FormulaeDetectArgs{}
	}
	detector.detect_formulae(options) or { return formulae_detect_error_value('UsageError', err.msg()) }
	return formulae_detect_nil_value()
}

// Ruby method `safe_formula_canonical_name(formula_name, args:)` at line 230.
pub fn ruby_formulae_detect_l230_d7_safe_formula_canonical_name(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	if args.len < 2 {
		return formulae_detect_error_value('ArgumentError', 'formula name is required')
	}
	options := if args.len > 2 {
		formulae_detect_args_from_value(args[2])
	} else {
		FormulaeDetectArgs{}
	}
	name := detector.safe_formula_canonical_name(args[1].as_string(), options) or {
		return formulae_detect_nil_value()
	}
	return brew_runtime.string_value(name)
}

// Ruby method `rev_parse(ref)` at line 240.
pub fn ruby_formulae_detect_l240_d8_rev_parse(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	if args.len < 2 {
		return formulae_detect_error_value('ArgumentError', 'Git reference is required')
	}
	revision := detector.rev_parse(args[1].as_string()) or {
		return formulae_detect_error_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_value(revision)
}

// Ruby method `current_sha1` at line 245.
pub fn ruby_formulae_detect_l245_d9_current_sha1(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	revision := detector.current_sha1() or {
		return formulae_detect_error_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_value(revision)
}

// Ruby method `diff_formulae(start_revision, end_revision, path, filter)` at line 257.
pub fn ruby_formulae_detect_l257_d10_diff_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	mut detector := formulae_detect_receiver(args) or { return formulae_detect_error_value('ArgumentError', err.msg()) }
	if args.len < 5 {
		return formulae_detect_error_value('ArgumentError', 'start revision, end revision, path and filter are required')
	}
	formulae := detector.diff_formulae(args[1].as_string(), args[2].as_string(), args[3].as_string(), args[4].as_string()) or {
		return formulae_detect_error_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_array_value(formulae)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class FormulaeDetect < Test
// 7:       # Formulae must have GitHub homepages and stable URLs, no stable dependencies,
// 8:       # one executable and one library between them.
// 9:       DEFAULT_TEST_FORMULAE = %w[libdeflate bats-core].freeze
// 10:
// 11:       sig { returns(T::Array[String]) }
// 12:       attr_reader :testing_formulae, :added_formulae, :deleted_formulae
// 13:
// 14:       sig {
// 15:         params(
// 16:           argument:  String,
// 17:           tap:       T.nilable(Tap),
// 18:           git:       String,
// 19:           dry_run:   T::Boolean,
// 20:           fail_fast: T::Boolean,
// 21:           verbose:   T::Boolean,
// 22:         ).void
// 23:       }
// 24:       def initialize(argument, tap:, git:, dry_run:, fail_fast:, verbose:)
// 25:         super(tap:, git:, dry_run:, fail_fast:, verbose:)
// 26:
// 27:         @argument = argument
// 28:         @added_formulae = T.let([], T::Array[String])
// 29:         @deleted_formulae = T.let([], T::Array[String])
// 30:         @formulae_to_fetch = T.let([], T::Array[String])
// 31:         @testing_formulae = T.let([], T::Array[String])
// 32:       end
// 33:
// 34:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 35:       def run!(args:)
// 36:         detect_formulae!(args:)
// 37:
// 38:         return unless GitHub::Actions.env_set?
// 39:
// 40:         File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 41:           f.puts "testing_formulae=#{@testing_formulae.join(",")}"
// 42:           f.puts "added_formulae=#{@added_formulae.join(",")}"
// 43:           f.puts "deleted_formulae=#{@deleted_formulae.join(",")}"
// 44:           f.puts "formulae_to_fetch=#{@formulae_to_fetch.join(",")}"
// 45:         end
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 51:       def detect_formulae!(args:)
// 52:         test_header(:FormulaeDetect, method: :detect_formulae!)
// 53:
// 54:         url = nil
// 55:         origin_ref = "origin/main"
// 56:
// 57:         github_repository = ENV.fetch("GITHUB_REPOSITORY", nil)
// 58:         github_ref = ENV.fetch("GITHUB_REF", nil)
// 59:
// 60:         if @argument == "HEAD"
// 61:           @testing_formulae = []
// 62:           # Use GitHub Actions variables for pull request jobs.
// 63:           if github_ref.present? && github_repository.present? &&
// 64:              %r{refs/pull/(\d+)/merge} =~ github_ref
// 65:             url = "https://github.com/#{github_repository}/pull/#{Regexp.last_match(1)}/checks"
// 66:           end
// 67:         elsif (canonical_formula_name = safe_formula_canonical_name(@argument, args:))
// 68:           unless canonical_formula_name.include?("/")
// 69:             ENV["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
// 70:             CoreTap.instance.ensure_installed!
// 71:           end
// 72:
// 73:           @testing_formulae = [canonical_formula_name]
// 74:         else
// 75:           raise UsageError,
// 76:                 "#{@argument} is not detected from GitHub Actions or a formula name!"
// 77:         end
// 78:
// 79:         github_sha = ENV.fetch("GITHUB_SHA", nil)
// 80:         if github_repository.blank? || github_sha.blank? || github_ref.blank?
// 81:           if GitHub::Actions.env_set?
// 82:             odie <<~EOS
// 83:               We cannot find the needed GitHub Actions environment variables! Check you have e.g. exported them to a Docker container.
// 84:             EOS
// 85:           elsif ENV["CI"]
// 86:             onoe <<~EOS
// 87:               No known CI provider detected! If you are using GitHub Actions then we cannot find the expected environment variables! Check you have e.g. exported them to a Docker container.
// 88:             EOS
// 89:           end
// 90:         elsif (tap = self.tap.presence) && tap.full_name.casecmp(github_repository)&.zero?
// 91:           # Use GitHub Actions variables for pull request jobs.
// 92:           if (base_ref = ENV.fetch("GITHUB_BASE_REF", nil)).present?
// 93:             unless tap.official?
// 94:               test git.to_s, "-C", repository.to_s, "fetch",
// 95:                    "origin", "+refs/heads/#{base_ref}"
// 96:             end
// 97:             origin_ref = "origin/#{base_ref}"
// 98:             diff_start_sha1 = rev_parse(origin_ref)
// 99:             diff_end_sha1 = github_sha
// 100:           # Use GitHub Actions variables for merge group jobs.
// 101:           elsif ENV.fetch("GITHUB_EVENT_NAME", nil) == "merge_group"
// 102:             diff_start_sha1 = rev_parse(origin_ref)
// 103:             origin_ref = "origin/#{github_ref.gsub(%r{^refs/heads/}, "")}"
// 104:             diff_end_sha1 = github_sha
// 105:           # Use GitHub Actions variables for branch jobs.
// 106:           else
// 107:             test git.to_s, "-C", repository.to_s, "fetch", "origin", "+#{github_ref}" unless tap.official?
// 108:             origin_ref = "origin/#{github_ref.gsub(%r{^refs/heads/}, "")}"
// 109:             diff_end_sha1 = diff_start_sha1 = github_sha
// 110:           end
// 111:         end
// 112:
// 113:         if diff_start_sha1.present? && diff_end_sha1.present?
// 114:           merge_base_sha1 =
// 115:             Utils.safe_popen_read(git, "-C", repository, "merge-base",
// 116:                                   diff_start_sha1, diff_end_sha1).strip
// 117:           diff_start_sha1 = merge_base_sha1 if merge_base_sha1.present?
// 118:         end
// 119:
// 120:         diff_start_sha1 = current_sha1 if diff_start_sha1.blank?
// 121:         diff_end_sha1 = current_sha1 if diff_end_sha1.blank?
// 122:
// 123:         diff_start_sha1 = diff_end_sha1 if @testing_formulae.present?
// 124:
// 125:         if (tap = self.tap.presence)
// 126:           tap_origin_ref_revision_args =
// 127:             [git, "-C", tap.path.to_s, "log", "-1", "--format=%h (%s)", origin_ref]
// 128:           tap_origin_ref_revision = if args.dry_run?
// 129:             # May fail on dry run as we've not fetched.
// 130:             Utils.popen_read(*tap_origin_ref_revision_args).strip
// 131:           else
// 132:             Utils.safe_popen_read(*tap_origin_ref_revision_args)
// 133:           end.strip
// 134:           tap_revision = Utils.safe_popen_read(
// 135:             git, "-C", tap.path.to_s,
// 136:             "log", "-1", "--format=%h (%s)"
// 137:           ).strip
// 138:         end
// 139:
// 140:         puts <<-EOS
// 141:     url               #{url.presence                     || "(blank)"}
// 142:     tap #{origin_ref} #{tap_origin_ref_revision.presence || "(blank)"}
// 143:     HEAD              #{tap_revision.presence            || "(blank)"}
// 144:     diff_start_sha1   #{diff_start_sha1.presence         || "(blank)"}
// 145:     diff_end_sha1     #{diff_end_sha1.presence           || "(blank)"}
// 146:         EOS
// 147:
// 148:         modified_formulae = []
// 149:
// 150:         if diff_start_sha1 != diff_end_sha1 && (tap = self.tap.presence)
// 151:           formula_path = tap.formula_dir.to_s
// 152:           @added_formulae +=
// 153:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "A")
// 154:           modified_formulae +=
// 155:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "M")
// 156:           @deleted_formulae +=
// 157:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "D")
// 158:         end
// 159:
// 160:         # If a formula is both added and deleted: it's actually modified.
// 161:         added_and_deleted_formulae = @added_formulae & @deleted_formulae
// 162:         @added_formulae -= added_and_deleted_formulae
// 163:         @deleted_formulae -= added_and_deleted_formulae
// 164:         modified_formulae += added_and_deleted_formulae
// 165:
// 166:         if args.test_default_formula?
// 167:           @added_formulae.reject! { |formula| formula.start_with?("portable-") }
// 168:           modified_formulae.reject! { |formula| formula.start_with?("portable-") }
// 169:           # Build the default test formulae.
// 170:           modified_formulae += DEFAULT_TEST_FORMULAE
// 171:         elsif @added_formulae.present? &&
// 172:               @added_formulae.all? { |formula| formula.start_with?("portable-") }
// 173:           @added_formulae = ["portable-ruby"]
// 174:         elsif modified_formulae.present? &&
// 175:               modified_formulae.all? { |formula| formula.start_with?("portable-") }
// 176:           modified_formulae = ["portable-ruby"]
// 177:         elsif modified_formulae.any? { |formula| formula.start_with?("portable-") } &&
// 178:               !(ENV["GITHUB_EVENT_NAME"] == "merge_group" && args.only_formulae_detect?)
// 179:           odie "Portable Ruby (and related formulae) cannot be tested in the same job as other formulae!"
// 180:         end
// 181:
// 182:         @testing_formulae += @added_formulae + modified_formulae
// 183:
// 184:         # TODO: Remove `GITHUB_EVENT_NAME` check when formulae detection
// 185:         #       is fixed for branch jobs.
// 186:         if @testing_formulae.blank? &&
// 187:            @deleted_formulae.blank? &&
// 188:            diff_start_sha1 == diff_end_sha1 &&
// 189:            (ENV["GITHUB_EVENT_NAME"] != "push")
// 190:           raise UsageError, "Did not find any formulae or commits to test!"
// 191:         end
// 192:
// 193:         # Remove all duplicates.
// 194:         @testing_formulae.uniq!
// 195:         @added_formulae.uniq!
// 196:         modified_formulae.uniq!
// 197:         @deleted_formulae.uniq!
// 198:
// 199:         # We only need to do a fetch test on formulae that have had a change in the pkg version or bottle block.
// 200:         # These fetch tests only happen in merge queues.
// 201:         @formulae_to_fetch = if diff_start_sha1 == diff_end_sha1 || ENV["GITHUB_EVENT_NAME"] != "merge_group"
// 202:           []
// 203:         else
// 204:           require "formula_versions"
// 205:
// 206:           @testing_formulae.reject do |formula_name|
// 207:             latest_formula = Formula[formula_name]
// 208:
// 209:             # nil = formula not found, false = bottles changed, true = bottles not changed
// 210:             equal_bottles = FormulaVersions.new(latest_formula).formula_at_revision(diff_start_sha1) do |old_formula|
// 211:               old_formula.pkg_version == latest_formula.pkg_version &&
// 212:                 old_formula.bottle_specification == latest_formula.bottle_specification
// 213:             end
// 214:
// 215:             equal_bottles # only exclude the true case (bottles not changed)
// 216:           end
// 217:         end
// 218:
// 219:         puts <<-EOS
// 220:
// 221:     testing_formulae  #{@testing_formulae.join(" ").presence  || "(none)"}
// 222:     added_formulae    #{@added_formulae.join(" ").presence    || "(none)"}
// 223:     modified_formulae #{modified_formulae.join(" ").presence  || "(none)"}
// 224:     deleted_formulae  #{@deleted_formulae.join(" ").presence  || "(none)"}
// 225:     formulae_to_fetch #{@formulae_to_fetch.join(" ").presence || "(none)"}
// 226:         EOS
// 227:       end
// 228:
// 229:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).returns(T.nilable(String)) }
// 230:       def safe_formula_canonical_name(formula_name, args:)
// 231:         Homebrew.with_no_api_env do
// 232:           Formulary.factory(formula_name).full_name
// 233:         end
// 234:       rescue FormulaUnavailableError, TapFormulaUnavailableError, TapFormulaAmbiguityError => e
// 235:         onoe e
// 236:         puts e.backtrace if args.debug?
// 237:       end
// 238:
// 239:       sig { params(ref: String).returns(String) }
// 240:       def rev_parse(ref)
// 241:         Utils.popen_read(git, "-C", repository, "rev-parse", "--verify", ref).strip
// 242:       end
// 243:
// 244:       sig { returns(String) }
// 245:       def current_sha1
// 246:         rev_parse("HEAD")
// 247:       end
// 248:
// 249:       sig {
// 250:         params(
// 251:           start_revision: String,
// 252:           end_revision:   String,
// 253:           path:           String,
// 254:           filter:         String,
// 255:         ).returns(T::Array[String])
// 256:       }
// 257:       def diff_formulae(start_revision, end_revision, path, filter)
// 258:         raise "A tap is required to call diff_formulae" unless @tap
// 259:
// 260:         Utils.safe_popen_read(
// 261:           git, "-C", repository,
// 262:           "diff-tree", "-r", "--name-only", "--diff-filter=#{filter}",
// 263:           start_revision, end_revision, "--", path
// 264:         ).lines(chomp: true).filter_map do |file|
// 265:           next unless @tap.formula_file?(file)
// 266:
// 267:           file = Pathname.new(file)
// 268:           @tap.formula_file_to_name(file)
// 269:         end
// 270:       end
// 271:     end
// 272:   end
// 273: end
