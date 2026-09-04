module executor

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/simple_executor_service.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
struct SimpleExecutorState {
	mutex &sync.Mutex
mut:
	running bool
	stopped bool
	count   int
}

@[heap]
pub struct SimpleExecutorService {
mut:
	state &SimpleExecutorState
pub:
	auto_terminate bool
	name           string
}

pub fn new_simple_executor_service(options AbstractExecutorOptions) &SimpleExecutorService {
	return &SimpleExecutorService{
		state: &SimpleExecutorState{
			mutex: sync.new_mutex()
			running: true
		}
		auto_terminate: options.auto_terminate
		name: options.name
	}
}

fn execute_simple_task(mut state &SimpleExecutorState, task ExecutorTask, args []ruby.Value) {
	task(args) or {
		// Ruby worker threads disable abort-on-exception; task failures stay on the worker.
	}
	state.mutex.lock()
	state.count--
	if !state.running && state.count == 0 {
		state.stopped = true
	}
	state.mutex.unlock()
}

pub fn simple_post(task ExecutorTask, args []ruby.Value) bool {

	// Match Thread.abort_on_exception = false from the Ruby class method.
	spawn fn [task, args] () {
		task(args) or {
		}
	}()
	return true
}

pub fn (mut executor SimpleExecutorService) post(task ExecutorTask, args []ruby.Value) bool {
	executor.state.mutex.lock()
	if !executor.state.running {
		executor.state.mutex.unlock()
		return false
	}
	executor.state.count++
	executor.state.mutex.unlock()
	spawn execute_simple_task(mut executor.state, task, args.clone())
	return true
}

pub fn (mut executor SimpleExecutorService) running() bool {
	executor.state.mutex.lock()
	value := executor.state.running
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor SimpleExecutorService) shutting_down() bool {
	executor.state.mutex.lock()
	value := !executor.state.running && !executor.state.stopped
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor SimpleExecutorService) is_shutdown() bool {
	executor.state.mutex.lock()
	value := executor.state.stopped
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor SimpleExecutorService) shutdown() bool {
	executor.state.mutex.lock()
	executor.state.running = false
	if executor.state.count == 0 {
		executor.state.stopped = true
	}
	executor.state.mutex.unlock()
	return true
}

pub fn (mut executor SimpleExecutorService) kill() bool {
	executor.state.mutex.lock()
	executor.state.running = false
	executor.state.stopped = true
	executor.state.mutex.unlock()
	return true
}

pub fn (mut executor SimpleExecutorService) wait_for_termination(timeout ?time.Duration) bool {
	started := time.sys_mono_now()
	for {
		if executor.is_shutdown() {
			return true
		}
		if duration := timeout {
			if time.sys_mono_now() - started >= u64(if duration > 0 { duration } else { 0 }) {
				return false
			}
		}
		time.sleep(time.millisecond)
	}
	return false
}

pub fn (executor &SimpleExecutorService) adapter() ExecutorAdapter {
	return ExecutorAdapter{
		context: voidptr(executor)
		post_task: simple_executor_adapter_post
		is_running: simple_executor_adapter_running
	}
}

fn simple_executor_adapter_post(context voidptr, task ExecutorTask, args []ruby.Value) bool {
	mut executor := unsafe { &SimpleExecutorService(context) }
	return executor.post(task, args)
}

fn simple_executor_adapter_running(context voidptr) bool {
	mut executor := unsafe { &SimpleExecutorService(context) }
	return executor.running()
}

fn simple_executor_boundary_value(executor &SimpleExecutorService) ruby.Value {
	return ruby.structured_value('Concurrent::SimpleExecutorService', '#<Concurrent::SimpleExecutorService>', {
		'simple_executor_address': u64(voidptr(executor)).str()
	})
}

fn simple_executor_boundary_receiver(args []ruby.Value) &SimpleExecutorService {
	if args.len == 0 {
		panic('SimpleExecutorService method requires a receiver')
	}
	address := (args[0].attribute('simple_executor_address') or {
		panic('${args[0].type_name} has no translated SimpleExecutorService state')
	}).u64()
	return unsafe { &SimpleExecutorService(voidptr(address)) }
}

fn simple_executor_boundary_timeout(args []ruby.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

// Ruby method `self.post(*args)` at line 24.
pub fn ruby_simple_executor_service_l24_d1_self_post(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	return ruby.bool_value(simple_post(boundary_noop_executor_task, args))
}

// Ruby method `self.<<(task)` at line 34.
pub fn ruby_simple_executor_service_l34_d2_self(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	simple_post(boundary_noop_executor_task, args)
	return ruby.object_value('Class', 'Concurrent::SimpleExecutorService')
}

// Ruby method `post(*args, &task)` at line 40.
pub fn ruby_simple_executor_service_l40_d3_post(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ArgumentError: no block given')
	}
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.post(boundary_noop_executor_task, args[1..].clone()))
}

