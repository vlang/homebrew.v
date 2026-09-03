module duplicable

import brew_runtime

// Translated from Homebrew/brew `extend/object/duplicable/unbound_method.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `duplicable? = false` at line 12.
pub fn ruby_unbound_method_l12_d1_duplicable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

pub fn unbound_method_is_duplicable() bool {
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class UnboundMethod
// 5:   # Unbound methods are not duplicable:
// 6:   #
// 7:   # ```ruby
// 8:   # method(:puts).unbind.duplicable? # => false
// 9:   # method(:puts).unbind.dup         # => TypeError: allocator undefined for UnboundMethod
// 10:   # ```
// 11:   sig { returns(FalseClass) }
// 12:   def duplicable? = false
// 13: end
