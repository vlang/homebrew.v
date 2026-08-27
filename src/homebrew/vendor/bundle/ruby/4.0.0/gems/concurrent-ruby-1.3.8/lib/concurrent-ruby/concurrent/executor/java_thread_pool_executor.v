module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/java_thread_pool_executor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :max_length` at line 29.
pub fn ruby_java_thread_pool_executor_l29_d1_max_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_length', ...args)
}

// Ruby attr_reader `attr_reader :max_queue` at line 32.
pub fn ruby_java_thread_pool_executor_l32_d2_max_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_queue', ...args)
}

// Ruby attr_reader `attr_reader :synchronous` at line 35.
pub fn ruby_java_thread_pool_executor_l35_d3_synchronous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synchronous', ...args)
}

// Ruby method `initialize(opts = {})` at line 38.
pub fn ruby_java_thread_pool_executor_l38_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `can_overflow?` at line 43.
pub fn ruby_java_thread_pool_executor_l43_d5_can_overflow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can_overflow?', ...args)
}

// Ruby method `min_length` at line 48.
pub fn ruby_java_thread_pool_executor_l48_d6_min_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('min_length', ...args)
}

// Ruby method `max_length` at line 53.
pub fn ruby_java_thread_pool_executor_l53_d7_max_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_length', ...args)
}

// Ruby method `length` at line 58.
pub fn ruby_java_thread_pool_executor_l58_d8_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('length', ...args)
}

// Ruby method `largest_length` at line 63.
pub fn ruby_java_thread_pool_executor_l63_d9_largest_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('largest_length', ...args)
}

// Ruby method `scheduled_task_count` at line 68.
pub fn ruby_java_thread_pool_executor_l68_d10_scheduled_task_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scheduled_task_count', ...args)
}

// Ruby method `completed_task_count` at line 73.
pub fn ruby_java_thread_pool_executor_l73_d11_completed_task_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('completed_task_count', ...args)
}

// Ruby method `active_count` at line 78.
pub fn ruby_java_thread_pool_executor_l78_d12_active_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('active_count', ...args)
}

// Ruby method `idletime` at line 83.
pub fn ruby_java_thread_pool_executor_l83_d13_idletime(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('idletime', ...args)
}

// Ruby method `queue_length` at line 88.
pub fn ruby_java_thread_pool_executor_l88_d14_queue_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('queue_length', ...args)
}

// Ruby method `remaining_capacity` at line 93.
pub fn ruby_java_thread_pool_executor_l93_d15_remaining_capacity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remaining_capacity', ...args)
}

// Ruby method `running?` at line 98.
pub fn ruby_java_thread_pool_executor_l98_d16_running(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('running?', ...args)
}

// Ruby method `prune_pool` at line 103.
pub fn ruby_java_thread_pool_executor_l103_d17_prune_pool(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prune_pool', ...args)
}

// Ruby method `ns_initialize(opts)` at line 109.
pub fn ruby_java_thread_pool_executor_l109_d18_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: if Concurrent.on_jruby?
// 2:
// 3:   require 'concurrent/executor/java_executor_service'
// 4:
// 5:   module Concurrent
// 6:
// 7:     # @!macro thread_pool_executor
// 8:     # @!macro thread_pool_options
// 9:     # @!visibility private
// 10:     class JavaThreadPoolExecutor < JavaExecutorService
// 11:       include Concern::Deprecation
// 12:
// 13:       # @!macro thread_pool_executor_constant_default_max_pool_size
// 14:       DEFAULT_MAX_POOL_SIZE = java.lang.Integer::MAX_VALUE # 2147483647
// 15:
// 16:       # @!macro thread_pool_executor_constant_default_min_pool_size
// 17:       DEFAULT_MIN_POOL_SIZE = 0
// 18:
// 19:       # @!macro thread_pool_executor_constant_default_max_queue_size
// 20:       DEFAULT_MAX_QUEUE_SIZE = 0
// 21:
// 22:       # @!macro thread_pool_executor_constant_default_thread_timeout
// 23:       DEFAULT_THREAD_IDLETIMEOUT = 60
// 24:
// 25:       # @!macro thread_pool_executor_constant_default_synchronous
// 26:       DEFAULT_SYNCHRONOUS = false
// 27:
// 28:       # @!macro thread_pool_executor_attr_reader_max_length
// 29:       attr_reader :max_length
// 30:
// 31:       # @!macro thread_pool_executor_attr_reader_max_queue
// 32:       attr_reader :max_queue
// 33:
// 34:       # @!macro thread_pool_executor_attr_reader_synchronous
// 35:       attr_reader :synchronous
// 36:
// 37:       # @!macro thread_pool_executor_method_initialize
// 38:       def initialize(opts = {})
// 39:         super(opts)
// 40:       end
// 41:
// 42:       # @!macro executor_service_method_can_overflow_question
// 43:       def can_overflow?
// 44:         @max_queue != 0
// 45:       end
// 46:
// 47:       # @!macro thread_pool_executor_attr_reader_min_length
// 48:       def min_length
// 49:         @executor.getCorePoolSize
// 50:       end
// 51:
// 52:       # @!macro thread_pool_executor_attr_reader_max_length
// 53:       def max_length
// 54:         @executor.getMaximumPoolSize
// 55:       end
// 56:
// 57:       # @!macro thread_pool_executor_attr_reader_length
// 58:       def length
// 59:         @executor.getPoolSize
// 60:       end
// 61:
// 62:       # @!macro thread_pool_executor_attr_reader_largest_length
// 63:       def largest_length
// 64:         @executor.getLargestPoolSize
// 65:       end
// 66:
// 67:       # @!macro thread_pool_executor_attr_reader_scheduled_task_count
// 68:       def scheduled_task_count
// 69:         @executor.getTaskCount
// 70:       end
// 71:
// 72:       # @!macro thread_pool_executor_attr_reader_completed_task_count
// 73:       def completed_task_count
// 74:         @executor.getCompletedTaskCount
// 75:       end
// 76:
// 77:       # @!macro thread_pool_executor_method_active_count
// 78:       def active_count
// 79:         @executor.getActiveCount
// 80:       end
// 81:
// 82:       # @!macro thread_pool_executor_attr_reader_idletime
// 83:       def idletime
// 84:         @executor.getKeepAliveTime(java.util.concurrent.TimeUnit::SECONDS)
// 85:       end
// 86:
// 87:       # @!macro thread_pool_executor_attr_reader_queue_length
// 88:       def queue_length
// 89:         @executor.getQueue.size
// 90:       end
// 91:
// 92:       # @!macro thread_pool_executor_attr_reader_remaining_capacity
// 93:       def remaining_capacity
// 94:         @max_queue == 0 ? -1 : @executor.getQueue.remainingCapacity
// 95:       end
// 96:
// 97:       # @!macro executor_service_method_running_question
// 98:       def running?
// 99:         super && !@executor.isTerminating
// 100:       end
// 101:
// 102:       # @!macro thread_pool_executor_method_prune_pool
// 103:       def prune_pool
// 104:         deprecated "#prune_pool has no effect and will be removed in the next release."
// 105:       end
// 106:
// 107:       private
// 108:
// 109:       def ns_initialize(opts)
// 110:         min_length       = opts.fetch(:min_threads, DEFAULT_MIN_POOL_SIZE).to_i
// 111:         max_length       = opts.fetch(:max_threads, DEFAULT_MAX_POOL_SIZE).to_i
// 112:         idletime         = opts.fetch(:idletime, DEFAULT_THREAD_IDLETIMEOUT).to_i
// 113:         @max_queue       = opts.fetch(:max_queue, DEFAULT_MAX_QUEUE_SIZE).to_i
// 114:         @synchronous     = opts.fetch(:synchronous, DEFAULT_SYNCHRONOUS)
// 115:         @fallback_policy = opts.fetch(:fallback_policy, :abort)
// 116:
// 117:         raise ArgumentError.new("`synchronous` cannot be set unless `max_queue` is 0") if @synchronous && @max_queue > 0
// 118:         raise ArgumentError.new("`max_threads` cannot be less than #{DEFAULT_MIN_POOL_SIZE}") if max_length < DEFAULT_MIN_POOL_SIZE
// 119:         raise ArgumentError.new("`max_threads` cannot be greater than #{DEFAULT_MAX_POOL_SIZE}") if max_length > DEFAULT_MAX_POOL_SIZE
// 120:         raise ArgumentError.new("`min_threads` cannot be less than #{DEFAULT_MIN_POOL_SIZE}") if min_length < DEFAULT_MIN_POOL_SIZE
// 121:         raise ArgumentError.new("`min_threads` cannot be more than `max_threads`") if min_length > max_length
// 122:         raise ArgumentError.new("#{fallback_policy} is not a valid fallback policy") unless FALLBACK_POLICY_CLASSES.include?(@fallback_policy)
// 123:
// 124:         if @max_queue == 0
// 125:           if @synchronous
// 126:             queue = java.util.concurrent.SynchronousQueue.new
// 127:           else
// 128:             queue = java.util.concurrent.LinkedBlockingQueue.new
// 129:           end
// 130:         else
// 131:           queue = java.util.concurrent.LinkedBlockingQueue.new(@max_queue)
// 132:         end
// 133:
// 134:         @executor = java.util.concurrent.ThreadPoolExecutor.new(
// 135:             min_length,
// 136:             max_length,
// 137:             idletime,
// 138:             java.util.concurrent.TimeUnit::SECONDS,
// 139:             queue,
// 140:             DaemonThreadFactory.new(ns_auto_terminate?),
// 141:             FALLBACK_POLICY_CLASSES[@fallback_policy].new)
// 142:
// 143:       end
// 144:     end
// 145:
// 146:   end
// 147: end
