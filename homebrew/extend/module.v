module extend

import brew_runtime

// Translated from Homebrew/brew `extend/module.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `exclude?(mod) = !include?(mod)` at line 10.
pub fn ruby_module_l10_d1_exclude(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exclude?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Module
// 5:   include T::Sig
// 6:
// 7:   # The inverse of <tt>Module#include?</tt>. Returns true if the module
// 8:   # does not include the other module.
// 9:   sig { params(mod: T::Module[T.anything]).returns(T::Boolean) }
// 10:   def exclude?(mod) = !include?(mod)
// 11: end
