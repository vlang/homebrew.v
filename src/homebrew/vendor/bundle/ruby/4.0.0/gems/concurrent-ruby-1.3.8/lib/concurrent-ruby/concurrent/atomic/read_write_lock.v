module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/read_write_lock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 60.
pub fn ruby_read_write_lock_l60_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `with_read_lock` at line 77.
pub fn ruby_read_write_lock_l77_d2_with_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_read_lock', ...args)
}

// Ruby method `with_write_lock` at line 96.
pub fn ruby_read_write_lock_l96_d3_with_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_write_lock', ...args)
}

// Ruby method `acquire_read_lock` at line 113.
pub fn ruby_read_write_lock_l113_d4_acquire_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('acquire_read_lock', ...args)
}

// Ruby method `release_read_lock` at line 144.
pub fn ruby_read_write_lock_l144_d5_release_read_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('release_read_lock', ...args)
}

// Ruby method `acquire_write_lock` at line 166.
pub fn ruby_read_write_lock_l166_d6_acquire_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('acquire_write_lock', ...args)
}

// Ruby method `release_write_lock` at line 206.
pub fn ruby_read_write_lock_l206_d7_release_write_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('release_write_lock', ...args)
}

// Ruby method `write_locked?` at line 220.
pub fn ruby_read_write_lock_l220_d8_write_locked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_locked?', ...args)
}

// Ruby method `has_waiters?` at line 227.
pub fn ruby_read_write_lock_l227_d9_has_waiters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has_waiters?', ...args)
}

// Ruby method `running_readers(c = @Counter.value)` at line 234.
pub fn ruby_read_write_lock_l234_d10_running_readers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('running_readers', ...args)
}

// Ruby method `running_readers?(c = @Counter.value)` at line 239.
pub fn ruby_read_write_lock_l239_d11_running_readers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('running_readers?', ...args)
}

// Ruby method `running_writer?(c = @Counter.value)` at line 244.
pub fn ruby_read_write_lock_l244_d12_running_writer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('running_writer?', ...args)
}

// Ruby method `waiting_writers(c = @Counter.value)` at line 249.
pub fn ruby_read_write_lock_l249_d13_waiting_writers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('waiting_writers', ...args)
}

// Ruby method `waiting_writer?(c = @Counter.value)` at line 254.
pub fn ruby_read_write_lock_l254_d14_waiting_writer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('waiting_writer?', ...args)
}

// Ruby method `max_readers?(c = @Counter.value)` at line 259.
pub fn ruby_read_write_lock_l259_d15_max_readers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_readers?', ...args)
}

