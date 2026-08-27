module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/event.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 40.
pub fn ruby_event_l40_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `set?` at line 48.
pub fn ruby_event_l48_d2_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set?', ...args)
}

// Ruby method `set` at line 56.
pub fn ruby_event_l56_d3_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `try?` at line 60.
pub fn ruby_event_l60_d4_try(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try?', ...args)
}

// Ruby method `reset` at line 68.
pub fn ruby_event_l68_d5_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset', ...args)
}

// Ruby method `wait(timeout = nil)` at line 83.
pub fn ruby_event_l83_d6_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `ns_set` at line 96.
pub fn ruby_event_l96_d7_ns_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_set', ...args)
}

// Ruby method `ns_initialize` at line 104.
pub fn ruby_event_l104_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/synchronization/lockable_object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # Old school kernel-style event reminiscent of Win32 programming in C++.
// 7:   #
// 8:   # When an `Event` is created it is in the `unset` state. Threads can choose to
// 9:   # `#wait` on the event, blocking until released by another thread. When one
// 10:   # thread wants to alert all blocking threads it calls the `#set` method which
// 11:   # will then wake up all listeners. Once an `Event` has been set it remains set.
// 12:   # New threads calling `#wait` will return immediately. An `Event` may be
// 13:   # `#reset` at any time once it has been set.
// 14:   #
// 15:   # @see http://msdn.microsoft.com/en-us/library/windows/desktop/ms682655.aspx
// 16:   # @example
// 17:   #   event = Concurrent::Event.new
// 18:   #
// 19:   #   t1 = Thread.new do
// 20:   #     puts "t1 is waiting"
// 21:   #     event.wait(1)
// 22:   #     puts "event occurred"
// 23:   #   end
// 24:   #
// 25:   #   t2 = Thread.new do
// 26:   #     puts "t2 calling set"
// 27:   #     event.set
// 28:   #   end
// 29:   #
// 30:   #   [t1, t2].each(&:join)
// 31:   #
// 32:   #   # prints:
// 33:   #   # t1 is waiting
// 34:   #   # t2 calling set
// 35:   #   # event occurred
// 36:   class Event < Synchronization::LockableObject
// 37:
// 38:     # Creates a new `Event` in the unset state. Threads calling `#wait` on the
// 39:     # `Event` will block.
// 40:     def initialize
// 41:       super
// 42:       synchronize { ns_initialize }
// 43:     end
// 44:
// 45:     # Is the object in the set state?
// 46:     #
// 47:     # @return [Boolean] indicating whether or not the `Event` has been set
// 48:     def set?
// 49:       synchronize { @set }
// 50:     end
// 51:
// 52:     # Trigger the event, setting the state to `set` and releasing all threads
// 53:     # waiting on the event. Has no effect if the `Event` has already been set.
// 54:     #
// 55:     # @return [Boolean] should always return `true`
// 56:     def set
// 57:       synchronize { ns_set }
// 58:     end
// 59:
// 60:     def try?
// 61:       synchronize { @set ? false : ns_set }
// 62:     end
// 63:
// 64:     # Reset a previously set event back to the `unset` state.
// 65:     # Has no effect if the `Event` has not yet been set.
// 66:     #
// 67:     # @return [Boolean] should always return `true`
// 68:     def reset
// 69:       synchronize do
// 70:         if @set
// 71:           @set       = false
// 72:           @iteration +=1
// 73:         end
// 74:         true
// 75:       end
// 76:     end
// 77:
// 78:     # Wait a given number of seconds for the `Event` to be set by another
// 79:     # thread. Will wait forever when no `timeout` value is given. Returns
// 80:     # immediately if the `Event` has already been set.
// 81:     #
// 82:     # @return [Boolean] true if the `Event` was set before timeout else false
// 83:     def wait(timeout = nil)
// 84:       synchronize do
// 85:         unless @set
// 86:           iteration = @iteration
// 87:           ns_wait_until(timeout) { iteration < @iteration || @set }
// 88:         else
// 89:           true
// 90:         end
// 91:       end
// 92:     end
// 93:
// 94:     protected
// 95:
// 96:     def ns_set
// 97:       unless @set
// 98:         @set = true
// 99:         ns_broadcast
// 100:       end
// 101:       true
// 102:     end
// 103:
// 104:     def ns_initialize
// 105:       @set       = false
// 106:       @iteration = 0
// 107:     end
// 108:   end
// 109: end
