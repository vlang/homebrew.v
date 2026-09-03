module executor

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/serialized_execution.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SerializedPost {
pub:
	executor ExecutorAdapter
	args     []brew_runtime.Value
	task     ExecutorTask @[required]
}

@[heap]
pub struct SerializedJob {
pub:
	executor ExecutorAdapter
	args     []brew_runtime.Value
	task     ExecutorTask @[required]
}

pub fn (job &SerializedJob) call() ! {
	job.task(job.args)!
}

@[heap]
pub struct SerializedExecution {
mut:
	lock           sync.Mutex
	being_executed bool
	stash          []&SerializedJob
}

pub fn new_serialized_execution() &SerializedExecution {
	return &SerializedExecution{}
}

pub fn (mut serialization SerializedExecution) post(executor ExecutorAdapter, task ExecutorTask, args []brew_runtime.Value) bool {
	serialization.posts([
		SerializedPost{
			executor: executor
			args: args.clone()
			task: task
		},
	])
	return true
}

pub fn (mut serialization SerializedExecution) posts(posts []SerializedPost) ?bool {
	if posts.len == 0 {
		return none
	}
	mut jobs := []&SerializedJob{cap: posts.len}
	for post in posts {
		jobs << &SerializedJob{
			executor: post.executor
			args: post.args.clone()
			task: post.task
		}
	}
	serialization.lock.lock()
	mut first := &SerializedJob(unsafe { nil })
	if serialization.being_executed {
		serialization.stash << jobs
	} else {
		serialization.being_executed = true
		if jobs.len > 1 {
			serialization.stash << jobs[1..]
		}
		first = jobs[0]
	}
	serialization.lock.unlock()
	if !isnil(first) {
		serialization.call_job(first)
	}
	return true
}

fn (mut serialization SerializedExecution) call_job(job &SerializedJob) {
	accepted := job.executor.post(serialized_job_executor_task, [
		brew_runtime.structured_value('Concurrent::SerializedExecution', '#<Concurrent::SerializedExecution>', {
			'serialized_execution_address': u64(voidptr(&serialization)).str()
		}),
		serialized_job_boundary_value(job),
	])
	// Ruby retries rejected jobs on the caller so the serialized chain cannot stall.
	if !accepted {
		serialization.work(job) or {
			// Source logs the task failure at DEBUG after running the rejected job itself.
		}
	}
}

pub fn (mut serialization SerializedExecution) work(job &SerializedJob) ! {
	mut task_error := ''
	job.call() or { task_error = err.msg() }
	serialization.lock.lock()
	mut next := &SerializedJob(unsafe { nil })
	if serialization.stash.len > 0 {
		next = serialization.stash[0]
		serialization.stash.delete(0)
	} else {
		serialization.being_executed = false
	}
	serialization.lock.unlock()
	if !isnil(next) {
		serialization.call_job(next)
	}
	if task_error.len > 0 {
		return error(task_error)
	}
}

pub fn (mut serialization SerializedExecution) active() bool {
	serialization.lock.lock()
	value := serialization.being_executed
	serialization.lock.unlock()
	return value
}

pub fn (mut serialization SerializedExecution) queued_count() int {
	serialization.lock.lock()
	value := serialization.stash.len
	serialization.lock.unlock()
	return value
}

fn serialized_job_executor_task(args []brew_runtime.Value) ! {
	if args.len < 2 {
		return error('SerializedExecution worker requires serializer and job')
	}
	mut serialization := serialized_execution_boundary_receiver(args)
	job := serialized_job_boundary_receiver(args[1])
	serialization.work(job)!
}

fn serialized_execution_boundary_value(serialization &SerializedExecution) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::SerializedExecution', '#<Concurrent::SerializedExecution>', {
		'serialized_execution_address': u64(voidptr(serialization)).str()
	})
}

fn serialized_execution_boundary_receiver(args []brew_runtime.Value) &SerializedExecution {
	if args.len == 0 {
		panic('SerializedExecution method requires a receiver')
	}
	address := (args[0].attribute('serialized_execution_address') or {
		panic('${args[0].type_name} has no translated SerializedExecution state')
	}).u64()
	return unsafe { &SerializedExecution(voidptr(address)) }
}

fn serialized_job_boundary_value(job &SerializedJob) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::SerializedExecution::Job', '#<Concurrent::SerializedExecution::Job>', {
		'serialized_job_address': u64(voidptr(job)).str()
	})
}

fn serialized_job_boundary_receiver(value brew_runtime.Value) &SerializedJob {
	address := (value.attribute('serialized_job_address') or {
		panic('${value.type_name} has no translated SerializedExecution::Job state')
	}).u64()
	return unsafe { &SerializedJob(voidptr(address)) }
}

fn boundary_executor_adapter() ExecutorAdapter {
	return ExecutorAdapter{
		context: unsafe { nil }
		post_task: boundary_executor_post
		is_running: boundary_executor_running
	}
}

fn boundary_executor_post(context voidptr, task ExecutorTask, args []brew_runtime.Value) bool {
	_ = context
	task(args) or { return false }
	return true
}

fn boundary_executor_running(context voidptr) bool {
	_ = context
	return true
}

// Ruby method `initialize()` at line 11.
pub fn ruby_serialized_execution_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return serialized_execution_boundary_value(new_serialized_execution())
}

// Ruby method `call` at line 17.
pub fn ruby_serialized_execution_l17_d2_call(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SerializedExecution::Job#call requires a receiver')
	}
	job := serialized_job_boundary_receiver(args[0])
	job.call() or { panic(err) }
	return nil_executor_value()
}

