module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/serialized_execution.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize()` at line 11.
pub fn ruby_serialized_execution_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `call` at line 17.
pub fn ruby_serialized_execution_l17_d2_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('call', ...args)
}

// Ruby method `post(executor, *args, &task)` at line 34.
pub fn ruby_serialized_execution_l34_d3_post(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('post', ...args)
}

// Ruby method `posts(posts)` at line 44.
pub fn ruby_serialized_execution_l44_d4_posts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('posts', ...args)
}

// Ruby method `ns_initialize` at line 70.
pub fn ruby_serialized_execution_l70_d5_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `call_job(job)` at line 75.
pub fn ruby_serialized_execution_l75_d6_call_job(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('call_job', ...args)
}

// Ruby method `work(job)` at line 95.
pub fn ruby_serialized_execution_l95_d7_work(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('work', ...args)
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
