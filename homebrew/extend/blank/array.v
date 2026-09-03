module blank

import brew_runtime

// Translated from Homebrew/brew `extend/blank/array.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = empty?` at line 12.
pub fn ruby_array_l12_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Array#blank? requires a receiver') }
	return brew_runtime.bool_value(value_is_blank(args[0]))
}

// Ruby method `present? = !empty? # :nodoc:` at line 15.
pub fn ruby_array_l15_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Array#present? requires a receiver') }
	return brew_runtime.bool_value(value_is_present(args[0]))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Array
// 5:   # An array is blank if it's empty:
// 6:   #
// 7:   # ```ruby
// 8:   # [].blank?      # => true
// 9:   # [1,2,3].blank? # => false
// 10:   # ```
// 11:   sig { returns(T::Boolean) }
// 12:   def blank? = empty?
// 13:
// 14:   sig { returns(T::Boolean) }
// 15:   def present? = !empty? # :nodoc:
// 16: end
