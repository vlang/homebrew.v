module developer

import homebrew.developer.subcommand

// Translated from Homebrew/brew `developer/subcommand.rb`.

// Ruby method `dispatch(args)` at line 16.
pub fn subcommand_dispatch(arguments []string, mut state subcommand.DeveloperState) !string {
	if arguments.len > 1 {
		return error('developer accepts at most one named argument')
	}
	name := if arguments.len == 0 { 'state' } else { arguments[0] }
	return match name {
		'on' { subcommand.enable_developer_mode(mut state) }
		'off' { subcommand.disable_developer_mode(mut state) }
		'state' { subcommand.developer_state_message(state) }
		else { error('unknown developer subcommand: ${name}') }
	}
}
