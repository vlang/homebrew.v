module utility

import brew_runtime
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/monotonic_time.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn monotonic_time(unit string) !brew_runtime.Value {
	nanoseconds := time.sys_mono_now()
	return match unit.trim_left(':') {
		'', 'float_second' { brew_runtime.float_value(f64(nanoseconds) / 1_000_000_000.0) }
		'float_millisecond' { brew_runtime.float_value(f64(nanoseconds) / 1_000_000.0) }
		'float_microsecond' { brew_runtime.float_value(f64(nanoseconds) / 1_000.0) }
		'second' { brew_runtime.int_value(i64(nanoseconds / 1_000_000_000)) }
		'millisecond' { brew_runtime.int_value(i64(nanoseconds / 1_000_000)) }
		'microsecond' { brew_runtime.int_value(i64(nanoseconds / 1_000)) }
		'nanosecond' { brew_runtime.int_value(i64(nanoseconds)) }
		else { error('unexpected unit: ${unit}') }
	}
}

// Ruby method `monotonic_time(unit = :float_second)` at line 15.
pub fn ruby_monotonic_time_l15_d1_monotonic_time(args ...brew_runtime.Value) brew_runtime.Value {
	unit := if args.len > 0 { args[0].as_string() } else { 'float_second' }
	return monotonic_time(unit) or { panic(err) }
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   # @!macro monotonic_get_time
// 4:   #
// 5:   #   Returns the current time as tracked by the application monotonic clock.
// 6:   #
// 7:   #   @param [Symbol] unit the time unit to be returned, can be either
// 8:   #     :float_second, :float_millisecond, :float_microsecond, :second,
// 9:   #     :millisecond, :microsecond, or :nanosecond default to :float_second.
// 10:   #
// 11:   #   @return [Float] The current monotonic time since some unspecified
// 12:   #     starting point
// 13:   #
// 14:   #   @!macro monotonic_clock_warning
// 15:   def monotonic_time(unit = :float_second)
// 16:     Process.clock_gettime(Process::CLOCK_MONOTONIC, unit)
// 17:   end
// 18:   module_function :monotonic_time
// 19: end
