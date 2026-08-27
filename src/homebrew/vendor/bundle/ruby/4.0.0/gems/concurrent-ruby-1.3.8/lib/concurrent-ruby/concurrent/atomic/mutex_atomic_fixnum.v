module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_atomic_fixnum.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(initial = 0)` at line 13.
pub fn ruby_mutex_atomic_fixnum_l13_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `value` at line 20.
pub fn ruby_mutex_atomic_fixnum_l20_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `value=(value)` at line 25.
pub fn ruby_mutex_atomic_fixnum_l25_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby method `increment(delta = 1)` at line 30.
pub fn ruby_mutex_atomic_fixnum_l30_d4_increment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('increment', ...args)
}

// Ruby alias_method `alias_method :up, :increment` at line 34.
pub fn ruby_mutex_atomic_fixnum_l34_d5_up(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('up', ...args)
}

// Ruby method `decrement(delta = 1)` at line 37.
pub fn ruby_mutex_atomic_fixnum_l37_d6_decrement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decrement', ...args)
}

// Ruby alias_method `alias_method :down, :decrement` at line 41.
pub fn ruby_mutex_atomic_fixnum_l41_d7_down(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('down', ...args)
}

// Ruby method `compare_and_set(expect, update)` at line 44.
pub fn ruby_mutex_atomic_fixnum_l44_d8_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set', ...args)
}

// Ruby method `update` at line 56.
pub fn ruby_mutex_atomic_fixnum_l56_d9_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update', ...args)
}

// Ruby method `synchronize` at line 65.
pub fn ruby_mutex_atomic_fixnum_l65_d10_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synchronize', ...args)
}

// Ruby method `ns_set(value)` at line 76.
pub fn ruby_mutex_atomic_fixnum_l76_d11_ns_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_set', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/safe_initialization'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro atomic_fixnum
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexAtomicFixnum
// 10:     extend Concurrent::Synchronization::SafeInitialization
// 11:
// 12:     # @!macro atomic_fixnum_method_initialize
// 13:     def initialize(initial = 0)
// 14:       super()
// 15:       @Lock = ::Mutex.new
// 16:       ns_set(initial)
// 17:     end
// 18:
// 19:     # @!macro atomic_fixnum_method_value_get
// 20:     def value
// 21:       synchronize { @value }
// 22:     end
// 23:
// 24:     # @!macro atomic_fixnum_method_value_set
// 25:     def value=(value)
// 26:       synchronize { ns_set(value) }
// 27:     end
// 28:
// 29:     # @!macro atomic_fixnum_method_increment
// 30:     def increment(delta = 1)
// 31:       synchronize { ns_set(@value + delta.to_i) }
// 32:     end
// 33:
// 34:     alias_method :up, :increment
// 35:
// 36:     # @!macro atomic_fixnum_method_decrement
// 37:     def decrement(delta = 1)
// 38:       synchronize { ns_set(@value - delta.to_i) }
// 39:     end
// 40:
// 41:     alias_method :down, :decrement
// 42:
// 43:     # @!macro atomic_fixnum_method_compare_and_set
// 44:     def compare_and_set(expect, update)
// 45:       synchronize do
// 46:         if @value == expect.to_i
// 47:           @value = update.to_i
// 48:           true
// 49:         else
// 50:           false
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     # @!macro atomic_fixnum_method_update
// 56:     def update
// 57:       synchronize do
// 58:         @value = yield @value
// 59:       end
// 60:     end
// 61:
// 62:     protected
// 63:
// 64:     # @!visibility private
// 65:     def synchronize
// 66:       if @Lock.owned?
// 67:         yield
// 68:       else
// 69:         @Lock.synchronize { yield }
// 70:       end
// 71:     end
// 72:
// 73:     private
// 74:
// 75:     # @!visibility private
// 76:     def ns_set(value)
// 77:       Utility::NativeInteger.ensure_integer_and_bounds value
// 78:       @value = value
// 79:     end
// 80:   end
// 81: end
