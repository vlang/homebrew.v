module utils

import time

// Translated from Homebrew/brew `utils/timer.rb`.
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
