module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/future.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(opts = {}, &block)` at line 33.
pub fn ruby_future_l33_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `execute` at line 53.
pub fn ruby_future_l53_d2_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute', ...args)
}

// Ruby method `self.execute(opts = {}, &block)` at line 77.
pub fn ruby_future_l77_d3_self_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.execute', ...args)
}

// Ruby method `set(value = NULL, &block)` at line 82.
pub fn ruby_future_l82_d4_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `cancel` at line 99.
pub fn ruby_future_l99_d5_cancel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cancel', ...args)
}

// Ruby method `cancelled?` at line 111.
pub fn ruby_future_l111_d6_cancelled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cancelled?', ...args)
}

// Ruby method `wait_or_cancel(timeout)` at line 121.
pub fn ruby_future_l121_d7_wait_or_cancel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_or_cancel', ...args)
}

// Ruby method `ns_initialize(value, opts)` at line 133.
pub fn ruby_future_l133_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
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
