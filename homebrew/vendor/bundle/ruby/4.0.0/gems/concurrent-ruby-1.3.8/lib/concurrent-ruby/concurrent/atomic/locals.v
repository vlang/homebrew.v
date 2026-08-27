module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/locals.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 36.
pub fn ruby_locals_l36_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `synchronize` at line 43.
pub fn ruby_locals_l43_d2_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synchronize', ...args)
}

// Ruby method `weak_synchronize` at line 48.
pub fn ruby_locals_l48_d3_weak_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('weak_synchronize', ...args)
}

// Ruby alias_method `alias_method :weak_synchronize, :synchronize` at line 52.
pub fn ruby_locals_l52_d4_weak_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('weak_synchronize', ...args)
}

// Ruby method `next_index(local)` at line 55.
pub fn ruby_locals_l55_d5_next_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('next_index', ...args)
}

// Ruby method `free_index(index)` at line 71.
pub fn ruby_locals_l71_d6_free_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('free_index', ...args)
}

// Ruby method `fetch(index)` at line 89.
pub fn ruby_locals_l89_d7_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch', ...args)
}

// Ruby method `set(index, value)` at line 102.
pub fn ruby_locals_l102_d8_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `local_finalizer(index)` at line 112.
pub fn ruby_locals_l112_d9_local_finalizer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_finalizer', ...args)
}

// Ruby method `thread_fiber_finalizer(array_object_id)` at line 119.
pub fn ruby_locals_l119_d10_thread_fiber_finalizer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('thread_fiber_finalizer', ...args)
}

// Ruby method `locals` at line 128.
pub fn ruby_locals_l128_d11_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals', ...args)
}

// Ruby method `locals!` at line 133.
pub fn ruby_locals_l133_d12_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals!', ...args)
}

// Ruby method `locals` at line 142.
pub fn ruby_locals_l142_d13_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals', ...args)
}

// Ruby method `locals!` at line 146.
pub fn ruby_locals_l146_d14_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals!', ...args)
}

// Ruby method `locals` at line 167.
pub fn ruby_locals_l167_d15_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals', ...args)
}

