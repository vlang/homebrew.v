module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/generic_unar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_generic_unar_l10_d1_self_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extensions', ...args)
}

// Ruby method `self.can_extract?(_path)` at line 15.
pub fn ruby_generic_unar_l15_d2_self_can_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_extract?', ...args)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_generic_unar_l20_d3_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependencies', ...args)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_generic_unar_l27_d4_extract_to_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_to_dir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking archives with `unar`.
// 6:   class GenericUnar
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       []
// 12:     end
// 13:
// 14:     sig { override.params(_path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(_path)
// 16:       false
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["unar"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       system_command! "unar",
// 29:                       args:    [
// 30:                         "-force-overwrite", "-quiet", "-no-directory",
// 31:                         "-output-directory", unpack_dir, "--", path
// 32:                       ],
// 33:                       env:     Utils::Path.formula_opt_bin_env("unar"),
// 34:                       verbose:
// 35:     end
// 36:   end
// 37: end
