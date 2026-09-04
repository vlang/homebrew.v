module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/array.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `deep_dup` at line 14.
pub fn ruby_array_l14_d1_deep_dup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	return ruby.array_value(deep_dup_array_values(args[0].as_array() or { [] }))
}

// deep_dup_values translates Array#deep_dup using the shared recursive value
// copier used by Object#deep_dup.
pub fn deep_dup_array_values(values []ruby.Value) []ruby.Value {
	return values.map(deep_dup_value(it))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Array
// 5:   # Returns a deep copy of array.
// 6:   #
// 7:   #   array = [1, [2, 3]]
// 8:   #   dup   = array.deep_dup
// 9:   #   dup[1][2] = 4
// 10:   #
// 11:   #   array[1][2] # => nil
// 12:   #   dup[1][2]   # => 4
// 13:   sig { returns(T.self_type) }
// 14:   def deep_dup
// 15:     T.unsafe(self).map(&:deep_dup)
// 16:   end
// 17: end
