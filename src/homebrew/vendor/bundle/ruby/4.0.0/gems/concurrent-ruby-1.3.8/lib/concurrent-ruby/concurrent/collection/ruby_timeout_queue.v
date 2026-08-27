module collection

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/ruby_timeout_queue.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args)` at line 6.
pub fn ruby_ruby_timeout_queue_l6_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `push(obj)` at line 17.
pub fn ruby_ruby_timeout_queue_l17_d2_push(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('push', ...args)
}

// Ruby alias_method `alias_method :enq, :push` at line 23.
pub fn ruby_ruby_timeout_queue_l23_d3_enq(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enq', ...args)
}

// Ruby alias_method `alias_method :<<, :push` at line 24.
pub fn ruby_ruby_timeout_queue_l24_d4_push(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('push', ...args)
}

// Ruby method `pop(non_block = false, timeout: nil)` at line 26.
pub fn ruby_ruby_timeout_queue_l26_d5_pop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pop', ...args)
}

// Ruby alias_method `alias_method :deq, :pop` at line 50.
pub fn ruby_ruby_timeout_queue_l50_d6_deq(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deq', ...args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 51.
pub fn ruby_ruby_timeout_queue_l51_d7_shift(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift', ...args)
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
