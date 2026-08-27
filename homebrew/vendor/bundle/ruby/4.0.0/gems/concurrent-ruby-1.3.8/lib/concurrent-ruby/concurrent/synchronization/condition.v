module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/condition.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_method `singleton_class.send :alias_method, :private_new, :new` at line 15.
pub fn ruby_condition_l15_d1_private_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('private_new', ...args)
}

// Ruby method `initialize(lock)` at line 18.
pub fn ruby_condition_l18_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `wait(timeout = nil)` at line 23.
pub fn ruby_condition_l23_d3_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `ns_wait(timeout = nil)` at line 27.
pub fn ruby_condition_l27_d4_ns_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_wait', ...args)
}

// Ruby method `wait_until(timeout = nil, &condition)` at line 31.
pub fn ruby_condition_l31_d5_wait_until(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_until', ...args)
}

// Ruby method `ns_wait_until(timeout = nil, &condition)` at line 35.
pub fn ruby_condition_l35_d6_ns_wait_until(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_wait_until', ...args)
}

// Ruby method `signal` at line 39.
pub fn ruby_condition_l39_d7_signal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('signal', ...args)
}

// Ruby method `ns_signal` at line 43.
pub fn ruby_condition_l43_d8_ns_signal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_signal', ...args)
}

// Ruby method `broadcast` at line 47.
pub fn ruby_condition_l47_d9_broadcast(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('broadcast', ...args)
}

// Ruby method `ns_broadcast` at line 51.
pub fn ruby_condition_l51_d10_ns_broadcast(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_broadcast', ...args)
}

// Ruby method `new_condition` at line 57.
pub fn ruby_condition_l57_d11_new_condition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_condition', ...args)
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
