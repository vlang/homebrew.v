module blank

import brew_runtime

// Translated from Homebrew/brew `extend/blank/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = empty?` at line 13.
pub fn ruby_hash_l13_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `present? = !empty? # :nodoc:` at line 16.
pub fn ruby_hash_l16_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
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
