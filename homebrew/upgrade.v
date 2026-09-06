module homebrew

import ruby
import homebrew.upgrade_helpers

pub struct UpgradeExecutionResult {
pub:
	success bool
	values  []ruby.Value
	stdout  string
	stderr  string
}

pub fn upgrade_format_summary(upgrades []string) []string {
	return upgrade_helpers.format_summary(upgrades)
}

// Translated from Homebrew/brew `upgrade.rb`.
