module concern

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/logging.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `log(level, progname, message = nil, &block)` at line 19.
pub fn ruby_logging_l19_d1_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('log', ...args)
}

// Ruby method `self.create_simple_logger(level = :FATAL, output = $stderr)` at line 38.
pub fn ruby_logging_l38_d2_self_create_simple_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_simple_logger', ...args)
}

// Ruby method `self.use_simple_logger(level = :FATAL, output = $stderr)` at line 66.
pub fn ruby_logging_l66_d3_self_use_simple_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.use_simple_logger', ...args)
}

// Ruby method `self.create_stdlib_logger(level = :FATAL, output = $stderr)` at line 73.
pub fn ruby_logging_l73_d4_self_create_stdlib_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create_stdlib_logger', ...args)
}

// Ruby method `self.use_stdlib_logger(level = :FATAL, output = $stderr)` at line 101.
pub fn ruby_logging_l101_d5_self_use_stdlib_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.use_stdlib_logger', ...args)
}

// Ruby method `self.global_logger` at line 114.
pub fn ruby_logging_l114_d6_self_global_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.global_logger', ...args)
}

// Ruby method `self.global_logger=(value)` at line 118.
pub fn ruby_logging_l118_d7_self_global_logger(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.global_logger=', ...args)
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
