module concurrent

import ruby
import runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/configuration.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ConfiguredExecutorKind {
	fast
	io
	immediate
}

@[heap]
pub struct ConfiguredExecutor {
pub:
	kind            ConfiguredExecutorKind
	adapter         ScheduledExecutor
	auto_terminate  bool = true
	min_threads     int
	max_threads     int
	idletime        int
	max_queue       int
	fallback_policy string = 'abort'
	name            string
}

fn immediate_scheduled_post(_ voidptr, task ScheduledExecution, args []ruby.Value) bool {
	task(args)
	return true
}

pub fn new_fast_executor(auto_terminate bool) ConfiguredExecutor {
	processor_count := runtime.nr_cpus()
	pool_size := if processor_count > 2 { processor_count } else { 2 }
	return ConfiguredExecutor{
		kind: .fast
		adapter: asynchronous_scheduled_executor('fast')
		auto_terminate: auto_terminate
		min_threads: pool_size
		max_threads: pool_size
		idletime: 60
		max_queue: 0
		fallback_policy: 'abort'
		name: 'fast'
	}
}

pub fn new_io_executor(auto_terminate bool) ConfiguredExecutor {
	return ConfiguredExecutor{
		kind: .io
		adapter: asynchronous_scheduled_executor('io')
		auto_terminate: auto_terminate
		min_threads: 0
		max_threads: 2_147_483_647
		idletime: 60
		max_queue: 0
		fallback_policy: 'abort'
		name: 'io'
	}
}

pub fn new_immediate_configured_executor() ConfiguredExecutor {
	return ConfiguredExecutor{
		kind: .immediate
		adapter: ScheduledExecutor{
			post_fn: immediate_scheduled_post
			name: 'immediate'
		}
		min_threads: 1
		max_threads: 1
		name: 'immediate'
	}
}

fn configured_executor_pointer(value ConfiguredExecutor) &ConfiguredExecutor {
	return &ConfiguredExecutor{
		kind: value.kind
		adapter: value.adapter
		auto_terminate: value.auto_terminate
		min_threads: value.min_threads
		max_threads: value.max_threads
		idletime: value.idletime
		max_queue: value.max_queue
		fallback_policy: value.fallback_policy
		name: value.name
	}
}

@[unsafe]
fn delayed_global_fast_executor() &ConfiguredExecutor {
	mut static executor := &ConfiguredExecutor(unsafe { nil })
	if executor == unsafe { nil } {
		executor = configured_executor_pointer(new_fast_executor(true))
	}
	return executor
}

pub fn global_fast_executor() ConfiguredExecutor {
	return *unsafe { delayed_global_fast_executor() }
}

@[unsafe]
fn delayed_global_io_executor() &ConfiguredExecutor {
	mut static executor := &ConfiguredExecutor(unsafe { nil })
	if executor == unsafe { nil } {
		executor = configured_executor_pointer(new_io_executor(true))
	}
	return executor
}

pub fn global_io_executor() ConfiguredExecutor {
	return *unsafe { delayed_global_io_executor() }
}

@[unsafe]
fn delayed_global_immediate_executor() &ConfiguredExecutor {
	mut static executor := &ConfiguredExecutor(unsafe { nil })
	if executor == unsafe { nil } {
		executor = configured_executor_pointer(new_immediate_configured_executor())
	}
	return executor
}

pub fn global_immediate_executor() ConfiguredExecutor {
	return *unsafe { delayed_global_immediate_executor() }
}

@[unsafe]
fn delayed_global_timer_set() &ScheduledTaskScheduler {
	mut static timer_set := &ScheduledTaskScheduler(unsafe { nil })
	if timer_set == unsafe { nil } {
		timer_set = new_scheduled_task_scheduler()
	}
	return timer_set
}

pub fn global_timer_set() &ScheduledTaskScheduler {
	return unsafe { delayed_global_timer_set() }
}

pub fn configured_executor(identifier ruby.Value) !ConfiguredExecutor {
	name := identifier.as_string().trim_left(':').to_lower()
	return match name {
		'fast' { global_fast_executor() }
		'io' { global_io_executor() }
		'immediate' { global_immediate_executor() }
		else {
			if identifier.type_name.ends_with('ExecutorService') {
				ConfiguredExecutor{
					kind: .io
					adapter: asynchronous_scheduled_executor(identifier.as_string())
					name: identifier.as_string()
				}
			} else {
				return error("executor not recognized by '${identifier.as_string()}'")
			}
		}
	}
}

