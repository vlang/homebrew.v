module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/pkg.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_pkg_l10_d1_self_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extensions', ...args)
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_pkg_l15_d2_self_can_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_extract?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking macOS package installers.
// 8:   class Pkg < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".pkg", ".mkpg"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.extname.match?(/\A.m?pkg\Z/) &&
// 17:         (path.directory? || path.magic_number.match?(/\Axar!/n))
// 18:     end
// 19:   end
// 20: end
