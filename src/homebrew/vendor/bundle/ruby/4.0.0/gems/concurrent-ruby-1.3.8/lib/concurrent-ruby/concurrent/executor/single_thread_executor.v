module executor

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/single_thread_executor.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/executor/ruby_single_thread_executor'
// 3:
// 4: module Concurrent
// 5:
// 6:   if Concurrent.on_jruby?
// 7:     require 'concurrent/executor/java_single_thread_executor'
// 8:   end
// 9:
// 10:   SingleThreadExecutorImplementation = case
// 11:                                        when Concurrent.on_jruby?
// 12:                                          JavaSingleThreadExecutor
// 13:                                        else
// 14:                                          RubySingleThreadExecutor
// 15:                                        end
// 16:   private_constant :SingleThreadExecutorImplementation
// 17:
// 18:   # @!macro single_thread_executor
// 19:   #
// 20:   #   A thread pool with a single thread an unlimited queue. Should the thread
// 21:   #   die for any reason it will be removed and replaced, thus ensuring that
// 22:   #   the executor will always remain viable and available to process jobs.
// 23:   #
// 24:   #   A common pattern for background processing is to create a single thread
// 25:   #   on which an infinite loop is run. The thread's loop blocks on an input
// 26:   #   source (perhaps blocking I/O or a queue) and processes each input as it
// 27:   #   is received. This pattern has several issues. The thread itself is highly
// 28:   #   susceptible to errors during processing. Also, the thread itself must be
// 29:   #   constantly monitored and restarted should it die. `SingleThreadExecutor`
// 30:   #   encapsulates all these behaviors. The task processor is highly resilient
// 31:   #   to errors from within tasks. Also, should the thread die it will
// 32:   #   automatically be restarted.
// 33:   #
// 34:   #   The API and behavior of this class are based on Java's `SingleThreadExecutor`.
// 35:   #
// 36:   # @!macro abstract_executor_service_public_api
// 37:   class SingleThreadExecutor < SingleThreadExecutorImplementation
// 38:
// 39:     # @!macro single_thread_executor_method_initialize
// 40:     #
// 41:     #   Create a new thread pool.
// 42:     #
// 43:     #   @option opts [Symbol] :fallback_policy (:discard) the policy for handling new
// 44:     #     tasks that are received when the queue size has reached
// 45:     #     `max_queue` or the executor has shut down
// 46:     #
// 47:     #   @raise [ArgumentError] if `:fallback_policy` is not one of the values specified
// 48:     #     in `FALLBACK_POLICIES`
// 49:     #
// 50:     #   @see http://docs.oracle.com/javase/tutorial/essential/concurrency/pools.html
// 51:     #   @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Executors.html
// 52:     #   @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
// 53:
// 54:     # @!method initialize(opts = {})
// 55:     #   @!macro single_thread_executor_method_initialize
// 56:   end
// 57: end
