module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/java_executor_service.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `post(*args, &task)` at line 21.
pub fn ruby_java_executor_service_l21_d1_post(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('post', ...args)
}

// Ruby method `wait_for_termination(timeout = nil)` at line 30.
pub fn ruby_java_executor_service_l30_d2_wait_for_termination(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait_for_termination', ...args)
}

// Ruby method `shutdown` at line 39.
pub fn ruby_java_executor_service_l39_d3_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shutdown', ...args)
}

// Ruby method `kill` at line 46.
pub fn ruby_java_executor_service_l46_d4_kill(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('kill', ...args)
}

// Ruby method `ns_running?` at line 56.
pub fn ruby_java_executor_service_l56_d5_ns_running(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_running?', ...args)
}

// Ruby method `ns_shuttingdown?` at line 60.
pub fn ruby_java_executor_service_l60_d6_ns_shuttingdown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_shuttingdown?', ...args)
}

// Ruby method `ns_shutdown?` at line 64.
pub fn ruby_java_executor_service_l64_d7_ns_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_shutdown?', ...args)
}

// Ruby method `initialize(args, block)` at line 70.
pub fn ruby_java_executor_service_l70_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run` at line 75.
pub fn ruby_java_executor_service_l75_d9_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `initialize(daemonize = true)` at line 86.
pub fn ruby_java_executor_service_l86_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `newThread(runnable)` at line 91.
pub fn ruby_java_executor_service_l91_d11_newthread(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('newThread', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2:
// 3: if Concurrent.on_jruby?
// 4:   require 'concurrent/errors'
// 5:   require 'concurrent/executor/abstract_executor_service'
// 6:
// 7:   module Concurrent
// 8:
// 9:     # @!macro abstract_executor_service_public_api
// 10:     # @!visibility private
// 11:     class JavaExecutorService < AbstractExecutorService
// 12:       java_import 'java.lang.Runnable'
// 13:
// 14:       FALLBACK_POLICY_CLASSES = {
// 15:         abort:       java.util.concurrent.ThreadPoolExecutor::AbortPolicy,
// 16:         discard:     java.util.concurrent.ThreadPoolExecutor::DiscardPolicy,
// 17:         caller_runs: java.util.concurrent.ThreadPoolExecutor::CallerRunsPolicy
// 18:       }.freeze
// 19:       private_constant :FALLBACK_POLICY_CLASSES
// 20:
// 21:       def post(*args, &task)
// 22:         raise ArgumentError.new('no block given') unless block_given?
// 23:         return fallback_action(*args, &task).call unless running?
// 24:         @executor.submit Job.new(args, task)
// 25:         true
// 26:       rescue Java::JavaUtilConcurrent::RejectedExecutionException
// 27:         raise RejectedExecutionError
// 28:       end
// 29:
// 30:       def wait_for_termination(timeout = nil)
// 31:         if timeout.nil?
// 32:           ok = @executor.awaitTermination(60, java.util.concurrent.TimeUnit::SECONDS) until ok
// 33:           true
// 34:         else
// 35:           @executor.awaitTermination(1000 * timeout, java.util.concurrent.TimeUnit::MILLISECONDS)
// 36:         end
// 37:       end
// 38:
// 39:       def shutdown
// 40:         synchronize do
// 41:           @executor.shutdown
// 42:           nil
// 43:         end
// 44:       end
// 45:
// 46:       def kill
// 47:         synchronize do
// 48:           @executor.shutdownNow
// 49:           wait_for_termination
// 50:           nil
// 51:         end
// 52:       end
// 53:
// 54:       private
// 55:
// 56:       def ns_running?
// 57:         !(ns_shuttingdown? || ns_shutdown?)
// 58:       end
// 59:
// 60:       def ns_shuttingdown?
// 61:         @executor.isShutdown && !@executor.isTerminated
// 62:       end
// 63:
// 64:       def ns_shutdown?
// 65:         @executor.isTerminated
// 66:       end
// 67:
// 68:       class Job
// 69:         include Runnable
// 70:         def initialize(args, block)
// 71:           @args = args
// 72:           @block = block
// 73:         end
// 74:
// 75:         def run
// 76:           @block.call(*@args)
// 77:         end
// 78:       end
// 79:       private_constant :Job
// 80:     end
// 81:
// 82:     class DaemonThreadFactory
// 83:       # hide include from YARD
// 84:       send :include, java.util.concurrent.ThreadFactory
// 85:
// 86:       def initialize(daemonize = true)
// 87:         @daemonize = daemonize
// 88:         @java_thread_factory = java.util.concurrent.Executors.defaultThreadFactory
// 89:       end
// 90:
// 91:       def newThread(runnable)
// 92:         thread = @java_thread_factory.newThread(runnable)
// 93:         thread.setDaemon(@daemonize)
// 94:         return thread
// 95:       end
// 96:     end
// 97:
// 98:     private_constant :DaemonThreadFactory
// 99:
// 100:   end
// 101: end
