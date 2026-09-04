module subcommand

// Translated from Homebrew/brew `completions/subcommand/state.rb`.
pub struct CompletionsState {
pub mut:
	linked bool
}

// Ruby method `run` at line 20.
pub fn completions_state_message(state CompletionsState) string {
	return if state.linked {
		'Completions are linked.\n'
	} else {
		'Completions are not linked.\n'
	}
}
