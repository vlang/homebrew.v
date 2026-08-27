module util

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/power_of_two_tuple.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(size)` at line 15.
pub fn ruby_power_of_two_tuple_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `hash_to_index(hash)` at line 20.
pub fn ruby_power_of_two_tuple_l20_d2_hash_to_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash_to_index', ...args)
}

// Ruby method `volatile_get_by_hash(hash)` at line 24.
pub fn ruby_power_of_two_tuple_l24_d3_volatile_get_by_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('volatile_get_by_hash', ...args)
}

// Ruby method `volatile_set_by_hash(hash, value)` at line 28.
pub fn ruby_power_of_two_tuple_l28_d4_volatile_set_by_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('volatile_set_by_hash', ...args)
}

// Ruby method `next_in_size_table` at line 32.
pub fn ruby_power_of_two_tuple_l32_d5_next_in_size_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('next_in_size_table', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/tuple'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!visibility private
// 7:   module ThreadSafe
// 8:
// 9:     # @!visibility private
// 10:     module Util
// 11:
// 12:       # @!visibility private
// 13:       class PowerOfTwoTuple < Concurrent::Tuple
// 14:
// 15:         def initialize(size)
// 16:           raise ArgumentError, "size must be a power of 2 (#{size.inspect} provided)" unless size > 0 && size & (size - 1) == 0
// 17:           super(size)
// 18:         end
// 19:
// 20:         def hash_to_index(hash)
// 21:           (size - 1) & hash
// 22:         end
// 23:
// 24:         def volatile_get_by_hash(hash)
// 25:           volatile_get(hash_to_index(hash))
// 26:         end
// 27:
// 28:         def volatile_set_by_hash(hash, value)
// 29:           volatile_set(hash_to_index(hash), value)
// 30:         end
// 31:
// 32:         def next_in_size_table
// 33:           self.class.new(size << 1)
// 34:         end
// 35:       end
// 36:     end
// 37:   end
// 38: end
