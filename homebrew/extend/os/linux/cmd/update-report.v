module cmd

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cmd/update-report.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `no_changes_message` at line 8.
pub fn ruby_update_report_l8_d1_no_changes_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_changes_message', ...args)
}

// Ruby method `migrate_gcc_dependents_if_needed` at line 13.
pub fn ruby_update_report_l13_d2_migrate_gcc_dependents_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrate_gcc_dependents_if_needed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module_function
// 6:
// 7:   sig { returns(String) }
// 8:   def no_changes_message
// 9:     "No changes to formulae."
// 10:   end
// 11:
// 12:   sig { void }
// 13:   def migrate_gcc_dependents_if_needed
// 14:     return if Settings.read("gcc-rpaths.fixed") == "true"
// 15:
// 16:     Formula.installed.each do |formula|
// 17:       next unless formula.tap&.core_tap?
// 18:
// 19:       recursive_runtime_dependencies = Dependency.expand(
// 20:         formula,
// 21:         cache_key: "update-report",
// 22:       ) do |_, dependency|
// 23:         next Dependable::PRUNE if dependency.build? || dependency.test?
// 24:       end
// 25:       next unless recursive_runtime_dependencies.map(&:name).include? "gcc"
// 26:
// 27:       keg = formula.installed_kegs.fetch(-1)
// 28:       tab = keg.tab
// 29:       # Force reinstallation upon `brew upgrade` to fix the bottle RPATH.
// 30:       tab.source["versions"]["version_scheme"] = -1
// 31:       tab.write
// 32:     rescue TapFormulaUnavailableError
// 33:       nil
// 34:     end
// 35:
// 36:     Settings.write "gcc-rpaths.fixed", true
// 37:   end
// 38: end
