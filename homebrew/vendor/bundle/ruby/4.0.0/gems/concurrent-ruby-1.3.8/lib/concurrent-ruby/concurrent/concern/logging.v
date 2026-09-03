module concern

import brew_runtime
import os
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/logging.rb`.
// The original source is retained below until every stub has a typed V body.
pub const log_debug = 0
pub const log_info = 1
pub const log_warn = 2
pub const log_error = 3
pub const log_fatal = 4
pub const log_unknown = 5

const severity_labels = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'ANY']
const global_logger_level_env = 'BREW_V_CONCURRENT_LOGGER_LEVEL'
const global_logger_output_env = 'BREW_V_CONCURRENT_LOGGER_OUTPUT'
const global_logger_kind_env = 'BREW_V_CONCURRENT_LOGGER_KIND'

pub enum LoggerKind {
	simple
	stdlib
	null
}

// ConcurrentLogger is the V representation of the callable Ruby logger.
// `output` accepts stderr, stdout, a filename, or the empty string for a null logger.
pub struct ConcurrentLogger {
pub:
	level  int = log_fatal
	output string = 'stderr'
	kind   LoggerKind = .simple
}

pub fn severity_from_name(value string) !int {
	return match value.to_upper() {
		'DEBUG' { log_debug }
		'INFO' { log_info }
		'WARN', 'WARNING' { log_warn }
		'ERROR' { log_error }
		'FATAL' { log_fatal }
		'UNKNOWN', 'ANY' { log_unknown }
		else { error('unknown logging severity `${value}`') }
	}
}

pub fn create_simple_logger(level int, output string) ConcurrentLogger {
	return ConcurrentLogger{
		level: level
		output: output
		kind: .simple
	}
}

pub fn create_simple_logger_named(level string, output string) !ConcurrentLogger {
	return create_simple_logger(severity_from_name(level)!, output)
}

pub fn create_stdlib_logger(level int, output string) ConcurrentLogger {
	return ConcurrentLogger{
		level: level
		output: output
		kind: .stdlib
	}
}

pub fn null_logger() ConcurrentLogger {
	return ConcurrentLogger{
		level: log_unknown + 1
		output: ''
		kind: .null
	}
}

fn (logger ConcurrentLogger) formatted_line(severity int, progname string, message string) string {
	label := if severity >= 0 && severity < severity_labels.len {
		severity_labels[severity]
	} else {
		severity_labels[log_unknown]
	}
	return '[${time.now().format_ss_milli()}] ${label:5s} -- ${progname}: ${message}\n'
}

// call implements both source logger lambdas. The bundled stdlib logger uses the
// same formatter as the simple logger, so their externally visible lines match.
pub fn (logger ConcurrentLogger) call(severity int, progname string, message string) !bool {
	if logger.kind == .null || severity < logger.level {
		return false
	}
	line := logger.formatted_line(severity, progname, message)
	match logger.output {
		'' {
			return false
		}
		'stderr' { eprint(line) }
		'stdout' { print(line) }
		else {
			mut file := os.open_append(logger.output)!
			file.write_string(line)!
			file.close()
		}
	}
	return true
}

fn logger_as_value(logger ConcurrentLogger) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::Logger', logger.kind.str(), {
		'level':  logger.level.str()
		'output': logger.output
		'kind':   logger.kind.str()
	})
}

fn logger_from_value(value brew_runtime.Value) !ConcurrentLogger {
	level := (value.attribute('level')!).int()
	output := value.attribute('output')!
	kind_name := value.attribute('kind')!
	kind := match kind_name {
		'simple' { LoggerKind.simple }
		'stdlib' { LoggerKind.stdlib }
		'null' { LoggerKind.null }
		else {
			return error('unknown logger kind `${kind_name}`')
		}
	}
	return ConcurrentLogger{
		level: level
		output: output
		kind: kind
	}
}

pub fn set_global_logger(logger ConcurrentLogger) {
	os.setenv(global_logger_level_env, logger.level.str(), true)
	os.setenv(global_logger_output_env, logger.output, true)
	os.setenv(global_logger_kind_env, logger.kind.str(), true)
}

pub fn global_logger() ConcurrentLogger {
	level := os.getenv_opt(global_logger_level_env) or { return create_simple_logger(log_warn, 'stderr') }
	kind_name := os.getenv(global_logger_kind_env)
	return ConcurrentLogger{
		level: level.int()
		output: os.getenv_opt(global_logger_output_env) or { 'stderr' }
		kind: match kind_name {
			'stdlib' { .stdlib }
			'null' { .null }
			else { .simple }
		}
	}
}

pub fn use_simple_logger(level int, output string) ConcurrentLogger {
	logger := create_simple_logger(level, output)
	set_global_logger(logger)
	return logger
}

pub fn use_stdlib_logger(level int, output string) ConcurrentLogger {
	logger := create_stdlib_logger(level, output)
	set_global_logger(logger)
	return logger
}

// Ruby method `log(level, progname, message = nil, &block)` at line 19.
pub fn ruby_logging_l19_d1_log(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('log requires severity and progname')
	}
	severity := int(args[0].as_int() or { panic(err) })
	message := if args.len > 2 { args[2].as_string() } else { '' }
	logged := global_logger().call(severity, args[1].as_string(), message) or {
		eprintln('`Concurrent.global_logger` failed to log: ${err}')
		false
	}
	return brew_runtime.bool_value(logged)
}

// Ruby method `self.create_simple_logger(level = :FATAL, output = $stderr)` at line 38.
pub fn ruby_logging_l38_d2_self_create_simple_logger(args ...brew_runtime.Value) brew_runtime.Value {
	level := if args.len > 0 {
		if args[0].type_name == 'Integer' {
			int(args[0].as_int() or { panic(err) })
		} else {
			severity_from_name(args[0].as_string()) or { panic(err) }
		}
	} else {
		log_fatal
	}
	output := if args.len > 1 { args[1].as_string() } else { 'stderr' }
	return logger_as_value(create_simple_logger(level, output))
}

// Ruby method `self.use_simple_logger(level = :FATAL, output = $stderr)` at line 66.
pub fn ruby_logging_l66_d3_self_use_simple_logger(args ...brew_runtime.Value) brew_runtime.Value {
	logger := logger_from_value(ruby_logging_l38_d2_self_create_simple_logger(...args)) or { panic(err) }
	set_global_logger(logger)
	return logger_as_value(logger)
}

// Ruby method `self.create_stdlib_logger(level = :FATAL, output = $stderr)` at line 73.
pub fn ruby_logging_l73_d4_self_create_stdlib_logger(args ...brew_runtime.Value) brew_runtime.Value {
	simple := logger_from_value(ruby_logging_l38_d2_self_create_simple_logger(...args)) or { panic(err) }
	return logger_as_value(create_stdlib_logger(simple.level, simple.output))
}

// Ruby method `self.use_stdlib_logger(level = :FATAL, output = $stderr)` at line 101.
pub fn ruby_logging_l101_d5_self_use_stdlib_logger(args ...brew_runtime.Value) brew_runtime.Value {
	logger := logger_from_value(ruby_logging_l73_d4_self_create_stdlib_logger(...args)) or { panic(err) }
	set_global_logger(logger)
	return logger_as_value(logger)
}

// Ruby method `self.global_logger` at line 114.
pub fn ruby_logging_l114_d6_self_global_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return logger_as_value(global_logger())
}

// Ruby method `self.global_logger=(value)` at line 118.
pub fn ruby_logging_l118_d7_self_global_logger(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('global_logger= requires a logger')
	}
	logger := logger_from_value(args[args.len - 1]) or { panic(err) }
	set_global_logger(logger)
	return logger_as_value(logger)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/atomic_reference'
// 2:
// 3: module Concurrent
// 4:   module Concern
// 5:
// 6:     # Include where logging is needed
// 7:     #
// 8:     # @!visibility private
// 9:     module Logging
// 10:       # The same as Logger::Severity but we copy it here to avoid a dependency on the logger gem just for these 7 constants
// 11:       DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN = 0, 1, 2, 3, 4, 5
// 12:       SEV_LABEL = %w[DEBUG INFO WARN ERROR FATAL ANY].freeze
// 13:
// 14:       # Logs through {Concurrent.global_logger}, it can be overridden by setting @logger
// 15:       # @param [Integer] level one of Concurrent::Concern::Logging constants
// 16:       # @param [String] progname e.g. a path of an Actor
// 17:       # @param [String, nil] message when nil block is used to generate the message
// 18:       # @yieldreturn [String] a message
// 19:       def log(level, progname, message = nil, &block)
// 20:         logger = if defined?(@logger) && @logger
// 21:                    @logger
// 22:                  else
// 23:                    Concurrent.global_logger
// 24:                  end
// 25:         logger.call level, progname, message, &block
// 26:       rescue => error
// 27:         $stderr.puts "`Concurrent.global_logger` failed to log #{[level, progname, message, block]}\n" +
// 28:           "#{error.message} (#{error.class})\n#{error.backtrace.join "\n"}"
// 29:       end
// 30:     end
// 31:   end
// 32: end
// 33:
// 34: module Concurrent
// 35:   extend Concern::Logging
// 36:
// 37:   # Create a simple logger with provided level and output.
// 38:   def self.create_simple_logger(level = :FATAL, output = $stderr)
// 39:     level = Concern::Logging.const_get(level) unless level.is_a?(Integer)
// 40:
// 41:     # TODO (pitr-ch 24-Dec-2016): figure out why it had to be replaced, stdlogger was deadlocking
// 42:     lambda do |severity, progname, message = nil, &block|
// 43:       return false if severity < level
// 44:
// 45:       message           = block ? block.call : message
// 46:       formatted_message = case message
// 47:                           when String
// 48:                             message
// 49:                           when Exception
// 50:                             format "%s (%s)\n%s",
// 51:                                    message.message, message.class, (message.backtrace || []).join("\n")
// 52:                           else
// 53:                             message.inspect
// 54:                           end
// 55:
// 56:       output.print format "[%s] %5s -- %s: %s\n",
// 57:                           Time.now.strftime('%Y-%m-%d %H:%M:%S.%L'),
// 58:                           Concern::Logging::SEV_LABEL[severity],
// 59:                           progname,
// 60:                           formatted_message
// 61:       true
// 62:     end
// 63:   end
// 64:
// 65:   # Use logger created by #create_simple_logger to log concurrent-ruby messages.
// 66:   def self.use_simple_logger(level = :FATAL, output = $stderr)
// 67:     Concurrent.global_logger = create_simple_logger level, output
// 68:   end
// 69:
// 70:   # Create a stdlib logger with provided level and output.
// 71:   # If you use this deprecated method you might need to add logger to your Gemfile to avoid warnings from Ruby 3.3.5+.
// 72:   # @deprecated
// 73:   def self.create_stdlib_logger(level = :FATAL, output = $stderr)
// 74:     require 'logger'
// 75:     logger           = Logger.new(output)
// 76:     logger.level     = level
// 77:     logger.formatter = lambda do |severity, datetime, progname, msg|
// 78:       formatted_message = case msg
// 79:                           when String
// 80:                             msg
// 81:                           when Exception
// 82:                             format "%s (%s)\n%s",
// 83:                                    msg.message, msg.class, (msg.backtrace || []).join("\n")
// 84:                           else
// 85:                             msg.inspect
// 86:                           end
// 87:       format "[%s] %5s -- %s: %s\n",
// 88:              datetime.strftime('%Y-%m-%d %H:%M:%S.%L'),
// 89:              severity,
// 90:              progname,
// 91:              formatted_message
// 92:     end
// 93:
// 94:     lambda do |loglevel, progname, message = nil, &block|
// 95:       logger.add loglevel, message, progname, &block
// 96:     end
// 97:   end
// 98:
// 99:   # Use logger created by #create_stdlib_logger to log concurrent-ruby messages.
// 100:   # @deprecated
// 101:   def self.use_stdlib_logger(level = :FATAL, output = $stderr)
// 102:     Concurrent.global_logger = create_stdlib_logger level, output
// 103:   end
// 104:
// 105:   # TODO (pitr-ch 27-Dec-2016): remove deadlocking stdlib_logger methods
// 106:
// 107:   # Suppresses all output when used for logging.
// 108:   NULL_LOGGER   = lambda { |level, progname, message = nil, &block| }
// 109:
// 110:   # @!visibility private
// 111:   GLOBAL_LOGGER = AtomicReference.new(create_simple_logger(:WARN))
// 112:   private_constant :GLOBAL_LOGGER
// 113:
// 114:   def self.global_logger
// 115:     GLOBAL_LOGGER.value
// 116:   end
// 117:
// 118:   def self.global_logger=(value)
// 119:     GLOBAL_LOGGER.value = value
// 120:   end
// 121: end