// Ruby method `locals!` at line 171.
pub fn ruby_locals_l171_d16_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locals!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'fiber'
// 2: require 'concurrent/utility/engine'
// 3: require 'concurrent/constants'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   # @!macro internal_implementation_note
// 8:   #
// 9:   # An abstract implementation of local storage, with sub-classes for
// 10:   # per-thread and per-fiber locals.
// 11:   #
// 12:   # Each execution context (EC, thread or fiber) has a lazily initialized array
// 13:   # of local variable values. Each time a new local variable is created, we
// 14:   # allocate an "index" for it.
// 15:   #
// 16:   # For example, if the allocated index is 1, that means slot #1 in EVERY EC's
// 17:   # locals array will be used for the value of that variable.
// 18:   #
// 19:   # The good thing about using a per-EC structure to hold values, rather than
// 20:   # a global, is that no synchronization is needed when reading and writing
// 21:   # those values (since the structure is only ever accessed by a single
// 22:   # thread).
// 23:   #
// 24:   # Of course, when a local variable is GC'd, 1) we need to recover its index
// 25:   # for use by other new local variables (otherwise the locals arrays could
// 26:   # get bigger and bigger with time), and 2) we need to null out all the
// 27:   # references held in the now-unused slots (both to avoid blocking GC of those
// 28:   # objects, and also to prevent "stale" values from being passed on to a new
// 29:   # local when the index is reused).
// 30:   #
// 31:   # Because we need to null out freed slots, we need to keep references to
// 32:   # ALL the locals arrays, so we can null out the appropriate slots in all of
// 33:   # them. This is why we need to use a finalizer to clean up the locals array
// 34:   # when the EC goes out of scope.
// 35:   class AbstractLocals
// 36:     def initialize
// 37:       @free = []
// 38:       @lock = Mutex.new
// 39:       @all_arrays = {}
// 40:       @next = 0
// 41:     end
// 42:
// 43:     def synchronize
// 44:       @lock.synchronize { yield }
// 45:     end
// 46:
// 47:     if Concurrent.on_cruby?
// 48:       def weak_synchronize
// 49:         yield
// 50:       end
// 51:     else
// 52:       alias_method :weak_synchronize, :synchronize
// 53:     end
// 54:
// 55:     def next_index(local)
// 56:       index = synchronize do
// 57:         if @free.empty?
// 58:           @next += 1
// 59:         else
// 60:           @free.pop
// 61:         end
// 62:       end
// 63:
// 64:       # When the local goes out of scope, we should free the associated index
// 65:       # and all values stored into it.
// 66:       ObjectSpace.define_finalizer(local, local_finalizer(index))
// 67:
// 68:       index
// 69:     end
// 70:
// 71:     def free_index(index)
// 72:       weak_synchronize do
// 73:         # The cost of GC'ing a TLV is linear in the number of ECs using local
// 74:         # variables. But that is natural! More ECs means more storage is used
// 75:         # per local variable. So naturally more CPU time is required to free
// 76:         # more storage.
// 77:         #
// 78:         # DO NOT use each_value which might conflict with new pair assignment
// 79:         # into the hash in #set method.
// 80:         @all_arrays.values.each do |locals|
// 81:           locals[index] = nil
// 82:         end
// 83:
// 84:         # free index has to be published after the arrays are cleared:
// 85:         @free << index
// 86:       end
// 87:     end
// 88:
// 89:     def fetch(index)
// 90:       locals = self.locals
// 91:       value = locals ? locals[index] : nil
// 92:
// 93:       if nil == value
// 94:         yield
// 95:       elsif NULL.equal?(value)
// 96:         nil
// 97:       else
// 98:         value
// 99:       end
// 100:     end
// 101:
// 102:     def set(index, value)
// 103:       locals = self.locals!
// 104:       locals[index] = (nil == value ? NULL : value)
// 105:
// 106:       value
// 107:     end
// 108:
// 109:     private
// 110:
// 111:     # When the local goes out of scope, clean up that slot across all locals currently assigned.
// 112:     def local_finalizer(index)
// 113:       proc do
// 114:         free_index(index)
// 115:       end
// 116:     end
// 117:
// 118:     # When a thread/fiber goes out of scope, remove the array from @all_arrays.
// 119:     def thread_fiber_finalizer(array_object_id)
// 120:       proc do
// 121:         weak_synchronize do
// 122:           @all_arrays.delete(array_object_id)
// 123:         end
// 124:       end
// 125:     end
// 126:
// 127:     # Returns the locals for the current scope, or nil if none exist.
// 128:     def locals
// 129:       raise NotImplementedError
// 130:     end
// 131:
// 132:     # Returns the locals for the current scope, creating them if necessary.
// 133:     def locals!
// 134:       raise NotImplementedError
// 135:     end
// 136:   end
// 137:
// 138:   # @!visibility private
// 139:   # @!macro internal_implementation_note
// 140:   # An array-backed storage of indexed variables per thread.
// 141:   class ThreadLocals < AbstractLocals
// 142:     def locals
// 143:       Thread.current.thread_variable_get(:concurrent_thread_locals)
// 144:     end
// 145:
// 146:     def locals!
// 147:       thread = Thread.current
// 148:       locals = thread.thread_variable_get(:concurrent_thread_locals)
// 149:
// 150:       unless locals
// 151:         locals = thread.thread_variable_set(:concurrent_thread_locals, [])
// 152:         weak_synchronize do
// 153:           @all_arrays[locals.object_id] = locals
// 154:         end
// 155:         # When the thread goes out of scope, we should delete the associated locals:
// 156:         ObjectSpace.define_finalizer(thread, thread_fiber_finalizer(locals.object_id))
// 157:       end
// 158:
// 159:       locals
// 160:     end
// 161:   end
// 162:
// 163:   # @!visibility private
// 164:   # @!macro internal_implementation_note
// 165:   # An array-backed storage of indexed variables per fiber.
// 166:   class FiberLocals < AbstractLocals
// 167:     def locals
// 168:       Thread.current[:concurrent_fiber_locals]
// 169:     end
// 170:
// 171:     def locals!
// 172:       thread = Thread.current
// 173:       locals = thread[:concurrent_fiber_locals]
// 174:
// 175:       unless locals
// 176:         locals = thread[:concurrent_fiber_locals] = []
// 177:         weak_synchronize do
// 178:           @all_arrays[locals.object_id] = locals
// 179:         end
// 180:         # When the fiber goes out of scope, we should delete the associated locals:
// 181:         ObjectSpace.define_finalizer(Fiber.current, thread_fiber_finalizer(locals.object_id))
// 182:       end
// 183:
// 184:       locals
// 185:     end
// 186:   end
// 187:
// 188:   private_constant :AbstractLocals, :ThreadLocals, :FiberLocals
// 189: end
