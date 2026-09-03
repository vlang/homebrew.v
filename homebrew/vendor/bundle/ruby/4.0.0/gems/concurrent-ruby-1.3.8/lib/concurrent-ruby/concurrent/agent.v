module concurrent

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/agent.rb`.
// The original source is retained below for source-parity auditing.
pub type AgentAction = fn(brew_runtime.Value, []brew_runtime.Value) !brew_runtime.Value

pub type AgentValidator = fn(brew_runtime.Value) !bool

pub type AgentErrorHandler = fn(&Agent, string)

pub type AgentObserver = fn(i64, brew_runtime.Value, brew_runtime.Value)

pub struct AgentOptions {
pub:
	error_mode    string
	error_handler ?AgentErrorHandler
	validator     ?AgentValidator
}

struct AgentJob {
	action   ?AgentAction
	args     []brew_runtime.Value
	executor ScheduledExecutor
	done     chan bool
}

@[heap]
pub struct Agent {
	mutex &sync.Mutex
mut:
	current       brew_runtime.Value
	error_message string
	error_mode    string
	error_handler AgentErrorHandler = agent_default_error_handler
	validator     AgentValidator = agent_default_validator
	queue         []AgentJob
	processing    bool
	observers     []AgentObserver
}

fn agent_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn agent_default_error_handler(_ &Agent, _ string) {}

fn agent_default_validator(_ brew_runtime.Value) !bool {
	return true
}

fn agent_constant_action(_ brew_runtime.Value, args []brew_runtime.Value) !brew_runtime.Value {
	if args.len == 0 {
		return error('no action value given')
	}
	return args.last()
}

pub fn new_agent(initial brew_runtime.Value, options AgentOptions) &Agent {
	mode := if options.error_mode.len > 0 {
		options.error_mode.trim_left(':')
	} else if options.error_handler != none {
		'continue'
	} else {
		'fail'
	}
	if mode !in ['continue', 'fail'] {
		panic('ArgumentError: unrecognized error mode')
	}
	mut agent := &Agent{
		mutex: sync.new_mutex()
		current: initial
		error_mode: mode
	}
	if handler := options.error_handler {
		agent.error_handler = handler
	}
	if validator := options.validator {
		agent.validator = validator
	}
	return agent
}

pub fn (agent &Agent) value() brew_runtime.Value {
	agent.mutex.lock()
	value := agent.current
	agent.mutex.unlock()
	return value
}

pub fn (agent &Agent) error() string {
	agent.mutex.lock()
	message := agent.error_message
	agent.mutex.unlock()
	return message
}

pub fn (agent &Agent) error_mode() string {
	return agent.error_mode
}

pub fn (agent &Agent) failed() bool {
	return agent.error().len > 0
}

pub fn (mut agent Agent) add_observer(observer AgentObserver) {
	agent.mutex.lock()
	agent.observers << observer
	agent.mutex.unlock()
}

fn agent_execute_post(args []brew_runtime.Value) {
	if args.len == 0 {
		return
	}
	mut agent := unsafe { &Agent(voidptr(args[0].int_data)) }
	agent.execute_next_job()
}

fn (mut agent Agent) post_job(job AgentJob, allow_failed bool, index ?int) bool {
	agent.mutex.lock()
	if !allow_failed && agent.error_message.len > 0 {
		agent.mutex.unlock()
		return false
	}
	if insertion := index {
		agent.queue.insert(insertion, job)
	} else {
		agent.queue << job
	}
	start := !agent.processing && agent.error_message.len == 0
	if start {
		agent.processing = true
	}
	agent.mutex.unlock()
	if start {
		job.executor.post(agent_execute_post, [
			brew_runtime.int_value(i64(voidptr(&agent))),
		])
	}
	return true
}

pub fn (mut agent Agent) send_action(action AgentAction, args []brew_runtime.Value) bool {
	return agent.send_via(global_fast_executor().adapter, action, args)
}

pub fn (mut agent Agent) send_off(action AgentAction, args []brew_runtime.Value) bool {
	return agent.send_via(global_io_executor().adapter, action, args)
}

pub fn (mut agent Agent) send_via(executor ScheduledExecutor, action AgentAction,
	args []brew_runtime.Value) bool {
	return agent.post_job(AgentJob{
		action: action
		args: args.clone()
		executor: executor
		done: chan bool{ cap: 1 }
	}, false, none)
}

pub fn (mut agent Agent) send_bang(action AgentAction, args []brew_runtime.Value) !bool {
	if !agent.send_action(action, args) {
		return error('agent must be restarted before jobs can post')
	}
	return true
}

pub fn (mut agent Agent) send_off_bang(action AgentAction, args []brew_runtime.Value) !bool {
	if !agent.send_off(action, args) {
		return error('agent must be restarted before jobs can post')
	}
	return true
}

pub fn (mut agent Agent) send_via_bang(executor ScheduledExecutor, action AgentAction,
	args []brew_runtime.Value) !bool {
	if !agent.send_via(executor, action, args) {
		return error('agent must be restarted before jobs can post')
	}
	return true
}

fn (mut agent Agent) enqueue_await_job() chan bool {
	done := chan bool{ cap: 1 }
	job := AgentJob{
		action: none
		executor: global_immediate_executor().adapter
		done: done
	}
	agent.post_job(job, true, none)
	return done
}

pub fn (mut agent Agent) wait(timeout ?time.Duration) bool {
	done := agent.enqueue_await_job()
	if duration := timeout {
		if duration <= 0 {
			select {
				_ := <-done {
					return true
				}
				else {
					return false
				}
			}
		}
		select {
			_ := <-done {
				return true
			}
			duration {
				return false
			}
		}
	}
	_ = <-done
	return true
}

pub fn (mut agent Agent) await() &Agent {
	agent.wait(none)
	return &agent
}

pub fn (mut agent Agent) await_for(timeout time.Duration) bool {
	return agent.wait(timeout)
}

pub fn (mut agent Agent) await_for_bang(timeout time.Duration) !bool {
	if !agent.wait(timeout) {
		return error('TimeoutError')
	}
	return true
}

pub fn (mut agent Agent) restart(new_value brew_runtime.Value, clear_actions bool) !bool {
	valid := agent.validator(new_value) or { false }
	if !valid {
		return error('invalid value')
	}
	agent.mutex.lock()
	if agent.error_message.len == 0 {
		agent.mutex.unlock()
		return error('agent is not failed')
	}
	agent.current = new_value
	agent.error_message = ''
	if clear_actions {
		agent.queue.clear()
	}
	start := !agent.processing && agent.queue.len > 0
	if start {
		agent.processing = true
	}
	executor := if start { agent.queue[0].executor } else { global_immediate_executor().adapter }
	agent.mutex.unlock()
	if start {
		executor.post(agent_execute_post, [
			brew_runtime.int_value(i64(voidptr(&agent))),
		])
	}
	return true
}

fn (mut agent Agent) handle_error(message string) {
	agent.mutex.lock()
	if agent.error_mode == 'fail' {
		agent.error_message = message
	}
	handler := agent.error_handler
	agent.mutex.unlock()
	handler(&agent, message)
}

fn (mut agent Agent) execute_next_job() {
	agent.mutex.lock()
	if agent.queue.len == 0 {
		agent.processing = false
		agent.mutex.unlock()
		return
	}
	job := agent.queue[0]
	old_value := agent.current
	agent.mutex.unlock()
	if action := job.action {
		new_value := action(old_value, job.args) or {
			agent.handle_error(err.msg())
			agent.finish_job(job)
			return
		}
		valid := agent.validator(new_value) or { false }
		if valid {
			agent.mutex.lock()
			agent.current = new_value
			observers := agent.observers.clone()
			agent.mutex.unlock()
			changed_at := time.now().unix_nano()
			for observer in observers {
				observer(changed_at, old_value, new_value)
			}
		} else {
			agent.handle_error('invalid value')
		}
	} else {
		job.done <- true
	}
	agent.finish_job(job)
}

fn (mut agent Agent) finish_job(_ AgentJob) {
	agent.mutex.lock()
	if agent.queue.len > 0 {
		agent.queue.delete(0)
	}
	can_continue := agent.error_message.len == 0 && agent.queue.len > 0
	if !can_continue {
		agent.processing = false
	}
	executor := if can_continue {
		agent.queue[0].executor
	} else {
		global_immediate_executor().adapter
	}
	agent.mutex.unlock()
	if can_continue {
		executor.post(agent_execute_post, [
			brew_runtime.int_value(i64(voidptr(&agent))),
		])
	}
}

pub fn await_agents(mut agents []&Agent) bool {
	for mut agent in agents {
		agent.await()
	}
	return true
}

pub fn await_agents_for(timeout time.Duration, mut agents []&Agent) bool {
	deadline := time.sys_mono_now() + u64(timeout)
	for mut agent in agents {
		now := time.sys_mono_now()
		if now >= deadline || !agent.await_for(time.Duration(deadline - now)) {
			return false
		}
	}
	return true
}

fn agent_options_from_value(value brew_runtime.Value) AgentOptions {
	if value.type_name != 'Hash' {
		return AgentOptions{}
	}
	options := value.as_map() or { return AgentOptions{} }
	return AgentOptions{
		error_mode: if 'error_mode' in options { options['error_mode'].as_string() } else { '' }
	}
}

fn agent_boundary_value(agent &Agent) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::Agent', '#<Concurrent::Agent>', {
		'agent_address': u64(voidptr(agent)).str()
	})
}

fn agent_boundary_receiver(args []brew_runtime.Value) &Agent {
	if args.len == 0 {
		panic('Agent method requires a receiver')
	}
	address := (args[0].attribute('agent_address') or {
		panic('${args[0].type_name} has no translated Agent state')
	}).u64()
	return unsafe { &Agent(voidptr(address)) }
}

fn agent_boundary_timeout(value brew_runtime.Value) time.Duration {
	return time.Duration(value.as_float() or { panic(err) } * f64(time.second))
}

fn agent_boundary_send(args []brew_runtime.Value, mode string) brew_runtime.Value {
	if args.len < 2 {
		panic('ArgumentError: no action given')
	}
	mut agent := agent_boundary_receiver(args)
	values := args[1..].clone()
	ok := match mode {
		'fast' { agent.send_action(agent_constant_action, values) }
		'io' { agent.send_off(agent_constant_action, values) }
		else { agent.send_via(global_immediate_executor().adapter, agent_constant_action, values) }
	}
	return brew_runtime.bool_value(ok)
}

// Ruby method `initialize(message = nil)` at line 168.
pub fn ruby_agent_l168_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	message := if args.len > 0 {
		args[0].as_string()
	} else {
		'agent must be restarted before jobs can post'
	}
	return brew_runtime.object_value('Concurrent::Agent::Error', message)
}

// Ruby method `initialize(message = nil)` at line 177.
pub fn ruby_agent_l177_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	message := if args.len > 0 { args[0].as_string() } else { 'invalid value' }
	return brew_runtime.object_value('Concurrent::Agent::ValidationError', message)
}

// Ruby attr_reader `attr_reader :error_mode` at line 184.
pub fn ruby_agent_l184_d3_error_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(agent_boundary_receiver(args).error_mode())
}

// Ruby method `initialize(initial, opts = {})` at line 220.
pub fn ruby_agent_l220_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Agent.new requires an initial value') }
	options := if args.len > 1 { agent_options_from_value(args[1]) } else { AgentOptions{} }
	return agent_boundary_value(new_agent(args[0], options))
}

// Ruby method `value` at line 229.
pub fn ruby_agent_l229_d5_value(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_receiver(args).value()
}

// Ruby alias_method `alias_method :deref, :value` at line 233.
pub fn ruby_agent_l233_d6_deref(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_agent_l229_d5_value(...args)
}

// Ruby method `error` at line 240.
pub fn ruby_agent_l240_d7_error(args ...brew_runtime.Value) brew_runtime.Value {
	message := agent_boundary_receiver(args).error()
	return if message.len == 0 {
		agent_nil_value()
	} else {
		brew_runtime.object_value('StandardError', message)
	}
}

// Ruby alias_method `alias_method :reason, :error` at line 244.
pub fn ruby_agent_l244_d8_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_agent_l240_d7_error(...args)
}

// Ruby method `send(*args, &action)` at line 278.
pub fn ruby_agent_l278_d9_send(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_send(args, 'fast')
}

// Ruby method `send!(*args, &action)` at line 287.
pub fn ruby_agent_l287_d10_send(args ...brew_runtime.Value) brew_runtime.Value {
	value := agent_boundary_send(args, 'fast')
	if !value.bool_data { panic('agent must be restarted before jobs can post') }
	return brew_runtime.bool_value(true)
}

// Ruby method `send_off(*args, &action)` at line 294.
pub fn ruby_agent_l294_d11_send_off(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_send(args, 'io')
}

// Ruby alias_method `alias_method :post, :send_off` at line 298.
pub fn ruby_agent_l298_d12_post(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_agent_l294_d11_send_off(...args)
}

// Ruby method `send_off!(*args, &action)` at line 302.
pub fn ruby_agent_l302_d13_send_off(args ...brew_runtime.Value) brew_runtime.Value {
	value := agent_boundary_send(args, 'io')
	if !value.bool_data { panic('agent must be restarted before jobs can post') }
	return brew_runtime.bool_value(true)
}

// Ruby method `send_via(executor, *args, &action)` at line 311.
pub fn ruby_agent_l311_d14_send_via(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_send(args, 'via')
}

// Ruby method `send_via!(executor, *args, &action)` at line 319.
pub fn ruby_agent_l319_d15_send_via(args ...brew_runtime.Value) brew_runtime.Value {
	value := agent_boundary_send(args, 'via')
	if !value.bool_data { panic('agent must be restarted before jobs can post') }
	return brew_runtime.bool_value(true)
}

// Ruby method `<<(action)` at line 331.
pub fn ruby_agent_l331_d16_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	agent_boundary_send(args, 'io')
	return args[0]
}

// Ruby method `await` at line 350.
pub fn ruby_agent_l350_d17_await(args ...brew_runtime.Value) brew_runtime.Value {
	mut agent := agent_boundary_receiver(args)
	agent.await()
	return args[0]
}

// Ruby method `await_for(timeout)` at line 363.
pub fn ruby_agent_l363_d18_await_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Agent#await_for requires timeout') }
	mut agent := agent_boundary_receiver(args)
	return brew_runtime.bool_value(agent.await_for(agent_boundary_timeout(args[1])))
}

// Ruby method `await_for!(timeout)` at line 377.
pub fn ruby_agent_l377_d19_await_for(args ...brew_runtime.Value) brew_runtime.Value {
	if !ruby_agent_l363_d18_await_for(...args).bool_data { panic('TimeoutError') }
	return brew_runtime.bool_value(true)
}

// Ruby method `wait(timeout = nil)` at line 393.
pub fn ruby_agent_l393_d20_wait(args ...brew_runtime.Value) brew_runtime.Value {
	mut agent := agent_boundary_receiver(args)
	timeout := if args.len > 1 && args[1].type_name != 'NilClass' {
		?time.Duration(agent_boundary_timeout(args[1]))
	} else {
		none
	}
	return brew_runtime.bool_value(agent.wait(timeout))
}

// Ruby method `failed?` at line 402.
pub fn ruby_agent_l402_d21_failed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(agent_boundary_receiver(args).failed())
}

// Ruby alias_method `alias_method :stopped?, :failed?` at line 406.
pub fn ruby_agent_l406_d22_stopped(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_agent_l402_d21_failed(...args)
}

// Ruby method `restart(new_value, opts = {})` at line 424.
pub fn ruby_agent_l424_d23_restart(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Agent#restart requires a new value') }
	mut agent := agent_boundary_receiver(args)
	clear := if args.len > 2 && args[2].type_name == 'Hash' {
		(args[2].as_map() or { map[string]brew_runtime.Value{} })['clear_actions'].as_bool() or { false }
	} else {
		false
	}
	return brew_runtime.bool_value(agent.restart(args[1], clear) or { panic(err) })
}

// Ruby method `await(*agents)` at line 449.
pub fn ruby_agent_l449_d24_await(args ...brew_runtime.Value) brew_runtime.Value {
	for value in args {
		mut agent := agent_boundary_receiver([value])
		agent.await()
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `await_for(timeout, *agents)` at line 463.
pub fn ruby_agent_l463_d25_await_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Agent.await_for requires timeout') }
	deadline := time.sys_mono_now() + u64(agent_boundary_timeout(args[0]))
	for value in args[1..] {
		now := time.sys_mono_now()
		if now >= deadline {
			return brew_runtime.bool_value(false)
		}
		mut agent := agent_boundary_receiver([value])
		if !agent.await_for(time.Duration(deadline - now)) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `await_for!(timeout, *agents)` at line 482.
pub fn ruby_agent_l482_d26_await_for(args ...brew_runtime.Value) brew_runtime.Value {
	if !ruby_agent_l463_d25_await_for(...args).bool_data { panic('TimeoutError') }
	return brew_runtime.bool_value(true)
}

// Ruby method `ns_initialize(initial, opts)` at line 490.
pub fn ruby_agent_l490_d27_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_agent_l220_d4_initialize(...args)
}

// Ruby method `enqueue_action_job(action, args, executor)` at line 510.
pub fn ruby_agent_l510_d28_enqueue_action_job(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_send(args, 'fast')
}

// Ruby method `enqueue_await_job(latch)` at line 516.
pub fn ruby_agent_l516_d29_enqueue_await_job(args ...brew_runtime.Value) brew_runtime.Value {
	mut agent := agent_boundary_receiver(args)
	agent.enqueue_await_job()
	return brew_runtime.object_value('Concurrent::CountDownLatch', '#<CountDownLatch>')
}

// Ruby method `ns_enqueue_job(job, index = nil)` at line 529.
pub fn ruby_agent_l529_d30_ns_enqueue_job(args ...brew_runtime.Value) brew_runtime.Value {
	return agent_boundary_send(args, 'fast')
}

// Ruby method `ns_post_next_job` at line 539.
pub fn ruby_agent_l539_d31_ns_post_next_job(args ...brew_runtime.Value) brew_runtime.Value {
	mut agent := agent_boundary_receiver(args)
	agent.mutex.lock()
	should_post := !agent.processing && agent.queue.len > 0
	if should_post {
		agent.processing = true
	}
	executor := if should_post {
		agent.queue[0].executor
	} else {
		global_immediate_executor().adapter
	}
	agent.mutex.unlock()
	if should_post {
		executor.post(agent_execute_post, [
			brew_runtime.int_value(i64(voidptr(agent))),
		])
	}
	return agent_nil_value()
}

// Ruby method `execute_next_job` at line 543.
pub fn ruby_agent_l543_d32_execute_next_job(args ...brew_runtime.Value) brew_runtime.Value {
	mut agent := agent_boundary_receiver(args)
	agent.execute_next_job()
	return agent_nil_value()
}

// Ruby method `ns_validate(value)` at line 570.
pub fn ruby_agent_l570_d33_ns_validate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Agent#ns_validate requires a value') }
	agent := agent_boundary_receiver(args)
	return brew_runtime.bool_value(agent.validator(args[1]) or { false })
}

// Ruby method `handle_error(error)` at line 576.
pub fn ruby_agent_l576_d34_handle_error(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Agent#handle_error requires an error') }
	mut agent := agent_boundary_receiver(args)
	agent.handle_error(args[1].as_string())
	return agent_nil_value()
}

// Ruby method `ns_find_last_job_for_thread` at line 584.
pub fn ruby_agent_l584_d35_ns_find_last_job_for_thread(args ...brew_runtime.Value) brew_runtime.Value {
	agent := agent_boundary_receiver(args)
	agent.mutex.lock()
	index := agent.queue.len - 1
	agent.mutex.unlock()
	return if index < 0 { agent_nil_value() } else { brew_runtime.int_value(index) }
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/configuration'
// 2: require 'concurrent/atomic/atomic_reference'
// 3: require 'concurrent/atomic/count_down_latch'
// 4: require 'concurrent/atomic/thread_local_var'
// 5: require 'concurrent/collection/copy_on_write_observer_set'
// 6: require 'concurrent/concern/observable'
// 7: require 'concurrent/synchronization/lockable_object'
// 8:
// 9: module Concurrent
// 10:
// 11:   # `Agent` is inspired by Clojure's [agent](http://clojure.org/agents)
// 12:   # function. An agent is a shared, mutable variable providing independent,
// 13:   # uncoordinated, *asynchronous* change of individual values. Best used when
// 14:   # the value will undergo frequent, complex updates. Suitable when the result
// 15:   # of an update does not need to be known immediately. `Agent` is (mostly)
// 16:   # functionally equivalent to Clojure's agent, except where the runtime
// 17:   # prevents parity.
// 18:   #
// 19:   # Agents are reactive, not autonomous - there is no imperative message loop
// 20:   # and no blocking receive. The state of an Agent should be itself immutable
// 21:   # and the `#value` of an Agent is always immediately available for reading by
// 22:   # any thread without any messages, i.e. observation does not require
// 23:   # cooperation or coordination.
// 24:   #
// 25:   # Agent action dispatches are made using the various `#send` methods. These
// 26:   # methods always return immediately. At some point later, in another thread,
// 27:   # the following will happen:
// 28:   #
// 29:   # 1. The given `action` will be applied to the state of the Agent and the
// 30:   #    `args`, if any were supplied.
// 31:   # 2. The return value of `action` will be passed to the validator lambda,
// 32:   #    if one has been set on the Agent.
// 33:   # 3. If the validator succeeds or if no validator was given, the return value
// 34:   #    of the given `action` will become the new `#value` of the Agent. See
// 35:   #    `#initialize` for details.
// 36:   # 4. If any observers were added to the Agent, they will be notified. See
// 37:   #    `#add_observer` for details.
// 38:   # 5. If during the `action` execution any other dispatches are made (directly
// 39:   #    or indirectly), they will be held until after the `#value` of the Agent
// 40:   #    has been changed.
// 41:   #
// 42:   # If any exceptions are thrown by an action function, no nested dispatches
// 43:   # will occur, and the exception will be cached in the Agent itself. When an
// 44:   # Agent has errors cached, any subsequent interactions will immediately throw
// 45:   # an exception, until the agent's errors are cleared. Agent errors can be
// 46:   # examined with `#error` and the agent restarted with `#restart`.
// 47:   #
// 48:   # The actions of all Agents get interleaved amongst threads in a thread pool.
// 49:   # At any point in time, at most one action for each Agent is being executed.
// 50:   # Actions dispatched to an agent from another single agent or thread will
// 51:   # occur in the order they were sent, potentially interleaved with actions
// 52:   # dispatched to the same agent from other sources. The `#send` method should
// 53:   # be used for actions that are CPU limited, while the `#send_off` method is
// 54:   # appropriate for actions that may block on IO.
// 55:   #
// 56:   # Unlike in Clojure, `Agent` cannot participate in `Concurrent::TVar` transactions.
// 57:   #
// 58:   # ## Example
// 59:   #
// 60:   # ```
// 61:   # def next_fibonacci(set = nil)
// 62:   #   return [0, 1] if set.nil?
// 63:   #   set + [set[-2..-1].reduce{|sum,x| sum + x }]
// 64:   # end
// 65:   #
// 66:   # # create an agent with an initial value
// 67:   # agent = Concurrent::Agent.new(next_fibonacci)
// 68:   #
// 69:   # # send a few update requests
// 70:   # 5.times do
// 71:   #   agent.send{|set| next_fibonacci(set) }
// 72:   # end
// 73:   #
// 74:   # # wait for them to complete
// 75:   # agent.await
// 76:   #
// 77:   # # get the current value
// 78:   # agent.value #=> [0, 1, 1, 2, 3, 5, 8]
// 79:   # ```
// 80:   #
// 81:   # ## Observation
// 82:   #
// 83:   # Agents support observers through the {Concurrent::Observable} mixin module.
// 84:   # Notification of observers occurs every time an action dispatch returns and
// 85:   # the new value is successfully validated. Observation will *not* occur if the
// 86:   # action raises an exception, if validation fails, or when a {#restart} occurs.
// 87:   #
// 88:   # When notified the observer will receive three arguments: `time`, `old_value`,
// 89:   # and `new_value`. The `time` argument is the time at which the value change
// 90:   # occurred. The `old_value` is the value of the Agent when the action began
// 91:   # processing. The `new_value` is the value to which the Agent was set when the
// 92:   # action completed. Note that `old_value` and `new_value` may be the same.
// 93:   # This is not an error. It simply means that the action returned the same
// 94:   # value.
// 95:   #
// 96:   # ## Nested Actions
// 97:   #
// 98:   # It is possible for an Agent action to post further actions back to itself.
// 99:   # The nested actions will be enqueued normally then processed *after* the
// 100:   # outer action completes, in the order they were sent, possibly interleaved
// 101:   # with action dispatches from other threads. Nested actions never deadlock
// 102:   # with one another and a failure in a nested action will never affect the
// 103:   # outer action.
// 104:   #
// 105:   # Nested actions can be called using the Agent reference from the enclosing
// 106:   # scope or by passing the reference in as a "send" argument. Nested actions
// 107:   # cannot be post using `self` from within the action block/proc/lambda; `self`
// 108:   # in this context will not reference the Agent. The preferred method for
// 109:   # dispatching nested actions is to pass the Agent as an argument. This allows
// 110:   # Ruby to more effectively manage the closing scope.
// 111:   #
// 112:   # Prefer this:
// 113:   #
// 114:   # ```
// 115:   # agent = Concurrent::Agent.new(0)
// 116:   # agent.send(agent) do |value, this|
// 117:   #   this.send {|v| v + 42 }
// 118:   #   3.14
// 119:   # end
// 120:   # agent.value #=> 45.14
// 121:   # ```
// 122:   #
// 123:   # Over this:
// 124:   #
// 125:   # ```
// 126:   # agent = Concurrent::Agent.new(0)
// 127:   # agent.send do |value|
// 128:   #   agent.send {|v| v + 42 }
// 129:   #   3.14
// 130:   # end
// 131:   # ```
// 132:   #
// 133:   # @!macro agent_await_warning
// 134:   #
// 135:   #   **NOTE** Never, *under any circumstances*, call any of the "await" methods
// 136:   #   ({#await}, {#await_for}, {#await_for!}, and {#wait}) from within an action
// 137:   #   block/proc/lambda. The call will block the Agent and will always fail.
// 138:   #   Calling either {#await} or {#wait} (with a timeout of `nil`) will
// 139:   #   hopelessly deadlock the Agent with no possibility of recovery.
// 140:   #
// 141:   # @!macro thread_safe_variable_comparison
// 142:   #
// 143:   # @see http://clojure.org/Agents Clojure Agents
// 144:   # @see http://clojure.org/state Values and Change - Clojure's approach to Identity and State
// 145:   class Agent < Synchronization::LockableObject
// 146:     include Concern::Observable
// 147:
// 148:     ERROR_MODES = [:continue, :fail].freeze
// 149:     private_constant :ERROR_MODES
// 150:
// 151:     AWAIT_FLAG = ::Object.new
// 152:     private_constant :AWAIT_FLAG
// 153:
// 154:     AWAIT_ACTION = ->(value, latch) { latch.count_down; AWAIT_FLAG }
// 155:     private_constant :AWAIT_ACTION
// 156:
// 157:     DEFAULT_ERROR_HANDLER = ->(agent, error) { nil }
// 158:     private_constant :DEFAULT_ERROR_HANDLER
// 159:
// 160:     DEFAULT_VALIDATOR = ->(value) { true }
// 161:     private_constant :DEFAULT_VALIDATOR
// 162:
// 163:     Job = Struct.new(:action, :args, :executor, :caller)
// 164:     private_constant :Job
// 165:
// 166:     # Raised during action processing or any other time in an Agent's lifecycle.
// 167:     class Error < StandardError
// 168:       def initialize(message = nil)
// 169:         message ||= 'agent must be restarted before jobs can post'
// 170:         super(message)
// 171:       end
// 172:     end
// 173:
// 174:     # Raised when a new value obtained during action processing or at `#restart`
// 175:     # fails validation.
// 176:     class ValidationError < Error
// 177:       def initialize(message = nil)
// 178:         message ||= 'invalid value'
// 179:         super(message)
// 180:       end
// 181:     end
// 182:
// 183:     # The error mode this Agent is operating in. See {#initialize} for details.
// 184:     attr_reader :error_mode
// 185:
// 186:     # Create a new `Agent` with the given initial value and options.
// 187:     #
// 188:     # The `:validator` option must be `nil` or a side-effect free proc/lambda
// 189:     # which takes one argument. On any intended value change the validator, if
// 190:     # provided, will be called. If the new value is invalid the validator should
// 191:     # return `false` or raise an error.
// 192:     #
// 193:     # The `:error_handler` option must be `nil` or a proc/lambda which takes two
// 194:     # arguments. When an action raises an error or validation fails, either by
// 195:     # returning false or raising an error, the error handler will be called. The
// 196:     # arguments to the error handler will be a reference to the agent itself and
// 197:     # the error object which was raised.
// 198:     #
// 199:     # The `:error_mode` may be either `:continue` (the default if an error
// 200:     # handler is given) or `:fail` (the default if error handler nil or not
// 201:     # given).
// 202:     #
// 203:     # If an action being run by the agent throws an error or doesn't pass
// 204:     # validation the error handler, if present, will be called. After the
// 205:     # handler executes if the error mode is `:continue` the Agent will continue
// 206:     # as if neither the action that caused the error nor the error itself ever
// 207:     # happened.
// 208:     #
// 209:     # If the mode is `:fail` the Agent will become {#failed?} and will stop
// 210:     # accepting new action dispatches. Any previously queued actions will be
// 211:     # held until {#restart} is called. The {#value} method will still work,
// 212:     # returning the value of the Agent before the error.
// 213:     #
// 214:     # @param [Object] initial the initial value
// 215:     # @param [Hash] opts the configuration options
// 216:     #
// 217:     # @option opts [Symbol] :error_mode either `:continue` or `:fail`
// 218:     # @option opts [nil, Proc] :error_handler the (optional) error handler
// 219:     # @option opts [nil, Proc] :validator the (optional) validation procedure
// 220:     def initialize(initial, opts = {})
// 221:       super()
// 222:       synchronize { ns_initialize(initial, opts) }
// 223:     end
// 224:
// 225:     # The current value (state) of the Agent, irrespective of any pending or
// 226:     # in-progress actions. The value is always available and is non-blocking.
// 227:     #
// 228:     # @return [Object] the current value
// 229:     def value
// 230:       @current.value # TODO (pitr 12-Sep-2015): broken unsafe read?
// 231:     end
// 232:
// 233:     alias_method :deref, :value
// 234:
// 235:     # When {#failed?} and {#error_mode} is `:fail`, returns the error object
// 236:     # which caused the failure, else `nil`. When {#error_mode} is `:continue`
// 237:     # will *always* return `nil`.
// 238:     #
// 239:     # @return [nil, Error] the error which caused the failure when {#failed?}
// 240:     def error
// 241:       @error.value
// 242:     end
// 243:
// 244:     alias_method :reason, :error
// 245:
// 246:     # @!macro agent_send
// 247:     #
// 248:     #   Dispatches an action to the Agent and returns immediately. Subsequently,
// 249:     #   in a thread from a thread pool, the {#value} will be set to the return
// 250:     #   value of the action. Action dispatches are only allowed when the Agent
// 251:     #   is not {#failed?}.
// 252:     #
// 253:     #   The action must be a block/proc/lambda which takes 1 or more arguments.
// 254:     #   The first argument is the current {#value} of the Agent. Any arguments
// 255:     #   passed to the send method via the `args` parameter will be passed to the
// 256:     #   action as the remaining arguments. The action must return the new value
// 257:     #   of the Agent.
// 258:     #
// 259:     #   * {#send} and {#send!} should be used for actions that are CPU limited
// 260:     #   * {#send_off}, {#send_off!}, and {#<<} are appropriate for actions that
// 261:     #     may block on IO
// 262:     #   * {#send_via} and {#send_via!} are used when a specific executor is to
// 263:     #     be used for the action
// 264:     #
// 265:     #   @param [Array<Object>] args zero or more arguments to be passed to
// 266:     #     the action
// 267:     #   @param [Proc] action the action dispatch to be enqueued
// 268:     #
// 269:     #   @yield [agent, value, *args] process the old value and return the new
// 270:     #   @yieldparam [Object] value the current {#value} of the Agent
// 271:     #   @yieldparam [Array<Object>] args zero or more arguments to pass to the
// 272:     #     action
// 273:     #   @yieldreturn [Object] the new value of the Agent
// 274:     #
// 275:     # @!macro send_return
// 276:     #   @return [Boolean] true if the action is successfully enqueued, false if
// 277:     #     the Agent is {#failed?}
// 278:     def send(*args, &action)
// 279:       enqueue_action_job(action, args, Concurrent.global_fast_executor)
// 280:     end
// 281:
// 282:     # @!macro agent_send
// 283:     #
// 284:     # @!macro send_bang_return_and_raise
// 285:     #   @return [Boolean] true if the action is successfully enqueued
// 286:     #   @raise [Concurrent::Agent::Error] if the Agent is {#failed?}
// 287:     def send!(*args, &action)
// 288:       raise Error.new unless send(*args, &action)
// 289:       true
// 290:     end
// 291:
// 292:     # @!macro agent_send
// 293:     # @!macro send_return
// 294:     def send_off(*args, &action)
// 295:       enqueue_action_job(action, args, Concurrent.global_io_executor)
// 296:     end
// 297:
// 298:     alias_method :post, :send_off
// 299:
// 300:     # @!macro agent_send
// 301:     # @!macro send_bang_return_and_raise
// 302:     def send_off!(*args, &action)
// 303:       raise Error.new unless send_off(*args, &action)
// 304:       true
// 305:     end
// 306:
// 307:     # @!macro agent_send
// 308:     # @!macro send_return
// 309:     # @param [Concurrent::ExecutorService] executor the executor on which the
// 310:     #   action is to be dispatched
// 311:     def send_via(executor, *args, &action)
// 312:       enqueue_action_job(action, args, executor)
// 313:     end
// 314:
// 315:     # @!macro agent_send
// 316:     # @!macro send_bang_return_and_raise
// 317:     # @param [Concurrent::ExecutorService] executor the executor on which the
// 318:     #   action is to be dispatched
// 319:     def send_via!(executor, *args, &action)
// 320:       raise Error.new unless send_via(executor, *args, &action)
// 321:       true
// 322:     end
// 323:
// 324:     # Dispatches an action to the Agent and returns immediately. Subsequently,
// 325:     # in a thread from a thread pool, the {#value} will be set to the return
// 326:     # value of the action. Appropriate for actions that may block on IO.
// 327:     #
// 328:     # @param [Proc] action the action dispatch to be enqueued
// 329:     # @return [Concurrent::Agent] self
// 330:     # @see #send_off
// 331:     def <<(action)
// 332:       send_off(&action)
// 333:       self
// 334:     end
// 335:
// 336:     # Blocks the current thread (indefinitely!) until all actions dispatched
// 337:     # thus far, from this thread or nested by the Agent, have occurred. Will
// 338:     # block when {#failed?}. Will never return if a failed Agent is {#restart}
// 339:     # with `:clear_actions` true.
// 340:     #
// 341:     # Returns a reference to `self` to support method chaining:
// 342:     #
// 343:     # ```
// 344:     # current_value = agent.await.value
// 345:     # ```
// 346:     #
// 347:     # @return [Boolean] self
// 348:     #
// 349:     # @!macro agent_await_warning
// 350:     def await
// 351:       wait(nil)
// 352:       self
// 353:     end
// 354:
// 355:     # Blocks the current thread until all actions dispatched thus far, from this
// 356:     # thread or nested by the Agent, have occurred, or the timeout (in seconds)
// 357:     # has elapsed.
// 358:     #
// 359:     # @param [Float] timeout the maximum number of seconds to wait
// 360:     # @return [Boolean] true if all actions complete before timeout else false
// 361:     #
// 362:     # @!macro agent_await_warning
// 363:     def await_for(timeout)
// 364:       wait(timeout.to_f)
// 365:     end
// 366:
// 367:     # Blocks the current thread until all actions dispatched thus far, from this
// 368:     # thread or nested by the Agent, have occurred, or the timeout (in seconds)
// 369:     # has elapsed.
// 370:     #
// 371:     # @param [Float] timeout the maximum number of seconds to wait
// 372:     # @return [Boolean] true if all actions complete before timeout
// 373:     #
// 374:     # @raise [Concurrent::TimeoutError] when timeout is reached
// 375:     #
// 376:     # @!macro agent_await_warning
// 377:     def await_for!(timeout)
// 378:       raise Concurrent::TimeoutError unless wait(timeout.to_f)
// 379:       true
// 380:     end
// 381:
// 382:     # Blocks the current thread until all actions dispatched thus far, from this
// 383:     # thread or nested by the Agent, have occurred, or the timeout (in seconds)
// 384:     # has elapsed. Will block indefinitely when timeout is nil or not given.
// 385:     #
// 386:     # Provided mainly for consistency with other classes in this library. Prefer
// 387:     # the various `await` methods instead.
// 388:     #
// 389:     # @param [Float] timeout the maximum number of seconds to wait
// 390:     # @return [Boolean] true if all actions complete before timeout else false
// 391:     #
// 392:     # @!macro agent_await_warning
// 393:     def wait(timeout = nil)
// 394:       latch = Concurrent::CountDownLatch.new(1)
// 395:       enqueue_await_job(latch)
// 396:       latch.wait(timeout)
// 397:     end
// 398:
// 399:     # Is the Agent in a failed state?
// 400:     #
// 401:     # @see #restart
// 402:     def failed?
// 403:       !@error.value.nil?
// 404:     end
// 405:
// 406:     alias_method :stopped?, :failed?
// 407:
// 408:     # When an Agent is {#failed?}, changes the Agent {#value} to `new_value`
// 409:     # then un-fails the Agent so that action dispatches are allowed again. If
// 410:     # the `:clear_actions` option is give and true, any actions queued on the
// 411:     # Agent that were being held while it was failed will be discarded,
// 412:     # otherwise those held actions will proceed. The `new_value` must pass the
// 413:     # validator if any, or `restart` will raise an exception and the Agent will
// 414:     # remain failed with its old {#value} and {#error}. Observers, if any, will
// 415:     # not be notified of the new state.
// 416:     #
// 417:     # @param [Object] new_value the new value for the Agent once restarted
// 418:     # @param [Hash] opts the configuration options
// 419:     # @option opts [Symbol] :clear_actions true if all enqueued but unprocessed
// 420:     #   actions should be discarded on restart, else false (default: false)
// 421:     # @return [Boolean] true
// 422:     #
// 423:     # @raise [Concurrent:AgentError] when not failed
// 424:     def restart(new_value, opts = {})
// 425:       clear_actions = opts.fetch(:clear_actions, false)
// 426:       synchronize do
// 427:         raise Error.new('agent is not failed') unless failed?
// 428:         raise ValidationError unless ns_validate(new_value)
// 429:         @current.value = new_value
// 430:         @error.value   = nil
// 431:         @queue.clear if clear_actions
// 432:         ns_post_next_job unless @queue.empty?
// 433:       end
// 434:       true
// 435:     end
// 436:
// 437:     class << self
// 438:
// 439:       # Blocks the current thread (indefinitely!) until all actions dispatched
// 440:       # thus far to all the given Agents, from this thread or nested by the
// 441:       # given Agents, have occurred. Will block when any of the agents are
// 442:       # failed. Will never return if a failed Agent is restart with
// 443:       # `:clear_actions` true.
// 444:       #
// 445:       # @param [Array<Concurrent::Agent>] agents the Agents on which to wait
// 446:       # @return [Boolean] true
// 447:       #
// 448:       # @!macro agent_await_warning
// 449:       def await(*agents)
// 450:         agents.each { |agent| agent.await }
// 451:         true
// 452:       end
// 453:
// 454:       # Blocks the current thread until all actions dispatched thus far to all
// 455:       # the given Agents, from this thread or nested by the given Agents, have
// 456:       # occurred, or the timeout (in seconds) has elapsed.
// 457:       #
// 458:       # @param [Float] timeout the maximum number of seconds to wait
// 459:       # @param [Array<Concurrent::Agent>] agents the Agents on which to wait
// 460:       # @return [Boolean] true if all actions complete before timeout else false
// 461:       #
// 462:       # @!macro agent_await_warning
// 463:       def await_for(timeout, *agents)
// 464:         end_at = Concurrent.monotonic_time + timeout.to_f
// 465:         ok     = agents.length.times do |i|
// 466:           break false if (delay = end_at - Concurrent.monotonic_time) < 0
// 467:           break false unless agents[i].await_for(delay)
// 468:         end
// 469:         !!ok
// 470:       end
// 471:
// 472:       # Blocks the current thread until all actions dispatched thus far to all
// 473:       # the given Agents, from this thread or nested by the given Agents, have
// 474:       # occurred, or the timeout (in seconds) has elapsed.
// 475:       #
// 476:       # @param [Float] timeout the maximum number of seconds to wait
// 477:       # @param [Array<Concurrent::Agent>] agents the Agents on which to wait
// 478:       # @return [Boolean] true if all actions complete before timeout
// 479:       #
// 480:       # @raise [Concurrent::TimeoutError] when timeout is reached
// 481:       # @!macro agent_await_warning
// 482:       def await_for!(timeout, *agents)
// 483:         raise Concurrent::TimeoutError unless await_for(timeout, *agents)
// 484:         true
// 485:       end
// 486:     end
// 487:
// 488:     private
// 489:
// 490:     def ns_initialize(initial, opts)
// 491:       @error_mode    = opts[:error_mode]
// 492:       @error_handler = opts[:error_handler]
// 493:
// 494:       if @error_mode && !ERROR_MODES.include?(@error_mode)
// 495:         raise ArgumentError.new('unrecognized error mode')
// 496:       elsif @error_mode.nil?
// 497:         @error_mode = @error_handler ? :continue : :fail
// 498:       end
// 499:
// 500:       @error_handler ||= DEFAULT_ERROR_HANDLER
// 501:       @validator     = opts.fetch(:validator, DEFAULT_VALIDATOR)
// 502:       @current       = Concurrent::AtomicReference.new(initial)
// 503:       @error         = Concurrent::AtomicReference.new(nil)
// 504:       @caller        = Concurrent::ThreadLocalVar.new(nil)
// 505:       @queue         = []
// 506:
// 507:       self.observers = Collection::CopyOnNotifyObserverSet.new
// 508:     end
// 509:
// 510:     def enqueue_action_job(action, args, executor)
// 511:       raise ArgumentError.new('no action given') unless action
// 512:       job = Job.new(action, args, executor, @caller.value || Thread.current.object_id)
// 513:       synchronize { ns_enqueue_job(job) }
// 514:     end
// 515:
// 516:     def enqueue_await_job(latch)
// 517:       synchronize do
// 518:         if (index = ns_find_last_job_for_thread)
// 519:           job = Job.new(AWAIT_ACTION, [latch], Concurrent.global_immediate_executor,
// 520:                         Thread.current.object_id)
// 521:           ns_enqueue_job(job, index+1)
// 522:         else
// 523:           latch.count_down
// 524:           true
// 525:         end
// 526:       end
// 527:     end
// 528:
// 529:     def ns_enqueue_job(job, index = nil)
// 530:       # a non-nil index means this is an await job
// 531:       return false if index.nil? && failed?
// 532:       index ||= @queue.length
// 533:       @queue.insert(index, job)
// 534:       # if this is the only job, post to executor
// 535:       ns_post_next_job if @queue.length == 1
// 536:       true
// 537:     end
// 538:
// 539:     def ns_post_next_job
// 540:       @queue.first.executor.post { execute_next_job }
// 541:     end
// 542:
// 543:     def execute_next_job
// 544:       job       = synchronize { @queue.first }
// 545:       old_value = @current.value
// 546:
// 547:       @caller.value = job.caller # for nested actions
// 548:       new_value     = job.action.call(old_value, *job.args)
// 549:       @caller.value = nil
// 550:
// 551:       return if new_value == AWAIT_FLAG
// 552:
// 553:       if ns_validate(new_value)
// 554:         @current.value = new_value
// 555:         observers.notify_observers(Time.now, old_value, new_value)
// 556:       else
// 557:         handle_error(ValidationError.new)
// 558:       end
// 559:     rescue => error
// 560:       handle_error(error)
// 561:     ensure
// 562:       synchronize do
// 563:         @queue.shift
// 564:         unless failed? || @queue.empty?
// 565:           ns_post_next_job
// 566:         end
// 567:       end
// 568:     end
// 569:
// 570:     def ns_validate(value)
// 571:       @validator.call(value)
// 572:     rescue
// 573:       false
// 574:     end
// 575:
// 576:     def handle_error(error)
// 577:       # stop new jobs from posting
// 578:       @error.value = error if @error_mode == :fail
// 579:       @error_handler.call(self, error)
// 580:     rescue
// 581:       # do nothing
// 582:     end
// 583:
// 584:     def ns_find_last_job_for_thread
// 585:       @queue.rindex { |job| job.caller == Thread.current.object_id }
// 586:     end
// 587:   end
// 588: end
