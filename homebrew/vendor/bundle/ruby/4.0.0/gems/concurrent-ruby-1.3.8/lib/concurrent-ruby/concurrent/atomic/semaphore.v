module atomic

import ruby
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/semaphore.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct Semaphore {
mut:
	implementation &MutexSemaphore
}

pub fn new_semaphore(count i64) !&Semaphore {
	return &Semaphore{
		implementation: new_mutex_semaphore(count)!
	}
}

pub fn (mut semaphore Semaphore) acquire(permits i64) ! {
	semaphore.implementation.acquire(permits)!
}

pub fn (mut semaphore Semaphore) acquire_with(permits i64, action SemaphoreAction) !ruby.Value {
	return semaphore.implementation.acquire_with(permits, action)
}

pub fn (mut semaphore Semaphore) available_permits() i64 {
	return semaphore.implementation.available_permits()
}

pub fn (mut semaphore Semaphore) drain_permits() i64 {
	return semaphore.implementation.drain_permits()
}

pub fn (mut semaphore Semaphore) try_acquire(permits i64, timeout ?time.Duration) !bool {
	return semaphore.implementation.try_acquire(permits, timeout)
}

pub fn (mut semaphore Semaphore) try_acquire_with(permits i64, timeout ?time.Duration, action SemaphoreAction) !SemaphoreActionResult {
	return semaphore.implementation.try_acquire_with(permits, timeout, action)
}

pub fn (mut semaphore Semaphore) release(permits i64) ! {
	semaphore.implementation.release(permits)!
}

