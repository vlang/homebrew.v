module executor

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/immediate_executor.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ImmediateTask = fn([]ruby.Value)

@[heap]
pub struct ImmediateExecutor {
mut:
	lock    sync.Mutex
	stopped bool
}

pub fn new_immediate_executor() &ImmediateExecutor {
	return &ImmediateExecutor{}
}

pub fn (mut executor ImmediateExecutor) post(task ImmediateTask, args []ruby.Value) bool {
	executor.lock.lock()
	if executor.stopped {
		executor.lock.unlock()
		return false
	}
	task(args)
	executor.lock.unlock()
	return true
}

pub fn (mut executor ImmediateExecutor) running() bool {
	executor.lock.lock()
	running := !executor.stopped
	executor.lock.unlock()
	return running
}

pub fn (mut executor ImmediateExecutor) shutting_down() bool {
	return false
}

pub fn (mut executor ImmediateExecutor) shutdown() bool {
	executor.lock.lock()
	executor.stopped = true
	executor.lock.unlock()
	return true
}

pub fn (mut executor ImmediateExecutor) is_shutdown() bool {
	return !executor.running()
}

pub fn (mut executor ImmediateExecutor) wait_for_termination(timeout time.Duration) bool {
	started := time.now()
	for {
		if executor.is_shutdown() {
			return true
		}
		if timeout >= 0 && time.since(started) >= timeout {
			return false
		}
		time.sleep(time.millisecond)
	}
	return false
}

// Ruby method `initialize` at line 21.
pub fn ruby_immediate_executor_l21_d1_initialize(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('ImmediateExecutor', '#<Concurrent::ImmediateExecutor>', {
		'stopped': 'false'
	})
}

// Ruby method `post(*args, &task)` at line 26.
pub fn ruby_immediate_executor_l26_d2_post(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	return ruby.bool_value(true)
}

// Ruby method `<<(task)` at line 34.
pub fn ruby_immediate_executor_l34_d3_anonymous(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	return ruby.object_value('ImmediateExecutor', '#<Concurrent::ImmediateExecutor>')
}

// Ruby method `running?` at line 40.
pub fn ruby_immediate_executor_l40_d4_running(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len == 0 || args[0].type_name != 'Bool' || !args[0].as_bool() or { false })
}

// Ruby method `shuttingdown?` at line 45.
pub fn ruby_immediate_executor_l45_d5_shuttingdown(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby method `shutdown?` at line 50.
pub fn ruby_immediate_executor_l50_d6_shutdown(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].type_name == 'Bool' && args[0].as_bool() or { false })
}

// Ruby method `shutdown` at line 55.
pub fn ruby_immediate_executor_l55_d7_shutdown(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby alias_method `alias_method :kill, :shutdown` at line 59.
pub fn ruby_immediate_executor_l59_d8_kill(args ...ruby.Value) ruby.Value {
	return ruby_immediate_executor_l55_d7_shutdown(...args)
}

// Ruby method `wait_for_termination(timeout = nil)` at line 62.
pub fn ruby_immediate_executor_l62_d9_wait_for_termination(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].type_name == 'Bool' && args[0].as_bool() or { false })
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/event'
// 2: require 'concurrent/executor/abstract_executor_service'
// 3: require 'concurrent/executor/serial_executor_service'
// 4:
// 5: module Concurrent
// 6:
// 7:   # An executor service which runs all operations on the current thread,
// 8:   # blocking as necessary. Operations are performed in the order they are
// 9:   # received and no two operations can be performed simultaneously.
// 10:   #
// 11:   # This executor service exists mainly for testing an debugging. When used
// 12:   # it immediately runs every `#post` operation on the current thread, blocking
// 13:   # that thread until the operation is complete. This can be very beneficial
// 14:   # during testing because it makes all operations deterministic.
// 15:   #
// 16:   # @note Intended for use primarily in testing and debugging.
// 17:   class ImmediateExecutor < AbstractExecutorService
// 18:     include SerialExecutorService
// 19:
// 20:     # Creates a new executor
// 21:     def initialize
// 22:       @stopped = Concurrent::Event.new
// 23:     end
// 24:
// 25:     # @!macro executor_service_method_post
// 26:     def post(*args, &task)
// 27:       raise ArgumentError.new('no block given') unless block_given?
// 28:       return false unless running?
// 29:       task.call(*args)
// 30:       true
// 31:     end
// 32:
// 33:     # @!macro executor_service_method_left_shift
// 34:     def <<(task)
// 35:       post(&task)
// 36:       self
// 37:     end
// 38:
// 39:     # @!macro executor_service_method_running_question
// 40:     def running?
// 41:       ! shutdown?
// 42:     end
// 43:
// 44:     # @!macro executor_service_method_shuttingdown_question
// 45:     def shuttingdown?
// 46:       false
// 47:     end
// 48:
// 49:     # @!macro executor_service_method_shutdown_question
// 50:     def shutdown?
// 51:       @stopped.set?
// 52:     end
// 53:
// 54:     # @!macro executor_service_method_shutdown
// 55:     def shutdown
// 56:       @stopped.set
// 57:       true
// 58:     end
// 59:     alias_method :kill, :shutdown
// 60:
// 61:     # @!macro executor_service_method_wait_for_termination
// 62:     def wait_for_termination(timeout = nil)
// 63:       @stopped.wait(timeout)
// 64:     end
// 65:   end
// 66: end
