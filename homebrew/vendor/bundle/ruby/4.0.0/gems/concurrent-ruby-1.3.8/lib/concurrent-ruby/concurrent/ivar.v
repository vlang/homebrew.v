module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/ivar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(value = NULL, opts = {}, &block)` at line 62.
pub fn ruby_ivar_l62_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 81.
pub fn ruby_ivar_l81_d2_add_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_observer', ...args)
}

// Ruby method `set(value = NULL)` at line 113.
pub fn ruby_ivar_l113_d3_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `fail(reason = StandardError.new)` at line 135.
pub fn ruby_ivar_l135_d4_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fail', ...args)
}

// Ruby method `try_set(value = NULL, &block)` at line 145.
pub fn ruby_ivar_l145_d5_try_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_set', ...args)
}

// Ruby method `ns_initialize(value, opts)` at line 155.
pub fn ruby_ivar_l155_d6_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `safe_execute(task, args = [])` at line 168.
pub fn ruby_ivar_l168_d7_safe_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('safe_execute', ...args)
}

// Ruby method `complete(success, value, reason)` at line 177.
pub fn ruby_ivar_l177_d8_complete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('complete', ...args)
}

// Ruby method `complete_without_notification(success, value, reason)` at line 184.
pub fn ruby_ivar_l184_d9_complete_without_notification(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('complete_without_notification', ...args)
}

// Ruby method `notify_observers(value, reason)` at line 190.
pub fn ruby_ivar_l190_d10_notify_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notify_observers', ...args)
}

// Ruby method `ns_complete_without_notification(success, value, reason)` at line 195.
pub fn ruby_ivar_l195_d11_ns_complete_without_notification(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_complete_without_notification', ...args)
}

// Ruby method `check_for_block_or_value!(block_given, value) # :nodoc:` at line 202.
pub fn ruby_ivar_l202_d12_check_for_block_or_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_for_block_or_value!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require 'concurrent/errors'
// 3: require 'concurrent/collection/copy_on_write_observer_set'
// 4: require 'concurrent/concern/obligation'
// 5: require 'concurrent/concern/observable'
// 6: require 'concurrent/executor/safe_task_executor'
// 7: require 'concurrent/synchronization/lockable_object'
// 8:
// 9: module Concurrent
// 10:
// 11:   # An `IVar` is like a future that you can assign. As a future is a value that
// 12:   # is being computed that you can wait on, an `IVar` is a value that is waiting
// 13:   # to be assigned, that you can wait on. `IVars` are single assignment and
// 14:   # deterministic.
// 15:   #
// 16:   # Then, express futures as an asynchronous computation that assigns an `IVar`.
// 17:   # The `IVar` becomes the primitive on which [futures](Future) and
// 18:   # [dataflow](Dataflow) are built.
// 19:   #
// 20:   # An `IVar` is a single-element container that is normally created empty, and
// 21:   # can only be set once. The I in `IVar` stands for immutable. Reading an
// 22:   # `IVar` normally blocks until it is set. It is safe to set and read an `IVar`
// 23:   # from different threads.
// 24:   #
// 25:   # If you want to have some parallel task set the value in an `IVar`, you want
// 26:   # a `Future`. If you want to create a graph of parallel tasks all executed
// 27:   # when the values they depend on are ready you want `dataflow`. `IVar` is
// 28:   # generally a low-level primitive.
// 29:   #
// 30:   # ## Examples
// 31:   #
// 32:   # Create, set and get an `IVar`
// 33:   #
// 34:   # ```ruby
// 35:   # ivar = Concurrent::IVar.new
// 36:   # ivar.set 14
// 37:   # ivar.value #=> 14
// 38:   # ivar.set 2 # would now be an error
// 39:   # ```
// 40:   #
// 41:   # ## See Also
// 42:   #
// 43:   # 1. For the theory: Arvind, R. Nikhil, and K. Pingali.
// 44:   #    [I-Structures: Data structures for parallel computing](http://dl.acm.org/citation.cfm?id=69562).
// 45:   #    In Proceedings of Workshop on Graph Reduction, 1986.
// 46:   # 2. For recent application:
// 47:   #    [DataDrivenFuture in Habanero Java from Rice](http://www.cs.rice.edu/~vs3/hjlib/doc/edu/rice/hj/api/HjDataDrivenFuture.html).
// 48:   class IVar < Synchronization::LockableObject
// 49:     include Concern::Obligation
// 50:     include Concern::Observable
// 51:
// 52:     # Create a new `IVar` in the `:pending` state with the (optional) initial value.
// 53:     #
// 54:     # @param [Object] value the initial value
// 55:     # @param [Hash] opts the options to create a message with
// 56:     # @option opts [String] :dup_on_deref (false) call `#dup` before returning
// 57:     #   the data
// 58:     # @option opts [String] :freeze_on_deref (false) call `#freeze` before
// 59:     #   returning the data
// 60:     # @option opts [String] :copy_on_deref (nil) call the given `Proc` passing
// 61:     #   the internal value and returning the value returned from the proc
// 62:     def initialize(value = NULL, opts = {}, &block)
// 63:       if value != NULL && block_given?
// 64:         raise ArgumentError.new('provide only a value or a block')
// 65:       end
// 66:       super(&nil)
// 67:       synchronize { ns_initialize(value, opts, &block) }
// 68:     end
// 69:
// 70:     # Add an observer on this object that will receive notification on update.
// 71:     #
// 72:     # Upon completion the `IVar` will notify all observers in a thread-safe way.
// 73:     # The `func` method of the observer will be called with three arguments: the
// 74:     # `Time` at which the `Future` completed the asynchronous operation, the
// 75:     # final `value` (or `nil` on rejection), and the final `reason` (or `nil` on
// 76:     # fulfillment).
// 77:     #
// 78:     # @param [Object] observer the object that will be notified of changes
// 79:     # @param [Symbol] func symbol naming the method to call when this
// 80:     #   `Observable` has changes`
// 81:     def add_observer(observer = nil, func = :update, &block)
// 82:       raise ArgumentError.new('cannot provide both an observer and a block') if observer && block
// 83:       direct_notification = false
// 84:
// 85:       if block
// 86:         observer = block
// 87:         func = :call
// 88:       end
// 89:
// 90:       synchronize do
// 91:         if event.set?
// 92:           direct_notification = true
// 93:         else
// 94:           observers.add_observer(observer, func)
// 95:         end
// 96:       end
// 97:
// 98:       observer.send(func, Time.now, self.value, reason) if direct_notification
// 99:       observer
// 100:     end
// 101:
// 102:     # @!macro ivar_set_method
// 103:     #   Set the `IVar` to a value and wake or notify all threads waiting on it.
// 104:     #
// 105:     #   @!macro ivar_set_parameters_and_exceptions
// 106:     #     @param [Object] value the value to store in the `IVar`
// 107:     #     @yield A block operation to use for setting the value
// 108:     #     @raise [ArgumentError] if both a value and a block are given
// 109:     #     @raise [Concurrent::MultipleAssignmentError] if the `IVar` has already
// 110:     #       been set or otherwise completed
// 111:     #
// 112:     #   @return [IVar] self
// 113:     def set(value = NULL)
// 114:       check_for_block_or_value!(block_given?, value)
// 115:       raise MultipleAssignmentError unless compare_and_set_state(:processing, :pending)
// 116:
// 117:       begin
// 118:         value = yield if block_given?
// 119:         complete_without_notification(true, value, nil)
// 120:       rescue => ex
// 121:         complete_without_notification(false, nil, ex)
// 122:       end
// 123:
// 124:       notify_observers(self.value, reason)
// 125:       self
// 126:     end
// 127:
// 128:     # @!macro ivar_fail_method
// 129:     #   Set the `IVar` to failed due to some error and wake or notify all threads waiting on it.
// 130:     #
// 131:     #   @param [Object] reason for the failure
// 132:     #   @raise [Concurrent::MultipleAssignmentError] if the `IVar` has already
// 133:     #     been set or otherwise completed
// 134:     #   @return [IVar] self
// 135:     def fail(reason = StandardError.new)
// 136:       complete(false, nil, reason)
// 137:     end
// 138:
// 139:     # Attempt to set the `IVar` with the given value or block. Return a
// 140:     # boolean indicating the success or failure of the set operation.
// 141:     #
// 142:     # @!macro ivar_set_parameters_and_exceptions
// 143:     #
// 144:     # @return [Boolean] true if the value was set else false
// 145:     def try_set(value = NULL, &block)
// 146:       set(value, &block)
// 147:       true
// 148:     rescue MultipleAssignmentError
// 149:       false
// 150:     end
// 151:
// 152:     protected
// 153:
// 154:     # @!visibility private
// 155:     def ns_initialize(value, opts)
// 156:       value = yield if block_given?
// 157:       init_obligation
// 158:       self.observers = Collection::CopyOnWriteObserverSet.new
// 159:       set_deref_options(opts)
// 160:
// 161:       @state = :pending
// 162:       if value != NULL
// 163:         ns_complete_without_notification(true, value, nil)
// 164:       end
// 165:     end
// 166:
// 167:     # @!visibility private
// 168:     def safe_execute(task, args = [])
// 169:       if compare_and_set_state(:processing, :pending)
// 170:         success, val, reason = SafeTaskExecutor.new(task, rescue_exception: true).execute(*@args)
// 171:         complete(success, val, reason)
// 172:         yield(success, val, reason) if block_given?
// 173:       end
// 174:     end
// 175:
// 176:     # @!visibility private
// 177:     def complete(success, value, reason)
// 178:       complete_without_notification(success, value, reason)
// 179:       notify_observers(self.value, reason)
// 180:       self
// 181:     end
// 182:
// 183:     # @!visibility private
// 184:     def complete_without_notification(success, value, reason)
// 185:       synchronize { ns_complete_without_notification(success, value, reason) }
// 186:       self
// 187:     end
// 188:
// 189:     # @!visibility private
// 190:     def notify_observers(value, reason)
// 191:       observers.notify_and_delete_observers{ [Time.now, value, reason] }
// 192:     end
// 193:
// 194:     # @!visibility private
// 195:     def ns_complete_without_notification(success, value, reason)
// 196:       raise MultipleAssignmentError if [:fulfilled, :rejected].include? @state
// 197:       set_state(success, value, reason)
// 198:       event.set
// 199:     end
// 200:
// 201:     # @!visibility private
// 202:     def check_for_block_or_value!(block_given, value) # :nodoc:
// 203:       if (block_given && value != NULL) || (! block_given && value == NULL)
// 204:         raise ArgumentError.new('must set with either a value or a block')
// 205:       end
// 206:     end
// 207:   end
// 208: end
