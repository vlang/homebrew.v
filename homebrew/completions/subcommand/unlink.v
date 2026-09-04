module subcommand

// Translated from Homebrew/brew `completions/subcommand/unlink.rb`.

// Ruby method `run` at line 20.
pub fn unlink_completions(mut state CompletionsState) string {
	state.linked = false
	return 'Completions are no longer linked.\n'
}