// Ruby method `post(executor, *args, &task)` at line 34.
pub fn ruby_serialized_execution_l34_d3_post(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SerializedExecution#post requires a receiver')
	}
	mut serialization := serialized_execution_boundary_receiver(args)
	job_args := if args.len > 1 { args[1..].clone() } else { []brew_runtime.Value{} }
	return brew_runtime.bool_value(serialization.post(boundary_executor_adapter(), boundary_noop_executor_task, job_args))
}

// Ruby method `posts(posts)` at line 44.
pub fn ruby_serialized_execution_l44_d4_posts(args ...brew_runtime.Value) brew_runtime.Value {
	mut serialization := serialized_execution_boundary_receiver(args)
	if args.len < 2 || args[1].type_name != 'Array' {
		return nil_executor_value()
	}
	values := args[1].as_array() or { panic(err) }
	if values.len == 0 {
		return nil_executor_value()
	}
	posts := values.map(SerializedPost{
		executor: boundary_executor_adapter()
		args: [it]
		task: boundary_noop_executor_task
	})
	return brew_runtime.bool_value(serialization.posts(posts) or { false })
}

// Ruby method `ns_initialize` at line 70.
pub fn ruby_serialized_execution_l70_d5_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut serialization := serialized_execution_boundary_receiver(args)
	serialization.lock.lock()
	serialization.being_executed = false
	serialization.stash.clear()
	serialization.lock.unlock()
	return nil_executor_value()
}

// Ruby method `call_job(job)` at line 75.
pub fn ruby_serialized_execution_l75_d6_call_job(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SerializedExecution#call_job requires a job')
	}
	mut serialization := serialized_execution_boundary_receiver(args)
	serialization.call_job(serialized_job_boundary_receiver(args[1]))
	return nil_executor_value()
}

// Ruby method `work(job)` at line 95.
pub fn ruby_serialized_execution_l95_d7_work(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SerializedExecution#work requires a job')
	}
	mut serialization := serialized_execution_boundary_receiver(args)
	serialization.work(serialized_job_boundary_receiver(args[1])) or { panic(err) }
	return nil_executor_value()
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/errors'
// 2: require 'concurrent/concern/logging'
// 3: require 'concurrent/synchronization/lockable_object'
// 4:
// 5: module Concurrent
// 6:
// 7:   # Ensures passed jobs in a serialized order never running at the same time.
// 8:   class SerializedExecution < Synchronization::LockableObject
// 9:     include Concern::Logging
// 10:
// 11:     def initialize()
// 12:       super()
// 13:       synchronize { ns_initialize }
// 14:     end
// 15:
// 16:     Job = Struct.new(:executor, :args, :block) do
// 17:       def call
// 18:         block.call(*args)
// 19:       end
// 20:     end
// 21:
// 22:     # Submit a task to the executor for asynchronous processing.
// 23:     #
// 24:     # @param [Executor] executor to be used for this job
// 25:     #
// 26:     # @param [Array] args zero or more arguments to be passed to the task
// 27:     #
// 28:     # @yield the asynchronous task to perform
// 29:     #
// 30:     # @return [Boolean] `true` if the task is queued, `false` if the executor
// 31:     #   is not running
// 32:     #
// 33:     # @raise [ArgumentError] if no task is given
// 34:     def post(executor, *args, &task)
// 35:       posts [[executor, args, task]]
// 36:       true
// 37:     end
// 38:
// 39:     # As {#post} but allows to submit multiple tasks at once, it's guaranteed that they will not
// 40:     # be interleaved by other tasks.
// 41:     #
// 42:     # @param [Array<Array(ExecutorService, Array<Object>, Proc)>] posts array of triplets where
// 43:     #   first is a {ExecutorService}, second is array of args for task, third is a task (Proc)
// 44:     def posts(posts)
// 45:       # if can_overflow?
// 46:       #   raise ArgumentError, 'SerializedExecution does not support thread-pools which can overflow'
// 47:       # end
// 48:
// 49:       return nil if posts.empty?
// 50:
// 51:       jobs = posts.map { |executor, args, task| Job.new executor, args, task }
// 52:
// 53:       job_to_post = synchronize do
// 54:         if @being_executed
// 55:           @stash.push(*jobs)
// 56:           nil
// 57:         else
// 58:           @being_executed = true
// 59:           @stash.push(*jobs[1..-1])
// 60:           jobs.first
// 61:         end
// 62:       end
// 63:
// 64:       call_job job_to_post if job_to_post
// 65:       true
// 66:     end
// 67:
// 68:     private
// 69:
// 70:     def ns_initialize
// 71:       @being_executed = false
// 72:       @stash          = []
// 73:     end
// 74:
// 75:     def call_job(job)
// 76:       did_it_run = begin
// 77:                      job.executor.post { work(job) }
// 78:                      true
// 79:                    rescue RejectedExecutionError => ex
// 80:                      false
// 81:                    end
// 82:
// 83:       # TODO not the best idea to run it myself
// 84:       unless did_it_run
// 85:         begin
// 86:           work job
// 87:         rescue => ex
// 88:           # let it fail
// 89:           log DEBUG, ex
// 90:         end
// 91:       end
// 92:     end
// 93:
// 94:     # ensures next job is executed if any is stashed
// 95:     def work(job)
// 96:       job.call
// 97:     ensure
// 98:       synchronize do
// 99:         job = @stash.shift || (@being_executed = false)
// 100:       end
// 101:
// 102:       # TODO maybe be able to tell caching pool to just enqueue this job, because the current one end at the end
// 103:       # of this block
// 104:       call_job job if job
// 105:     end
// 106:   end
// 107: end
