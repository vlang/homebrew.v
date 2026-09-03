module utils

import time

// Translated from Homebrew/brew `utils/timer.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn timer_monotonic_time() f64 {
	return f64(time.sys_mono_now()) / 1_000_000_000.0
}

pub fn timer_remaining_at(deadline ?f64, now f64) ?f64 {
	end := deadline or { return none }
	return if end > now { end - now } else { 0.0 }
}

pub fn timer_remaining(deadline ?f64) ?f64 {
	return timer_remaining_at(deadline, timer_monotonic_time())
}

pub struct TimerRemaining {
pub:
	seconds   f64
	has_value bool
}

pub fn timer_remaining_or_error_at(deadline ?f64, now f64) !TimerRemaining {
	remaining := timer_remaining_at(deadline, now) or { return TimerRemaining{} }
	if remaining <= 0 {
		return error('execution expired')
	}
	return TimerRemaining{
		seconds: remaining
		has_value: true
	}
}

pub fn timer_remaining_or_error(deadline ?f64) !TimerRemaining {
	return timer_remaining_or_error_at(deadline, timer_monotonic_time())
}

// Ruby method `self.remaining(time)` at line 7.
pub fn ruby_timer_l7_d1_self_remaining(deadline ?f64) ?f64 {
	return timer_remaining(deadline)
}

// Ruby method `self.remaining!(time)` at line 14.
pub fn ruby_timer_l14_d2_self_remaining(deadline ?f64) !TimerRemaining {
	return timer_remaining_or_error(deadline)
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
