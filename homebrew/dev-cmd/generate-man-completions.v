module dev_cmd

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