pub fn (mut semaphore Semaphore) reduce_permits(reduction i64) ! {
	semaphore.implementation.reduce_permits(reduction)!
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/mutex_semaphore'
// 2:
// 3: module Concurrent
// 4:
// 5:   ###################################################################
// 6:
// 7:   # @!macro semaphore_method_initialize
// 8:   #
// 9:   #   Create a new `Semaphore` with the initial `count`.
// 10:   #
// 11:   #   @param [Fixnum] count the initial count
// 12:   #
// 13:   #   @raise [ArgumentError] if `count` is not an integer
// 14:
// 15:   # @!macro semaphore_method_acquire
// 16:   #
// 17:   #   Acquires the given number of permits from this semaphore,
// 18:   #     blocking until all are available. If a block is given,
// 19:   #     yields to it and releases the permits afterwards.
// 20:   #
// 21:   #   @param [Fixnum] permits Number of permits to acquire
// 22:   #
// 23:   #   @raise [ArgumentError] if `permits` is not an integer or is less than zero
// 24:   #
// 25:   #   @return [nil, BasicObject] Without a block, `nil` is returned. If a block
// 26:   #   is given, its return value is returned.
// 27:
// 28:   # @!macro semaphore_method_available_permits
// 29:   #
// 30:   #   Returns the current number of permits available in this semaphore.
// 31:   #
// 32:   #   @return [Integer]
// 33:
// 34:   # @!macro semaphore_method_drain_permits
// 35:   #
// 36:   #   Acquires and returns all permits that are immediately available.
// 37:   #
// 38:   #   @return [Integer]
// 39:
// 40:   # @!macro semaphore_method_try_acquire
// 41:   #
// 42:   #   Acquires the given number of permits from this semaphore,
// 43:   #     only if all are available at the time of invocation or within
// 44:   #     `timeout` interval. If a block is given, yields to it if the permits
// 45:   #     were successfully acquired, and releases them afterward, returning the
// 46:   #     block's return value.
// 47:   #
// 48:   #   @param [Fixnum] permits the number of permits to acquire
// 49:   #
// 50:   #   @param [Fixnum] timeout the number of seconds to wait for the counter
// 51:   #     or `nil` to return immediately
// 52:   #
// 53:   #   @raise [ArgumentError] if `permits` is not an integer or is less than zero
// 54:   #
// 55:   #   @return [true, false, nil, BasicObject] `false` if no permits are
// 56:   #     available, `true` when acquired a permit. If a block is given, the
// 57:   #     block's return value is returned if the permits were acquired; if not,
// 58:   #     `nil` is returned.
// 59:
// 60:   # @!macro semaphore_method_release
// 61:   #
// 62:   #   Releases the given number of permits, returning them to the semaphore.
// 63:   #
// 64:   #   @param [Fixnum] permits Number of permits to return to the semaphore.
// 65:   #
// 66:   #   @raise [ArgumentError] if `permits` is not a number or is less than zero
// 67:   #
// 68:   #   @return [nil]
// 69:
// 70:   ###################################################################
// 71:
// 72:   # @!macro semaphore_public_api
// 73:   #
// 74:   #   @!method initialize(count)
// 75:   #     @!macro semaphore_method_initialize
// 76:   #
// 77:   #   @!method acquire(permits = 1)
// 78:   #     @!macro semaphore_method_acquire
// 79:   #
// 80:   #   @!method available_permits
// 81:   #     @!macro semaphore_method_available_permits
// 82:   #
// 83:   #   @!method drain_permits
// 84:   #     @!macro semaphore_method_drain_permits
// 85:   #
// 86:   #   @!method try_acquire(permits = 1, timeout = nil)
// 87:   #     @!macro semaphore_method_try_acquire
// 88:   #
// 89:   #   @!method release(permits = 1)
// 90:   #     @!macro semaphore_method_release
// 91:
// 92:   ###################################################################
// 93:
// 94:   # @!visibility private
// 95:   # @!macro internal_implementation_note
// 96:   SemaphoreImplementation = if Concurrent.on_jruby?
// 97:                               require 'concurrent/utility/native_extension_loader'
// 98:                               JavaSemaphore
// 99:                             else
// 100:                               MutexSemaphore
// 101:                             end
// 102:   private_constant :SemaphoreImplementation
// 103:
// 104:   # @!macro semaphore
// 105:   #
// 106:   #   A counting semaphore. Conceptually, a semaphore maintains a set of
// 107:   #   permits. Each {#acquire} blocks if necessary until a permit is
// 108:   #   available, and then takes it. Each {#release} adds a permit, potentially
// 109:   #   releasing a blocking acquirer.
// 110:   #   However, no actual permit objects are used; the Semaphore just keeps a
// 111:   #   count of the number available and acts accordingly.
// 112:   #   Alternatively, permits may be acquired within a block, and automatically
// 113:   #   released after the block finishes executing.
// 114:   #
// 115:   # @!macro semaphore_public_api
// 116:   # @example
// 117:   #   semaphore = Concurrent::Semaphore.new(2)
// 118:   #
// 119:   #   t1 = Thread.new do
// 120:   #     semaphore.acquire
// 121:   #     puts "Thread 1 acquired semaphore"
// 122:   #   end
// 123:   #
// 124:   #   t2 = Thread.new do
// 125:   #     semaphore.acquire
// 126:   #     puts "Thread 2 acquired semaphore"
// 127:   #   end
// 128:   #
// 129:   #   t3 = Thread.new do
// 130:   #     semaphore.acquire
// 131:   #     puts "Thread 3 acquired semaphore"
// 132:   #   end
// 133:   #
// 134:   #   t4 = Thread.new do
// 135:   #     sleep(2)
// 136:   #     puts "Thread 4 releasing semaphore"
// 137:   #     semaphore.release
// 138:   #   end
// 139:   #
// 140:   #   [t1, t2, t3, t4].each(&:join)
// 141:   #
// 142:   #   # prints:
// 143:   #   # Thread 3 acquired semaphore
// 144:   #   # Thread 2 acquired semaphore
// 145:   #   # Thread 4 releasing semaphore
// 146:   #   # Thread 1 acquired semaphore
// 147:   #
// 148:   # @example
// 149:   #   semaphore = Concurrent::Semaphore.new(1)
// 150:   #
// 151:   #   puts semaphore.available_permits
// 152:   #   semaphore.acquire do
// 153:   #     puts semaphore.available_permits
// 154:   #   end
// 155:   #   puts semaphore.available_permits
// 156:   #
// 157:   #   # prints:
// 158:   #   # 1
// 159:   #   # 0
// 160:   #   # 1
// 161:   class Semaphore < SemaphoreImplementation
// 162:   end
// 163: end
