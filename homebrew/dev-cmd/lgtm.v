module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/lgtm.rb`.

pub struct LgtmTap {
pub:
	name             string
	formula_prefixes []string = ['Formula/']
	cask_prefixes    []string = ['Casks/']
}

pub fn (tap LgtmTap) formula_file(path string) bool {
	return tap.formula_prefixes.any(path.starts_with(it))
}

pub fn (tap LgtmTap) cask_file(path string) bool {
	return tap.cask_prefixes.any(path.starts_with(it))
}

pub struct LgtmCommandOptions {
pub:
	brew_file                string = 'brew'
	online                   bool
	valid_gem_groups         []string
	tap_present              bool
	tap                      LgtmTap
	added_files              []string
	changed_files            []string
	untracked_files          []string
	latest_version_installed map[string]bool
}

pub struct LgtmCommandResult {
pub mut:
	bundler_groups   []string
	commands         [][]string
	ohai             []string
	warnings         []string
	blank_lines      int
	changed_formulae []string
	new_formulae     []string
	changed_casks    []string
	new_casks        []string
	formulae_to_test []string
}

fn lgtm_nonblank_lines(lines []string) []string {
	return lines.filter(it.trim_space().len > 0)
}

fn lgtm_tapped_name(tap LgtmTap, path string) string {
	return '${tap.name}/${os.file_name(path).trim_string_right('.rb')}'
}

fn lgtm_append_command(mut result LgtmCommandResult, command []string, heading string,
	with_blank_line bool) {
	result.ohai << heading
	result.commands << command
	if with_blank_line {
		result.blank_lines++
	}
}

pub fn run_lgtm_command(options LgtmCommandOptions) LgtmCommandResult {
	mut result := LgtmCommandResult{
		bundler_groups: options.valid_gem_groups.filter(it != 'sorbet')
	}
	mut typecheck_command := [options.brew_file, 'typecheck']
	if options.tap_present {
		typecheck_command << options.tap.name
	}
	lgtm_append_command(mut result, typecheck_command, 'brew ${typecheck_command[1..].join(' ')}', true)
	lgtm_append_command(mut result, [options.brew_file, 'style', '--changed', '--fix'], 'brew style --changed --fix', true)

	if !options.tap_present {
		mut tests_command := [options.brew_file, 'tests', '--changed']
		if options.online {
			tests_command << '--online'
		}
		lgtm_append_command(mut result, tests_command, 'brew ${tests_command[1..].join(' ')}', false)
		return result
	}

	added_files := lgtm_nonblank_lines(options.added_files)
	for file in lgtm_nonblank_lines(options.changed_files) {
		tapped_name := lgtm_tapped_name(options.tap, file)
		if options.tap.formula_file(file) {
			if file in added_files {
				result.new_formulae << tapped_name
			} else {
				result.changed_formulae << tapped_name
			}
		} else if options.tap.cask_file(file) {
			if file in added_files {
				result.new_casks << tapped_name
			} else {
				result.changed_casks << tapped_name
			}
		}
	}

	if lgtm_nonblank_lines(options.untracked_files).any(options.tap.formula_file(it)
		|| options.tap.cask_file(it)) {
		result.warnings << 'Untracked formula or cask files are not checked by `brew lgtm`; stage or commit them first.'
	}
	if !options.online && (result.new_formulae.len > 0 || result.new_casks.len > 0) {
		result.warnings << 'New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks.'
	}

	mut changed_audit_args := ['--strict']
	if options.online {
		changed_audit_args << '--online'
	}
	new_audit_args := if options.online { ['--new'] } else { ['--strict'] }
	lgtm_append_audit(mut result, options.brew_file, changed_audit_args, '--formula', result.changed_formulae)
	lgtm_append_audit(mut result, options.brew_file, new_audit_args, '--formula', result.new_formulae)
	lgtm_append_audit(mut result, options.brew_file, changed_audit_args, '--cask', result.changed_casks)
	lgtm_append_audit(mut result, options.brew_file, new_audit_args, '--cask', result.new_casks)

	for formula_name in result.changed_formulae.clone() {
		if options.latest_version_installed[formula_name] or { false } {
			result.formulae_to_test << formula_name
		} else {
			result.warnings << 'Skipping `brew test ${formula_name}`; the latest version is not installed.'
		}
	}
	for formula_name in result.new_formulae.clone() {
		if options.latest_version_installed[formula_name] or { false } {
			result.formulae_to_test << formula_name
		} else {
			result.warnings << 'Skipping `brew test ${formula_name}`; the latest version is not installed.'
		}
	}
	if result.formulae_to_test.len > 0 {
		mut test_command := [options.brew_file, 'test']
		test_command << result.formulae_to_test
		lgtm_append_command(mut result, test_command, 'brew ${test_command[1..].join(' ')}', false)
	}
	return result
}

fn lgtm_append_audit(mut result LgtmCommandResult, brew_file string, audit_args []string,
	kind string, names []string) {
	if names.len == 0 {
		return
	}
	mut command := [brew_file, 'audit']
	command << audit_args
	command << ['--skip-style', kind]
	command << names
	lgtm_append_command(mut result, command, 'brew ${command[1..].join(' ')}', true)
}

@[heap]
pub struct LgtmCommandInput {
pub:
	options LgtmCommandOptions
}

pub fn lgtm_command_input_boundary(input &LgtmCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Lgtm::Input', '', {
		'lgtm_command_input_address': u64(voidptr(input)).str()
	})
}

fn lgtm_command_input_from_value(value ruby.Value) &LgtmCommandInput {
	address := value.attributes['lgtm_command_input_address'] or { panic('invalid Lgtm command input') }
	return unsafe { &LgtmCommandInput(voidptr(address.u64())) }
}

fn lgtm_command_result_value(result LgtmCommandResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':   ruby.string_array_value(result.bundler_groups)
		'commands':         ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'ohai':             ruby.string_array_value(result.ohai)
		'warnings':         ruby.string_array_value(result.warnings)
		'blank_lines':      ruby.int_value(result.blank_lines)
		'changed_formulae': ruby.string_array_value(result.changed_formulae)
		'new_formulae':     ruby.string_array_value(result.new_formulae)
		'changed_casks':    ruby.string_array_value(result.changed_casks)
		'new_casks':        ruby.string_array_value(result.new_casks)
		'formulae_to_test': ruby.string_array_value(result.formulae_to_test)
	})
}
