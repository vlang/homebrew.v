module duplicable

import ruby

// Translated from Homebrew/brew `extend/object/duplicable/method.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `duplicable? = false` at line 12.
pub fn ruby_method_l12_d1_duplicable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

pub fn method_is_duplicable() bool {
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Method
// 5:   # Methods are not duplicable:
// 6:   #
// 7:   # ```ruby
// 8:   # method(:puts).duplicable? # => false
// 9:   # method(:puts).dup         # => TypeError: allocator undefined for Method
// 10:   # ```
// 11:   sig { returns(FalseClass) }
// 12:   def duplicable? = false
// 13: end
