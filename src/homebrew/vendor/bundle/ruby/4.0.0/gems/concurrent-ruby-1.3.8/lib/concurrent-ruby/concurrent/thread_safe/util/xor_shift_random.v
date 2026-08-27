module util

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/xor_shift_random.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `get` at line 27.
pub fn ruby_xor_shift_random_l27_d1_get(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get', ...args)
}

// Ruby method `xorshift(x)` at line 34.
pub fn ruby_xor_shift_random_l34_d2_xorshift(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xorshift', ...args)
}

// Ruby method `xorshift(x)` at line 41.
pub fn ruby_xor_shift_random_l41_d3_xorshift(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xorshift', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module ThreadSafe
// 7:
// 8:     # @!visibility private
// 9:     module Util
// 10:
// 11:       # A xorshift random number (positive +Fixnum+s) generator, provides
// 12:       # reasonably cheap way to generate thread local random numbers without
// 13:       # contending for the global +Kernel.rand+.
// 14:       #
// 15:       # Usage:
// 16:       #   x = XorShiftRandom.get # uses Kernel.rand to generate an initial seed
// 17:       #   while true
// 18:       #     if (x = XorShiftRandom.xorshift).odd? # thread-locally generate a next random number
// 19:       #       do_something_at_random
// 20:       #     end
// 21:       #   end
// 22:       module XorShiftRandom
// 23:         extend self
// 24:         MAX_XOR_SHIFTABLE_INT = MAX_INT - 1
// 25:
// 26:         # Generates an initial non-zero positive +Fixnum+ via +Kernel.rand+.
// 27:         def get
// 28:           Kernel.rand(MAX_XOR_SHIFTABLE_INT) + 1 # 0 can't be xorshifted
// 29:         end
// 30:
// 31:         # xorshift based on: http://www.jstatsoft.org/v08/i14/paper
// 32:         if 0.size == 4
// 33:           # using the "yˆ=y>>a; yˆ=y<<b; yˆ=y>>c;" transform with the (a,b,c) tuple with values (3,1,14) to minimise Bignum overflows
// 34:           def xorshift(x)
// 35:             x ^= x >> 3
// 36:             x ^= (x << 1) & MAX_INT # cut-off Bignum overflow
// 37:             x ^= x >> 14
// 38:           end
// 39:         else
// 40:           # using the "yˆ=y>>a; yˆ=y<<b; yˆ=y>>c;" transform with the (a,b,c) tuple with values (1,1,54) to minimise Bignum overflows
// 41:           def xorshift(x)
// 42:             x ^= x >> 1
// 43:             x ^= (x << 1) & MAX_INT # cut-off Bignum overflow
// 44:             x ^= x >> 54
// 45:           end
// 46:         end
// 47:       end
// 48:     end
// 49:   end
// 50: end
