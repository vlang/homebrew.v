module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/errors.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MultipleAssignmentError {
pub:
	message         string
	inspection_data brew_runtime.Value
}

pub fn (err MultipleAssignmentError) msg() string {
	return err.message
}

pub fn (err MultipleAssignmentError) code() int {
	return 1
}

pub fn (err MultipleAssignmentError) inspect() string {
	return '#<Concurrent::MultipleAssignmentError: ${err.message} ${err.inspection_data.repr}>'
}

pub struct ErrorDetail {
pub:
	message    string
	class_name string = 'Error'
	backtrace  []string
}

pub struct MultipleErrors {
pub:
	errors  []ErrorDetail
	message string
}

pub fn new_multiple_errors(errors []ErrorDetail, message string) MultipleErrors {
	header := if message.len > 0 { message } else { '${errors.len} errors' }
	mut lines := [header]
	for detail in errors {
		lines << '${detail.message} (${detail.class_name})'
		lines << detail.backtrace
	}
	return MultipleErrors{
		errors: errors.clone()
		message: lines.join('\n')
	}
}

pub fn (err MultipleErrors) msg() string {
	return err.message
}

pub fn (err MultipleErrors) code() int {
	return 1
}

fn multiple_assignment_from_args(args []brew_runtime.Value) MultipleAssignmentError {
	message := if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	}
	inspection_data := if args.len > 1 {
		args[1]
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
	return MultipleAssignmentError{
		message: message
		inspection_data: inspection_data
	}
}

// Ruby attr_reader `attr_reader :inspection_data` at line 34.
pub fn ruby_errors_l34_d1_inspection_data(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 1 {
		args[1]
	} else if args.len > 0 {
		args[0]
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `initialize(message = nil, inspection_data = nil)` at line 36.
pub fn ruby_errors_l36_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	err := multiple_assignment_from_args(args)
	return brew_runtime.structured_value('MultipleAssignmentError', err.message, {
		'inspection_data': err.inspection_data.repr
	})
}

// Ruby method `inspect` at line 41.
pub fn ruby_errors_l41_d3_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(multiple_assignment_from_args(args).inspect())
}

// Ruby attr_reader `attr_reader :errors` at line 59.
pub fn ruby_errors_l59_d4_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len == 1 && args[0].type_name == 'Array' {
		args[0]
	} else {
		brew_runtime.array_value(args)
	}
}

// Ruby method `initialize(errors, message = "#{errors.size} errors")` at line 61.
pub fn ruby_errors_l61_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	values := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_array() or { panic(err) }
	} else {
		[]brew_runtime.Value{}
	}
	mut details := []ErrorDetail{cap: values.len}
	for value in values {
		details << ErrorDetail{
			message: value.as_string()
			class_name: value.type_name
		}
	}
	message := if args.len > 1 { args[1].as_string() } else { '' }
	errors := new_multiple_errors(details, message)
	return brew_runtime.structured_value('MultipleErrors', errors.message, {
		'errors': values.len.str()
	})
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
