module executor

import brew_runtime
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/java_executor_service.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct JavaExecutorService {
mut:
	service &SimpleExecutorService
	base    &AbstractExecutorService
}

pub struct JavaExecutorJob {
pub:
	args []brew_runtime.Value
	task ExecutorTask @[required]
}

pub struct JavaDaemonThread {
pub:
	daemon   bool
	runnable brew_runtime.Value
}

@[heap]
pub struct DaemonThreadFactory {
pub:
	daemonize bool
}

pub fn new_java_executor_service(options AbstractExecutorOptions) &JavaExecutorService {
	return &JavaExecutorService{
		service: new_simple_executor_service(options)
		base: new_abstract_executor_service(options)
	}
}

pub fn (mut executor JavaExecutorService) post(task ExecutorTask, args []brew_runtime.Value) !bool {
	if !executor.service.running() {
		return executor.base.fallback(task, args)
	}
	if !executor.service.post(task, args) {
		return error('RejectedExecutionError')
	}
	return true
}

pub fn (mut executor JavaExecutorService) wait_for_termination(timeout ?time.Duration) bool {
	return executor.service.wait_for_termination(timeout)
}

pub fn (mut executor JavaExecutorService) shutdown() {
	executor.service.shutdown()
}

pub fn (mut executor JavaExecutorService) kill() {
	executor.service.kill()
	executor.service.wait_for_termination(none)
}

pub fn (mut executor JavaExecutorService) running() bool {
	return executor.service.running()
}

pub fn (mut executor JavaExecutorService) shutting_down() bool {
	return executor.service.shutting_down()
}

pub fn (mut executor JavaExecutorService) is_shutdown() bool {
	return executor.service.is_shutdown()
}

pub fn new_java_executor_job(args []brew_runtime.Value, task ExecutorTask) JavaExecutorJob {
	return JavaExecutorJob{
		args: args.clone()
		task: task
	}
}

pub fn (job JavaExecutorJob) run() ! {
	job.task(job.args)!
}

pub fn new_daemon_thread_factory(daemonize bool) &DaemonThreadFactory {
	return &DaemonThreadFactory{
		daemonize: daemonize
	}
}

pub fn (factory &DaemonThreadFactory) new_thread(runnable brew_runtime.Value) JavaDaemonThread {
	return JavaDaemonThread{
		daemon: factory.daemonize
		runnable: runnable
	}
}

fn java_executor_boundary_value(executor &JavaExecutorService) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::JavaExecutorService', '#<Concurrent::JavaExecutorService>', {
		'java_executor_address': u64(voidptr(executor)).str()
	})
}

fn java_executor_boundary_receiver(args []brew_runtime.Value) &JavaExecutorService {
	if args.len == 0 {
		panic('JavaExecutorService method requires a receiver')
	}
	address := (args[0].attribute('java_executor_address') or {
		panic('${args[0].type_name} has no translated JavaExecutorService state')
	}).u64()
	return unsafe { &JavaExecutorService(voidptr(address)) }
}

fn java_executor_job_value(job &JavaExecutorJob) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::JavaExecutorService::Job', '#<JavaExecutorService::Job>', {
		'java_executor_job_address': u64(voidptr(job)).str()
	})
}

fn java_executor_job_from_args(args []brew_runtime.Value) &JavaExecutorJob {
	if args.len == 0 {
		panic('JavaExecutorService::Job method requires a receiver')
	}
	address := (args[0].attribute('java_executor_job_address') or {
		panic('${args[0].type_name} has no translated Job state')
	}).u64()
	return unsafe { &JavaExecutorJob(voidptr(address)) }
}

fn daemon_thread_factory_value(factory &DaemonThreadFactory) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::DaemonThreadFactory', '#<Concurrent::DaemonThreadFactory>', {
		'daemon_thread_factory_address': u64(voidptr(factory)).str()
	})
}

fn daemon_thread_factory_from_args(args []brew_runtime.Value) &DaemonThreadFactory {
	if args.len == 0 {
		panic('DaemonThreadFactory method requires a receiver')
	}
	address := (args[0].attribute('daemon_thread_factory_address') or {
		panic('${args[0].type_name} has no translated DaemonThreadFactory state')
	}).u64()
	return unsafe { &DaemonThreadFactory(voidptr(address)) }
}

fn java_executor_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `post(*args, &task)` at line 21.
pub fn ruby_java_executor_service_l21_d1_post(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ArgumentError: no block given')
	}
	mut executor := java_executor_boundary_receiver(args)
	return brew_runtime.bool_value(executor.post(boundary_noop_executor_task, args[1..]) or {
		panic(err)
	})
}

// Ruby method `wait_for_termination(timeout = nil)` at line 30.
pub fn ruby_java_executor_service_l30_d2_wait_for_termination(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	return brew_runtime.bool_value(executor.wait_for_termination(executor_base_boundary_timeout(args, 1)))
}

// Ruby method `shutdown` at line 39.
pub fn ruby_java_executor_service_l39_d3_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	executor.shutdown()
	return java_executor_nil_value()
}

// Ruby method `kill` at line 46.
pub fn ruby_java_executor_service_l46_d4_kill(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	executor.kill()
	return java_executor_nil_value()
}

// Ruby method `ns_running?` at line 56.
pub fn ruby_java_executor_service_l56_d5_ns_running(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	return brew_runtime.bool_value(executor.running())
}

// Ruby method `ns_shuttingdown?` at line 60.
pub fn ruby_java_executor_service_l60_d6_ns_shuttingdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	return brew_runtime.bool_value(executor.shutting_down())
}

// Ruby method `ns_shutdown?` at line 64.
pub fn ruby_java_executor_service_l64_d7_ns_shutdown(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := java_executor_boundary_receiver(args)
	return brew_runtime.bool_value(executor.is_shutdown())
}

// Ruby method `initialize(args, block)` at line 70.
pub fn ruby_java_executor_service_l70_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	values := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_array() or { panic(err) }
	} else {
		args.clone()
	}
	job := &JavaExecutorJob{
		args: values.clone()
		task: boundary_noop_executor_task
	}
	return java_executor_job_value(job)
}

// Ruby method `run` at line 75.
pub fn ruby_java_executor_service_l75_d9_run(args ...brew_runtime.Value) brew_runtime.Value {
	java_executor_job_from_args(args).run() or { panic(err) }
	return java_executor_nil_value()
}

// Ruby method `initialize(daemonize = true)` at line 86.
pub fn ruby_java_executor_service_l86_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	daemonize := if args.len > 0 { args[0].as_bool() or { true } } else { true }
	return daemon_thread_factory_value(new_daemon_thread_factory(daemonize))
}

// Ruby method `newThread(runnable)` at line 91.
pub fn ruby_java_executor_service_l91_d11_newthread(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DaemonThreadFactory#newThread requires a runnable')
	}
	factory := daemon_thread_factory_from_args(args)
	java_thread := factory.new_thread(args[1])
	return brew_runtime.structured_value('Java::JavaLang::Thread', '#<JavaThread>', {
		'daemon':        java_thread.daemon.str()
		'runnable_type': java_thread.runnable.type_name
	})
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
