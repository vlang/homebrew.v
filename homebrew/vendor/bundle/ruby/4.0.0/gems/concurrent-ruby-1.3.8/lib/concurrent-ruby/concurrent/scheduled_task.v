module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/scheduled_task.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :executor` at line 163.
pub fn ruby_scheduled_task_l163_d1_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executor', ...args)
}

// Ruby method `initialize(delay, opts = {}, &task)` at line 178.
pub fn ruby_scheduled_task_l178_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initial_delay` at line 199.
pub fn ruby_scheduled_task_l199_d3_initial_delay(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initial_delay', ...args)
}

// Ruby method `schedule_time` at line 206.
pub fn ruby_scheduled_task_l206_d4_schedule_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('schedule_time', ...args)
}

// Ruby method `<=>(other)` at line 213.
pub fn ruby_scheduled_task_l213_d5_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `cancelled?` at line 220.
pub fn ruby_scheduled_task_l220_d6_cancelled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cancelled?', ...args)
}

// Ruby method `processing?` at line 227.
pub fn ruby_scheduled_task_l227_d7_processing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processing?', ...args)
}

// Ruby method `cancel` at line 235.
pub fn ruby_scheduled_task_l235_d8_cancel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cancel', ...args)
}

// Ruby method `reset` at line 250.
pub fn ruby_scheduled_task_l250_d9_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset', ...args)
}

// Ruby method `reschedule(delay)` at line 262.
pub fn ruby_scheduled_task_l262_d10_reschedule(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reschedule', ...args)
}

// Ruby method `execute` at line 273.
pub fn ruby_scheduled_task_l273_d11_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute', ...args)
}

// Ruby method `self.execute(delay, opts = {}, &task)` at line 290.
pub fn ruby_scheduled_task_l290_d12_self_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.execute', ...args)
}

// Ruby method `process_task` at line 297.
pub fn ruby_scheduled_task_l297_d13_process_task(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_task', ...args)
}

// Ruby method `ns_schedule(delay)` at line 312.
pub fn ruby_scheduled_task_l312_d14_ns_schedule(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_schedule', ...args)
}

