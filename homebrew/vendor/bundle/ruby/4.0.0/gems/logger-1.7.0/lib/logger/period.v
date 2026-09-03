module logger

import brew_runtime
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger/period.rb`.
// The original source is retained below until every stub has a typed V body.
const seconds_in_day = 24 * 60 * 60

fn midnight(value time.Time) time.Time {
	return time.new(time.Time{
		year: value.year
		month: value.month
		day: value.day
		is_local: value.is_local
	})
}

pub fn next_rotate_time(now time.Time, shift_age string) !time.Time {
	mut rotated := match shift_age.to_lower() {
		'daily' { midnight(now).add_days(1) }
		'weekly' { midnight(now).add_days(7 - now.day_of_week() % 7) }
		'monthly' {
			probe := time.new(time.Time{
				year: now.year
				month: now.month
				day: 1
				is_local: now.is_local
			}).add_days(32)
			return time.new(time.Time{
				year: probe.year
				month: probe.month
				day: 1
				is_local: now.is_local
			})
		}
		'now', 'everytime' {
			return now
		}
		else {
			return error('invalid :shift_age `${shift_age}`, should be daily, weekly, monthly, or everytime')
		}
	}
	// Ruby reconstructs the date when adding a nominal day crosses a daylight
	// saving transition, advancing a date when the intermediate hour is late.
	if rotated.hour != 0 || rotated.minute != 0 || rotated.second != 0 {
		hour := rotated.hour
		rotated = midnight(rotated)
		if hour > 12 {
			rotated = rotated.add_days(1)
		}
	}
	return rotated
}

pub fn previous_period_end(now time.Time, shift_age string) !time.Time {
	if shift_age in ['now', 'everytime'] {
		return now
	}
	base := match shift_age.to_lower() {
		'daily' { midnight(now).add_seconds(-seconds_in_day / 2) }
		'weekly' {
			midnight(now).add_seconds(-(seconds_in_day * (now.day_of_week() % 7) + seconds_in_day / 2))
		}
		'monthly' {
			time.new(time.Time{
				year: now.year
				month: now.month
				day: 1
				is_local: now.is_local
			}).add_seconds(-seconds_in_day / 2)
		}
		else {
			return error('invalid :shift_age `${shift_age}`, should be daily, weekly, monthly, or everytime')
		}
	}
	return time.new(time.Time{
		year: base.year
		month: base.month
		day: base.day
		hour: 23
		minute: 59
		second: 59
		is_local: now.is_local
	})
}

fn period_value_time(value brew_runtime.Value) time.Time {
	if value.type_name == 'Integer' {
		return time.unix(value.as_int() or { 0 })
	}
	return time.parse_iso8601(value.as_string()) or { panic('invalid Logger period time `${value.as_string()}`') }
}

// Ruby method `next_rotate_time(now, shift_age)` at line 9.
pub fn ruby_period_l9_d1_next_rotate_time(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Logger::Period.next_rotate_time requires a time and shift age')
	}
	return brew_runtime.int_value(next_rotate_time(period_value_time(args[0]), args[1].as_string()) or {
		panic(err)
	}.unix())
}

// Ruby method `previous_period_end(now, shift_age)` at line 31.
pub fn ruby_period_l31_d2_previous_period_end(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Logger::Period.previous_period_end requires a time and shift age')
	}
	return brew_runtime.int_value(previous_period_end(period_value_time(args[0]), args[1].as_string()) or {
		panic(err)
	}.unix())
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