// Ruby method `<<(task)` at line 56.
pub fn ruby_simple_executor_service_l56_d4_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ArgumentError: no block given')
	}
	mut executor := simple_executor_boundary_receiver(args)
	executor.post(boundary_noop_executor_task, args[1..].clone())
	return args[0]
}

// Ruby method `running?` at line 62.
pub fn ruby_simple_executor_service_l62_d5_running(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.running())
}

// Ruby method `shuttingdown?` at line 67.
pub fn ruby_simple_executor_service_l67_d6_shuttingdown(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.shutting_down())
}

// Ruby method `shutdown?` at line 72.
pub fn ruby_simple_executor_service_l72_d7_shutdown(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.is_shutdown())
}

// Ruby method `shutdown` at line 77.
pub fn ruby_simple_executor_service_l77_d8_shutdown(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.shutdown())
}

// Ruby method `kill` at line 84.
pub fn ruby_simple_executor_service_l84_d9_kill(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.kill())
}

// Ruby method `wait_for_termination(timeout = nil)` at line 91.
pub fn ruby_simple_executor_service_l91_d10_wait_for_termination(args ...ruby.Value) ruby.Value {
	mut executor := simple_executor_boundary_receiver(args)
	return ruby.bool_value(executor.wait_for_termination(simple_executor_boundary_timeout(args, 1)))
}

// Ruby method `ns_initialize(*args)` at line 97.
pub fn ruby_simple_executor_service_l97_d11_ns_initialize(args ...ruby.Value) ruby.Value {
	return simple_executor_boundary_value(new_simple_executor_service(AbstractExecutorOptions{}))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/atomic_boolean'
// 2: require 'concurrent/atomic/atomic_fixnum'
// 3: require 'concurrent/atomic/event'
// 4: require 'concurrent/executor/executor_service'
// 5: require 'concurrent/executor/ruby_executor_service'
// 6:
// 7: module Concurrent
// 8:
// 9:   # An executor service in which every operation spawns a new,
// 10:   # independently operating thread.
// 11:   #
// 12:   # This is perhaps the most inefficient executor service in this
// 13:   # library. It exists mainly for testing an debugging. Thread creation
// 14:   # and management is expensive in Ruby and this executor performs no
// 15:   # resource pooling. This can be very beneficial during testing and
// 16:   # debugging because it decouples the using code from the underlying
// 17:   # executor implementation. In production this executor will likely
// 18:   # lead to suboptimal performance.
// 19:   #
// 20:   # @note Intended for use primarily in testing and debugging.
// 21:   class SimpleExecutorService < RubyExecutorService
// 22:
// 23:     # @!macro executor_service_method_post
// 24:     def self.post(*args)
// 25:       raise ArgumentError.new('no block given') unless block_given?
// 26:       Thread.new(*args) do
// 27:         Thread.current.abort_on_exception = false
// 28:         yield(*args)
// 29:       end
// 30:       true
// 31:     end
// 32:
// 33:     # @!macro executor_service_method_left_shift
// 34:     def self.<<(task)
// 35:       post(&task)
// 36:       self
// 37:     end
// 38:
// 39:     # @!macro executor_service_method_post
// 40:     def post(*args, &task)
// 41:       raise ArgumentError.new('no block given') unless block_given?
// 42:       return false unless running?
// 43:       @count.increment
// 44:       Thread.new(*args) do
// 45:         Thread.current.abort_on_exception = false
// 46:         begin
// 47:           yield(*args)
// 48:         ensure
// 49:           @count.decrement
// 50:           @stopped.set if @running.false? && @count.value == 0
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     # @!macro executor_service_method_left_shift
// 56:     def <<(task)
// 57:       post(&task)
// 58:       self
// 59:     end
// 60:
// 61:     # @!macro executor_service_method_running_question
// 62:     def running?
// 63:       @running.true?
// 64:     end
// 65:
// 66:     # @!macro executor_service_method_shuttingdown_question
// 67:     def shuttingdown?
// 68:       @running.false? && ! @stopped.set?
// 69:     end
// 70:
// 71:     # @!macro executor_service_method_shutdown_question
// 72:     def shutdown?
// 73:       @stopped.set?
// 74:     end
// 75:
// 76:     # @!macro executor_service_method_shutdown
// 77:     def shutdown
// 78:       @running.make_false
// 79:       @stopped.set if @count.value == 0
// 80:       true
// 81:     end
// 82:
// 83:     # @!macro executor_service_method_kill
// 84:     def kill
// 85:       @running.make_false
// 86:       @stopped.set
// 87:       true
// 88:     end
// 89:
// 90:     # @!macro executor_service_method_wait_for_termination
// 91:     def wait_for_termination(timeout = nil)
// 92:       @stopped.wait(timeout)
// 93:     end
// 94:
// 95:     private
// 96:
// 97:     def ns_initialize(*args)
// 98:       @running = Concurrent::AtomicBoolean.new(true)
// 99:       @stopped = Concurrent::Event.new
// 100:       @count = Concurrent::AtomicFixnum.new(0)
// 101:     end
// 102:   end
// 103: end
