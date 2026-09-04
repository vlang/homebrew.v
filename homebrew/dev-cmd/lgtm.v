module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/lgtm.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 23.
pub fn ruby_lgtm_l23_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return lgtm_command_result_value(run_lgtm_command(lgtm_command_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "tap"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Lgtm < AbstractCommand
// 10:       include SystemCommand::Mixin
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Run `brew typecheck`, `brew style --changed` and the relevant `brew tests`,
// 15:           `brew audit` and `brew test` checks in one go.
// 16:         EOS
// 17:         switch "--online",
// 18:                description: "Run additional, slower checks that require a network connection."
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         Homebrew.install_bundler_gems!(groups: Homebrew.valid_gem_groups - ["sorbet"])
// 25:
// 26:         tap = Tap.from_path(Dir.pwd)
// 27:
// 28:         typecheck_args = ["typecheck", tap&.name].compact
// 29:         ohai "brew #{typecheck_args.join(" ")}"
// 30:         safe_system HOMEBREW_BREW_FILE, *typecheck_args
// 31:         puts
// 32:
// 33:         ohai "brew style --changed --fix"
// 34:         safe_system HOMEBREW_BREW_FILE, "style", "--changed", "--fix"
// 35:         puts
// 36:
// 37:         if tap
// 38:           added_files = Utils.popen_read("git", "diff", "--name-only", "--no-relative", "--diff-filter=A", "main")
// 39:                              .split("\n")
// 40:           changed_formulae = []
// 41:           new_formulae = []
// 42:           changed_casks = []
// 43:           new_casks = []
// 44:           changed_audit_args = ["--strict"]
// 45:           changed_audit_args << "--online" if args.online?
// 46:           new_audit_args = args.online? ? ["--new"] : ["--strict"]
// 47:
// 48:           Utils.popen_read("git", "diff", "--name-only", "--no-relative", "--diff-filter=AMR", "main")
// 49:                .split("\n").each do |file|
// 50:             next if file.blank?
// 51:
// 52:             tapped_name = "#{tap.name}/#{Pathname(file).basename(".rb")}"
// 53:
// 54:             if tap.formula_file?(file)
// 55:               (added_files.include?(file) ? new_formulae : changed_formulae) << tapped_name
// 56:             elsif tap.cask_file?(file)
// 57:               (added_files.include?(file) ? new_casks : changed_casks) << tapped_name
// 58:             end
// 59:           end
// 60:
// 61:           if Utils.popen_read("git", "ls-files", "--others", "--exclude-standard", "--full-name")
// 62:                   .split("\n")
// 63:                   .any? { |file| tap.formula_file?(file) || tap.cask_file?(file) }
// 64:             opoo "Untracked formula or cask files are not checked by `brew lgtm`; stage or commit them first."
// 65:           end
// 66:
// 67:           if !args.online? && [*new_formulae, *new_casks].present?
// 68:             opoo "New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks."
// 69:           end
// 70:
// 71:           unless changed_formulae.empty?
// 72:             ohai "brew audit #{changed_audit_args.join(" ")} --skip-style --formula #{changed_formulae.join(" ")}"
// 73:             safe_system HOMEBREW_BREW_FILE, "audit", *changed_audit_args, "--skip-style", "--formula",
// 74:                         *changed_formulae
// 75:             puts
// 76:           end
// 77:
// 78:           unless new_formulae.empty?
// 79:             ohai "brew audit #{new_audit_args.join(" ")} --skip-style --formula #{new_formulae.join(" ")}"
// 80:             safe_system HOMEBREW_BREW_FILE, "audit", *new_audit_args, "--skip-style", "--formula", *new_formulae
// 81:             puts
// 82:           end
// 83:
// 84:           unless changed_casks.empty?
// 85:             ohai "brew audit #{changed_audit_args.join(" ")} --skip-style --cask #{changed_casks.join(" ")}"
// 86:             safe_system HOMEBREW_BREW_FILE, "audit", *changed_audit_args, "--skip-style", "--cask", *changed_casks
// 87:             puts
// 88:           end
// 89:
// 90:           unless new_casks.empty?
// 91:             ohai "brew audit #{new_audit_args.join(" ")} --skip-style --cask #{new_casks.join(" ")}"
// 92:             safe_system HOMEBREW_BREW_FILE, "audit", *new_audit_args, "--skip-style", "--cask", *new_casks
// 93:             puts
// 94:           end
// 95:
// 96:           formulae_to_test = [*changed_formulae, *new_formulae].select do |formula_name|
// 97:             next true if Formulary.factory(formula_name).latest_version_installed?
// 98:
// 99:             opoo "Skipping `brew test #{formula_name}`; the latest version is not installed."
// 100:             false
// 101:           end
// 102:           return if formulae_to_test.empty?
// 103:
// 104:           ohai "brew test #{formulae_to_test.join(" ")}"
// 105:           safe_system HOMEBREW_BREW_FILE, "test", *formulae_to_test
// 106:         else
// 107:           audit_or_tests_args = ["--changed"]
// 108:           audit_or_tests_args << "--online" if args.online?
// 109:           ohai "brew tests #{audit_or_tests_args.join(" ")}"
// 110:           safe_system HOMEBREW_BREW_FILE, "tests", *audit_or_tests_args
// 111:         end
// 112:       end
// 113:     end
// 114:   end
// 115: end
