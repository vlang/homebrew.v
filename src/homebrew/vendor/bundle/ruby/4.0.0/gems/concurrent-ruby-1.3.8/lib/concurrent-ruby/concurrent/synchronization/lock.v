module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/lock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `wait(timeout = nil)` at line 13.
pub fn ruby_lock_l13_d1_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `wait_until(timeout = nil, &condition)` at line 19.
pub fn ruby_lock_l19_d2_wait_until(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_until', ...args)
}

// Ruby method `signal` at line 25.
pub fn ruby_lock_l25_d3_signal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('signal', ...args)
}

// Ruby method `broadcast` at line 31.
pub fn ruby_lock_l31_d4_broadcast(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('broadcast', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:
// 6:     # @!visibility private
// 7:     # TODO (pitr-ch 04-Dec-2016): should be in edge
// 8:     class Lock < LockableObject
// 9:       # TODO use JavaReentrantLock on JRuby
// 10:
// 11:       public :synchronize
// 12:
// 13:       def wait(timeout = nil)
// 14:         synchronize { ns_wait(timeout) }
// 15:       end
// 16:
// 17:       public :ns_wait
// 18:
// 19:       def wait_until(timeout = nil, &condition)
// 20:         synchronize { ns_wait_until(timeout, &condition) }
// 21:       end
// 22:
// 23:       public :ns_wait_until
// 24:
// 25:       def signal
// 26:         synchronize { ns_signal }
// 27:       end
// 28:
// 29:       public :ns_signal
// 30:
// 31:       def broadcast
// 32:         synchronize { ns_broadcast }
// 33:       end
// 34:
// 35:       public :ns_broadcast
// 36:     end
// 37:   end
// 38: end
