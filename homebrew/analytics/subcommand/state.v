module subcommand

import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand/state.rb`.

// Ruby method `run` at line 20.
pub fn analytics_state_message(state utils.AnalyticsState) string {
	status := if state.disabled() { 'disabled' } else { 'enabled' }
	return 'InfluxDB analytics are ${status}.\nGoogle Analytics were destroyed.\n'
}
