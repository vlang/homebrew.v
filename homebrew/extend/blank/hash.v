module blank

import ruby

// Translated from Homebrew/brew `extend/blank/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = empty?` at line 13.
pub fn ruby_hash_l13_d1_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Hash#blank? requires a receiver') }
	return ruby.bool_value(value_is_blank(args[0]))
}

// Ruby method `present? = !empty? # :nodoc:` at line 16.
pub fn ruby_hash_l16_d2_present(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Hash#present? requires a receiver') }
	return ruby.bool_value(value_is_present(args[0]))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # A hash is blank if it's empty:
// 6:   #
// 7:   #
// 8:   # ```ruby
// 9:   # {}.blank?                # => true
// 10:   # { key: 'value' }.blank?  # => false
// 11:   # ```
// 12:   sig { returns(T::Boolean) }
// 13:   def blank? = empty?
// 14:
// 15:   sig { returns(T::Boolean) }
// 16:   def present? = !empty? # :nodoc:
// 17: end
