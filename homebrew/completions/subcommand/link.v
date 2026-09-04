module subcommand

// Translated from Homebrew/brew `completions/subcommand/link.rb`.

// Ruby method `run` at line 20.
pub fn link_completions(mut state CompletionsState) string {
	state.linked = true
	return 'Completions are now linked.\n'
}
