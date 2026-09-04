module executor

import ruby
import os
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/timer_set.rb`.
// The original source is retained below until every stub has a typed V body.
pub type TimerSetDispatch = fn(voidptr) bool

pub struct TimerSetTask {
pub:
	context       voidptr
	initial_delay f64
	schedule_time f64
	dispatch      TimerSetDispatch @[required]
}

@[heap]
pub struct TimerSet {
	mutex &sync.Mutex
	wake  chan bool
mut:
	tasks      []TimerSetTask
	running    bool
	stopped    bool
	processing bool
	ruby_pid   int
}

pub fn new_timer_set() &TimerSet {
	return &TimerSet{
		mutex: sync.new_mutex()
		wake: chan bool{ cap: 1 }
		running: true
		ruby_pid: os.getpid()
	}
}

pub fn monotonic_seconds() f64 {
	return f64(time.sys_mono_now()) / f64(time.second)
}

fn signal_timer_set(timer &TimerSet) {
	select {
		timer.wake <- true {
		}
		else {
		}
	}
}

pub fn (mut timer TimerSet) is_running() bool {
	timer.mutex.lock()
	running := timer.running
	timer.mutex.unlock()
	return running
}

pub fn (mut timer TimerSet) is_shutdown() bool {
	timer.mutex.lock()
	stopped := timer.stopped
	timer.mutex.unlock()
	return stopped
}

pub fn (mut timer TimerSet) queue_length() int {
	timer.mutex.lock()
	length := timer.tasks.len
	timer.mutex.unlock()
	return length
}

fn timer_set_insert(mut tasks []TimerSetTask, task TimerSetTask) {
	mut index := 0
	for index < tasks.len && tasks[index].schedule_time <= task.schedule_time {
		index++
	}
	tasks.insert(index, task)
}

fn run_timer_set(timer_address u64) {
	mut active_timer := unsafe { &TimerSet(voidptr(timer_address)) }
	active_timer.process_tasks()
}

pub fn (mut timer TimerSet) post_task(task TimerSetTask) bool {
	timer.mutex.lock()
	if !timer.running {
		timer.mutex.unlock()
		return false
	}
	timer.ns_reset_if_forked_locked()
	if task.initial_delay <= 0.01 {
		timer.mutex.unlock()
		return task.dispatch(task.context)
	}
	timer_set_insert(mut timer.tasks, task)
	start_worker := !timer.processing
	if start_worker {
		timer.processing = true
	}
	timer.mutex.unlock()
	signal_timer_set(timer)
	if start_worker {
		spawn run_timer_set(u64(voidptr(timer)))
	}
	return true
}

pub fn (mut timer TimerSet) remove_task(task TimerSetTask) bool {
	timer.mutex.lock()
	mut removed := false
	for index, queued in timer.tasks {
		if queued.context == task.context {
			timer.tasks.delete(index)
			removed = true
			break
		}
	}
	timer.mutex.unlock()
	if removed {
		signal_timer_set(timer)
	}
	return removed
}

pub fn (mut timer TimerSet) shutdown() bool {
	timer.mutex.lock()
	if timer.running {
		timer.ns_reset_if_forked_locked()
		timer.running = false
		timer.tasks.clear()
		if !timer.processing {
			timer.stopped = true
		}
	}
	timer.mutex.unlock()
	signal_timer_set(timer)
	return true
}

pub fn (mut timer TimerSet) kill() bool {
	return timer.shutdown()
}

pub fn (mut timer TimerSet) wait_for_termination(timeout time.Duration) bool {
	started := time.sys_mono_now()
	for {
		if timer.is_shutdown() {
			return true
		}
		if timeout >= 0 && time.sys_mono_now() - started >= u64(timeout) {
			return false
		}
		time.sleep(time.millisecond)
	}
	return false
}

fn (mut timer TimerSet) ns_reset_if_forked_locked() {
	pid := os.getpid()
	if pid != timer.ruby_pid {
		timer.tasks.clear()
		timer.ruby_pid = pid
	}
}

pub fn (mut timer TimerSet) reset_if_forked() bool {
	timer.mutex.lock()
	previous := timer.ruby_pid
	timer.ns_reset_if_forked_locked()
	changed := previous != timer.ruby_pid
	timer.mutex.unlock()
	return changed
}

pub fn (mut timer TimerSet) process_tasks() {
	for {
		timer.mutex.lock()
		if !timer.running || timer.tasks.len == 0 {
			timer.processing = false
			if !timer.running {
				timer.stopped = true
			}
			timer.mutex.unlock()
			return
		}
		now := monotonic_seconds()
		difference := timer.tasks[0].schedule_time - now
		if difference <= 0 {
			task := timer.tasks[0]
			timer.tasks.delete(0)
			timer.mutex.unlock()
			task.dispatch(task.context)
			continue
		}
		timer.mutex.unlock()
		maximum_wait := 60 * time.second
		requested_wait := time.Duration(difference * f64(time.second))
		wait := if requested_wait < maximum_wait { requested_wait } else { maximum_wait }
		select {
			_ := <-timer.wake {
			}
			wait {
			}
		}
	}
}

@[heap]
struct BoundaryTimerSetTask {
	result ruby.Value
mut:
	fired bool
}

fn dispatch_boundary_timer_set_task(context voidptr) bool {
	mut task := unsafe { &BoundaryTimerSetTask(context) }
	task.fired = true
	return true
}

fn timer_set_boundary_value(timer &TimerSet) ruby.Value {
	return ruby.structured_value('Concurrent::TimerSet', '#<Concurrent::TimerSet>', {
		'timer_set_address': u64(voidptr(timer)).str()
	})
}

pub fn timer_set_from_value(value ruby.Value) &TimerSet {
	address := (value.attribute('timer_set_address') or {
		panic('${value.type_name} has no translated TimerSet state')
	}).u64()
	return unsafe { &TimerSet(voidptr(address)) }
}

fn timer_set_task_from_value(value ruby.Value) TimerSetTask {
	address := (value.attribute('timer_set_task_address') or {
		panic('${value.type_name} has no translated TimerSet task state')
	}).u64()
	task := unsafe { &TimerSetTask(voidptr(address)) }
	return *task
}

fn boundary_timer_task_value(task &TimerSetTask) ruby.Value {
	return ruby.structured_value('Concurrent::ScheduledTask', '#<Concurrent::ScheduledTask>', {
		'timer_set_task_address': u64(voidptr(task)).str()
	})
}

// Ruby method `initialize(opts = {})` at line 30.
pub fn ruby_timer_set_l30_d1_initialize(args ...ruby.Value) ruby.Value {
	return timer_set_boundary_value(new_timer_set())
}

// Ruby method `post(delay, *args, &task)` at line 48.
pub fn ruby_timer_set_l48_d2_post(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('ArgumentError: no block given')
	}
	mut timer := timer_set_from_value(args[0])
	if !timer.is_running() {
		return ruby.bool_value(false)
	}
	delay := args[1].as_float() or { panic(err) }
	if delay < 0 {
		panic('ArgumentError: seconds must be greater than zero')
	}
	payload := &BoundaryTimerSetTask{
		result: args[args.len - 1]
	}
	task := &TimerSetTask{
		context: voidptr(payload)
		initial_delay: delay
		schedule_time: monotonic_seconds() + delay
		dispatch: dispatch_boundary_timer_set_task
	}
	if !timer.post_task(*task) {
		return ruby.bool_value(false)
	}
	return boundary_timer_task_value(task)
}

// Ruby method `kill` at line 62.
pub fn ruby_timer_set_l62_d3_kill(args ...ruby.Value) ruby.Value {
	mut timer := timer_set_from_value(args[0])
	return ruby.bool_value(timer.kill())
}

// Ruby method `ns_initialize(opts)` at line 75.
pub fn ruby_timer_set_l75_d4_ns_initialize(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		_ := args[0].attribute('timer_set_address') or {
			return timer_set_boundary_value(new_timer_set())
		}
		return args[0]
	}
	return timer_set_boundary_value(new_timer_set())
}

// Ruby method `post_task(task)` at line 90.
pub fn ruby_timer_set_l90_d5_post_task(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TimerSet#post_task requires a task')
	}
	mut timer := timer_set_from_value(args[0])
	return ruby.bool_value(timer.post_task(timer_set_task_from_value(args[1])))
}

// Ruby method `ns_post_task(task)` at line 95.
pub fn ruby_timer_set_l95_d6_ns_post_task(args ...ruby.Value) ruby.Value {
	return ruby_timer_set_l90_d5_post_task(...args)
}

// Ruby method `remove_task(task)` at line 116.
pub fn ruby_timer_set_l116_d7_remove_task(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TimerSet#remove_task requires a task')
	}
	mut timer := timer_set_from_value(args[0])
	return ruby.bool_value(timer.remove_task(timer_set_task_from_value(args[1])))
}

// Ruby method `ns_shutdown_execution` at line 123.
pub fn ruby_timer_set_l123_d8_ns_shutdown_execution(args ...ruby.Value) ruby.Value {
	mut timer := timer_set_from_value(args[0])
	return ruby.bool_value(timer.shutdown())
}

// Ruby method `ns_reset_if_forked` at line 132.
pub fn ruby_timer_set_l132_d9_ns_reset_if_forked(args ...ruby.Value) ruby.Value {
	mut timer := timer_set_from_value(args[0])
	timer.reset_if_forked()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `process_tasks` at line 146.
pub fn ruby_timer_set_l146_d10_process_tasks(args ...ruby.Value) ruby.Value {
	mut timer := timer_set_from_value(args[0])
	timer.process_tasks()
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/scheduled_task'
// 2: require 'concurrent/atomic/event'
// 3: require 'concurrent/collection/non_concurrent_priority_queue'
// 4: require 'concurrent/executor/executor_service'
// 5: require 'concurrent/executor/single_thread_executor'
// 6: require 'concurrent/errors'
// 7: require 'concurrent/options'
// 8:
// 9: module Concurrent
// 10:
// 11:   # Executes a collection of tasks, each after a given delay. A master task
// 12:   # monitors the set and schedules each task for execution at the appropriate
// 13:   # time. Tasks are run on the global thread pool or on the supplied executor.
// 14:   # Each task is represented as a `ScheduledTask`.
// 15:   #
// 16:   # @see Concurrent::ScheduledTask
// 17:   #
// 18:   # @!macro monotonic_clock_warning
// 19:   class TimerSet < RubyExecutorService
// 20:
// 21:     # Create a new set of timed tasks.
// 22:     #
// 23:     # @!macro executor_options
// 24:     #
// 25:     #   @param [Hash] opts the options used to specify the executor on which to perform actions
// 26:     #   @option opts [Executor] :executor when set use the given `Executor` instance.
// 27:     #     Three special values are also supported: `:task` returns the global task pool,
// 28:     #     `:operation` returns the global operation pool, and `:immediate` returns a new
// 29:     #     `ImmediateExecutor` object.
// 30:     def initialize(opts = {})
// 31:       super(opts)
// 32:     end
// 33:
// 34:     # Post a task to be execute run after a given delay (in seconds). If the
// 35:     # delay is less than 1/100th of a second the task will be immediately post
// 36:     # to the executor.
// 37:     #
// 38:     # @param [Float] delay the number of seconds to wait for before executing the task.
// 39:     # @param [Array<Object>] args the arguments passed to the task on execution.
// 40:     #
// 41:     # @yield the task to be performed.
// 42:     #
// 43:     # @return [Concurrent::ScheduledTask, false] IVar representing the task if the post
// 44:     #   is successful; false after shutdown.
// 45:     #
// 46:     # @raise [ArgumentError] if the intended execution time is not in the future.
// 47:     # @raise [ArgumentError] if no block is given.
// 48:     def post(delay, *args, &task)
// 49:       raise ArgumentError.new('no block given') unless block_given?
// 50:       return false unless running?
// 51:       opts = { executor:  @task_executor,
// 52:                args:      args,
// 53:                timer_set: self }
// 54:       task = ScheduledTask.execute(delay, opts, &task) # may raise exception
// 55:       task.unscheduled? ? false : task
// 56:     end
// 57:
// 58:     # Begin an immediate shutdown. In-progress tasks will be allowed to
// 59:     # complete but enqueued tasks will be dismissed and no new tasks
// 60:     # will be accepted. Has no additional effect if the thread pool is
// 61:     # not running.
// 62:     def kill
// 63:       shutdown
// 64:       @timer_executor.kill
// 65:     end
// 66:
// 67:     private :<<
// 68:
// 69:     private
// 70:
// 71:     # Initialize the object.
// 72:     #
// 73:     # @param [Hash] opts the options to create the object with.
// 74:     # @!visibility private
// 75:     def ns_initialize(opts)
// 76:       @queue              = Collection::NonConcurrentPriorityQueue.new(order: :min)
// 77:       @task_executor      = Options.executor_from_options(opts) || Concurrent.global_io_executor
// 78:       @timer_executor     = SingleThreadExecutor.new
// 79:       @condition          = Event.new
// 80:       @ruby_pid           = $$ # detects if Ruby has forked
// 81:     end
// 82:
// 83:     # Post the task to the internal queue.
// 84:     #
// 85:     # @note This is intended as a callback method from ScheduledTask
// 86:     #   only. It is not intended to be used directly. Post a task
// 87:     #   by using the `SchedulesTask#execute` method.
// 88:     #
// 89:     # @!visibility private
// 90:     def post_task(task)
// 91:       synchronize { ns_post_task(task) }
// 92:     end
// 93:
// 94:     # @!visibility private
// 95:     def ns_post_task(task)
// 96:       return false unless ns_running?
// 97:       ns_reset_if_forked
// 98:       if (task.initial_delay) <= 0.01
// 99:         task.executor.post { task.process_task }
// 100:       else
// 101:         @queue.push(task)
// 102:         # only post the process method when the queue is empty
// 103:         @timer_executor.post(&method(:process_tasks)) if @queue.length == 1
// 104:         @condition.set
// 105:       end
// 106:       true
// 107:     end
// 108:
// 109:     # Remove the given task from the queue.
// 110:     #
// 111:     # @note This is intended as a callback method from `ScheduledTask`
// 112:     #   only. It is not intended to be used directly. Cancel a task
// 113:     #   by using the `ScheduledTask#cancel` method.
// 114:     #
// 115:     # @!visibility private
// 116:     def remove_task(task)
// 117:       synchronize { @queue.delete(task) }
// 118:     end
// 119:
// 120:     # `ExecutorService` callback called during shutdown.
// 121:     #
// 122:     # @!visibility private
// 123:     def ns_shutdown_execution
// 124:       ns_reset_if_forked
// 125:       @queue.clear
// 126:       @condition.set
// 127:       @condition.reset
// 128:       @timer_executor.shutdown
// 129:       stopped_event.set
// 130:     end
// 131:
// 132:     def ns_reset_if_forked
// 133:       if $$ != @ruby_pid
// 134:         @queue.clear
// 135:         @condition.reset
// 136:         @ruby_pid = $$
// 137:       end
// 138:     end
// 139:
// 140:     # Run a loop and execute tasks in the scheduled order and at the approximate
// 141:     # scheduled time. If no tasks remain the thread will exit gracefully so that
// 142:     # garbage collection can occur. If there are no ready tasks it will sleep
// 143:     # for up to 60 seconds waiting for the next scheduled task.
// 144:     #
// 145:     # @!visibility private
// 146:     def process_tasks
// 147:       loop do
// 148:         task = synchronize { @condition.reset; @queue.peek }
// 149:         break unless task
// 150:
// 151:         now  = Concurrent.monotonic_time
// 152:         diff = task.schedule_time - now
// 153:
// 154:         if diff <= 0
// 155:           # We need to remove the task from the queue before passing
// 156:           # it to the executor, to avoid race conditions where we pass
// 157:           # the peek'ed task to the executor and then pop a different
// 158:           # one that's been added in the meantime.
// 159:           #
// 160:           # Note that there's no race condition between the peek and
// 161:           # this pop - this pop could retrieve a different task from
// 162:           # the peek, but that task would be due to fire now anyway
// 163:           # (because @queue is a priority queue, and this thread is
// 164:           # the only reader, so whatever timer is at the head of the
// 165:           # queue now must have the same pop time, or a closer one, as
// 166:           # when we peeked).
// 167:           task = synchronize { @queue.pop }
// 168:           begin
// 169:             task.executor.post { task.process_task }
// 170:           rescue RejectedExecutionError
// 171:             # ignore and continue
// 172:           end
// 173:         else
// 174:           @condition.wait([diff, 60].min)
// 175:         end
// 176:       end
// 177:     end
// 178:   end
// 179: end
