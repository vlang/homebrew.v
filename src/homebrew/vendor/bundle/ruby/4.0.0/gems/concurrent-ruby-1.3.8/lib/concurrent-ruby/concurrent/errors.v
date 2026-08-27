module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/errors.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :inspection_data` at line 34.
pub fn ruby_errors_l34_d1_inspection_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspection_data', ...args)
}

// Ruby method `initialize(message = nil, inspection_data = nil)` at line 36.
pub fn ruby_errors_l36_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `inspect` at line 41.
pub fn ruby_errors_l41_d3_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby attr_reader `attr_reader :errors` at line 59.
pub fn ruby_errors_l59_d4_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby method `initialize(errors, message = "#{errors.size} errors")` at line 61.
pub fn ruby_errors_l61_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   Error = Class.new(StandardError)
// 4:
// 5:   # Raised when errors occur during configuration.
// 6:   ConfigurationError = Class.new(Error)
// 7:
// 8:   # Raised when an asynchronous operation is cancelled before execution.
// 9:   CancelledOperationError = Class.new(Error)
// 10:
// 11:   # Raised when a lifecycle method (such as `stop`) is called in an improper
// 12:   # sequence or when the object is in an inappropriate state.
// 13:   LifecycleError = Class.new(Error)
// 14:
// 15:   # Raised when an attempt is made to violate an immutability guarantee.
// 16:   ImmutabilityError = Class.new(Error)
// 17:
// 18:   # Raised when an operation is attempted which is not legal given the
// 19:   # receiver's current state
// 20:   IllegalOperationError = Class.new(Error)
// 21:
// 22:   # Raised when an object's methods are called when it has not been
// 23:   # properly initialized.
// 24:   InitializationError = Class.new(Error)
// 25:
// 26:   # Raised when an object with a start/stop lifecycle has been started an
// 27:   # excessive number of times. Often used in conjunction with a restart
// 28:   # policy or strategy.
// 29:   MaxRestartFrequencyError = Class.new(Error)
// 30:
// 31:   # Raised when an attempt is made to modify an immutable object
// 32:   # (such as an `IVar`) after its final state has been set.
// 33:   class MultipleAssignmentError < Error
// 34:     attr_reader :inspection_data
// 35:
// 36:     def initialize(message = nil, inspection_data = nil)
// 37:       @inspection_data = inspection_data
// 38:       super message
// 39:     end
// 40:
// 41:     def inspect
// 42:       format '%s %s>', super[0..-2], @inspection_data.inspect
// 43:     end
// 44:   end
// 45:
// 46:   # Raised by an `Executor` when it is unable to process a given task,
// 47:   # possibly because of a reject policy or other internal error.
// 48:   RejectedExecutionError = Class.new(Error)
// 49:
// 50:   # Raised when any finite resource, such as a lock counter, exceeds its
// 51:   # maximum limit/threshold.
// 52:   ResourceLimitError = Class.new(Error)
// 53:
// 54:   # Raised when an operation times out.
// 55:   TimeoutError = Class.new(Error)
// 56:
// 57:   # Aggregates multiple exceptions.
// 58:   class MultipleErrors < Error
// 59:     attr_reader :errors
// 60:
// 61:     def initialize(errors, message = "#{errors.size} errors")
// 62:       @errors = errors
// 63:       super [*message,
// 64:              *errors.map { |e| [format('%s (%s)', e.message, e.class), *e.backtrace] }.flatten(1)
// 65:             ].join("\n")
// 66:     end
// 67:   end
// 68:
// 69:   # @!macro internal_implementation_note
// 70:   class ConcurrentUpdateError < ThreadError
// 71:     # frozen pre-allocated backtrace to speed ConcurrentUpdateError
// 72:     CONC_UP_ERR_BACKTRACE = ['backtrace elided; set verbose to enable'].freeze
// 73:   end
// 74: end
