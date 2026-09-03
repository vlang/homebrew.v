module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/lock_local_var.rb`.
// The original source is retained below until every stub has a typed V body.

// V has no Ruby Fiber scheduler; mutex ownership is therefore not exposed as a
// Ruby-thread-local property.
pub fn mutex_owned_per_thread() bool {
	return false
}

// Ruby method `self.mutex_owned_per_thread?` at line 7.
pub fn ruby_lock_local_var_l7_d1_self_mutex_owned_per_thread(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(mutex_owned_per_thread())
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require_relative 'fiber_local_var'
// 3: require_relative 'thread_local_var'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   def self.mutex_owned_per_thread?
// 8:     return false if Concurrent.on_jruby? || Concurrent.on_truffleruby?
// 9:     return RUBY_VERSION < "3.0" if Concurrent.on_cruby?
// 10:
// 11:     mutex = Mutex.new
// 12:     # Lock the mutex:
// 13:     mutex.synchronize do
// 14:       # Check if the mutex is still owned in a child fiber:
// 15:       Fiber.new { mutex.owned? }.resume
// 16:     end
// 17:   end
// 18:
// 19:   if mutex_owned_per_thread?
// 20:     LockLocalVar = ThreadLocalVar
// 21:   else
// 22:     LockLocalVar = FiberLocalVar
// 23:   end
// 24:
// 25:   # Either {FiberLocalVar} or {ThreadLocalVar} depending on whether Mutex (and Monitor)
// 26:   # are held, respectively, per Fiber or per Thread.
// 27:   class LockLocalVar
// 28:   end
// 29: end
