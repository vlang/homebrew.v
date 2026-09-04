module concurrent

import ruby
import os
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/async.rb`.
// The original source is retained below until every stub has a typed V body.
pub type AsyncDelegate = fn(string, []ruby.Value) !ruby.Value

struct AsyncCall {
	ivar   &IVar
	method string
	args   []ruby.Value
}

@[heap]
pub struct AsyncDelegator {
	mutex     &sync.Mutex
	delegate  AsyncDelegate @[required]
	arities   map[string]int
	allow_any bool
mut:
	queue    []AsyncCall
	ruby_pid int
}

@[heap]
pub struct AwaitDelegator {
	delegate &AsyncDelegator
}

@[heap]
pub struct AsyncRuntime {
	async_delegator &AsyncDelegator
	await_delegator &AwaitDelegator
}

pub fn validate_async_argc(arities map[string]int, allow_any bool, method string, args []ruby.Value) ! {
	if method !in arities {
		if allow_any {
			return
		}
		return error('NameError: undefined method `${method}`')
	}
	argc := args.len
	mut arity := arities[method]
	if arity >= 0 && argc != arity {
		return error('ArgumentError: wrong number of arguments (${argc} for ${arity})')
	}
	if arity < 0 {
		arity = -(arity + 1)
		if arity > argc {
			return error('ArgumentError: wrong number of arguments (${argc} for ${arity}..*)')
		}
	}
}

pub fn new_async_delegator(delegate AsyncDelegate, arities map[string]int) &AsyncDelegator {
	return &AsyncDelegator{
		mutex: sync.new_mutex()
		delegate: delegate
		arities: arities.clone()
		ruby_pid: os.getpid()
	}
}

fn new_dynamic_async_delegator(delegate AsyncDelegate) &AsyncDelegator {
	return &AsyncDelegator{
		mutex: sync.new_mutex()
		delegate: delegate
		allow_any: true
		ruby_pid: os.getpid()
	}
}

pub fn new_await_delegator(delegate &AsyncDelegator) &AwaitDelegator {
	return &AwaitDelegator{
		delegate: delegate
	}
}

pub fn new_async_runtime(delegate AsyncDelegate, arities map[string]int) &AsyncRuntime {
	async_delegator := new_async_delegator(delegate, arities)
	return &AsyncRuntime{
		async_delegator: async_delegator
		await_delegator: new_await_delegator(async_delegator)
	}
}

fn new_dynamic_async_runtime(delegate AsyncDelegate) &AsyncRuntime {
	async_delegator := new_dynamic_async_delegator(delegate)
	return &AsyncRuntime{
		async_delegator: async_delegator
		await_delegator: new_await_delegator(async_delegator)
	}
}

fn perform_async_calls(mut delegator AsyncDelegator) {
	delegator.perform()
}

fn (mut delegator AsyncDelegator) reset_if_forked_locked() bool {
	current_pid := os.getpid()
	if current_pid == delegator.ruby_pid {
		return false
	}
	delegator.queue.clear()
	delegator.ruby_pid = current_pid
	return true
}

pub fn (mut delegator AsyncDelegator) reset_if_forked() bool {
	delegator.mutex.lock()
	reset := delegator.reset_if_forked_locked()
	delegator.mutex.unlock()
	return reset
}

pub fn (mut delegator AsyncDelegator) respond_to(method string) bool {
	return delegator.allow_any || method in delegator.arities
}

pub fn (mut delegator AsyncDelegator) post(method string, args []ruby.Value) !&IVar {
	validate_async_argc(delegator.arities, delegator.allow_any, method, args)!
	ivar := new_ivar()
	delegator.mutex.lock()
	delegator.reset_if_forked_locked()
	delegator.queue << AsyncCall{
		ivar: ivar
		method: method
		args: args.clone()
	}
	start_worker := delegator.queue.len == 1
	delegator.mutex.unlock()
	if start_worker {
		spawn perform_async_calls(mut delegator)
	}
	return ivar
}

pub fn (mut delegator AsyncDelegator) perform() {
	for {
		delegator.mutex.lock()
		if delegator.queue.len == 0 {
			delegator.mutex.unlock()
			return
		}
		call := delegator.queue[0]
		delegator.mutex.unlock()

		value := delegator.delegate(call.method, call.args) or {
			mut failed_ivar := call.ivar
			failed_ivar.fail(err.msg()) or { panic(err) }
			delegator.mutex.lock()
			if delegator.queue.len > 0 {
				delegator.queue.delete(0)
			}
			delegator.mutex.unlock()
			continue
		}
		mut successful_ivar := call.ivar
		successful_ivar.set(value) or { panic(err) }

		delegator.mutex.lock()
		if delegator.queue.len > 0 {
			delegator.queue.delete(0)
		}
		empty := delegator.queue.len == 0
		delegator.mutex.unlock()
		if empty {
			return
		}
	}
}

pub fn (mut delegator AwaitDelegator) call(method string, args []ruby.Value) !&IVar {
	mut async_delegator := delegator.delegate
	mut ivar := async_delegator.post(method, args)!
	ivar.wait(none)
	return ivar
}

pub fn (mut delegator AwaitDelegator) respond_to(method string) bool {
	mut async_delegator := delegator.delegate
	return async_delegator.respond_to(method)
}

pub fn (runtime &AsyncRuntime) async_proxy() &AsyncDelegator {
	return runtime.async_delegator
}

pub fn (runtime &AsyncRuntime) cast() &AsyncDelegator {
	return runtime.async_proxy()
}

pub fn (runtime &AsyncRuntime) await_proxy() &AwaitDelegator {
	return runtime.await_delegator
}

pub fn (runtime &AsyncRuntime) call_proxy() &AwaitDelegator {
	return runtime.await_proxy()
}

fn async_delegator_boundary_value(delegator &AsyncDelegator) ruby.Value {
	return ruby.structured_value('Concurrent::Async::AsyncDelegator', '#<Concurrent::Async::AsyncDelegator>', {
		'async_delegator_address': u64(voidptr(delegator)).str()
	})
}

fn async_delegator_boundary_receiver(args []ruby.Value) &AsyncDelegator {
	if args.len == 0 {
		panic('AsyncDelegator method requires a receiver')
	}
	address := (args[0].attribute('async_delegator_address') or {
		panic('${args[0].type_name} has no translated AsyncDelegator state')
	}).u64()
	return unsafe { &AsyncDelegator(voidptr(address)) }
}

fn await_delegator_boundary_value(delegator &AwaitDelegator) ruby.Value {
	return ruby.structured_value('Concurrent::Async::AwaitDelegator', '#<Concurrent::Async::AwaitDelegator>', {
		'await_delegator_address': u64(voidptr(delegator)).str()
	})
}

fn await_delegator_boundary_receiver(args []ruby.Value) &AwaitDelegator {
	if args.len == 0 {
		panic('AwaitDelegator method requires a receiver')
	}
	address := (args[0].attribute('await_delegator_address') or {
		panic('${args[0].type_name} has no translated AwaitDelegator state')
	}).u64()
	return unsafe { &AwaitDelegator(voidptr(address)) }
}

fn async_runtime_boundary_value(runtime &AsyncRuntime) ruby.Value {
	return ruby.structured_value('Concurrent::Async::Runtime', '#<Concurrent::Async>', {
		'async_runtime_address': u64(voidptr(runtime)).str()
	})
}

fn async_runtime_boundary_receiver(args []ruby.Value) &AsyncRuntime {
	if args.len == 0 {
		panic('Async method requires a receiver')
	}
	address := (args[0].attribute('async_runtime_address') or {
		panic('${args[0].type_name} has no translated Async state')
	}).u64()
	return unsafe { &AsyncRuntime(voidptr(address)) }
}

fn async_boundary_delegate(_ string, args []ruby.Value) !ruby.Value {
	return if args.len > 0 { args[args.len - 1] } else { ivar_nil_value() }
}

fn async_boundary_method(args []ruby.Value) string {
	if args.len < 2 {
		panic('method_missing requires a method')
	}
	return args[1].as_string().trim_left(':')
}

// Ruby method `self.validate_argc(obj, method, *args)` at line 250.
pub fn ruby_async_l250_d1_self_validate_argc(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('validate_argc requires an object and method')
	}
	method := args[1].as_string().trim_left(':')
	attribute := args[0].attribute('arity:${method}') or { '' }
	if attribute.len == 0 {
		return ivar_nil_value()
	}
	validate_async_argc({
		method: attribute.int()
	}, false, method, args[2..]) or { panic(err) }
	return ivar_nil_value()
}

// Ruby method `self.included(base)` at line 262.
pub fn ruby_async_l262_d2_self_included(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('included requires a base')
	}
	return args[0]
}

// Ruby alias_method `base.singleton_class.send(:alias_method, :original_new, :new)` at line 263.
pub fn ruby_async_l263_d3_original_new(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ivar_nil_value() }
}

// Ruby method `new(*args, &block)` at line 270.
pub fn ruby_async_l270_d4_new(args ...ruby.Value) ruby.Value {
	return async_runtime_boundary_value(new_dynamic_async_runtime(async_boundary_delegate))
}

// Ruby method `initialize(delegate)` at line 288.
pub fn ruby_async_l288_d5_initialize(args ...ruby.Value) ruby.Value {
	return async_delegator_boundary_value(new_dynamic_async_delegator(async_boundary_delegate))
}

// Ruby method `method_missing(method, *args, &block)` at line 305.
pub fn ruby_async_l305_d6_method_missing(args ...ruby.Value) ruby.Value {
	mut delegator := async_delegator_boundary_receiver(args)
	method := async_boundary_method(args)
	ivar := delegator.post(method, args[2..]) or { panic(err) }
	return ivar_boundary_value(ivar)
}

// Ruby method `respond_to_missing?(method, include_private = false)` at line 322.
pub fn ruby_async_l322_d7_respond_to_missing(args ...ruby.Value) ruby.Value {
	mut delegator := async_delegator_boundary_receiver(args)
	return ruby.bool_value(delegator.respond_to(async_boundary_method(args)))
}

// Ruby method `perform` at line 330.
pub fn ruby_async_l330_d8_perform(args ...ruby.Value) ruby.Value {
	mut delegator := async_delegator_boundary_receiver(args)
	delegator.perform()
	return ivar_nil_value()
}

// Ruby method `reset_if_forked` at line 348.
pub fn ruby_async_l348_d9_reset_if_forked(args ...ruby.Value) ruby.Value {
	mut delegator := async_delegator_boundary_receiver(args)
	delegator.reset_if_forked()
	return ivar_nil_value()
}

// Ruby method `initialize(delegate)` at line 365.
pub fn ruby_async_l365_d10_initialize(args ...ruby.Value) ruby.Value {
	delegator := async_delegator_boundary_receiver(args)
	return await_delegator_boundary_value(new_await_delegator(delegator))
}

// Ruby method `method_missing(method, *args, &block)` at line 378.
pub fn ruby_async_l378_d11_method_missing(args ...ruby.Value) ruby.Value {
	mut delegator := await_delegator_boundary_receiver(args)
	method := async_boundary_method(args)
	ivar := delegator.call(method, args[2..]) or { panic(err) }
	return ivar_boundary_value(ivar)
}

// Ruby method `respond_to_missing?(method, include_private = false)` at line 387.
pub fn ruby_async_l387_d12_respond_to_missing(args ...ruby.Value) ruby.Value {
	mut delegator := await_delegator_boundary_receiver(args)
	return ruby.bool_value(delegator.respond_to(async_boundary_method(args)))
}

// Ruby method `async` at line 412.
pub fn ruby_async_l412_d13_async(args ...ruby.Value) ruby.Value {
	runtime := async_runtime_boundary_receiver(args)
	return async_delegator_boundary_value(runtime.async_proxy())
}

// Ruby alias_method `alias_method :cast, :async` at line 415.
pub fn ruby_async_l415_d14_cast(args ...ruby.Value) ruby.Value {
	return ruby_async_l412_d13_async(...args)
}

// Ruby method `await` at line 430.
pub fn ruby_async_l430_d15_await(args ...ruby.Value) ruby.Value {
	runtime := async_runtime_boundary_receiver(args)
	return await_delegator_boundary_value(runtime.await_proxy())
}

// Ruby alias_method `alias_method :call, :await` at line 433.
pub fn ruby_async_l433_d16_call(args ...ruby.Value) ruby.Value {
	return ruby_async_l430_d15_await(...args)
}

// Ruby method `init_synchronization` at line 441.
pub fn ruby_async_l441_d17_init_synchronization(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].type_name == 'Concurrent::Async::Runtime' {
		return args[0]
	}
	return async_runtime_boundary_value(new_dynamic_async_runtime(async_boundary_delegate))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/configuration'
// 2: require 'concurrent/ivar'
// 3: require 'concurrent/synchronization/lockable_object'
// 4:
// 5: module Concurrent
// 6:
// 7:   # A mixin module that provides simple asynchronous behavior to a class,
// 8:   # turning it into a simple actor. Loosely based on Erlang's
// 9:   # [gen_server](http://www.erlang.org/doc/man/gen_server.html), but without
// 10:   # supervision or linking.
// 11:   #
// 12:   # A more feature-rich {Concurrent::Actor} is also available when the
// 13:   # capabilities of `Async` are too limited.
// 14:   #
// 15:   # ```cucumber
// 16:   # Feature:
// 17:   #   As a stateful, plain old Ruby class
// 18:   #   I want safe, asynchronous behavior
// 19:   #   So my long-running methods don't block the main thread
// 20:   # ```
// 21:   #
// 22:   # The `Async` module is a way to mix simple yet powerful asynchronous
// 23:   # capabilities into any plain old Ruby object or class, turning each object
// 24:   # into a simple Actor. Method calls are processed on a background thread. The
// 25:   # caller is free to perform other actions while processing occurs in the
// 26:   # background.
// 27:   #
// 28:   # Method calls to the asynchronous object are made via two proxy methods:
// 29:   # `async` (alias `cast`) and `await` (alias `call`). These proxy methods post
// 30:   # the method call to the object's background thread and return a "future"
// 31:   # which will eventually contain the result of the method call.
// 32:   #
// 33:   # This behavior is loosely patterned after Erlang's `gen_server` behavior.
// 34:   # When an Erlang module implements the `gen_server` behavior it becomes
// 35:   # inherently asynchronous. The `start` or `start_link` function spawns a
// 36:   # process (similar to a thread but much more lightweight and efficient) and
// 37:   # returns the ID of the process. Using the process ID, other processes can
// 38:   # send messages to the `gen_server` via the `cast` and `call` methods. Unlike
// 39:   # Erlang's `gen_server`, however, `Async` classes do not support linking or
// 40:   # supervision trees.
// 41:   #
// 42:   # ## Basic Usage
// 43:   #
// 44:   # When this module is mixed into a class, objects of the class become inherently
// 45:   # asynchronous. Each object gets its own background thread on which to post
// 46:   # asynchronous method calls. Asynchronous method calls are executed in the
// 47:   # background one at a time in the order they are received.
// 48:   #
// 49:   # To create an asynchronous class, simply mix in the `Concurrent::Async` module:
// 50:   #
// 51:   # ```
// 52:   # class Hello
// 53:   #   include Concurrent::Async
// 54:   #
// 55:   #   def hello(name)
// 56:   #     "Hello, #{name}!"
// 57:   #   end
// 58:   # end
// 59:   # ```
// 60:   #
// 61:   # Mixing this module into a class provides each object two proxy methods:
// 62:   # `async` and `await`. These methods are thread safe with respect to the
// 63:   # enclosing object. The former proxy allows methods to be called
// 64:   # asynchronously by posting to the object's internal thread. The latter proxy
// 65:   # allows a method to be called synchronously but does so safely with respect
// 66:   # to any pending asynchronous method calls and ensures proper ordering. Both
// 67:   # methods return a {Concurrent::IVar} which can be inspected for the result
// 68:   # of the proxied method call. Calling a method with `async` will return a
// 69:   # `:pending` `IVar` whereas `await` will return a `:complete` `IVar`.
// 70:   #
// 71:   # ```
// 72:   # class Echo
// 73:   #   include Concurrent::Async
// 74:   #
// 75:   #   def echo(msg)
// 76:   #     print "#{msg}\n"
// 77:   #   end
// 78:   # end
// 79:   #
// 80:   # horn = Echo.new
// 81:   # horn.echo('zero')      # synchronous, not thread-safe
// 82:   #                        # returns the actual return value of the method
// 83:   #
// 84:   # horn.async.echo('one') # asynchronous, non-blocking, thread-safe
// 85:   #                        # returns an IVar in the :pending state
// 86:   #
// 87:   # horn.await.echo('two') # synchronous, blocking, thread-safe
// 88:   #                        # returns an IVar in the :complete state
// 89:   # ```
// 90:   #
// 91:   # ## Let It Fail
// 92:   #
// 93:   # The `async` and `await` proxy methods have built-in error protection based
// 94:   # on Erlang's famous "let it fail" philosophy. Instance methods should not be
// 95:   # programmed defensively. When an exception is raised by a delegated method
// 96:   # the proxy will rescue the exception, expose it to the caller as the `reason`
// 97:   # attribute of the returned future, then process the next method call.
// 98:   #
// 99:   # ## Calling Methods Internally
// 100:   #
// 101:   # External method calls should *always* use the `async` and `await` proxy
// 102:   # methods. When one method calls another method, the `async` proxy should
// 103:   # rarely be used and the `await` proxy should *never* be used.
// 104:   #
// 105:   # When an object calls one of its own methods using the `await` proxy the
// 106:   # second call will be enqueued *behind* the currently running method call.
// 107:   # Any attempt to wait on the result will fail as the second call will never
// 108:   # run until after the current call completes.
// 109:   #
// 110:   # Calling a method using the `await` proxy from within a method that was
// 111:   # itself called using `async` or `await` will irreversibly deadlock the
// 112:   # object. Do *not* do this, ever.
// 113:   #
// 114:   # ## Instance Variables and Attribute Accessors
// 115:   #
// 116:   # Instance variables do not need to be thread-safe so long as they are private.
// 117:   # Asynchronous method calls are processed in the order they are received and
// 118:   # are processed one at a time. Therefore private instance variables can only
// 119:   # be accessed by one thread at a time. This is inherently thread-safe.
// 120:   #
// 121:   # When using private instance variables within asynchronous methods, the best
// 122:   # practice is to read the instance variable into a local variable at the start
// 123:   # of the method then update the instance variable at the *end* of the method.
// 124:   # This way, should an exception be raised during method execution the internal
// 125:   # state of the object will not have been changed.
// 126:   #
// 127:   # ### Reader Attributes
// 128:   #
// 129:   # The use of `attr_reader` is discouraged. Internal state exposed externally,
// 130:   # when necessary, should be done through accessor methods. The instance
// 131:   # variables exposed by these methods *must* be thread-safe, or they must be
// 132:   # called using the `async` and `await` proxy methods. These two approaches are
// 133:   # subtly different.
// 134:   #
// 135:   # When internal state is accessed via the `async` and `await` proxy methods,
// 136:   # the returned value represents the object's state *at the time the call is
// 137:   # processed*, which may *not* be the state of the object at the time the call
// 138:   # is made.
// 139:   #
// 140:   # To get the state *at the current* time, irrespective of an enqueued method
// 141:   # calls, a reader method must be called directly. This is inherently unsafe
// 142:   # unless the instance variable is itself thread-safe, preferably using one
// 143:   # of the thread-safe classes within this library. Because the thread-safe
// 144:   # classes within this library are internally-locking or non-locking, they can
// 145:   # be safely used from within asynchronous methods without causing deadlocks.
// 146:   #
// 147:   # Generally speaking, the best practice is to *not* expose internal state via
// 148:   # reader methods. The best practice is to simply use the method's return value.
// 149:   #
// 150:   # ### Writer Attributes
// 151:   #
// 152:   # Writer attributes should never be used with asynchronous classes. Changing
// 153:   # the state externally, even when done in the thread-safe way, is not logically
// 154:   # consistent. Changes to state need to be timed with respect to all asynchronous
// 155:   # method calls which my be in-process or enqueued. The only safe practice is to
// 156:   # pass all necessary data to each method as arguments and let the method update
// 157:   # the internal state as necessary.
// 158:   #
// 159:   # ## Class Constants, Variables, and Methods
// 160:   #
// 161:   # ### Class Constants
// 162:   #
// 163:   # Class constants do not need to be thread-safe. Since they are read-only and
// 164:   # immutable they may be safely read both externally and from within
// 165:   # asynchronous methods.
// 166:   #
// 167:   # ### Class Variables
// 168:   #
// 169:   # Class variables should be avoided. Class variables represent shared state.
// 170:   # Shared state is anathema to concurrency. Should there be a need to share
// 171:   # state using class variables they *must* be thread-safe, preferably
// 172:   # using the thread-safe classes within this library. When updating class
// 173:   # variables, never assign a new value/object to the variable itself. Assignment
// 174:   # is not thread-safe in Ruby. Instead, use the thread-safe update functions
// 175:   # of the variable itself to change the value.
// 176:   #
// 177:   # The best practice is to *never* use class variables with `Async` classes.
// 178:   #
// 179:   # ### Class Methods
// 180:   #
// 181:   # Class methods which are pure functions are safe. Class methods which modify
// 182:   # class variables should be avoided, for all the reasons listed above.
// 183:   #
// 184:   # ## An Important Note About Thread Safe Guarantees
// 185:   #
// 186:   # > Thread safe guarantees can only be made when asynchronous method calls
// 187:   # > are not mixed with direct method calls. Use only direct method calls
// 188:   # > when the object is used exclusively on a single thread. Use only
// 189:   # > `async` and `await` when the object is shared between threads. Once you
// 190:   # > call a method using `async` or `await`, you should no longer call methods
// 191:   # > directly on the object. Use `async` and `await` exclusively from then on.
// 192:   #
// 193:   # @example
// 194:   #
// 195:   #   class Echo
// 196:   #     include Concurrent::Async
// 197:   #
// 198:   #     def echo(msg)
// 199:   #       print "#{msg}\n"
// 200:   #     end
// 201:   #   end
// 202:   #
// 203:   #   horn = Echo.new
// 204:   #   horn.echo('zero')      # synchronous, not thread-safe
// 205:   #                          # returns the actual return value of the method
// 206:   #
// 207:   #   horn.async.echo('one') # asynchronous, non-blocking, thread-safe
// 208:   #                          # returns an IVar in the :pending state
// 209:   #
// 210:   #   horn.await.echo('two') # synchronous, blocking, thread-safe
// 211:   #                          # returns an IVar in the :complete state
// 212:   #
// 213:   # @see Concurrent::Actor
// 214:   # @see https://en.wikipedia.org/wiki/Actor_model "Actor Model" at Wikipedia
// 215:   # @see http://www.erlang.org/doc/man/gen_server.html Erlang gen_server
// 216:   # @see http://c2.com/cgi/wiki?LetItCrash "Let It Crash" at http://c2.com/
// 217:   module Async
// 218:
// 219:     # @!method self.new(*args, &block)
// 220:     #
// 221:     #   Instantiate a new object and ensure proper initialization of the
// 222:     #   synchronization mechanisms.
// 223:     #
// 224:     #   @param [Array<Object>] args Zero or more arguments to be passed to the
// 225:     #     object's initializer.
// 226:     #   @param [Proc] block Optional block to pass to the object's initializer.
// 227:     #   @return [Object] A properly initialized object of the asynchronous class.
// 228:
// 229:     # Check for the presence of a method on an object and determine if a given
// 230:     # set of arguments matches the required arity.
// 231:     #
// 232:     # @param [Object] obj the object to check against
// 233:     # @param [Symbol] method the method to check the object for
// 234:     # @param [Array] args zero or more arguments for the arity check
// 235:     #
// 236:     # @raise [NameError] the object does not respond to `method` method
// 237:     # @raise [ArgumentError] the given `args` do not match the arity of `method`
// 238:     #
// 239:     # @note This check is imperfect because of the way Ruby reports the arity of
// 240:     #   methods with a variable number of arguments. It is possible to determine
// 241:     #   if too few arguments are given but impossible to determine if too many
// 242:     #   arguments are given. This check may also fail to recognize dynamic behavior
// 243:     #   of the object, such as methods simulated with `method_missing`.
// 244:     #
// 245:     # @see http://www.ruby-doc.org/core-2.1.1/Method.html#method-i-arity Method#arity
// 246:     # @see http://ruby-doc.org/core-2.1.0/Object.html#method-i-respond_to-3F Object#respond_to?
// 247:     # @see http://www.ruby-doc.org/core-2.1.0/BasicObject.html#method-i-method_missing BasicObject#method_missing
// 248:     #
// 249:     # @!visibility private
// 250:     def self.validate_argc(obj, method, *args)
// 251:       argc = args.length
// 252:       arity = obj.method(method).arity
// 253:
// 254:       if arity >= 0 && argc != arity
// 255:         raise ArgumentError.new("wrong number of arguments (#{argc} for #{arity})")
// 256:       elsif arity < 0 && (arity = (arity + 1).abs) > argc
// 257:         raise ArgumentError.new("wrong number of arguments (#{argc} for #{arity}..*)")
// 258:       end
// 259:     end
// 260:
// 261:     # @!visibility private
// 262:     def self.included(base)
// 263:       base.singleton_class.send(:alias_method, :original_new, :new)
// 264:       base.extend(ClassMethods)
// 265:       super(base)
// 266:     end
// 267:
// 268:     # @!visibility private
// 269:     module ClassMethods
// 270:       def new(*args, &block)
// 271:         obj = original_new(*args, &block)
// 272:         obj.send(:init_synchronization)
// 273:         obj
// 274:       end
// 275:       ruby2_keywords :new if respond_to?(:ruby2_keywords, true)
// 276:     end
// 277:     private_constant :ClassMethods
// 278:
// 279:     # Delegates asynchronous, thread-safe method calls to the wrapped object.
// 280:     #
// 281:     # @!visibility private
// 282:     class AsyncDelegator < Synchronization::LockableObject
// 283:       safe_initialization!
// 284:
// 285:       # Create a new delegator object wrapping the given delegate.
// 286:       #
// 287:       # @param [Object] delegate the object to wrap and delegate method calls to
// 288:       def initialize(delegate)
// 289:         super()
// 290:         @delegate = delegate
// 291:         @queue = []
// 292:         @executor = Concurrent.global_io_executor
// 293:         @ruby_pid = $$
// 294:       end
// 295:
// 296:       # Delegates method calls to the wrapped object.
// 297:       #
// 298:       # @param [Symbol] method the method being called
// 299:       # @param [Array] args zero or more arguments to the method
// 300:       #
// 301:       # @return [IVar] the result of the method call
// 302:       #
// 303:       # @raise [NameError] the object does not respond to `method` method
// 304:       # @raise [ArgumentError] the given `args` do not match the arity of `method`
// 305:       def method_missing(method, *args, &block)
// 306:         super unless @delegate.respond_to?(method)
// 307:         Async::validate_argc(@delegate, method, *args)
// 308:
// 309:         ivar = Concurrent::IVar.new
// 310:         synchronize do
// 311:           reset_if_forked
// 312:           @queue.push [ivar, method, args, block]
// 313:           @executor.post { perform } if @queue.length == 1
// 314:         end
// 315:
// 316:         ivar
// 317:       end
// 318:
// 319:       # Check whether the method is responsive
// 320:       #
// 321:       # @param [Symbol] method the method being called
// 322:       def respond_to_missing?(method, include_private = false)
// 323:         @delegate.respond_to?(method) || super
// 324:       end
// 325:
// 326:       # Perform all enqueued tasks.
// 327:       #
// 328:       # This method must be called from within the executor. It must not be
// 329:       # called while already running. It will loop until the queue is empty.
// 330:       def perform
// 331:         loop do
// 332:           ivar, method, args, block = synchronize { @queue.first }
// 333:           break unless ivar # queue is empty
// 334:
// 335:           begin
// 336:             ivar.set(@delegate.send(method, *args, &block))
// 337:           rescue => error
// 338:             ivar.fail(error)
// 339:           end
// 340:
// 341:           synchronize do
// 342:             @queue.shift
// 343:             return if @queue.empty?
// 344:           end
// 345:         end
// 346:       end
// 347:
// 348:       def reset_if_forked
// 349:         if $$ != @ruby_pid
// 350:           @queue.clear
// 351:           @ruby_pid = $$
// 352:         end
// 353:       end
// 354:     end
// 355:     private_constant :AsyncDelegator
// 356:
// 357:     # Delegates synchronous, thread-safe method calls to the wrapped object.
// 358:     #
// 359:     # @!visibility private
// 360:     class AwaitDelegator
// 361:
// 362:       # Create a new delegator object wrapping the given delegate.
// 363:       #
// 364:       # @param [AsyncDelegator] delegate the object to wrap and delegate method calls to
// 365:       def initialize(delegate)
// 366:         @delegate = delegate
// 367:       end
// 368:
// 369:       # Delegates method calls to the wrapped object.
// 370:       #
// 371:       # @param [Symbol] method the method being called
// 372:       # @param [Array] args zero or more arguments to the method
// 373:       #
// 374:       # @return [IVar] the result of the method call
// 375:       #
// 376:       # @raise [NameError] the object does not respond to `method` method
// 377:       # @raise [ArgumentError] the given `args` do not match the arity of `method`
// 378:       def method_missing(method, *args, &block)
// 379:         ivar = @delegate.send(method, *args, &block)
// 380:         ivar.wait
// 381:         ivar
// 382:       end
// 383:
// 384:       # Check whether the method is responsive
// 385:       #
// 386:       # @param [Symbol] method the method being called
// 387:       def respond_to_missing?(method, include_private = false)
// 388:         @delegate.respond_to?(method) || super
// 389:       end
// 390:     end
// 391:     private_constant :AwaitDelegator
// 392:
// 393:     # Causes the chained method call to be performed asynchronously on the
// 394:     # object's thread. The delegated method will return a future in the
// 395:     # `:pending` state and the method call will have been scheduled on the
// 396:     # object's thread. The final disposition of the method call can be obtained
// 397:     # by inspecting the returned future.
// 398:     #
// 399:     # @!macro async_thread_safety_warning
// 400:     #   @note The method call is guaranteed to be thread safe with respect to
// 401:     #     all other method calls against the same object that are called with
// 402:     #     either `async` or `await`. The mutable nature of Ruby references
// 403:     #     (and object orientation in general) prevent any other thread safety
// 404:     #     guarantees. Do NOT mix direct method calls with delegated method calls.
// 405:     #     Use *only* delegated method calls when sharing the object between threads.
// 406:     #
// 407:     # @return [Concurrent::IVar] the pending result of the asynchronous operation
// 408:     #
// 409:     # @raise [NameError] the object does not respond to the requested method
// 410:     # @raise [ArgumentError] the given `args` do not match the arity of
// 411:     #   the requested method
// 412:     def async
// 413:       @__async_delegator__
// 414:     end
// 415:     alias_method :cast, :async
// 416:
// 417:     # Causes the chained method call to be performed synchronously on the
// 418:     # current thread. The delegated will return a future in either the
// 419:     # `:fulfilled` or `:rejected` state and the delegated method will have
// 420:     # completed. The final disposition of the delegated method can be obtained
// 421:     # by inspecting the returned future.
// 422:     #
// 423:     # @!macro async_thread_safety_warning
// 424:     #
// 425:     # @return [Concurrent::IVar] the completed result of the synchronous operation
// 426:     #
// 427:     # @raise [NameError] the object does not respond to the requested method
// 428:     # @raise [ArgumentError] the given `args` do not match the arity of the
// 429:     #   requested method
// 430:     def await
// 431:       @__await_delegator__
// 432:     end
// 433:     alias_method :call, :await
// 434:
// 435:     # Initialize the internal serializer and other stnchronization mechanisms.
// 436:     #
// 437:     # @note This method *must* be called immediately upon object construction.
// 438:     #   This is the only way thread-safe initialization can be guaranteed.
// 439:     #
// 440:     # @!visibility private
// 441:     def init_synchronization
// 442:       return self if defined?(@__async_initialized__) && @__async_initialized__
// 443:       @__async_initialized__ = true
// 444:       @__async_delegator__ = AsyncDelegator.new(self)
// 445:       @__await_delegator__ = AwaitDelegator.new(@__async_delegator__)
// 446:       self
// 447:     end
// 448:   end
// 449: end
