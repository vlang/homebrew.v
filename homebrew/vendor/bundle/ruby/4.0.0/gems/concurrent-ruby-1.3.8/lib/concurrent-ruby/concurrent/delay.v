module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/delay.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(opts = {}, &block)` at line 62.
pub fn ruby_delay_l62_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `value(timeout = nil)` at line 77.
pub fn ruby_delay_l77_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `value!(timeout = nil)` at line 113.
pub fn ruby_delay_l113_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value!', ...args)
}

// Ruby method `wait(timeout = nil)` at line 132.
pub fn ruby_delay_l132_d4_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `reconfigure(&block)` at line 146.
pub fn ruby_delay_l146_d5_reconfigure(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reconfigure', ...args)
}

// Ruby method `ns_initialize(opts, &block)` at line 160.
pub fn ruby_delay_l160_d6_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `execute_task_once # :nodoc:` at line 173.
pub fn ruby_delay_l173_d7_execute_task_once(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute_task_once', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/concern/obligation'
// 3: require 'concurrent/executor/immediate_executor'
// 4: require 'concurrent/synchronization/lockable_object'
// 5:
// 6: module Concurrent
// 7:
// 8:   # This file has circular require issues. It must be autoloaded here.
// 9:   autoload :Options, 'concurrent/options'
// 10:
// 11:   # Lazy evaluation of a block yielding an immutable result. Useful for
// 12:   # expensive operations that may never be needed. It may be non-blocking,
// 13:   # supports the `Concern::Obligation` interface, and accepts the injection of
// 14:   # custom executor upon which to execute the block. Processing of
// 15:   # block will be deferred until the first time `#value` is called.
// 16:   # At that time the caller can choose to return immediately and let
// 17:   # the block execute asynchronously, block indefinitely, or block
// 18:   # with a timeout.
// 19:   #
// 20:   # When a `Delay` is created its state is set to `pending`. The value and
// 21:   # reason are both `nil`. The first time the `#value` method is called the
// 22:   # enclosed operation will be run and the calling thread will block. Other
// 23:   # threads attempting to call `#value` will block as well. Once the operation
// 24:   # is complete the *value* will be set to the result of the operation or the
// 25:   # *reason* will be set to the raised exception, as appropriate. All threads
// 26:   # blocked on `#value` will return. Subsequent calls to `#value` will immediately
// 27:   # return the cached value. The operation will only be run once. This means that
// 28:   # any side effects created by the operation will only happen once as well.
// 29:   #
// 30:   # `Delay` includes the `Concurrent::Concern::Dereferenceable` mixin to support thread
// 31:   # safety of the reference returned by `#value`.
// 32:   #
// 33:   # @!macro copy_options
// 34:   #
// 35:   # @!macro delay_note_regarding_blocking
// 36:   #   @note The default behavior of `Delay` is to block indefinitely when
// 37:   #     calling either `value` or `wait`, executing the delayed operation on
// 38:   #     the current thread. This makes the `timeout` value completely
// 39:   #     irrelevant. To enable non-blocking behavior, use the `executor`
// 40:   #     constructor option. This will cause the delayed operation to be
// 41:   #     execute on the given executor, allowing the call to timeout.
// 42:   #
// 43:   # @see Concurrent::Concern::Dereferenceable
// 44:   class Delay < Synchronization::LockableObject
// 45:     include Concern::Obligation
// 46:
// 47:     # NOTE: Because the global thread pools are lazy-loaded with these objects
// 48:     # there is a performance hit every time we post a new task to one of these
// 49:     # thread pools. Subsequently it is critical that `Delay` perform as fast
// 50:     # as possible post-completion. This class has been highly optimized using
// 51:     # the benchmark script `examples/lazy_and_delay.rb`. Do NOT attempt to
// 52:     # DRY-up this class or perform other refactoring with running the
// 53:     # benchmarks and ensuring that performance is not negatively impacted.
// 54:
// 55:     # Create a new `Delay` in the `:pending` state.
// 56:     #
// 57:     # @!macro executor_and_deref_options
// 58:     #
// 59:     # @yield the delayed operation to perform
// 60:     #
// 61:     # @raise [ArgumentError] if no block is given
// 62:     def initialize(opts = {}, &block)
// 63:       raise ArgumentError.new('no block given') unless block_given?
// 64:       super(&nil)
// 65:       synchronize { ns_initialize(opts, &block) }
// 66:     end
// 67:
// 68:     # Return the value this object represents after applying the options
// 69:     # specified by the `#set_deref_options` method. If the delayed operation
// 70:     # raised an exception this method will return nil. The exception object
// 71:     # can be accessed via the `#reason` method.
// 72:     #
// 73:     # @param [Numeric] timeout the maximum number of seconds to wait
// 74:     # @return [Object] the current value of the object
// 75:     #
// 76:     # @!macro delay_note_regarding_blocking
// 77:     def value(timeout = nil)
// 78:       if @executor # TODO (pitr 12-Sep-2015): broken unsafe read?
// 79:         super
// 80:       else
// 81:         # this function has been optimized for performance and
// 82:         # should not be modified without running new benchmarks
// 83:         synchronize do
// 84:           execute = @evaluation_started = true unless @evaluation_started
// 85:           if execute
// 86:             begin
// 87:               set_state(true, @task.call, nil)
// 88:             rescue => ex
// 89:               set_state(false, nil, ex)
// 90:             end
// 91:           elsif incomplete?
// 92:             raise IllegalOperationError, 'Recursive call to #value during evaluation of the Delay'
// 93:           end
// 94:         end
// 95:         if @do_nothing_on_deref
// 96:           @value
// 97:         else
// 98:           apply_deref_options(@value)
// 99:         end
// 100:       end
// 101:     end
// 102:
// 103:     # Return the value this object represents after applying the options
// 104:     # specified by the `#set_deref_options` method. If the delayed operation
// 105:     # raised an exception, this method will raise that exception (even when)
// 106:     # the operation has already been executed).
// 107:     #
// 108:     # @param [Numeric] timeout the maximum number of seconds to wait
// 109:     # @return [Object] the current value of the object
// 110:     # @raise [Exception] when `#rejected?` raises `#reason`
// 111:     #
// 112:     # @!macro delay_note_regarding_blocking
// 113:     def value!(timeout = nil)
// 114:       if @executor
// 115:         super
// 116:       else
// 117:         result = value
// 118:         raise @reason if @reason
// 119:         result
// 120:       end
// 121:     end
// 122:
// 123:     # Return the value this object represents after applying the options
// 124:     # specified by the `#set_deref_options` method.
// 125:     #
// 126:     # @param [Integer] timeout (nil) the maximum number of seconds to wait for
// 127:     #   the value to be computed. When `nil` the caller will block indefinitely.
// 128:     #
// 129:     # @return [Object] self
// 130:     #
// 131:     # @!macro delay_note_regarding_blocking
// 132:     def wait(timeout = nil)
// 133:       if @executor
// 134:         execute_task_once
// 135:         super(timeout)
// 136:       else
// 137:         value
// 138:       end
// 139:       self
// 140:     end
// 141:
// 142:     # Reconfigures the block returning the value if still `#incomplete?`
// 143:     #
// 144:     # @yield the delayed operation to perform
// 145:     # @return [true, false] if success
// 146:     def reconfigure(&block)
// 147:       synchronize do
// 148:         raise ArgumentError.new('no block given') unless block_given?
// 149:         unless @evaluation_started
// 150:           @task = block
// 151:           true
// 152:         else
// 153:           false
// 154:         end
// 155:       end
// 156:     end
// 157:
// 158:     protected
// 159:
// 160:     def ns_initialize(opts, &block)
// 161:       init_obligation
// 162:       set_deref_options(opts)
// 163:       @executor = opts[:executor]
// 164:
// 165:       @task               = block
// 166:       @state              = :pending
// 167:       @evaluation_started = false
// 168:     end
// 169:
// 170:     private
// 171:
// 172:     # @!visibility private
// 173:     def execute_task_once # :nodoc:
// 174:       # this function has been optimized for performance and
// 175:       # should not be modified without running new benchmarks
// 176:       execute = task = nil
// 177:       synchronize do
// 178:         execute = @evaluation_started = true unless @evaluation_started
// 179:         task    = @task
// 180:       end
// 181:
// 182:       if execute
// 183:         executor = Options.executor_from_options(executor: @executor)
// 184:         executor.post do
// 185:           begin
// 186:             result  = task.call
// 187:             success = true
// 188:           rescue => ex
// 189:             reason = ex
// 190:           end
// 191:           synchronize do
// 192:             set_state(success, result, reason)
// 193:             event.set
// 194:           end
// 195:         end
// 196:       end
// 197:     end
// 198:   end
// 199: end