// Ruby method `max_writers?(c = @Counter.value)` at line 264.
pub fn ruby_read_write_lock_l264_d16_max_writers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_writers?', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/atomic/atomic_fixnum'
// 3: require 'concurrent/atomic/atomic_reference'
// 4: require 'concurrent/errors'
// 5: require 'concurrent/synchronization/object'
// 6: require 'concurrent/synchronization/lock'
// 7:
// 8: module Concurrent
// 9:
// 10:   # Ruby read-write lock implementation
// 11:   #
// 12:   # Allows any number of concurrent readers, but only one concurrent writer
// 13:   # (And if the "write" lock is taken, any readers who come along will have to wait)
// 14:   #
// 15:   # If readers are already active when a writer comes along, the writer will wait for
// 16:   # all the readers to finish before going ahead.
// 17:   # Any additional readers that come when the writer is already waiting, will also
// 18:   # wait (so writers are not starved).
// 19:   #
// 20:   # This implementation is based on `java.util.concurrent.ReentrantReadWriteLock`.
// 21:   #
// 22:   # @example
// 23:   #   lock = Concurrent::ReadWriteLock.new
// 24:   #   lock.with_read_lock  { data.retrieve }
// 25:   #   lock.with_write_lock { data.modify! }
// 26:   #
// 27:   # @note Do **not** try to acquire the write lock while already holding a read lock
// 28:   #   **or** try to acquire the write lock while you already have it.
// 29:   #   This will lead to deadlock
// 30:   #
// 31:   # @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/locks/ReentrantReadWriteLock.html java.util.concurrent.ReentrantReadWriteLock
// 32:   class ReadWriteLock < Synchronization::Object
// 33:
// 34:     # @!visibility private
// 35:     WAITING_WRITER = 1 << 15
// 36:
// 37:     # @!visibility private
// 38:     RUNNING_WRITER = 1 << 29
// 39:
// 40:     # @!visibility private
// 41:     MAX_READERS    = WAITING_WRITER - 1
// 42:
// 43:     # @!visibility private
// 44:     MAX_WRITERS    = RUNNING_WRITER - MAX_READERS - 1
// 45:
// 46:     safe_initialization!
// 47:
// 48:     # Implementation notes:
// 49:     # A goal is to make the uncontended path for both readers/writers lock-free
// 50:     # Only if there is reader-writer or writer-writer contention, should locks be used
// 51:     # Internal state is represented by a single integer ("counter"), and updated
// 52:     #  using atomic compare-and-swap operations
// 53:     # When the counter is 0, the lock is free
// 54:     # Each reader increments the counter by 1 when acquiring a read lock
// 55:     #   (and decrements by 1 when releasing the read lock)
// 56:     # The counter is increased by (1 << 15) for each writer waiting to acquire the
// 57:     #   write lock, and by (1 << 29) if the write lock is taken
// 58:
// 59:     # Create a new `ReadWriteLock` in the unlocked state.
// 60:     def initialize
// 61:       super()
// 62:       @Counter   = AtomicFixnum.new(0)      # single integer which represents lock state
// 63:       @Writer    = AtomicReference.new(nil) # the thread currently holding the write lock
// 64:       @ReadLock  = Synchronization::Lock.new
// 65:       @WriteLock = Synchronization::Lock.new
// 66:     end
// 67:
// 68:     # Execute a block operation within a read lock.
// 69:     #
// 70:     # @yield the task to be performed within the lock.
// 71:     #
// 72:     # @return [Object] the result of the block operation.
// 73:     #
// 74:     # @raise [ArgumentError] when no block is given.
// 75:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 76:     #   is exceeded.
// 77:     def with_read_lock
// 78:       raise ArgumentError.new('no block given') unless block_given?
// 79:       acquire_read_lock
// 80:       begin
// 81:         yield
// 82:       ensure
// 83:         release_read_lock
// 84:       end
// 85:     end
// 86:
// 87:     # Execute a block operation within a write lock.
// 88:     #
// 89:     # @yield the task to be performed within the lock.
// 90:     #
// 91:     # @return [Object] the result of the block operation.
// 92:     #
// 93:     # @raise [ArgumentError] when no block is given.
// 94:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 95:     #   is exceeded.
// 96:     def with_write_lock
// 97:       raise ArgumentError.new('no block given') unless block_given?
// 98:       acquire_write_lock
// 99:       begin
// 100:         yield
// 101:       ensure
// 102:         release_write_lock
// 103:       end
// 104:     end
// 105:
// 106:     # Acquire a read lock. If a write lock has been acquired will block until
// 107:     # it is released. Will not block if other read locks have been acquired.
// 108:     #
// 109:     # @return [Boolean] true if the lock is successfully acquired
// 110:     #
// 111:     # @raise [Concurrent::ResourceLimitError] if the maximum number of readers
// 112:     #   is exceeded.
// 113:     def acquire_read_lock
// 114:       while true
// 115:         c = @Counter.value
// 116:         raise ResourceLimitError.new('Too many reader threads') if max_readers?(c)
// 117:
// 118:         # If a writer is waiting when we first queue up, we need to wait
// 119:         if waiting_writer?(c)
// 120:           @ReadLock.wait_until { !waiting_writer? }
// 121:
// 122:           # after a reader has waited once, they are allowed to "barge" ahead of waiting writers
// 123:           # but if a writer is *running*, the reader still needs to wait (naturally)
// 124:           while true
// 125:             c = @Counter.value
// 126:             if running_writer?(c)
// 127:               @ReadLock.wait_until { !running_writer? }
// 128:             else
// 129:               return if @Counter.compare_and_set(c, c+1)
// 130:             end
// 131:           end
// 132:         else
// 133:           break if @Counter.compare_and_set(c, c+1)
// 134:         end
// 135:       end
// 136:       true
// 137:     end
// 138:
// 139:     # Release a previously acquired read lock.
// 140:     #
// 141:     # @return [Boolean] true if the lock is successfully released
// 142:     #
// 143:     # @raise [Concurrent::IllegalOperationError] if no read lock is currently held.
// 144:     def release_read_lock
// 145:       while true
// 146:         c = @Counter.value
// 147:         raise IllegalOperationError, 'Cannot release a read lock which is not held' if running_readers(c) == 0
// 148:
// 149:         if @Counter.compare_and_set(c, c-1)
// 150:           # If one or more writers were waiting, and we were the last reader, wake a writer up
// 151:           if waiting_writer?(c) && running_readers(c) == 1
// 152:             @WriteLock.signal
// 153:           end
// 154:           break
// 155:         end
// 156:       end
// 157:       true
// 158:     end
// 159:
// 160:     # Acquire a write lock. Will block and wait for all active readers and writers.
// 161:     #
// 162:     # @return [Boolean] true if the lock is successfully acquired
// 163:     #
// 164:     # @raise [Concurrent::ResourceLimitError] if the maximum number of writers
// 165:     #   is exceeded.
// 166:     def acquire_write_lock
// 167:       while true
// 168:         c = @Counter.value
// 169:         raise ResourceLimitError.new('Too many writer threads') if max_writers?(c)
// 170:
// 171:         if c == 0 # no readers OR writers running
// 172:           # if we successfully swap the RUNNING_WRITER bit on, then we can go ahead
// 173:           break if @Counter.compare_and_set(0, RUNNING_WRITER)
// 174:         elsif @Counter.compare_and_set(c, c+WAITING_WRITER)
// 175:           while true
// 176:             # Now we have successfully incremented, so no more readers will be able to increment
// 177:             #   (they will wait instead)
// 178:             # However, readers OR writers could decrement right here, OR another writer could increment
// 179:             @WriteLock.wait_until do
// 180:               # So we have to do another check inside the synchronized section
// 181:               # If a writer OR reader is running, then go to sleep
// 182:               c = @Counter.value
// 183:               !running_writer?(c) && !running_readers?(c)
// 184:             end
// 185:
// 186:             # We just came out of a wait
// 187:             # If we successfully turn the RUNNING_WRITER bit on with an atomic swap,
// 188:             # Then we are OK to stop waiting and go ahead
// 189:             # Otherwise go back and wait again
// 190:             c = @Counter.value
// 191:             break if !running_writer?(c) && !running_readers?(c) && @Counter.compare_and_set(c, c+RUNNING_WRITER-WAITING_WRITER)
// 192:           end
// 193:           break
// 194:         end
// 195:       end
// 196:       @Writer.set(Thread.current)
// 197:       true
// 198:     end
// 199:
// 200:     # Release a previously acquired write lock.
// 201:     #
// 202:     # @return [Boolean] true if the lock is successfully released
// 203:     #
// 204:     # @raise [Concurrent::IllegalOperationError] if the write lock is not held
// 205:     #   by the current thread.
// 206:     def release_write_lock
// 207:       unless @Writer.compare_and_set(Thread.current, nil)
// 208:         raise IllegalOperationError, 'Cannot release a write lock which is not held by the current thread'
// 209:       end
// 210:
// 211:       c = @Counter.update { |counter| counter - RUNNING_WRITER }
// 212:       @ReadLock.broadcast
// 213:       @WriteLock.signal if waiting_writers(c) > 0
// 214:       true
// 215:     end
// 216:
// 217:     # Queries if the write lock is held by any thread.
// 218:     #
// 219:     # @return [Boolean] true if the write lock is held else false`
// 220:     def write_locked?
// 221:       @Counter.value >= RUNNING_WRITER
// 222:     end
// 223:
// 224:     # Queries whether any threads are waiting to acquire the read or write lock.
// 225:     #
// 226:     # @return [Boolean] true if any threads are waiting for a lock else false
// 227:     def has_waiters?
// 228:       waiting_writer?(@Counter.value)
// 229:     end
// 230:
// 231:     private
// 232:
// 233:     # @!visibility private
// 234:     def running_readers(c = @Counter.value)
// 235:       c & MAX_READERS
// 236:     end
// 237:
// 238:     # @!visibility private
// 239:     def running_readers?(c = @Counter.value)
// 240:       (c & MAX_READERS) > 0
// 241:     end
// 242:
// 243:     # @!visibility private
// 244:     def running_writer?(c = @Counter.value)
// 245:       c >= RUNNING_WRITER
// 246:     end
// 247:
// 248:     # @!visibility private
// 249:     def waiting_writers(c = @Counter.value)
// 250:       (c & MAX_WRITERS) / WAITING_WRITER
// 251:     end
// 252:
// 253:     # @!visibility private
// 254:     def waiting_writer?(c = @Counter.value)
// 255:       c >= WAITING_WRITER
// 256:     end
// 257:
// 258:     # @!visibility private
// 259:     def max_readers?(c = @Counter.value)
// 260:       (c & MAX_READERS) == MAX_READERS
// 261:     end
// 262:
// 263:     # @!visibility private
// 264:     def max_writers?(c = @Counter.value)
// 265:       (c & MAX_WRITERS) == MAX_WRITERS
// 266:     end
// 267:   end
// 268: end
