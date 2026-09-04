module subcommand

import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand/off.rb`.

// Ruby method `run` at line 20.
pub fn disable_analytics(mut state utils.AnalyticsState) {
	state.disable()
}
