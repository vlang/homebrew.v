module executor

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/ruby_single_thread_executor.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn single_thread_pool_options(options map[string]ruby.Value) ThreadPoolOptions {
	return ThreadPoolOptions{
		min_threads: 1
		max_threads: 1
		max_queue: 0
		idletime: default_thread_idletimeout
		fallback_policy: option_string(options, 'fallback_policy', 'discard')
	}
}

// Ruby method `initialize(opts = {})` at line 13.
pub fn ruby_ruby_single_thread_executor_l13_d1_initialize(args ...ruby.Value) ruby.Value {
	return thread_pool_value('Concurrent::RubySingleThreadExecutor', single_thread_pool_options(thread_pool_arguments(args)))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/executor/ruby_thread_pool_executor'
// 2: require 'concurrent/executor/serial_executor_service'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro single_thread_executor
// 7:   # @!macro abstract_executor_service_public_api
// 8:   # @!visibility private
// 9:   class RubySingleThreadExecutor < RubyThreadPoolExecutor
// 10:     include SerialExecutorService
// 11:
// 12:     # @!macro single_thread_executor_method_initialize
// 13:     def initialize(opts = {})
// 14:       super(
// 15:         min_threads: 1,
// 16:         max_threads: 1,
// 17:         max_queue: 0,
// 18:         idletime: DEFAULT_THREAD_IDLETIMEOUT,
// 19:         fallback_policy: opts.fetch(:fallback_policy, :discard),
// 20:       )
// 21:     end
// 22:   end
// 23: end
