module logger

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger/severity.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn coerce_severity(value ruby.Value) !int {
	if value.type_name == 'Integer' {
		return int(value.as_int()!)
	}
	return match value.as_string().to_lower() {
		'debug' { 0 }
		'info' { 1 }
		'warn' { 2 }
		'error' { 3 }
		'fatal' { 4 }
		'unknown' { 5 }
		else { error('invalid log level: ${value.as_string()}') }
	}
}

// Ruby method `self.coerce(severity)` at line 29.
pub fn ruby_severity_l29_d1_self_coerce(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Logger::Severity.coerce requires a severity') }
	return ruby.int_value(coerce_severity(args[0]) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: class Logger
// 4:   # Logging severity.
// 5:   module Severity
// 6:     # Low-level information, mostly for developers.
// 7:     DEBUG = 0
// 8:     # Generic (useful) information about system operation.
// 9:     INFO = 1
// 10:     # A warning.
// 11:     WARN = 2
// 12:     # A handleable error condition.
// 13:     ERROR = 3
// 14:     # An unhandleable error that results in a program crash.
// 15:     FATAL = 4
// 16:     # An unknown message that should always be logged.
// 17:     UNKNOWN = 5
// 18:
// 19:     LEVELS = {
// 20:       "debug" => DEBUG,
// 21:       "info" => INFO,
// 22:       "warn" => WARN,
// 23:       "error" => ERROR,
// 24:       "fatal" => FATAL,
// 25:       "unknown" => UNKNOWN,
// 26:     }
// 27:     private_constant :LEVELS
// 28:
// 29:     def self.coerce(severity)
// 30:       if severity.is_a?(Integer)
// 31:         severity
// 32:       else
// 33:         key = severity.to_s.downcase
// 34:         LEVELS[key] || raise(ArgumentError, "invalid log level: #{severity}")
// 35:       end
// 36:     end
// 37:   end
// 38: end
