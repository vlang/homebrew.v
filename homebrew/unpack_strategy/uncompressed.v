module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/uncompressed.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions = []` at line 10.
pub fn ruby_uncompressed_l10_d1_self_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extensions', ...args)
}

// Ruby method `self.can_extract?(_path) = false` at line 13.
pub fn ruby_uncompressed_l13_d2_self_can_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_extract?', ...args)
}

// Ruby method `extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)` at line 23.
pub fn ruby_uncompressed_l23_d3_extract_nestedly(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_nestedly', ...args)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose: false)` at line 30.
pub fn ruby_uncompressed_l30_d4_extract_to_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_to_dir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking uncompressed files.
// 6:   class Uncompressed
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions = []
// 11:
// 12:     sig { override.params(_path: Pathname).returns(T::Boolean) }
// 13:     def self.can_extract?(_path) = false
// 14:
// 15:     sig {
// 16:       params(
// 17:         to:                   T.nilable(Pathname),
// 18:         basename:             T.nilable(T.any(String, Pathname)),
// 19:         verbose:              T::Boolean,
// 20:         prioritize_extension: T::Boolean,
// 21:       ).returns(T.untyped)
// 22:     }
// 23:     def extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)
// 24:       extract(to:, basename:, verbose:)
// 25:     end
// 26:
// 27:     private
// 28:
// 29:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 30:     def extract_to_dir(unpack_dir, basename:, verbose: false)
// 31:       FileUtils.cp path, unpack_dir/basename.sub(/^[\da-f]{64}--/, ""), preserve: true, verbose:
// 32:     end
// 33:   end
// 34: end
