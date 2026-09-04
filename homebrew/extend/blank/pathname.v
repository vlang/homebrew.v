module blank

import ruby

// Translated from Homebrew/brew `extend/blank/pathname.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank?` at line 18.
pub fn ruby_pathname_l18_d1_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Pathname#blank? requires a receiver') }
	return ruby.bool_value(value_is_blank(args[0]))
}

// Ruby method `present? = !blank? # :nodoc:` at line 23.
pub fn ruby_pathname_l23_d2_present(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Pathname#present? requires a receiver') }
	return ruby.bool_value(value_is_present(args[0]))
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
