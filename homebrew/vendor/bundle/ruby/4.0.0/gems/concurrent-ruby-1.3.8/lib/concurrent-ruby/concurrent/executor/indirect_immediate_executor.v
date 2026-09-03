module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/indirect_immediate_executor.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct IndirectImmediateExecutor {
mut:
	immediate &ImmediateExecutor
}

pub fn new_indirect_immediate_executor() &IndirectImmediateExecutor {
	return &IndirectImmediateExecutor{
		immediate: new_immediate_executor()
	}
}

pub fn (mut executor IndirectImmediateExecutor) post(task ImmediateTask, args []brew_runtime.Value) bool {
	if !executor.immediate.running() {
		return false
	}
	worker := spawn task(args.clone())
	worker.wait()
	return true
}

pub fn (mut executor IndirectImmediateExecutor) shutdown() bool {
	return executor.immediate.shutdown()
}

// Ruby method `initialize` at line 21.
pub fn ruby_indirect_immediate_executor_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('IndirectImmediateExecutor', '#<Concurrent::IndirectImmediateExecutor>', {
		'stopped': 'false'
	})
}

// Ruby method `post(*args, &task)` at line 27.
pub fn ruby_indirect_immediate_executor_l27_d2_post(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/executor/immediate_executor'
// 2: require 'concurrent/executor/simple_executor_service'
// 3:
// 4: module Concurrent
// 5:   # An executor service which runs all operations on a new thread, blocking
// 6:   # until it completes. Operations are performed in the order they are received
// 7:   # and no two operations can be performed simultaneously.
// 8:   #
// 9:   # This executor service exists mainly for testing an debugging. When used it
// 10:   # immediately runs every `#post` operation on a new thread, blocking the
// 11:   # current thread until the operation is complete. This is similar to how the
// 12:   # ImmediateExecutor works, but the operation has the full stack of the new
// 13:   # thread at its disposal. This can be helpful when the operations will spawn
// 14:   # more operations on the same executor and so on - such a situation might
// 15:   # overflow the single stack in case of an ImmediateExecutor, which is
// 16:   # inconsistent with how it would behave for a threaded executor.
// 17:   #
// 18:   # @note Intended for use primarily in testing and debugging.
// 19:   class IndirectImmediateExecutor < ImmediateExecutor
// 20:     # Creates a new executor
// 21:     def initialize
// 22:       super
// 23:       @internal_executor = SimpleExecutorService.new
// 24:     end
// 25:
// 26:     # @!macro executor_service_method_post
// 27:     def post(*args, &task)
// 28:       raise ArgumentError.new("no block given") unless block_given?
// 29:       return false unless running?
// 30:
// 31:       event = Concurrent::Event.new
// 32:       @internal_executor.post do
// 33:         begin
// 34:           task.call(*args)
// 35:         ensure
// 36:           event.set
// 37:         end
// 38:       end
// 39:       event.wait
// 40:
// 41:       true
// 42:     end
// 43:   end
// 44: end
