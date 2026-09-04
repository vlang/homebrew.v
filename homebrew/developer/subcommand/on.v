module subcommand

// Translated from Homebrew/brew `developer/subcommand/on.rb`.

// Ruby method `run` at line 22.
pub fn enable_developer_mode(mut state DeveloperState) string {
	state.devcmdrun = true
	if state.update_to_tag {
		return 'To fully enable developer mode, you must unset HOMEBREW_UPDATE_TO_TAG.\n'
	}
	return ''
}
