module duplicable

import brew_runtime

// Translated from Homebrew/brew `extend/object/duplicable/singleton.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `duplicable? = false` at line 11.
pub fn ruby_singleton_l11_d1_duplicable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('duplicable?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Singleton
// 5:   # Singleton instances are not duplicable:
// 6:   #
// 7:   # ```ruby
// 8:   # Class.new.include(Singleton).instance.dup # TypeError (can't dup instance of singleton
// 9:   # ```
// 10:   sig { returns(FalseClass) }
// 11:   def duplicable? = false
// 12: end
