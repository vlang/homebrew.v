module collection

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/ruby_timeout_queue.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TimeoutQueuePopResult {
pub:
	found bool
	value brew_runtime.Value
}

@[heap]
struct TimeoutQueueState {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	values []brew_runtime.Value
}

@[heap]
pub struct RubyTimeoutQueue {
mut:
	state &TimeoutQueueState
}

fn timeout_queue_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_ruby_timeout_queue(initial []brew_runtime.Value) &RubyTimeoutQueue {
	mutex := sync.new_mutex()
	return &RubyTimeoutQueue{
		state: &TimeoutQueueState{
			mutex: mutex
			condition: sync.new_cond(mutex)
			values: initial.clone()
		}
	}
}

pub fn (mut queue RubyTimeoutQueue) push(value brew_runtime.Value) {
	queue.state.mutex.lock()
	queue.state.values << value
	queue.state.condition.signal()
	queue.state.mutex.unlock()
}

fn (mut queue RubyTimeoutQueue) take_locked() TimeoutQueuePopResult {
	if queue.state.values.len == 0 {
		return TimeoutQueuePopResult{
			value: timeout_queue_nil_value()
		}
	}
	value := queue.state.values[0]
	queue.state.values.delete(0)
	return TimeoutQueuePopResult{
		found: true
		value: value
	}
}

pub fn (mut queue RubyTimeoutQueue) pop(non_block bool, timeout ?time.Duration) !TimeoutQueuePopResult {
	if non_block && timeout != none {
		return error("can't set a timeout if non_block is enabled")
	}
	queue.state.mutex.lock()
	defer {
		queue.state.mutex.unlock()
	}
	if non_block {
		result := queue.take_locked()
		if !result.found {
			return error('ThreadError: queue empty')
		}
		return result
	}
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for queue.state.values.len == 0 {
			now := time.sys_mono_now()
			if now >= deadline {
				return queue.take_locked()
			}
			remaining := deadline - now
			sleep_for := if remaining < u64(time.millisecond) {
				time.Duration(remaining)
			} else {
				time.millisecond
			}
			queue.state.mutex.unlock()
			time.sleep(sleep_for)
			queue.state.mutex.lock()
		}
		return queue.take_locked()
	}
	for queue.state.values.len == 0 {
		queue.state.condition.wait()
	}
	return queue.take_locked()
}

pub fn (mut queue RubyTimeoutQueue) len() int {
	queue.state.mutex.lock()
	defer {
		queue.state.mutex.unlock()
	}
	return queue.state.values.len
}

fn timeout_queue_boundary_new(initial []brew_runtime.Value) brew_runtime.Value {
	queue := new_ruby_timeout_queue(initial)
	return brew_runtime.structured_value('Concurrent::Collection::RubyTimeoutQueue', '#<Concurrent::Collection::RubyTimeoutQueue>', {
		'timeout_queue_address': u64(voidptr(queue)).str()
	})
}

fn timeout_queue_boundary_receiver(args []brew_runtime.Value) &RubyTimeoutQueue {
	if args.len == 0 {
		panic('RubyTimeoutQueue method requires a receiver')
	}
	address := (args[0].attribute('timeout_queue_address') or {
		panic('${args[0].type_name} has no translated RubyTimeoutQueue state')
	}).u64()
	return unsafe { &RubyTimeoutQueue(voidptr(address)) }
}

fn timeout_queue_boundary_pop(args []brew_runtime.Value) brew_runtime.Value {
	mut queue := timeout_queue_boundary_receiver(args)
	non_block := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	timeout := if args.len > 2 && args[2].type_name != 'NilClass' {
		?time.Duration(time.Duration((args[2].as_float() or { panic(err) }) * f64(time.second)))
	} else {
		?time.Duration(none)
	}
	result := queue.pop(non_block, timeout) or { panic(err) }
	return if result.found { result.value } else { timeout_queue_nil_value() }
}

// Ruby method `initialize(*args)` at line 6.
pub fn ruby_ruby_timeout_queue_l6_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return timeout_queue_boundary_new(args)
}

// Ruby method `push(obj)` at line 17.
pub fn ruby_ruby_timeout_queue_l17_d2_push(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('RubyTimeoutQueue#push requires object')
	}
	mut queue := timeout_queue_boundary_receiver(args)
	queue.push(args[1])
	return args[0]
}

// Ruby alias_method `alias_method :enq, :push` at line 23.
pub fn ruby_ruby_timeout_queue_l23_d3_enq(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_timeout_queue_l17_d2_push(...args)
}

// Ruby alias_method `alias_method :<<, :push` at line 24.
pub fn ruby_ruby_timeout_queue_l24_d4_push(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_timeout_queue_l17_d2_push(...args)
}

// Ruby method `pop(non_block = false, timeout: nil)` at line 26.
pub fn ruby_ruby_timeout_queue_l26_d5_pop(args ...brew_runtime.Value) brew_runtime.Value {
	return timeout_queue_boundary_pop(args)
}

// Ruby alias_method `alias_method :deq, :pop` at line 50.
pub fn ruby_ruby_timeout_queue_l50_d6_deq(args ...brew_runtime.Value) brew_runtime.Value {
	return timeout_queue_boundary_pop(args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 51.
pub fn ruby_ruby_timeout_queue_l51_d7_shift(args ...brew_runtime.Value) brew_runtime.Value {
	return timeout_queue_boundary_pop(args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Collection
// 3:     # @!visibility private
// 4:     # @!macro ruby_timeout_queue
// 5:     class RubyTimeoutQueue < ::Queue
// 6:       def initialize(*args)
// 7:         if RUBY_VERSION >= '3.2'
// 8:           raise "#{self.class.name} is not needed on Ruby 3.2 or later, use ::Queue instead"
// 9:         end
// 10:
// 11:         super(*args)
// 12:
// 13:         @mutex = Mutex.new
// 14:         @cond_var = ConditionVariable.new
// 15:       end
// 16:
// 17:       def push(obj)
// 18:         @mutex.synchronize do
// 19:           super(obj)
// 20:           @cond_var.signal
// 21:         end
// 22:       end
// 23:       alias_method :enq, :push
// 24:       alias_method :<<, :push
// 25:
// 26:       def pop(non_block = false, timeout: nil)
// 27:         if non_block && timeout
// 28:           raise ArgumentError, "can't set a timeout if non_block is enabled"
// 29:         end
// 30:
// 31:         if non_block
// 32:           super(true)
// 33:         elsif timeout
// 34:           @mutex.synchronize do
// 35:             deadline = Concurrent.monotonic_time + timeout
// 36:             while (now = Concurrent.monotonic_time) < deadline && empty?
// 37:               @cond_var.wait(@mutex, deadline - now)
// 38:             end
// 39:             begin
// 40:               return super(true)
// 41:             rescue ThreadError
// 42:               # still empty
// 43:               nil
// 44:             end
// 45:           end
// 46:         else
// 47:           super(false)
// 48:         end
// 49:       end
// 50:       alias_method :deq, :pop
// 51:       alias_method :shift, :pop
// 52:     end
// 53:     private_constant :RubyTimeoutQueue
// 54:   end
// 55: end
