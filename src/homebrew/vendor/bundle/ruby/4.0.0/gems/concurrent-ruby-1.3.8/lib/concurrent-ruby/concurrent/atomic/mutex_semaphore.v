module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_semaphore.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(count)` at line 12.
pub fn ruby_mutex_semaphore_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `acquire(permits = 1)` at line 20.
pub fn ruby_mutex_semaphore_l20_d2_acquire(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('acquire', ...args)
}

// Ruby method `available_permits` at line 38.
pub fn ruby_mutex_semaphore_l38_d3_available_permits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available_permits', ...args)
}

// Ruby method `drain_permits` at line 47.
pub fn ruby_mutex_semaphore_l47_d4_drain_permits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('drain_permits', ...args)
}

// Ruby method `try_acquire(permits = 1, timeout = nil)` at line 54.
pub fn ruby_mutex_semaphore_l54_d5_try_acquire(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_acquire', ...args)
}

// Ruby method `release(permits = 1)` at line 77.
pub fn ruby_mutex_semaphore_l77_d6_release(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('release', ...args)
}

// Ruby method `reduce_permits(reduction)` at line 99.
pub fn ruby_mutex_semaphore_l99_d7_reduce_permits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reduce_permits', ...args)
}

// Ruby method `ns_initialize(count)` at line 110.
pub fn ruby_mutex_semaphore_l110_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `try_acquire_now(permits)` at line 117.
pub fn ruby_mutex_semaphore_l117_d9_try_acquire_now(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_acquire_now', ...args)
}

// Ruby method `try_acquire_timed(permits, timeout)` at line 127.
pub fn ruby_mutex_semaphore_l127_d10_try_acquire_timed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_acquire_timed', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro semaphore
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexSemaphore < Synchronization::LockableObject
// 10:
// 11:     # @!macro semaphore_method_initialize
// 12:     def initialize(count)
// 13:       Utility::NativeInteger.ensure_integer_and_bounds count
// 14:
// 15:       super()
// 16:       synchronize { ns_initialize count }
// 17:     end
// 18:
// 19:     # @!macro semaphore_method_acquire
// 20:     def acquire(permits = 1)
// 21:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 22:       Utility::NativeInteger.ensure_positive permits
// 23:
// 24:       synchronize do
// 25:         try_acquire_timed(permits, nil)
// 26:       end
// 27:
// 28:       return unless block_given?
// 29:
// 30:       begin
// 31:         yield
// 32:       ensure
// 33:         release(permits)
// 34:       end
// 35:     end
// 36:
// 37:     # @!macro semaphore_method_available_permits
// 38:     def available_permits
// 39:       synchronize { @free }
// 40:     end
// 41:
// 42:     # @!macro semaphore_method_drain_permits
// 43:     #
// 44:     #   Acquires and returns all permits that are immediately available.
// 45:     #
// 46:     #   @return [Integer]
// 47:     def drain_permits
// 48:       synchronize do
// 49:         @free.tap { |_| @free = 0 }
// 50:       end
// 51:     end
// 52:
// 53:     # @!macro semaphore_method_try_acquire
// 54:     def try_acquire(permits = 1, timeout = nil)
// 55:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 56:       Utility::NativeInteger.ensure_positive permits
// 57:
// 58:       acquired = synchronize do
// 59:         if timeout.nil?
// 60:           try_acquire_now(permits)
// 61:         else
// 62:           try_acquire_timed(permits, timeout)
// 63:         end
// 64:       end
// 65:
// 66:       return acquired unless block_given?
// 67:       return unless acquired
// 68:
// 69:       begin
// 70:         yield
// 71:       ensure
// 72:         release(permits)
// 73:       end
// 74:     end
// 75:
// 76:     # @!macro semaphore_method_release
// 77:     def release(permits = 1)
// 78:       Utility::NativeInteger.ensure_integer_and_bounds permits
// 79:       Utility::NativeInteger.ensure_positive permits
// 80:
// 81:       synchronize do
// 82:         @free += permits
// 83:         permits.times { ns_signal }
// 84:       end
// 85:       nil
// 86:     end
// 87:
// 88:     # Shrinks the number of available permits by the indicated reduction.
// 89:     #
// 90:     # @param [Fixnum] reduction Number of permits to remove.
// 91:     #
// 92:     # @raise [ArgumentError] if `reduction` is not an integer or is negative
// 93:     #
// 94:     # @raise [ArgumentError] if `@free` - `@reduction` is less than zero
// 95:     #
// 96:     # @return [nil]
// 97:     #
// 98:     # @!visibility private
// 99:     def reduce_permits(reduction)
// 100:       Utility::NativeInteger.ensure_integer_and_bounds reduction
// 101:       Utility::NativeInteger.ensure_positive reduction
// 102:
// 103:       synchronize { @free -= reduction }
// 104:       nil
// 105:     end
// 106:
// 107:     protected
// 108:
// 109:     # @!visibility private
// 110:     def ns_initialize(count)
// 111:       @free = count
// 112:     end
// 113:
// 114:     private
// 115:
// 116:     # @!visibility private
// 117:     def try_acquire_now(permits)
// 118:       if @free >= permits
// 119:         @free -= permits
// 120:         true
// 121:       else
// 122:         false
// 123:       end
// 124:     end
// 125:
// 126:     # @!visibility private
// 127:     def try_acquire_timed(permits, timeout)
// 128:       ns_wait_until(timeout) { try_acquire_now(permits) }
// 129:     end
// 130:   end
// 131: end
