module subcommand

// Translated from Homebrew/brew `developer/subcommand/off.rb`.

// Ruby method `run` at line 22.
pub fn disable_developer_mode(mut state DeveloperState) string {
	state.devcmdrun = false
	if state.developer_environment {
		return 'To fully disable developer mode, you must unset HOMEBREW_DEVELOPER.\n'
	}
	return ''
}
