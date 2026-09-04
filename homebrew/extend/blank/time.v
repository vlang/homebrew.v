module blank

import ruby

// Translated from Homebrew/brew `extend/blank/time.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = false` at line 11.
pub fn ruby_time_l11_d1_blank(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby method `present? = true` at line 14.
pub fn ruby_time_l14_d2_present(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Time # :nodoc:
// 5:   # No Time is blank:
// 6:   #
// 7:   # ```ruby
// 8:   # Time.now.blank? # => false
// 9:   # ```
// 10:   sig { returns(FalseClass) }
// 11:   def blank? = false
// 12:
// 13:   sig { returns(TrueClass) }
// 14:   def present? = true
// 15: end
