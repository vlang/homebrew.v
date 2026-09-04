module dev_cmd

import ruby
import regex

// Translated from Homebrew/brew `dev-cmd/generate-man-completions.rb`.
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

pub fn generate_man_completions_input_boundary(input &GenerateManCompletionsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateManCompletions::Input', '', {
		'generate_man_completions_input_address': u64(voidptr(input)).str()
	})
}

fn generate_man_completions_input_from_value(value ruby.Value) &GenerateManCompletionsInput {
	address := value.attributes['generate_man_completions_input_address'] or {
		panic('invalid GenerateManCompletions input')
	}
	return unsafe { &GenerateManCompletionsInput(voidptr(address.u64())) }
}

fn generate_man_completions_result_value(result GenerateManCompletionsResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':            ruby.string_array_value(result.bundler_groups)
		'rebuild_internal_commands': ruby.bool_value(result.rebuild_internal_commands)
		'regenerate_man_pages':      ruby.bool_value(result.regenerate_man_pages)
		'man_pages_quiet':           ruby.bool_value(result.man_pages_quiet)
		'update_shell_completions':  ruby.bool_value(result.update_shell_completions)
		'diff_command':              ruby.string_array_value(result.diff_command)
		'status':                    ruby.object_value('Symbol', result.status)
		'message':                   ruby.string_value(result.message)
		'failed':                    ruby.bool_value(result.failed)
	})
}
