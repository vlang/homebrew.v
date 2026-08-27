module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/promise.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(opts = {}, &block)` at line 210.
pub fn ruby_promise_l210_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.fulfill(value, opts = {})` at line 224.
pub fn ruby_promise_l224_d2_self_fulfill(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fulfill', ...args)
}

// Ruby method `self.reject(reason, opts = {})` at line 237.
pub fn ruby_promise_l237_d3_self_reject(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reject', ...args)
}

// Ruby method `execute` at line 246.
pub fn ruby_promise_l246_d4_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute', ...args)
}

// Ruby method `set(value = NULL, &block)` at line 262.
pub fn ruby_promise_l262_d5_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `fail(reason = StandardError.new)` at line 278.
pub fn ruby_promise_l278_d6_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fail', ...args)
}

// Ruby method `self.execute(opts = {}, &block)` at line 296.
pub fn ruby_promise_l296_d7_self_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.execute', ...args)
}

// Ruby method `then(*args, &block)` at line 314.
pub fn ruby_promise_l314_d8_then(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('then', ...args)
}

// Ruby method `on_success(&block)` at line 349.
pub fn ruby_promise_l349_d9_on_success(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_success', ...args)
}

// Ruby method `rescue(&block)` at line 360.
pub fn ruby_promise_l360_d10_rescue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rescue', ...args)
}

// Ruby alias_method `alias_method :catch, :rescue` at line 364.
pub fn ruby_promise_l364_d11_catch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('catch', ...args)
}

// Ruby alias_method `alias_method :on_error, :rescue` at line 365.
pub fn ruby_promise_l365_d12_on_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_error', ...args)
}

// Ruby method `flat_map(&block)` at line 375.
pub fn ruby_promise_l375_d13_flat_map(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('flat_map', ...args)
}

// Ruby method `self.zip(*promises)` at line 409.
pub fn ruby_promise_l409_d14_self_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.zip', ...args)
}

// Ruby method `zip(*others)` at line 440.
pub fn ruby_promise_l440_d15_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('zip', ...args)
}

// Ruby method `self.all?(*promises)` at line 464.
pub fn ruby_promise_l464_d16_self_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.all?', ...args)
}

// Ruby method `self.any?(*promises)` at line 475.
pub fn ruby_promise_l475_d17_self_any(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.any?', ...args)
}

// Ruby method `ns_initialize(value, opts)` at line 481.
pub fn ruby_promise_l481_d18_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `self.aggregate(method, *promises)` at line 505.
pub fn ruby_promise_l505_d19_self_aggregate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.aggregate', ...args)
}

// Ruby method `set_pending` at line 520.
pub fn ruby_promise_l520_d20_set_pending(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_pending', ...args)
}

// Ruby method `root? # :nodoc:` at line 528.
pub fn ruby_promise_l528_d21_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('root?', ...args)
}

// Ruby method `on_fulfill(result)` at line 533.
pub fn ruby_promise_l533_d22_on_fulfill(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_fulfill', ...args)
}

// Ruby method `on_reject(reason)` at line 539.
pub fn ruby_promise_l539_d23_on_reject(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_reject', ...args)
}

// Ruby method `notify_child(child)` at line 545.
pub fn ruby_promise_l545_d24_notify_child(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notify_child', ...args)
}

// Ruby method `complete(success, value, reason)` at line 551.
pub fn ruby_promise_l551_d25_complete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('complete', ...args)
}

// Ruby method `realize(task)` at line 562.
pub fn ruby_promise_l562_d26_realize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('realize', ...args)
}

// Ruby method `set_state!(success, value, reason)` at line 570.
pub fn ruby_promise_l570_d27_set_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_state!', ...args)
}

