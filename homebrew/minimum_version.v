module homebrew

import brew_runtime

// Translated from Homebrew/brew `minimum_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.formula_outdated_kegs(formula, minimum_version, fetch_head:)` at line 14.
pub fn ruby_minimum_version_l14_d1_self_formula_outdated_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_outdated_kegs', ...args)
}

// Ruby method `self.cask_installed_below?(cask, minimum_version)` at line 25.
pub fn ruby_minimum_version_l25_d2_self_cask_installed_below(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_installed_below?', ...args)
}

// Ruby method `self.comparable_cask_version(version)` at line 39.
pub fn ruby_minimum_version_l39_d3_self_comparable_cask_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.comparable_cask_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/cask"
// 5: require "cask/dsl/version"
// 6: require "formula"
// 7: require "pkg_version"
// 8:
// 9: module Homebrew
// 10:   module MinimumVersion
// 11:     sig {
// 12:       params(formula: Formula, minimum_version: T.nilable(String), fetch_head: T::Boolean).returns(T::Array[Keg])
// 13:     }
// 14:     def self.formula_outdated_kegs(formula, minimum_version, fetch_head:)
// 15:       return formula.outdated_kegs(fetch_head:) if minimum_version.blank?
// 16:
// 17:       minimum_pkg_version = PkgVersion.parse(minimum_version)
// 18:       formula.installed_kegs.select do |keg|
// 19:         keg.version_scheme < formula.version_scheme ||
// 20:           (keg.version_scheme == formula.version_scheme && keg.version < minimum_pkg_version)
// 21:       end
// 22:     end
// 23:
// 24:     sig { params(cask: Cask::Cask, minimum_version: String).returns(T::Boolean) }
// 25:     def self.cask_installed_below?(cask, minimum_version)
// 26:       minimum_cask_version = comparable_cask_version(minimum_version)
// 27:       raise UsageError, "invalid `--minimum-version`: #{minimum_version}" if minimum_cask_version.nil?
// 28:
// 29:       installed_version = cask.installed_version
// 30:       return false if installed_version.blank?
// 31:
// 32:       installed_cask_version = comparable_cask_version(installed_version)
// 33:       return false if installed_cask_version.nil?
// 34:
// 35:       installed_cask_version < minimum_cask_version
// 36:     end
// 37:
// 38:     sig { params(version: String).returns(T.nilable(::Version)) }
// 39:     def self.comparable_cask_version(version)
// 40:       cask_version = Cask::DSL::Version.new(version)
// 41:       return if cask_version.latest?
// 42:
// 43:       ::Version.new(cask_version.to_s)
// 44:     rescue TypeError
// 45:       nil
// 46:     end
// 47:     private_class_method :comparable_cask_version
// 48:   end
// 49: end
