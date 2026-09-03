module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/serialized_execution_delegator.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct SerializedExecutionDelegator {
mut:
	executor   ExecutorAdapter
	serializer &SerializedExecution
}

pub fn new_serialized_execution_delegator(executor ExecutorAdapter) &SerializedExecutionDelegator {
	return &SerializedExecutionDelegator{
		executor: executor
		serializer: new_serialized_execution()
	}
}

pub fn (mut delegator SerializedExecutionDelegator) post(task ExecutorTask, args []brew_runtime.Value) bool {
	if !delegator.executor.running() {
		return false
	}
	return delegator.serializer.post(delegator.executor, task, args)
}

pub fn (mut delegator SerializedExecutionDelegator) running() bool {
	return delegator.executor.running()
}

pub fn (delegator &SerializedExecutionDelegator) serialized() bool {
	return true
}

fn serialized_delegator_boundary_value(delegator &SerializedExecutionDelegator) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::SerializedExecutionDelegator', '#<Concurrent::SerializedExecutionDelegator>', {
		'serialized_delegator_address': u64(voidptr(delegator)).str()
	})
}

fn serialized_delegator_boundary_receiver(args []brew_runtime.Value) &SerializedExecutionDelegator {
	if args.len == 0 {
		panic('SerializedExecutionDelegator method requires a receiver')
	}
	address := (args[0].attribute('serialized_delegator_address') or {
		panic('${args[0].type_name} has no translated SerializedExecutionDelegator state')
	}).u64()
	return unsafe { &SerializedExecutionDelegator(voidptr(address)) }
}

// Ruby method `initialize(executor)` at line 15.
pub fn ruby_serialized_execution_delegator_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return serialized_delegator_boundary_value(new_serialized_execution_delegator(boundary_executor_adapter()))
}

// Ruby method `post(*args, &task)` at line 22.
pub fn ruby_serialized_execution_delegator_l22_d2_post(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ArgumentError: no block given')
	}
	mut delegator := serialized_delegator_boundary_receiver(args)
	return brew_runtime.bool_value(delegator.post(boundary_noop_executor_task, args[1..].clone()))
}

// Original Ruby source (line-for-line):
// 1: require 'delegate'
// 2: require 'concurrent/executor/serial_executor_service'
// 3: require 'concurrent/executor/serialized_execution'
// 4:
// 5: module Concurrent
// 6:
// 7:   # A wrapper/delegator for any `ExecutorService` that
// 8:   # guarantees serialized execution of tasks.
// 9:   #
// 10:   # @see [SimpleDelegator](http://www.ruby-doc.org/stdlib-2.1.2/libdoc/delegate/rdoc/SimpleDelegator.html)
// 11:   # @see Concurrent::SerializedExecution
// 12:   class SerializedExecutionDelegator < SimpleDelegator
// 13:     include SerialExecutorService
// 14:
// 15:     def initialize(executor)
// 16:       @executor   = executor
// 17:       @serializer = SerializedExecution.new
// 18:       super(executor)
// 19:     end
// 20:
// 21:     # @!macro executor_service_method_post
// 22:     def post(*args, &task)
// 23:       raise ArgumentError.new('no block given') unless block_given?
// 24:       return false unless running?
// 25:       @serializer.post(@executor, *args, &task)
// 26:     end
// 27:   end
// 28: end
