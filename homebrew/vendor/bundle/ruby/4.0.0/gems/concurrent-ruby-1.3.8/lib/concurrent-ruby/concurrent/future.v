module concurrent

import brew_runtime
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/future.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum FutureExecutorMode {
	async
	immediate
	deferred
}

@[heap]
pub struct Future {
	mode FutureExecutorMode
mut:
	ivar &IVar
	task IVarTask @[required]
	args []brew_runtime.Value
}

pub fn new_future(task IVarTask, args []brew_runtime.Value) &Future {
	return new_future_with_mode(task, args, .async)
}

pub fn new_future_with_mode(task IVarTask, args []brew_runtime.Value, mode FutureExecutorMode) &Future {
	mut ivar := new_ivar_with_options(IVarOptions{
		args: args.clone()
	})
	ivar.set_state(.unscheduled)
	return &Future{
		ivar: ivar
		mode: mode
		task: task
		args: args.clone()
	}
}

fn run_future(mut future Future) {
	future.run()
}

pub fn (mut future Future) run() bool {
	return future.ivar.safe_execute(future.task, future.args, none)
}

fn (mut future Future) dispatch() {
	match future.mode {
		.async { spawn run_future(mut future) }
		.immediate { future.run() }
		.deferred {}
	}
}

pub fn (mut future Future) execute() bool {
	if !future.ivar.compare_and_set_state(.pending, [.unscheduled]) {
		return false
	}
	future.dispatch()
	return true
}

pub fn execute_future(task IVarTask, args []brew_runtime.Value) &Future {
	mut future := new_future(task, args)
	future.execute()
	return future
}

pub fn (mut future Future) set(value brew_runtime.Value) !&Future {
	return future.set_task(future_value_task, [value])
}

pub fn (mut future Future) set_task(task IVarTask, args []brew_runtime.Value) !&Future {
	future.ivar.data.mutex.lock()
	if future.ivar.data.state != .unscheduled {
		future.ivar.data.mutex.unlock()
		return error('MultipleAssignmentError')
	}
	future.task = task
	future.args = args.clone()
	future.ivar.data.state = .pending
	future.ivar.data.mutex.unlock()
	future.dispatch()
	return future
}

fn future_value_task(args []brew_runtime.Value) !brew_runtime.Value {
	return if args.len > 0 { args[0] } else { ivar_nil_value() }
}

pub fn (mut future Future) cancel() bool {
	if !future.ivar.compare_and_set_state(.cancelled, [.pending]) {
		return false
	}
	// The Ruby implementation immediately completes the cancelled operation as a
	// rejection, so its observable final state is `rejected` with this reason.
	future.ivar.complete(false, ivar_nil_value(), 'CancelledOperationError') or { panic(err) }
	return true
}

pub fn (mut future Future) cancelled() bool {
	return future.ivar.state() == .cancelled
}

pub fn (mut future Future) wait_or_cancel(timeout time.Duration) bool {
	future.ivar.wait(timeout)
	if future.ivar.is_complete() {
		return true
	}
	future.cancel()
	return false
}

pub fn (mut future Future) state() IVarState {
	return future.ivar.state()
}

pub fn (mut future Future) value(timeout ?time.Duration) brew_runtime.Value {
	return future.ivar.value(timeout)
}

pub fn (mut future Future) value_or_error(timeout ?time.Duration) !brew_runtime.Value {
	return future.ivar.value_or_error(timeout)
}

pub fn (mut future Future) reason() string {
	return future.ivar.reason()
}

fn future_boundary_value(future &Future) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::Future', '#<Concurrent::Future>', {
		'future_address': u64(voidptr(future)).str()
	})
}

fn future_boundary_receiver(args []brew_runtime.Value) &Future {
	if args.len == 0 {
		panic('Future method requires a receiver')
	}
	address := (args[0].attribute('future_address') or {
		panic('${args[0].type_name} has no translated Future state')
	}).u64()
	return unsafe { &Future(voidptr(address)) }
}

fn future_boundary_timeout(value brew_runtime.Value) time.Duration {
	return time.Duration((value.as_float() or { panic(err) }) * f64(time.second))
}

// Ruby method `initialize(opts = {}, &block)` at line 33.
pub fn ruby_future_l33_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	return future_boundary_value(new_future(future_value_task, [args[args.len - 1]]))
}

// Ruby method `execute` at line 53.
pub fn ruby_future_l53_d2_execute(args ...brew_runtime.Value) brew_runtime.Value {
	mut future := future_boundary_receiver(args)
	return if future.execute() { args[0] } else { ivar_nil_value() }
}

// Ruby method `self.execute(opts = {}, &block)` at line 77.
pub fn ruby_future_l77_d3_self_execute(args ...brew_runtime.Value) brew_runtime.Value {
	value := ruby_future_l33_d1_initialize(...args)
	return ruby_future_l53_d2_execute(value)
}

// Ruby method `set(value = NULL, &block)` at line 82.
pub fn ruby_future_l82_d4_set(args ...brew_runtime.Value) brew_runtime.Value {
	mut future := future_boundary_receiver(args)
	if args.len < 2 {
		panic('ArgumentError: must set with either a value or a block')
	}
	future.set(args[1]) or { panic(err) }
	return args[0]
}

// Ruby method `cancel` at line 99.
pub fn ruby_future_l99_d5_cancel(args ...brew_runtime.Value) brew_runtime.Value {
	mut future := future_boundary_receiver(args)
	return brew_runtime.bool_value(future.cancel())
}

// Ruby method `cancelled?` at line 111.
pub fn ruby_future_l111_d6_cancelled(args ...brew_runtime.Value) brew_runtime.Value {
	mut future := future_boundary_receiver(args)
	return brew_runtime.bool_value(future.cancelled())
}

