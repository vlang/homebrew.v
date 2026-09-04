module blank

import ruby

// Translated from Homebrew/brew `extend/blank/numeric.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = false` at line 12.
pub fn ruby_numeric_l12_d1_blank(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby method `present? = true` at line 15.
pub fn ruby_numeric_l15_d2_present(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Numeric # :nodoc:
// 5:   # No number is blank:
// 6:   #
// 7:   # ```ruby
// 8:   # 1.blank? # => false
// 9:   # 0.blank? # => false
// 10:   # ```
// 11:   sig { returns(FalseClass) }
// 12:   def blank? = false
// 13:
// 14:   sig { returns(TrueClass) }
// 15:   def present? = true
// 16: end
