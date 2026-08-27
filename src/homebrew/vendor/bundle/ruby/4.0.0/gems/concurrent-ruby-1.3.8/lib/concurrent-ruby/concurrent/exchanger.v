module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/exchanger.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 44.
pub fn ruby_exchanger_l44_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `exchange(value, timeout = nil)` at line 69.
pub fn ruby_exchanger_l69_d2_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exchange', ...args)
}

// Ruby method `exchange!(value, timeout = nil)` at line 80.
pub fn ruby_exchanger_l80_d3_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exchange!', ...args)
}

// Ruby method `try_exchange(value, timeout = nil)` at line 109.
pub fn ruby_exchanger_l109_d4_try_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_exchange', ...args)
}

// Ruby method `do_exchange(value, timeout)` at line 122.
pub fn ruby_exchanger_l122_d5_do_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_exchange', ...args)
}

// Ruby attr_atomic `attr_atomic :value` at line 139.
pub fn ruby_exchanger_l139_d6_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby attr_atomic `attr_atomic :value` at line 139.
pub fn ruby_exchanger_l139_d7_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby attr_atomic `attr_atomic :value` at line 139.
pub fn ruby_exchanger_l139_d8_compare_and_set_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_value', ...args)
}

// Ruby attr_atomic `attr_atomic :value` at line 139.
pub fn ruby_exchanger_l139_d9_swap_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap_value', ...args)
}

// Ruby attr_atomic `attr_atomic :value` at line 139.
pub fn ruby_exchanger_l139_d10_update_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_value', ...args)
}

// Ruby method `initialize(item)` at line 142.
pub fn ruby_exchanger_l142_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `latch` at line 149.
pub fn ruby_exchanger_l149_d12_latch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latch', ...args)
}

// Ruby method `item` at line 153.
pub fn ruby_exchanger_l153_d13_item(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('item', ...args)
}

// Ruby method `initialize` at line 159.
pub fn ruby_exchanger_l159_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_atomic `attr_atomic(:slot)` at line 165.
pub fn ruby_exchanger_l165_d15_slot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('slot', ...args)
}

// Ruby attr_atomic `attr_atomic(:slot)` at line 165.
pub fn ruby_exchanger_l165_d16_slot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('slot=', ...args)
}

// Ruby attr_atomic `attr_atomic(:slot)` at line 165.
pub fn ruby_exchanger_l165_d17_compare_and_set_slot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_slot', ...args)
}

// Ruby attr_atomic `attr_atomic(:slot)` at line 165.
pub fn ruby_exchanger_l165_d18_swap_slot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap_slot', ...args)
}

// Ruby attr_atomic `attr_atomic(:slot)` at line 165.
pub fn ruby_exchanger_l165_d19_update_slot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_slot', ...args)
}

// Ruby method `do_exchange(value, timeout)` at line 170.
pub fn ruby_exchanger_l170_d20_do_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_exchange', ...args)
}

