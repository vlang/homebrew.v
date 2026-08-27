module blank

import brew_runtime

// Translated from Homebrew/brew `extend/blank/time.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank? = false` at line 11.
pub fn ruby_time_l11_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `present? = true` at line 14.
pub fn ruby_time_l14_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
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
