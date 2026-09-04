module synchronization

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/mutex_lockable_object.rb`.
// The original source is retained below until every stub has a typed V body.
pub type LockableAction = fn() !ruby.Value

pub type LockableCondition = fn() bool

@[heap]
struct LockableState {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	generation u64
}

@[heap]
pub struct MutexLockableObject {
mut:
	state &LockableState
}

pub fn new_mutex_lockable_object() &MutexLockableObject {
	mutex := sync.new_mutex()
	return &MutexLockableObject{
		state: &LockableState{
			mutex: mutex
			condition: sync.new_cond(mutex)
		}
	}
}

pub fn (lockable &MutexLockableObject) copy() &MutexLockableObject {
	return new_mutex_lockable_object()
}

pub fn (mut lockable MutexLockableObject) synchronize(action LockableAction) !ruby.Value {
	lockable.state.mutex.lock()
	defer {
		lockable.state.mutex.unlock()
	}
	return action()!
}

fn (mut lockable MutexLockableObject) wait_locked(timeout ?time.Duration) bool {
	starting_generation := lockable.state.generation
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for lockable.state.generation == starting_generation {
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
			lockable.state.mutex.unlock()
			time.sleep(sleep_for)
			lockable.state.mutex.lock()
		}
		return true
	}
	lockable.state.condition.wait()
	return true
}

pub fn (mut lockable MutexLockableObject) wait(timeout ?time.Duration) bool {
	lockable.state.mutex.lock()
	defer {
		lockable.state.mutex.unlock()
	}
	return lockable.wait_locked(timeout)
}

pub fn (mut lockable MutexLockableObject) wait_until(timeout ?time.Duration, condition LockableCondition) bool {
	lockable.state.mutex.lock()
	defer {
		lockable.state.mutex.unlock()
	}
	if condition() {
		return true
	}
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for {
			now := time.sys_mono_now()
			if now >= deadline {
				return condition()
			}
			lockable.wait_locked(time.Duration(deadline - now))
			if condition() {
				return true
			}
		}
	}
	for !condition() {
		lockable.wait_locked(none)
	}
	return true
}

pub fn (mut lockable MutexLockableObject) signal() {
	lockable.state.mutex.lock()
	lockable.state.generation++
	lockable.state.condition.signal()
	lockable.state.mutex.unlock()
}

pub fn (mut lockable MutexLockableObject) broadcast() {
	lockable.state.mutex.lock()
	lockable.state.generation++
	lockable.state.condition.broadcast()
	lockable.state.mutex.unlock()
}

fn lockable_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn lockable_boundary_new(type_name string) ruby.Value {
	lockable := new_mutex_lockable_object()
	return ruby.structured_value(type_name, '#<${type_name}>', {
		'lockable_address': u64(voidptr(lockable)).str()
	})
}

fn lockable_boundary_receiver(args []ruby.Value) &MutexLockableObject {
	if args.len == 0 {
		panic('lockable method requires a receiver')
	}
	address := (args[0].attribute('lockable_address') or {
		panic('${args[0].type_name} has no translated lockable state')
	}).u64()
	return unsafe { &MutexLockableObject(voidptr(address)) }
}

fn lockable_boundary_timeout(args []ruby.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

// Ruby method `ns_signal` at line 11.
pub fn ruby_mutex_lockable_object_l11_d1_ns_signal(args ...ruby.Value) ruby.Value {
	mut lockable := lockable_boundary_receiver(args)
	lockable.signal()
	return args[0]
}

// Ruby method `ns_broadcast` at line 16.
pub fn ruby_mutex_lockable_object_l16_d2_ns_broadcast(args ...ruby.Value) ruby.Value {
	mut lockable := lockable_boundary_receiver(args)
	lockable.broadcast()
	return args[0]
}

// Ruby method `initialize` at line 30.
pub fn ruby_mutex_lockable_object_l30_d3_initialize(args ...ruby.Value) ruby.Value {
	return lockable_boundary_new('Concurrent::Synchronization::MutexLockableObject')
}

// Ruby method `initialize_copy(other)` at line 36.
pub fn ruby_mutex_lockable_object_l36_d4_initialize_copy(args ...ruby.Value) ruby.Value {
	return lockable_boundary_new('Concurrent::Synchronization::MutexLockableObject')
}

// Ruby method `synchronize` at line 44.
pub fn ruby_mutex_lockable_object_l44_d5_synchronize(args ...ruby.Value) ruby.Value {
	mut lockable := lockable_boundary_receiver(args)
	lockable.state.mutex.lock()
	value := if args.len > 1 { args[1] } else { lockable_nil_value() }
	lockable.state.mutex.unlock()
	return value
}

// Ruby method `ns_wait(timeout = nil)` at line 52.
pub fn ruby_mutex_lockable_object_l52_d6_ns_wait(args ...ruby.Value) ruby.Value {
	mut lockable := lockable_boundary_receiver(args)
	lockable.wait(lockable_boundary_timeout(args, 1))
	return args[0]
}

// Ruby method `initialize` at line 65.
pub fn ruby_mutex_lockable_object_l65_d7_initialize(args ...ruby.Value) ruby.Value {
	return lockable_boundary_new('Concurrent::Synchronization::MonitorLockableObject')
}

// Ruby method `initialize_copy(other)` at line 71.
pub fn ruby_mutex_lockable_object_l71_d8_initialize_copy(args ...ruby.Value) ruby.Value {
	return lockable_boundary_new('Concurrent::Synchronization::MonitorLockableObject')
}

// Ruby method `synchronize # TODO may be a problem with lock.synchronize { lock.wait }` at line 79.
pub fn ruby_mutex_lockable_object_l79_d9_synchronize(args ...ruby.Value) ruby.Value {
	return ruby_mutex_lockable_object_l44_d5_synchronize(...args)
}

