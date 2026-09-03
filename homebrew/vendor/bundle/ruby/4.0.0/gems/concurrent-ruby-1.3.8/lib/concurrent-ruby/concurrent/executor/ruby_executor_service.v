module executor

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/ruby_executor_service.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct RubyExecutorService {
mut:
	lock    sync.Mutex
	stop    bool
	stopped bool
pub:
	auto_terminate  bool
	name            string
	fallback_policy FallbackPolicy
}

pub fn new_ruby_executor_service(options AbstractExecutorOptions) &RubyExecutorService {
	return &RubyExecutorService{
		auto_terminate: options.auto_terminate
		name: options.name
		fallback_policy: options.fallback_policy
	}
}

pub fn (mut executor RubyExecutorService) post(task ExecutorTask, args []brew_runtime.Value) !bool {
	executor.lock.lock()
	if !executor.stop {
		executor.lock.unlock()
		return error('NotImplementedError: RubyExecutorService#ns_execute')
	}
	policy := executor.fallback_policy
	executor.lock.unlock()
	return match policy {
		.abort { error('RejectedExecutionError') }
		.discard { false }
		.caller_runs {
			task(args) or {
				// The Ruby implementation logs failures from caller-runs and reports success.
			}
			true
		}
	}
}

pub fn (mut executor RubyExecutorService) shutdown() bool {
	executor.lock.lock()
	if !executor.stop {
		executor.stop = true
		// Default ns_shutdown_execution signals StoppedEvent immediately.
		executor.stopped = true
	}
	executor.lock.unlock()
	return true
}

pub fn (mut executor RubyExecutorService) kill() bool {
	executor.lock.lock()
	if !executor.stopped {
		executor.stop = true
		executor.stopped = true
	}
	executor.lock.unlock()
	return true
}

pub fn (mut executor RubyExecutorService) running() bool {
	executor.lock.lock()
	value := !executor.stop
	executor.lock.unlock()
	return value
}

pub fn (mut executor RubyExecutorService) shutting_down() bool {
	executor.lock.lock()
	value := executor.stop && !executor.stopped
	executor.lock.unlock()
	return value
}

pub fn (mut executor RubyExecutorService) is_shutdown() bool {
	executor.lock.lock()
	value := executor.stopped
	executor.lock.unlock()
	return value
}

pub fn (mut executor RubyExecutorService) wait_for_termination(timeout ?time.Duration) bool {
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

fn executor_base_boundary_value(executor &RubyExecutorService) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::RubyExecutorService', '#<Concurrent::RubyExecutorService>', {
		'ruby_executor_address': u64(voidptr(executor)).str()
	})
}

fn executor_base_boundary_receiver(args []brew_runtime.Value) &RubyExecutorService {
	if args.len == 0 {
		panic('RubyExecutorService method requires a receiver')
	}
	address := (args[0].attribute('ruby_executor_address') or {
		panic('${args[0].type_name} has no translated RubyExecutorService state')
	}).u64()
	return unsafe { &RubyExecutorService(voidptr(address)) }
}

fn executor_base_boundary_timeout(args []brew_runtime.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

// Ruby method `initialize(*args, &block)` at line 11.
pub fn ruby_ruby_executor_service_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return executor_base_boundary_value(new_ruby_executor_service(abstract_executor_options_from_boundary(args)))
}

// Ruby method `post(*args, &task)` at line 17.
pub fn ruby_ruby_executor_service_l17_d2_post(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ArgumentError: no block given')
	}
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.post(boundary_noop_executor_task, args[1..].clone()) or {
		panic(err)
	})
}

// Ruby method `shutdown` at line 33.
pub fn ruby_ruby_executor_service_l33_d3_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.shutdown())
}

// Ruby method `kill` at line 42.
pub fn ruby_ruby_executor_service_l42_d4_kill(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.kill())
}

// Ruby method `wait_for_termination(timeout = nil)` at line 52.
pub fn ruby_ruby_executor_service_l52_d5_wait_for_termination(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.wait_for_termination(executor_base_boundary_timeout(args, 1)))
}

// Ruby method `stop_event` at line 58.
pub fn ruby_ruby_executor_service_l58_d6_stop_event(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(!executor.running())
}

// Ruby method `stopped_event` at line 62.
pub fn ruby_ruby_executor_service_l62_d7_stopped_event(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.is_shutdown())
}

// Ruby method `ns_shutdown_execution` at line 66.
pub fn ruby_ruby_executor_service_l66_d8_ns_shutdown_execution(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	executor.lock.lock()
	executor.stopped = true
	executor.lock.unlock()
	return brew_runtime.bool_value(true)
}

// Ruby method `ns_running?` at line 70.
pub fn ruby_ruby_executor_service_l70_d9_ns_running(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.running())
}

// Ruby method `ns_shuttingdown?` at line 74.
pub fn ruby_ruby_executor_service_l74_d10_ns_shuttingdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.shutting_down())
}

// Ruby method `ns_shutdown?` at line 78.
pub fn ruby_ruby_executor_service_l78_d11_ns_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := executor_base_boundary_receiver(args)
	return brew_runtime.bool_value(executor.is_shutdown())
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/executor/abstract_executor_service'
// 2: require 'concurrent/atomic/event'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro abstract_executor_service_public_api
// 7:   # @!visibility private
// 8:   class RubyExecutorService < AbstractExecutorService
// 9:     safe_initialization!
// 10:
// 11:     def initialize(*args, &block)
// 12:       super
// 13:       @StopEvent    = Event.new
// 14:       @StoppedEvent = Event.new
// 15:     end
// 16:
// 17:     def post(*args, &task)
// 18:       raise ArgumentError.new('no block given') unless block_given?
// 19:       deferred_action = synchronize {
// 20:         if running?
// 21:           ns_execute(*args, &task)
// 22:         else
// 23:           fallback_action(*args, &task)
// 24:         end
// 25:       }
// 26:       if deferred_action
// 27:         deferred_action.call
// 28:       else
// 29:         true
// 30:       end
// 31:     end
// 32:
// 33:     def shutdown
// 34:       synchronize do
// 35:         break unless running?
// 36:         stop_event.set
// 37:         ns_shutdown_execution
// 38:       end
// 39:       true
// 40:     end
// 41:
// 42:     def kill
// 43:       synchronize do
// 44:         break if shutdown?
// 45:         stop_event.set
// 46:         ns_kill_execution
// 47:         stopped_event.set
// 48:       end
// 49:       true
// 50:     end
// 51:
// 52:     def wait_for_termination(timeout = nil)
// 53:       stopped_event.wait(timeout)
// 54:     end
// 55:
// 56:     private
// 57:
// 58:     def stop_event
// 59:       @StopEvent
// 60:     end
// 61:
// 62:     def stopped_event
// 63:       @StoppedEvent
// 64:     end
// 65:
// 66:     def ns_shutdown_execution
// 67:       stopped_event.set
// 68:     end
// 69:
// 70:     def ns_running?
// 71:       !stop_event.set?
// 72:     end
// 73:
// 74:     def ns_shuttingdown?
// 75:       !(ns_running? || ns_shutdown?)
// 76:     end
// 77:
// 78:     def ns_shutdown?
// 79:       stopped_event.set?
// 80:     end
// 81:   end
// 82: end
