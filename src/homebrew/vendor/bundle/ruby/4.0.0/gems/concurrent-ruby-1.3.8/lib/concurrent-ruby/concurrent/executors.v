module concurrent

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executors.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/executor/abstract_executor_service'
// 2: require 'concurrent/executor/cached_thread_pool'
// 3: require 'concurrent/executor/executor_service'
// 4: require 'concurrent/executor/fixed_thread_pool'
// 5: require 'concurrent/executor/immediate_executor'
// 6: require 'concurrent/executor/indirect_immediate_executor'
// 7: require 'concurrent/executor/java_executor_service'
// 8: require 'concurrent/executor/java_single_thread_executor'
// 9: require 'concurrent/executor/java_thread_pool_executor'
// 10: require 'concurrent/executor/ruby_executor_service'
// 11: require 'concurrent/executor/ruby_single_thread_executor'
// 12: require 'concurrent/executor/ruby_thread_pool_executor'
// 13: require 'concurrent/executor/safe_task_executor'
// 14: require 'concurrent/executor/serial_executor_service'
// 15: require 'concurrent/executor/serialized_execution'
// 16: require 'concurrent/executor/serialized_execution_delegator'
// 17: require 'concurrent/executor/single_thread_executor'
// 18: require 'concurrent/executor/thread_pool_executor'
// 19: require 'concurrent/executor/timer_set'
