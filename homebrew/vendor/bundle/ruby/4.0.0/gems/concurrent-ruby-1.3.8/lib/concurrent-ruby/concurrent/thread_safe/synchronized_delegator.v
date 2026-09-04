module thread_safe

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/synchronized_delegator.rb`.
// The original source is retained below until every stub has a typed V body.
pub type DelegatedAction = fn(ruby.Value, string, []ruby.Value) !ruby.Value

@[heap]
pub struct SynchronizedDelegator {
pub:
	object ruby.Value
mut:
	monitor            sync.Mutex
	abort_on_exception bool
	old_abort          bool
}

pub fn new_synchronized_delegator(object ruby.Value) &SynchronizedDelegator {
	return &SynchronizedDelegator{
		object: object
	}
}

pub fn (mut delegator SynchronizedDelegator) setup() bool {
	delegator.monitor.lock()
	delegator.old_abort = delegator.abort_on_exception
	delegator.abort_on_exception = true
	delegator.monitor.unlock()
	return true
}

pub fn (mut delegator SynchronizedDelegator) teardown() bool {
	delegator.monitor.lock()
	delegator.abort_on_exception = delegator.old_abort
	current := delegator.abort_on_exception
	delegator.monitor.unlock()
	return current
}

pub fn (mut delegator SynchronizedDelegator) invoke(method string, args []ruby.Value, action DelegatedAction) !ruby.Value {
	delegator.monitor.lock()
	defer {
		delegator.monitor.unlock()
	}
	return action(delegator.object, method, args)
}

fn synchronized_delegator_value(delegator &SynchronizedDelegator) ruby.Value {
	return ruby.structured_value('Concurrent::SynchronizedDelegator', '#<Concurrent::SynchronizedDelegator>', {
		'synchronized_delegator_address': u64(voidptr(delegator)).str()
	})
}

fn synchronized_delegator_from_args(args []ruby.Value) &SynchronizedDelegator {
	if args.len == 0 {
		panic('SynchronizedDelegator method requires a receiver')
	}
	address := (args[0].attribute('synchronized_delegator_address') or {
		panic('${args[0].type_name} has no translated SynchronizedDelegator state')
	}).u64()
	return unsafe { &SynchronizedDelegator(voidptr(address)) }
}

// Ruby method `setup` at line 22.
pub fn ruby_synchronized_delegator_l22_d1_setup(args ...ruby.Value) ruby.Value {
	mut delegator := synchronized_delegator_from_args(args)
	return ruby.bool_value(delegator.setup())
}

// Ruby method `teardown` at line 27.
pub fn ruby_synchronized_delegator_l27_d2_teardown(args ...ruby.Value) ruby.Value {
	mut delegator := synchronized_delegator_from_args(args)
	return ruby.bool_value(delegator.teardown())
}

// Ruby method `initialize(obj)` at line 31.
pub fn ruby_synchronized_delegator_l31_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SynchronizedDelegator.new requires an object')
	}
	return synchronized_delegator_value(new_synchronized_delegator(args[0]))
}

// Ruby method `method_missing(method, *args, &block)` at line 36.
pub fn ruby_synchronized_delegator_l36_d4_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('SynchronizedDelegator#method_missing requires receiver, method, and translated delegated result')
	}
	mut delegator := synchronized_delegator_from_args(args)
	method := args[1].as_string()
	call_args := if args.len > 3 { args[2..args.len - 1] } else { []ruby.Value{} }
	mut result := args[args.len - 1]
	return delegator.invoke(method, call_args, fn [mut result] (_ ruby.Value, _ string, _ []ruby.Value) !ruby.Value {
		return result
	}) or { panic(err) }
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
