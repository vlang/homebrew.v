module atomic

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_count_down_latch.rb`.
// The original source is retained below until every stub has a typed V body.
const latch_native_min = i64(-4_611_686_018_427_387_904)
const latch_native_max = i64(4_611_686_018_427_387_903)

@[heap]
struct CountDownLatchState {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	count i64
}

@[heap]
pub struct CountDownLatch {
mut:
	state &CountDownLatchState
}

fn validate_latch_count(count i64) !i64 {
	if count < latch_native_min || count > latch_native_max {
		return error('${count} is outside the native integer range')
	}
	if count < 0 {
		return error('${count} cannot be negative')
	}
	return count
}

pub fn new_count_down_latch(count i64) !&CountDownLatch {
	validate_latch_count(count)!
	mutex := sync.new_mutex()
	return &CountDownLatch{
		state: &CountDownLatchState{
			mutex: mutex
			condition: sync.new_cond(mutex)
			count: count
		}
	}
}

pub fn (mut latch CountDownLatch) count() i64 {
	latch.state.mutex.lock()
	defer {
		latch.state.mutex.unlock()
	}
	return latch.state.count
}

pub fn (mut latch CountDownLatch) count_down() {
	latch.state.mutex.lock()
	if latch.state.count > 0 {
		latch.state.count--
	}
	if latch.state.count == 0 {
		latch.state.condition.broadcast()
	}
	latch.state.mutex.unlock()
}

pub fn (mut latch CountDownLatch) wait(timeout ?time.Duration) bool {
	latch.state.mutex.lock()
	defer {
		latch.state.mutex.unlock()
	}
	if latch.state.count == 0 {
		return true
	}
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for latch.state.count > 0 {
			now := time.sys_mono_now()
			if now >= deadline {
				return false
			}
			remaining := deadline - now
			sleep_for := if remaining < u64(time.millisecond) {
				time.Duration(remaining)
			} else {
				time.millisecond
			}
			latch.state.mutex.unlock()
			time.sleep(sleep_for)
			latch.state.mutex.lock()
		}
		return true
	}
	for latch.state.count > 0 {
		latch.state.condition.wait()
	}
	return true
}

pub fn (mut latch CountDownLatch) ns_initialize(count i64) ! {
	validate_latch_count(count)!
	latch.state.mutex.lock()
	latch.state.count = count
	if count == 0 {
		latch.state.condition.broadcast()
	}
	latch.state.mutex.unlock()
}

fn latch_boundary_new(count i64, type_name string) brew_runtime.Value {
	latch := new_count_down_latch(count) or { panic(err) }
	return brew_runtime.structured_value(type_name, '#<${type_name}>', {
		'latch_address': u64(voidptr(latch)).str()
	})
}

fn latch_boundary_receiver(args []brew_runtime.Value) &CountDownLatch {
	if args.len == 0 {
		panic('CountDownLatch method requires a receiver')
	}
	address := (args[0].attribute('latch_address') or {
		panic('${args[0].type_name} has no translated CountDownLatch state')
	}).u64()
	return unsafe { &CountDownLatch(voidptr(address)) }
}

fn latch_boundary_count(args []brew_runtime.Value, index int, default_count i64) i64 {
	if index >= args.len {
		return default_count
	}
	return validate_latch_count(args[index].as_int() or { panic(err) }) or { panic(err) }
}

fn latch_boundary_timeout(args []brew_runtime.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

// Ruby method `initialize(count = 1)` at line 12.
pub fn ruby_mutex_count_down_latch_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return latch_boundary_new(latch_boundary_count(args, 0, 1), 'Concurrent::MutexCountDownLatch')
}

// Ruby method `wait(timeout = nil)` at line 21.
pub fn ruby_mutex_count_down_latch_l21_d2_wait(args ...brew_runtime.Value) brew_runtime.Value {
	mut latch := latch_boundary_receiver(args)
	return brew_runtime.bool_value(latch.wait(latch_boundary_timeout(args, 1)))
}

// Ruby method `count_down` at line 26.
pub fn ruby_mutex_count_down_latch_l26_d3_count_down(args ...brew_runtime.Value) brew_runtime.Value {
	mut latch := latch_boundary_receiver(args)
	latch.count_down()
	return args[0]
}

// Ruby method `count` at line 34.
pub fn ruby_mutex_count_down_latch_l34_d4_count(args ...brew_runtime.Value) brew_runtime.Value {
	mut latch := latch_boundary_receiver(args)
	return brew_runtime.int_value(latch.count())
}

// Ruby method `ns_initialize(count)` at line 40.
pub fn ruby_mutex_count_down_latch_l40_d5_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut latch := latch_boundary_receiver(args)
	if args.len < 2 {
		panic('CountDownLatch#ns_initialize requires count')
	}
	latch.ns_initialize(latch_boundary_count(args, 1, 1)) or { panic(err) }
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro count_down_latch
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexCountDownLatch < Synchronization::LockableObject
// 10:
// 11:     # @!macro count_down_latch_method_initialize
// 12:     def initialize(count = 1)
// 13:       Utility::NativeInteger.ensure_integer_and_bounds count
// 14:       Utility::NativeInteger.ensure_positive count
// 15:
// 16:       super()
// 17:       synchronize { ns_initialize count }
// 18:     end
// 19:
// 20:     # @!macro count_down_latch_method_wait
// 21:     def wait(timeout = nil)
// 22:       synchronize { ns_wait_until(timeout) { @count == 0 } }
// 23:     end
// 24:
// 25:     # @!macro count_down_latch_method_count_down
// 26:     def count_down
// 27:       synchronize do
// 28:         @count -= 1 if @count > 0
// 29:         ns_broadcast if @count == 0
// 30:       end
// 31:     end
// 32:
// 33:     # @!macro count_down_latch_method_count
// 34:     def count
// 35:       synchronize { @count }
// 36:     end
// 37:
// 38:     protected
// 39:
// 40:     def ns_initialize(count)
// 41:       @count = count
// 42:     end
// 43:   end
// 44: end
