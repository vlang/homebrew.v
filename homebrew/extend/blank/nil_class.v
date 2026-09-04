module blank

import ruby

// Translated from Homebrew/brew `extend/blank/nil_class.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = true` at line 11.
pub fn ruby_nil_class_l11_d1_blank(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby method `present? = false # :nodoc:` at line 14.
pub fn ruby_nil_class_l14_d2_present(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class NilClass
// 5:   # `nil` is blank:
// 6:   #
// 7:   # ```ruby
// 8:   # nil.blank? # => true
// 9:   # ```
// 10:   sig { returns(TrueClass) }
// 11:   def blank? = true
// 12:
// 13:   sig { returns(FalseClass) }
// 14:   def present? = false # :nodoc:
// 15: end
