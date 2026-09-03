module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/cached_thread_pool.rb`.
// The original source is retained below until every stub has a typed V body.
pub const default_max_pool_size = 2_147_483_647
pub const default_max_queue_size = 0
pub const default_thread_idletimeout = 60

pub struct ThreadPoolOptions {
pub:
	min_threads     int
	max_threads     int
	max_queue       int
	idletime        int
	fallback_policy string
}

pub fn cached_thread_pool_options(options map[string]brew_runtime.Value) ThreadPoolOptions {
	return ThreadPoolOptions{
		min_threads: 0
		max_threads: default_max_pool_size
		max_queue: default_max_queue_size
		idletime: option_integer(options, 'idletime', default_thread_idletimeout)
		fallback_policy: option_string(options, 'fallback_policy', 'abort')
	}
}

fn option_integer(options map[string]brew_runtime.Value, name string, default_value int) int {
	return if name in options {
		int(options[name].as_int() or { panic(err) })
	} else {
		default_value
	}
}

fn option_string(options map[string]brew_runtime.Value, name string, default_value string) string {
	return if name in options { options[name].as_string().trim_left(':') } else { default_value }
}

fn thread_pool_value(type_name string, options ThreadPoolOptions) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, type_name, {
		'min_threads':     options.min_threads.str()
		'max_threads':     options.max_threads.str()
		'max_queue':       options.max_queue.str()
		'idletime':        options.idletime.str()
		'fallback_policy': options.fallback_policy
	})
}

fn thread_pool_arguments(args []brew_runtime.Value) map[string]brew_runtime.Value {
	return if args.len == 0 {
		map[string]brew_runtime.Value{}
	} else {
		args[0].as_map() or {
			panic(err)
		}
	}
}

// Ruby method `initialize(opts = {})` at line 39.
pub fn ruby_cached_thread_pool_l39_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return thread_pool_value('Concurrent::CachedThreadPool', cached_thread_pool_options(thread_pool_arguments(args)))
}

// Ruby method `ns_initialize(opts)` at line 51.
pub fn ruby_cached_thread_pool_l51_d2_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return thread_pool_value('Concurrent::CachedThreadPool', cached_thread_pool_options(thread_pool_arguments(args)))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/executor/thread_pool_executor'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A thread pool that dynamically grows and shrinks to fit the current workload.
// 7:   # New threads are created as needed, existing threads are reused, and threads
// 8:   # that remain idle for too long are killed and removed from the pool. These
// 9:   # pools are particularly suited to applications that perform a high volume of
// 10:   # short-lived tasks.
// 11:   #
// 12:   # On creation a `CachedThreadPool` has zero running threads. New threads are
// 13:   # created on the pool as new operations are `#post`. The size of the pool
// 14:   # will grow until `#max_length` threads are in the pool or until the number
// 15:   # of threads exceeds the number of running and pending operations. When a new
// 16:   # operation is post to the pool the first available idle thread will be tasked
// 17:   # with the new operation.
// 18:   #
// 19:   # Should a thread crash for any reason the thread will immediately be removed
// 20:   # from the pool. Similarly, threads which remain idle for an extended period
// 21:   # of time will be killed and reclaimed. Thus these thread pools are very
// 22:   # efficient at reclaiming unused resources.
// 23:   #
// 24:   # The API and behavior of this class are based on Java's `CachedThreadPool`
// 25:   #
// 26:   # @!macro thread_pool_options
// 27:   class CachedThreadPool < ThreadPoolExecutor
// 28:
// 29:     # @!macro cached_thread_pool_method_initialize
// 30:     #
// 31:     #   Create a new thread pool.
// 32:     #
// 33:     #   @param [Hash] opts the options defining pool behavior.
// 34:     #   @option opts [Symbol] :fallback_policy (`:abort`) the fallback policy
// 35:     #
// 36:     #   @raise [ArgumentError] if `fallback_policy` is not a known policy
// 37:     #
// 38:     #   @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html#newCachedThreadPool--
// 39:     def initialize(opts = {})
// 40:       defaults  = { idletime: DEFAULT_THREAD_IDLETIMEOUT }
// 41:       overrides = { min_threads: 0,
// 42:                     max_threads: DEFAULT_MAX_POOL_SIZE,
// 43:                     max_queue:   DEFAULT_MAX_QUEUE_SIZE }
// 44:       super(defaults.merge(opts).merge(overrides))
// 45:     end
// 46:
// 47:     private
// 48:
// 49:     # @!macro cached_thread_pool_method_initialize
// 50:     # @!visibility private
// 51:     def ns_initialize(opts)
// 52:       super(opts)
// 53:       if Concurrent.on_jruby?
// 54:         @max_queue          = 0
// 55:         @executor           = java.util.concurrent.Executors.newCachedThreadPool(
// 56:             DaemonThreadFactory.new(ns_auto_terminate?))
// 57:         @executor.setRejectedExecutionHandler(FALLBACK_POLICY_CLASSES[@fallback_policy].new)
// 58:         @executor.setKeepAliveTime(opts.fetch(:idletime, DEFAULT_THREAD_IDLETIMEOUT), java.util.concurrent.TimeUnit::SECONDS)
// 59:       end
// 60:     end
// 61:   end
// 62: end
