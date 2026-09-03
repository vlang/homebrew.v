module logger

import brew_runtime
import os
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger/formatter.rb`.
// The original source is retained below until every stub has a typed V body.
pub const default_datetime_format = '%Y-%m-%dT%H:%M:%S.%6N'

pub struct Formatter {
pub mut:
	datetime_format string
}

pub fn new_formatter() Formatter {
	return Formatter{}
}

pub fn (formatter Formatter) format_datetime(value time.Time) string {
	format := if formatter.datetime_format.len > 0 {
		formatter.datetime_format
	} else {
		default_datetime_format
	}
	// POSIX strftime has no Ruby `%N` directive. Substitute Ruby's six-digit
	// nanosecond precision after strftime has expanded the remaining fields.
	placeholder := '__LOGGER_MICROSECONDS__'
	formatted := value.strftime(format.replace('%6N', placeholder))
	return formatted.replace(placeholder, '${value.nanosecond / 1_000:06}')
}

pub fn message_to_string(message brew_runtime.Value) string {
	if message.type_name == 'String' {
		return message.as_string()
	}
	if message.type_name == 'Exception' {
		exception_message := message.attribute('message') or { message.as_string() }
		exception_class := message.attribute('class') or { 'Exception' }
		backtrace := message.attribute('backtrace') or { '' }
		if backtrace.len > 0 {
			return '${exception_message} (${exception_class})\n${backtrace}'
		}
		return '${exception_message} (${exception_class})\n'
	}
	return message.as_string()
}

pub fn (formatter Formatter) call(severity string, at time.Time, progname string, message brew_runtime.Value) string {
	initial := if severity.len > 0 { severity[..1] } else { '' }
	return '${initial}, [${formatter.format_datetime(at)} #${os.getpid()}] ${severity:5} -- ${progname}: ${message_to_string(message)}\n'
}

fn formatter_from_value(value brew_runtime.Value) Formatter {
	return Formatter{
		datetime_format: value.attribute('datetime_format') or { '' }
	}
}

fn formatter_value(formatter Formatter) brew_runtime.Value {
	return brew_runtime.structured_value('Logger::Formatter', '#<Logger::Formatter>', {
		'datetime_format': formatter.datetime_format
	})
}

fn value_time(value brew_runtime.Value) time.Time {
	if value.type_name == 'Integer' {
		return time.unix(value.as_int() or { 0 })
	}
	return time.parse_iso8601(value.as_string()) or { time.now() }
}

// Ruby attr_accessor `attr_accessor :datetime_format` at line 9.
pub fn ruby_formatter_l9_d1_datetime_format(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Logger::Formatter#datetime_format requires a formatter')
	}
	return brew_runtime.string_value(formatter_from_value(args[0]).datetime_format)
}

// Ruby attr_accessor `attr_accessor :datetime_format` at line 9.
pub fn ruby_formatter_l9_d2_datetime_format(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Logger::Formatter#datetime_format= requires a formatter and format')
	}
	mut formatter := formatter_from_value(args[0])
	formatter.datetime_format = args[1].as_string()
	return formatter_value(formatter)
}

// Ruby method `initialize` at line 11.
pub fn ruby_formatter_l11_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return formatter_value(new_formatter())
}

// Ruby method `call(severity, time, progname, msg)` at line 15.
pub fn ruby_formatter_l15_d4_call(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('Logger::Formatter#call requires a formatter, severity, time, progname, and message')
	}
	formatter := formatter_from_value(args[0])
	return brew_runtime.string_value(formatter.call(args[1].as_string(), value_time(args[2]), args[3].as_string(), args[4]))
}

// Ruby method `format_datetime(time)` at line 21.
pub fn ruby_formatter_l21_d5_format_datetime(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Logger::Formatter#format_datetime requires a formatter and time')
	}
	return brew_runtime.string_value(formatter_from_value(args[0]).format_datetime(value_time(args[1])))
}

// Ruby method `msg2str(msg)` at line 25.
pub fn ruby_formatter_l25_d6_msg2str(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Logger::Formatter#msg2str requires a message')
	}
	return brew_runtime.string_value(message_to_string(args[args.len - 1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: class Logger
// 4:   # Default formatter for log messages.
// 5:   class Formatter
// 6:     Format = "%.1s, [%s #%d] %5s -- %s: %s\n"
// 7:     DatetimeFormat = "%Y-%m-%dT%H:%M:%S.%6N"
// 8:
// 9:     attr_accessor :datetime_format
// 10:
// 11:     def initialize
// 12:       @datetime_format = nil
// 13:     end
// 14:
// 15:     def call(severity, time, progname, msg)
// 16:       sprintf(Format, severity, format_datetime(time), Process.pid, severity, progname, msg2str(msg))
// 17:     end
// 18:
// 19:   private
// 20:
// 21:     def format_datetime(time)
// 22:       time.strftime(@datetime_format || DatetimeFormat)
// 23:     end
// 24:
// 25:     def msg2str(msg)
// 26:       case msg
// 27:       when ::String
// 28:         msg
// 29:       when ::Exception
// 30:         "#{ msg.message } (#{ msg.class })\n#{ msg.backtrace.join("\n") if msg.backtrace }"
// 31:       else
// 32:         msg.inspect
// 33:       end
// 34:     end
// 35:   end
// 36: end