// Ruby method `synchronized_set_state!(success, value, reason)` at line 576.
pub fn ruby_promise_l576_d28_synchronized_set_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synchronized_set_state!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/constants'
// 3: require 'concurrent/errors'
// 4: require 'concurrent/ivar'
// 5: require 'concurrent/executor/safe_task_executor'
// 6:
// 7: require 'concurrent/options'
// 8:
// 9: module Concurrent
// 10:
// 11:   PromiseExecutionError = Class.new(StandardError)
// 12:
// 13:   # Promises are inspired by the JavaScript [Promises/A](http://wiki.commonjs.org/wiki/Promises/A)
// 14:   # and [Promises/A+](http://promises-aplus.github.io/promises-spec/) specifications.
// 15:   #
// 16:   # > A promise represents the eventual value returned from the single
// 17:   # > completion of an operation.
// 18:   #
// 19:   # Promises are similar to futures and share many of the same behaviours.
// 20:   # Promises are far more robust, however. Promises can be chained in a tree
// 21:   # structure where each promise may have zero or more children. Promises are
// 22:   # chained using the `then` method. The result of a call to `then` is always
// 23:   # another promise. Promises are resolved asynchronously (with respect to the
// 24:   # main thread) but in a strict order: parents are guaranteed to be resolved
// 25:   # before their children, children before their younger siblings. The `then`
// 26:   # method takes two parameters: an optional block to be executed upon parent
// 27:   # resolution and an optional callable to be executed upon parent failure. The
// 28:   # result of each promise is passed to each of its children upon resolution.
// 29:   # When a promise is rejected all its children will be summarily rejected and
// 30:   # will receive the reason.
// 31:   #
// 32:   # Promises have several possible states: *:unscheduled*, *:pending*,
// 33:   # *:processing*, *:rejected*, or *:fulfilled*. These are also aggregated as
// 34:   # `#incomplete?` and `#complete?`. When a Promise is created it is set to
// 35:   # *:unscheduled*. Once the `#execute` method is called the state becomes
// 36:   # *:pending*. Once a job is pulled from the thread pool's queue and is given
// 37:   # to a thread for processing (often immediately upon `#post`) the state
// 38:   # becomes *:processing*. The future will remain in this state until processing
// 39:   # is complete. A future that is in the *:unscheduled*, *:pending*, or
// 40:   # *:processing* is considered `#incomplete?`. A `#complete?` Promise is either
// 41:   # *:rejected*, indicating that an exception was thrown during processing, or
// 42:   # *:fulfilled*, indicating success. If a Promise is *:fulfilled* its `#value`
// 43:   # will be updated to reflect the result of the operation. If *:rejected* the
// 44:   # `reason` will be updated with a reference to the thrown exception. The
// 45:   # predicate methods `#unscheduled?`, `#pending?`, `#rejected?`, and
// 46:   # `#fulfilled?` can be called at any time to obtain the state of the Promise,
// 47:   # as can the `#state` method, which returns a symbol.
// 48:   #
// 49:   # Retrieving the value of a promise is done through the `value` (alias:
// 50:   # `deref`) method. Obtaining the value of a promise is a potentially blocking
// 51:   # operation. When a promise is *rejected* a call to `value` will return `nil`
// 52:   # immediately. When a promise is *fulfilled* a call to `value` will
// 53:   # immediately return the current value. When a promise is *pending* a call to
// 54:   # `value` will block until the promise is either *rejected* or *fulfilled*. A
// 55:   # *timeout* value can be passed to `value` to limit how long the call will
// 56:   # block. If `nil` the call will block indefinitely. If `0` the call will not
// 57:   # block. Any other integer or float value will indicate the maximum number of
// 58:   # seconds to block.
// 59:   #
// 60:   # Promises run on the global thread pool.
// 61:   #
// 62:   # @!macro copy_options
// 63:   #
// 64:   # ### Examples
// 65:   #
// 66:   # Start by requiring promises
// 67:   #
// 68:   # ```ruby
// 69:   # require 'concurrent/promise'
// 70:   # ```
// 71:   #
// 72:   # Then create one
// 73:   #
// 74:   # ```ruby
// 75:   # p = Concurrent::Promise.execute do
// 76:   #       # do something
// 77:   #       42
// 78:   #     end
// 79:   # ```
// 80:   #
// 81:   # Promises can be chained using the `then` method. The `then` method accepts a
// 82:   # block and an executor, to be executed on fulfillment, and a callable argument to be executed
// 83:   # on rejection. The result of the each promise is passed as the block argument
// 84:   # to chained promises.
// 85:   #
// 86:   # ```ruby
// 87:   # p = Concurrent::Promise.new{10}.then{|x| x * 2}.then{|result| result - 10 }.execute
// 88:   # ```
// 89:   #
// 90:   # And so on, and so on, and so on...
// 91:   #
// 92:   # ```ruby
// 93:   # p = Concurrent::Promise.fulfill(20).
// 94:   #     then{|result| result - 10 }.
// 95:   #     then{|result| result * 3 }.
// 96:   #     then(executor: different_executor){|result| result % 5 }.execute
// 97:   # ```
// 98:   #
// 99:   # The initial state of a newly created Promise depends on the state of its parent:
// 100:   # - if parent is *unscheduled* the child will be *unscheduled*
// 101:   # - if parent is *pending* the child will be *pending*
// 102:   # - if parent is *fulfilled* the child will be *pending*
// 103:   # - if parent is *rejected* the child will be *pending* (but will ultimately be *rejected*)
// 104:   #
// 105:   # Promises are executed asynchronously from the main thread. By the time a
// 106:   # child Promise finishes initialization it may be in a different state than its
// 107:   # parent (by the time a child is created its parent may have completed
// 108:   # execution and changed state). Despite being asynchronous, however, the order
// 109:   # of execution of Promise objects in a chain (or tree) is strictly defined.
// 110:   #
// 111:   # There are multiple ways to create and execute a new `Promise`. Both ways
// 112:   # provide identical behavior:
// 113:   #
// 114:   # ```ruby
// 115:   # # create, operate, then execute
// 116:   # p1 = Concurrent::Promise.new{ "Hello World!" }
// 117:   # p1.state #=> :unscheduled
// 118:   # p1.execute
// 119:   #
// 120:   # # create and immediately execute
// 121:   # p2 = Concurrent::Promise.new{ "Hello World!" }.execute
// 122:   #
// 123:   # # execute during creation
// 124:   # p3 = Concurrent::Promise.execute{ "Hello World!" }
// 125:   # ```
// 126:   #
// 127:   # Once the `execute` method is called a `Promise` becomes `pending`:
// 128:   #
// 129:   # ```ruby
// 130:   # p = Concurrent::Promise.execute{ "Hello, world!" }
// 131:   # p.state    #=> :pending
// 132:   # p.pending? #=> true
// 133:   # ```
// 134:   #
// 135:   # Wait a little bit, and the promise will resolve and provide a value:
// 136:   #
// 137:   # ```ruby
// 138:   # p = Concurrent::Promise.execute{ "Hello, world!" }
// 139:   # sleep(0.1)
// 140:   #
// 141:   # p.state      #=> :fulfilled
// 142:   # p.fulfilled? #=> true
// 143:   # p.value      #=> "Hello, world!"
// 144:   # ```
// 145:   #
// 146:   # If an exception occurs, the promise will be rejected and will provide
// 147:   # a reason for the rejection:
// 148:   #
// 149:   # ```ruby
// 150:   # p = Concurrent::Promise.execute{ raise StandardError.new("Here comes the Boom!") }
// 151:   # sleep(0.1)
// 152:   #
// 153:   # p.state     #=> :rejected
// 154:   # p.rejected? #=> true
// 155:   # p.reason    #=> "#<StandardError: Here comes the Boom!>"
// 156:   # ```
// 157:   #
// 158:   # #### Rejection
// 159:   #
// 160:   # When a promise is rejected all its children will be rejected and will
// 161:   # receive the rejection `reason` as the rejection callable parameter:
// 162:   #
// 163:   # ```ruby
// 164:   # p = Concurrent::Promise.execute { Thread.pass; raise StandardError }
// 165:   #
// 166:   # c1 = p.then(-> reason { 42 })
// 167:   # c2 = p.then(-> reason { raise 'Boom!' })
// 168:   #
// 169:   # c1.wait.state  #=> :fulfilled
// 170:   # c1.value       #=> 42
// 171:   # c2.wait.state  #=> :rejected
// 172:   # c2.reason      #=> #<RuntimeError: Boom!>
// 173:   # ```
// 174:   #
// 175:   # Once a promise is rejected it will continue to accept children that will
// 176:   # receive immediately rejection (they will be executed asynchronously).
// 177:   #
// 178:   # #### Aliases
// 179:   #
// 180:   # The `then` method is the most generic alias: it accepts a block to be
// 181:   # executed upon parent fulfillment and a callable to be executed upon parent
// 182:   # rejection. At least one of them should be passed. The default block is `{
// 183:   # |result| result }` that fulfills the child with the parent value. The
// 184:   # default callable is `{ |reason| raise reason }` that rejects the child with
// 185:   # the parent reason.
// 186:   #
// 187:   # - `on_success { |result| ... }` is the same as `then {|result| ... }`
// 188:   # - `rescue { |reason| ... }` is the same as `then(Proc.new { |reason| ... } )`
// 189:   # - `rescue` is aliased by `catch` and `on_error`
// 190:   class Promise < IVar
// 191:
// 192:     # Initialize a new Promise with the provided options.
// 193:     #
// 194:     # @!macro executor_and_deref_options
// 195:     #
// 196:     # @!macro promise_init_options
// 197:     #
// 198:     #   @option opts [Promise] :parent the parent `Promise` when building a chain/tree
// 199:     #   @option opts [Proc] :on_fulfill fulfillment handler
// 200:     #   @option opts [Proc] :on_reject rejection handler
// 201:     #   @option opts [object, Array] :args zero or more arguments to be passed
// 202:     #    the task block on execution
// 203:     #
// 204:     # @yield The block operation to be performed asynchronously.
// 205:     #
// 206:     # @raise [ArgumentError] if no block is given
// 207:     #
// 208:     # @see http://wiki.commonjs.org/wiki/Promises/A
// 209:     # @see http://promises-aplus.github.io/promises-spec/
// 210:     def initialize(opts = {}, &block)
// 211:       opts.delete_if { |k, v| v.nil? }
// 212:       super(NULL, opts.merge(__promise_body_from_block__: block), &nil)
// 213:     end
// 214:
// 215:     # Create a new `Promise` and fulfill it immediately.
// 216:     #
// 217:     # @!macro executor_and_deref_options
// 218:     #
// 219:     # @!macro promise_init_options
// 220:     #
// 221:     # @raise [ArgumentError] if no block is given
// 222:     #
// 223:     # @return [Promise] the newly created `Promise`
// 224:     def self.fulfill(value, opts = {})
// 225:       Promise.new(opts).tap { |p| p.send(:synchronized_set_state!, true, value, nil) }
// 226:     end
// 227:
// 228:     # Create a new `Promise` and reject it immediately.
// 229:     #
// 230:     # @!macro executor_and_deref_options
// 231:     #
// 232:     # @!macro promise_init_options
// 233:     #
// 234:     # @raise [ArgumentError] if no block is given
// 235:     #
// 236:     # @return [Promise] the newly created `Promise`
// 237:     def self.reject(reason, opts = {})
// 238:       Promise.new(opts).tap { |p| p.send(:synchronized_set_state!, false, nil, reason) }
// 239:     end
// 240:
// 241:     # Execute an `:unscheduled` `Promise`. Immediately sets the state to `:pending` and
// 242:     # passes the block to a new thread/thread pool for eventual execution.
// 243:     # Does nothing if the `Promise` is in any state other than `:unscheduled`.
// 244:     #
// 245:     # @return [Promise] a reference to `self`
// 246:     def execute
// 247:       if root?
// 248:         if compare_and_set_state(:pending, :unscheduled)
// 249:           set_pending
// 250:           realize(@promise_body)
// 251:         end
// 252:       else
// 253:         compare_and_set_state(:pending, :unscheduled)
// 254:         @parent.execute
// 255:       end
// 256:       self
// 257:     end
// 258:
// 259:     # @!macro ivar_set_method
// 260:     #
// 261:     # @raise [Concurrent::PromiseExecutionError] if not the root promise
// 262:     def set(value = NULL, &block)
// 263:       raise PromiseExecutionError.new('supported only on root promise') unless root?
// 264:       check_for_block_or_value!(block_given?, value)
// 265:       synchronize do
// 266:         if @state != :unscheduled
// 267:           raise MultipleAssignmentError
// 268:         else
// 269:           @promise_body = block || Proc.new { |result| value }
// 270:         end
// 271:       end
// 272:       execute
// 273:     end
// 274:
// 275:     # @!macro ivar_fail_method
// 276:     #
// 277:     # @raise [Concurrent::PromiseExecutionError] if not the root promise
// 278:     def fail(reason = StandardError.new)
// 279:       set { raise reason }
// 280:     end
// 281:
// 282:     # Create a new `Promise` object with the given block, execute it, and return the
// 283:     # `:pending` object.
// 284:     #
// 285:     # @!macro executor_and_deref_options
// 286:     #
// 287:     # @!macro promise_init_options
// 288:     #
// 289:     # @return [Promise] the newly created `Promise` in the `:pending` state
// 290:     #
// 291:     # @raise [ArgumentError] if no block is given
// 292:     #
// 293:     # @example
// 294:     #   promise = Concurrent::Promise.execute{ sleep(1); 42 }
// 295:     #   promise.state #=> :pending
// 296:     def self.execute(opts = {}, &block)
// 297:       new(opts, &block).execute
// 298:     end
// 299:
// 300:     # Chain a new promise off the current promise.
// 301:     #
// 302:     # @return [Promise] the new promise
// 303:     # @yield The block operation to be performed asynchronously.
// 304:     # @overload then(rescuer, executor, &block)
// 305:     #   @param [Proc] rescuer An optional rescue block to be executed if the
// 306:     #     promise is rejected.
// 307:     #   @param [ThreadPool] executor An optional thread pool executor to be used
// 308:     #     in the new Promise
// 309:     # @overload then(rescuer, executor: executor, &block)
// 310:     #   @param [Proc] rescuer An optional rescue block to be executed if the
// 311:     #     promise is rejected.
// 312:     #   @param [ThreadPool] executor An optional thread pool executor to be used
// 313:     #     in the new Promise
// 314:     def then(*args, &block)
// 315:       if args.last.is_a?(::Hash)
// 316:         executor = args.pop[:executor]
// 317:         rescuer = args.first
// 318:       else
// 319:         rescuer, executor = args
// 320:       end
// 321:
// 322:       executor ||= @executor
// 323:
// 324:       raise ArgumentError.new('rescuers and block are both missing') if rescuer.nil? && !block_given?
// 325:       block = Proc.new { |result| result } unless block_given?
// 326:       child = Promise.new(
// 327:         parent: self,
// 328:         executor: executor,
// 329:         on_fulfill: block,
// 330:         on_reject: rescuer
// 331:       )
// 332:
// 333:       synchronize do
// 334:         child.state = :pending if @state == :pending
// 335:         child.on_fulfill(apply_deref_options(@value)) if @state == :fulfilled
// 336:         child.on_reject(@reason) if @state == :rejected
// 337:         @children << child
// 338:       end
// 339:
// 340:       child
// 341:     end
// 342:
// 343:     # Chain onto this promise an action to be undertaken on success
// 344:     # (fulfillment).
// 345:     #
// 346:     # @yield The block to execute
// 347:     #
// 348:     # @return [Promise] self
// 349:     def on_success(&block)
// 350:       raise ArgumentError.new('no block given') unless block_given?
// 351:       self.then(&block)
// 352:     end
// 353:
// 354:     # Chain onto this promise an action to be undertaken on failure
// 355:     # (rejection).
// 356:     #
// 357:     # @yield The block to execute
// 358:     #
// 359:     # @return [Promise] self
// 360:     def rescue(&block)
// 361:       self.then(block)
// 362:     end
// 363:
// 364:     alias_method :catch, :rescue
// 365:     alias_method :on_error, :rescue
// 366:
// 367:     # Yield the successful result to the block that returns a promise. If that
// 368:     # promise is also successful the result is the result of the yielded promise.
// 369:     # If either part fails the whole also fails.
// 370:     #
// 371:     # @example
// 372:     #   Promise.execute { 1 }.flat_map { |v| Promise.execute { v + 2 } }.value! #=> 3
// 373:     #
// 374:     # @return [Promise]
// 375:     def flat_map(&block)
// 376:       child = Promise.new(
// 377:         parent: self,
// 378:         executor: ImmediateExecutor.new,
// 379:       )
// 380:
// 381:       on_error { |e| child.on_reject(e) }
// 382:       on_success do |result1|
// 383:         begin
// 384:           inner = block.call(result1)
// 385:           inner.execute
// 386:           inner.on_success { |result2| child.on_fulfill(result2) }
// 387:           inner.on_error { |e| child.on_reject(e) }
// 388:         rescue => e
// 389:           child.on_reject(e)
// 390:         end
// 391:       end
// 392:
// 393:       child
// 394:     end
// 395:
// 396:     # Builds a promise that produces the result of promises in an Array
// 397:     # and fails if any of them fails.
// 398:     #
// 399:     # @overload zip(*promises)
// 400:     #   @param [Array<Promise>] promises
// 401:     #
// 402:     # @overload zip(*promises, opts)
// 403:     #   @param [Array<Promise>] promises
// 404:     #   @param [Hash] opts the configuration options
// 405:     #   @option opts [Executor] :executor (ImmediateExecutor.new) when set use the given `Executor` instance.
// 406:     #   @option opts [Boolean] :execute (true) execute promise before returning
// 407:     #
// 408:     # @return [Promise<Array>]
// 409:     def self.zip(*promises)
// 410:       opts = promises.last.is_a?(::Hash) ? promises.pop.dup : {}
// 411:       opts[:executor] ||= ImmediateExecutor.new
// 412:       zero = if !opts.key?(:execute) || opts.delete(:execute)
// 413:         fulfill([], opts)
// 414:       else
// 415:         Promise.new(opts) { [] }
// 416:       end
// 417:
// 418:       promises.reduce(zero) do |p1, p2|
// 419:         p1.flat_map do |results|
// 420:           p2.then do |next_result|
// 421:             results << next_result
// 422:           end
// 423:         end
// 424:       end
// 425:     end
// 426:
// 427:     # Builds a promise that produces the result of self and others in an Array
// 428:     # and fails if any of them fails.
// 429:     #
// 430:     # @overload zip(*promises)
// 431:     #   @param [Array<Promise>] others
// 432:     #
// 433:     # @overload zip(*promises, opts)
// 434:     #   @param [Array<Promise>] others
// 435:     #   @param [Hash] opts the configuration options
// 436:     #   @option opts [Executor] :executor (ImmediateExecutor.new) when set use the given `Executor` instance.
// 437:     #   @option opts [Boolean] :execute (true) execute promise before returning
// 438:     #
// 439:     # @return [Promise<Array>]
// 440:     def zip(*others)
// 441:       self.class.zip(self, *others)
// 442:     end
// 443:
// 444:     # Aggregates a collection of promises and executes the `then` condition
// 445:     # if all aggregated promises succeed. Executes the `rescue` handler with
// 446:     # a `Concurrent::PromiseExecutionError` if any of the aggregated promises
// 447:     # fail. Upon execution will execute any of the aggregate promises that
// 448:     # were not already executed.
// 449:     #
// 450:     # @!macro promise_self_aggregate
// 451:     #
// 452:     #   The returned promise will not yet have been executed. Additional `#then`
// 453:     #   and `#rescue` handlers may still be provided. Once the returned promise
// 454:     #   is execute the aggregate promises will be also be executed (if they have
// 455:     #   not been executed already). The results of the aggregate promises will
// 456:     #   be checked upon completion. The necessary `#then` and `#rescue` blocks
// 457:     #   on the aggregating promise will then be executed as appropriate. If the
// 458:     #   `#rescue` handlers are executed the raises exception will be
// 459:     #   `Concurrent::PromiseExecutionError`.
// 460:     #
// 461:     #   @param [Array] promises Zero or more promises to aggregate
// 462:     #   @return [Promise] an unscheduled (not executed) promise that aggregates
// 463:     #     the promises given as arguments
// 464:     def self.all?(*promises)
// 465:       aggregate(:all?, *promises)
// 466:     end
// 467:
// 468:     # Aggregates a collection of promises and executes the `then` condition
// 469:     # if any aggregated promises succeed. Executes the `rescue` handler with
// 470:     # a `Concurrent::PromiseExecutionError` if any of the aggregated promises
// 471:     # fail. Upon execution will execute any of the aggregate promises that
// 472:     # were not already executed.
// 473:     #
// 474:     # @!macro promise_self_aggregate
// 475:     def self.any?(*promises)
// 476:       aggregate(:any?, *promises)
// 477:     end
// 478:
// 479:     protected
// 480:
// 481:     def ns_initialize(value, opts)
// 482:       super
// 483:
// 484:       @executor = Options.executor_from_options(opts) || Concurrent.global_io_executor
// 485:       @args = get_arguments_from(opts)
// 486:
// 487:       @parent = opts.fetch(:parent) { nil }
// 488:       @on_fulfill = opts.fetch(:on_fulfill) { Proc.new { |result| result } }
// 489:       @on_reject = opts.fetch(:on_reject) { Proc.new { |reason| raise reason } }
// 490:
// 491:       @promise_body = opts[:__promise_body_from_block__] || Proc.new { |result| result }
// 492:       @state = :unscheduled
// 493:       @children = []
// 494:     end
// 495:
// 496:     # Aggregate a collection of zero or more promises under a composite promise,
// 497:     # execute the aggregated promises and collect them into a standard Ruby array,
// 498:     # call the given Ruby `Ennnumerable` predicate (such as `any?`, `all?`, `none?`,
// 499:     # or `one?`) on the collection checking for the success or failure of each,
// 500:     # then executing the composite's `#then` handlers if the predicate returns
// 501:     # `true` or executing the composite's `#rescue` handlers if the predicate
// 502:     # returns false.
// 503:     #
// 504:     # @!macro promise_self_aggregate
// 505:     def self.aggregate(method, *promises)
// 506:       composite = Promise.new do
// 507:         completed = promises.collect do |promise|
// 508:           promise.execute if promise.unscheduled?
// 509:           promise.wait
// 510:           promise
// 511:         end
// 512:         unless completed.empty? || completed.send(method){|promise| promise.fulfilled? }
// 513:           raise PromiseExecutionError
// 514:         end
// 515:       end
// 516:       composite
// 517:     end
// 518:
// 519:     # @!visibility private
// 520:     def set_pending
// 521:       synchronize do
// 522:         @state = :pending
// 523:         @children.each { |c| c.set_pending }
// 524:       end
// 525:     end
// 526:
// 527:     # @!visibility private
// 528:     def root? # :nodoc:
// 529:       @parent.nil?
// 530:     end
// 531:
// 532:     # @!visibility private
// 533:     def on_fulfill(result)
// 534:       realize Proc.new { @on_fulfill.call(result) }
// 535:       nil
// 536:     end
// 537:
// 538:     # @!visibility private
// 539:     def on_reject(reason)
// 540:       realize Proc.new { @on_reject.call(reason) }
// 541:       nil
// 542:     end
// 543:
// 544:     # @!visibility private
// 545:     def notify_child(child)
// 546:       if_state(:fulfilled) { child.on_fulfill(apply_deref_options(@value)) }
// 547:       if_state(:rejected) { child.on_reject(@reason) }
// 548:     end
// 549:
// 550:     # @!visibility private
// 551:     def complete(success, value, reason)
// 552:       children_to_notify = synchronize do
// 553:         set_state!(success, value, reason)
// 554:         @children.dup
// 555:       end
// 556:
// 557:       children_to_notify.each { |child| notify_child(child) }
// 558:       observers.notify_and_delete_observers{ [Time.now, self.value, reason] }
// 559:     end
// 560:
// 561:     # @!visibility private
// 562:     def realize(task)
// 563:       @executor.post do
// 564:         success, value, reason = SafeTaskExecutor.new(task, rescue_exception: true).execute(*@args)
// 565:         complete(success, value, reason)
// 566:       end
// 567:     end
// 568:
// 569:     # @!visibility private
// 570:     def set_state!(success, value, reason)
// 571:       set_state(success, value, reason)
// 572:       event.set
// 573:     end
// 574:
// 575:     # @!visibility private
// 576:     def synchronized_set_state!(success, value, reason)
// 577:       synchronize { set_state!(success, value, reason) }
// 578:     end
// 579:   end
// 580: end
