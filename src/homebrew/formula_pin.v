module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_pin.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 9.
pub fn ruby_formula_pin_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `path` at line 14.
pub fn ruby_formula_pin_l14_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby method `pin_at(version)` at line 19.
pub fn ruby_formula_pin_l19_d3_pin_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pin_at', ...args)
}

// Ruby method `pin` at line 26.
pub fn ruby_formula_pin_l26_d4_pin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pin', ...args)
}

// Ruby method `unpin` at line 34.
pub fn ruby_formula_pin_l34_d5_unpin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpin', ...args)
}

// Ruby method `pinned?` at line 40.
pub fn ruby_formula_pin_l40_d6_pinned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pinned?', ...args)
}

// Ruby method `pinnable?` at line 45.
pub fn ruby_formula_pin_l45_d7_pinnable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pinnable?', ...args)
}

// Ruby method `pinned_version` at line 50.
pub fn ruby_formula_pin_l50_d8_pinned_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pinned_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5:
// 6: # Helper functions for pinning a formula.
// 7: class FormulaPin
// 8:   sig { params(formula: Formula).void }
// 9:   def initialize(formula)
// 10:     @formula = formula
// 11:   end
// 12:
// 13:   sig { returns(Pathname) }
// 14:   def path
// 15:     HOMEBREW_PINNED_KEGS/@formula.name
// 16:   end
// 17:
// 18:   sig { params(version: PkgVersion).void }
// 19:   def pin_at(version)
// 20:     HOMEBREW_PINNED_KEGS.mkpath
// 21:     version_path = @formula.rack/version.to_s
// 22:     path.make_relative_symlink(version_path) if !pinned? && version_path.exist?
// 23:   end
// 24:
// 25:   sig { void }
// 26:   def pin
// 27:     latest_keg = @formula.installed_kegs.max_by(&:scheme_and_version)
// 28:     return if latest_keg.nil?
// 29:
// 30:     pin_at(latest_keg.version)
// 31:   end
// 32:
// 33:   sig { void }
// 34:   def unpin
// 35:     path.unlink if pinned?
// 36:     HOMEBREW_PINNED_KEGS.rmdir_if_possible
// 37:   end
// 38:
// 39:   sig { returns(T::Boolean) }
// 40:   def pinned?
// 41:     path.symlink?
// 42:   end
// 43:
// 44:   sig { returns(T::Boolean) }
// 45:   def pinnable?
// 46:     !@formula.installed_prefixes.empty?
// 47:   end
// 48:
// 49:   sig { returns(T.nilable(PkgVersion)) }
// 50:   def pinned_version
// 51:     Keg.new(path.resolved_path).version if pinned?
// 52:   end
// 53: end
