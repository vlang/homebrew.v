module completions

import homebrew.completions.subcommand

// Translated from Homebrew/brew `completions/subcommand.rb`.

// Ruby method `dispatch(args)` at line 16.
pub fn subcommand_dispatch(arguments []string, mut state subcommand.CompletionsState) !string {
	if arguments.len > 1 {
		return error('completions accepts at most one named argument')
	}
	name := if arguments.len == 0 { 'state' } else { arguments[0] }
	return match name {
		'link' { subcommand.link_completions(mut state) }
		'unlink' { subcommand.unlink_completions(mut state) }
		'state' { subcommand.completions_state_message(state) }
		else { error('unknown completions subcommand: ${name}') }
	}
}