// Ruby method `ns_reschedule(delay)` at line 326.
pub fn ruby_scheduled_task_l326_d15_ns_reschedule(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_reschedule', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require 'concurrent/errors'
// 3: require 'concurrent/configuration'
// 4: require 'concurrent/ivar'
// 5: require 'concurrent/collection/copy_on_notify_observer_set'
// 6: require 'concurrent/utility/monotonic_time'
// 7:
// 8: require 'concurrent/options'
// 9:
// 10: module Concurrent
// 11:
// 12:   # `ScheduledTask` is a close relative of `Concurrent::Future` but with one
// 13:   # important difference: A `Future` is set to execute as soon as possible
// 14:   # whereas a `ScheduledTask` is set to execute after a specified delay. This
// 15:   # implementation is loosely based on Java's
// 16:   # [ScheduledExecutorService](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ScheduledExecutorService.html).
// 17:   # It is a more feature-rich variant of {Concurrent.timer}.
// 18:   #
// 19:   # The *intended* schedule time of task execution is set on object construction
// 20:   # with the `delay` argument. The delay is a numeric (floating point or integer)
// 21:   # representing a number of seconds in the future. Any other value or a numeric
// 22:   # equal to or less than zero will result in an exception. The *actual* schedule
// 23:   # time of task execution is set when the `execute` method is called.
// 24:   #
// 25:   # The constructor can also be given zero or more processing options. Currently
// 26:   # the only supported options are those recognized by the
// 27:   # [Dereferenceable](Dereferenceable) module.
// 28:   #
// 29:   # The final constructor argument is a block representing the task to be performed.
// 30:   # If no block is given an `ArgumentError` will be raised.
// 31:   #
// 32:   # **States**
// 33:   #
// 34:   # `ScheduledTask` mixes in the  [Obligation](Obligation) module thus giving it
// 35:   # "future" behavior. This includes the expected lifecycle states. `ScheduledTask`
// 36:   # has one additional state, however. While the task (block) is being executed the
// 37:   # state of the object will be `:processing`. This additional state is necessary
// 38:   # because it has implications for task cancellation.
// 39:   #
// 40:   # **Cancellation**
// 41:   #
// 42:   # A `:pending` task can be cancelled using the `#cancel` method. A task in any
// 43:   # other state, including `:processing`, cannot be cancelled. The `#cancel`
// 44:   # method returns a boolean indicating the success of the cancellation attempt.
// 45:   # A cancelled `ScheduledTask` cannot be restarted. It is immutable.
// 46:   #
// 47:   # **Obligation and Observation**
// 48:   #
// 49:   # The result of a `ScheduledTask` can be obtained either synchronously or
// 50:   # asynchronously. `ScheduledTask` mixes in both the [Obligation](Obligation)
// 51:   # module and the
// 52:   # [Observable](http://ruby-doc.org/stdlib-2.0/libdoc/observer/rdoc/Observable.html)
// 53:   # module from the Ruby standard library. With one exception `ScheduledTask`
// 54:   # behaves identically to [Future](Observable) with regard to these modules.
// 55:   #
// 56:   # @!macro copy_options
// 57:   #
// 58:   # @example Basic usage
// 59:   #
// 60:   #   require 'concurrent/scheduled_task'
// 61:   #   require 'csv'
// 62:   #   require 'open-uri'
// 63:   #
// 64:   #   class Ticker
// 65:   #     def get_year_end_closing(symbol, year, api_key)
// 66:   #      uri = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=#{symbol}&apikey=#{api_key}&datatype=csv"
// 67:   #      data = []
// 68:   #      csv = URI.parse(uri).read
// 69:   #      if csv.include?('call frequency')
// 70:   #        return :rate_limit_exceeded
// 71:   #      end
// 72:   #      CSV.parse(csv, headers: true) do |row|
// 73:   #        data << row['close'].to_f if row['timestamp'].include?(year.to_s)
// 74:   #      end
// 75:   #      year_end = data.first
// 76:   #      year_end
// 77:   #    rescue => e
// 78:   #      p e
// 79:   #    end
// 80:   #   end
// 81:   #
// 82:   #   api_key = ENV['ALPHAVANTAGE_KEY']
// 83:   #   abort(error_message) unless api_key
// 84:   #
// 85:   #   # Future
// 86:   #   price = Concurrent::Future.execute{ Ticker.new.get_year_end_closing('TWTR', 2013, api_key) }
// 87:   #   price.state #=> :pending
// 88:   #   price.pending? #=> true
// 89:   #   price.value(0) #=> nil (does not block)
// 90:   #
// 91:   #    sleep(1)    # do other stuff
// 92:   #
// 93:   #   price.value #=> 63.65 (after blocking if necessary)
// 94:   #   price.state #=> :fulfilled
// 95:   #   price.fulfilled? #=> true
// 96:   #   price.value #=> 63.65
// 97:   #
// 98:   # @example Successful task execution
// 99:   #
// 100:   #   task = Concurrent::ScheduledTask.new(2){ 'What does the fox say?' }
// 101:   #   task.state         #=> :unscheduled
// 102:   #   task.execute
// 103:   #   task.state         #=> pending
// 104:   #
// 105:   #   # wait for it...
// 106:   #   sleep(3)
// 107:   #
// 108:   #   task.unscheduled? #=> false
// 109:   #   task.pending?     #=> false
// 110:   #   task.fulfilled?   #=> true
// 111:   #   task.rejected?    #=> false
// 112:   #   task.value        #=> 'What does the fox say?'
// 113:   #
// 114:   # @example One line creation and execution
// 115:   #
// 116:   #   task = Concurrent::ScheduledTask.new(2){ 'What does the fox say?' }.execute
// 117:   #   task.state         #=> pending
// 118:   #
// 119:   #   task = Concurrent::ScheduledTask.execute(2){ 'What do you get when you multiply 6 by 9?' }
// 120:   #   task.state         #=> pending
// 121:   #
// 122:   # @example Failed task execution
// 123:   #
// 124:   #   task = Concurrent::ScheduledTask.execute(2){ raise StandardError.new('Call me maybe?') }
// 125:   #   task.pending?      #=> true
// 126:   #
// 127:   #   # wait for it...
// 128:   #   sleep(3)
// 129:   #
// 130:   #   task.unscheduled? #=> false
// 131:   #   task.pending?     #=> false
// 132:   #   task.fulfilled?   #=> false
// 133:   #   task.rejected?    #=> true
// 134:   #   task.value        #=> nil
// 135:   #   task.reason       #=> #<StandardError: Call me maybe?>
// 136:   #
// 137:   # @example Task execution with observation
// 138:   #
// 139:   #   observer = Class.new{
// 140:   #     def update(time, value, reason)
// 141:   #       puts "The task completed at #{time} with value '#{value}'"
// 142:   #     end
// 143:   #   }.new
// 144:   #
// 145:   #   task = Concurrent::ScheduledTask.new(2){ 'What does the fox say?' }
// 146:   #   task.add_observer(observer)
// 147:   #   task.execute
// 148:   #   task.pending?      #=> true
// 149:   #
// 150:   #   # wait for it...
// 151:   #   sleep(3)
// 152:   #
// 153:   #   #>> The task completed at 2013-11-07 12:26:09 -0500 with value 'What does the fox say?'
// 154:   #
// 155:   # @!macro monotonic_clock_warning
// 156:   #
// 157:   # @see Concurrent.timer
// 158:   class ScheduledTask < IVar
// 159:     include Comparable
// 160:
// 161:     # The executor on which to execute the task.
// 162:     # @!visibility private
// 163:     attr_reader :executor
// 164:
// 165:     # Schedule a task for execution at a specified future time.
// 166:     #
// 167:     # @param [Float] delay the number of seconds to wait for before executing the task
// 168:     #
// 169:     # @yield the task to be performed
// 170:     #
// 171:     # @!macro executor_and_deref_options
// 172:     #
// 173:     # @option opts [object, Array] :args zero or more arguments to be passed the task
// 174:     #   block on execution
// 175:     #
// 176:     # @raise [ArgumentError] When no block is given
// 177:     # @raise [ArgumentError] When given a time that is in the past
// 178:     def initialize(delay, opts = {}, &task)
// 179:       raise ArgumentError.new('no block given') unless block_given?
// 180:       raise ArgumentError.new('seconds must be greater than zero') if delay.to_f < 0.0
// 181:
// 182:       super(NULL, opts, &nil)
// 183:
// 184:       synchronize do
// 185:         ns_set_state(:unscheduled)
// 186:         @parent = opts.fetch(:timer_set, Concurrent.global_timer_set)
// 187:         @args = get_arguments_from(opts)
// 188:         @delay = delay.to_f
// 189:         @task = task
// 190:         @time = nil
// 191:         @executor = Options.executor_from_options(opts) || Concurrent.global_io_executor
// 192:         self.observers = Collection::CopyOnNotifyObserverSet.new
// 193:       end
// 194:     end
// 195:
// 196:     # The `delay` value given at instantiation.
// 197:     #
// 198:     # @return [Float] the initial delay.
// 199:     def initial_delay
// 200:       synchronize { @delay }
// 201:     end
// 202:
// 203:     # The monotonic time at which the the task is scheduled to be executed.
// 204:     #
// 205:     # @return [Float] the schedule time or nil if `unscheduled`
// 206:     def schedule_time
// 207:       synchronize { @time }
// 208:     end
// 209:
// 210:     # Comparator which orders by schedule time.
// 211:     #
// 212:     # @!visibility private
// 213:     def <=>(other)
// 214:       schedule_time <=> other.schedule_time
// 215:     end
// 216:
// 217:     # Has the task been cancelled?
// 218:     #
// 219:     # @return [Boolean] true if the task is in the given state else false
// 220:     def cancelled?
// 221:       synchronize { ns_check_state?(:cancelled) }
// 222:     end
// 223:
// 224:     # In the task execution in progress?
// 225:     #
// 226:     # @return [Boolean] true if the task is in the given state else false
// 227:     def processing?
// 228:       synchronize { ns_check_state?(:processing) }
// 229:     end
// 230:
// 231:     # Cancel this task and prevent it from executing. A task can only be
// 232:     # cancelled if it is pending or unscheduled.
// 233:     #
// 234:     # @return [Boolean] true if successfully cancelled else false
// 235:     def cancel
// 236:       if compare_and_set_state(:cancelled, :pending, :unscheduled)
// 237:         complete(false, nil, CancelledOperationError.new)
// 238:         # To avoid deadlocks this call must occur outside of #synchronize
// 239:         # Changing the state above should prevent redundant calls
// 240:         @parent.send(:remove_task, self)
// 241:       else
// 242:         false
// 243:       end
// 244:     end
// 245:
// 246:     # Reschedule the task using the original delay and the current time.
// 247:     # A task can only be reset while it is `:pending`.
// 248:     #
// 249:     # @return [Boolean] true if successfully rescheduled else false
// 250:     def reset
// 251:       synchronize{ ns_reschedule(@delay) }
// 252:     end
// 253:
// 254:     # Reschedule the task using the given delay and the current time.
// 255:     # A task can only be reset while it is `:pending`.
// 256:     #
// 257:     # @param [Float] delay the number of seconds to wait for before executing the task
// 258:     #
// 259:     # @return [Boolean] true if successfully rescheduled else false
// 260:     #
// 261:     # @raise [ArgumentError] When given a time that is in the past
// 262:     def reschedule(delay)
// 263:       delay = delay.to_f
// 264:       raise ArgumentError.new('seconds must be greater than zero') if delay < 0.0
// 265:       synchronize{ ns_reschedule(delay) }
// 266:     end
// 267:
// 268:     # Execute an `:unscheduled` `ScheduledTask`. Immediately sets the state to `:pending`
// 269:     # and starts counting down toward execution. Does nothing if the `ScheduledTask` is
// 270:     # in any state other than `:unscheduled`.
// 271:     #
// 272:     # @return [ScheduledTask] a reference to `self`
// 273:     def execute
// 274:       if compare_and_set_state(:pending, :unscheduled)
// 275:         synchronize{ ns_schedule(@delay) }
// 276:       end
// 277:       self
// 278:     end
// 279:
// 280:     # Create a new `ScheduledTask` object with the given block, execute it, and return the
// 281:     # `:pending` object.
// 282:     #
// 283:     # @param [Float] delay the number of seconds to wait for before executing the task
// 284:     #
// 285:     # @!macro executor_and_deref_options
// 286:     #
// 287:     # @return [ScheduledTask] the newly created `ScheduledTask` in the `:pending` state
// 288:     #
// 289:     # @raise [ArgumentError] if no block is given
// 290:     def self.execute(delay, opts = {}, &task)
// 291:       new(delay, opts, &task).execute
// 292:     end
// 293:
// 294:     # Execute the task.
// 295:     #
// 296:     # @!visibility private
// 297:     def process_task
// 298:       safe_execute(@task, @args)
// 299:     end
// 300:
// 301:     protected :set, :try_set, :fail, :complete
// 302:
// 303:     protected
// 304:
// 305:     # Schedule the task using the given delay and the current time.
// 306:     #
// 307:     # @param [Float] delay the number of seconds to wait for before executing the task
// 308:     #
// 309:     # @return [Boolean] true if successfully rescheduled else false
// 310:     #
// 311:     # @!visibility private
// 312:     def ns_schedule(delay)
// 313:       @delay = delay
// 314:       @time = Concurrent.monotonic_time + @delay
// 315:       @parent.send(:post_task, self)
// 316:     end
// 317:
// 318:     # Reschedule the task using the given delay and the current time.
// 319:     # A task can only be reset while it is `:pending`.
// 320:     #
// 321:     # @param [Float] delay the number of seconds to wait for before executing the task
// 322:     #
// 323:     # @return [Boolean] true if successfully rescheduled else false
// 324:     #
// 325:     # @!visibility private
// 326:     def ns_reschedule(delay)
// 327:       return false unless ns_check_state?(:pending)
// 328:       @parent.send(:remove_task, self) && ns_schedule(delay)
// 329:     end
// 330:   end
// 331: end
