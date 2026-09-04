module subcommand

// Translated from Homebrew/brew `developer/subcommand/state.rb`.

// DeveloperState is the process-independent form of EnvConfig's three inputs
// used by the developer subcommands. Keeping the setting mutable models the
// devcmdrun Settings.write/delete calls without hiding state in globals.
pub struct DeveloperState {
pub mut:
	developer_environment bool
	devcmdrun             bool
	update_to_tag         bool
}

// Ruby method `run` at line 21.
pub fn developer_state_message(state DeveloperState) string {
	mut lines := []string{}
	if state.developer_environment {
		lines << 'Developer mode is enabled because HOMEBREW_DEVELOPER is set.'
	} else if state.devcmdrun {
		lines << 'Developer mode is enabled because a developer command or `brew developer on` was run.'
	} else {
		lines << 'Developer mode is disabled.'
	}

	if state.developer_environment || state.devcmdrun {
		if state.update_to_tag {
			lines << 'However, `brew update` will update to the latest stable tag because HOMEBREW_UPDATE_TO_TAG is set.'
		} else {
			lines << '`brew update` will update to the latest commit on the `main` branch.'
		}
	} else {
		lines << '`brew update` will update to the latest stable tag.'
	}
	return lines.join('\n') + '\n'
}
