module analytics

import homebrew.analytics.subcommand
import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand.rb`.

// Ruby method `dispatch(args)` at line 16.
pub fn subcommand_dispatch(arguments []string, mut state utils.AnalyticsState) !string {
	if arguments.len > 1 {
		return error('analytics accepts at most one named argument')
	}
	name := if arguments.len == 0 { 'state' } else { arguments[0] }
	match name {
		'on' {
			subcommand.enable_analytics(mut state)
			return ''
		}
		'off' {
			subcommand.disable_analytics(mut state)
			return ''
		}
		'state' {
			return subcommand.analytics_state_message(state)
		}
		'regenerate-uuid' {
			return subcommand.regenerate_analytics_uuid()
		}
		else {
			return error('unknown analytics subcommand: ${name}')
		}
	}
}
