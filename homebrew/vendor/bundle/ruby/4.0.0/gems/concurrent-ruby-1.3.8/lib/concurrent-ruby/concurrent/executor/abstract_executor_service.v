module executor

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/abstract_executor_service.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ExecutorTask = fn([]ruby.Value) !

pub type ExecutorPostFunction = fn(voidptr, ExecutorTask, []ruby.Value) bool

pub type ExecutorRunningFunction = fn(voidptr) bool

pub struct ExecutorAdapter {
pub:
	context    voidptr
	post_task  ExecutorPostFunction @[required]
	is_running ExecutorRunningFunction @[required]
}

pub fn (adapter ExecutorAdapter) post(task ExecutorTask, args []ruby.Value) bool {
	return adapter.post_task(adapter.context, task, args)
}

pub fn (adapter ExecutorAdapter) running() bool {
	return adapter.is_running(adapter.context)
}

pub enum FallbackPolicy {
	abort
	discard
	caller_runs
}

pub struct AbstractExecutorOptions {
pub:
	auto_terminate  bool = true
	name            string
	fallback_policy FallbackPolicy = .abort
}

@[heap]
pub struct AbstractExecutorService {
mut:
	lock sync.Mutex
pub:
	auto_terminate  bool
	name            string
	fallback_policy FallbackPolicy
}

pub fn new_abstract_executor_service(options AbstractExecutorOptions) &AbstractExecutorService {
	return &AbstractExecutorService{
		auto_terminate: options.auto_terminate
		name: options.name
		fallback_policy: options.fallback_policy
	}
}

pub fn (executor &AbstractExecutorService) fallback_policy_name() string {
	return executor.fallback_policy.str()
}

pub fn (executor &AbstractExecutorService) string() string {
	base := '#<Concurrent::AbstractExecutorService>'
	if executor.name.len == 0 {
		return base
	}
	return '${base[..base.len - 1]} name: ${executor.name}>'
}

pub fn (mut executor AbstractExecutorService) running() bool {
	executor.lock.lock()
	executor.lock.unlock()
	panic('NotImplementedError: AbstractExecutorService#ns_running?')
}

pub fn (mut executor AbstractExecutorService) shutting_down() bool {
	executor.lock.lock()
	executor.lock.unlock()
	panic('NotImplementedError: AbstractExecutorService#ns_shuttingdown?')
}

pub fn (mut executor AbstractExecutorService) is_shutdown() bool {
	executor.lock.lock()
	executor.lock.unlock()
	panic('NotImplementedError: AbstractExecutorService#ns_shutdown?')
}

pub fn (mut executor AbstractExecutorService) is_auto_terminate() bool {
	executor.lock.lock()
	value := executor.auto_terminate
	executor.lock.unlock()
	return value
}

pub fn (mut executor AbstractExecutorService) fallback(task ExecutorTask, args []ruby.Value) !bool {
	return match executor.fallback_policy {
		.abort { error('RejectedExecutionError') }
		.discard { false }
		.caller_runs {
			task(args) or {
				// Ruby logs task failures at DEBUG and still reports that caller-runs handled it.
			}
			true
		}
	}
}

fn nil_executor_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn fallback_policy_from_string(value string) FallbackPolicy {
	return match value.trim_left(':') {
		'discard' { .discard }
		'caller_runs' { .caller_runs }
		else { .abort }
	}
}

fn abstract_executor_options_from_boundary(args []ruby.Value) AbstractExecutorOptions {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return AbstractExecutorOptions{}
	}
	options := args[0].as_map() or { return AbstractExecutorOptions{} }
	return AbstractExecutorOptions{
		auto_terminate: if 'auto_terminate' in options {
			options['auto_terminate'].as_bool() or { true }} else {
			true}
		name: if 'name' in options { options['name'].as_string() } else { '' }
		fallback_policy: if 'fallback_policy' in options {
			fallback_policy_from_string(options['fallback_policy'].as_string())} else {
			.abort}
	}
}

fn abstract_executor_boundary_value(executor &AbstractExecutorService) ruby.Value {
	return ruby.structured_value('Concurrent::AbstractExecutorService', executor.string(), {
		'abstract_executor_address': u64(voidptr(executor)).str()
	})
}

fn abstract_executor_boundary_receiver(args []ruby.Value) &AbstractExecutorService {
	if args.len == 0 {
		panic('AbstractExecutorService method requires a receiver')
	}
	address := (args[0].attribute('abstract_executor_address') or {
		panic('${args[0].type_name} has no translated AbstractExecutorService state')
	}).u64()
	return unsafe { &AbstractExecutorService(voidptr(address)) }
}

