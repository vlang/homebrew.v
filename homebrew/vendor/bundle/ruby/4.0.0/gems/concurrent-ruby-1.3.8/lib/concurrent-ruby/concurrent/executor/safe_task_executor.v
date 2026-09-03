module executor

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/safe_task_executor.rb`.
// The original source is retained below until every stub has a typed V body.
pub type SafeTask = fn([]brew_runtime.Value) !brew_runtime.Value

pub struct SafeTaskResult {
pub:
	success bool
	value   brew_runtime.Value
	reason  string
}

@[heap]
pub struct SafeTaskExecutor {
mut:
	lock sync.Mutex
pub:
	task             SafeTask @[required]
	rescue_exception bool
}

pub fn new_safe_task_executor(task SafeTask, rescue_exception bool) &SafeTaskExecutor {
	return &SafeTaskExecutor{
		task: task
		rescue_exception: rescue_exception
	}
}

pub fn (mut executor SafeTaskExecutor) execute(args []brew_runtime.Value) SafeTaskResult {
	executor.lock.lock()
	value := executor.task(args) or {
		executor.lock.unlock()
		return SafeTaskResult{
			success: false
			value: brew_runtime.object_value('NilClass', 'nil')
			reason: err.msg()
		}
	}
	executor.lock.unlock()
	return SafeTaskResult{
		success: true
		value: value
	}
}

fn safe_task_result_value(result SafeTaskResult) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.bool_value(result.success),
		result.value,
		if result.reason.len > 0 {
			brew_runtime.object_value('StandardError', result.reason)
		} else {
			brew_runtime.object_value('NilClass', 'nil')
		},
	])
}

// Ruby method `initialize(task, opts = {})` at line 11.
pub fn ruby_safe_task_executor_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('SafeTaskExecutor', '#<Concurrent::SafeTaskExecutor>', {
		'rescue_exception': (args.len > 1 && args[1].type_name == 'Bool' && args[1].as_bool() or { false }).str()
	})
}

// Ruby method `execute(*args)` at line 18.
pub fn ruby_safe_task_executor_l18_d2_execute(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 && args[0].type_name.ends_with('Error') {
		return safe_task_result_value(SafeTaskResult{
			success: false
			value: brew_runtime.object_value('NilClass', 'nil')
			reason: args[0].as_string()
		})
	}
	return safe_task_result_value(SafeTaskResult{
		success: true
		value: if args.len > 0 { args[0] } else { brew_runtime.object_value('NilClass', 'nil') }
	})
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2:
// 3: module Concurrent
// 4:
// 5:   # A simple utility class that executes a callable and returns and array of three elements:
// 6:   # success - indicating if the callable has been executed without errors
// 7:   # value - filled by the callable result if it has been executed without errors, nil otherwise
// 8:   # reason - the error risen by the callable if it has been executed with errors, nil otherwise
// 9:   class SafeTaskExecutor < Synchronization::LockableObject
// 10:
// 11:     def initialize(task, opts = {})
// 12:       @task            = task
// 13:       @exception_class = opts.fetch(:rescue_exception, false) ? Exception : StandardError
// 14:       super() # ensures visibility
// 15:     end
// 16:
// 17:     # @return [Array]
// 18:     def execute(*args)
// 19:       success = true
// 20:       value   = reason = nil
// 21:
// 22:       synchronize do
// 23:         begin
// 24:           value   = @task.call(*args)
// 25:           success = true
// 26:         rescue @exception_class => ex
// 27:           reason  = ex
// 28:           success = false
// 29:         end
// 30:       end
// 31:
// 32:       [success, value, reason]
// 33:     end
// 34:   end
// 35: end
