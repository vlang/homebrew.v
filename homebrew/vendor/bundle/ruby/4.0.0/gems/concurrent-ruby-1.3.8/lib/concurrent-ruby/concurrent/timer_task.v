module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/timer_task.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(opts = {}, &task)` at line 210.
pub fn ruby_timer_task_l210_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `running?` at line 219.
pub fn ruby_timer_task_l219_d2_running(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('running?', ...args)
}

// Ruby method `execute` at line 236.
pub fn ruby_timer_task_l236_d3_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute', ...args)
}

// Ruby method `self.execute(opts = {}, &task)` at line 254.
pub fn ruby_timer_task_l254_d4_self_execute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.execute', ...args)
}

// Ruby method `execution_interval` at line 261.
pub fn ruby_timer_task_l261_d5_execution_interval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execution_interval', ...args)
}

// Ruby method `execution_interval=(value)` at line 268.
pub fn ruby_timer_task_l268_d6_execution_interval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execution_interval=', ...args)
}

// Ruby attr_reader `attr_reader :interval_type` at line 278.
pub fn ruby_timer_task_l278_d7_interval_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interval_type', ...args)
}

// Ruby method `timeout_interval` at line 283.
pub fn ruby_timer_task_l283_d8_timeout_interval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('timeout_interval', ...args)
}

// Ruby method `timeout_interval=(value)` at line 290.
pub fn ruby_timer_task_l290_d9_timeout_interval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('timeout_interval=', ...args)
}

// Ruby method `ns_initialize(opts, &task)` at line 298.
pub fn ruby_timer_task_l298_d10_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `ns_shutdown_execution` at line 321.
pub fn ruby_timer_task_l321_d11_ns_shutdown_execution(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_shutdown_execution', ...args)
}

// Ruby method `ns_kill_execution` at line 327.
pub fn ruby_timer_task_l327_d12_ns_kill_execution(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_kill_execution', ...args)
}

// Ruby method `schedule_next_task(interval = execution_interval)` at line 333.
pub fn ruby_timer_task_l333_d13_schedule_next_task(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('schedule_next_task', ...args)
}

// Ruby method `execute_task(completion, age_when_scheduled)` at line 339.
pub fn ruby_timer_task_l339_d14_execute_task(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('execute_task', ...args)
}

// Ruby method `calculate_next_interval(start_time)` at line 357.
pub fn ruby_timer_task_l357_d15_calculate_next_interval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('calculate_next_interval', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/collection/copy_on_notify_observer_set'
// 2: require 'concurrent/concern/dereferenceable'
// 3: require 'concurrent/concern/observable'
// 4: require 'concurrent/atomic/atomic_boolean'
// 5: require 'concurrent/atomic/atomic_fixnum'
// 6: require 'concurrent/executor/executor_service'
// 7: require 'concurrent/executor/ruby_executor_service'
// 8: require 'concurrent/executor/safe_task_executor'
// 9: require 'concurrent/scheduled_task'
// 10:
// 11: module Concurrent
// 12:
// 13:   # A very common concurrency pattern is to run a thread that performs a task at
// 14:   # regular intervals. The thread that performs the task sleeps for the given
// 15:   # interval then wakes up and performs the task. Lather, rinse, repeat... This
// 16:   # pattern causes two problems. First, it is difficult to test the business
// 17:   # logic of the task because the task itself is tightly coupled with the
// 18:   # concurrency logic. Second, an exception raised while performing the task can
// 19:   # cause the entire thread to abend. In a long-running application where the
// 20:   # task thread is intended to run for days/weeks/years a crashed task thread
// 21:   # can pose a significant problem. `TimerTask` alleviates both problems.
// 22:   #
// 23:   # When a `TimerTask` is launched it starts a thread for monitoring the
// 24:   # execution interval. The `TimerTask` thread does not perform the task,
// 25:   # however. Instead, the TimerTask launches the task on a separate thread.
// 26:   # Should the task experience an unrecoverable crash only the task thread will
// 27:   # crash. This makes the `TimerTask` very fault tolerant. Additionally, the
// 28:   # `TimerTask` thread can respond to the success or failure of the task,
// 29:   # performing logging or ancillary operations.
// 30:   #
// 31:   # One other advantage of `TimerTask` is that it forces the business logic to
// 32:   # be completely decoupled from the concurrency logic. The business logic can
// 33:   # be tested separately then passed to the `TimerTask` for scheduling and
// 34:   # running.
// 35:   #
// 36:   # A `TimerTask` supports two different types of interval calculations.
// 37:   # A fixed delay will always wait the same amount of time between the
// 38:   # completion of one task and the start of the next. A fixed rate will
// 39:   # attempt to maintain a constant rate of execution regardless of the
// 40:   # duration of the task. For example, if a fixed rate task is scheduled
// 41:   # to run every 60 seconds but the task itself takes 10 seconds to
// 42:   # complete, the next task will be scheduled to run 50 seconds after
// 43:   # the start of the previous task. If the task takes 70 seconds to
// 44:   # complete, the next task will be start immediately after the previous
// 45:   # task completes. Tasks will not be executed concurrently.
// 46:   #
// 47:   # In some cases it may be necessary for a `TimerTask` to affect its own
// 48:   # execution cycle. To facilitate this, a reference to the TimerTask instance
// 49:   # is passed as an argument to the provided block every time the task is
// 50:   # executed.
// 51:   #
// 52:   # The `TimerTask` class includes the `Dereferenceable` mixin module so the
// 53:   # result of the last execution is always available via the `#value` method.
// 54:   # Dereferencing options can be passed to the `TimerTask` during construction or
// 55:   # at any later time using the `#set_deref_options` method.
// 56:   #
// 57:   # `TimerTask` supports notification through the Ruby standard library
// 58:   # {http://ruby-doc.org/stdlib-2.0/libdoc/observer/rdoc/Observable.html
// 59:   # Observable} module. On execution the `TimerTask` will notify the observers
// 60:   # with three arguments: time of execution, the result of the block (or nil on
// 61:   # failure), and any raised exceptions (or nil on success).
// 62:   #
// 63:   # @!macro copy_options
// 64:   #
// 65:   # @example Basic usage
// 66:   #   task = Concurrent::TimerTask.new{ puts 'Boom!' }
// 67:   #   task.execute
// 68:   #
// 69:   #   task.execution_interval #=> 60 (default)
// 70:   #
// 71:   #   # wait 60 seconds...
// 72:   #   #=> 'Boom!'
// 73:   #
// 74:   #   task.shutdown #=> true
// 75:   #
// 76:   # @example Configuring `:execution_interval`
// 77:   #   task = Concurrent::TimerTask.new(execution_interval: 5) do
// 78:   #          puts 'Boom!'
// 79:   #        end
// 80:   #
// 81:   #   task.execution_interval #=> 5
// 82:   #
// 83:   # @example Immediate execution with `:run_now`
// 84:   #   task = Concurrent::TimerTask.new(run_now: true){ puts 'Boom!' }
// 85:   #   task.execute
// 86:   #
// 87:   #   #=> 'Boom!'
// 88:   #
// 89:   # @example Configuring `:interval_type` with either :fixed_delay or :fixed_rate, default is :fixed_delay
// 90:   #   task = Concurrent::TimerTask.new(execution_interval: 5, interval_type: :fixed_rate) do
// 91:   #          puts 'Boom!'
// 92:   #        end
// 93:   #   task.interval_type #=> :fixed_rate
// 94:   #
// 95:   # @example Last `#value` and `Dereferenceable` mixin
// 96:   #   task = Concurrent::TimerTask.new(
// 97:   #     dup_on_deref: true,
// 98:   #     execution_interval: 5
// 99:   #   ){ Time.now }
// 100:   #
// 101:   #   task.execute
// 102:   #   Time.now   #=> 2013-11-07 18:06:50 -0500
// 103:   #   sleep(10)
// 104:   #   task.value #=> 2013-11-07 18:06:55 -0500
// 105:   #
// 106:   # @example Controlling execution from within the block
// 107:   #   timer_task = Concurrent::TimerTask.new(execution_interval: 1) do |task|
// 108:   #     task.execution_interval.to_i.times{ print 'Boom! ' }
// 109:   #     print "\n"
// 110:   #     task.execution_interval += 1
// 111:   #     if task.execution_interval > 5
// 112:   #       puts 'Stopping...'
// 113:   #       task.shutdown
// 114:   #     end
// 115:   #   end
// 116:   #
// 117:   #   timer_task.execute
// 118:   #   #=> Boom!
// 119:   #   #=> Boom! Boom!
// 120:   #   #=> Boom! Boom! Boom!
// 121:   #   #=> Boom! Boom! Boom! Boom!
// 122:   #   #=> Boom! Boom! Boom! Boom! Boom!
// 123:   #   #=> Stopping...
// 124:   #
// 125:   # @example Observation
// 126:   #   class TaskObserver
// 127:   #     def update(time, result, ex)
// 128:   #       if result
// 129:   #         print "(#{time}) Execution successfully returned #{result}\n"
// 130:   #       else
// 131:   #         print "(#{time}) Execution failed with error #{ex}\n"
// 132:   #       end
// 133:   #     end
// 134:   #   end
// 135:   #
// 136:   #   task = Concurrent::TimerTask.new(execution_interval: 1){ 42 }
// 137:   #   task.add_observer(TaskObserver.new)
// 138:   #   task.execute
// 139:   #   sleep 4
// 140:   #
// 141:   #   #=> (2013-10-13 19:08:58 -0400) Execution successfully returned 42
// 142:   #   #=> (2013-10-13 19:08:59 -0400) Execution successfully returned 42
// 143:   #   #=> (2013-10-13 19:09:00 -0400) Execution successfully returned 42
// 144:   #   task.shutdown
// 145:   #
// 146:   #   task = Concurrent::TimerTask.new(execution_interval: 1){ sleep }
// 147:   #   task.add_observer(TaskObserver.new)
// 148:   #   task.execute
// 149:   #
// 150:   #   #=> (2013-10-13 19:07:25 -0400) Execution timed out
// 151:   #   #=> (2013-10-13 19:07:27 -0400) Execution timed out
// 152:   #   #=> (2013-10-13 19:07:29 -0400) Execution timed out
// 153:   #   task.shutdown
// 154:   #
// 155:   #   task = Concurrent::TimerTask.new(execution_interval: 1){ raise StandardError }
// 156:   #   task.add_observer(TaskObserver.new)
// 157:   #   task.execute
// 158:   #
// 159:   #   #=> (2013-10-13 19:09:37 -0400) Execution failed with error StandardError
// 160:   #   #=> (2013-10-13 19:09:38 -0400) Execution failed with error StandardError
// 161:   #   #=> (2013-10-13 19:09:39 -0400) Execution failed with error StandardError
// 162:   #   task.shutdown
// 163:   #
// 164:   # @see http://ruby-doc.org/stdlib-2.0/libdoc/observer/rdoc/Observable.html
// 165:   # @see http://docs.oracle.com/javase/7/docs/api/java/util/TimerTask.html
// 166:   class TimerTask < RubyExecutorService
// 167:     include Concern::Dereferenceable
// 168:     include Concern::Observable
// 169:
// 170:     # Default `:execution_interval` in seconds.
// 171:     EXECUTION_INTERVAL = 60
// 172:
// 173:     # Maintain the interval between the end of one execution and the start of the next execution.
// 174:     FIXED_DELAY = :fixed_delay
// 175:
// 176:     # Maintain the interval between the start of one execution and the start of the next.
// 177:     # If execution time exceeds the interval, the next execution will start immediately
// 178:     # after the previous execution finishes. Executions will not run concurrently.
// 179:     FIXED_RATE = :fixed_rate
// 180:
// 181:     # Default `:interval_type`
// 182:     DEFAULT_INTERVAL_TYPE = FIXED_DELAY
// 183:
// 184:     # Create a new TimerTask with the given task and configuration.
// 185:     #
// 186:     # @!macro timer_task_initialize
// 187:     #   @param [Hash] opts the options defining task execution.
// 188:     #   @option opts [Float] :execution_interval number of seconds between
// 189:     #     task executions (default: EXECUTION_INTERVAL)
// 190:     #   @option opts [Boolean] :run_now Whether to run the task immediately
// 191:     #     upon instantiation or to wait until the first #  execution_interval
// 192:     #     has passed (default: false)
// 193:     #   @options opts [Symbol] :interval_type method to calculate the interval
// 194:     #     between executions, can be either :fixed_rate or :fixed_delay.
// 195:     #     (default: :fixed_delay)
// 196:     #   @option opts [Executor] executor, default is `global_io_executor`
// 197:     #
// 198:     #   @!macro deref_options
// 199:     #
// 200:     #   @raise ArgumentError when no block is given.
// 201:     #
// 202:     #   @yield to the block after :execution_interval seconds have passed since
// 203:     #     the last yield
// 204:     #   @yieldparam task a reference to the `TimerTask` instance so that the
// 205:     #     block can control its own lifecycle. Necessary since `self` will
// 206:     #     refer to the execution context of the block rather than the running
// 207:     #     `TimerTask`.
// 208:     #
// 209:     #   @return [TimerTask] the new `TimerTask`
// 210:     def initialize(opts = {}, &task)
// 211:       raise ArgumentError.new('no block given') unless block_given?
// 212:       super
// 213:       set_deref_options opts
// 214:     end
// 215:
// 216:     # Is the executor running?
// 217:     #
// 218:     # @return [Boolean] `true` when running, `false` when shutting down or shutdown
// 219:     def running?
// 220:       @running.true?
// 221:     end
// 222:
// 223:     # Execute a previously created `TimerTask`.
// 224:     #
// 225:     # @return [TimerTask] a reference to `self`
// 226:     #
// 227:     # @example Instance and execute in separate steps
// 228:     #   task = Concurrent::TimerTask.new(execution_interval: 10){ print "Hello World\n" }
// 229:     #   task.running? #=> false
// 230:     #   task.execute
// 231:     #   task.running? #=> true
// 232:     #
// 233:     # @example Instance and execute in one line
// 234:     #   task = Concurrent::TimerTask.new(execution_interval: 10){ print "Hello World\n" }.execute
// 235:     #   task.running? #=> true
// 236:     def execute
// 237:       synchronize do
// 238:         if @running.false?
// 239:           @running.make_true
// 240:           @age.increment
// 241:           schedule_next_task(@run_now ? 0 : @execution_interval)
// 242:         end
// 243:       end
// 244:       self
// 245:     end
// 246:
// 247:     # Create and execute a new `TimerTask`.
// 248:     #
// 249:     # @!macro timer_task_initialize
// 250:     #
// 251:     # @example
// 252:     #   task = Concurrent::TimerTask.execute(execution_interval: 10){ print "Hello World\n" }
// 253:     #   task.running? #=> true
// 254:     def self.execute(opts = {}, &task)
// 255:       TimerTask.new(opts, &task).execute
// 256:     end
// 257:
// 258:     # @!attribute [rw] execution_interval
// 259:     # @return [Fixnum] Number of seconds after the task completes before the
// 260:     #   task is performed again.
// 261:     def execution_interval
// 262:       synchronize { @execution_interval }
// 263:     end
// 264:
// 265:     # @!attribute [rw] execution_interval
// 266:     # @return [Fixnum] Number of seconds after the task completes before the
// 267:     #   task is performed again.
// 268:     def execution_interval=(value)
// 269:       if (value = value.to_f) <= 0.0
// 270:         raise ArgumentError.new('must be greater than zero')
// 271:       else
// 272:         synchronize { @execution_interval = value }
// 273:       end
// 274:     end
// 275:
// 276:     # @!attribute [r] interval_type
// 277:     # @return [Symbol] method to calculate the interval between executions
// 278:     attr_reader :interval_type
// 279:
// 280:     # @!attribute [rw] timeout_interval
// 281:     # @return [Fixnum] Number of seconds the task can run before it is
// 282:     #   considered to have failed.
// 283:     def timeout_interval
// 284:       warn 'TimerTask timeouts are now ignored as these were not able to be implemented correctly'
// 285:     end
// 286:
// 287:     # @!attribute [rw] timeout_interval
// 288:     # @return [Fixnum] Number of seconds the task can run before it is
// 289:     #   considered to have failed.
// 290:     def timeout_interval=(value)
// 291:       warn 'TimerTask timeouts are now ignored as these were not able to be implemented correctly'
// 292:     end
// 293:
// 294:     private :post, :<<
// 295:
// 296:     private
// 297:
// 298:     def ns_initialize(opts, &task)
// 299:       set_deref_options(opts)
// 300:
// 301:       self.execution_interval = opts[:execution] || opts[:execution_interval] || EXECUTION_INTERVAL
// 302:       if opts[:interval_type] && ![FIXED_DELAY, FIXED_RATE].include?(opts[:interval_type])
// 303:         raise ArgumentError.new('interval_type must be either :fixed_delay or :fixed_rate')
// 304:       end
// 305:       if opts[:timeout] || opts[:timeout_interval]
// 306:         warn 'TimeTask timeouts are now ignored as these were not able to be implemented correctly'
// 307:       end
// 308:
// 309:       @run_now = opts[:now] || opts[:run_now]
// 310:       @interval_type = opts[:interval_type] || DEFAULT_INTERVAL_TYPE
// 311:       @task = Concurrent::SafeTaskExecutor.new(task)
// 312:       @executor = opts[:executor] || Concurrent.global_io_executor
// 313:       @running = Concurrent::AtomicBoolean.new(false)
// 314:       @age = Concurrent::AtomicFixnum.new(0)
// 315:       @value = nil
// 316:
// 317:       self.observers = Collection::CopyOnNotifyObserverSet.new
// 318:     end
// 319:
// 320:     # @!visibility private
// 321:     def ns_shutdown_execution
// 322:       @running.make_false
// 323:       super
// 324:     end
// 325:
// 326:     # @!visibility private
// 327:     def ns_kill_execution
// 328:       @running.make_false
// 329:       super
// 330:     end
// 331:
// 332:     # @!visibility private
// 333:     def schedule_next_task(interval = execution_interval)
// 334:       ScheduledTask.execute(interval, executor: @executor, args: [Concurrent::Event.new, @age.value], &method(:execute_task))
// 335:       nil
// 336:     end
// 337:
// 338:     # @!visibility private
// 339:     def execute_task(completion, age_when_scheduled)
// 340:       return nil unless @running.true?
// 341:       return nil unless @age.value == age_when_scheduled
// 342:
// 343:       start_time = Concurrent.monotonic_time
// 344:       _success, value, reason = @task.execute(self)
// 345:       if completion.try?
// 346:         self.value = value
// 347:         schedule_next_task(calculate_next_interval(start_time))
// 348:         time = Time.now
// 349:         observers.notify_observers do
// 350:           [time, self.value, reason]
// 351:         end
// 352:       end
// 353:       nil
// 354:     end
// 355:
// 356:     # @!visibility private
// 357:     def calculate_next_interval(start_time)
// 358:       if @interval_type == FIXED_RATE
// 359:         run_time = Concurrent.monotonic_time - start_time
// 360:         [execution_interval - run_time, 0].max
// 361:       else # FIXED_DELAY
// 362:         execution_interval
// 363:       end
// 364:     end
// 365:   end
// 366: end
