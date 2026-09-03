module atomic

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/reentrant_read_write_lock.rb`.
// The original source is retained below until every stub has a typed V body.
const reentrant_reader_bits = 15
const reentrant_writer_bits = 14
const reentrant_waiting_writer = i64(32_768)
const reentrant_running_writer = i64(536_870_912)
const reentrant_max_readers = reentrant_waiting_writer - 1
const reentrant_max_writers = reentrant_running_writer - reentrant_max_readers - 1
const reentrant_write_lock_held = reentrant_waiting_writer
const reentrant_read_lock_mask = reentrant_write_lock_held - 1
const reentrant_write_lock_mask = reentrant_max_writers

@[heap]
struct ReentrantReadWriteLockState {
	mutex           &sync.Mutex
	read_condition  &sync.Cond
	write_condition &sync.Cond
mut:
	counter i64
	holds   map[u64]i64
}

@[heap]
pub struct ReentrantReadWriteLock {
mut:
	state &ReentrantReadWriteLockState
}

pub fn new_reentrant_read_write_lock() &ReentrantReadWriteLock {
	mutex := sync.new_mutex()
	return &ReentrantReadWriteLock{
		state: &ReentrantReadWriteLockState{
			mutex: mutex
			read_condition: sync.new_cond(mutex)
			write_condition: sync.new_cond(mutex)
		}
	}
}

fn reentrant_running_readers(counter i64) i64 {
	return counter & reentrant_max_readers
}

fn reentrant_running_readers_present(counter i64) bool {
	return reentrant_running_readers(counter) > 0
}

fn reentrant_running_writer_present(counter i64) bool {
	return counter >= reentrant_running_writer
}

fn reentrant_waiting_writers(counter i64) i64 {
	return (counter & reentrant_max_writers) >> reentrant_reader_bits
}

fn reentrant_waiting_or_running_writer_present(counter i64) bool {
	return counter >= reentrant_waiting_writer
}

fn reentrant_max_readers_reached(counter i64) bool {
	return (counter & reentrant_max_readers) == reentrant_max_readers
}

fn reentrant_max_writers_reached(counter i64) bool {
	return (counter & reentrant_max_writers) == reentrant_max_writers
}

fn reentrant_read_holds(held i64) i64 {
	return held & reentrant_read_lock_mask
}

fn reentrant_write_holds(held i64) i64 {
	return (held & reentrant_write_lock_mask) >> reentrant_reader_bits
}

pub fn (mut rwlock ReentrantReadWriteLock) with_read_lock(action ReadWriteLockAction) !brew_runtime.Value {
	rwlock.acquire_read_lock()!
	defer {
		rwlock.release_read_lock() or {}
	}
	return action()!
}

pub fn (mut rwlock ReentrantReadWriteLock) with_write_lock(action ReadWriteLockAction) !brew_runtime.Value {
	rwlock.acquire_write_lock()!
	defer {
		rwlock.release_write_lock() or {}
	}
	return action()!
}

pub fn (mut rwlock ReentrantReadWriteLock) acquire_read_lock() !bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if held > 0 {
		if reentrant_read_holds(held) == reentrant_read_lock_mask {
			return error('Too many reader holds on this thread')
		}
		if reentrant_read_holds(held) == 0 {
			if reentrant_max_readers_reached(rwlock.state.counter) {
				return error('Too many reader threads')
			}
			rwlock.state.counter++
		}
		rwlock.state.holds[context_id] = held + 1
		return true
	}
	mut has_waited := false
	for {
		if reentrant_max_readers_reached(rwlock.state.counter) {
			return error('Too many reader threads')
		}
		if (!has_waited && reentrant_waiting_or_running_writer_present(rwlock.state.counter)) || (has_waited && reentrant_running_writer_present(rwlock.state.counter)) {
			rwlock.state.read_condition.wait()
			has_waited = true
			continue
		}
		rwlock.state.counter++
		rwlock.state.holds[context_id] = 1
		return true
	}
	return false
}

pub fn (mut rwlock ReentrantReadWriteLock) try_read_lock() !bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if held > 0 {
		if reentrant_read_holds(held) == reentrant_read_lock_mask {
			return error('Too many reader holds on this thread')
		}
		if reentrant_read_holds(held) == 0 {
			if reentrant_max_readers_reached(rwlock.state.counter) {
				return error('Too many reader threads')
			}
			rwlock.state.counter++
		}
		rwlock.state.holds[context_id] = held + 1
		return true
	}
	if reentrant_waiting_or_running_writer_present(rwlock.state.counter) {
		return false
	}
	if reentrant_max_readers_reached(rwlock.state.counter) {
		return error('Too many reader threads')
	}
	rwlock.state.counter++
	rwlock.state.holds[context_id] = 1
	return true
}

pub fn (mut rwlock ReentrantReadWriteLock) try_read_lock_for(timeout time.Duration) !bool {
	deadline := time.sys_mono_now() + u64(if timeout > 0 { timeout } else { 0 })
	for {
		if rwlock.try_read_lock()! {
			return true
		}
		sleep_for := lock_poll_duration(deadline)
		if sleep_for <= 0 {
			return false
		}
		time.sleep(sleep_for)
	}
	return false
}

pub fn (mut rwlock ReentrantReadWriteLock) release_read_lock() !bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if reentrant_read_holds(held) == 0 {
		return error('Cannot release a read lock which is not held')
	}
	new_held := held - 1
	if reentrant_read_holds(new_held) == 0 {
		rwlock.state.counter--
		if reentrant_waiting_or_running_writer_present(rwlock.state.counter) {
			rwlock.state.write_condition.signal()
		}
	}
	if new_held == 0 {
		rwlock.state.holds.delete(context_id)
	} else {
		rwlock.state.holds[context_id] = new_held
	}
	return true
}

pub fn (mut rwlock ReentrantReadWriteLock) acquire_write_lock() !bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if reentrant_write_holds(held) > 0 {
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	own_readers := if reentrant_read_holds(held) > 0 { i64(1) } else { i64(0) }
	if !reentrant_waiting_or_running_writer_present(rwlock.state.counter) && reentrant_running_readers(rwlock.state.counter) == own_readers {
		rwlock.state.counter += reentrant_running_writer
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	if reentrant_max_writers_reached(rwlock.state.counter) {
		return error('Too many writer threads')
	}
	rwlock.state.counter += reentrant_waiting_writer
	for reentrant_running_writer_present(rwlock.state.counter) || reentrant_running_readers(rwlock.state.counter) != own_readers {
		rwlock.state.write_condition.wait()
	}
	rwlock.state.counter += reentrant_running_writer - reentrant_waiting_writer
	rwlock.state.holds[context_id] = held + reentrant_write_lock_held
	return true
}

pub fn (mut rwlock ReentrantReadWriteLock) try_write_lock() bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if reentrant_write_holds(held) > 0 {
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	own_readers := if reentrant_read_holds(held) > 0 { i64(1) } else { i64(0) }
	if !reentrant_waiting_or_running_writer_present(rwlock.state.counter) && reentrant_running_readers(rwlock.state.counter) == own_readers {
		rwlock.state.counter += reentrant_running_writer
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	return false
}

pub fn (mut rwlock ReentrantReadWriteLock) try_write_lock_for(timeout time.Duration) !bool {
	context_id := sync.thread_id()
	deadline := time.sys_mono_now() + u64(if timeout > 0 { timeout } else { 0 })
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if reentrant_write_holds(held) > 0 {
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	own_readers := if reentrant_read_holds(held) > 0 { i64(1) } else { i64(0) }
	if !reentrant_waiting_or_running_writer_present(rwlock.state.counter) && reentrant_running_readers(rwlock.state.counter) == own_readers {
		rwlock.state.counter += reentrant_running_writer
		rwlock.state.holds[context_id] = held + reentrant_write_lock_held
		return true
	}
	if reentrant_max_writers_reached(rwlock.state.counter) {
		return error('Too many writer threads')
	}
	rwlock.state.counter += reentrant_waiting_writer
	for {
		if !reentrant_running_writer_present(rwlock.state.counter) && reentrant_running_readers(rwlock.state.counter) == own_readers {
			rwlock.state.counter += reentrant_running_writer - reentrant_waiting_writer
			rwlock.state.holds[context_id] = held + reentrant_write_lock_held
			return true
		}
		sleep_for := lock_poll_duration(deadline)
		if sleep_for <= 0 {
			rwlock.state.counter -= reentrant_waiting_writer
			if !reentrant_waiting_or_running_writer_present(rwlock.state.counter) {
				rwlock.state.read_condition.broadcast()
			}
			return false
		}
		rwlock.state.mutex.unlock()
		time.sleep(sleep_for)
		rwlock.state.mutex.lock()
	}
	return false
}

pub fn (mut rwlock ReentrantReadWriteLock) release_write_lock() !bool {
	context_id := sync.thread_id()
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	held := rwlock.state.holds[context_id]
	if reentrant_write_holds(held) == 0 {
		return error('Cannot release a write lock which is not held')
	}
	new_held := held - reentrant_write_lock_held
	if reentrant_write_holds(new_held) == 0 {
		rwlock.state.counter -= reentrant_running_writer
		rwlock.state.read_condition.broadcast()
		if reentrant_waiting_writers(rwlock.state.counter) > 0 {
			rwlock.state.write_condition.signal()
		}
	}
	if new_held == 0 {
		rwlock.state.holds.delete(context_id)
	} else {
		rwlock.state.holds[context_id] = new_held
	}
	return true
}

pub fn (mut rwlock ReentrantReadWriteLock) counter_value() i64 {
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	return rwlock.state.counter
}

pub fn (mut rwlock ReentrantReadWriteLock) held_count() i64 {
	rwlock.state.mutex.lock()
	defer {
		rwlock.state.mutex.unlock()
	}
	return rwlock.state.holds[sync.thread_id()]
}

fn reentrant_read_write_lock_boundary(rwlock &ReentrantReadWriteLock) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::ReentrantReadWriteLock', '#<Concurrent::ReentrantReadWriteLock>', {
		'reentrant_read_write_lock_address': u64(voidptr(rwlock)).str()
	})
}

fn reentrant_read_write_lock_boundary_receiver(args []brew_runtime.Value) &ReentrantReadWriteLock {
	if args.len == 0 {
		panic('ReentrantReadWriteLock method requires a receiver')
	}
	address := (args[0].attribute('reentrant_read_write_lock_address') or {
		panic('${args[0].type_name} has no translated reentrant-read-write-lock state')
	}).u64()
	return unsafe { &ReentrantReadWriteLock(voidptr(address)) }
}

fn reentrant_boundary_counter(mut rwlock ReentrantReadWriteLock, args []brew_runtime.Value) i64 {
	return if args.len > 1 { args[1].as_int() or { panic(err) } } else { rwlock.counter_value() }
}

// Ruby method `initialize` at line 109.
pub fn ruby_reentrant_read_write_lock_l109_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return reentrant_read_write_lock_boundary(new_reentrant_read_write_lock())
}

// Ruby method `with_read_lock` at line 126.
pub fn ruby_reentrant_read_write_lock_l126_d2_with_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('no block given')
	}
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	rwlock.acquire_read_lock() or { panic(err) }
	defer {
		rwlock.release_read_lock() or {}
	}
	return args[1]
}

// Ruby method `with_write_lock` at line 145.
pub fn ruby_reentrant_read_write_lock_l145_d3_with_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('no block given')
	}
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	rwlock.acquire_write_lock() or { panic(err) }
	defer {
		rwlock.release_write_lock() or {}
	}
	return args[1]
}

// Ruby method `acquire_read_lock` at line 162.
pub fn ruby_reentrant_read_write_lock_l162_d4_acquire_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.acquire_read_lock() or { panic(err) })
}

// Ruby method `try_read_lock` at line 220.
pub fn ruby_reentrant_read_write_lock_l220_d5_try_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.try_read_lock() or { panic(err) })
}

// Ruby method `release_read_lock` at line 243.
pub fn ruby_reentrant_read_write_lock_l243_d6_release_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.release_read_lock() or { panic(err) })
}

// Ruby method `acquire_write_lock` at line 264.
pub fn ruby_reentrant_read_write_lock_l264_d7_acquire_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.acquire_write_lock() or { panic(err) })
}

// Ruby method `try_write_lock` at line 317.
pub fn ruby_reentrant_read_write_lock_l317_d8_try_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.try_write_lock())
}

// Ruby method `release_write_lock` at line 336.
pub fn ruby_reentrant_read_write_lock_l336_d9_release_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(rwlock.release_write_lock() or { panic(err) })
}

// Ruby method `running_readers(c = @Counter.value)` at line 352.
pub fn ruby_reentrant_read_write_lock_l352_d10_running_readers(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.int_value(reentrant_running_readers(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `running_readers?(c = @Counter.value)` at line 357.
pub fn ruby_reentrant_read_write_lock_l357_d11_running_readers(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(reentrant_running_readers_present(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `running_writer?(c = @Counter.value)` at line 362.
pub fn ruby_reentrant_read_write_lock_l362_d12_running_writer(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(reentrant_running_writer_present(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `waiting_writers(c = @Counter.value)` at line 367.
pub fn ruby_reentrant_read_write_lock_l367_d13_waiting_writers(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.int_value(reentrant_waiting_writers(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `waiting_or_running_writer?(c = @Counter.value)` at line 372.
pub fn ruby_reentrant_read_write_lock_l372_d14_waiting_or_running_writer(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(reentrant_waiting_or_running_writer_present(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `max_readers?(c = @Counter.value)` at line 377.
pub fn ruby_reentrant_read_write_lock_l377_d15_max_readers(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(reentrant_max_readers_reached(reentrant_boundary_counter(mut rwlock, args)))
}

// Ruby method `max_writers?(c = @Counter.value)` at line 382.
pub fn ruby_reentrant_read_write_lock_l382_d16_max_writers(args ...brew_runtime.Value) brew_runtime.Value {
	mut rwlock := reentrant_read_write_lock_boundary_receiver(args)
	return brew_runtime.bool_value(reentrant_max_writers_reached(reentrant_boundary_counter(mut rwlock, args)))
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/atomic/atomic_reference'
// 3: require 'concurrent/atomic/atomic_fixnum'
// 4: require 'concurrent/errors'
// 5: require 'concurrent/synchronization/object'
// 6: require 'concurrent/synchronization/lock'
// 7: require 'concurrent/atomic/lock_local_var'
// 8:
// 9: module Concurrent
// 10:
// 11:   # Re-entrant read-write lock implementation
// 12:   #
// 13:   # Allows any number of concurrent readers, but only one concurrent writer
// 14:   # (And while the "write" lock is taken, no read locks can be obtained either.
// 15:   # Hence, the write lock can also be called an "exclusive" lock.)
// 16:   #
// 17:   # If another thread has taken a read lock, any thread which wants a write lock
// 18:   # will block until all the readers release their locks. However, once a thread
// 19:   # starts waiting to obtain a write lock, any additional readers that come along
// 20:   # will also wait (so writers are not starved).
// 21:   #
// 22:   # A thread can acquire both a read and write lock at the same time. A thread can
// 23:   # also acquire a read lock OR a write lock more than once. Only when the read (or
// 24:   # write) lock is released as many times as it was acquired, will the thread
// 25:   # actually let it go, allowing other threads which might have been waiting
// 26:   # to proceed. Therefore the lock can be upgraded by first acquiring
// 27:   # read lock and then write lock and that the lock can be downgraded by first
// 28:   # having both read and write lock a releasing just the write lock.
// 29:   #
// 30:   # If both read and write locks are acquired by the same thread, it is not strictly
// 31:   # necessary to release them in the same order they were acquired. In other words,
// 32:   # the following code is legal:
// 33:   #
// 34:   # @example
// 35:   #   lock = Concurrent::ReentrantReadWriteLock.new
// 36:   #   lock.acquire_write_lock
// 37:   #   lock.acquire_read_lock
// 38:   #   lock.release_write_lock
// 39:   #   # At this point, the current thread is holding only a read lock, not a write
// 40:   #   # lock. So other threads can take read locks, but not a write lock.
// 41:   #   lock.release_read_lock
// 42:   #   # Now the current thread is not holding either a read or write lock, so
// 43:   #   # another thread could potentially acquire a write lock.
// 44:   #
// 45:   # This implementation was inspired by `java.util.concurrent.ReentrantReadWriteLock`.
// 46:   #
// 47:   # @example
// 48:   #   lock = Concurrent::ReentrantReadWriteLock.new
// 49:   #   lock.with_read_lock  { data.retrieve }
// 50:   #   lock.with_write_lock { data.modify! }
// 51:   #
// 52:   # @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/locks/ReentrantReadWriteLock.html java.util.concurrent.ReentrantReadWriteLock
// 53:   class ReentrantReadWriteLock < Synchronization::Object
// 54:
// 55:     # Implementation notes:
// 56:     #
// 57:     # A goal is to make the uncontended path for both readers/writers mutex-free
// 58:     # Only if there is reader-writer or writer-writer contention, should mutexes be used
// 59:     # Otherwise, a single CAS operation is all we need to acquire/release a lock
// 60:     #
// 61:     # Internal state is represented by a single integer ("counter"), and updated
// 62:     #   using atomic compare-and-swap operations
// 63:     # When the counter is 0, the lock is free
// 64:     # Each thread which has one OR MORE read locks increments the counter by 1
// 65:     #   (and decrements by 1 when releasing the read lock)
// 66:     # The counter is increased by (1 << 15) for each writer waiting to acquire the
// 67:     #   write lock, and by (1 << 29) if the write lock is taken
// 68:     #
// 69:     # Additionally, each thread uses a thread-local variable to count how many times
// 70:     #   it has acquired a read lock, AND how many times it has acquired a write lock.
// 71:     # It uses a similar trick; an increment of 1 means a read lock was taken, and
// 72:     #   an increment of (1 << 15) means a write lock was taken
// 73:     # This is what makes re-entrancy possible
// 74:     #
// 75:     # 2 rules are followed to ensure good liveness properties:
// 76:     # 1) Once a writer has queued up and is waiting for a write lock, no other thread
// 77:     #    can take a lock without waiting
// 78:     # 2) When a write lock is released, readers are given the "first chance" to wake
// 79:     #    up and acquire a read lock
// 80:     # Following these rules means readers and writers tend to "take turns", so neither
// 81:     #   can starve the other, even under heavy contention
// 82:
// 83:     # @!visibility private
// 84:     READER_BITS    = 15
// 85:     # @!visibility private
// 86:     WRITER_BITS    = 14
// 87:
// 88:     # Used with @Counter:
// 89:     # @!visibility private
// 90:     WAITING_WRITER = 1 << READER_BITS
// 91:     # @!visibility private
// 92:     RUNNING_WRITER = 1 << (READER_BITS + WRITER_BITS)
// 93:     # @!visibility private
// 94:     MAX_READERS    = WAITING_WRITER - 1
// 95:     # @!visibility private
// 96:     MAX_WRITERS    = RUNNING_WRITER - MAX_READERS - 1
// 97:
// 98:     # Used with @HeldCount:
// 99:     # @!visibility private
// 100:     WRITE_LOCK_HELD = 1 << READER_BITS
// 101:     # @!visibility private
// 102:     READ_LOCK_MASK  = WRITE_LOCK_HELD - 1
// 103:     # @!visibility private
// 104:     WRITE_LOCK_MASK = MAX_WRITERS
// 105:
// 106:     safe_initialization!
// 107:
// 108:     # Create a new `ReentrantReadWriteLock` in the unlocked state.
// 109:     def initialize
// 110:       super()
// 111:       @Counter    = AtomicFixnum.new(0)       # single integer which represents lock state
// 112:       @ReadQueue  = Synchronization::Lock.new # used to queue waiting readers
// 113:       @WriteQueue = Synchronization::Lock.new # used to queue waiting writers
// 114:       @HeldCount  = LockLocalVar.new(0) # indicates # of R & W locks held by this thread
// 115:     end
// 116:
// 117:     # Execute a block operation within a read lock.
// 118:     #
// 119:     # @yield the task to be performed within the lock.
// 120:     #
// 121:     # @return [Object] the result of the block operation.
// 122:     #
// 123:     # @raise [ArgumentError] when no block is given.
// 124:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 125:     #   is exceeded.
// 126:     def with_read_lock
// 127:       raise ArgumentError.new('no block given') unless block_given?
// 128:       acquire_read_lock
// 129:       begin
// 130:         yield
// 131:       ensure
// 132:         release_read_lock
// 133:       end
// 134:     end
// 135:
// 136:     # Execute a block operation within a write lock.
// 137:     #
// 138:     # @yield the task to be performed within the lock.
// 139:     #
// 140:     # @return [Object] the result of the block operation.
// 141:     #
// 142:     # @raise [ArgumentError] when no block is given.
// 143:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 144:     #   is exceeded.
// 145:     def with_write_lock
// 146:       raise ArgumentError.new('no block given') unless block_given?
// 147:       acquire_write_lock
// 148:       begin
// 149:         yield
// 150:       ensure
// 151:         release_write_lock
// 152:       end
// 153:     end
// 154:
// 155:     # Acquire a read lock. If a write lock is held by another thread, will block
// 156:     # until it is released.
// 157:     #
// 158:     # @return [Boolean] true if the lock is successfully acquired
// 159:     #
// 160:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 161:     #   or per-thread reentrant acquires is exceeded.
// 162:     def acquire_read_lock
// 163:       if (held = @HeldCount.value) > 0
// 164:         raise ResourceLimitError.new('Too many reader holds on this thread') if (held & READ_LOCK_MASK) == READ_LOCK_MASK
// 165:
// 166:         # If we already have a lock, there's no need to wait
// 167:         if held & READ_LOCK_MASK == 0
// 168:           # But we do need to update the counter, if we were holding a write
// 169:           #   lock but not a read lock
// 170:           @Counter.update { |c| c + 1 }
// 171:         end
// 172:         @HeldCount.value = held + 1
// 173:         return true
// 174:       end
// 175:
// 176:       while true
// 177:         c = @Counter.value
// 178:         raise ResourceLimitError.new('Too many reader threads') if max_readers?(c)
// 179:
// 180:         # If a writer is waiting OR running when we first queue up, we need to wait
// 181:         if waiting_or_running_writer?(c)
// 182:           # Before going to sleep, check again with the ReadQueue mutex held
// 183:           @ReadQueue.synchronize do
// 184:             @ReadQueue.ns_wait if waiting_or_running_writer?
// 185:           end
// 186:           # Note: the above 'synchronize' block could have used #wait_until,
// 187:           #   but that waits repeatedly in a loop, checking the wait condition
// 188:           #   each time it wakes up (to protect against spurious wakeups)
// 189:           # But we are already in a loop, which is only broken when we successfully
// 190:           #   acquire the lock! So we don't care about spurious wakeups, and would
// 191:           #   rather not pay the extra overhead of using #wait_until
// 192:
// 193:           # After a reader has waited once, they are allowed to "barge" ahead of waiting writers
// 194:           # But if a writer is *running*, the reader still needs to wait (naturally)
// 195:           while true
// 196:             c = @Counter.value
// 197:             if running_writer?(c)
// 198:               @ReadQueue.synchronize do
// 199:                 @ReadQueue.ns_wait if running_writer?
// 200:               end
// 201:             elsif @Counter.compare_and_set(c, c+1)
// 202:               @HeldCount.value = held + 1
// 203:               return true
// 204:             end
// 205:           end
// 206:         elsif @Counter.compare_and_set(c, c+1)
// 207:           @HeldCount.value = held + 1
// 208:           return true
// 209:         end
// 210:       end
// 211:     end
// 212:
// 213:     # Try to acquire a read lock and return true if we succeed. If it cannot be
// 214:     # acquired immediately, return false.
// 215:     #
// 216:     # @return [Boolean] true if the lock is successfully acquired
// 217:     #
// 218:     # @raise [Concurrent::ResourceLimitError] if the maximum number of per-thread
// 219:     #   reentrant acquires is exceeded.
// 220:     def try_read_lock
// 221:       if (held = @HeldCount.value) > 0
// 222:         raise ResourceLimitError.new('Too many reader holds on this thread') if (held & READ_LOCK_MASK) == READ_LOCK_MASK
// 223:
// 224:         if held & READ_LOCK_MASK == 0
// 225:           # If we hold a write lock, but not a read lock...
// 226:           @Counter.update { |c| c + 1 }
// 227:         end
// 228:         @HeldCount.value = held + 1
// 229:         return true
// 230:       else
// 231:         c = @Counter.value
// 232:         if !waiting_or_running_writer?(c) && @Counter.compare_and_set(c, c+1)
// 233:           @HeldCount.value = held + 1
// 234:           return true
// 235:         end
// 236:       end
// 237:       false
// 238:     end
// 239:
// 240:     # Release a previously acquired read lock.
// 241:     #
// 242:     # @return [Boolean] true if the lock is successfully released
// 243:     def release_read_lock
// 244:       held = @HeldCount.value = @HeldCount.value - 1
// 245:       rlocks_held = held & READ_LOCK_MASK
// 246:       if rlocks_held == 0
// 247:         c = @Counter.update { |counter| counter - 1 }
// 248:         # If one or more writers were waiting, and we were the last reader, wake a writer up
// 249:         if waiting_or_running_writer?(c) && running_readers(c) == 0
// 250:           @WriteQueue.signal
// 251:         end
// 252:       elsif rlocks_held == READ_LOCK_MASK
// 253:         raise IllegalOperationError, "Cannot release a read lock which is not held"
// 254:       end
// 255:       true
// 256:     end
// 257:
// 258:     # Acquire a write lock. Will block and wait for all active readers and writers.
// 259:     #
// 260:     # @return [Boolean] true if the lock is successfully acquired
// 261:     #
// 262:     # @raise [Concurrent::ResourceLimitError] if the maximum number of writers
// 263:     #   is exceeded.
// 264:     def acquire_write_lock
// 265:       if (held = @HeldCount.value) >= WRITE_LOCK_HELD
// 266:         # if we already have a write (exclusive) lock, there's no need to wait
// 267:         @HeldCount.value = held + WRITE_LOCK_HELD
// 268:         return true
// 269:       end
// 270:
// 271:       while true
// 272:         c = @Counter.value
// 273:         raise ResourceLimitError.new('Too many writer threads') if max_writers?(c)
// 274:
// 275:         # To go ahead and take the lock without waiting, there must be no writer
// 276:         #   running right now, AND no writers who came before us still waiting to
// 277:         #   acquire the lock
// 278:         # Additionally, if any read locks have been taken, we must hold all of them
// 279:         if held > 0 && @Counter.compare_and_set(1, c+RUNNING_WRITER)
// 280:           # If we are the only one reader and successfully swap the RUNNING_WRITER bit on, then we can go ahead
// 281:           @HeldCount.value = held + WRITE_LOCK_HELD
// 282:           return true
// 283:         elsif @Counter.compare_and_set(c, c+WAITING_WRITER)
// 284:           while true
// 285:             # Now we have successfully incremented, so no more readers will be able to increment
// 286:             #   (they will wait instead)
// 287:             # However, readers OR writers could decrement right here
// 288:             @WriteQueue.synchronize do
// 289:               # So we have to do another check inside the synchronized section
// 290:               # If a writer OR another reader is running, then go to sleep
// 291:               c = @Counter.value
// 292:               @WriteQueue.ns_wait if running_writer?(c) || running_readers(c) != held
// 293:             end
// 294:             # Note: if you are thinking of replacing the above 'synchronize' block
// 295:             # with #wait_until, read the comment in #acquire_read_lock first!
// 296:
// 297:             # We just came out of a wait
// 298:             # If we successfully turn the RUNNING_WRITER bit on with an atomic swap,
// 299:             #   then we are OK to stop waiting and go ahead
// 300:             # Otherwise go back and wait again
// 301:             c = @Counter.value
// 302:             if !running_writer?(c) &&
// 303:                running_readers(c) == held &&
// 304:                @Counter.compare_and_set(c, c+RUNNING_WRITER-WAITING_WRITER)
// 305:               @HeldCount.value = held + WRITE_LOCK_HELD
// 306:               return true
// 307:             end
// 308:           end
// 309:         end
// 310:       end
// 311:     end
// 312:
// 313:     # Try to acquire a write lock and return true if we succeed. If it cannot be
// 314:     # acquired immediately, return false.
// 315:     #
// 316:     # @return [Boolean] true if the lock is successfully acquired
// 317:     def try_write_lock
// 318:       if (held = @HeldCount.value) >= WRITE_LOCK_HELD
// 319:         @HeldCount.value = held + WRITE_LOCK_HELD
// 320:         return true
// 321:       else
// 322:         c = @Counter.value
// 323:         if !waiting_or_running_writer?(c) &&
// 324:            running_readers(c) == held &&
// 325:            @Counter.compare_and_set(c, c+RUNNING_WRITER)
// 326:            @HeldCount.value = held + WRITE_LOCK_HELD
// 327:           return true
// 328:         end
// 329:       end
// 330:       false
// 331:     end
// 332:
// 333:     # Release a previously acquired write lock.
// 334:     #
// 335:     # @return [Boolean] true if the lock is successfully released
// 336:     def release_write_lock
// 337:       held = @HeldCount.value = @HeldCount.value - WRITE_LOCK_HELD
// 338:       wlocks_held = held & WRITE_LOCK_MASK
// 339:       if wlocks_held == 0
// 340:         c = @Counter.update { |counter| counter - RUNNING_WRITER }
// 341:         @ReadQueue.broadcast
// 342:         @WriteQueue.signal if waiting_writers(c) > 0
// 343:       elsif wlocks_held == WRITE_LOCK_MASK
// 344:         raise IllegalOperationError, "Cannot release a write lock which is not held"
// 345:       end
// 346:       true
// 347:     end
// 348:
// 349:     private
// 350:
// 351:     # @!visibility private
// 352:     def running_readers(c = @Counter.value)
// 353:       c & MAX_READERS
// 354:     end
// 355:
// 356:     # @!visibility private
// 357:     def running_readers?(c = @Counter.value)
// 358:       (c & MAX_READERS) > 0
// 359:     end
// 360:
// 361:     # @!visibility private
// 362:     def running_writer?(c = @Counter.value)
// 363:       c >= RUNNING_WRITER
// 364:     end
// 365:
// 366:     # @!visibility private
// 367:     def waiting_writers(c = @Counter.value)
// 368:       (c & MAX_WRITERS) >> READER_BITS
// 369:     end
// 370:
// 371:     # @!visibility private
// 372:     def waiting_or_running_writer?(c = @Counter.value)
// 373:       c >= WAITING_WRITER
// 374:     end
// 375:
// 376:     # @!visibility private
// 377:     def max_readers?(c = @Counter.value)
// 378:       (c & MAX_READERS) == MAX_READERS
// 379:     end
// 380:
// 381:     # @!visibility private
// 382:     def max_writers?(c = @Counter.value)
// 383:       (c & MAX_WRITERS) == MAX_WRITERS
// 384:     end
// 385:   end
// 386: end
