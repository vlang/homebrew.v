module subcommand

import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand/on.rb`.

// Ruby method `run` at line 20.
pub fn enable_analytics(mut state utils.AnalyticsState) {
	state.enable()
}
