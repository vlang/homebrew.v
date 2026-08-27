module blank

import brew_runtime

// Translated from Homebrew/brew `extend/blank/symbol.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = empty?` at line 12.
pub fn ruby_symbol_l12_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `present? = !empty? # :nodoc:` at line 15.
pub fn ruby_symbol_l15_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
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