fn configured_executor_value(executor ConfiguredExecutor) ruby.Value {
	return ruby.structured_value('Concurrent::ExecutorService', executor.name, {
		'kind':            executor.kind.str()
		'auto_terminate':  executor.auto_terminate.str()
		'min_threads':     executor.min_threads.str()
		'max_threads':     executor.max_threads.str()
		'idletime':        executor.idletime.str()
		'max_queue':       executor.max_queue.str()
		'fallback_policy': executor.fallback_policy
	})
}

fn configuration_auto_terminate(args []ruby.Value) bool {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return true
	}
	options := args[0].as_map() or { return true }
	return if 'auto_terminate' in options {
		options['auto_terminate'].as_bool() or { true }
	} else {
		true
	}
}

// Ruby method `self.disable_at_exit_handlers!` at line 48.
pub fn ruby_configuration_l48_d1_self_disable_at_exit_handlers(args ...ruby.Value) ruby.Value {
	eprintln('Method #disable_at_exit_handlers! has no effect since it is no longer needed, see https://github.com/ruby-concurrency/concurrent-ruby/pull/841.')
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.global_fast_executor` at line 55.
pub fn ruby_configuration_l55_d2_self_global_fast_executor(args ...ruby.Value) ruby.Value {
	return configured_executor_value(global_fast_executor())
}

// Ruby method `self.global_io_executor` at line 62.
pub fn ruby_configuration_l62_d3_self_global_io_executor(args ...ruby.Value) ruby.Value {
	return configured_executor_value(global_io_executor())
}

// Ruby method `self.global_immediate_executor` at line 66.
pub fn ruby_configuration_l66_d4_self_global_immediate_executor(args ...ruby.Value) ruby.Value {
	return configured_executor_value(global_immediate_executor())
}

// Ruby method `self.global_timer_set` at line 73.
pub fn ruby_configuration_l73_d5_self_global_timer_set(args ...ruby.Value) ruby.Value {
	timer_set := global_timer_set()
	return ruby.structured_value('Concurrent::TimerSet', '#<Concurrent::TimerSet>', {
		'scheduled_task_scheduler_address': u64(voidptr(timer_set)).str()
	})
}

// Ruby method `self.executor(executor_identifier)` at line 83.
pub fn ruby_configuration_l83_d6_self_executor(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Concurrent.executor requires an identifier')
	}
	return configured_executor_value(configured_executor(args[0]) or { panic(err) })
}

// Ruby method `self.new_fast_executor(opts = {})` at line 87.
pub fn ruby_configuration_l87_d7_self_new_fast_executor(args ...ruby.Value) ruby.Value {
	return configured_executor_value(new_fast_executor(configuration_auto_terminate(args)))
}

// Ruby method `self.new_io_executor(opts = {})` at line 98.
pub fn ruby_configuration_l98_d8_self_new_io_executor(args ...ruby.Value) ruby.Value {
	return configured_executor_value(new_io_executor(configuration_auto_terminate(args)))
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/delay'
// 3: require 'concurrent/errors'
// 4: require 'concurrent/concern/deprecation'
// 5: require 'concurrent/executor/immediate_executor'
// 6: require 'concurrent/executor/fixed_thread_pool'
// 7: require 'concurrent/executor/cached_thread_pool'
// 8: require 'concurrent/utility/processor_counter'
// 9:
// 10: module Concurrent
// 11:   extend Concern::Deprecation
// 12:
// 13:   autoload :Options, 'concurrent/options'
// 14:   autoload :TimerSet, 'concurrent/executor/timer_set'
// 15:   autoload :ThreadPoolExecutor, 'concurrent/executor/thread_pool_executor'
// 16:
// 17:   # @!visibility private
// 18:   GLOBAL_FAST_EXECUTOR = Delay.new { Concurrent.new_fast_executor }
// 19:   private_constant :GLOBAL_FAST_EXECUTOR
// 20:
// 21:   # @!visibility private
// 22:   GLOBAL_IO_EXECUTOR = Delay.new { Concurrent.new_io_executor }
// 23:   private_constant :GLOBAL_IO_EXECUTOR
// 24:
// 25:   # @!visibility private
// 26:   GLOBAL_TIMER_SET = Delay.new { TimerSet.new }
// 27:   private_constant :GLOBAL_TIMER_SET
// 28:
// 29:   # @!visibility private
// 30:   GLOBAL_IMMEDIATE_EXECUTOR = ImmediateExecutor.new
// 31:   private_constant :GLOBAL_IMMEDIATE_EXECUTOR
// 32:
// 33:   # Disables AtExit handlers including pool auto-termination handlers.
// 34:   # When disabled it will be the application programmer's responsibility
// 35:   # to ensure that the handlers are shutdown properly prior to application
// 36:   # exit by calling `AtExit.run` method.
// 37:   #
// 38:   # @note this option should be needed only because of `at_exit` ordering
// 39:   #   issues which may arise when running some of the testing frameworks.
// 40:   #   E.g. Minitest's test-suite runs itself in `at_exit` callback which
// 41:   #   executes after the pools are already terminated. Then auto termination
// 42:   #   needs to be disabled and called manually after test-suite ends.
// 43:   # @note This method should *never* be called
// 44:   #   from within a gem. It should *only* be used from within the main
// 45:   #   application and even then it should be used only when necessary.
// 46:   # @deprecated Has no effect since it is no longer needed, see https://github.com/ruby-concurrency/concurrent-ruby/pull/841.
// 47:   #
// 48:   def self.disable_at_exit_handlers!
// 49:     deprecated "Method #disable_at_exit_handlers! has no effect since it is no longer needed, see https://github.com/ruby-concurrency/concurrent-ruby/pull/841."
// 50:   end
// 51:
// 52:   # Global thread pool optimized for short, fast *operations*.
// 53:   #
// 54:   # @return [ThreadPoolExecutor] the thread pool
// 55:   def self.global_fast_executor
// 56:     GLOBAL_FAST_EXECUTOR.value!
// 57:   end
// 58:
// 59:   # Global thread pool optimized for long, blocking (IO) *tasks*.
// 60:   #
// 61:   # @return [ThreadPoolExecutor] the thread pool
// 62:   def self.global_io_executor
// 63:     GLOBAL_IO_EXECUTOR.value!
// 64:   end
// 65:
// 66:   def self.global_immediate_executor
// 67:     GLOBAL_IMMEDIATE_EXECUTOR
// 68:   end
// 69:
// 70:   # Global thread pool user for global *timers*.
// 71:   #
// 72:   # @return [Concurrent::TimerSet] the thread pool
// 73:   def self.global_timer_set
// 74:     GLOBAL_TIMER_SET.value!
// 75:   end
// 76:
// 77:   # General access point to global executors.
// 78:   # @param [Symbol, Executor] executor_identifier symbols:
// 79:   #   - :fast - {Concurrent.global_fast_executor}
// 80:   #   - :io - {Concurrent.global_io_executor}
// 81:   #   - :immediate - {Concurrent.global_immediate_executor}
// 82:   # @return [Executor]
// 83:   def self.executor(executor_identifier)
// 84:     Options.executor(executor_identifier)
// 85:   end
// 86:
// 87:   def self.new_fast_executor(opts = {})
// 88:     FixedThreadPool.new(
// 89:         [2, Concurrent.processor_count].max,
// 90:         auto_terminate:  opts.fetch(:auto_terminate, true),
// 91:         idletime:        60, # 1 minute
// 92:         max_queue:       0, # unlimited
// 93:         fallback_policy: :abort, # shouldn't matter -- 0 max queue
// 94:         name:            "fast"
// 95:     )
// 96:   end
// 97:
// 98:   def self.new_io_executor(opts = {})
// 99:     CachedThreadPool.new(
// 100:         auto_terminate:  opts.fetch(:auto_terminate, true),
// 101:         fallback_policy: :abort, # shouldn't matter -- 0 max queue
// 102:         name:            "io"
// 103:     )
// 104:   end
// 105: end
