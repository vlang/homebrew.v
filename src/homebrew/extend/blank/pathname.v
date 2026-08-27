module blank

import brew_runtime

// Translated from Homebrew/brew `extend/blank/pathname.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank?` at line 18.
pub fn ruby_pathname_l18_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `present? = !blank? # :nodoc:` at line 23.
pub fn ruby_pathname_l23_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Pathname
// 5:   # A Pathname is blank if its path is empty. Unlike `Pathname#empty?`,
// 6:   # this never touches the filesystem, so an existing-but-empty file or
// 7:   # directory is still present.
// 8:   #
// 9:   # ```ruby
// 10:   # Pathname.new("").blank?     # => true
// 11:   # Pathname.new(" ").blank?    # => false
// 12:   # Pathname.new("test").blank? # => false
// 13:   # ```
// 14:   #
// 15:   # @see https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/pathname/blank.rb
// 16:   #   `Pathname#blank?`
// 17:   sig { returns(T::Boolean) }
// 18:   def blank?
// 19:     to_s.empty?
// 20:   end
// 21:
// 22:   sig { returns(T::Boolean) }
// 23:   def present? = !blank? # :nodoc:
// 24: end
