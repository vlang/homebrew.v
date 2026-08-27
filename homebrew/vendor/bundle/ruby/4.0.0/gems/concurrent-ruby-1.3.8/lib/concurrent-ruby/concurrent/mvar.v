module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/mvar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(value = EMPTY, opts = {})` at line 54.
pub fn ruby_mvar_l54_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `take(timeout = nil)` at line 66.
pub fn ruby_mvar_l66_d2_take(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('take', ...args)
}

// Ruby method `borrow(timeout = nil)` at line 86.
pub fn ruby_mvar_l86_d3_borrow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('borrow', ...args)
}

// Ruby method `put(value, timeout = nil)` at line 103.
pub fn ruby_mvar_l103_d4_put(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('put', ...args)
}

// Ruby method `modify(timeout = nil)` at line 123.
pub fn ruby_mvar_l123_d5_modify(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('modify', ...args)
}

// Ruby method `try_take!` at line 142.
pub fn ruby_mvar_l142_d6_try_take(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_take!', ...args)
}

// Ruby method `try_put!(value)` at line 156.
pub fn ruby_mvar_l156_d7_try_put(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_put!', ...args)
}

// Ruby method `set!(value)` at line 169.
pub fn ruby_mvar_l169_d8_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set!', ...args)
}

// Ruby method `modify!` at line 179.
pub fn ruby_mvar_l179_d9_modify(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('modify!', ...args)
}

// Ruby method `empty?` at line 195.
pub fn ruby_mvar_l195_d10_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `full?` at line 200.
pub fn ruby_mvar_l200_d11_full(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full?', ...args)
}

// Ruby method `synchronize(&block)` at line 206.
pub fn ruby_mvar_l206_d12_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synchronize', ...args)
}

// Ruby method `unlocked_empty?` at line 212.
pub fn ruby_mvar_l212_d13_unlocked_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlocked_empty?', ...args)
}

// Ruby method `unlocked_full?` at line 216.
pub fn ruby_mvar_l216_d14_unlocked_full(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlocked_full?', ...args)
}

// Ruby method `wait_for_full(timeout)` at line 220.
pub fn ruby_mvar_l220_d15_wait_for_full(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_for_full', ...args)
}

// Ruby method `wait_for_empty(timeout)` at line 224.
pub fn ruby_mvar_l224_d16_wait_for_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_for_empty', ...args)
}

// Ruby method `wait_while(condition, timeout)` at line 228.
pub fn ruby_mvar_l228_d17_wait_while(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_while', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/concern/dereferenceable'
// 2: require 'concurrent/synchronization/object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # An `MVar` is a synchronized single element container. They are empty or
// 7:   # contain one item. Taking a value from an empty `MVar` blocks, as does
// 8:   # putting a value into a full one. You can either think of them as blocking
// 9:   # queue of length one, or a special kind of mutable variable.
// 10:   #
// 11:   # On top of the fundamental `#put` and `#take` operations, we also provide a
// 12:   # `#modify` that is atomic with respect to operations on the same instance.
// 13:   # These operations all support timeouts.
// 14:   #
// 15:   # We also support non-blocking operations `#try_put!` and `#try_take!`, a
// 16:   # `#set!` that ignores existing values, a `#value` that returns the value
// 17:   # without removing it or returns `MVar::EMPTY`, and a `#modify!` that yields
// 18:   # `MVar::EMPTY` if the `MVar` is empty and can be used to set `MVar::EMPTY`.
// 19:   # You shouldn't use these operations in the first instance.
// 20:   #
// 21:   # `MVar` is a [Dereferenceable](Dereferenceable).
// 22:   #
// 23:   # `MVar` is related to M-structures in Id, `MVar` in Haskell and `SyncVar` in Scala.
// 24:   #
// 25:   # Note that unlike the original Haskell paper, our `#take` is blocking. This is how
// 26:   # Haskell and Scala do it today.
// 27:   #
// 28:   # @!macro copy_options
// 29:   #
// 30:   # ## See Also
// 31:   #
// 32:   # 1. P. Barth, R. Nikhil, and Arvind. [M-Structures: Extending a parallel, non- strict, functional language with state](http://dl.acm.org/citation.cfm?id=652538). In Proceedings of the 5th
// 33:   #    ACM Conference on Functional Programming Languages and Computer Architecture (FPCA), 1991.
// 34:   #
// 35:   # 2. S. Peyton Jones, A. Gordon, and S. Finne. [Concurrent Haskell](http://dl.acm.org/citation.cfm?id=237794).
// 36:   #    In Proceedings of the 23rd Symposium on Principles of Programming Languages
// 37:   #    (PoPL), 1996.
// 38:   class MVar < Synchronization::Object
// 39:     include Concern::Dereferenceable
// 40:     safe_initialization!
// 41:
// 42:     # Unique value that represents that an `MVar` was empty
// 43:     EMPTY = ::Object.new
// 44:
// 45:     # Unique value that represents that an `MVar` timed out before it was able
// 46:     # to produce a value.
// 47:     TIMEOUT = ::Object.new
// 48:
// 49:     # Create a new `MVar`, either empty or with an initial value.
// 50:     #
// 51:     # @param [Hash] opts the options controlling how the future will be processed
// 52:     #
// 53:     # @!macro deref_options
// 54:     def initialize(value = EMPTY, opts = {})
// 55:       @value = value
// 56:       @mutex = Mutex.new
// 57:       @empty_condition = ConditionVariable.new
// 58:       @full_condition = ConditionVariable.new
// 59:       set_deref_options(opts)
// 60:     end
// 61:
// 62:     # Remove the value from an `MVar`, leaving it empty, and blocking if there
// 63:     # isn't a value. A timeout can be set to limit the time spent blocked, in
// 64:     # which case it returns `TIMEOUT` if the time is exceeded.
// 65:     # @return [Object] the value that was taken, or `TIMEOUT`
// 66:     def take(timeout = nil)
// 67:       @mutex.synchronize do
// 68:         wait_for_full(timeout)
// 69:
// 70:         # If we timed out we'll still be empty
// 71:         if unlocked_full?
// 72:           value = @value
// 73:           @value = EMPTY
// 74:           @empty_condition.signal
// 75:           apply_deref_options(value)
// 76:         else
// 77:           TIMEOUT
// 78:         end
// 79:       end
// 80:     end
// 81:
// 82:     # acquires lock on the from an `MVAR`, yields the value to provided block,
// 83:     # and release lock. A timeout can be set to limit the time spent blocked,
// 84:     # in which case it returns `TIMEOUT` if the time is exceeded.
// 85:     # @return [Object] the value returned by the block, or `TIMEOUT`
// 86:     def borrow(timeout = nil)
// 87:       @mutex.synchronize do
// 88:         wait_for_full(timeout)
// 89:
// 90:         # If we timed out we'll still be empty
// 91:         if unlocked_full?
// 92:           yield @value
// 93:         else
// 94:           TIMEOUT
// 95:         end
// 96:       end
// 97:     end
// 98:
// 99:     # Put a value into an `MVar`, blocking if there is already a value until
// 100:     # it is empty. A timeout can be set to limit the time spent blocked, in
// 101:     # which case it returns `TIMEOUT` if the time is exceeded.
// 102:     # @return [Object] the value that was put, or `TIMEOUT`
// 103:     def put(value, timeout = nil)
// 104:       @mutex.synchronize do
// 105:         wait_for_empty(timeout)
// 106:
// 107:         # If we timed out we won't be empty
// 108:         if unlocked_empty?
// 109:           @value = value
// 110:           @full_condition.signal
// 111:           apply_deref_options(value)
// 112:         else
// 113:           TIMEOUT
// 114:         end
// 115:       end
// 116:     end
// 117:
// 118:     # Atomically `take`, yield the value to a block for transformation, and then
// 119:     # `put` the transformed value. Returns the pre-transform value. A timeout can
// 120:     # be set to limit the time spent blocked, in which case it returns `TIMEOUT`
// 121:     # if the time is exceeded.
// 122:     # @return [Object] the pre-transform value, or `TIMEOUT`
// 123:     def modify(timeout = nil)
// 124:       raise ArgumentError.new('no block given') unless block_given?
// 125:
// 126:       @mutex.synchronize do
// 127:         wait_for_full(timeout)
// 128:
// 129:         # If we timed out we'll still be empty
// 130:         if unlocked_full?
// 131:           value = @value
// 132:           @value = yield value
// 133:           @full_condition.signal
// 134:           apply_deref_options(value)
// 135:         else
// 136:           TIMEOUT
// 137:         end
// 138:       end
// 139:     end
// 140:
// 141:     # Non-blocking version of `take`, that returns `EMPTY` instead of blocking.
// 142:     def try_take!
// 143:       @mutex.synchronize do
// 144:         if unlocked_full?
// 145:           value = @value
// 146:           @value = EMPTY
// 147:           @empty_condition.signal
// 148:           apply_deref_options(value)
// 149:         else
// 150:           EMPTY
// 151:         end
// 152:       end
// 153:     end
// 154:
// 155:     # Non-blocking version of `put`, that returns whether or not it was successful.
// 156:     def try_put!(value)
// 157:       @mutex.synchronize do
// 158:         if unlocked_empty?
// 159:           @value = value
// 160:           @full_condition.signal
// 161:           true
// 162:         else
// 163:           false
// 164:         end
// 165:       end
// 166:     end
// 167:
// 168:     # Non-blocking version of `put` that will overwrite an existing value.
// 169:     def set!(value)
// 170:       @mutex.synchronize do
// 171:         old_value = @value
// 172:         @value = value
// 173:         @full_condition.signal
// 174:         apply_deref_options(old_value)
// 175:       end
// 176:     end
// 177:
// 178:     # Non-blocking version of `modify` that will yield with `EMPTY` if there is no value yet.
// 179:     def modify!
// 180:       raise ArgumentError.new('no block given') unless block_given?
// 181:
// 182:       @mutex.synchronize do
// 183:         value = @value
// 184:         @value = yield value
// 185:         if unlocked_empty?
// 186:           @empty_condition.signal
// 187:         else
// 188:           @full_condition.signal
// 189:         end
// 190:         apply_deref_options(value)
// 191:       end
// 192:     end
// 193:
// 194:     # Returns if the `MVar` is currently empty.
// 195:     def empty?
// 196:       @mutex.synchronize { @value == EMPTY }
// 197:     end
// 198:
// 199:     # Returns if the `MVar` currently contains a value.
// 200:     def full?
// 201:       !empty?
// 202:     end
// 203:
// 204:     protected
// 205:
// 206:     def synchronize(&block)
// 207:       @mutex.synchronize(&block)
// 208:     end
// 209:
// 210:     private
// 211:
// 212:     def unlocked_empty?
// 213:       @value == EMPTY
// 214:     end
// 215:
// 216:     def unlocked_full?
// 217:       ! unlocked_empty?
// 218:     end
// 219:
// 220:     def wait_for_full(timeout)
// 221:       wait_while(@full_condition, timeout) { unlocked_empty? }
// 222:     end
// 223:
// 224:     def wait_for_empty(timeout)
// 225:       wait_while(@empty_condition, timeout) { unlocked_full? }
// 226:     end
// 227:
// 228:     def wait_while(condition, timeout)
// 229:       if timeout.nil?
// 230:         while yield
// 231:           condition.wait(@mutex)
// 232:         end
// 233:       else
// 234:         stop = Concurrent.monotonic_time + timeout
// 235:         while yield && timeout > 0.0
// 236:           condition.wait(@mutex, timeout)
// 237:           timeout = stop - Concurrent.monotonic_time
// 238:         end
// 239:       end
// 240:     end
// 241:   end
// 242: end
