module extend

import ruby

// Translated from Homebrew/brew `extend/string.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn string_excludes(input string, substring string) bool {
	return !input.contains(substring)
}

// Ruby method `exclude?(string) = !include?(string)` at line 12.
pub fn ruby_string_l12_d1_exclude(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('String#exclude? requires a receiver and string')
	}
	return ruby.bool_value(string_excludes(args[0].as_string(), args[1].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class String
// 5:   # The inverse of <tt>String#include?</tt>. Returns true if the string
// 6:   # does not include the other string.
// 7:   #
// 8:   #   "hello".exclude? "lo" # => false
// 9:   #   "hello".exclude? "ol" # => true
// 10:   #   "hello".exclude? ?h   # => false
// 11:   sig { params(string: String).returns(T::Boolean) }
// 12:   def exclude?(string) = !include?(string)
// 13: end
