module dev_cmd

import brew_runtime
import regex

// Translated from Homebrew/brew `dev-cmd/generate-man-completions.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GenerateManCompletionsOptions {
pub:
	repository   string
	quiet        bool
	no_exit_code bool
	diff_success bool
	diff_stdout  string
}

pub struct GenerateManCompletionsResult {
pub:
	bundler_groups            []string
	rebuild_internal_commands bool
	regenerate_man_pages      bool
	man_pages_quiet           bool
	update_shell_completions  bool
	diff_command              []string
	status                    string
	message                   string
	failed                    bool
}

@[heap]
pub struct GenerateManCompletionsInput {
pub:
	options GenerateManCompletionsOptions
}

pub fn man_completions_only_date_change(diff_stdout string) bool {
	summary := '1 file changed, 1 insertion(+), 1 deletion(-)'
	summary_index := diff_stdout.index(summary) or { return false }
	mut date_line := regex.regex_opt(r'-\.TH "BREW" "1" "[A-Za-z0-9_]+ [0-9]+"') or {
		return false
	}
	date_index, _ := date_line.find(diff_stdout)
	return date_index > summary_index
}

pub fn generate_man_completions_plan(options GenerateManCompletionsOptions) GenerateManCompletionsResult {
	mut status := ''
	mut message := ''
	if options.diff_success {
		status = 'failure'
		message = 'No changes to manpage or completions.'
	} else if man_completions_only_date_change(options.diff_stdout) {
		status = 'failure'
		message = 'No changes to manpage or completions other than the date.'
	} else {
		status = 'success'
		message = 'Manpage and completions updated.'
	}
	return GenerateManCompletionsResult{
		bundler_groups: ['man']
		rebuild_internal_commands: true
		regenerate_man_pages: true
		man_pages_quiet: options.quiet
		update_shell_completions: true
		diff_command: ['git', '-C', options.repository, 'diff', '--shortstat', '--patch',
			'--exit-code', 'docs/Manpage.md', 'manpages', 'completions']
		status: status
		message: message
		failed: status == 'failure' && !options.no_exit_code
	}
}

pub fn generate_man_completions_input_boundary(input &GenerateManCompletionsInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::GenerateManCompletions::Input', '', {
		'generate_man_completions_input_address': u64(voidptr(input)).str()
	})
}

fn generate_man_completions_input_from_value(value brew_runtime.Value) &GenerateManCompletionsInput {
	address := value.attributes['generate_man_completions_input_address'] or {
		panic('invalid GenerateManCompletions input')
	}
	return unsafe { &GenerateManCompletionsInput(voidptr(address.u64())) }
}

fn generate_man_completions_result_value(result GenerateManCompletionsResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bundler_groups':            brew_runtime.string_array_value(result.bundler_groups)
		'rebuild_internal_commands': brew_runtime.bool_value(result.rebuild_internal_commands)
		'regenerate_man_pages':      brew_runtime.bool_value(result.regenerate_man_pages)
		'man_pages_quiet':           brew_runtime.bool_value(result.man_pages_quiet)
		'update_shell_completions':  brew_runtime.bool_value(result.update_shell_completions)
		'diff_command':              brew_runtime.string_array_value(result.diff_command)
		'status':                    brew_runtime.object_value('Symbol', result.status)
		'message':                   brew_runtime.string_value(result.message)
		'failed':                    brew_runtime.bool_value(result.failed)
	})
}

// Ruby method `run` at line 26.
pub fn ruby_generate_man_completions_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return generate_man_completions_result_value(generate_man_completions_plan(generate_man_completions_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "completions"
// 7: require "manpages"
// 8: require "system_command"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class GenerateManCompletions < AbstractCommand
// 13:       include SystemCommand::Mixin
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Generate Homebrew's manpages and shell completions.
// 18:         EOS
// 19:
// 20:         switch "--no-exit-code", description: "Exit with code 0 even if no changes were made."
// 21:
// 22:         named_args :none
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         Homebrew.install_bundler_gems!(groups: ["man"])
// 28:
// 29:         Commands.rebuild_internal_commands_completion_list
// 30:         Manpages.regenerate_man_pages(quiet: args.quiet?)
// 31:         Completions.update_shell_completions!
// 32:
// 33:         diff = system_command "git", args: [
// 34:           "-C", HOMEBREW_REPOSITORY,
// 35:           "diff", "--shortstat", "--patch", "--exit-code", "docs/Manpage.md", "manpages", "completions"
// 36:         ]
// 37:         status, message = if diff.status.success?
// 38:           [:failure, "No changes to manpage or completions."]
// 39:         elsif /1 file changed, 1 insertion\(\+\), 1 deletion\(-\).*-\.TH "BREW" "1" "\w+ \d+"/m.match?(diff.stdout)
// 40:           [:failure, "No changes to manpage or completions other than the date."]
// 41:         else
// 42:           [:success, "Manpage and completions updated."]
// 43:         end
// 44:
// 45:         if status == :failure && !args.no_exit_code?
// 46:           ofail message
// 47:         else
// 48:           puts message
// 49:         end
// 50:       end
// 51:     end
// 52:   end
// 53: end
