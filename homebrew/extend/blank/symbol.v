module blank

import ruby

// Translated from Homebrew/brew `extend/blank/symbol.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = empty?` at line 12.
pub fn ruby_symbol_l12_d1_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Symbol#blank? requires a receiver') }
	return ruby.bool_value(value_is_blank(args[0]))
}

// Ruby method `present? = !empty? # :nodoc:` at line 15.
pub fn ruby_symbol_l15_d2_present(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Symbol#present? requires a receiver') }
	return ruby.bool_value(value_is_present(args[0]))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Symbol
// 5:   # A Symbol is blank if it's empty:
// 6:   #
// 7:   # ```ruby
// 8:   # :''.blank?     # => true
// 9:   # :symbol.blank? # => false
// 10:   # ```
// 11:   sig { returns(T::Boolean) }
// 12:   def blank? = empty?
// 13:
// 14:   sig { returns(T::Boolean) }
// 15:   def present? = !empty? # :nodoc:
// 16: end
