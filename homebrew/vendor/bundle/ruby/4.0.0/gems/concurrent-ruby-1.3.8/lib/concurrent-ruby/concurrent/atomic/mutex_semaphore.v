module atomic

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_semaphore.rb`.
// The original source is retained below until every stub has a typed V body.
const semaphore_native_min = i64(-4_611_686_018_427_387_904)
const semaphore_native_max = i64(4_611_686_018_427_387_903)

pub type SemaphoreAction = fn() !ruby.Value

pub struct SemaphoreActionResult {
pub:
	acquired bool
	value    ruby.Value
}

@[heap]
struct MutexSemaphoreState {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	free i64
}

@[heap]
pub struct MutexSemaphore {
mut:
	state &MutexSemaphoreState
}

pub fn validate_semaphore_integer(value i64) !i64 {
	if value > semaphore_native_max {
		return error('${value} is greater than the maximum value of ${semaphore_native_max}')
	}
	if value < semaphore_native_min {
		return error('${value} is less than the maximum value of ${semaphore_native_min}')
	}
	return value
}

pub fn validate_semaphore_permits(value i64) !i64 {
	validate_semaphore_integer(value)!
	if value < 0 {
		return error('${value} cannot be negative')
	}
	return value
}

pub fn new_mutex_semaphore(count i64) !&MutexSemaphore {
	validate_semaphore_integer(count)!
	mutex := sync.new_mutex()
	return &MutexSemaphore{
		state: &MutexSemaphoreState{
			mutex: mutex
			condition: sync.new_cond(mutex)
			free: count
		}
	}
}

fn (mut semaphore MutexSemaphore) try_acquire_now_locked(permits i64) bool {
	if semaphore.state.free >= permits {
		semaphore.state.free -= permits
		return true
	}
	return false
}

fn (mut semaphore MutexSemaphore) try_acquire_timed_locked(permits i64, timeout ?time.Duration) bool {
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for {
			if semaphore.try_acquire_now_locked(permits) {
				return true
			}
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
			semaphore.state.mutex.unlock()
			time.sleep(sleep_for)
			semaphore.state.mutex.lock()
		}
	}
	for !semaphore.try_acquire_now_locked(permits) {
		semaphore.state.condition.wait()
	}
	return true
}

pub fn (mut semaphore MutexSemaphore) acquire(permits i64) ! {
	validate_semaphore_permits(permits)!
	semaphore.state.mutex.lock()
	semaphore.try_acquire_timed_locked(permits, none)
	semaphore.state.mutex.unlock()
}

pub fn (mut semaphore MutexSemaphore) acquire_with(permits i64, action SemaphoreAction) !ruby.Value {
	semaphore.acquire(permits)!
	defer {
		semaphore.release(permits) or {}
	}
	return action()!
}

pub fn (mut semaphore MutexSemaphore) available_permits() i64 {
	semaphore.state.mutex.lock()
	defer {
		semaphore.state.mutex.unlock()
	}
	return semaphore.state.free
}

pub fn (mut semaphore MutexSemaphore) drain_permits() i64 {
	semaphore.state.mutex.lock()
	defer {
		semaphore.state.mutex.unlock()
	}
	available := semaphore.state.free
	semaphore.state.free = 0
	return available
}

pub fn (mut semaphore MutexSemaphore) try_acquire(permits i64, timeout ?time.Duration) !bool {
	validate_semaphore_permits(permits)!
	semaphore.state.mutex.lock()
	defer {
		semaphore.state.mutex.unlock()
	}
	if timeout == none {
		return semaphore.try_acquire_now_locked(permits)
	}
	return semaphore.try_acquire_timed_locked(permits, timeout)
}

pub fn (mut semaphore MutexSemaphore) try_acquire_with(permits i64, timeout ?time.Duration, action SemaphoreAction) !SemaphoreActionResult {
	if !semaphore.try_acquire(permits, timeout)! {
		return SemaphoreActionResult{
			acquired: false
			value: semaphore_nil_value()
		}
	}
	defer {
		semaphore.release(permits) or {}
	}
	return SemaphoreActionResult{
		acquired: true
		value: action()!
	}
}

pub fn (mut semaphore MutexSemaphore) release(permits i64) ! {
	validate_semaphore_permits(permits)!
	semaphore.state.mutex.lock()
	semaphore.state.free += permits
	mut remaining := permits
	for remaining > 0 {
		semaphore.state.condition.signal()
		remaining--
	}
	semaphore.state.mutex.unlock()
}

pub fn (mut semaphore MutexSemaphore) reduce_permits(reduction i64) ! {
	validate_semaphore_permits(reduction)!
	semaphore.state.mutex.lock()
	semaphore.state.free -= reduction
	semaphore.state.mutex.unlock()
}

pub fn (mut semaphore MutexSemaphore) ns_initialize(count i64) {
	semaphore.state.mutex.lock()
	semaphore.state.free = count
	semaphore.state.mutex.unlock()
}

pub fn (mut semaphore MutexSemaphore) try_acquire_now(permits i64) !bool {
	validate_semaphore_permits(permits)!
	semaphore.state.mutex.lock()
	defer {
		semaphore.state.mutex.unlock()
	}
	return semaphore.try_acquire_now_locked(permits)
}

pub fn (mut semaphore MutexSemaphore) try_acquire_timed(permits i64, timeout ?time.Duration) !bool {
	validate_semaphore_permits(permits)!
	semaphore.state.mutex.lock()
	defer {
		semaphore.state.mutex.unlock()
	}
	return semaphore.try_acquire_timed_locked(permits, timeout)
}

fn semaphore_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn semaphore_boundary_new(count i64, type_name string) ruby.Value {
	semaphore := new_mutex_semaphore(count) or { panic(err) }
	return ruby.structured_value(type_name, '#<${type_name}>', {
		'semaphore_address': u64(voidptr(semaphore)).str()
	})
}

fn semaphore_boundary_receiver(args []ruby.Value) &MutexSemaphore {
	if args.len == 0 {
		panic('semaphore method requires a receiver')
	}
	address := (args[0].attribute('semaphore_address') or {
		panic('${args[0].type_name} has no translated semaphore state')
	}).u64()
	return unsafe { &MutexSemaphore(voidptr(address)) }
}

fn semaphore_boundary_permits(args []ruby.Value, index int) i64 {
	if index >= args.len {
		return 1
	}
	return validate_semaphore_permits(args[index].as_int() or { panic(err) }) or { panic(err) }
}

fn semaphore_boundary_timeout(value ruby.Value) ?time.Duration {
	if value.type_name == 'NilClass' {
		return none
	}
	seconds := value.as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

// Ruby method `initialize(count)` at line 12.
pub fn ruby_mutex_semaphore_l12_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MutexSemaphore#initialize requires count')
	}
	count := validate_semaphore_integer(args[0].as_int() or { panic(err) }) or { panic(err) }
	return semaphore_boundary_new(count, 'Concurrent::MutexSemaphore')
}

// Ruby method `acquire(permits = 1)` at line 20.
pub fn ruby_mutex_semaphore_l20_d2_acquire(args ...ruby.Value) ruby.Value {
	mut semaphore := semaphore_boundary_receiver(args)
	permits := semaphore_boundary_permits(args, 1)
	semaphore.acquire(permits) or { panic(err) }
	if args.len > 2 {
		defer {
			semaphore.release(permits) or {}
		}
		return args[2]
	}
	return semaphore_nil_value()
}

// Ruby method `available_permits` at line 38.
pub fn ruby_mutex_semaphore_l38_d3_available_permits(args ...ruby.Value) ruby.Value {
	mut semaphore := semaphore_boundary_receiver(args)
	return ruby.int_value(semaphore.available_permits())
}

// Ruby method `drain_permits` at line 47.
pub fn ruby_mutex_semaphore_l47_d4_drain_permits(args ...ruby.Value) ruby.Value {
	mut semaphore := semaphore_boundary_receiver(args)
	return ruby.int_value(semaphore.drain_permits())
}

// Ruby method `try_acquire(permits = 1, timeout = nil)` at line 54.
pub fn ruby_mutex_semaphore_l54_d5_try_acquire(args ...ruby.Value) ruby.Value {
	mut semaphore := semaphore_boundary_receiver(args)
	permits := semaphore_boundary_permits(args, 1)
	timeout := if args.len > 2 { semaphore_boundary_timeout(args[2]) } else { none }
	acquired := semaphore.try_acquire(permits, timeout) or { panic(err) }
	if args.len <= 3 {
		return ruby.bool_value(acquired)
	}
	if !acquired {
		return semaphore_nil_value()
	}
	defer {
		semaphore.release(permits) or {}
	}
	return args[3]
}

// Ruby method `release(permits = 1)` at line 77.
pub fn ruby_mutex_semaphore_l77_d6_release(args ...ruby.Value) ruby.Value {
	mut semaphore := semaphore_boundary_receiver(args)
	semaphore.release(semaphore_boundary_permits(args, 1)) or { panic(err) }
	return semaphore_nil_value()
}

// Ruby method `reduce_permits(reduction)` at line 99.
pub fn ruby_mutex_semaphore_l99_d7_reduce_permits(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('reduce_permits requires a receiver and reduction')
	}
	mut semaphore := semaphore_boundary_receiver(args)
	semaphore.reduce_permits(semaphore_boundary_permits(args, 1)) or { panic(err) }
	return semaphore_nil_value()
}

// Ruby method `ns_initialize(count)` at line 110.
pub fn ruby_mutex_semaphore_l110_d8_ns_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ns_initialize requires a receiver and count')
	}
	mut semaphore := semaphore_boundary_receiver(args)
	count := validate_semaphore_integer(args[1].as_int() or { panic(err) }) or { panic(err) }
	semaphore.ns_initialize(count)
	return ruby.int_value(count)
}

// Ruby method `try_acquire_now(permits)` at line 117.
pub fn ruby_mutex_semaphore_l117_d9_try_acquire_now(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('try_acquire_now requires a receiver and permits')
	}
	mut semaphore := semaphore_boundary_receiver(args)
	return ruby.bool_value(semaphore.try_acquire_now(semaphore_boundary_permits(args, 1)) or { panic(err) })
}

// Ruby method `try_acquire_timed(permits, timeout)` at line 127.
pub fn ruby_mutex_semaphore_l127_d10_try_acquire_timed(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('try_acquire_timed requires a receiver, permits, and timeout')
	}
	mut semaphore := semaphore_boundary_receiver(args)
	timeout := semaphore_boundary_timeout(args[2])
	return ruby.bool_value(semaphore.try_acquire_timed(semaphore_boundary_permits(args, 1), timeout) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro semaphore
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexSemaphore < Synchronization::LockableObject
// 10:
// 11:     # @!macro semaphore_method_initialize
// 12:     def initialize(count)
// 13:       Utility::NativeInteger.ensure_integer_and_bounds count
// 14:
// 15:       super()
// 16:       synchronize { ns_initialize count }
// 17:     end
// 18:
// 19:     # @!macro semaphore_method_acquire
// 20:     def acquire(permits = 1)
// 21:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 22:       Utility::NativeInteger.ensure_positive permits
// 23:
// 24:       synchronize do
// 25:         try_acquire_timed(permits, nil)
// 26:       end
// 27:
// 28:       return unless block_given?
// 29:
// 30:       begin
// 31:         yield
// 32:       ensure
// 33:         release(permits)
// 34:       end
// 35:     end
// 36:
// 37:     # @!macro semaphore_method_available_permits
// 38:     def available_permits
// 39:       synchronize { @free }
// 40:     end
// 41:
// 42:     # @!macro semaphore_method_drain_permits
// 43:     #
// 44:     #   Acquires and returns all permits that are immediately available.
// 45:     #
// 46:     #   @return [Integer]
// 47:     def drain_permits
// 48:       synchronize do
// 49:         @free.tap { |_| @free = 0 }
// 50:       end
// 51:     end
// 52:
// 53:     # @!macro semaphore_method_try_acquire
// 54:     def try_acquire(permits = 1, timeout = nil)
// 55:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 56:       Utility::NativeInteger.ensure_positive permits
// 57:
// 58:       acquired = synchronize do
// 59:         if timeout.nil?
// 60:           try_acquire_now(permits)
// 61:         else
// 62:           try_acquire_timed(permits, timeout)
// 63:         end
// 64:       end
// 65:
// 66:       return acquired unless block_given?
// 67:       return unless acquired
// 68:
// 69:       begin
// 70:         yield
// 71:       ensure
// 72:         release(permits)
// 73:       end
// 74:     end
// 75:
// 76:     # @!macro semaphore_method_release
// 77:     def release(permits = 1)
// 78:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 79:       Utility::NativeInteger.ensure_positive permits
// 80:
// 81:       synchronize do
// 82:         @free += permits
// 83:         permits.times { ns_signal }
// 84:       end
// 85:       nil
// 86:     end
// 87:
// 88:     # Shrinks the number of available permits by the indicated reduction.
// 89:     #
// 90:     # @param [Fixnum] reduction Number of permits to remove.
// 91:     #
// 92:     # @raise [ArgumentError] if `reduction` is not an integer or is negative
// 93:     #
// 94:     # @raise [ArgumentError] if `@free` - `@reduction` is less than zero
// 95:     #
// 96:     # @return [nil]
// 97:     #
// 98:     # @!visibility private
// 99:     def reduce_permits(reduction)
// 100:       Utility::NativeInteger.ensure_integer_and_bounds reduction
// 101:       Utility::NativeInteger.ensure_positive reduction
// 102:
// 103:       synchronize { @free -= reduction }
// 104:       nil
// 105:     end
// 106:
// 107:     protected
// 108:
// 109:     # @!visibility private
// 110:     def ns_initialize(count)
// 111:       @free = count
// 112:     end
// 113:
// 114:     private
// 115:
// 116:     # @!visibility private
// 117:     def try_acquire_now(permits)
// 118:       if @free >= permits
// 119:         @free -= permits
// 120:         true
// 121:       else
// 122:         false
// 123:       end
// 124:     end
// 125:
// 126:     # @!visibility private
// 127:     def try_acquire_timed(permits, timeout)
// 128:       ns_wait_until(timeout) { try_acquire_now(permits) }
// 129:     end
// 130:   end
// 131: end
