module logger

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger/period.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `next_rotate_time(now, shift_age)` at line 9.
pub fn ruby_period_l9_d1_next_rotate_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('next_rotate_time', ...args)
}

// Ruby method `previous_period_end(now, shift_age)` at line 31.
pub fn ruby_period_l31_d2_previous_period_end(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('previous_period_end', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: class Logger
// 4:   module Period
// 5:     module_function
// 6:
// 7:     SiD = 24 * 60 * 60
// 8:
// 9:     def next_rotate_time(now, shift_age)
// 10:       case shift_age
// 11:       when 'daily', :daily
// 12:         t = Time.mktime(now.year, now.month, now.mday) + SiD
// 13:       when 'weekly', :weekly
// 14:         t = Time.mktime(now.year, now.month, now.mday) + SiD * (7 - now.wday)
// 15:       when 'monthly', :monthly
// 16:         t = Time.mktime(now.year, now.month, 1) + SiD * 32
// 17:         return Time.mktime(t.year, t.month, 1)
// 18:       when 'now', 'everytime', :now, :everytime
// 19:         return now
// 20:       else
// 21:         raise ArgumentError, "invalid :shift_age #{shift_age.inspect}, should be daily, weekly, monthly, or everytime"
// 22:       end
// 23:       if t.hour.nonzero? or t.min.nonzero? or t.sec.nonzero?
// 24:         hour = t.hour
// 25:         t = Time.mktime(t.year, t.month, t.mday)
// 26:         t += SiD if hour > 12
// 27:       end
// 28:       t
// 29:     end
// 30:
// 31:     def previous_period_end(now, shift_age)
// 32:       case shift_age
// 33:       when 'daily', :daily
// 34:         t = Time.mktime(now.year, now.month, now.mday) - SiD / 2
// 35:       when 'weekly', :weekly
// 36:         t = Time.mktime(now.year, now.month, now.mday) - (SiD * now.wday + SiD / 2)
// 37:       when 'monthly', :monthly
// 38:         t = Time.mktime(now.year, now.month, 1) - SiD / 2
// 39:       when 'now', 'everytime', :now, :everytime
// 40:         return now
// 41:       else
// 42:         raise ArgumentError, "invalid :shift_age #{shift_age.inspect}, should be daily, weekly, monthly, or everytime"
// 43:       end
// 44:       Time.mktime(t.year, t.month, t.mday, 23, 59, 59)
// 45:     end
// 46:   end
// 47: end
