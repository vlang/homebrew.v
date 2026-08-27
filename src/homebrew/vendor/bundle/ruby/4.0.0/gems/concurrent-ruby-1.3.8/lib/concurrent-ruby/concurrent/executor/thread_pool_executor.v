module executor

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/thread_pool_executor.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/executor/ruby_thread_pool_executor'
// 3:
// 4: module Concurrent
// 5:
// 6:   if Concurrent.on_jruby?
// 7:     require 'concurrent/executor/java_thread_pool_executor'
// 8:   end
// 9:
// 10:   ThreadPoolExecutorImplementation = case
// 11:                                      when Concurrent.on_jruby?
// 12:                                        JavaThreadPoolExecutor
// 13:                                      else
// 14:                                        RubyThreadPoolExecutor
// 15:                                      end
// 16:   private_constant :ThreadPoolExecutorImplementation
// 17:
// 18:   # @!macro thread_pool_executor
// 19:   #
// 20:   #   An abstraction composed of one or more threads and a task queue. Tasks
// 21:   #   (blocks or `proc` objects) are submitted to the pool and added to the queue.
// 22:   #   The threads in the pool remove the tasks and execute them in the order
// 23:   #   they were received.
// 24:   #
// 25:   #   A `ThreadPoolExecutor` will automatically adjust the pool size according
// 26:   #   to the bounds set by `min-threads` and `max-threads`. When a new task is
// 27:   #   submitted and fewer than `min-threads` threads are running, a new thread
// 28:   #   is created to handle the request, even if other worker threads are idle.
// 29:   #   If there are more than `min-threads` but less than `max-threads` threads
// 30:   #   running, a new thread will be created only if the queue is full.
// 31:   #
// 32:   #   Threads that are idle for too long will be garbage collected, down to the
// 33:   #   configured minimum options. Should a thread crash it, too, will be garbage collected.
// 34:   #
// 35:   #   `ThreadPoolExecutor` is based on the Java class of the same name. From
// 36:   #   the official Java documentation;
// 37:   #
// 38:   #   > Thread pools address two different problems: they usually provide
// 39:   #   > improved performance when executing large numbers of asynchronous tasks,
// 40:   #   > due to reduced per-task invocation overhead, and they provide a means
// 41:   #   > of bounding and managing the resources, including threads, consumed
// 42:   #   > when executing a collection of tasks. Each ThreadPoolExecutor also
// 43:   #   > maintains some basic statistics, such as the number of completed tasks.
// 44:   #   >
// 45:   #   > To be useful across a wide range of contexts, this class provides many
// 46:   #   > adjustable parameters and extensibility hooks. However, programmers are
// 47:   #   > urged to use the more convenient Executors factory methods
// 48:   #   > [CachedThreadPool] (unbounded thread pool, with automatic thread reclamation),
// 49:   #   > [FixedThreadPool] (fixed size thread pool) and [SingleThreadExecutor] (single
// 50:   #   > background thread), that preconfigure settings for the most common usage
// 51:   #   > scenarios.
// 52:   #
// 53:   # @!macro thread_pool_options
// 54:   #
// 55:   # @!macro thread_pool_executor_public_api
// 56:   class ThreadPoolExecutor < ThreadPoolExecutorImplementation
// 57:
// 58:     # @!macro thread_pool_executor_method_initialize
// 59:     #
// 60:     #   Create a new thread pool.
// 61:     #
// 62:     #   @param [Hash] opts the options which configure the thread pool.
// 63:     #
// 64:     #   @option opts [Integer] :max_threads (DEFAULT_MAX_POOL_SIZE) the maximum
// 65:     #     number of threads to be created
// 66:     #   @option opts [Integer] :min_threads (DEFAULT_MIN_POOL_SIZE) When a new task is submitted
// 67:     #      and fewer than `min_threads` are running, a new thread is created
// 68:     #   @option opts [Integer] :idletime (DEFAULT_THREAD_IDLETIMEOUT) the maximum
// 69:     #     number of seconds a thread may be idle before being reclaimed
// 70:     #   @option opts [Integer] :max_queue (DEFAULT_MAX_QUEUE_SIZE) the maximum
// 71:     #     number of tasks allowed in the work queue at any one time; a value of
// 72:     #     zero means the queue may grow without bound
// 73:     #   @option opts [Symbol] :fallback_policy (:abort) the policy for handling new
// 74:     #     tasks that are received when the queue size has reached
// 75:     #     `max_queue` or the executor has shut down
// 76:     #   @option opts [Boolean] :synchronous (DEFAULT_SYNCHRONOUS) whether or not a value of 0
// 77:     #     for :max_queue means the queue must perform direct hand-off rather than unbounded.
// 78:     #   @raise [ArgumentError] if `:max_threads` is less than one
// 79:     #   @raise [ArgumentError] if `:min_threads` is less than zero
// 80:     #   @raise [ArgumentError] if `:fallback_policy` is not one of the values specified
// 81:     #     in `FALLBACK_POLICIES`
// 82:     #
// 83:     #   @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ThreadPoolExecutor.html
// 84:
// 85:     # @!method initialize(opts = {})
// 86:     #   @!macro thread_pool_executor_method_initialize
// 87:   end
// 88: end