// Ruby method `ns_wait(timeout = nil)` at line 83.
pub fn ruby_mutex_lockable_object_l83_d10_ns_wait(args ...ruby.Value) ruby.Value {
	return ruby_mutex_lockable_object_l52_d6_ns_wait(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/abstract_lockable_object'
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:
// 6:     # @!visibility private
// 7:     # @!macro internal_implementation_note
// 8:     module ConditionSignalling
// 9:       protected
// 10:
// 11:       def ns_signal
// 12:         @__Condition__.signal
// 13:         self
// 14:       end
// 15:
// 16:       def ns_broadcast
// 17:         @__Condition__.broadcast
// 18:         self
// 19:       end
// 20:     end
// 21:
// 22:
// 23:     # @!visibility private
// 24:     # @!macro internal_implementation_note
// 25:     class MutexLockableObject < AbstractLockableObject
// 26:       include ConditionSignalling
// 27:
// 28:       safe_initialization!
// 29:
// 30:       def initialize
// 31:         super()
// 32:         @__Lock__      = ::Mutex.new
// 33:         @__Condition__ = ::ConditionVariable.new
// 34:       end
// 35:
// 36:       def initialize_copy(other)
// 37:         super
// 38:         @__Lock__      = ::Mutex.new
// 39:         @__Condition__ = ::ConditionVariable.new
// 40:       end
// 41:
// 42:       protected
// 43:
// 44:       def synchronize
// 45:         if @__Lock__.owned?
// 46:           yield
// 47:         else
// 48:           @__Lock__.synchronize { yield }
// 49:         end
// 50:       end
// 51:
// 52:       def ns_wait(timeout = nil)
// 53:         @__Condition__.wait @__Lock__, timeout
// 54:         self
// 55:       end
// 56:     end
// 57:
// 58:     # @!visibility private
// 59:     # @!macro internal_implementation_note
// 60:     class MonitorLockableObject < AbstractLockableObject
// 61:       include ConditionSignalling
// 62:
// 63:       safe_initialization!
// 64:
// 65:       def initialize
// 66:         super()
// 67:         @__Lock__      = ::Monitor.new
// 68:         @__Condition__ = @__Lock__.new_cond
// 69:       end
// 70:
// 71:       def initialize_copy(other)
// 72:         super
// 73:         @__Lock__      = ::Monitor.new
// 74:         @__Condition__ = @__Lock__.new_cond
// 75:       end
// 76:
// 77:       protected
// 78:
// 79:       def synchronize # TODO may be a problem with lock.synchronize { lock.wait }
// 80:         @__Lock__.synchronize { yield }
// 81:       end
// 82:
// 83:       def ns_wait(timeout = nil)
// 84:         @__Condition__.wait timeout
// 85:         self
// 86:       end
// 87:     end
// 88:   end
// 89: end