// Ruby attr_reader `attr_reader :fallback_policy` at line 18.
pub fn ruby_abstract_executor_service_l18_d1_fallback_policy(args ...ruby.Value) ruby.Value {
	executor := abstract_executor_boundary_receiver(args)
	return ruby.object_value('Symbol', ':${executor.fallback_policy_name()}')
}

// Ruby attr_reader `attr_reader :name` at line 20.
pub fn ruby_abstract_executor_service_l20_d2_name(args ...ruby.Value) ruby.Value {
	executor := abstract_executor_boundary_receiver(args)
	if executor.name.len == 0 {
		return nil_executor_value()
	}
	return ruby.string_value(executor.name)
}

// Ruby method `initialize(opts = {}, &block)` at line 23.
pub fn ruby_abstract_executor_service_l23_d3_initialize(args ...ruby.Value) ruby.Value {
	return abstract_executor_boundary_value(new_abstract_executor_service(abstract_executor_options_from_boundary(args)))
}

// Ruby method `to_s` at line 32.
pub fn ruby_abstract_executor_service_l32_d4_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(abstract_executor_boundary_receiver(args).string())
}

// Ruby method `shutdown` at line 37.
pub fn ruby_abstract_executor_service_l37_d5_shutdown(args ...ruby.Value) ruby.Value {
	panic('NotImplementedError: AbstractExecutorService#shutdown')
}

// Ruby method `kill` at line 42.
pub fn ruby_abstract_executor_service_l42_d6_kill(args ...ruby.Value) ruby.Value {
	panic('NotImplementedError: AbstractExecutorService#kill')
}

// Ruby method `wait_for_termination(timeout = nil)` at line 47.
pub fn ruby_abstract_executor_service_l47_d7_wait_for_termination(args ...ruby.Value) ruby.Value {
	panic('NotImplementedError: AbstractExecutorService#wait_for_termination')
}

// Ruby method `running?` at line 52.
pub fn ruby_abstract_executor_service_l52_d8_running(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	return ruby.bool_value(executor.running())
}

// Ruby method `shuttingdown?` at line 57.
pub fn ruby_abstract_executor_service_l57_d9_shuttingdown(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	return ruby.bool_value(executor.shutting_down())
}

// Ruby method `shutdown?` at line 62.
pub fn ruby_abstract_executor_service_l62_d10_shutdown(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	return ruby.bool_value(executor.is_shutdown())
}

// Ruby method `auto_terminate?` at line 67.
pub fn ruby_abstract_executor_service_l67_d11_auto_terminate(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	return ruby.bool_value(executor.is_auto_terminate())
}

// Ruby method `auto_terminate=(value)` at line 72.
pub fn ruby_abstract_executor_service_l72_d12_auto_terminate(args ...ruby.Value) ruby.Value {
	// The Ruby setter is deprecated and deliberately has no effect.
	return nil_executor_value()
}

// Ruby method `fallback_action(*args)` at line 85.
pub fn ruby_abstract_executor_service_l85_d13_fallback_action(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	task_args := if args.len > 1 { args[1..].clone() } else { []ruby.Value{} }
	return ruby.bool_value(executor.fallback(boundary_noop_executor_task, task_args) or {
		panic(err)
	})
}

// Ruby method `ns_execute(*args, &task)` at line 106.
pub fn ruby_abstract_executor_service_l106_d14_ns_execute(args ...ruby.Value) ruby.Value {
	panic('NotImplementedError: AbstractExecutorService#ns_execute')
}

// Ruby method `ns_shutdown_execution` at line 114.
pub fn ruby_abstract_executor_service_l114_d15_ns_shutdown_execution(args ...ruby.Value) ruby.Value {
	return nil_executor_value()
}

// Ruby method `ns_kill_execution` at line 122.
pub fn ruby_abstract_executor_service_l122_d16_ns_kill_execution(args ...ruby.Value) ruby.Value {
	return nil_executor_value()
}

// Ruby method `ns_auto_terminate?` at line 126.
pub fn ruby_abstract_executor_service_l126_d17_ns_auto_terminate(args ...ruby.Value) ruby.Value {
	mut executor := abstract_executor_boundary_receiver(args)
	return ruby.bool_value(executor.is_auto_terminate())
}

