module thread_safe

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/synchronized_delegator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `setup` at line 22.
pub fn ruby_synchronized_delegator_l22_d1_setup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup', ...args)
}

// Ruby method `teardown` at line 27.
pub fn ruby_synchronized_delegator_l27_d2_teardown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('teardown', ...args)
}

// Ruby method `initialize(obj)` at line 31.
pub fn ruby_synchronized_delegator_l31_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `method_missing(method, *args, &block)` at line 36.
pub fn ruby_synchronized_delegator_l36_d4_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'delegate'
// 2: require 'monitor'
// 3:
// 4: module Concurrent
// 5:   # This class provides a trivial way to synchronize all calls to a given object
// 6:   # by wrapping it with a `Delegator` that performs `Monitor#enter/exit` calls
// 7:   # around the delegated `#send`. Example:
// 8:   #
// 9:   #   array = [] # not thread-safe on many impls
// 10:   #   array = SynchronizedDelegator.new([]) # thread-safe
// 11:   #
// 12:   # A simple `Monitor` provides a very coarse-grained way to synchronize a given
// 13:   # object, in that it will cause synchronization for methods that have no need
// 14:   # for it, but this is a trivial way to get thread-safety where none may exist
// 15:   # currently on some implementations.
// 16:   #
// 17:   # This class is currently being considered for inclusion into stdlib, via
// 18:   # https://bugs.ruby-lang.org/issues/8556
// 19:   #
// 20:   # @!visibility private
// 21:   class SynchronizedDelegator < SimpleDelegator
// 22:     def setup
// 23:       @old_abort = Thread.abort_on_exception
// 24:       Thread.abort_on_exception = true
// 25:     end
// 26:
// 27:     def teardown
// 28:       Thread.abort_on_exception = @old_abort
// 29:     end
// 30:
// 31:     def initialize(obj)
// 32:       __setobj__(obj)
// 33:       @monitor = Monitor.new
// 34:     end
// 35:
// 36:     def method_missing(method, *args, &block)
// 37:       monitor = @monitor
// 38:       begin
// 39:         monitor.enter
// 40:         super
// 41:       ensure
// 42:         monitor.exit
// 43:       end
// 44:     end
// 45:
// 46:   end
// 47: end
