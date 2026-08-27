module utils

import brew_runtime

// Translated from Homebrew/brew `utils/timer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.remaining(time)` at line 7.
pub fn ruby_timer_l7_d1_self_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remaining', ...args)
}

// Ruby method `self.remaining!(time)` at line 14.
pub fn ruby_timer_l14_d2_self_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remaining!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   module Timer
// 6:     sig { params(time: T.nilable(Time)).returns(T.nilable(T.any(Float, Integer))) }
// 7:     def self.remaining(time)
// 8:       return unless time
// 9:
// 10:       [0, time - Time.now].max
// 11:     end
// 12:
// 13:     sig { params(time: T.nilable(Time)).returns(T.nilable(T.any(Float, Integer))) }
// 14:     def self.remaining!(time)
// 15:       r = remaining(time)
// 16:       raise Timeout::Error if r && r <= 0
// 17:
// 18:       r
// 19:     end
// 20:   end
// 21: end