fn boundary_noop_executor_task(args []ruby.Value) ! {
	_ = args
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/errors'
// 2: require 'concurrent/concern/deprecation'
// 3: require 'concurrent/executor/executor_service'
// 4: require 'concurrent/synchronization/lockable_object'
// 5:
// 6: module Concurrent
// 7:
// 8:   # @!macro abstract_executor_service_public_api
// 9:   # @!visibility private
// 10:   class AbstractExecutorService < Synchronization::LockableObject
// 11:     include ExecutorService
// 12:     include Concern::Deprecation
// 13:
// 14:     # The set of possible fallback policies that may be set at thread pool creation.
// 15:     FALLBACK_POLICIES = [:abort, :discard, :caller_runs].freeze
// 16:
// 17:     # @!macro executor_service_attr_reader_fallback_policy
// 18:     attr_reader :fallback_policy
// 19:
// 20:     attr_reader :name
// 21:
// 22:     # Create a new thread pool.
// 23:     def initialize(opts = {}, &block)
// 24:       super(&nil)
// 25:       synchronize do
// 26:         @auto_terminate = opts.fetch(:auto_terminate, true)
// 27:         @name = opts.fetch(:name) if opts.key?(:name)
// 28:         ns_initialize(opts, &block)
// 29:       end
// 30:     end
// 31:
// 32:     def to_s
// 33:       name ? "#{super[0..-2]} name: #{name}>" : super
// 34:     end
// 35:
// 36:     # @!macro executor_service_method_shutdown
// 37:     def shutdown
// 38:       raise NotImplementedError
// 39:     end
// 40:
// 41:     # @!macro executor_service_method_kill
// 42:     def kill
// 43:       raise NotImplementedError
// 44:     end
// 45:
// 46:     # @!macro executor_service_method_wait_for_termination
// 47:     def wait_for_termination(timeout = nil)
// 48:       raise NotImplementedError
// 49:     end
// 50:
// 51:     # @!macro executor_service_method_running_question
// 52:     def running?
// 53:       synchronize { ns_running? }
// 54:     end
// 55:
// 56:     # @!macro executor_service_method_shuttingdown_question
// 57:     def shuttingdown?
// 58:       synchronize { ns_shuttingdown? }
// 59:     end
// 60:
// 61:     # @!macro executor_service_method_shutdown_question
// 62:     def shutdown?
// 63:       synchronize { ns_shutdown? }
// 64:     end
// 65:
// 66:     # @!macro executor_service_method_auto_terminate_question
// 67:     def auto_terminate?
// 68:       synchronize { @auto_terminate }
// 69:     end
// 70:
// 71:     # @!macro executor_service_method_auto_terminate_setter
// 72:     def auto_terminate=(value)
// 73:       deprecated "Method #auto_terminate= has no effect. Set :auto_terminate option when executor is initialized."
// 74:     end
// 75:
// 76:     private
// 77:
// 78:     # Returns an action which executes the `fallback_policy` once the queue
// 79:     # size reaches `max_queue`. The reason for the indirection of an action
// 80:     # is so that the work can be deferred outside of synchronization.
// 81:     #
// 82:     # @param [Array] args the arguments to the task which is being handled.
// 83:     #
// 84:     # @!visibility private
// 85:     def fallback_action(*args)
// 86:       case fallback_policy
// 87:       when :abort
// 88:         lambda { raise RejectedExecutionError }
// 89:       when :discard
// 90:         lambda { false }
// 91:       when :caller_runs
// 92:         lambda {
// 93:           begin
// 94:             yield(*args)
// 95:           rescue => ex
// 96:             # let it fail
// 97:             log DEBUG, ex
// 98:           end
// 99:           true
// 100:         }
// 101:       else
// 102:         lambda { fail "Unknown fallback policy #{fallback_policy}" }
// 103:       end
// 104:     end
// 105:
// 106:     def ns_execute(*args, &task)
// 107:       raise NotImplementedError
// 108:     end
// 109:
// 110:     # @!macro executor_service_method_ns_shutdown_execution
// 111:     #
// 112:     #   Callback method called when an orderly shutdown has completed.
// 113:     #   The default behavior is to signal all waiting threads.
// 114:     def ns_shutdown_execution
// 115:       # do nothing
// 116:     end
// 117:
// 118:     # @!macro executor_service_method_ns_kill_execution
// 119:     #
// 120:     #   Callback method called when the executor has been killed.
// 121:     #   The default behavior is to do nothing.
// 122:     def ns_kill_execution
// 123:       # do nothing
// 124:     end
// 125:
// 126:     def ns_auto_terminate?
// 127:       @auto_terminate
// 128:     end
// 129:
// 130:   end
// 131: end