// Ruby method `wait_or_cancel(timeout)` at line 121.
pub fn ruby_future_l121_d7_wait_or_cancel(args ...brew_runtime.Value) brew_runtime.Value {
	mut future := future_boundary_receiver(args)
	if args.len < 2 {
		panic('wait_or_cancel requires a timeout')
	}
	return brew_runtime.bool_value(future.wait_or_cancel(future_boundary_timeout(args[1])))
}

// Ruby method `ns_initialize(value, opts)` at line 133.
pub fn ruby_future_l133_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_future_l33_d1_initialize(...args)
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
// 9: # TODO (pitr-ch 14-Mar-2017): deprecate, Future, Promise, etc.
// 10:
// 11:
// 12: module Concurrent
// 13:
// 14:   # {include:file:docs-source/future.md}
// 15:   #
// 16:   # @!macro copy_options
// 17:   #
// 18:   # @see http://ruby-doc.org/stdlib-2.1.1/libdoc/observer/rdoc/Observable.html Ruby Observable module
// 19:   # @see http://clojuredocs.org/clojure_core/clojure.core/future Clojure's future function
// 20:   # @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Future.html java.util.concurrent.Future
// 21:   class Future < IVar
// 22:
// 23:     # Create a new `Future` in the `:unscheduled` state.
// 24:     #
// 25:     # @yield the asynchronous operation to perform
// 26:     #
// 27:     # @!macro executor_and_deref_options
// 28:     #
// 29:     # @option opts [object, Array] :args zero or more arguments to be passed the task
// 30:     #   block on execution
// 31:     #
// 32:     # @raise [ArgumentError] if no block is given
// 33:     def initialize(opts = {}, &block)
// 34:       raise ArgumentError.new('no block given') unless block_given?
// 35:       super(NULL, opts.merge(__task_from_block__: block), &nil)
// 36:     end
// 37:
// 38:     # Execute an `:unscheduled` `Future`. Immediately sets the state to `:pending` and
// 39:     # passes the block to a new thread/thread pool for eventual execution.
// 40:     # Does nothing if the `Future` is in any state other than `:unscheduled`.
// 41:     #
// 42:     # @return [Future] a reference to `self`
// 43:     #
// 44:     # @example Instance and execute in separate steps
// 45:     #   future = Concurrent::Future.new{ sleep(1); 42 }
// 46:     #   future.state #=> :unscheduled
// 47:     #   future.execute
// 48:     #   future.state #=> :pending
// 49:     #
// 50:     # @example Instance and execute in one line
// 51:     #   future = Concurrent::Future.new{ sleep(1); 42 }.execute
// 52:     #   future.state #=> :pending
// 53:     def execute
// 54:       if compare_and_set_state(:pending, :unscheduled)
// 55:         @executor.post{ safe_execute(@task, @args) }
// 56:         self
// 57:       end
// 58:     end
// 59:
// 60:     # Create a new `Future` object with the given block, execute it, and return the
// 61:     # `:pending` object.
// 62:     #
// 63:     # @yield the asynchronous operation to perform
// 64:     #
// 65:     # @!macro executor_and_deref_options
// 66:     #
// 67:     # @option opts [object, Array] :args zero or more arguments to be passed the task
// 68:     #   block on execution
// 69:     #
// 70:     # @raise [ArgumentError] if no block is given
// 71:     #
// 72:     # @return [Future] the newly created `Future` in the `:pending` state
// 73:     #
// 74:     # @example
// 75:     #   future = Concurrent::Future.execute{ sleep(1); 42 }
// 76:     #   future.state #=> :pending
// 77:     def self.execute(opts = {}, &block)
// 78:       Future.new(opts, &block).execute
// 79:     end
// 80:
// 81:     # @!macro ivar_set_method
// 82:     def set(value = NULL, &block)
// 83:       check_for_block_or_value!(block_given?, value)
// 84:       synchronize do
// 85:         if @state != :unscheduled
// 86:           raise MultipleAssignmentError
// 87:         else
// 88:           @task = block || Proc.new { value }
// 89:         end
// 90:       end
// 91:       execute
// 92:     end
// 93:
// 94:     # Attempt to cancel the operation if it has not already processed.
// 95:     # The operation can only be cancelled while still `pending`. It cannot
// 96:     # be cancelled once it has begun processing or has completed.
// 97:     #
// 98:     # @return [Boolean] was the operation successfully cancelled.
// 99:     def cancel
// 100:       if compare_and_set_state(:cancelled, :pending)
// 101:         complete(false, nil, CancelledOperationError.new)
// 102:         true
// 103:       else
// 104:         false
// 105:       end
// 106:     end
// 107:
// 108:     # Has the operation been successfully cancelled?
// 109:     #
// 110:     # @return [Boolean]
// 111:     def cancelled?
// 112:       state == :cancelled
// 113:     end
// 114:
// 115:     # Wait the given number of seconds for the operation to complete.
// 116:     # On timeout attempt to cancel the operation.
// 117:     #
// 118:     # @param [Numeric] timeout the maximum time in seconds to wait.
// 119:     # @return [Boolean] true if the operation completed before the timeout
// 120:     #   else false
// 121:     def wait_or_cancel(timeout)
// 122:       wait(timeout)
// 123:       if complete?
// 124:         true
// 125:       else
// 126:         cancel
// 127:         false
// 128:       end
// 129:     end
// 130:
// 131:     protected
// 132:
// 133:     def ns_initialize(value, opts)
// 134:       super
// 135:       @state = :unscheduled
// 136:       @task = opts[:__task_from_block__]
// 137:       @executor = Options.executor_from_options(opts) || Concurrent.global_io_executor
// 138:       @args = get_arguments_from(opts)
// 139:     end
// 140:   end
// 141: end