// Ruby method `initialize` at line 298.
pub fn ruby_exchanger_l298_d21_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `do_exchange(value, timeout)` at line 307.
pub fn ruby_exchanger_l307_d22_do_exchange(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_exchange', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require 'concurrent/errors'
// 3: require 'concurrent/maybe'
// 4: require 'concurrent/atomic/atomic_reference'
// 5: require 'concurrent/atomic/count_down_latch'
// 6: require 'concurrent/utility/engine'
// 7: require 'concurrent/utility/monotonic_time'
// 8:
// 9: module Concurrent
// 10:
// 11:   # @!macro exchanger
// 12:   #
// 13:   #   A synchronization point at which threads can pair and swap elements within
// 14:   #   pairs. Each thread presents some object on entry to the exchange method,
// 15:   #   matches with a partner thread, and receives its partner's object on return.
// 16:   #
// 17:   #   @!macro thread_safe_variable_comparison
// 18:   #
// 19:   #   This implementation is very simple, using only a single slot for each
// 20:   #   exchanger (unlike more advanced implementations which use an "arena").
// 21:   #   This approach will work perfectly fine when there are only a few threads
// 22:   #   accessing a single `Exchanger`. Beyond a handful of threads the performance
// 23:   #   will degrade rapidly due to contention on the single slot, but the algorithm
// 24:   #   will remain correct.
// 25:   #
// 26:   #   @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Exchanger.html java.util.concurrent.Exchanger
// 27:   #   @example
// 28:   #
// 29:   #     exchanger = Concurrent::Exchanger.new
// 30:   #
// 31:   #     threads = [
// 32:   #       Thread.new { puts "first: " << exchanger.exchange('foo', 1) }, #=> "first: bar"
// 33:   #       Thread.new { puts "second: " << exchanger.exchange('bar', 1) } #=> "second: foo"
// 34:   #     ]
// 35:   #     threads.each {|t| t.join(2) }
// 36:
// 37:   # @!visibility private
// 38:   class AbstractExchanger < Synchronization::Object
// 39:
// 40:     # @!visibility private
// 41:     CANCEL = ::Object.new
// 42:     private_constant :CANCEL
// 43:
// 44:     def initialize
// 45:       super
// 46:     end
// 47:
// 48:     # @!macro exchanger_method_do_exchange
// 49:     #
// 50:     #   Waits for another thread to arrive at this exchange point (unless the
// 51:     #   current thread is interrupted), and then transfers the given object to
// 52:     #   it, receiving its object in return. The timeout value indicates the
// 53:     #   approximate number of seconds the method should block while waiting
// 54:     #   for the exchange. When the timeout value is `nil` the method will
// 55:     #   block indefinitely.
// 56:     #
// 57:     #   @param [Object] value the value to exchange with another thread
// 58:     #   @param [Numeric, nil] timeout in seconds, `nil` blocks indefinitely
// 59:     #
// 60:     # @!macro exchanger_method_exchange
// 61:     #
// 62:     #   In some edge cases when a `timeout` is given a return value of `nil` may be
// 63:     #   ambiguous. Specifically, if `nil` is a valid value in the exchange it will
// 64:     #   be impossible to tell whether `nil` is the actual return value or if it
// 65:     #   signifies timeout. When `nil` is a valid value in the exchange consider
// 66:     #   using {#exchange!} or {#try_exchange} instead.
// 67:     #
// 68:     #   @return [Object] the value exchanged by the other thread or `nil` on timeout
// 69:     def exchange(value, timeout = nil)
// 70:       (value = do_exchange(value, timeout)) == CANCEL ? nil : value
// 71:     end
// 72:
// 73:     # @!macro exchanger_method_do_exchange
// 74:     # @!macro exchanger_method_exchange_bang
// 75:     #
// 76:     #   On timeout a {Concurrent::TimeoutError} exception will be raised.
// 77:     #
// 78:     #   @return [Object] the value exchanged by the other thread
// 79:     #   @raise [Concurrent::TimeoutError] on timeout
// 80:     def exchange!(value, timeout = nil)
// 81:       if (value = do_exchange(value, timeout)) == CANCEL
// 82:         raise Concurrent::TimeoutError
// 83:       else
// 84:         value
// 85:       end
// 86:     end
// 87:
// 88:     # @!macro exchanger_method_do_exchange
// 89:     # @!macro exchanger_method_try_exchange
// 90:     #
// 91:     #   The return value will be a {Concurrent::Maybe} set to `Just` on success or
// 92:     #   `Nothing` on timeout.
// 93:     #
// 94:     #   @return [Concurrent::Maybe] on success a `Just` maybe will be returned with
// 95:     #     the item exchanged by the other thread as `#value`; on timeout a
// 96:     #     `Nothing` maybe will be returned with {Concurrent::TimeoutError} as `#reason`
// 97:     #
// 98:     #   @example
// 99:     #
// 100:     #     exchanger = Concurrent::Exchanger.new
// 101:     #
// 102:     #     result = exchanger.exchange(:foo, 0.5)
// 103:     #
// 104:     #     if result.just?
// 105:     #       puts result.value #=> :bar
// 106:     #     else
// 107:     #       puts 'timeout'
// 108:     #     end
// 109:     def try_exchange(value, timeout = nil)
// 110:       if (value = do_exchange(value, timeout)) == CANCEL
// 111:         Concurrent::Maybe.nothing(Concurrent::TimeoutError)
// 112:       else
// 113:         Concurrent::Maybe.just(value)
// 114:       end
// 115:     end
// 116:
// 117:     private
// 118:
// 119:     # @!macro exchanger_method_do_exchange
// 120:     #
// 121:     # @return [Object, CANCEL] the value exchanged by the other thread; {CANCEL} on timeout
// 122:     def do_exchange(value, timeout)
// 123:       raise NotImplementedError
// 124:     end
// 125:   end
// 126:
// 127:   # @!macro internal_implementation_note
// 128:   # @!visibility private
// 129:   class RubyExchanger < AbstractExchanger
// 130:     # A simplified version of java.util.concurrent.Exchanger written by
// 131:     # Doug Lea, Bill Scherer, and Michael Scott with assistance from members
// 132:     # of JCP JSR-166 Expert Group and released to the public domain. It does
// 133:     # not include the arena or the multi-processor spin loops.
// 134:     # http://grepcode.com/file/repository.grepcode.com/java/root/jdk/openjdk/6-b14/java/util/concurrent/Exchanger.java
// 135:
// 136:     safe_initialization!
// 137:
// 138:     class Node < Concurrent::Synchronization::Object
// 139:       attr_atomic :value
// 140:       safe_initialization!
// 141:
// 142:       def initialize(item)
// 143:         super()
// 144:         @Item      = item
// 145:         @Latch     = Concurrent::CountDownLatch.new
// 146:         self.value = nil
// 147:       end
// 148:
// 149:       def latch
// 150:         @Latch
// 151:       end
// 152:
// 153:       def item
// 154:         @Item
// 155:       end
// 156:     end
// 157:     private_constant :Node
// 158:
// 159:     def initialize
// 160:       super
// 161:     end
// 162:
// 163:     private
// 164:
// 165:     attr_atomic(:slot)
// 166:
// 167:     # @!macro exchanger_method_do_exchange
// 168:     #
// 169:     # @return [Object, CANCEL] the value exchanged by the other thread; {CANCEL} on timeout
// 170:     def do_exchange(value, timeout)
// 171:
// 172:       # ALGORITHM
// 173:       #
// 174:       # From the original Java version:
// 175:       #
// 176:       # > The basic idea is to maintain a "slot", which is a reference to
// 177:       # > a Node containing both an Item to offer and a "hole" waiting to
// 178:       # > get filled in.  If an incoming "occupying" thread sees that the
// 179:       # > slot is null, it CAS'es (compareAndSets) a Node there and waits
// 180:       # > for another to invoke exchange.  That second "fulfilling" thread
// 181:       # > sees that the slot is non-null, and so CASes it back to null,
// 182:       # > also exchanging items by CASing the hole, plus waking up the
// 183:       # > occupying thread if it is blocked.  In each case CAS'es may
// 184:       # > fail because a slot at first appears non-null but is null upon
// 185:       # > CAS, or vice-versa.  So threads may need to retry these
// 186:       # > actions.
// 187:       #
// 188:       # This version:
// 189:       #
// 190:       # An exchange occurs between an "occupier" thread and a "fulfiller" thread.
// 191:       # The "slot" is used to setup this interaction. The first thread in the
// 192:       # exchange puts itself into the slot (occupies) and waits for a fulfiller.
// 193:       # The second thread removes the occupier from the slot and attempts to
// 194:       # perform the exchange. Removing the occupier also frees the slot for
// 195:       # another occupier/fulfiller pair.
// 196:       #
// 197:       # Because the occupier and the fulfiller are operating independently and
// 198:       # because there may be contention with other threads, any failed operation
// 199:       # indicates contention. Both the occupier and the fulfiller operate within
// 200:       # spin loops. Any failed actions along the happy path will cause the thread
// 201:       # to repeat the loop and try again.
// 202:       #
// 203:       # When a timeout value is given the thread must be cognizant of time spent
// 204:       # in the spin loop. The remaining time is checked every loop. When the time
// 205:       # runs out the thread will exit.
// 206:       #
// 207:       # A "node" is the data structure used to perform the exchange. Only the
// 208:       # occupier's node is necessary. It's the node used for the exchange.
// 209:       # Each node has an "item," a "hole" (self), and a "latch." The item is the
// 210:       # node's initial value. It never changes. It's what the fulfiller returns on
// 211:       # success. The occupier's hole is where the fulfiller put its item. It's the
// 212:       # item that the occupier returns on success. The latch is used for synchronization.
// 213:       # Because a thread may act as either an occupier or fulfiller (or possibly
// 214:       # both in periods of high contention) every thread creates a node when
// 215:       # the exchange method is first called.
// 216:       #
// 217:       # The following steps occur within the spin loop. If any actions fail
// 218:       # the thread will loop and try again, so long as there is time remaining.
// 219:       # If time runs out the thread will return CANCEL.
// 220:       #
// 221:       # Check the slot for an occupier:
// 222:       #
// 223:       #   * If the slot is empty try to occupy
// 224:       #   * If the slot is full try to fulfill
// 225:       #
// 226:       # Attempt to occupy:
// 227:       #
// 228:       #   * Attempt to CAS myself into the slot
// 229:       #   * Go to sleep and wait to be woken by a fulfiller
// 230:       #   * If the sleep is successful then the fulfiller completed its happy path
// 231:       #     - Return the value from my hole (the value given by the fulfiller)
// 232:       #   * When the sleep fails (time ran out) attempt to cancel the operation
// 233:       #     - Attempt to CAS myself out of the hole
// 234:       #     - If successful there is no contention
// 235:       #       - Return CANCEL
// 236:       #     - On failure, I am competing with a fulfiller
// 237:       #       - Attempt to CAS my hole to CANCEL
// 238:       #       - On success
// 239:       #         - Let the fulfiller deal with my cancel
// 240:       #         - Return CANCEL
// 241:       #       - On failure the fulfiller has completed its happy path
// 242:       #         - Return th value from my hole (the fulfiller's value)
// 243:       #
// 244:       # Attempt to fulfill:
// 245:       #
// 246:       # * Attempt to CAS the occupier out of the slot
// 247:       #   - On failure loop again
// 248:       # * Attempt to CAS my item into the occupier's hole
// 249:       #   - On failure the occupier is trying to cancel
// 250:       #     - Loop again
// 251:       #   - On success we are on the happy path
// 252:       #     - Wake the sleeping occupier
// 253:       #     - Return the occupier's item
// 254:
// 255:       value  = NULL if value.nil? # The sentinel allows nil to be a valid value
// 256:       me     = Node.new(value) # create my node in case I need to occupy
// 257:       end_at = Concurrent.monotonic_time + timeout.to_f # The time to give up
// 258:
// 259:       result = loop do
// 260:         other = slot
// 261:         if other && compare_and_set_slot(other, nil)
// 262:           # try to fulfill
// 263:           if other.compare_and_set_value(nil, value)
// 264:             # happy path
// 265:             other.latch.count_down
// 266:             break other.item
// 267:           end
// 268:         elsif other.nil? && compare_and_set_slot(nil, me)
// 269:           # try to occupy
// 270:           timeout = end_at - Concurrent.monotonic_time if timeout
// 271:           if me.latch.wait(timeout)
// 272:             # happy path
// 273:             break me.value
// 274:           else
// 275:             # attempt to remove myself from the slot
// 276:             if compare_and_set_slot(me, nil)
// 277:               break CANCEL
// 278:             elsif !me.compare_and_set_value(nil, CANCEL)
// 279:               # I've failed to block the fulfiller
// 280:               break me.value
// 281:             end
// 282:           end
// 283:         end
// 284:         break CANCEL if timeout && Concurrent.monotonic_time >= end_at
// 285:       end
// 286:
// 287:       result == NULL ? nil : result
// 288:     end
// 289:   end
// 290:
// 291:   if Concurrent.on_jruby?
// 292:     require 'concurrent/utility/native_extension_loader'
// 293:
// 294:     # @!macro internal_implementation_note
// 295:     # @!visibility private
// 296:     class JavaExchanger < AbstractExchanger
// 297:
// 298:       def initialize
// 299:         @exchanger = java.util.concurrent.Exchanger.new
// 300:       end
// 301:
// 302:       private
// 303:
// 304:       # @!macro exchanger_method_do_exchange
// 305:       #
// 306:       # @return [Object, CANCEL] the value exchanged by the other thread; {CANCEL} on timeout
// 307:       def do_exchange(value, timeout)
// 308:         result = nil
// 309:         if timeout.nil?
// 310:           Synchronization::JRuby.sleep_interruptibly do
// 311:             result = @exchanger.exchange(value)
// 312:           end
// 313:         else
// 314:           Synchronization::JRuby.sleep_interruptibly do
// 315:             result = @exchanger.exchange(value, 1000 * timeout, java.util.concurrent.TimeUnit::MILLISECONDS)
// 316:           end
// 317:         end
// 318:         result
// 319:       rescue java.util.concurrent.TimeoutException
// 320:         CANCEL
// 321:       end
// 322:     end
// 323:   end
// 324:
// 325:   # @!visibility private
// 326:   # @!macro internal_implementation_note
// 327:   ExchangerImplementation = case
// 328:                             when Concurrent.on_jruby?
// 329:                               JavaExchanger
// 330:                             else
// 331:                               RubyExchanger
// 332:                             end
// 333:   private_constant :ExchangerImplementation
// 334:
// 335:   # @!macro exchanger
// 336:   class Exchanger < ExchangerImplementation
// 337:
// 338:     # @!method initialize
// 339:     #   Creates exchanger instance
// 340:
// 341:     # @!method exchange(value, timeout = nil)
// 342:     #   @!macro exchanger_method_do_exchange
// 343:     #   @!macro exchanger_method_exchange
// 344:
// 345:     # @!method exchange!(value, timeout = nil)
// 346:     #   @!macro exchanger_method_do_exchange
// 347:     #   @!macro exchanger_method_exchange_bang
// 348:
// 349:     # @!method try_exchange(value, timeout = nil)
// 350:     #   @!macro exchanger_method_do_exchange
// 351:     #   @!macro exchanger_method_try_exchange
// 352:   end
// 353: end
