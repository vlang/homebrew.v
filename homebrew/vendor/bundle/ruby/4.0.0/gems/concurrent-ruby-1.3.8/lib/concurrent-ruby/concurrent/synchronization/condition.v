module synchronization

import ruby
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/condition.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct Condition {
mut:
	associated_lock &MutexLockableObject
}

pub fn new_condition(associated_lock &MutexLockableObject) &Condition {
	return &Condition{
		associated_lock: associated_lock
	}
}

pub fn (mut condition Condition) wait(timeout ?time.Duration) bool {
	return condition.associated_lock.wait(timeout)
}

pub fn (mut condition Condition) wait_until(timeout ?time.Duration, predicate LockableCondition) bool {
	return condition.associated_lock.wait_until(timeout, predicate)
}

pub fn (mut condition Condition) signal() &Condition {
	condition.associated_lock.signal()
	return condition
}

pub fn (mut condition Condition) broadcast() &Condition {
	condition.associated_lock.broadcast()
	return condition
}

fn condition_boundary_value(condition &Condition) ruby.Value {
	return ruby.structured_value('Concurrent::Synchronization::Condition', '#<Concurrent::Synchronization::Condition>', {
		'condition_address': u64(voidptr(condition)).str()
	})
}

fn condition_boundary_receiver(args []ruby.Value) &Condition {
	if args.len == 0 {
		panic('Condition method requires a receiver')
	}
	address := (args[0].attribute('condition_address') or {
		panic('${args[0].type_name} has no translated Condition state')
	}).u64()
	return unsafe { &Condition(voidptr(address)) }
}

// Ruby alias_method `singleton_class.send :alias_method, :private_new, :new` at line 15.
pub fn ruby_condition_l15_d1_private_new(args ...ruby.Value) ruby.Value {
	return ruby_condition_l18_d2_initialize(...args)
}

// Ruby method `initialize(lock)` at line 18.
pub fn ruby_condition_l18_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Condition.new requires a LockableObject')
	}
	return condition_boundary_value(new_condition(lockable_boundary_receiver(args)))
}

// Ruby method `wait(timeout = nil)` at line 23.
pub fn ruby_condition_l23_d3_wait(args ...ruby.Value) ruby.Value {
	mut condition := condition_boundary_receiver(args)
	condition.wait(lockable_boundary_timeout(args, 1))
	return args[0]
}

// Ruby method `ns_wait(timeout = nil)` at line 27.
pub fn ruby_condition_l27_d4_ns_wait(args ...ruby.Value) ruby.Value {
	return ruby_condition_l23_d3_wait(...args)
}

// Ruby method `wait_until(timeout = nil, &condition)` at line 31.
pub fn ruby_condition_l31_d5_wait_until(args ...ruby.Value) ruby.Value {
	mut condition := condition_boundary_receiver(args)
	expected := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return ruby.bool_value(condition.wait_until(lockable_boundary_timeout(args, 1), fn [expected] () bool {
		return expected
	}))
}

// Ruby method `ns_wait_until(timeout = nil, &condition)` at line 35.
pub fn ruby_condition_l35_d6_ns_wait_until(args ...ruby.Value) ruby.Value {
	return ruby_condition_l31_d5_wait_until(...args)
}

// Ruby method `signal` at line 39.
pub fn ruby_condition_l39_d7_signal(args ...ruby.Value) ruby.Value {
	mut condition := condition_boundary_receiver(args)
	condition.signal()
	return args[0]
}

// Ruby method `ns_signal` at line 43.
pub fn ruby_condition_l43_d8_ns_signal(args ...ruby.Value) ruby.Value {
	return ruby_condition_l39_d7_signal(...args)
}

// Ruby method `broadcast` at line 47.
pub fn ruby_condition_l47_d9_broadcast(args ...ruby.Value) ruby.Value {
	mut condition := condition_boundary_receiver(args)
	condition.broadcast()
	return args[0]
}

// Ruby method `ns_broadcast` at line 51.
pub fn ruby_condition_l51_d10_ns_broadcast(args ...ruby.Value) ruby.Value {
	return ruby_condition_l47_d9_broadcast(...args)
}

// Ruby method `new_condition` at line 57.
pub fn ruby_condition_l57_d11_new_condition(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LockableObject#new_condition requires a receiver')
	}
	return condition_boundary_value(new_condition(lockable_boundary_receiver(args)))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:
// 6:     # @!visibility private
// 7:     # TODO (pitr-ch 04-Dec-2016): should be in edge
// 8:     class Condition < LockableObject
// 9:       safe_initialization!
// 10:
// 11:       # TODO (pitr 12-Sep-2015): locks two objects, improve
// 12:       # TODO (pitr 26-Sep-2015): study
// 13:       # http://grepcode.com/file/repository.grepcode.com/java/root/jdk/openjdk/8-b132/java/util/concurrent/locks/AbstractQueuedSynchronizer.java#AbstractQueuedSynchronizer.Node
// 14:
// 15:       singleton_class.send :alias_method, :private_new, :new
// 16:       private_class_method :new
// 17:
// 18:       def initialize(lock)
// 19:         super()
// 20:         @Lock = lock
// 21:       end
// 22:
// 23:       def wait(timeout = nil)
// 24:         @Lock.synchronize { ns_wait(timeout) }
// 25:       end
// 26:
// 27:       def ns_wait(timeout = nil)
// 28:         synchronize { super(timeout) }
// 29:       end
// 30:
// 31:       def wait_until(timeout = nil, &condition)
// 32:         @Lock.synchronize { ns_wait_until(timeout, &condition) }
// 33:       end
// 34:
// 35:       def ns_wait_until(timeout = nil, &condition)
// 36:         synchronize { super(timeout, &condition) }
// 37:       end
// 38:
// 39:       def signal
// 40:         @Lock.synchronize { ns_signal }
// 41:       end
// 42:
// 43:       def ns_signal
// 44:         synchronize { super }
// 45:       end
// 46:
// 47:       def broadcast
// 48:         @Lock.synchronize { ns_broadcast }
// 49:       end
// 50:
// 51:       def ns_broadcast
// 52:         synchronize { super }
// 53:       end
// 54:     end
// 55:
// 56:     class LockableObject < LockableObjectImplementation
// 57:       def new_condition
// 58:         Condition.private_new(self)
// 59:       end
// 60:     end
// 61:   end
// 62: end
