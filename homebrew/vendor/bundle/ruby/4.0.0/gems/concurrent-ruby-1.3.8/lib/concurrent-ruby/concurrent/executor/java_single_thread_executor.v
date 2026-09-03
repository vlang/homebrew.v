module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/java_single_thread_executor.rb`.
// The original source is retained below until every stub has a typed V body.
fn validate_java_single_thread_options(options map[string]brew_runtime.Value) !ThreadPoolOptions {
	config := single_thread_pool_options(options)
	if config.fallback_policy !in ['abort', 'discard', 'caller_runs'] {
		return error('${config.fallback_policy} is not a valid fallback policy')
	}
	return config
}

// Ruby method `initialize(opts = {})` at line 15.
pub fn ruby_java_single_thread_executor_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return thread_pool_value('Concurrent::JavaSingleThreadExecutor', validate_java_single_thread_options(thread_pool_arguments(args)) or {
		panic(err)
	})
}

// Ruby method `ns_initialize(opts)` at line 21.
pub fn ruby_java_single_thread_executor_l21_d2_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return thread_pool_value('Concurrent::JavaSingleThreadExecutor', validate_java_single_thread_options(thread_pool_arguments(args)) or {
		panic(err)
	})
}

// Original Ruby source (line-for-line):
// 1: if Concurrent.on_jruby?
// 2:
// 3:   require 'concurrent/executor/java_executor_service'
// 4:   require 'concurrent/executor/serial_executor_service'
// 5:
// 6:   module Concurrent
// 7:
// 8:     # @!macro single_thread_executor
// 9:     # @!macro abstract_executor_service_public_api
// 10:     # @!visibility private
// 11:     class JavaSingleThreadExecutor < JavaExecutorService
// 12:       include SerialExecutorService
// 13:
// 14:       # @!macro single_thread_executor_method_initialize
// 15:       def initialize(opts = {})
// 16:         super(opts)
// 17:       end
// 18:
// 19:       private
// 20:
// 21:       def ns_initialize(opts)
// 22:         @executor = java.util.concurrent.Executors.newSingleThreadExecutor(
// 23:             DaemonThreadFactory.new(ns_auto_terminate?)
// 24:         )
// 25:         @fallback_policy = opts.fetch(:fallback_policy, :discard)
// 26:         raise ArgumentError.new("#{@fallback_policy} is not a valid fallback policy") unless FALLBACK_POLICY_CLASSES.keys.include?(@fallback_policy)
// 27:       end
// 28:     end
// 29:   end
// 30: end
