module concurrent

import brew_runtime
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/promises.rb`.
// The original source is retained below for source-parity auditing.
pub enum PromisesState {
	pending
	reserved
	fulfilled
	rejected
}

pub struct PromisesResult {
pub:
	fulfilled bool
	value     brew_runtime.Value
	reason    brew_runtime.Value
}

pub type PromisesTask = fn([]brew_runtime.Value) !brew_runtime.Value

pub type PromisesCallback = fn(PromisesResult, []brew_runtime.Value)

enum PromisesCallbackKind {
	resolution
	fulfillment
	rejection
	async_resolution
	async_fulfillment
	async_rejection
	propagate
	chain
	then
	rescue
	blocker
	flatten
	run
	scheduled_dependency
}

enum PromisesAggregateMode {
	none
	zip_futures
	zip_events
	zip_future_event
	any_resolved_future
	any_fulfilled_future
	any_event
}

struct PromisesCallbackEntry {
	kind          PromisesCallbackKind
	args          []brew_runtime.Value
	callback      PromisesCallback = promises_noop_callback
	target        &PromisesEventFuture = unsafe { nil }
	task          PromisesTask = promises_identity_task
	index         int
	levels        int
	as_event      bool
	executor_name string
	seconds       f64
}

@[heap]
struct PromisesJob {
	target &PromisesEventFuture
	task   PromisesTask @[required]
	args   []brew_runtime.Value
}

@[heap]
struct PromisesCallbackJob {
	callback PromisesCallback @[required]
	result   PromisesResult
	args     []brew_runtime.Value
}

@[heap]
pub struct PromisesEventFuture {
	mutex                 &sync.Mutex
	condition             &sync.Cond
	is_event              bool
	default_executor      ScheduledExecutor
	default_executor_name string
mut:
	state                 PromisesState
	value                 brew_runtime.Value
	reason                brew_runtime.Value
	callbacks             []PromisesCallbackEntry
	waiters               int
	touched               bool
	delayed               bool
	intended_time_seconds f64
	blockers              []&PromisesEventFuture
	aggregate_mode        PromisesAggregateMode
	aggregate_resolutions []?PromisesResult
	aggregate_remaining   int
	aggregate_resolved    bool
	hidden_wrapper        &PromisesEventFuture = unsafe { nil }
}

fn promises_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn promises_exception_value(message string) brew_runtime.Value {
	return brew_runtime.object_value('Exception', message)
}

fn promises_identity_task(args []brew_runtime.Value) !brew_runtime.Value {
	return if args.len > 0 { args[0] } else { promises_nil_value() }
}

fn promises_noop_callback(_ PromisesResult, _ []brew_runtime.Value) {}

fn promises_value_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr
}

fn promises_mutable_pointer(address voidptr) &PromisesEventFuture {
	return unsafe { &PromisesEventFuture(address) }
}

fn promises_executor(name string) ScheduledExecutor {
	return match name.trim_left(':') {
		'fast' { global_fast_executor().adapter }
		'immediate' { global_immediate_executor().adapter }
		else { global_io_executor().adapter }
	}
}

fn promises_new_event_future(is_event bool, executor_name string) &PromisesEventFuture {
	mutex := sync.new_mutex()
	return &PromisesEventFuture{
		mutex: mutex
		condition: sync.new_cond(mutex)
		is_event: is_event
		default_executor: promises_executor(executor_name)
		default_executor_name: executor_name
		state: .pending
		value: promises_nil_value()
		reason: promises_nil_value()
	}
}

pub fn promises_resolvable_event_on(executor_name string) &PromisesEventFuture {
	return promises_new_event_future(true, executor_name)
}

pub fn promises_resolvable_event() &PromisesEventFuture {
	return promises_resolvable_event_on('io')
}

pub fn promises_resolvable_future_on(executor_name string) &PromisesEventFuture {
	return promises_new_event_future(false, executor_name)
}

pub fn promises_resolvable_future() &PromisesEventFuture {
	return promises_resolvable_future_on('io')
}

pub fn promises_resolved_future(fulfilled bool, value brew_runtime.Value, reason brew_runtime.Value,
	executor_name string) &PromisesEventFuture {
	mut future := promises_resolvable_future_on(executor_name)
	if fulfilled {
		future.fulfill(value, true, false) or { panic(err) }
	} else {
		future.reject(reason, true, false) or { panic(err) }
	}
	return future
}

pub fn promises_fulfilled_future(value brew_runtime.Value) &PromisesEventFuture {
	return promises_resolved_future(true, value, promises_nil_value(), 'io')
}

pub fn promises_rejected_future(reason brew_runtime.Value) &PromisesEventFuture {
	return promises_resolved_future(false, promises_nil_value(), reason, 'io')
}

pub fn promises_resolved_event_on(executor_name string) &PromisesEventFuture {
	mut event := promises_resolvable_event_on(executor_name)
	event.resolve_event(true, false) or { panic(err) }
	return event
}

pub fn promises_resolved_event() &PromisesEventFuture {
	return promises_resolved_event_on('io')
}

fn promises_job_execute(args []brew_runtime.Value) {
	if args.len == 0 {
		return
	}
	mut job := unsafe { &PromisesJob(voidptr(args[0].int_data)) }
	value := job.task(job.args) or {
		mut target := job.target
		target.reject(promises_exception_value(err.msg()), false, false) or {}
		return
	}
	mut target := job.target
	target.fulfill(value, false, false) or {}
}

fn promises_callback_execute(args []brew_runtime.Value) {
	if args.len == 0 {
		return
	}
	job := unsafe { &PromisesCallbackJob(voidptr(args[0].int_data)) }
	job.callback(job.result, job.args)
}

fn promises_post_callback(executor ScheduledExecutor, callback PromisesCallback,
	result PromisesResult, args []brew_runtime.Value) {
	job := &PromisesCallbackJob{
		callback: callback
		result: result
		args: args.clone()
	}
	executor.post(promises_callback_execute, [
		brew_runtime.int_value(i64(voidptr(job))),
	])
}

fn promises_post_task(target &PromisesEventFuture, executor ScheduledExecutor, task PromisesTask,
	args []brew_runtime.Value) {
	job := &PromisesJob{
		target: target
		task: task
		args: args.clone()
	}
	executor.post(promises_job_execute, [brew_runtime.int_value(i64(voidptr(job)))])
}

pub fn promises_future_on(executor_name string, task PromisesTask, args []brew_runtime.Value) &PromisesEventFuture {
	mut future := promises_resolvable_future_on(executor_name)
	promises_post_task(future, future.default_executor, task, args)
	return future
}

pub fn promises_future(task PromisesTask, args []brew_runtime.Value) &PromisesEventFuture {
	return promises_future_on('io', task, args)
}

pub fn (mut future PromisesEventFuture) state_symbol() string {
	future.mutex.lock()
	state := future.state
	future.mutex.unlock()
	if future.is_event && state in [.fulfilled, .rejected] {
		return 'resolved'
	}
	return state.str()
}

pub fn (mut future PromisesEventFuture) pending() bool {
	future.mutex.lock()
	state := future.state
	future.mutex.unlock()
	return state in [.pending, .reserved]
}

pub fn (mut future PromisesEventFuture) resolved() bool {
	return !future.pending()
}

pub fn (mut future PromisesEventFuture) fulfilled() bool {
	future.mutex.lock()
	state := future.state
	future.mutex.unlock()
	return state == .fulfilled
}

pub fn (mut future PromisesEventFuture) rejected() bool {
	future.mutex.lock()
	state := future.state
	future.mutex.unlock()
	return state == .rejected
}

pub fn (mut future PromisesEventFuture) result_now() ?PromisesResult {
	future.mutex.lock()
	defer {
		future.mutex.unlock()
	}
	if future.state in [.pending, .reserved] {
		return none
	}
	return PromisesResult{
		fulfilled: future.state == .fulfilled
		value: future.value
		reason: future.reason
	}
}

fn (mut future PromisesEventFuture) reject_reassignment(raise_on_reassign bool) !bool {
	if raise_on_reassign {
		message := if future.is_event {
			'Concurrent::MultipleAssignmentError: Event can be resolved only once'
		} else {
			'Concurrent::MultipleAssignmentError: Future can be resolved only once'
		}
		return error(message)
	}
	return false
}

fn (mut future PromisesEventFuture) resolve_result(result PromisesResult, raise_on_reassign bool,
	reserved bool) !bool {
	future.mutex.lock()
	expected := if reserved { PromisesState.reserved } else { PromisesState.pending }
	if future.state != expected {
		future.mutex.unlock()
		return future.reject_reassignment(raise_on_reassign)
	}
	future.state = if future.is_event || result.fulfilled { .fulfilled } else { .rejected }
	future.value = if future.is_event { promises_nil_value() } else { result.value }
	future.reason = if future.is_event { promises_nil_value() } else { result.reason }
	callbacks := future.callbacks.clone()
	future.callbacks.clear()
	future.condition.broadcast()
	future.mutex.unlock()
	actual := PromisesResult{
		fulfilled: future.state == .fulfilled
		value: future.value
		reason: future.reason
	}
	for index := callbacks.len - 1; index >= 0; index-- {
		future.call_callback(callbacks[index], actual)
	}
	return true
}

pub fn (mut future PromisesEventFuture) resolve_event(raise_on_reassign bool, reserved bool) !bool {
	return future.resolve_result(PromisesResult{
		fulfilled: true
		value: promises_nil_value()
		reason: promises_nil_value()
	}, raise_on_reassign, reserved)
}

pub fn (mut future PromisesEventFuture) resolve(fulfilled bool, value brew_runtime.Value,
	reason brew_runtime.Value, raise_on_reassign bool, reserved bool) !bool {
	return future.resolve_result(PromisesResult{
		fulfilled: fulfilled
		value: value
		reason: reason
	}, raise_on_reassign, reserved)
}

pub fn (mut future PromisesEventFuture) fulfill(value brew_runtime.Value, raise_on_reassign bool,
	reserved bool) !bool {
	return future.resolve(true, value, promises_nil_value(), raise_on_reassign, reserved)
}

pub fn (mut future PromisesEventFuture) reject(reason brew_runtime.Value, raise_on_reassign bool,
	reserved bool) !bool {
	return future.resolve(false, promises_nil_value(), reason, raise_on_reassign, reserved)
}

pub fn (mut future PromisesEventFuture) reserve() bool {
	future.mutex.lock()
	defer {
		future.mutex.unlock()
	}
	if future.state != .pending {
		return false
	}
	future.state = .reserved
	return true
}

fn (mut future PromisesEventFuture) add_callback_entry(callback PromisesCallbackEntry) {
	future.mutex.lock()
	if future.state in [.pending, .reserved] {
		future.callbacks << callback
		future.mutex.unlock()
		return
	}
	result := PromisesResult{
		fulfilled: future.state == .fulfilled
		value: future.value
		reason: future.reason
	}
	future.mutex.unlock()
	future.call_callback(callback, result)
}

fn (mut future PromisesEventFuture) call_callback(callback PromisesCallbackEntry,
	result PromisesResult) {
	match callback.kind {
		.resolution { callback.callback(result, callback.args) }
		.fulfillment {
			if result.fulfilled {
				callback.callback(result, callback.args)
			}
		}
		.rejection {
			if !result.fulfilled {
				callback.callback(result, callback.args)
			}
		}
		.async_resolution {
			promises_post_callback(promises_executor(callback.executor_name), callback.callback, result, callback.args)
		}
		.async_fulfillment {
			if result.fulfilled {
				promises_post_callback(promises_executor(callback.executor_name), callback.callback, result, callback.args)
			}
		}
		.async_rejection {
			if !result.fulfilled {
				promises_post_callback(promises_executor(callback.executor_name), callback.callback, result, callback.args)
			}
		}
		.propagate {
			mut target := callback.target
			target.resolve_result(result, false, false) or {}
		}
		.chain, .then, .rescue {
			mut target := callback.target
			should_run := callback.kind == .chain || (callback.kind == .then && result.fulfilled) || (callback.kind == .rescue && !result.fulfilled)
			if should_run {
				mut call_args := []brew_runtime.Value{}
				if callback.kind == .chain {
					if !future.is_event {
						call_args << brew_runtime.bool_value(result.fulfilled)
						call_args << result.value
						call_args << result.reason
					}
				} else if callback.kind == .then {
					call_args << result.value
				} else {
					call_args << result.reason
				}
				call_args << callback.args
				promises_post_task(target, target.default_executor, callback.task, call_args)
			} else {
				target.resolve_result(result, false, false) or {}
			}
		}
		.blocker {
			mut target := callback.target
			target.receive_blocker(result, callback.index)
		}
		.flatten {
			promises_flatten_resolution(callback.target, result, callback.levels, callback.as_event)
		}
		.run {
			promises_flatten_resolution(callback.target, result, -1, false)
		}
		.scheduled_dependency {
			mut event := promises_schedule_event_on(callback.executor_name, callback.seconds)
			event.chain_resolvable(callback.target)
		}
	}
}

pub fn (mut future PromisesEventFuture) on_resolution_bang(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .resolution
		args: args.clone()
		callback: callback
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_resolution_using(executor_name string,
	callback PromisesCallback, args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .async_resolution
		args: args.clone()
		callback: callback
		executor_name: executor_name
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_resolution(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.on_resolution_using(future.default_executor_name, callback, args)
}

pub fn (mut future PromisesEventFuture) on_fulfillment_bang(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .fulfillment
		args: args.clone()
		callback: callback
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_fulfillment_using(executor_name string,
	callback PromisesCallback, args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .async_fulfillment
		args: args.clone()
		callback: callback
		executor_name: executor_name
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_fulfillment(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.on_fulfillment_using(future.default_executor_name, callback, args)
}

pub fn (mut future PromisesEventFuture) on_rejection_bang(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .rejection
		args: args.clone()
		callback: callback
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_rejection_using(executor_name string,
	callback PromisesCallback, args []brew_runtime.Value) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .async_rejection
		args: args.clone()
		callback: callback
		executor_name: executor_name
	})
	return &future
}

pub fn (mut future PromisesEventFuture) on_rejection(callback PromisesCallback,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.on_rejection_using(future.default_executor_name, callback, args)
}

pub fn (mut future PromisesEventFuture) touch() &PromisesEventFuture {
	future.mutex.lock()
	if future.touched {
		future.mutex.unlock()
		return &future
	}
	future.touched = true
	is_delayed := future.delayed
	blockers := future.blockers.clone()
	future.mutex.unlock()
	if is_delayed {
		future.resolve_event(false, false) or {}
	}
	for blocker in blockers {
		mut dependency := promises_mutable_pointer(voidptr(blocker))
		dependency.touch()
	}
	return &future
}

pub fn (mut future PromisesEventFuture) was_touched() bool {
	future.mutex.lock()
	touched := future.touched
	future.mutex.unlock()
	return touched
}

pub fn (mut future PromisesEventFuture) wait(timeout ?time.Duration) bool {
	if future.resolved() {
		return true
	}
	future.touch()
	future.mutex.lock()
	defer {
		future.mutex.unlock()
	}
	if future.state in [.fulfilled, .rejected] {
		return true
	}
	future.waiters++
	defer {
		future.waiters--
	}
	if duration := timeout {
		if duration <= 0 {
			return false
		}
		deadline := time.sys_mono_now() + u64(duration)
		for future.state in [.pending, .reserved] {
			now := time.sys_mono_now()
			if now >= deadline {
				return false
			}
			remaining := deadline - now
			sleep_for := if remaining < u64(time.millisecond) {
				time.Duration(remaining)
			} else {
				time.millisecond
			}
			future.mutex.unlock()
			time.sleep(sleep_for)
			future.mutex.lock()
		}
		return true
	}
	for future.state in [.pending, .reserved] {
		future.condition.wait()
	}
	return true
}

pub fn (mut future PromisesEventFuture) value(timeout ?time.Duration,
	timeout_value brew_runtime.Value) brew_runtime.Value {
	if !future.wait(timeout) {
		return timeout_value
	}
	future.mutex.lock()
	value := if future.state == .fulfilled { future.value } else { promises_nil_value() }
	future.mutex.unlock()
	return value
}

pub fn (mut future PromisesEventFuture) reason(timeout ?time.Duration,
	timeout_value brew_runtime.Value) brew_runtime.Value {
	if !future.wait(timeout) {
		return timeout_value
	}
	future.mutex.lock()
	reason := if future.state == .rejected { future.reason } else { promises_nil_value() }
	future.mutex.unlock()
	return reason
}

pub fn (mut future PromisesEventFuture) result(timeout ?time.Duration) ?PromisesResult {
	if !future.wait(timeout) {
		return none
	}
	return future.result_now()
}

pub fn (mut future PromisesEventFuture) value_or_error(timeout ?time.Duration) !brew_runtime.Value {
	if !future.wait(timeout) {
		return promises_nil_value()
	}
	result := future.result_now() or { return promises_nil_value() }
	if !result.fulfilled {
		return error(result.reason.repr)
	}
	return result.value
}

pub fn (mut future PromisesEventFuture) chain_on(executor_name string, task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	target := promises_resolvable_future_on(executor_name)
	mut blockers := []&PromisesEventFuture{}
	blockers << unsafe { &future }
	unsafe { target.blockers = blockers }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .chain
		args: args.clone()
		target: target
		task: task
	})
	return target
}

pub fn (mut future PromisesEventFuture) chain(task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.chain_on(future.default_executor_name, task, args)
}

pub fn (mut future PromisesEventFuture) then_on(executor_name string, task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	target := promises_resolvable_future_on(executor_name)
	mut blockers := []&PromisesEventFuture{}
	blockers << unsafe { &future }
	unsafe { target.blockers = blockers }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .then
		args: args.clone()
		target: target
		task: task
	})
	return target
}

pub fn (mut future PromisesEventFuture) then(task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.then_on(future.default_executor_name, task, args)
}

pub fn (mut future PromisesEventFuture) rescue_on(executor_name string, task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	target := promises_resolvable_future_on(executor_name)
	mut blockers := []&PromisesEventFuture{}
	blockers << unsafe { &future }
	unsafe { target.blockers = blockers }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .rescue
		args: args.clone()
		target: target
		task: task
	})
	return target
}

pub fn (mut future PromisesEventFuture) rescue(task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	return future.rescue_on(future.default_executor_name, task, args)
}

pub fn (mut future PromisesEventFuture) chain_resolvable(target &PromisesEventFuture) &PromisesEventFuture {
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .propagate
		target: target
	})
	return &future
}

pub fn (mut future PromisesEventFuture) to_event() &PromisesEventFuture {
	if future.is_event {
		return &future
	}
	target := promises_resolvable_event()
	future.chain_resolvable(target)
	return target
}

pub fn (mut future PromisesEventFuture) to_future() &PromisesEventFuture {
	if !future.is_event {
		return &future
	}
	target := promises_resolvable_future()
	future.chain_resolvable(target)
	return target
}

pub fn (mut future PromisesEventFuture) with_default_executor(executor_name string) &PromisesEventFuture {
	mut target := promises_new_event_future(future.is_event, executor_name)
	target.blockers << unsafe { &future }
	future.chain_resolvable(target)
	return target
}

pub fn (mut future PromisesEventFuture) with_hidden_resolvable() &PromisesEventFuture {
	future.mutex.lock()
	if future.hidden_wrapper != unsafe { nil } {
		wrapper := future.hidden_wrapper
		future.mutex.unlock()
		return wrapper
	}
	mut target := promises_new_event_future(future.is_event, future.default_executor_name)
	target.blockers << unsafe { &future }
	future.hidden_wrapper = target
	future.mutex.unlock()
	future.chain_resolvable(target)
	return target
}

pub fn (mut future PromisesEventFuture) string() string {
	state := future.state_symbol()
	if !future.is_event && future.resolved() {
		result := future.result_now() or { return '#<Concurrent::Promises::Future ${state}>' }
		shown := if result.fulfilled { result.value.repr } else { result.reason.repr }
		return '#<Concurrent::Promises::Future ${state} with ${shown}>'
	}
	kind := if future.is_event { 'Event' } else { 'Future' }
	return '#<Concurrent::Promises::${kind} ${state}>'
}

pub fn (mut future PromisesEventFuture) callbacks_count() int {
	future.mutex.lock()
	count := future.callbacks.len
	future.mutex.unlock()
	return count
}

pub fn (mut future PromisesEventFuture) waiting_threads() int {
	future.mutex.lock()
	count := future.waiters
	future.mutex.unlock()
	return count
}

pub fn promises_delay_event_on(executor_name string) &PromisesEventFuture {
	mut event := promises_resolvable_event_on(executor_name)
	event.delayed = true
	return event
}

pub fn promises_delay_event() &PromisesEventFuture {
	return promises_delay_event_on('io')
}

pub fn promises_delay_future_on(executor_name string, task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	mut event := promises_delay_event_on(executor_name)
	return event.chain_on(executor_name, task, args)
}

fn promises_schedule_resolve(args []brew_runtime.Value) {
	if args.len < 2 {
		return
	}
	duration := time.Duration(args[1].float_data * f64(time.second))
	if duration > 0 {
		time.sleep(duration)
	}
	mut event := unsafe { &PromisesEventFuture(voidptr(args[0].int_data)) }
	event.resolve_event(false, false) or {}
}

pub fn promises_schedule_event_on(executor_name string, intended_seconds f64) &PromisesEventFuture {
	mut event := promises_resolvable_event_on(executor_name)
	event.intended_time_seconds = intended_seconds
	spawn promises_schedule_resolve([
		brew_runtime.int_value(i64(voidptr(event))),
		brew_runtime.float_value(if intended_seconds > 0 { intended_seconds } else { 0 }),
	])
	return event
}

pub fn promises_schedule_future_on(executor_name string, intended_seconds f64, task PromisesTask,
	args []brew_runtime.Value) &PromisesEventFuture {
	mut event := promises_schedule_event_on(executor_name, intended_seconds)
	return event.chain_on(executor_name, task, args)
}

fn promises_new_aggregate(blockers []&PromisesEventFuture, executor_name string,
	mode PromisesAggregateMode) &PromisesEventFuture {
	is_event := mode in [.zip_events, .any_event]
	mut target := promises_new_event_future(is_event, executor_name)
	target.blockers = blockers.clone()
	target.aggregate_mode = mode
	target.aggregate_resolutions = []?PromisesResult{len: blockers.len}
	target.aggregate_remaining = blockers.len
	if blockers.len == 0 {
		match mode {
			.zip_futures {
				target.fulfill(brew_runtime.array_value([]), false, false) or {}
			}
			.zip_events { target.resolve_event(false, false) or {} }
			else {}
		}
		return target
	}
	for index, blocker in blockers {
		mut source := promises_mutable_pointer(voidptr(blocker))
		source.add_callback_entry(PromisesCallbackEntry{
			kind: .blocker
			target: target
			index: index
		})
	}
	return target
}

fn (mut target PromisesEventFuture) receive_blocker(result PromisesResult, index int) {
	target.mutex.lock()
	if target.aggregate_resolved || target.state !in [.pending, .reserved] {
		target.mutex.unlock()
		return
	}
	if index >= 0 && index < target.aggregate_resolutions.len && target.aggregate_resolutions[index] == none {
		target.aggregate_resolutions[index] = result
		target.aggregate_remaining--
	}
	mode := target.aggregate_mode
	remaining := target.aggregate_remaining
	mut should_resolve := false
	mut resolution := PromisesResult{
		fulfilled: true
		value: promises_nil_value()
		reason: promises_nil_value()
	}
	match mode {
		.any_event, .any_resolved_future {
			should_resolve = true
			resolution = result
		}
		.any_fulfilled_future {
			if result.fulfilled || remaining == 0 {
				should_resolve = true
				resolution = result
			}
		}
		.zip_events {
			if remaining == 0 {
				should_resolve = true
			}
		}
		.zip_future_event {
			if remaining == 0 {
				for item in target.aggregate_resolutions {
					if state := item {
						resolution = state
						break
					}
				}
				should_resolve = true
			}
		}
		.zip_futures {
			if remaining == 0 {
				mut values := []brew_runtime.Value{cap: target.aggregate_resolutions.len}
				mut reasons := []brew_runtime.Value{cap: target.aggregate_resolutions.len}
				mut all_fulfilled := true
				for item in target.aggregate_resolutions {
					state := item or { continue }
					all_fulfilled = all_fulfilled && state.fulfilled
					values << state.value
					reasons << state.reason
				}
				resolution = PromisesResult{
					fulfilled: all_fulfilled
					value: brew_runtime.array_value(values)
					reason: if all_fulfilled {
						promises_nil_value()} else {
						brew_runtime.array_value(reasons)}
				}
				should_resolve = true
			}
		}
		else {}
	}
	if should_resolve {
		target.aggregate_resolved = true
	}
	target.mutex.unlock()
	if should_resolve {
		target.resolve_result(resolution, false, false) or {}
	}
}

pub fn promises_zip_futures_on(executor_name string,
	blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_new_aggregate(blockers, executor_name, .zip_futures)
}

pub fn promises_zip_futures(blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_zip_futures_on('io', blockers)
}

pub fn promises_zip_events_on(executor_name string,
	blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_new_aggregate(blockers, executor_name, .zip_events)
}

pub fn promises_zip_events(blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_zip_events_on('io', blockers)
}

pub fn promises_any_resolved_future_on(executor_name string,
	blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_new_aggregate(blockers, executor_name, .any_resolved_future)
}

pub fn promises_any_resolved_future(blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_any_resolved_future_on('io', blockers)
}

pub fn promises_any_fulfilled_future_on(executor_name string,
	blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_new_aggregate(blockers, executor_name, .any_fulfilled_future)
}

pub fn promises_any_fulfilled_future(blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_any_fulfilled_future_on('io', blockers)
}

pub fn promises_any_event_on(executor_name string,
	blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_new_aggregate(blockers, executor_name, .any_event)
}

pub fn promises_any_event(blockers []&PromisesEventFuture) &PromisesEventFuture {
	return promises_any_event_on('io', blockers)
}

pub fn (mut future PromisesEventFuture) zip(other &PromisesEventFuture) &PromisesEventFuture {
	mut blockers := []&PromisesEventFuture{}
	blockers << unsafe { &future }
	blockers << other
	if future.is_event && other.is_event {
		return promises_zip_events_on(future.default_executor_name, blockers)
	}
	if !future.is_event && other.is_event {
		return promises_new_aggregate(blockers, future.default_executor_name, .zip_future_event)
	}
	if future.is_event && !other.is_event {
		return promises_new_aggregate([other, blockers[0]], future.default_executor_name, .zip_future_event)
	}
	return promises_zip_futures_on(future.default_executor_name, blockers)
}

pub fn (mut future PromisesEventFuture) any(other &PromisesEventFuture) &PromisesEventFuture {
	mut blockers := []&PromisesEventFuture{}
	blockers << unsafe { &future }
	blockers << other
	if future.is_event {
		return promises_any_event_on(future.default_executor_name, blockers)
	}
	return promises_any_resolved_future_on(future.default_executor_name, blockers)
}

pub fn (mut future PromisesEventFuture) delay() &PromisesEventFuture {
	mut event := promises_delay_event_on(future.default_executor_name)
	return future.zip(event)
}

pub fn (mut future PromisesEventFuture) schedule(intended_seconds f64) &PromisesEventFuture {
	mut target := promises_new_event_future(future.is_event, future.default_executor_name)
	target.blockers << unsafe { &future }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .scheduled_dependency
		target: target
		executor_name: future.default_executor_name
		seconds: intended_seconds
	})
	return target
}

fn promises_flatten_resolution(target &PromisesEventFuture, result PromisesResult, levels int,
	as_event bool) {
	mut output := promises_mutable_pointer(voidptr(target))
	if !result.fulfilled {
		if as_event {
			output.resolve_event(false, false) or {}
		} else {
			output.resolve_result(result, false, false) or {}
		}
		return
	}
	if levels != 0 && promises_is_boundary_future(result.value) {
		mut nested := promises_boundary_receiver_value(result.value)
		nested.add_callback_entry(PromisesCallbackEntry{
			kind: .flatten
			target: output
			levels: if levels < 0 { -1 } else { levels - 1 }
			as_event: as_event
		})
		nested.touch()
		return
	}
	if levels > 0 && !as_event {
		output.reject(promises_exception_value('TypeError: returned value ${result.value.repr} is not a Future'), false, false) or {}
		return
	}
	if as_event {
		output.resolve_event(false, false) or {}
	} else {
		output.resolve_result(result, false, false) or {}
	}
}

pub fn (mut future PromisesEventFuture) flat_future(levels int) &PromisesEventFuture {
	if levels < 1 {
		panic('ArgumentError: levels has to be higher than 0')
	}
	mut target := promises_resolvable_future_on(future.default_executor_name)
	target.blockers << unsafe { &future }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .flatten
		target: target
		levels: levels
	})
	return target
}

pub fn (mut future PromisesEventFuture) flat_event() &PromisesEventFuture {
	mut target := promises_resolvable_event_on(future.default_executor_name)
	target.blockers << unsafe { &future }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .flatten
		target: target
		levels: 1
		as_event: true
	})
	return target
}

pub fn (mut future PromisesEventFuture) run() &PromisesEventFuture {
	mut target := promises_resolvable_future_on(future.default_executor_name)
	target.blockers << unsafe { &future }
	future.add_callback_entry(PromisesCallbackEntry{
		kind: .run
		target: target
	})
	return target
}

fn promises_boundary_value(future &PromisesEventFuture, type_name string) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: type_name
		repr: '#<${type_name}>'
		int_data: i64(voidptr(future))
		attributes: {
			'promises_future_address': u64(voidptr(future)).str()
		}
	}
}

fn promises_public_boundary_value(future &PromisesEventFuture) brew_runtime.Value {
	return promises_boundary_value(future, if future.is_event {
		'Concurrent::Promises::Event'
	} else {
		'Concurrent::Promises::Future'
	})
}

fn promises_resolvable_boundary_value(future &PromisesEventFuture) brew_runtime.Value {
	return promises_boundary_value(future, if future.is_event {
		'Concurrent::Promises::ResolvableEvent'
	} else {
		'Concurrent::Promises::ResolvableFuture'
	})
}

fn promises_is_boundary_future(value brew_runtime.Value) bool {
	return 'promises_future_address' in value.attributes
}

fn promises_boundary_receiver_value(value brew_runtime.Value) &PromisesEventFuture {
	address := (value.attribute('promises_future_address') or {
		panic('${value.type_name} has no translated Promises event/future state')
	}).u64()
	return unsafe { &PromisesEventFuture(voidptr(address)) }
}

fn promises_boundary_receiver(args []brew_runtime.Value) &PromisesEventFuture {
	if args.len == 0 {
		panic('Promises method requires a receiver')
	}
	return promises_boundary_receiver_value(args[0])
}

fn promises_result_boundary_value(result PromisesResult, type_name string) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: type_name
		repr: result.fulfilled.str()
		map_data: {
			'fulfilled': brew_runtime.bool_value(result.fulfilled)
			'value':     result.value
			'reason':    result.reason
		}
	}
}

fn promises_result_boundary_receiver(value brew_runtime.Value) PromisesResult {
	if 'fulfilled' in value.map_data {
		return PromisesResult{
			fulfilled: value.map_data['fulfilled'].as_bool() or { false }
			value: value.map_data['value']
			reason: value.map_data['reason']
		}
	}
	return match value.type_name {
		'Concurrent::Promises::InternalStates::Pending', 'Concurrent::Promises::InternalStates::Reserved' {
			PromisesResult{
				value: promises_nil_value()
				reason: promises_nil_value()
			}
		}
		else {
			PromisesResult{
				fulfilled: value.type_name.contains('Fulfilled')
				value: promises_nil_value()
				reason: promises_nil_value()
			}
		}
	}
}

fn promises_pending_boundary(reserved bool) brew_runtime.Value {
	name := if reserved { 'Reserved' } else { 'Pending' }
	return brew_runtime.object_value('Concurrent::Promises::InternalStates::${name}', ':${name.to_lower()}')
}

fn promises_result_type(result PromisesResult) string {
	return if result.fulfilled {
		'Concurrent::Promises::InternalStates::Fulfilled'
	} else {
		'Concurrent::Promises::InternalStates::Rejected'
	}
}

fn promises_future_state_boundary(mut future PromisesEventFuture) brew_runtime.Value {
	future.mutex.lock()
	state := future.state
	result := PromisesResult{
		fulfilled: state == .fulfilled
		value: future.value
		reason: future.reason
	}
	future.mutex.unlock()
	return match state {
		.pending { promises_pending_boundary(false) }
		.reserved { promises_pending_boundary(true) }
		else { promises_result_boundary_value(result, promises_result_type(result)) }
	}
}

fn promises_boundary_executor(args []brew_runtime.Value, index int) string {
	if index >= args.len {
		return 'io'
	}
	name := args[index].as_string().trim_left(':')
	return if name.len > 0 { name } else { 'io' }
}

fn promises_boundary_timeout(args []brew_runtime.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	return time.Duration((args[index].as_float() or { panic(err) }) * f64(time.second))
}

fn promises_boundary_blockers(args []brew_runtime.Value, start int) []&PromisesEventFuture {
	mut values := []brew_runtime.Value{}
	if start < args.len && args.len == start + 1 && args[start].type_name == 'Array' {
		values = args[start].as_array() or { panic(err) }
	} else if start < args.len {
		values = args[start..].clone()
	}
	mut blockers := []&PromisesEventFuture{cap: values.len}
	for value in values {
		blockers << promises_boundary_receiver_value(value)
	}
	return blockers
}

fn promises_boundary_array(blockers []&PromisesEventFuture) brew_runtime.Value {
	mut values := []brew_runtime.Value{cap: blockers.len}
	for blocker in blockers {
		values << promises_public_boundary_value(blocker)
	}
	return brew_runtime.array_value(values)
}

fn promises_last_value_task(args []brew_runtime.Value) !brew_runtime.Value {
	return if args.len > 0 { args.last() } else { promises_nil_value() }
}

fn promises_boundary_task_args(args []brew_runtime.Value, start int) []brew_runtime.Value {
	return if start < args.len { args[start..].clone() } else { [] }
}

fn promises_result_array(result PromisesResult) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.bool_value(result.fulfilled),
		result.value,
		result.reason,
	])
}

fn promises_boundary_result(mut future PromisesEventFuture, timeout ?time.Duration) brew_runtime.Value {
	result := future.result(timeout) or { return promises_nil_value() }
	return promises_result_array(result)
}

fn promises_boundary_bool(value brew_runtime.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.as_bool() or { fallback } } else { fallback }
}

fn promises_boundary_float(value brew_runtime.Value) f64 {
	return value.as_float() or { panic(err) }
}

fn promises_internal_promise_value(future &PromisesEventFuture, class_name string) brew_runtime.Value {
	return promises_boundary_value(future, 'Concurrent::Promises::${class_name}')
}

fn promises_boundary_noop_callback(_ PromisesResult, _ []brew_runtime.Value) {}

fn promises_boundary_call(id int, args []brew_runtime.Value) brew_runtime.Value {
	match id {
		1 {
			return brew_runtime.object_value('Symbol', ':io')
		}
		2 {
			return promises_resolvable_boundary_value(promises_resolvable_event())
		}
		3 {
			return promises_resolvable_boundary_value(promises_resolvable_event_on(promises_boundary_executor(args, 0)))
		}
		4 {
			return promises_resolvable_boundary_value(promises_resolvable_future())
		}
		5 {
			return promises_resolvable_boundary_value(promises_resolvable_future_on(promises_boundary_executor(args, 0)))
		}
		6 {
			if args.len == 0 {
				panic('ArgumentError: no block given')
			}
			return promises_public_boundary_value(promises_future(promises_last_value_task, promises_boundary_task_args(args, 0)))
		}
		7 {
			if args.len < 2 {
				panic('ArgumentError: no block given')
			}
			return promises_public_boundary_value(promises_future_on(promises_boundary_executor(args, 0), promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		8 {
			if args.len < 3 {
				panic('ArgumentError: resolved_future requires fulfilled, value, and reason')
			}
			return promises_public_boundary_value(promises_resolved_future(promises_boundary_bool(args[0], false), args[1], args[2], promises_boundary_executor(args, 3)))
		}
		9 {
			if args.len == 0 {
				panic('ArgumentError: fulfilled_future requires a value')
			}
			return promises_public_boundary_value(promises_resolved_future(true, args[0], promises_nil_value(), promises_boundary_executor(args, 1)))
		}
		10 {
			if args.len == 0 {
				panic('ArgumentError: rejected_future requires a reason')
			}
			return promises_public_boundary_value(promises_resolved_future(false, promises_nil_value(), args[0], promises_boundary_executor(args, 1)))
		}
		11 {
			return promises_public_boundary_value(promises_resolved_event_on(promises_boundary_executor(args, 0)))
		}
		12 {
			if args.len == 0 || args[0].type_name == 'NilClass' {
				return promises_public_boundary_value(promises_resolved_event_on(promises_boundary_executor(args, 1)))
			}
			if promises_is_boundary_future(args[0]) {
				return args[0]
			}
			if args[0].type_name.ends_with('Exception') || args[0].type_name.ends_with('Error') || args[0].type_name == 'Exception' {
				return promises_public_boundary_value(promises_resolved_future(false, promises_nil_value(), args[0], promises_boundary_executor(args, 1)))
			}
			return promises_public_boundary_value(promises_resolved_future(true, args[0], promises_nil_value(), promises_boundary_executor(args, 1)))
		}
		13 {
			if args.len == 0 {
				return promises_public_boundary_value(promises_delay_event())
			}
			return promises_public_boundary_value(promises_delay_future_on('io', promises_last_value_task, promises_boundary_task_args(args, 0)))
		}
		14 {
			executor := promises_boundary_executor(args, 0)
			if args.len <= 1 {
				return promises_public_boundary_value(promises_delay_event_on(executor))
			}
			return promises_public_boundary_value(promises_delay_future_on(executor, promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		15 {
			if args.len == 0 {
				panic('ArgumentError: schedule requires intended_time')
			}
			if args.len == 1 {
				return promises_public_boundary_value(promises_schedule_event_on('io', promises_boundary_float(args[0])))
			}
			return promises_public_boundary_value(promises_schedule_future_on('io', promises_boundary_float(args[0]), promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		16 {
			if args.len < 2 {
				panic('ArgumentError: schedule_on requires executor and intended_time')
			}
			if args.len == 2 {
				return promises_public_boundary_value(promises_schedule_event_on(promises_boundary_executor(args, 0), promises_boundary_float(args[1])))
			}
			return promises_public_boundary_value(promises_schedule_future_on(promises_boundary_executor(args, 0), promises_boundary_float(args[1]), promises_last_value_task, promises_boundary_task_args(args, 2)))
		}
		17, 19 {
			return promises_public_boundary_value(promises_zip_futures(promises_boundary_blockers(args, 0)))
		}
		18 {
			return promises_public_boundary_value(promises_zip_futures_on(promises_boundary_executor(args, 0), promises_boundary_blockers(args, 1)))
		}
		20 {
			return promises_public_boundary_value(promises_zip_events(promises_boundary_blockers(args, 0)))
		}
		21 {
			return promises_public_boundary_value(promises_zip_events_on(promises_boundary_executor(args, 0), promises_boundary_blockers(args, 1)))
		}
		22, 23 {
			return promises_public_boundary_value(promises_any_resolved_future(promises_boundary_blockers(args, 0)))
		}
		24 {
			return promises_public_boundary_value(promises_any_resolved_future_on(promises_boundary_executor(args, 0), promises_boundary_blockers(args, 1)))
		}
		25 {
			return promises_public_boundary_value(promises_any_fulfilled_future(promises_boundary_blockers(args, 0)))
		}
		26 {
			return promises_public_boundary_value(promises_any_fulfilled_future_on(promises_boundary_executor(args, 0), promises_boundary_blockers(args, 1)))
		}
		27 {
			return promises_public_boundary_value(promises_any_event(promises_boundary_blockers(args, 0)))
		}
		28 {
			return promises_public_boundary_value(promises_any_event_on(promises_boundary_executor(args, 0), promises_boundary_blockers(args, 1)))
		}
		else {
			return promises_boundary_call_rest(id, args)
		}
	}
}

fn promises_boundary_assign_state(mut future PromisesEventFuture, state_value brew_runtime.Value) {
	future.mutex.lock()
	match state_value.type_name {
		'Concurrent::Promises::InternalStates::Pending' {
			future.state = .pending
		}
		'Concurrent::Promises::InternalStates::Reserved' {
			future.state = .reserved
		}
		else {
			result := promises_result_boundary_receiver(state_value)
			future.state = if result.fulfilled || future.is_event { .fulfilled } else { .rejected }
			future.value = result.value
			future.reason = result.reason
		}
	}
	future.mutex.unlock()
}

fn promises_boundary_symbol(name string) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${name}')
}

fn promises_boundary_apply(args []brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args.last() } else { promises_nil_value() }
}

fn promises_boundary_call_rest(id int, args []brew_runtime.Value) brew_runtime.Value {
	match id {
		29, 30, 36, 37, 38, 39 { panic('NotImplementedError') }
		31 {
			return brew_runtime.bool_value(false)
		}
		32 {
			return promises_boundary_symbol('pending')
		}
		33 {
			return brew_runtime.bool_value(true)
		}
		34 {
			return promises_boundary_symbol('resolved')
		}
		35 {
			result := promises_result_boundary_receiver(args[0])
			return promises_result_array(result)
		}
		40 {
			value := if args.len > 0 { args[0] } else { promises_nil_value() }
			return promises_result_boundary_value(PromisesResult{
				fulfilled: true
				value: value
				reason: promises_nil_value()
			}, 'Concurrent::Promises::InternalStates::Fulfilled')
		}
		41 {
			return brew_runtime.bool_value(true)
		}
		42, 46 {
			return promises_boundary_apply(args)
		}
		43 {
			return promises_result_boundary_receiver(args[0]).value
		}
		44 {
			return promises_nil_value()
		}
		45 {
			return promises_boundary_symbol('fulfilled')
		}
		47 {
			reason := if args.len > 0 { args[0] } else { promises_nil_value() }
			return promises_result_boundary_value(PromisesResult{
				value: promises_nil_value()
				reason: reason
			}, 'Concurrent::Promises::InternalStates::Rejected')
		}
		48, 54 {
			return brew_runtime.bool_value(false)
		}
		49 {
			return promises_nil_value()
		}
		50 {
			return promises_result_boundary_receiver(args[0]).reason
		}
		51, 55 {
			return promises_boundary_symbol('rejected')
		}
		52, 58 {
			return promises_boundary_apply(args)
		}
		53 {
			if args.len < 2 {
				panic('ArgumentError: PartiallyRejected requires value and reason')
			}
			return promises_result_boundary_value(PromisesResult{
				value: args[0]
				reason: args[1]
			}, 'Concurrent::Promises::InternalStates::PartiallyRejected')
		}
		56 {
			return promises_result_boundary_receiver(args[0]).value
		}
		57 {
			return promises_result_boundary_receiver(args[0]).reason
		}
		59 {
			return promises_boundary_symbol('resolved')
		}
		60 {
			mut future := promises_boundary_receiver(args)
			return promises_future_state_boundary(mut future)
		}
		61 {
			if args.len < 2 {
				panic('internal_state= requires a state')
			}
			mut future := promises_boundary_receiver(args)
			promises_boundary_assign_state(mut future, args[1])
			return args[1]
		}
		62 {
			if args.len < 3 {
				panic('compare_and_set_internal_state requires old and new state')
			}
			mut future := promises_boundary_receiver(args)
			current := promises_future_state_boundary(mut future)
			if current.type_name != args[1].type_name {
				return brew_runtime.bool_value(false)
			}
			promises_boundary_assign_state(mut future, args[2])
			return brew_runtime.bool_value(true)
		}
		63 {
			if args.len < 2 {
				panic('swap_internal_state requires a state')
			}
			mut future := promises_boundary_receiver(args)
			current := promises_future_state_boundary(mut future)
			promises_boundary_assign_state(mut future, args[1])
			return current
		}
		64 {
			if args.len < 2 {
				panic('update_internal_state requires an updated state')
			}
			mut future := promises_boundary_receiver(args)
			promises_boundary_assign_state(mut future, args.last())
			return args.last()
		}
		65 {
			return promises_public_boundary_value(promises_resolvable_future_on(promises_boundary_executor(args, 1)))
		}
		66 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_symbol(future.state_symbol())
		}
		67 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.pending())
		}
		68 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.resolved())
		}
		69 {
			mut future := promises_boundary_receiver(args)
			future.touch()
			return args[0]
		}
		70 {
			mut future := promises_boundary_receiver(args)
			if args.len < 2 || args[1].type_name == 'NilClass' {
				future.wait(none)
				return args[0]
			}
			return brew_runtime.bool_value(future.wait(promises_boundary_timeout(args, 1)))
		}
		71 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_symbol(future.default_executor_name)
		}
		72 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.chain(promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		73 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.chain_on(promises_boundary_executor(args, 1), promises_last_value_task, promises_boundary_task_args(args, 2)))
		}
		74, 75 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.string_value(future.string())
		}
		76, 77 {
			if args.len < 2 {
				panic('chain_resolvable requires a resolvable')
			}
			mut future := promises_boundary_receiver(args)
			future.chain_resolvable(promises_boundary_receiver_value(args[1]))
			return args[0]
		}
		78, 79, 80 {
			mut future := promises_boundary_receiver(args)
			if id == 79 {
				future.on_resolution_bang(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			} else if id == 80 {
				future.on_resolution_using(promises_boundary_executor(args, 1), promises_boundary_noop_callback, promises_boundary_task_args(args, 2))
			} else {
				future.on_resolution(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			}
			return args[0]
		}
		81 { panic('NotImplementedError') }
		82 {
			if args.len < 2 {
				panic('resolve_with requires a state')
			}
			mut future := promises_boundary_receiver(args)
			result := promises_result_boundary_receiver(args[1])
			raise_reassign := if args.len > 2 {
				promises_boundary_bool(args[2], true)
			} else {
				true
			}
			reserved := if args.len > 3 { promises_boundary_bool(args[3], false) } else { false }
			resolved := future.resolve_result(result, raise_reassign, reserved) or { panic(err) }
			return if resolved { args[0] } else { brew_runtime.bool_value(false) }
		}
		83 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_array(future.blockers)
		}
		84 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.array_value([]brew_runtime.Value{len: future.callbacks_count(), init: promises_boundary_symbol('callback')})
		}
		85 {
			return promises_internal_promise_value(promises_boundary_receiver(args), 'AbstractPromise')
		}
		86 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.was_touched())
		}
		87 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.int_value(future.waiting_threads())
		}
		88 {
			if args.len < 2 {
				panic('add_callback_notify_blocked requires a promise')
			}
			mut source := promises_boundary_receiver(args)
			target := promises_boundary_receiver_value(args[1])
			index := if args.len > 2 { int(args[2].as_int() or { 0 }) } else { 0 }
			source.add_callback_entry(PromisesCallbackEntry{
				kind: .blocker
				target: target
				index: index
			})
			return args[0]
		}
		89, 92, 94, 95, 96, 97 {
			return promises_nil_value()
		}
		90 {
			return args[0]
		}
		91 {
			return args[0]
		}
		93 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.wait(promises_boundary_timeout(args, 1)))
		}
		98 {
			if args.len >= 2 {
				mut target := promises_boundary_receiver_value(args[1])
				mut source := promises_boundary_receiver(args)
				if result := source.result_now() {
					target.receive_blocker(result, if args.len > 2 {
						int(args[2].int_data)
					} else {
						0
					})
				}
			}
			return promises_nil_value()
		}
		99 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.chain(promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		100, 101 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.zip(promises_boundary_receiver_value(args[1])))
		}
		102, 103 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.any(promises_boundary_receiver_value(args[1])))
		}
		104 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.delay())
		}
		105 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.schedule(promises_boundary_float(args[1])))
		}
		106 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.to_future())
		}
		107 {
			return args[0]
		}
		108 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.with_default_executor(promises_boundary_executor(args, 1)))
		}
		109 {
			raise_reassign := if args.len > 1 {
				promises_boundary_bool(args[1], true)
			} else {
				true
			}
			if raise_reassign {
				panic('Concurrent::MultipleAssignmentError: Event can be resolved only once')
			}
			return brew_runtime.bool_value(false)
		}
		110 {
			return promises_nil_value()
		}
		else {
			return promises_boundary_call_future_and_promises(id, args)
		}
	}
}

fn promises_boundary_resolution(value brew_runtime.Value) ?PromisesResult {
	if value.type_name == 'NilClass' {
		return none
	}
	items := value.as_array() or { panic('resolve_on_timeout must be an Array') }
	if items.len < 3 {
		panic('resolve_on_timeout must contain fulfilled, value, and reason')
	}
	return PromisesResult{
		fulfilled: promises_boundary_bool(items[0], false)
		value: items[1]
		reason: items[2]
	}
}

fn promises_resolve_timeout(mut future PromisesEventFuture, resolution_value brew_runtime.Value) bool {
	if resolution := promises_boundary_resolution(resolution_value) {
		return future.resolve_result(resolution, false, false) or { false }
	}
	return false
}

fn promises_boundary_call_future_and_promises(id int, args []brew_runtime.Value) brew_runtime.Value {
	match id {
		111 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.fulfilled())
		}
		112 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.rejected())
		}
		113 {
			mut future := promises_boundary_receiver(args)
			timeout_value := if args.len > 2 { args[2] } else { promises_nil_value() }
			return future.value(promises_boundary_timeout(args, 1), timeout_value)
		}
		114 {
			mut future := promises_boundary_receiver(args)
			timeout_value := if args.len > 2 { args[2] } else { promises_nil_value() }
			return future.reason(promises_boundary_timeout(args, 1), timeout_value)
		}
		115 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_result(mut future, promises_boundary_timeout(args, 1))
		}
		116 {
			mut future := promises_boundary_receiver(args)
			resolved := future.wait(promises_boundary_timeout(args, 1))
			if future.rejected() {
				panic(future.reason(none, promises_nil_value()).repr)
			}
			return if args.len > 1 { brew_runtime.bool_value(resolved) } else { args[0] }
		}
		117 {
			mut future := promises_boundary_receiver(args)
			timeout_value := if args.len > 2 { args[2] } else { promises_nil_value() }
			return future.value_or_error(promises_boundary_timeout(args, 1)) or {
				if !future.resolved() {
					return timeout_value
				}
				panic(err)
			}
		}
		118 {
			mut future := promises_boundary_receiver(args)
			if !future.rejected() {
				panic('Concurrent::Error: it is not rejected')
			}
			reason := future.reason(none, promises_nil_value())
			return if reason.type_name.ends_with('Exception') || reason.type_name == 'Exception' {
				reason
			} else {
				promises_exception_value(reason.repr)
			}
		}
		119 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.then(promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		120 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.then_on(promises_boundary_executor(args, 1), promises_last_value_task, promises_boundary_task_args(args, 2)))
		}
		121 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.rescue(promises_last_value_task, promises_boundary_task_args(args, 1)))
		}
		122 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.rescue_on(promises_boundary_executor(args, 1), promises_last_value_task, promises_boundary_task_args(args, 2)))
		}
		123, 124 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.zip(promises_boundary_receiver_value(args[1])))
		}
		125, 126 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.any(promises_boundary_receiver_value(args[1])))
		}
		127 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.delay())
		}
		128 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.schedule(promises_boundary_float(args[1])))
		}
		129 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.with_default_executor(promises_boundary_executor(args, 1)))
		}
		130, 131 {
			mut future := promises_boundary_receiver(args)
			levels := if args.len > 1 { int(args[1].as_int() or { 1 }) } else { 1 }
			return promises_public_boundary_value(future.flat_future(levels))
		}
		132 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.flat_event())
		}
		133, 134, 135 {
			mut future := promises_boundary_receiver(args)
			if id == 134 {
				future.on_fulfillment_bang(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			} else if id == 135 {
				future.on_fulfillment_using(promises_boundary_executor(args, 1), promises_boundary_noop_callback, promises_boundary_task_args(args, 2))
			} else {
				future.on_fulfillment(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			}
			return args[0]
		}
		136, 137, 138 {
			mut future := promises_boundary_receiver(args)
			if id == 137 {
				future.on_rejection_bang(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			} else if id == 138 {
				future.on_rejection_using(promises_boundary_executor(args, 1), promises_boundary_noop_callback, promises_boundary_task_args(args, 2))
			} else {
				future.on_rejection(promises_boundary_noop_callback, promises_boundary_task_args(args, 1))
			}
			return args[0]
		}
		139 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.run())
		}
		140 {
			return promises_boundary_apply(args)
		}
		141 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.to_event())
		}
		142 {
			return args[0]
		}
		143, 144 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.string_value(future.string())
		}
		145 {
			if args.len > 1 && promises_is_boundary_future(args[1]) {
				return args[1]
			}
			return promises_nil_value()
		}
		146 {
			raise_reassign := if args.len > 1 {
				promises_boundary_bool(args[1], true)
			} else {
				true
			}
			if raise_reassign {
				panic('Concurrent::MultipleAssignmentError: Future can be resolved only once')
			}
			return brew_runtime.bool_value(false)
		}
		147 {
			mut future := promises_boundary_receiver(args)
			resolved := future.wait(promises_boundary_timeout(args, 1))
			if future.rejected() {
				panic(future.reason(none, promises_nil_value()).repr)
			}
			return brew_runtime.bool_value(resolved)
		}
		148, 149, 150, 151, 152 {
			return promises_nil_value()
		}
		153 {
			mut event := promises_boundary_receiver(args)
			raise_reassign := if args.len > 1 {
				promises_boundary_bool(args[1], true)
			} else {
				true
			}
			reserved := if args.len > 2 { promises_boundary_bool(args[2], false) } else { false }
			resolved := event.resolve_event(raise_reassign, reserved) or { panic(err) }
			return if resolved { args[0] } else { brew_runtime.bool_value(false) }
		}
		154 {
			mut event := promises_boundary_receiver(args)
			return promises_public_boundary_value(event.with_hidden_resolvable())
		}
		155 {
			mut event := promises_boundary_receiver(args)
			resolved := event.wait(promises_boundary_timeout(args, 1))
			if !resolved && args.len > 2 && promises_boundary_bool(args[2], false) {
				resolved_on_timeout := event.resolve_event(false, false) or { false }
				return brew_runtime.bool_value(!resolved_on_timeout)
			}
			return if args.len > 1 { brew_runtime.bool_value(resolved) } else { args[0] }
		}
		156 {
			mut future := promises_boundary_receiver(args)
			fulfilled := if args.len > 1 { promises_boundary_bool(args[1], true) } else { true }
			value := if args.len > 2 { args[2] } else { promises_nil_value() }
			reason := if args.len > 3 { args[3] } else { promises_nil_value() }
			raise_reassign := if args.len > 4 {
				promises_boundary_bool(args[4], true)
			} else {
				true
			}
			reserved := if args.len > 5 { promises_boundary_bool(args[5], false) } else { false }
			resolved := future.resolve(fulfilled, value, reason, raise_reassign, reserved) or { panic(err) }
			return if resolved { args[0] } else { brew_runtime.bool_value(false) }
		}
		157 {
			mut future := promises_boundary_receiver(args)
			if args.len < 2 {
				panic('fulfill requires a value')
			}
			resolved := future.fulfill(args[1], if args.len > 2 {
				promises_boundary_bool(args[2], true)
			} else {
				true
			}, if args.len > 3 { promises_boundary_bool(args[3], false) } else { false }) or {
				panic(err)
			}
			return if resolved { args[0] } else { brew_runtime.bool_value(false) }
		}
		158 {
			mut future := promises_boundary_receiver(args)
			if args.len < 2 {
				panic('reject requires a reason')
			}
			resolved := future.reject(args[1], if args.len > 2 {
				promises_boundary_bool(args[2], true)
			} else {
				true
			}, if args.len > 3 { promises_boundary_bool(args[3], false) } else { false }) or {
				panic(err)
			}
			return if resolved { args[0] } else { brew_runtime.bool_value(false) }
		}
		159, 160 {
			mut future := promises_boundary_receiver(args)
			value := if args.len > 1 { args.last() } else { promises_nil_value() }
			future.fulfill(value, true, false) or { panic(err) }
			if id == 160 {
				future.value_or_error(none) or { panic(err) }
			}
			return args[0]
		}
		161, 162 {
			mut future := promises_boundary_receiver(args)
			resolved := future.wait(promises_boundary_timeout(args, 1))
			if !resolved && args.len > 2 {
				resolved_on_timeout := promises_resolve_timeout(mut future, args[2])
				if resolved_on_timeout {
					return brew_runtime.bool_value(false)
				}
			}
			if id == 162 && future.rejected() {
				panic(future.reason(none, promises_nil_value()).repr)
			}
			return if args.len > 1 {
				brew_runtime.bool_value(resolved || future.resolved())
			} else {
				args[0]
			}
		}
		163, 164 {
			mut future := promises_boundary_receiver(args)
			timeout_value := if args.len > 2 { args[2] } else { promises_nil_value() }
			if !future.wait(promises_boundary_timeout(args, 1)) && args.len > 3 {
				resolved_on_timeout := promises_resolve_timeout(mut future, args[3])
				if !resolved_on_timeout {
					if id == 164 {
						return future.value_or_error(none) or { panic(err) }
					}
					return future.value(none, timeout_value)
				}
				return timeout_value
			}
			if id == 164 {
				return future.value_or_error(none) or { panic(err) }
			}
			return future.value(none, timeout_value)
		}
		165 {
			mut future := promises_boundary_receiver(args)
			timeout_value := if args.len > 2 { args[2] } else { promises_nil_value() }
			if !future.wait(promises_boundary_timeout(args, 1)) && args.len > 3 {
				resolved_on_timeout := promises_resolve_timeout(mut future, args[3])
				if !resolved_on_timeout {
					return future.reason(none, timeout_value)
				}
				return timeout_value
			}
			return future.reason(none, timeout_value)
		}
		166 {
			mut future := promises_boundary_receiver(args)
			if !future.wait(promises_boundary_timeout(args, 1)) {
				if args.len > 2 {
					resolved_on_timeout := promises_resolve_timeout(mut future, args[2])
					if !resolved_on_timeout {
						return promises_boundary_result(mut future, time.Duration(0))
					}
				}
				return promises_nil_value()
			}
			return promises_boundary_result(mut future, time.Duration(0))
		}
		167 {
			mut future := promises_boundary_receiver(args)
			return promises_public_boundary_value(future.with_hidden_resolvable())
		}
		else {
			return promises_boundary_call_internal_promises(id, args)
		}
	}
}

fn promises_first_boundary_future(args []brew_runtime.Value) ?&PromisesEventFuture {
	for value in args {
		if promises_is_boundary_future(value) {
			return promises_boundary_receiver_value(value)
		}
	}
	return none
}

fn promises_internal_new_future(args []brew_runtime.Value, is_event bool) &PromisesEventFuture {
	if existing := promises_first_boundary_future(args) {
		return existing
	}
	return promises_new_event_future(is_event, promises_boundary_executor(args, 0))
}

fn promises_boundary_call_internal_promises(id int, args []brew_runtime.Value) brew_runtime.Value {
	match id {
		168 {
			future := promises_internal_new_future(args, false)
			return promises_internal_promise_value(future, 'AbstractPromise')
		}
		169, 170 {
			return promises_public_boundary_value(promises_boundary_receiver(args))
		}
		171 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_symbol(future.default_executor_name)
		}
		172 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_symbol(future.state_symbol())
		}
		173 {
			mut future := promises_boundary_receiver(args)
			future.touch()
			return promises_nil_value()
		}
		174, 175 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.string_value('#<Concurrent::Promises::AbstractPromise ${future.string()}>')
		}
		176 {
			mut future := promises_boundary_receiver(args)
			return if future.blockers.len == 0 {
				promises_nil_value()
			} else {
				promises_boundary_array(future.blockers)
			}
		}
		177 {
			if args.len < 2 {
				panic('resolve_with requires a state')
			}
			mut future := promises_boundary_receiver(args)
			result := promises_result_boundary_receiver(args[1])
			future.resolve_result(result, if args.len > 2 {
				promises_boundary_bool(args[2], true)
			} else {
				true
			}, false) or { panic(err) }
			return promises_public_boundary_value(future)
		}
		178 {
			mut future := promises_boundary_receiver(args)
			future.fulfill(if args.len > 1 { args.last() } else { promises_nil_value() }, true, false) or { panic(err) }
			return promises_public_boundary_value(future)
		}
		179 {
			return promises_internal_promise_value(promises_resolvable_event_on(promises_boundary_executor(args, 0)), 'ResolvableEventPromise')
		}
		180 {
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 0)), 'ResolvableFuturePromise')
		}
		181 {
			if args.len == 0 {
				panic('new_blocked_by1 requires a blocker')
			}
			mut blocker := promises_boundary_receiver_value(args[0])
			target := blocker.chain(promises_last_value_task, promises_boundary_task_args(args, 1))
			return promises_internal_promise_value(target, 'BlockedPromise')
		}
		182 {
			blockers := promises_boundary_blockers(args, 0)
			target := promises_zip_futures(blockers)
			return promises_internal_promise_value(target, 'BlockedPromise')
		}
		183 {
			blockers := promises_boundary_blockers(args, 0)
			return promises_internal_promise_value(promises_zip_futures(blockers), 'BlockedPromise')
		}
		184 {
			mut values := []brew_runtime.Value{}
			for value in args {
				if value.type_name == 'Array' {
					values << (value.as_array() or { [] })
				} else if value.type_name != 'NilClass' {
					values << value
				}
			}
			return if values.len == 0 {
				promises_nil_value()
			} else {
				brew_runtime.array_value(values)
			}
		}
		185 {
			future := promises_internal_new_future(args, false)
			return promises_internal_promise_value(future, 'BlockedPromise')
		}
		186 {
			mut target := promises_boundary_receiver(args)
			if args.len > 1 {
				mut source := promises_boundary_receiver_value(args[1])
				if result := source.result_now() {
					target.receive_blocker(result, if args.len > 2 {
						int(args[2].int_data)
					} else {
						0
					})
				}
			}
			return promises_nil_value()
		}
		187, 189 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_array(future.blockers)
		}
		188 {
			mut future := promises_boundary_receiver(args)
			future.touch()
			return promises_nil_value()
		}
		190 {
			for blocker in promises_boundary_blockers(args, 0) {
				mut dependency := promises_mutable_pointer(voidptr(blocker))
				dependency.touch()
			}
			return promises_nil_value()
		}
		191 {
			countdown := if args.len > 1 { args[1].as_int() or { 0 } } else { 0 }
			return brew_runtime.bool_value(countdown == 0)
		}
		192 {
			mut future := promises_boundary_receiver(args)
			future.mutex.lock()
			future.aggregate_remaining--
			countdown := future.aggregate_remaining
			future.mutex.unlock()
			return brew_runtime.int_value(countdown)
		}
		193 { panic('NotImplementedError') }
		194, 196, 198 {
			if args.len == 0 {
				panic('ArgumentError: no block given')
			}
			future := promises_resolvable_future_on(promises_boundary_executor(args, 2))
			return promises_internal_promise_value(future, match id {
				194 { 'BlockedTaskPromise' }
				196 { 'ThenPromise' }
				else { 'RescuePromise' }
			})
		}
		195 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_symbol(future.default_executor_name)
		}
		197 {
			mut target := promises_boundary_receiver(args)
			if args.len > 1 {
				mut source := promises_boundary_receiver_value(args[1])
				if result := source.result_now() {
					if result.fulfilled {
						target.fulfill(if args.len > 2 { args.last() } else { result.value }, false, false) or {}
					} else {
						target.resolve_result(result, false, false) or {}
					}
				}
			}
			return promises_nil_value()
		}
		199 {
			mut target := promises_boundary_receiver(args)
			if args.len > 1 {
				mut source := promises_boundary_receiver_value(args[1])
				if result := source.result_now() {
					if !result.fulfilled {
						target.fulfill(if args.len > 2 { args.last() } else { result.reason }, false, false) or {}
					} else {
						target.resolve_result(result, false, false) or {}
					}
				}
			}
			return promises_nil_value()
		}
		200 {
			mut target := promises_boundary_receiver(args)
			target.fulfill(if args.len > 1 { args.last() } else { promises_nil_value() }, false, false) or {}
			return promises_nil_value()
		}
		201 {
			return promises_internal_promise_value(promises_resolved_event_on(promises_boundary_executor(args, 0)), 'ImmediateEventPromise')
		}
		202 {
			if args.len < 4 {
				panic('ImmediateFuturePromise requires executor, fulfilled, value, reason')
			}
			future := promises_resolved_future(promises_boundary_bool(args[1], false), args[2], args[3], promises_boundary_executor(args, 0))
			return promises_internal_promise_value(future, 'ImmediateFuturePromise')
		}
		203 {
			future := promises_internal_new_future(args, false)
			return promises_internal_promise_value(future, 'AbstractFlatPromise')
		}
		204 {
			mut future := promises_boundary_receiver(args)
			future.touch()
			return promises_nil_value()
		}
		205 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.bool_value(future.was_touched())
		}
		206, 210, 212, 214, 216, 219, 221, 223, 226, 228, 231, 234 {
			return promises_internal_resolution_action(id, args)
		}
		207 {
			mut future := promises_boundary_receiver(args)
			countdown := if args.len > 1 { args[1].int_data } else { 0 }
			return brew_runtime.bool_value(!future.resolved() && countdown == 0)
		}
		208 {
			mut future := promises_boundary_receiver(args)
			if args.len > 1 && promises_is_boundary_future(args[1]) {
				future.blockers << promises_boundary_receiver_value(args[1])
			}
			return promises_nil_value()
		}
		209 {
			return promises_internal_promise_value(promises_resolvable_event_on(promises_boundary_executor(args, 2)), 'FlatEventPromise')
		}
		211 {
			levels := if args.len > 2 { args[2].as_int() or { 1 } } else { 1 }
			if levels < 1 {
				panic('ArgumentError: levels has to be higher than 0')
			}
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 3)), 'FlatFuturePromise')
		}
		213 {
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 2)), 'RunFuturePromise')
		}
		215 {
			return promises_internal_promise_value(promises_resolvable_event_on(promises_boundary_executor(args, 2)), 'ZipEventEventPromise')
		}
		217 {
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 2)), 'ZipFutureEventPromise')
		}
		218, 225 {
			mut target := promises_boundary_receiver(args)
			if args.len > 1 {
				mut source := promises_boundary_receiver_value(args[1])
				if result := source.result_now() {
					target.receive_blocker(result, if args.len > 2 {
						int(args[2].int_data)
					} else {
						0
					})
				}
			}
			return brew_runtime.int_value(target.aggregate_remaining)
		}
		220 {
			return promises_internal_promise_value(promises_resolvable_event_on(promises_boundary_executor(args, 2)), 'EventWrapperPromise')
		}
		222 {
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 2)), 'FutureWrapperPromise')
		}
		224 {
			count := if args.len > 1 { int(args[1].int_data) } else { 0 }
			mut target := promises_resolvable_future_on(promises_boundary_executor(args, 2))
			target.aggregate_mode = .zip_futures
			target.aggregate_resolutions = []?PromisesResult{len: count}
			target.aggregate_remaining = count
			if count == 0 {
				target.fulfill(brew_runtime.array_value([]), false, false) or {}
			}
			return promises_internal_promise_value(target, 'ZipFuturesPromise')
		}
		227 {
			count := if args.len > 1 { int(args[1].int_data) } else { 0 }
			mut target := promises_resolvable_event_on(promises_boundary_executor(args, 2))
			target.aggregate_mode = .zip_events
			target.aggregate_resolutions = []?PromisesResult{len: count}
			target.aggregate_remaining = count
			if count == 0 {
				target.resolve_event(false, false) or {}
			}
			return promises_internal_promise_value(target, 'ZipEventsPromise')
		}
		229 {
			return promises_internal_promise_value(promises_resolvable_event_on(promises_boundary_executor(args, 2)), 'AnyResolvedEventPromise')
		}
		230, 233 {
			return brew_runtime.bool_value(true)
		}
		232 {
			return promises_internal_promise_value(promises_resolvable_future_on(promises_boundary_executor(args, 2)), 'AnyResolvedFuturePromise')
		}
		235 {
			if args.len > 2 && promises_is_boundary_future(args[2]) {
				mut future := promises_boundary_receiver_value(args[2])
				countdown := if args.len > 1 { args[1].int_data } else { 0 }
				return brew_runtime.bool_value((future.is_event && future.resolved()) || future.fulfilled() || countdown == 0)
			}
			return brew_runtime.bool_value(args.len > 1 && args[1].int_data == 0)
		}
		236 {
			return promises_internal_promise_value(promises_delay_event_on(promises_boundary_executor(args, 0)), 'DelayPromise')
		}
		237 {
			mut future := promises_boundary_receiver(args)
			future.touch()
			return promises_nil_value()
		}
		238 {
			mut future := promises_boundary_receiver(args)
			return promises_boundary_array(future.blockers)
		}
		239 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.float_value(future.intended_time_seconds)
		}
		240 {
			mut future := promises_boundary_receiver(args)
			return brew_runtime.string_value('${future.string()[..future.string().len - 1]} intended_time: ${future.intended_time_seconds}>')
		}
		241 {
			if args.len < 2 {
				panic('ScheduledPromise requires executor and intended_time')
			}
			return promises_internal_promise_value(promises_schedule_event_on(promises_boundary_executor(args, 0), promises_boundary_float(args[1])), 'ScheduledPromise')
		}
		else { panic('unknown translated Promises boundary ${id}') }
	}
}

fn promises_internal_resolution_action(id int, args []brew_runtime.Value) brew_runtime.Value {
	mut target := promises_boundary_receiver(args)
	if args.len < 2 || !promises_is_boundary_future(args[1]) {
		return promises_nil_value()
	}
	mut source := promises_boundary_receiver_value(args[1])
	result := source.result_now() or { return promises_nil_value() }
	match id {
		210, 216, 221, 228, 231 { target.resolve_event(false, false) or {} }
		212 {
			promises_flatten_resolution(target, result, 1, false)
		}
		214 {
			promises_flatten_resolution(target, result, -1, false)
		}
		219, 223, 234 { target.resolve_result(result, false, false) or {} }
		225 { target.receive_blocker(result, if args.len > 2 { int(args[2].int_data) } else { 0 }) }
		226 { target.receive_blocker(result, if args.len > 2 { int(args[2].int_data) } else { 0 }) }
		206 { target.resolve_result(result, false, false) or {} }
		else {}
	}
	return promises_nil_value()
}

// Ruby method `default_executor` at line 54.
pub fn ruby_promises_l54_d1_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(1, args)
}

// Ruby method `resolvable_event` at line 63.
pub fn ruby_promises_l63_d2_resolvable_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(2, args)
}

// Ruby method `resolvable_event_on(default_executor = self.default_executor)` at line 72.
pub fn ruby_promises_l72_d3_resolvable_event_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(3, args)
}

// Ruby method `resolvable_future` at line 78.
pub fn ruby_promises_l78_d4_resolvable_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(4, args)
}

// Ruby method `resolvable_future_on(default_executor = self.default_executor)` at line 88.
pub fn ruby_promises_l88_d5_resolvable_future_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(5, args)
}

// Ruby method `future(*args, &task)` at line 94.
pub fn ruby_promises_l94_d6_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(6, args)
}

// Ruby method `future_on(default_executor, *args, &task)` at line 106.
pub fn ruby_promises_l106_d7_future_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(7, args)
}

// Ruby method `resolved_future(fulfilled, value, reason, default_executor = self.default_executor)` at line 118.
pub fn ruby_promises_l118_d8_resolved_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(8, args)
}

// Ruby method `fulfilled_future(value, default_executor = self.default_executor)` at line 127.
pub fn ruby_promises_l127_d9_fulfilled_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(9, args)
}

// Ruby method `rejected_future(reason, default_executor = self.default_executor)` at line 136.
pub fn ruby_promises_l136_d10_rejected_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(10, args)
}

// Ruby method `resolved_event(default_executor = self.default_executor)` at line 144.
pub fn ruby_promises_l144_d11_resolved_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(11, args)
}

// Ruby method `make_future(argument = nil, default_executor = self.default_executor)` at line 174.
pub fn ruby_promises_l174_d12_make_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(12, args)
}

// Ruby method `delay(*args, &task)` at line 190.
pub fn ruby_promises_l190_d13_delay(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(13, args)
}

// Ruby method `delay_on(default_executor, *args, &task)` at line 207.
pub fn ruby_promises_l207_d14_delay_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(14, args)
}

// Ruby method `schedule(intended_time, *args, &task)` at line 214.
pub fn ruby_promises_l214_d15_schedule(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(15, args)
}

// Ruby method `schedule_on(default_executor, intended_time, *args, &task)` at line 233.
pub fn ruby_promises_l233_d16_schedule_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(16, args)
}

// Ruby method `zip_futures(*futures_and_or_events)` at line 240.
pub fn ruby_promises_l240_d17_zip_futures(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(17, args)
}

// Ruby method `zip_futures_on(default_executor, *futures_and_or_events)` at line 254.
pub fn ruby_promises_l254_d18_zip_futures_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(18, args)
}

// Ruby alias_method `alias_method :zip, :zip_futures` at line 258.
pub fn ruby_promises_l258_d19_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(19, args)
}

// Ruby method `zip_events(*futures_and_or_events)` at line 262.
pub fn ruby_promises_l262_d20_zip_events(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(20, args)
}

// Ruby method `zip_events_on(default_executor, *futures_and_or_events)` at line 272.
pub fn ruby_promises_l272_d21_zip_events_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(21, args)
}

// Ruby method `any_resolved_future(*futures_and_or_events)` at line 278.
pub fn ruby_promises_l278_d22_any_resolved_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(22, args)
}

// Ruby alias_method `alias_method :any, :any_resolved_future` at line 282.
pub fn ruby_promises_l282_d23_any(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(23, args)
}

// Ruby method `any_resolved_future_on(default_executor, *futures_and_or_events)` at line 294.
pub fn ruby_promises_l294_d24_any_resolved_future_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(24, args)
}

// Ruby method `any_fulfilled_future(*futures_and_or_events)` at line 300.
pub fn ruby_promises_l300_d25_any_fulfilled_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(25, args)
}

// Ruby method `any_fulfilled_future_on(default_executor, *futures_and_or_events)` at line 313.
pub fn ruby_promises_l313_d26_any_fulfilled_future_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(26, args)
}

// Ruby method `any_event(*futures_and_or_events)` at line 319.
pub fn ruby_promises_l319_d27_any_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(27, args)
}

// Ruby method `any_event_on(default_executor, *futures_and_or_events)` at line 329.
pub fn ruby_promises_l329_d28_any_event_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(28, args)
}

// Ruby method `resolved?` at line 341.
pub fn ruby_promises_l341_d29_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(29, args)
}

// Ruby method `to_sym` at line 345.
pub fn ruby_promises_l345_d30_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(30, args)
}

// Ruby method `resolved?` at line 352.
pub fn ruby_promises_l352_d31_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(31, args)
}

// Ruby method `to_sym` at line 356.
pub fn ruby_promises_l356_d32_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(32, args)
}

// Ruby method `resolved?` at line 367.
pub fn ruby_promises_l367_d33_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(33, args)
}

// Ruby method `to_sym` at line 371.
pub fn ruby_promises_l371_d34_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(34, args)
}

// Ruby method `result` at line 375.
pub fn ruby_promises_l375_d35_result(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(35, args)
}

// Ruby method `fulfilled?` at line 379.
pub fn ruby_promises_l379_d36_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(36, args)
}

// Ruby method `value` at line 383.
pub fn ruby_promises_l383_d37_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(37, args)
}

// Ruby method `reason` at line 387.
pub fn ruby_promises_l387_d38_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(38, args)
}

// Ruby method `apply` at line 391.
pub fn ruby_promises_l391_d39_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(39, args)
}

// Ruby method `initialize(value)` at line 399.
pub fn ruby_promises_l399_d40_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(40, args)
}

// Ruby method `fulfilled?` at line 403.
pub fn ruby_promises_l403_d41_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(41, args)
}

// Ruby method `apply(args, block)` at line 407.
pub fn ruby_promises_l407_d42_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(42, args)
}

// Ruby method `value` at line 411.
pub fn ruby_promises_l411_d43_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(43, args)
}

// Ruby method `reason` at line 415.
pub fn ruby_promises_l415_d44_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(44, args)
}

// Ruby method `to_sym` at line 419.
pub fn ruby_promises_l419_d45_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(45, args)
}

// Ruby method `apply(args, block)` at line 426.
pub fn ruby_promises_l426_d46_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(46, args)
}

// Ruby method `initialize(reason)` at line 433.
pub fn ruby_promises_l433_d47_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(47, args)
}

// Ruby method `fulfilled?` at line 437.
pub fn ruby_promises_l437_d48_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(48, args)
}

// Ruby method `value` at line 441.
pub fn ruby_promises_l441_d49_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(49, args)
}

// Ruby method `reason` at line 445.
pub fn ruby_promises_l445_d50_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(50, args)
}

// Ruby method `to_sym` at line 449.
pub fn ruby_promises_l449_d51_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(51, args)
}

// Ruby method `apply(args, block)` at line 453.
pub fn ruby_promises_l453_d52_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(52, args)
}

// Ruby method `initialize(value, reason)` at line 460.
pub fn ruby_promises_l460_d53_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(53, args)
}

// Ruby method `fulfilled?` at line 466.
pub fn ruby_promises_l466_d54_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(54, args)
}

// Ruby method `to_sym` at line 470.
pub fn ruby_promises_l470_d55_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(55, args)
}

// Ruby method `value` at line 474.
pub fn ruby_promises_l474_d56_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(56, args)
}

// Ruby method `reason` at line 478.
pub fn ruby_promises_l478_d57_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(57, args)
}

// Ruby method `apply(args, block)` at line 482.
pub fn ruby_promises_l482_d58_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(58, args)
}

// Ruby method `RESOLVED.to_sym` at line 494.
pub fn ruby_promises_l494_d59_resolved_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(59, args)
}

// Ruby attr_atomic `attr_atomic(:internal_state)` at line 515.
pub fn ruby_promises_l515_d60_internal_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(60, args)
}

// Ruby attr_atomic `attr_atomic(:internal_state)` at line 515.
pub fn ruby_promises_l515_d61_internal_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(61, args)
}

// Ruby attr_atomic `attr_atomic(:internal_state)` at line 515.
pub fn ruby_promises_l515_d62_compare_and_set_internal_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(62, args)
}

// Ruby attr_atomic `attr_atomic(:internal_state)` at line 515.
pub fn ruby_promises_l515_d63_swap_internal_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(63, args)
}

// Ruby attr_atomic `attr_atomic(:internal_state)` at line 515.
pub fn ruby_promises_l515_d64_update_internal_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(64, args)
}

// Ruby method `initialize(promise, default_executor)` at line 522.
pub fn ruby_promises_l522_d65_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(65, args)
}

// Ruby method `state` at line 543.
pub fn ruby_promises_l543_d66_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(66, args)
}

// Ruby method `pending?` at line 549.
pub fn ruby_promises_l549_d67_pending(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(67, args)
}

// Ruby method `resolved?` at line 555.
pub fn ruby_promises_l555_d68_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(68, args)
}

// Ruby method `touch` at line 562.
pub fn ruby_promises_l562_d69_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(69, args)
}

// Ruby method `wait(timeout = nil)` at line 578.
pub fn ruby_promises_l578_d70_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(70, args)
}

// Ruby method `default_executor` at line 590.
pub fn ruby_promises_l590_d71_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(71, args)
}

// Ruby method `chain(*args, &task)` at line 596.
pub fn ruby_promises_l596_d72_chain(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(72, args)
}

// Ruby method `chain_on(executor, *args, &task)` at line 614.
pub fn ruby_promises_l614_d73_chain_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(73, args)
}

// Ruby method `to_s` at line 619.
pub fn ruby_promises_l619_d74_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(74, args)
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 623.
pub fn ruby_promises_l623_d75_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(75, args)
}

// Ruby method `chain_resolvable(resolvable)` at line 629.
pub fn ruby_promises_l629_d76_chain_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(76, args)
}

// Ruby alias_method `alias_method :tangle, :chain_resolvable` at line 633.
pub fn ruby_promises_l633_d77_tangle(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(77, args)
}

// Ruby method `on_resolution(*args, &callback)` at line 637.
pub fn ruby_promises_l637_d78_on_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(78, args)
}

// Ruby method `on_resolution!(*args, &callback)` at line 655.
pub fn ruby_promises_l655_d79_on_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(79, args)
}

// Ruby method `on_resolution_using(executor, *args, &callback)` at line 673.
pub fn ruby_promises_l673_d80_on_resolution_using(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(80, args)
}

// Ruby method `with_default_executor(executor)` at line 683.
pub fn ruby_promises_l683_d81_with_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(81, args)
}

// Ruby method `resolve_with(state, raise_on_reassign = true, reserved = false)` at line 688.
pub fn ruby_promises_l688_d82_resolve_with(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(82, args)
}

// Ruby method `blocks` at line 702.
pub fn ruby_promises_l702_d83_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(83, args)
}

// Ruby method `callbacks` at line 710.
pub fn ruby_promises_l710_d84_callbacks(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(84, args)
}

// Ruby method `promise` at line 716.
pub fn ruby_promises_l716_d85_promise(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(85, args)
}

// Ruby method `touched?` at line 722.
pub fn ruby_promises_l722_d86_touched(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(86, args)
}

// Ruby method `waiting_threads` at line 728.
pub fn ruby_promises_l728_d87_waiting_threads(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(87, args)
}

// Ruby method `add_callback_notify_blocked(promise, index)` at line 733.
pub fn ruby_promises_l733_d88_add_callback_notify_blocked(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(88, args)
}

// Ruby method `add_callback_clear_delayed_node(node)` at line 738.
pub fn ruby_promises_l738_d89_add_callback_clear_delayed_node(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(89, args)
}

// Ruby method `with_hidden_resolvable` at line 743.
pub fn ruby_promises_l743_d90_with_hidden_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(90, args)
}

// Ruby method `add_callback(method, *args)` at line 750.
pub fn ruby_promises_l750_d91_add_callback(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(91, args)
}

// Ruby method `callback_clear_delayed_node(state, node)` at line 763.
pub fn ruby_promises_l763_d92_callback_clear_delayed_node(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(92, args)
}

// Ruby method `wait_until_resolved(timeout)` at line 768.
pub fn ruby_promises_l768_d93_wait_until_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(93, args)
}

// Ruby method `call_callback(method, state, args)` at line 796.
pub fn ruby_promises_l796_d94_call_callback(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(94, args)
}

// Ruby method `call_callbacks(state)` at line 800.
pub fn ruby_promises_l800_d95_call_callbacks(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(95, args)
}

// Ruby method `with_async(executor, *args, &block)` at line 808.
pub fn ruby_promises_l808_d96_with_async(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(96, args)
}

// Ruby method `async_callback_on_resolution(state, executor, args, callback)` at line 812.
pub fn ruby_promises_l812_d97_async_callback_on_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(97, args)
}

// Ruby method `callback_notify_blocked(state, promise, index)` at line 818.
pub fn ruby_promises_l818_d98_callback_notify_blocked(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(98, args)
}

// Ruby alias_method `alias_method :then, :chain` at line 828.
pub fn ruby_promises_l828_d99_then(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(99, args)
}

// Ruby method `zip(other)` at line 839.
pub fn ruby_promises_l839_d100_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(100, args)
}

// Ruby alias_method `alias_method :&, :zip` at line 847.
pub fn ruby_promises_l847_d101_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(101, args)
}

// Ruby method `any(event_or_future)` at line 853.
pub fn ruby_promises_l853_d102_any(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(102, args)
}

// Ruby alias_method `alias_method :|, :any` at line 857.
pub fn ruby_promises_l857_d103_any(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(103, args)
}

// Ruby method `delay` at line 863.
pub fn ruby_promises_l863_d104_delay(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(104, args)
}

// Ruby method `schedule(intended_time)` at line 875.
pub fn ruby_promises_l875_d105_schedule(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(105, args)
}

// Ruby method `to_future` at line 885.
pub fn ruby_promises_l885_d106_to_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(106, args)
}

// Ruby method `to_event` at line 893.
pub fn ruby_promises_l893_d107_to_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(107, args)
}

// Ruby method `with_default_executor(executor)` at line 899.
pub fn ruby_promises_l899_d108_with_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(108, args)
}

// Ruby method `rejected_resolution(raise_on_reassign, state)` at line 905.
pub fn ruby_promises_l905_d109_rejected_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(109, args)
}

// Ruby method `callback_on_resolution(state, args, callback)` at line 910.
pub fn ruby_promises_l910_d110_callback_on_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(110, args)
}

// Ruby method `fulfilled?` at line 922.
pub fn ruby_promises_l922_d111_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(111, args)
}

// Ruby method `rejected?` at line 929.
pub fn ruby_promises_l929_d112_rejected(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(112, args)
}

// Ruby method `value(timeout = nil, timeout_value = nil)` at line 951.
pub fn ruby_promises_l951_d113_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(113, args)
}

// Ruby method `reason(timeout = nil, timeout_value = nil)` at line 967.
pub fn ruby_promises_l967_d114_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(114, args)
}

// Ruby method `result(timeout = nil)` at line 982.
pub fn ruby_promises_l982_d115_result(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(115, args)
}

// Ruby method `wait!(timeout = nil)` at line 988.
pub fn ruby_promises_l988_d116_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(116, args)
}

// Ruby method `value!(timeout = nil, timeout_value = nil)` at line 998.
pub fn ruby_promises_l998_d117_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(117, args)
}

// Ruby method `exception(*args)` at line 1014.
pub fn ruby_promises_l1014_d118_exception(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(118, args)
}

// Ruby method `then(*args, &task)` at line 1040.
pub fn ruby_promises_l1040_d119_then(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(119, args)
}

// Ruby method `then_on(executor, *args, &task)` at line 1052.
pub fn ruby_promises_l1052_d120_then_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(120, args)
}

// Ruby method `rescue(*args, &task)` at line 1058.
pub fn ruby_promises_l1058_d121_rescue(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(121, args)
}

// Ruby method `rescue_on(executor, *args, &task)` at line 1070.
pub fn ruby_promises_l1070_d122_rescue_on(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(122, args)
}

// Ruby method `zip(other)` at line 1076.
pub fn ruby_promises_l1076_d123_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(123, args)
}

// Ruby alias_method `alias_method :&, :zip` at line 1084.
pub fn ruby_promises_l1084_d124_zip(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(124, args)
}

// Ruby method `any(event_or_future)` at line 1091.
pub fn ruby_promises_l1091_d125_any(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(125, args)
}

// Ruby alias_method `alias_method :|, :any` at line 1095.
pub fn ruby_promises_l1095_d126_any(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(126, args)
}

// Ruby method `delay` at line 1101.
pub fn ruby_promises_l1101_d127_delay(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(127, args)
}

// Ruby method `schedule(intended_time)` at line 1108.
pub fn ruby_promises_l1108_d128_schedule(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(128, args)
}

// Ruby method `with_default_executor(executor)` at line 1117.
pub fn ruby_promises_l1117_d129_with_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(129, args)
}

// Ruby method `flat_future(level = 1)` at line 1126.
pub fn ruby_promises_l1126_d130_flat_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(130, args)
}

// Ruby alias_method `alias_method :flat, :flat_future` at line 1130.
pub fn ruby_promises_l1130_d131_flat(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(131, args)
}

// Ruby method `flat_event` at line 1136.
pub fn ruby_promises_l1136_d132_flat_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(132, args)
}

// Ruby method `on_fulfillment(*args, &callback)` at line 1142.
pub fn ruby_promises_l1142_d133_on_fulfillment(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(133, args)
}

// Ruby method `on_fulfillment!(*args, &callback)` at line 1153.
pub fn ruby_promises_l1153_d134_on_fulfillment(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(134, args)
}

// Ruby method `on_fulfillment_using(executor, *args, &callback)` at line 1165.
pub fn ruby_promises_l1165_d135_on_fulfillment_using(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(135, args)
}

// Ruby method `on_rejection(*args, &callback)` at line 1171.
pub fn ruby_promises_l1171_d136_on_rejection(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(136, args)
}

// Ruby method `on_rejection!(*args, &callback)` at line 1182.
pub fn ruby_promises_l1182_d137_on_rejection(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(137, args)
}

// Ruby method `on_rejection_using(executor, *args, &callback)` at line 1194.
pub fn ruby_promises_l1194_d138_on_rejection_using(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(138, args)
}

// Ruby method `run(run_test = method(:run_test))` at line 1216.
pub fn ruby_promises_l1216_d139_run(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(139, args)
}

// Ruby method `apply(args, block)` at line 1221.
pub fn ruby_promises_l1221_d140_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(140, args)
}

// Ruby method `to_event` at line 1228.
pub fn ruby_promises_l1228_d141_to_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(141, args)
}

// Ruby method `to_future` at line 1236.
pub fn ruby_promises_l1236_d142_to_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(142, args)
}

// Ruby method `to_s` at line 1241.
pub fn ruby_promises_l1241_d143_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(143, args)
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 1249.
pub fn ruby_promises_l1249_d144_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(144, args)
}

// Ruby method `run_test(v)` at line 1253.
pub fn ruby_promises_l1253_d145_run_test(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(145, args)
}

// Ruby method `rejected_resolution(raise_on_reassign, state)` at line 1257.
pub fn ruby_promises_l1257_d146_rejected_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(146, args)
}

// Ruby method `wait_until_resolved!(timeout = nil)` at line 1272.
pub fn ruby_promises_l1272_d147_wait_until_resolved(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(147, args)
}

// Ruby method `async_callback_on_fulfillment(state, executor, args, callback)` at line 1278.
pub fn ruby_promises_l1278_d148_async_callback_on_fulfillment(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(148, args)
}

// Ruby method `async_callback_on_rejection(state, executor, args, callback)` at line 1284.
pub fn ruby_promises_l1284_d149_async_callback_on_rejection(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(149, args)
}

// Ruby method `callback_on_fulfillment(state, args, callback)` at line 1290.
pub fn ruby_promises_l1290_d150_callback_on_fulfillment(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(150, args)
}

// Ruby method `callback_on_rejection(state, args, callback)` at line 1294.
pub fn ruby_promises_l1294_d151_callback_on_rejection(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(151, args)
}

// Ruby method `callback_on_resolution(state, args, callback)` at line 1298.
pub fn ruby_promises_l1298_d152_callback_on_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(152, args)
}

// Ruby method `resolve(raise_on_reassign = true, reserved = false)` at line 1330.
pub fn ruby_promises_l1330_d153_resolve(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(153, args)
}

// Ruby method `with_hidden_resolvable` at line 1337.
pub fn ruby_promises_l1337_d154_with_hidden_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(154, args)
}

// Ruby method `wait(timeout = nil, resolve_on_timeout = false)` at line 1348.
pub fn ruby_promises_l1348_d155_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(155, args)
}

// Ruby method `resolve(fulfilled = true, value = nil, reason = nil, raise_on_reassign = true, reserved = false)` at line 1371.
pub fn ruby_promises_l1371_d156_resolve(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(156, args)
}

// Ruby method `fulfill(value, raise_on_reassign = true, reserved = false)` at line 1381.
pub fn ruby_promises_l1381_d157_fulfill(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(157, args)
}

// Ruby method `reject(reason, raise_on_reassign = true, reserved = false)` at line 1391.
pub fn ruby_promises_l1391_d158_reject(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(158, args)
}

// Ruby method `evaluate_to(*args, &block)` at line 1401.
pub fn ruby_promises_l1401_d159_evaluate_to(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(159, args)
}

// Ruby method `evaluate_to!(*args, &block)` at line 1412.
pub fn ruby_promises_l1412_d160_evaluate_to(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(160, args)
}

// Ruby method `wait(timeout = nil, resolve_on_timeout = nil)` at line 1427.
pub fn ruby_promises_l1427_d161_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(161, args)
}

// Ruby method `wait!(timeout = nil, resolve_on_timeout = nil)` at line 1444.
pub fn ruby_promises_l1444_d162_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(162, args)
}

// Ruby method `value(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)` at line 1465.
pub fn ruby_promises_l1465_d163_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(163, args)
}

// Ruby method `value!(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)` at line 1487.
pub fn ruby_promises_l1487_d164_value(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(164, args)
}

// Ruby method `reason(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)` at line 1509.
pub fn ruby_promises_l1509_d165_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(165, args)
}

// Ruby method `result(timeout = nil, resolve_on_timeout = nil)` at line 1530.
pub fn ruby_promises_l1530_d166_result(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(166, args)
}

// Ruby method `with_hidden_resolvable` at line 1548.
pub fn ruby_promises_l1548_d167_with_hidden_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(167, args)
}

// Ruby method `initialize(future)` at line 1559.
pub fn ruby_promises_l1559_d168_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(168, args)
}

// Ruby method `future` at line 1564.
pub fn ruby_promises_l1564_d169_future(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(169, args)
}

// Ruby alias_method `alias_method :event, :future` at line 1568.
pub fn ruby_promises_l1568_d170_event(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(170, args)
}

// Ruby method `default_executor` at line 1570.
pub fn ruby_promises_l1570_d171_default_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(171, args)
}

// Ruby method `state` at line 1574.
pub fn ruby_promises_l1574_d172_state(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(172, args)
}

// Ruby method `touch` at line 1578.
pub fn ruby_promises_l1578_d173_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(173, args)
}

// Ruby method `to_s` at line 1581.
pub fn ruby_promises_l1581_d174_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(174, args)
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 1585.
pub fn ruby_promises_l1585_d175_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(175, args)
}

// Ruby method `delayed_because` at line 1587.
pub fn ruby_promises_l1587_d176_delayed_because(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(176, args)
}

// Ruby method `resolve_with(new_state, raise_on_reassign = true)` at line 1593.
pub fn ruby_promises_l1593_d177_resolve_with(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(177, args)
}

// Ruby method `evaluate_to(*args, block)` at line 1598.
pub fn ruby_promises_l1598_d178_evaluate_to(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(178, args)
}

// Ruby method `initialize(default_executor)` at line 1607.
pub fn ruby_promises_l1607_d179_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(179, args)
}

// Ruby method `initialize(default_executor)` at line 1613.
pub fn ruby_promises_l1613_d180_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(180, args)
}

// Ruby method `self.new_blocked_by1(blocker, *args, &block)` at line 1629.
pub fn ruby_promises_l1629_d181_self_new_blocked_by1(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(181, args)
}

// Ruby method `self.new_blocked_by2(blocker1, blocker2, *args, &block)` at line 1636.
pub fn ruby_promises_l1636_d182_self_new_blocked_by2(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(182, args)
}

// Ruby method `self.new_blocked_by(blockers, *args, &block)` at line 1651.
pub fn ruby_promises_l1651_d183_self_new_blocked_by(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(183, args)
}

// Ruby method `self.add_delayed(delayed1, delayed2)` at line 1658.
pub fn ruby_promises_l1658_d184_self_add_delayed(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(184, args)
}

// Ruby method `initialize(delayed, blockers_count, future)` at line 1667.
pub fn ruby_promises_l1667_d185_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(185, args)
}

// Ruby method `on_blocker_resolution(future, index)` at line 1673.
pub fn ruby_promises_l1673_d186_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(186, args)
}

// Ruby method `delayed_because` at line 1680.
pub fn ruby_promises_l1680_d187_delayed_because(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(187, args)
}

// Ruby method `touch` at line 1684.
pub fn ruby_promises_l1684_d188_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(188, args)
}

// Ruby method `blocked_by` at line 1689.
pub fn ruby_promises_l1689_d189_blocked_by(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(189, args)
}

// Ruby method `clear_and_propagate_touch(stack_or_element = @Delayed)` at line 1697.
pub fn ruby_promises_l1697_d190_clear_and_propagate_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(190, args)
}

// Ruby method `resolvable?(countdown, future, index)` at line 1708.
pub fn ruby_promises_l1708_d191_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(191, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 1712.
pub fn ruby_promises_l1712_d192_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(192, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1716.
pub fn ruby_promises_l1716_d193_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(193, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor, executor, args, &task)` at line 1723.
pub fn ruby_promises_l1723_d194_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(194, args)
}

// Ruby method `executor` at line 1731.
pub fn ruby_promises_l1731_d195_executor(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(195, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor, executor, args, &task)` at line 1739.
pub fn ruby_promises_l1739_d196_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(196, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1743.
pub fn ruby_promises_l1743_d197_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(197, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor, executor, args, &task)` at line 1757.
pub fn ruby_promises_l1757_d198_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(198, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1761.
pub fn ruby_promises_l1761_d199_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(199, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1775.
pub fn ruby_promises_l1775_d200_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(200, args)
}

// Ruby method `initialize(default_executor)` at line 1790.
pub fn ruby_promises_l1790_d201_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(201, args)
}

// Ruby method `initialize(default_executor, fulfilled, value, reason)` at line 1796.
pub fn ruby_promises_l1796_d202_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(202, args)
}

// Ruby method `initialize(delayed_because, blockers_count, event_or_future)` at line 1804.
pub fn ruby_promises_l1804_d203_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(203, args)
}

// Ruby method `touch` at line 1814.
pub fn ruby_promises_l1814_d204_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(204, args)
}

// Ruby method `touched?` at line 1822.
pub fn ruby_promises_l1822_d205_touched(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(205, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1826.
pub fn ruby_promises_l1826_d206_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(206, args)
}

// Ruby method `resolvable?(countdown, future, index)` at line 1830.
pub fn ruby_promises_l1830_d207_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(207, args)
}

// Ruby method `add_delayed_of(future)` at line 1834.
pub fn ruby_promises_l1834_d208_add_delayed_of(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(208, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 1850.
pub fn ruby_promises_l1850_d209_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(209, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 1854.
pub fn ruby_promises_l1854_d210_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(210, args)
}

// Ruby method `initialize(delayed, blockers_count, levels, default_executor)` at line 1883.
pub fn ruby_promises_l1883_d211_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(211, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 1890.
pub fn ruby_promises_l1890_d212_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(212, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor, run_test)` at line 1919.
pub fn ruby_promises_l1919_d213_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(213, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 1924.
pub fn ruby_promises_l1924_d214_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(214, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 1947.
pub fn ruby_promises_l1947_d215_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(215, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1953.
pub fn ruby_promises_l1953_d216_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(216, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 1959.
pub fn ruby_promises_l1959_d217_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(217, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 1966.
pub fn ruby_promises_l1966_d218_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(218, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1973.
pub fn ruby_promises_l1973_d219_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(219, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 1979.
pub fn ruby_promises_l1979_d220_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(220, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1985.
pub fn ruby_promises_l1985_d221_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(221, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 1991.
pub fn ruby_promises_l1991_d222_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(222, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 1997.
pub fn ruby_promises_l1997_d223_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(223, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 2006.
pub fn ruby_promises_l2006_d224_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(224, args)
}

// Ruby method `process_on_blocker_resolution(future, index)` at line 2013.
pub fn ruby_promises_l2013_d225_process_on_blocker_resolution(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(225, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 2019.
pub fn ruby_promises_l2019_d226_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(226, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 2041.
pub fn ruby_promises_l2041_d227_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(227, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 2047.
pub fn ruby_promises_l2047_d228_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(228, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 2060.
pub fn ruby_promises_l2060_d229_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(229, args)
}

// Ruby method `resolvable?(countdown, future, index)` at line 2064.
pub fn ruby_promises_l2064_d230_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(230, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 2068.
pub fn ruby_promises_l2068_d231_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(231, args)
}

// Ruby method `initialize(delayed, blockers_count, default_executor)` at line 2077.
pub fn ruby_promises_l2077_d232_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(232, args)
}

// Ruby method `resolvable?(countdown, future, index)` at line 2081.
pub fn ruby_promises_l2081_d233_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(233, args)
}

// Ruby method `on_resolvable(resolved_future, index)` at line 2085.
pub fn ruby_promises_l2085_d234_on_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(234, args)
}

// Ruby method `resolvable?(countdown, event_or_future, index)` at line 2094.
pub fn ruby_promises_l2094_d235_resolvable(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(235, args)
}

// Ruby method `initialize(default_executor)` at line 2103.
pub fn ruby_promises_l2103_d236_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(236, args)
}

// Ruby method `touch` at line 2110.
pub fn ruby_promises_l2110_d237_touch(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(237, args)
}

// Ruby method `delayed_because` at line 2114.
pub fn ruby_promises_l2114_d238_delayed_because(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(238, args)
}

// Ruby method `intended_time` at line 2121.
pub fn ruby_promises_l2121_d239_intended_time(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(239, args)
}

// Ruby method `inspect` at line 2125.
pub fn ruby_promises_l2125_d240_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(240, args)
}

// Ruby method `initialize(default_executor, intended_time)` at line 2131.
pub fn ruby_promises_l2131_d241_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return promises_boundary_call(241, args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/object'
// 2: require 'concurrent/atomic/atomic_boolean'
// 3: require 'concurrent/atomic/atomic_fixnum'
// 4: require 'concurrent/collection/lock_free_stack'
// 5: require 'concurrent/configuration'
// 6: require 'concurrent/errors'
// 7: require 'concurrent/re_include'
// 8: require 'concurrent/utility/monotonic_time'
// 9:
// 10: module Concurrent
// 11:
// 12:   # {include:file:docs-source/promises-main.md}
// 13:   module Promises
// 14:
// 15:     # @!macro promises.param.default_executor
// 16:     #   @param [Executor, :io, :fast] default_executor Instance of an executor or a name of the
// 17:     #     global executor. Default executor propagates to chained futures unless overridden with
// 18:     #     executor parameter or changed with {AbstractEventFuture#with_default_executor}.
// 19:     #
// 20:     # @!macro promises.param.executor
// 21:     #   @param [Executor, :io, :fast] executor Instance of an executor or a name of the
// 22:     #     global executor. The task is executed on it, default executor remains unchanged.
// 23:     #
// 24:     # @!macro promises.param.args
// 25:     #   @param [Object] args arguments which are passed to the task when it's executed.
// 26:     #     (It might be prepended with other arguments, see the @yield section).
// 27:     #
// 28:     # @!macro promises.shortcut.on
// 29:     #   Shortcut of {#$0_on} with default `:io` executor supplied.
// 30:     #   @see #$0_on
// 31:     #
// 32:     # @!macro promises.shortcut.using
// 33:     #   Shortcut of {#$0_using} with default `:io` executor supplied.
// 34:     #   @see #$0_using
// 35:     #
// 36:     # @!macro promise.param.task-future
// 37:     #  @yieldreturn will become result of the returned Future.
// 38:     #     Its returned value becomes {Future#value} fulfilling it,
// 39:     #     raised exception becomes {Future#reason} rejecting it.
// 40:     #
// 41:     # @!macro promise.param.callback
// 42:     #  @yieldreturn is forgotten.
// 43:
// 44:     # Container of all {Future}, {Event} factory methods. They are never constructed directly with
// 45:     # new.
// 46:     module FactoryMethods
// 47:       extend ReInclude
// 48:       extend self
// 49:
// 50:       module Configuration
// 51:         # @return [Executor, :io, :fast] the executor which is used when none is supplied
// 52:         #   to a factory method. The method can be overridden in the receivers of
// 53:         #   `include FactoryMethod`
// 54:         def default_executor
// 55:           :io
// 56:         end
// 57:       end
// 58:
// 59:       include Configuration
// 60:
// 61:       # @!macro promises.shortcut.on
// 62:       # @return [ResolvableEvent]
// 63:       def resolvable_event
// 64:         resolvable_event_on default_executor
// 65:       end
// 66:
// 67:       # Creates a resolvable event, user is responsible for resolving the event once
// 68:       # by calling {Promises::ResolvableEvent#resolve}.
// 69:       #
// 70:       # @!macro promises.param.default_executor
// 71:       # @return [ResolvableEvent]
// 72:       def resolvable_event_on(default_executor = self.default_executor)
// 73:         ResolvableEventPromise.new(default_executor).future
// 74:       end
// 75:
// 76:       # @!macro promises.shortcut.on
// 77:       # @return [ResolvableFuture]
// 78:       def resolvable_future
// 79:         resolvable_future_on default_executor
// 80:       end
// 81:
// 82:       # Creates resolvable future, user is responsible for resolving the future once by
// 83:       # {Promises::ResolvableFuture#resolve}, {Promises::ResolvableFuture#fulfill},
// 84:       # or {Promises::ResolvableFuture#reject}
// 85:       #
// 86:       # @!macro promises.param.default_executor
// 87:       # @return [ResolvableFuture]
// 88:       def resolvable_future_on(default_executor = self.default_executor)
// 89:         ResolvableFuturePromise.new(default_executor).future
// 90:       end
// 91:
// 92:       # @!macro promises.shortcut.on
// 93:       # @return [Future]
// 94:       def future(*args, &task)
// 95:         future_on(default_executor, *args, &task)
// 96:       end
// 97:
// 98:       # Constructs a new Future which will be resolved after block is evaluated on default executor.
// 99:       # Evaluation begins immediately.
// 100:       #
// 101:       # @!macro promises.param.default_executor
// 102:       # @!macro promises.param.args
// 103:       # @yield [*args] to the task.
// 104:       # @!macro promise.param.task-future
// 105:       # @return [Future]
// 106:       def future_on(default_executor, *args, &task)
// 107:         ImmediateEventPromise.new(default_executor).future.then(*args, &task)
// 108:       end
// 109:
// 110:       # Creates a resolved future with will be either fulfilled with the given value or rejected with
// 111:       # the given reason.
// 112:       #
// 113:       # @param [true, false] fulfilled
// 114:       # @param [Object] value
// 115:       # @param [Object] reason
// 116:       # @!macro promises.param.default_executor
// 117:       # @return [Future]
// 118:       def resolved_future(fulfilled, value, reason, default_executor = self.default_executor)
// 119:         ImmediateFuturePromise.new(default_executor, fulfilled, value, reason).future
// 120:       end
// 121:
// 122:       # Creates a resolved future which will be fulfilled with the given value.
// 123:       #
// 124:       # @!macro promises.param.default_executor
// 125:       # @param [Object] value
// 126:       # @return [Future]
// 127:       def fulfilled_future(value, default_executor = self.default_executor)
// 128:         resolved_future true, value, nil, default_executor
// 129:       end
// 130:
// 131:       # Creates a resolved future which will be rejected with the given reason.
// 132:       #
// 133:       # @!macro promises.param.default_executor
// 134:       # @param [Object] reason
// 135:       # @return [Future]
// 136:       def rejected_future(reason, default_executor = self.default_executor)
// 137:         resolved_future false, nil, reason, default_executor
// 138:       end
// 139:
// 140:       # Creates resolved event.
// 141:       #
// 142:       # @!macro promises.param.default_executor
// 143:       # @return [Event]
// 144:       def resolved_event(default_executor = self.default_executor)
// 145:         ImmediateEventPromise.new(default_executor).event
// 146:       end
// 147:
// 148:       # General constructor. Behaves differently based on the argument's type. It's provided for convenience
// 149:       # but it's better to be explicit.
// 150:       #
// 151:       # @see rejected_future, resolved_event, fulfilled_future
// 152:       # @!macro promises.param.default_executor
// 153:       # @return [Event, Future]
// 154:       #
// 155:       # @overload make_future(nil, default_executor = self.default_executor)
// 156:       #   @param [nil] nil
// 157:       #   @return [Event] resolved event.
// 158:       #
// 159:       # @overload make_future(a_future, default_executor = self.default_executor)
// 160:       #   @param [Future] a_future
// 161:       #   @return [Future] a future which will be resolved when a_future is.
// 162:       #
// 163:       # @overload make_future(an_event, default_executor = self.default_executor)
// 164:       #   @param [Event] an_event
// 165:       #   @return [Event] an event which will be resolved when an_event is.
// 166:       #
// 167:       # @overload make_future(exception, default_executor = self.default_executor)
// 168:       #   @param [Exception] exception
// 169:       #   @return [Future] a rejected future with the exception as its reason.
// 170:       #
// 171:       # @overload make_future(value, default_executor = self.default_executor)
// 172:       #   @param [Object] value when none of the above overloads fits
// 173:       #   @return [Future] a fulfilled future with the value.
// 174:       def make_future(argument = nil, default_executor = self.default_executor)
// 175:         case argument
// 176:         when AbstractEventFuture
// 177:           # returning wrapper would change nothing
// 178:           argument
// 179:         when Exception
// 180:           rejected_future argument, default_executor
// 181:         when nil
// 182:           resolved_event default_executor
// 183:         else
// 184:           fulfilled_future argument, default_executor
// 185:         end
// 186:       end
// 187:
// 188:       # @!macro promises.shortcut.on
// 189:       # @return [Future, Event]
// 190:       def delay(*args, &task)
// 191:         delay_on default_executor, *args, &task
// 192:       end
// 193:
// 194:       # Creates a new event or future which is resolved only after it is touched,
// 195:       # see {Concurrent::AbstractEventFuture#touch}.
// 196:       #
// 197:       # @!macro promises.param.default_executor
// 198:       # @overload delay_on(default_executor, *args, &task)
// 199:       #   If task is provided it returns a {Future} representing the result of the task.
// 200:       #   @!macro promises.param.args
// 201:       #   @yield [*args] to the task.
// 202:       #   @!macro promise.param.task-future
// 203:       #   @return [Future]
// 204:       # @overload delay_on(default_executor)
// 205:       #   If no task is provided, it returns an {Event}
// 206:       #   @return [Event]
// 207:       def delay_on(default_executor, *args, &task)
// 208:         event = DelayPromise.new(default_executor).event
// 209:         task ? event.chain(*args, &task) : event
// 210:       end
// 211:
// 212:       # @!macro promises.shortcut.on
// 213:       # @return [Future, Event]
// 214:       def schedule(intended_time, *args, &task)
// 215:         schedule_on default_executor, intended_time, *args, &task
// 216:       end
// 217:
// 218:       # Creates a new event or future which is resolved in intended_time.
// 219:       #
// 220:       # @!macro promises.param.default_executor
// 221:       # @!macro promises.param.intended_time
// 222:       #   @param [Numeric, Time] intended_time `Numeric` means to run in `intended_time` seconds.
// 223:       #     `Time` means to run on `intended_time`.
// 224:       # @overload schedule_on(default_executor, intended_time, *args, &task)
// 225:       #   If task is provided it returns a {Future} representing the result of the task.
// 226:       #   @!macro promises.param.args
// 227:       #   @yield [*args] to the task.
// 228:       #   @!macro promise.param.task-future
// 229:       #   @return [Future]
// 230:       # @overload schedule_on(default_executor, intended_time)
// 231:       #   If no task is provided, it returns an {Event}
// 232:       #   @return [Event]
// 233:       def schedule_on(default_executor, intended_time, *args, &task)
// 234:         event = ScheduledPromise.new(default_executor, intended_time).event
// 235:         task ? event.chain(*args, &task) : event
// 236:       end
// 237:
// 238:       # @!macro promises.shortcut.on
// 239:       # @return [Future]
// 240:       def zip_futures(*futures_and_or_events)
// 241:         zip_futures_on default_executor, *futures_and_or_events
// 242:       end
// 243:
// 244:       # Creates a new future which is resolved after all futures_and_or_events are resolved.
// 245:       # Its value is an array of zipped future values. Its reason is an array of reasons for rejection.
// 246:       # If there is an error it rejects.
// 247:       # @!macro promises.event-conversion
// 248:       #   If event is supplied, which does not have value and can be only resolved, it's
// 249:       #   represented as `:fulfilled` with value `nil`.
// 250:       #
// 251:       # @!macro promises.param.default_executor
// 252:       # @param [AbstractEventFuture] futures_and_or_events
// 253:       # @return [Future]
// 254:       def zip_futures_on(default_executor, *futures_and_or_events)
// 255:         ZipFuturesPromise.new_blocked_by(futures_and_or_events, default_executor).future
// 256:       end
// 257:
// 258:       alias_method :zip, :zip_futures
// 259:
// 260:       # @!macro promises.shortcut.on
// 261:       # @return [Event]
// 262:       def zip_events(*futures_and_or_events)
// 263:         zip_events_on default_executor, *futures_and_or_events
// 264:       end
// 265:
// 266:       # Creates a new event which is resolved after all futures_and_or_events are resolved.
// 267:       # (Future is resolved when fulfilled or rejected.)
// 268:       #
// 269:       # @!macro promises.param.default_executor
// 270:       # @param [AbstractEventFuture] futures_and_or_events
// 271:       # @return [Event]
// 272:       def zip_events_on(default_executor, *futures_and_or_events)
// 273:         ZipEventsPromise.new_blocked_by(futures_and_or_events, default_executor).event
// 274:       end
// 275:
// 276:       # @!macro promises.shortcut.on
// 277:       # @return [Future]
// 278:       def any_resolved_future(*futures_and_or_events)
// 279:         any_resolved_future_on default_executor, *futures_and_or_events
// 280:       end
// 281:
// 282:       alias_method :any, :any_resolved_future
// 283:
// 284:       # Creates a new future which is resolved after the first futures_and_or_events is resolved.
// 285:       # Its result equals the result of the first resolved future.
// 286:       # @!macro promises.any-touch
// 287:       #   If resolved it does not propagate {Concurrent::AbstractEventFuture#touch}, leaving delayed
// 288:       #   futures un-executed if they are not required any more.
// 289:       # @!macro promises.event-conversion
// 290:       #
// 291:       # @!macro promises.param.default_executor
// 292:       # @param [AbstractEventFuture] futures_and_or_events
// 293:       # @return [Future]
// 294:       def any_resolved_future_on(default_executor, *futures_and_or_events)
// 295:         AnyResolvedFuturePromise.new_blocked_by(futures_and_or_events, default_executor).future
// 296:       end
// 297:
// 298:       # @!macro promises.shortcut.on
// 299:       # @return [Future]
// 300:       def any_fulfilled_future(*futures_and_or_events)
// 301:         any_fulfilled_future_on default_executor, *futures_and_or_events
// 302:       end
// 303:
// 304:       # Creates a new future which is resolved after the first futures_and_or_events is fulfilled.
// 305:       # Its result equals the result of the first resolved future or if all futures_and_or_events reject,
// 306:       # it has reason of the last rejected future.
// 307:       # @!macro promises.any-touch
// 308:       # @!macro promises.event-conversion
// 309:       #
// 310:       # @!macro promises.param.default_executor
// 311:       # @param [AbstractEventFuture] futures_and_or_events
// 312:       # @return [Future]
// 313:       def any_fulfilled_future_on(default_executor, *futures_and_or_events)
// 314:         AnyFulfilledFuturePromise.new_blocked_by(futures_and_or_events, default_executor).future
// 315:       end
// 316:
// 317:       # @!macro promises.shortcut.on
// 318:       # @return [Event]
// 319:       def any_event(*futures_and_or_events)
// 320:         any_event_on default_executor, *futures_and_or_events
// 321:       end
// 322:
// 323:       # Creates a new event which becomes resolved after the first futures_and_or_events resolves.
// 324:       # @!macro promises.any-touch
// 325:       #
// 326:       # @!macro promises.param.default_executor
// 327:       # @param [AbstractEventFuture] futures_and_or_events
// 328:       # @return [Event]
// 329:       def any_event_on(default_executor, *futures_and_or_events)
// 330:         AnyResolvedEventPromise.new_blocked_by(futures_and_or_events, default_executor).event
// 331:       end
// 332:
// 333:       # TODO consider adding first(count, *futures)
// 334:       # TODO consider adding zip_by(slice, *futures) processing futures in slices
// 335:       # TODO or rather a generic aggregator taking a function
// 336:     end
// 337:
// 338:     module InternalStates
// 339:       # @!visibility private
// 340:       class State
// 341:         def resolved?
// 342:           raise NotImplementedError
// 343:         end
// 344:
// 345:         def to_sym
// 346:           raise NotImplementedError
// 347:         end
// 348:       end
// 349:
// 350:       # @!visibility private
// 351:       class Pending < State
// 352:         def resolved?
// 353:           false
// 354:         end
// 355:
// 356:         def to_sym
// 357:           :pending
// 358:         end
// 359:       end
// 360:
// 361:       # @!visibility private
// 362:       class Reserved < Pending
// 363:       end
// 364:
// 365:       # @!visibility private
// 366:       class ResolvedWithResult < State
// 367:         def resolved?
// 368:           true
// 369:         end
// 370:
// 371:         def to_sym
// 372:           :resolved
// 373:         end
// 374:
// 375:         def result
// 376:           [fulfilled?, value, reason]
// 377:         end
// 378:
// 379:         def fulfilled?
// 380:           raise NotImplementedError
// 381:         end
// 382:
// 383:         def value
// 384:           raise NotImplementedError
// 385:         end
// 386:
// 387:         def reason
// 388:           raise NotImplementedError
// 389:         end
// 390:
// 391:         def apply
// 392:           raise NotImplementedError
// 393:         end
// 394:       end
// 395:
// 396:       # @!visibility private
// 397:       class Fulfilled < ResolvedWithResult
// 398:
// 399:         def initialize(value)
// 400:           @Value = value
// 401:         end
// 402:
// 403:         def fulfilled?
// 404:           true
// 405:         end
// 406:
// 407:         def apply(args, block)
// 408:           block.call value, *args
// 409:         end
// 410:
// 411:         def value
// 412:           @Value
// 413:         end
// 414:
// 415:         def reason
// 416:           nil
// 417:         end
// 418:
// 419:         def to_sym
// 420:           :fulfilled
// 421:         end
// 422:       end
// 423:
// 424:       # @!visibility private
// 425:       class FulfilledArray < Fulfilled
// 426:         def apply(args, block)
// 427:           block.call(*value, *args)
// 428:         end
// 429:       end
// 430:
// 431:       # @!visibility private
// 432:       class Rejected < ResolvedWithResult
// 433:         def initialize(reason)
// 434:           @Reason = reason
// 435:         end
// 436:
// 437:         def fulfilled?
// 438:           false
// 439:         end
// 440:
// 441:         def value
// 442:           nil
// 443:         end
// 444:
// 445:         def reason
// 446:           @Reason
// 447:         end
// 448:
// 449:         def to_sym
// 450:           :rejected
// 451:         end
// 452:
// 453:         def apply(args, block)
// 454:           block.call reason, *args
// 455:         end
// 456:       end
// 457:
// 458:       # @!visibility private
// 459:       class PartiallyRejected < ResolvedWithResult
// 460:         def initialize(value, reason)
// 461:           super()
// 462:           @Value  = value
// 463:           @Reason = reason
// 464:         end
// 465:
// 466:         def fulfilled?
// 467:           false
// 468:         end
// 469:
// 470:         def to_sym
// 471:           :rejected
// 472:         end
// 473:
// 474:         def value
// 475:           @Value
// 476:         end
// 477:
// 478:         def reason
// 479:           @Reason
// 480:         end
// 481:
// 482:         def apply(args, block)
// 483:           block.call(*reason, *args)
// 484:         end
// 485:       end
// 486:
// 487:       # @!visibility private
// 488:       PENDING = Pending.new
// 489:       # @!visibility private
// 490:       RESERVED = Reserved.new
// 491:       # @!visibility private
// 492:       RESOLVED = Fulfilled.new(nil)
// 493:
// 494:       def RESOLVED.to_sym
// 495:         :resolved
// 496:       end
// 497:     end
// 498:
// 499:     private_constant :InternalStates
// 500:
// 501:     # @!macro promises.shortcut.event-future
// 502:     #   @see Event#$0
// 503:     #   @see Future#$0
// 504:
// 505:     # @!macro promises.param.timeout
// 506:     #   @param [Numeric] timeout the maximum time in second to wait.
// 507:
// 508:     # @!macro promises.warn.blocks
// 509:     #   @note This function potentially blocks current thread until the Future is resolved.
// 510:     #     Be careful it can deadlock. Try to chain instead.
// 511:
// 512:     # Common ancestor of {Event} and {Future} classes, many shared methods are defined here.
// 513:     class AbstractEventFuture < Synchronization::Object
// 514:       safe_initialization!
// 515:       attr_atomic(:internal_state)
// 516:       private :internal_state=, :swap_internal_state, :compare_and_set_internal_state, :update_internal_state
// 517:       # @!method internal_state
// 518:       #   @!visibility private
// 519:
// 520:       include InternalStates
// 521:
// 522:       def initialize(promise, default_executor)
// 523:         super()
// 524:         @Lock               = Mutex.new
// 525:         @Condition          = ConditionVariable.new
// 526:         @Promise            = promise
// 527:         @DefaultExecutor    = default_executor
// 528:         @Callbacks          = LockFreeStack.new
// 529:         @Waiters            = AtomicFixnum.new 0
// 530:         self.internal_state = PENDING
// 531:       end
// 532:
// 533:       private :initialize
// 534:
// 535:       # Returns its state.
// 536:       # @return [Symbol]
// 537:       #
// 538:       # @overload an_event.state
// 539:       #   @return [:pending, :resolved]
// 540:       # @overload a_future.state
// 541:       #   Both :fulfilled, :rejected implies :resolved.
// 542:       #   @return [:pending, :fulfilled, :rejected]
// 543:       def state
// 544:         internal_state.to_sym
// 545:       end
// 546:
// 547:       # Is it in pending state?
// 548:       # @return [Boolean]
// 549:       def pending?
// 550:         !internal_state.resolved?
// 551:       end
// 552:
// 553:       # Is it in resolved state?
// 554:       # @return [Boolean]
// 555:       def resolved?
// 556:         internal_state.resolved?
// 557:       end
// 558:
// 559:       # Propagates touch. Requests all the delayed futures, which it depends on, to be
// 560:       # executed. This method is called by any other method requiring resolved state, like {#wait}.
// 561:       # @return [self]
// 562:       def touch
// 563:         @Promise.touch
// 564:         self
// 565:       end
// 566:
// 567:       # @!macro promises.touches
// 568:       #   Calls {Concurrent::AbstractEventFuture#touch}.
// 569:
// 570:       # @!macro promises.method.wait
// 571:       #   Wait (block the Thread) until receiver is {#resolved?}.
// 572:       #   @!macro promises.touches
// 573:       #
// 574:       #   @!macro promises.warn.blocks
// 575:       #   @!macro promises.param.timeout
// 576:       #   @return [self, true, false] self implies timeout was not used, true implies timeout was used
// 577:       #     and it was resolved, false implies it was not resolved within timeout.
// 578:       def wait(timeout = nil)
// 579:         result = wait_until_resolved(timeout)
// 580:         timeout ? result : self
// 581:       end
// 582:
// 583:       # Returns default executor.
// 584:       # @return [Executor] default executor
// 585:       # @see #with_default_executor
// 586:       # @see FactoryMethods#future_on
// 587:       # @see FactoryMethods#resolvable_future
// 588:       # @see FactoryMethods#any_fulfilled_future_on
// 589:       # @see similar
// 590:       def default_executor
// 591:         @DefaultExecutor
// 592:       end
// 593:
// 594:       # @!macro promises.shortcut.on
// 595:       # @return [Future]
// 596:       def chain(*args, &task)
// 597:         chain_on @DefaultExecutor, *args, &task
// 598:       end
// 599:
// 600:       # Chains the task to be executed asynchronously on executor after it is resolved.
// 601:       #
// 602:       # @!macro promises.param.executor
// 603:       # @!macro promises.param.args
// 604:       # @return [Future]
// 605:       # @!macro promise.param.task-future
// 606:       #
// 607:       # @overload an_event.chain_on(executor, *args, &task)
// 608:       #   @yield [*args] to the task.
// 609:       # @overload a_future.chain_on(executor, *args, &task)
// 610:       #   @yield [fulfilled, value, reason, *args] to the task.
// 611:       #   @yieldparam [true, false] fulfilled
// 612:       #   @yieldparam [Object] value
// 613:       #   @yieldparam [Object] reason
// 614:       def chain_on(executor, *args, &task)
// 615:         ChainPromise.new_blocked_by1(self, executor, executor, args, &task).future
// 616:       end
// 617:
// 618:       # @return [String] Short string representation.
// 619:       def to_s
// 620:         format '%s %s>', super[0..-2], state
// 621:       end
// 622:
// 623:       alias_method :inspect, :to_s
// 624:
// 625:       # Resolves the resolvable when receiver is resolved.
// 626:       #
// 627:       # @param [Resolvable] resolvable
// 628:       # @return [self]
// 629:       def chain_resolvable(resolvable)
// 630:         on_resolution! { resolvable.resolve_with internal_state }
// 631:       end
// 632:
// 633:       alias_method :tangle, :chain_resolvable
// 634:
// 635:       # @!macro promises.shortcut.using
// 636:       # @return [self]
// 637:       def on_resolution(*args, &callback)
// 638:         on_resolution_using @DefaultExecutor, *args, &callback
// 639:       end
// 640:
// 641:       # Stores the callback to be executed synchronously on resolving thread after it is
// 642:       # resolved.
// 643:       #
// 644:       # @!macro promises.param.args
// 645:       # @!macro promise.param.callback
// 646:       # @return [self]
// 647:       #
// 648:       # @overload an_event.on_resolution!(*args, &callback)
// 649:       #   @yield [*args] to the callback.
// 650:       # @overload a_future.on_resolution!(*args, &callback)
// 651:       #   @yield [fulfilled, value, reason, *args] to the callback.
// 652:       #   @yieldparam [true, false] fulfilled
// 653:       #   @yieldparam [Object] value
// 654:       #   @yieldparam [Object] reason
// 655:       def on_resolution!(*args, &callback)
// 656:         add_callback :callback_on_resolution, args, callback
// 657:       end
// 658:
// 659:       # Stores the callback to be executed asynchronously on executor after it is resolved.
// 660:       #
// 661:       # @!macro promises.param.executor
// 662:       # @!macro promises.param.args
// 663:       # @!macro promise.param.callback
// 664:       # @return [self]
// 665:       #
// 666:       # @overload an_event.on_resolution_using(executor, *args, &callback)
// 667:       #   @yield [*args] to the callback.
// 668:       # @overload a_future.on_resolution_using(executor, *args, &callback)
// 669:       #   @yield [fulfilled, value, reason, *args] to the callback.
// 670:       #   @yieldparam [true, false] fulfilled
// 671:       #   @yieldparam [Object] value
// 672:       #   @yieldparam [Object] reason
// 673:       def on_resolution_using(executor, *args, &callback)
// 674:         add_callback :async_callback_on_resolution, executor, args, callback
// 675:       end
// 676:
// 677:       # @!macro promises.method.with_default_executor
// 678:       #   Crates new object with same class with the executor set as its new default executor.
// 679:       #   Any futures depending on it will use the new default executor.
// 680:       # @!macro promises.shortcut.event-future
// 681:       # @abstract
// 682:       # @return [AbstractEventFuture]
// 683:       def with_default_executor(executor)
// 684:         raise NotImplementedError
// 685:       end
// 686:
// 687:       # @!visibility private
// 688:       def resolve_with(state, raise_on_reassign = true, reserved = false)
// 689:         if compare_and_set_internal_state(reserved ? RESERVED : PENDING, state)
// 690:           # go to synchronized block only if there were waiting threads
// 691:           @Lock.synchronize { @Condition.broadcast } unless @Waiters.value == 0
// 692:           call_callbacks state
// 693:         else
// 694:           return rejected_resolution(raise_on_reassign, state)
// 695:         end
// 696:         self
// 697:       end
// 698:
// 699:       # For inspection.
// 700:       # @!visibility private
// 701:       # @return [Array<AbstractPromise>]
// 702:       def blocks
// 703:         @Callbacks.each_with_object([]) do |(method, args), promises|
// 704:           promises.push(args[0]) if method == :callback_notify_blocked
// 705:         end
// 706:       end
// 707:
// 708:       # For inspection.
// 709:       # @!visibility private
// 710:       def callbacks
// 711:         @Callbacks.each.to_a
// 712:       end
// 713:
// 714:       # For inspection.
// 715:       # @!visibility private
// 716:       def promise
// 717:         @Promise
// 718:       end
// 719:
// 720:       # For inspection.
// 721:       # @!visibility private
// 722:       def touched?
// 723:         promise.touched?
// 724:       end
// 725:
// 726:       # For inspection.
// 727:       # @!visibility private
// 728:       def waiting_threads
// 729:         @Waiters.each.to_a
// 730:       end
// 731:
// 732:       # @!visibility private
// 733:       def add_callback_notify_blocked(promise, index)
// 734:         add_callback :callback_notify_blocked, promise, index
// 735:       end
// 736:
// 737:       # @!visibility private
// 738:       def add_callback_clear_delayed_node(node)
// 739:         add_callback(:callback_clear_delayed_node, node)
// 740:       end
// 741:
// 742:       # @!visibility private
// 743:       def with_hidden_resolvable
// 744:         # TODO (pitr-ch 10-Dec-2018): documentation, better name if in edge
// 745:         self
// 746:       end
// 747:
// 748:       private
// 749:
// 750:       def add_callback(method, *args)
// 751:         state = internal_state
// 752:         if state.resolved?
// 753:           call_callback method, state, args
// 754:         else
// 755:           @Callbacks.push [method, args]
// 756:           state = internal_state
// 757:           # take back if it was resolved in the meanwhile
// 758:           call_callbacks state if state.resolved?
// 759:         end
// 760:         self
// 761:       end
// 762:
// 763:       def callback_clear_delayed_node(state, node)
// 764:         node.value = nil
// 765:       end
// 766:
// 767:       # @return [Boolean]
// 768:       def wait_until_resolved(timeout)
// 769:         return true if resolved?
// 770:
// 771:         touch
// 772:
// 773:         @Lock.synchronize do
// 774:           @Waiters.increment
// 775:           begin
// 776:             if timeout
// 777:               start = Concurrent.monotonic_time
// 778:               until resolved?
// 779:                 break if @Condition.wait(@Lock, timeout) == nil # nil means timeout
// 780:                 timeout -= (Concurrent.monotonic_time - start)
// 781:                 break if timeout <= 0
// 782:               end
// 783:             else
// 784:               until resolved?
// 785:                 @Condition.wait(@Lock, timeout)
// 786:               end
// 787:             end
// 788:           ensure
// 789:             # JRuby may raise ConcurrencyError
// 790:             @Waiters.decrement
// 791:           end
// 792:         end
// 793:         resolved?
// 794:       end
// 795:
// 796:       def call_callback(method, state, args)
// 797:         self.send method, state, *args
// 798:       end
// 799:
// 800:       def call_callbacks(state)
// 801:         method, args = @Callbacks.pop
// 802:         while method
// 803:           call_callback method, state, args
// 804:           method, args = @Callbacks.pop
// 805:         end
// 806:       end
// 807:
// 808:       def with_async(executor, *args, &block)
// 809:         Concurrent.executor(executor).post(*args, &block)
// 810:       end
// 811:
// 812:       def async_callback_on_resolution(state, executor, args, callback)
// 813:         with_async(executor, state, args, callback) do |st, ar, cb|
// 814:           callback_on_resolution st, ar, cb
// 815:         end
// 816:       end
// 817:
// 818:       def callback_notify_blocked(state, promise, index)
// 819:         promise.on_blocker_resolution self, index
// 820:       end
// 821:     end
// 822:
// 823:     # Represents an event which will happen in future (will be resolved). The event is either
// 824:     # pending or resolved. It should be always resolved. Use {Future} to communicate rejections and
// 825:     # cancellation.
// 826:     class Event < AbstractEventFuture
// 827:
// 828:       alias_method :then, :chain
// 829:
// 830:
// 831:       # @!macro promises.method.zip
// 832:       #   Creates a new event or a future which will be resolved when receiver and other are.
// 833:       #   Returns an event if receiver and other are events, otherwise returns a future.
// 834:       #   If just one of the parties is Future then the result
// 835:       #   of the returned future is equal to the result of the supplied future. If both are futures
// 836:       #   then the result is as described in {FactoryMethods#zip_futures_on}.
// 837:       #
// 838:       # @return [Future, Event]
// 839:       def zip(other)
// 840:         if other.is_a?(Future)
// 841:           ZipFutureEventPromise.new_blocked_by2(other, self, @DefaultExecutor).future
// 842:         else
// 843:           ZipEventEventPromise.new_blocked_by2(self, other, @DefaultExecutor).event
// 844:         end
// 845:       end
// 846:
// 847:       alias_method :&, :zip
// 848:
// 849:       # Creates a new event which will be resolved when the first of receiver, `event_or_future`
// 850:       # resolves.
// 851:       #
// 852:       # @return [Event]
// 853:       def any(event_or_future)
// 854:         AnyResolvedEventPromise.new_blocked_by2(self, event_or_future, @DefaultExecutor).event
// 855:       end
// 856:
// 857:       alias_method :|, :any
// 858:
// 859:       # Creates new event dependent on receiver which will not evaluate until touched, see {#touch}.
// 860:       # In other words, it inserts delay into the chain of Futures making rest of it lazy evaluated.
// 861:       #
// 862:       # @return [Event]
// 863:       def delay
// 864:         event = DelayPromise.new(@DefaultExecutor).event
// 865:         ZipEventEventPromise.new_blocked_by2(self, event, @DefaultExecutor).event
// 866:       end
// 867:
// 868:       # @!macro promise.method.schedule
// 869:       #   Creates new event dependent on receiver scheduled to execute on/in intended_time.
// 870:       #   In time is interpreted from the moment the receiver is resolved, therefore it inserts
// 871:       #   delay into the chain.
// 872:       #
// 873:       #   @!macro promises.param.intended_time
// 874:       # @return [Event]
// 875:       def schedule(intended_time)
// 876:         chain do
// 877:           event = ScheduledPromise.new(@DefaultExecutor, intended_time).event
// 878:           ZipEventEventPromise.new_blocked_by2(self, event, @DefaultExecutor).event
// 879:         end.flat_event
// 880:       end
// 881:
// 882:       # Converts event to a future. The future is fulfilled when the event is resolved, the future may never fail.
// 883:       #
// 884:       # @return [Future]
// 885:       def to_future
// 886:         future = Promises.resolvable_future
// 887:       ensure
// 888:         chain_resolvable(future)
// 889:       end
// 890:
// 891:       # Returns self, since this is event
// 892:       # @return [Event]
// 893:       def to_event
// 894:         self
// 895:       end
// 896:
// 897:       # @!macro promises.method.with_default_executor
// 898:       # @return [Event]
// 899:       def with_default_executor(executor)
// 900:         EventWrapperPromise.new_blocked_by1(self, executor).event
// 901:       end
// 902:
// 903:       private
// 904:
// 905:       def rejected_resolution(raise_on_reassign, state)
// 906:         raise Concurrent::MultipleAssignmentError.new('Event can be resolved only once') if raise_on_reassign
// 907:         return false
// 908:       end
// 909:
// 910:       def callback_on_resolution(state, args, callback)
// 911:         callback.call(*args)
// 912:       end
// 913:     end
// 914:
// 915:     # Represents a value which will become available in future. May reject with a reason instead,
// 916:     # e.g. when the tasks raises an exception.
// 917:     class Future < AbstractEventFuture
// 918:       SET_BACKTRACE_LOCATIONS_SUPPORTED = RUBY_VERSION >= '3.4'
// 919:
// 920:       # Is it in fulfilled state?
// 921:       # @return [Boolean]
// 922:       def fulfilled?
// 923:         state = internal_state
// 924:         state.resolved? && state.fulfilled?
// 925:       end
// 926:
// 927:       # Is it in rejected state?
// 928:       # @return [Boolean]
// 929:       def rejected?
// 930:         state = internal_state
// 931:         state.resolved? && !state.fulfilled?
// 932:       end
// 933:
// 934:       # @!macro promises.warn.nil
// 935:       #   @note Make sure returned `nil` is not confused with timeout, no value when rejected,
// 936:       #     no reason when fulfilled, etc.
// 937:       #     Use more exact methods if needed, like {#wait}, {#value!}, {#result}, etc.
// 938:
// 939:       # @!macro promises.method.value
// 940:       #   Return value of the future.
// 941:       #   @!macro promises.touches
// 942:       #
// 943:       #   @!macro promises.warn.blocks
// 944:       #   @!macro promises.warn.nil
// 945:       #   @!macro promises.param.timeout
// 946:       #   @!macro promises.param.timeout_value
// 947:       #     @param [Object] timeout_value a value returned by the method when it times out
// 948:       # @return [Object, nil, timeout_value] the value of the Future when fulfilled,
// 949:       #   timeout_value on timeout,
// 950:       #   nil on rejection.
// 951:       def value(timeout = nil, timeout_value = nil)
// 952:         if wait_until_resolved timeout
// 953:           internal_state.value
// 954:         else
// 955:           timeout_value
// 956:         end
// 957:       end
// 958:
// 959:       # Returns reason of future's rejection.
// 960:       # @!macro promises.touches
// 961:       #
// 962:       # @!macro promises.warn.blocks
// 963:       # @!macro promises.warn.nil
// 964:       # @!macro promises.param.timeout
// 965:       # @!macro promises.param.timeout_value
// 966:       # @return [Object, timeout_value] the reason, or timeout_value on timeout, or nil on fulfillment.
// 967:       def reason(timeout = nil, timeout_value = nil)
// 968:         if wait_until_resolved timeout
// 969:           internal_state.reason
// 970:         else
// 971:           timeout_value
// 972:         end
// 973:       end
// 974:
// 975:       # Returns triplet fulfilled?, value, reason.
// 976:       # @!macro promises.touches
// 977:       #
// 978:       # @!macro promises.warn.blocks
// 979:       # @!macro promises.param.timeout
// 980:       # @return [Array(Boolean, Object, Object), nil] triplet of fulfilled?, value, reason, or nil
// 981:       #   on timeout.
// 982:       def result(timeout = nil)
// 983:         internal_state.result if wait_until_resolved timeout
// 984:       end
// 985:
// 986:       # @!macro promises.method.wait
// 987:       # @raise [Exception] {#reason} on rejection
// 988:       def wait!(timeout = nil)
// 989:         result = wait_until_resolved!(timeout)
// 990:         timeout ? result : self
// 991:       end
// 992:
// 993:       # @!macro promises.method.value
// 994:       # @return [Object, nil, timeout_value] the value of the Future when fulfilled,
// 995:       #   or nil on rejection,
// 996:       #   or timeout_value on timeout.
// 997:       # @raise [Exception] {#reason} on rejection
// 998:       def value!(timeout = nil, timeout_value = nil)
// 999:         if wait_until_resolved! timeout
// 1000:           internal_state.value
// 1001:         else
// 1002:           timeout_value
// 1003:         end
// 1004:       end
// 1005:
// 1006:       # Allows rejected Future to be risen with `raise` method.
// 1007:       # If the reason is not an exception `Runtime.new(reason)` is returned.
// 1008:       #
// 1009:       # @example
// 1010:       #   raise Promises.rejected_future(StandardError.new("boom"))
// 1011:       #   raise Promises.rejected_future("or just boom")
// 1012:       # @raise [Concurrent::Error] when raising not rejected future
// 1013:       # @return [Exception]
// 1014:       def exception(*args)
// 1015:         raise Concurrent::Error, 'it is not rejected' unless rejected?
// 1016:         raise ArgumentError unless args.size <= 1
// 1017:         reason = Array(internal_state.reason).flatten.compact
// 1018:         callsites = SET_BACKTRACE_LOCATIONS_SUPPORTED ? caller_locations : caller
// 1019:         if reason.size > 1
// 1020:           ex = Concurrent::MultipleErrors.new reason
// 1021:           ex.set_backtrace(callsites)
// 1022:           ex
// 1023:         else
// 1024:           ex = if reason[0].respond_to? :exception
// 1025:                  reason[0].exception(*args)
// 1026:                else
// 1027:                  RuntimeError.new(reason[0]).exception(*args)
// 1028:                end
// 1029:           if SET_BACKTRACE_LOCATIONS_SUPPORTED && (locations = ex.backtrace_locations)
// 1030:             ex.set_backtrace locations + callsites
// 1031:           else
// 1032:             ex.set_backtrace Array(ex.backtrace) + callsites.map(&:to_s)
// 1033:           end
// 1034:           ex
// 1035:         end
// 1036:       end
// 1037:
// 1038:       # @!macro promises.shortcut.on
// 1039:       # @return [Future]
// 1040:       def then(*args, &task)
// 1041:         then_on @DefaultExecutor, *args, &task
// 1042:       end
// 1043:
// 1044:       # Chains the task to be executed asynchronously on executor after it fulfills. Does not run
// 1045:       # the task if it rejects. It will resolve though, triggering any dependent futures.
// 1046:       #
// 1047:       # @!macro promises.param.executor
// 1048:       # @!macro promises.param.args
// 1049:       # @!macro promise.param.task-future
// 1050:       # @return [Future]
// 1051:       # @yield [value, *args] to the task.
// 1052:       def then_on(executor, *args, &task)
// 1053:         ThenPromise.new_blocked_by1(self, executor, executor, args, &task).future
// 1054:       end
// 1055:
// 1056:       # @!macro promises.shortcut.on
// 1057:       # @return [Future]
// 1058:       def rescue(*args, &task)
// 1059:         rescue_on @DefaultExecutor, *args, &task
// 1060:       end
// 1061:
// 1062:       # Chains the task to be executed asynchronously on executor after it rejects. Does not run
// 1063:       # the task if it fulfills. It will resolve though, triggering any dependent futures.
// 1064:       #
// 1065:       # @!macro promises.param.executor
// 1066:       # @!macro promises.param.args
// 1067:       # @!macro promise.param.task-future
// 1068:       # @return [Future]
// 1069:       # @yield [reason, *args] to the task.
// 1070:       def rescue_on(executor, *args, &task)
// 1071:         RescuePromise.new_blocked_by1(self, executor, executor, args, &task).future
// 1072:       end
// 1073:
// 1074:       # @!macro promises.method.zip
// 1075:       # @return [Future]
// 1076:       def zip(other)
// 1077:         if other.is_a?(Future)
// 1078:           ZipFuturesPromise.new_blocked_by2(self, other, @DefaultExecutor).future
// 1079:         else
// 1080:           ZipFutureEventPromise.new_blocked_by2(self, other, @DefaultExecutor).future
// 1081:         end
// 1082:       end
// 1083:
// 1084:       alias_method :&, :zip
// 1085:
// 1086:       # Creates a new event which will be resolved when the first of receiver, `event_or_future`
// 1087:       # resolves. Returning future will have value nil if event_or_future is event and resolves
// 1088:       # first.
// 1089:       #
// 1090:       # @return [Future]
// 1091:       def any(event_or_future)
// 1092:         AnyResolvedFuturePromise.new_blocked_by2(self, event_or_future, @DefaultExecutor).future
// 1093:       end
// 1094:
// 1095:       alias_method :|, :any
// 1096:
// 1097:       # Creates new future dependent on receiver which will not evaluate until touched, see {#touch}.
// 1098:       # In other words, it inserts delay into the chain of Futures making rest of it lazy evaluated.
// 1099:       #
// 1100:       # @return [Future]
// 1101:       def delay
// 1102:         event = DelayPromise.new(@DefaultExecutor).event
// 1103:         ZipFutureEventPromise.new_blocked_by2(self, event, @DefaultExecutor).future
// 1104:       end
// 1105:
// 1106:       # @!macro promise.method.schedule
// 1107:       # @return [Future]
// 1108:       def schedule(intended_time)
// 1109:         chain do
// 1110:           event = ScheduledPromise.new(@DefaultExecutor, intended_time).event
// 1111:           ZipFutureEventPromise.new_blocked_by2(self, event, @DefaultExecutor).future
// 1112:         end.flat
// 1113:       end
// 1114:
// 1115:       # @!macro promises.method.with_default_executor
// 1116:       # @return [Future]
// 1117:       def with_default_executor(executor)
// 1118:         FutureWrapperPromise.new_blocked_by1(self, executor).future
// 1119:       end
// 1120:
// 1121:       # Creates new future which will have result of the future returned by receiver. If receiver
// 1122:       # rejects it will have its rejection.
// 1123:       #
// 1124:       # @param [Integer] level how many levels of futures should flatten
// 1125:       # @return [Future]
// 1126:       def flat_future(level = 1)
// 1127:         FlatFuturePromise.new_blocked_by1(self, level, @DefaultExecutor).future
// 1128:       end
// 1129:
// 1130:       alias_method :flat, :flat_future
// 1131:
// 1132:       # Creates new event which will be resolved when the returned event by receiver is.
// 1133:       # Be careful if the receiver rejects it will just resolve since Event does not hold reason.
// 1134:       #
// 1135:       # @return [Event]
// 1136:       def flat_event
// 1137:         FlatEventPromise.new_blocked_by1(self, @DefaultExecutor).event
// 1138:       end
// 1139:
// 1140:       # @!macro promises.shortcut.using
// 1141:       # @return [self]
// 1142:       def on_fulfillment(*args, &callback)
// 1143:         on_fulfillment_using @DefaultExecutor, *args, &callback
// 1144:       end
// 1145:
// 1146:       # Stores the callback to be executed synchronously on resolving thread after it is
// 1147:       # fulfilled. Does nothing on rejection.
// 1148:       #
// 1149:       # @!macro promises.param.args
// 1150:       # @!macro promise.param.callback
// 1151:       # @return [self]
// 1152:       # @yield [value, *args] to the callback.
// 1153:       def on_fulfillment!(*args, &callback)
// 1154:         add_callback :callback_on_fulfillment, args, callback
// 1155:       end
// 1156:
// 1157:       # Stores the callback to be executed asynchronously on executor after it is
// 1158:       # fulfilled. Does nothing on rejection.
// 1159:       #
// 1160:       # @!macro promises.param.executor
// 1161:       # @!macro promises.param.args
// 1162:       # @!macro promise.param.callback
// 1163:       # @return [self]
// 1164:       # @yield [value, *args] to the callback.
// 1165:       def on_fulfillment_using(executor, *args, &callback)
// 1166:         add_callback :async_callback_on_fulfillment, executor, args, callback
// 1167:       end
// 1168:
// 1169:       # @!macro promises.shortcut.using
// 1170:       # @return [self]
// 1171:       def on_rejection(*args, &callback)
// 1172:         on_rejection_using @DefaultExecutor, *args, &callback
// 1173:       end
// 1174:
// 1175:       # Stores the callback to be executed synchronously on resolving thread after it is
// 1176:       # rejected. Does nothing on fulfillment.
// 1177:       #
// 1178:       # @!macro promises.param.args
// 1179:       # @!macro promise.param.callback
// 1180:       # @return [self]
// 1181:       # @yield [reason, *args] to the callback.
// 1182:       def on_rejection!(*args, &callback)
// 1183:         add_callback :callback_on_rejection, args, callback
// 1184:       end
// 1185:
// 1186:       # Stores the callback to be executed asynchronously on executor after it is
// 1187:       # rejected. Does nothing on fulfillment.
// 1188:       #
// 1189:       # @!macro promises.param.executor
// 1190:       # @!macro promises.param.args
// 1191:       # @!macro promise.param.callback
// 1192:       # @return [self]
// 1193:       # @yield [reason, *args] to the callback.
// 1194:       def on_rejection_using(executor, *args, &callback)
// 1195:         add_callback :async_callback_on_rejection, executor, args, callback
// 1196:       end
// 1197:
// 1198:       # Allows to use futures as green threads. The receiver has to evaluate to a future which
// 1199:       # represents what should be done next. It basically flattens indefinitely until non Future
// 1200:       # values is returned which becomes result of the returned future. Any encountered exception
// 1201:       # will become reason of the returned future.
// 1202:       #
// 1203:       # @return [Future]
// 1204:       # @param [#call(value)] run_test
// 1205:       #   an object which when called returns either Future to keep running with
// 1206:       #   or nil, then the run completes with the value.
// 1207:       #   The run_test can be used to extract the Future from deeper structure,
// 1208:       #   or to distinguish Future which is a resulting value from a future
// 1209:       #   which is suppose to continue running.
// 1210:       # @example
// 1211:       #   body = lambda do |v|
// 1212:       #     v += 1
// 1213:       #     v < 5 ? Promises.future(v, &body) : v
// 1214:       #   end
// 1215:       #   Promises.future(0, &body).run.value! # => 5
// 1216:       def run(run_test = method(:run_test))
// 1217:         RunFuturePromise.new_blocked_by1(self, @DefaultExecutor, run_test).future
// 1218:       end
// 1219:
// 1220:       # @!visibility private
// 1221:       def apply(args, block)
// 1222:         internal_state.apply args, block
// 1223:       end
// 1224:
// 1225:       # Converts future to event which is resolved when future is resolved by fulfillment or rejection.
// 1226:       #
// 1227:       # @return [Event]
// 1228:       def to_event
// 1229:         event = Promises.resolvable_event
// 1230:       ensure
// 1231:         chain_resolvable(event)
// 1232:       end
// 1233:
// 1234:       # Returns self, since this is a future
// 1235:       # @return [Future]
// 1236:       def to_future
// 1237:         self
// 1238:       end
// 1239:
// 1240:       # @return [String] Short string representation.
// 1241:       def to_s
// 1242:         if resolved?
// 1243:           format '%s with %s>', super[0..-2], (fulfilled? ? value : reason).inspect
// 1244:         else
// 1245:           super
// 1246:         end
// 1247:       end
// 1248:
// 1249:       alias_method :inspect, :to_s
// 1250:
// 1251:       private
// 1252:
// 1253:       def run_test(v)
// 1254:         v if v.is_a?(Future)
// 1255:       end
// 1256:
// 1257:       def rejected_resolution(raise_on_reassign, state)
// 1258:         if raise_on_reassign
// 1259:           if internal_state == RESERVED
// 1260:             raise Concurrent::MultipleAssignmentError.new(
// 1261:                 "Future can be resolved only once. It is already reserved.")
// 1262:           else
// 1263:             raise Concurrent::MultipleAssignmentError.new(
// 1264:                 "Future can be resolved only once. It's #{result}, trying to set #{state.result}.",
// 1265:                 current_result: result,
// 1266:                 new_result:     state.result)
// 1267:           end
// 1268:         end
// 1269:         return false
// 1270:       end
// 1271:
// 1272:       def wait_until_resolved!(timeout = nil)
// 1273:         result = wait_until_resolved(timeout)
// 1274:         raise self if rejected?
// 1275:         result
// 1276:       end
// 1277:
// 1278:       def async_callback_on_fulfillment(state, executor, args, callback)
// 1279:         with_async(executor, state, args, callback) do |st, ar, cb|
// 1280:           callback_on_fulfillment st, ar, cb
// 1281:         end
// 1282:       end
// 1283:
// 1284:       def async_callback_on_rejection(state, executor, args, callback)
// 1285:         with_async(executor, state, args, callback) do |st, ar, cb|
// 1286:           callback_on_rejection st, ar, cb
// 1287:         end
// 1288:       end
// 1289:
// 1290:       def callback_on_fulfillment(state, args, callback)
// 1291:         state.apply args, callback if state.fulfilled?
// 1292:       end
// 1293:
// 1294:       def callback_on_rejection(state, args, callback)
// 1295:         state.apply args, callback unless state.fulfilled?
// 1296:       end
// 1297:
// 1298:       def callback_on_resolution(state, args, callback)
// 1299:         callback.call(*state.result, *args)
// 1300:       end
// 1301:
// 1302:     end
// 1303:
// 1304:     # Marker module of Future, Event resolved manually.
// 1305:     module Resolvable
// 1306:       include InternalStates
// 1307:     end
// 1308:
// 1309:     # A Event which can be resolved by user.
// 1310:     class ResolvableEvent < Event
// 1311:       include Resolvable
// 1312:
// 1313:       # @!macro raise_on_reassign
// 1314:       # @raise [MultipleAssignmentError] when already resolved and raise_on_reassign is true.
// 1315:
// 1316:       # @!macro promise.param.raise_on_reassign
// 1317:       #   @param [Boolean] raise_on_reassign should method raise exception if already resolved
// 1318:       #   @return [self, false] false is returned when raise_on_reassign is false and the receiver
// 1319:       #     is already resolved.
// 1320:       #
// 1321:
// 1322:       # Makes the event resolved, which triggers all dependent futures.
// 1323:       #
// 1324:       # @!macro promise.param.raise_on_reassign
// 1325:       # @!macro promise.param.reserved
// 1326:       #   @param [true, false] reserved
// 1327:       #     Set to true if the resolvable is {#reserve}d by you,
// 1328:       #     marks resolution of reserved resolvable events and futures explicitly.
// 1329:       #     Advanced feature, ignore unless you use {Resolvable#reserve} from edge.
// 1330:       def resolve(raise_on_reassign = true, reserved = false)
// 1331:         resolve_with RESOLVED, raise_on_reassign, reserved
// 1332:       end
// 1333:
// 1334:       # Creates new event wrapping receiver, effectively hiding the resolve method.
// 1335:       #
// 1336:       # @return [Event]
// 1337:       def with_hidden_resolvable
// 1338:         @with_hidden_resolvable ||= EventWrapperPromise.new_blocked_by1(self, @DefaultExecutor).event
// 1339:       end
// 1340:
// 1341:       # Behaves as {AbstractEventFuture#wait} but has one additional optional argument
// 1342:       # resolve_on_timeout.
// 1343:       #
// 1344:       # @param [true, false] resolve_on_timeout
// 1345:       #   If it times out and the argument is true it will also resolve the event.
// 1346:       # @return [self, true, false]
// 1347:       # @see AbstractEventFuture#wait
// 1348:       def wait(timeout = nil, resolve_on_timeout = false)
// 1349:         super(timeout) or if resolve_on_timeout
// 1350:                             # if it fails to resolve it was resolved in the meantime
// 1351:                             # so return true as if there was no timeout
// 1352:                             !resolve(false)
// 1353:                           else
// 1354:                             false
// 1355:                           end
// 1356:       end
// 1357:     end
// 1358:
// 1359:     # A Future which can be resolved by user.
// 1360:     class ResolvableFuture < Future
// 1361:       include Resolvable
// 1362:
// 1363:       # Makes the future resolved with result of triplet `fulfilled?`, `value`, `reason`,
// 1364:       # which triggers all dependent futures.
// 1365:       #
// 1366:       # @param [true, false] fulfilled
// 1367:       # @param [Object] value
// 1368:       # @param [Object] reason
// 1369:       # @!macro promise.param.raise_on_reassign
// 1370:       # @!macro promise.param.reserved
// 1371:       def resolve(fulfilled = true, value = nil, reason = nil, raise_on_reassign = true, reserved = false)
// 1372:         resolve_with(fulfilled ? Fulfilled.new(value) : Rejected.new(reason), raise_on_reassign, reserved)
// 1373:       end
// 1374:
// 1375:       # Makes the future fulfilled with `value`,
// 1376:       # which triggers all dependent futures.
// 1377:       #
// 1378:       # @param [Object] value
// 1379:       # @!macro promise.param.raise_on_reassign
// 1380:       # @!macro promise.param.reserved
// 1381:       def fulfill(value, raise_on_reassign = true, reserved = false)
// 1382:         resolve_with Fulfilled.new(value), raise_on_reassign, reserved
// 1383:       end
// 1384:
// 1385:       # Makes the future rejected with `reason`,
// 1386:       # which triggers all dependent futures.
// 1387:       #
// 1388:       # @param [Object] reason
// 1389:       # @!macro promise.param.raise_on_reassign
// 1390:       # @!macro promise.param.reserved
// 1391:       def reject(reason, raise_on_reassign = true, reserved = false)
// 1392:         resolve_with Rejected.new(reason), raise_on_reassign, reserved
// 1393:       end
// 1394:
// 1395:       # Evaluates the block and sets its result as future's value fulfilling, if the block raises
// 1396:       # an exception the future rejects with it.
// 1397:       #
// 1398:       # @yield [*args] to the block.
// 1399:       # @yieldreturn [Object] value
// 1400:       # @return [self]
// 1401:       def evaluate_to(*args, &block)
// 1402:         promise.evaluate_to(*args, block)
// 1403:       end
// 1404:
// 1405:       # Evaluates the block and sets its result as future's value fulfilling, if the block raises
// 1406:       # an exception the future rejects with it.
// 1407:       #
// 1408:       # @yield [*args] to the block.
// 1409:       # @yieldreturn [Object] value
// 1410:       # @return [self]
// 1411:       # @raise [Exception] also raise reason on rejection.
// 1412:       def evaluate_to!(*args, &block)
// 1413:         promise.evaluate_to(*args, block).wait!
// 1414:       end
// 1415:
// 1416:       # @!macro promises.resolvable.resolve_on_timeout
// 1417:       #   @param [::Array(true, Object, nil), ::Array(false, nil, Exception), nil] resolve_on_timeout
// 1418:       #     If it times out and the argument is not nil it will also resolve the future
// 1419:       #     to the provided resolution.
// 1420:
// 1421:       # Behaves as {AbstractEventFuture#wait} but has one additional optional argument
// 1422:       # resolve_on_timeout.
// 1423:       #
// 1424:       # @!macro promises.resolvable.resolve_on_timeout
// 1425:       # @return [self, true, false]
// 1426:       # @see AbstractEventFuture#wait
// 1427:       def wait(timeout = nil, resolve_on_timeout = nil)
// 1428:         super(timeout) or if resolve_on_timeout
// 1429:                             # if it fails to resolve it was resolved in the meantime
// 1430:                             # so return true as if there was no timeout
// 1431:                             !resolve(*resolve_on_timeout, false)
// 1432:                           else
// 1433:                             false
// 1434:                           end
// 1435:       end
// 1436:
// 1437:       # Behaves as {Future#wait!} but has one additional optional argument
// 1438:       # resolve_on_timeout.
// 1439:       #
// 1440:       # @!macro promises.resolvable.resolve_on_timeout
// 1441:       # @return [self, true, false]
// 1442:       # @raise [Exception] {#reason} on rejection
// 1443:       # @see Future#wait!
// 1444:       def wait!(timeout = nil, resolve_on_timeout = nil)
// 1445:         super(timeout) or if resolve_on_timeout
// 1446:                             if resolve(*resolve_on_timeout, false)
// 1447:                               false
// 1448:                             else
// 1449:                               # if it fails to resolve it was resolved in the meantime
// 1450:                               # so return true as if there was no timeout
// 1451:                               raise self if rejected?
// 1452:                               true
// 1453:                             end
// 1454:                           else
// 1455:                             false
// 1456:                           end
// 1457:       end
// 1458:
// 1459:       # Behaves as {Future#value} but has one additional optional argument
// 1460:       # resolve_on_timeout.
// 1461:       #
// 1462:       # @!macro promises.resolvable.resolve_on_timeout
// 1463:       # @return [Object, timeout_value, nil]
// 1464:       # @see Future#value
// 1465:       def value(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)
// 1466:         if wait_until_resolved timeout
// 1467:           internal_state.value
// 1468:         else
// 1469:           if resolve_on_timeout
// 1470:             unless resolve(*resolve_on_timeout, false)
// 1471:               # if it fails to resolve it was resolved in the meantime
// 1472:               # so return value as if there was no timeout
// 1473:               return internal_state.value
// 1474:             end
// 1475:           end
// 1476:           timeout_value
// 1477:         end
// 1478:       end
// 1479:
// 1480:       # Behaves as {Future#value!} but has one additional optional argument
// 1481:       # resolve_on_timeout.
// 1482:       #
// 1483:       # @!macro promises.resolvable.resolve_on_timeout
// 1484:       # @return [Object, timeout_value, nil]
// 1485:       # @raise [Exception] {#reason} on rejection
// 1486:       # @see Future#value!
// 1487:       def value!(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)
// 1488:         if wait_until_resolved! timeout
// 1489:           internal_state.value
// 1490:         else
// 1491:           if resolve_on_timeout
// 1492:             unless resolve(*resolve_on_timeout, false)
// 1493:               # if it fails to resolve it was resolved in the meantime
// 1494:               # so return value as if there was no timeout
// 1495:               raise self if rejected?
// 1496:               return internal_state.value
// 1497:             end
// 1498:           end
// 1499:           timeout_value
// 1500:         end
// 1501:       end
// 1502:
// 1503:       # Behaves as {Future#reason} but has one additional optional argument
// 1504:       # resolve_on_timeout.
// 1505:       #
// 1506:       # @!macro promises.resolvable.resolve_on_timeout
// 1507:       # @return [Exception, timeout_value, nil]
// 1508:       # @see Future#reason
// 1509:       def reason(timeout = nil, timeout_value = nil, resolve_on_timeout = nil)
// 1510:         if wait_until_resolved timeout
// 1511:           internal_state.reason
// 1512:         else
// 1513:           if resolve_on_timeout
// 1514:             unless resolve(*resolve_on_timeout, false)
// 1515:               # if it fails to resolve it was resolved in the meantime
// 1516:               # so return value as if there was no timeout
// 1517:               return internal_state.reason
// 1518:             end
// 1519:           end
// 1520:           timeout_value
// 1521:         end
// 1522:       end
// 1523:
// 1524:       # Behaves as {Future#result} but has one additional optional argument
// 1525:       # resolve_on_timeout.
// 1526:       #
// 1527:       # @!macro promises.resolvable.resolve_on_timeout
// 1528:       # @return [::Array(Boolean, Object, Exception), nil]
// 1529:       # @see Future#result
// 1530:       def result(timeout = nil, resolve_on_timeout = nil)
// 1531:         if wait_until_resolved timeout
// 1532:           internal_state.result
// 1533:         else
// 1534:           if resolve_on_timeout
// 1535:             unless resolve(*resolve_on_timeout, false)
// 1536:               # if it fails to resolve it was resolved in the meantime
// 1537:               # so return value as if there was no timeout
// 1538:               internal_state.result
// 1539:             end
// 1540:           end
// 1541:           # otherwise returns nil
// 1542:         end
// 1543:       end
// 1544:
// 1545:       # Creates new future wrapping receiver, effectively hiding the resolve method and similar.
// 1546:       #
// 1547:       # @return [Future]
// 1548:       def with_hidden_resolvable
// 1549:         @with_hidden_resolvable ||= FutureWrapperPromise.new_blocked_by1(self, @DefaultExecutor).future
// 1550:       end
// 1551:     end
// 1552:
// 1553:     # @abstract
// 1554:     # @private
// 1555:     class AbstractPromise < Synchronization::Object
// 1556:       safe_initialization!
// 1557:       include InternalStates
// 1558:
// 1559:       def initialize(future)
// 1560:         super()
// 1561:         @Future = future
// 1562:       end
// 1563:
// 1564:       def future
// 1565:         @Future
// 1566:       end
// 1567:
// 1568:       alias_method :event, :future
// 1569:
// 1570:       def default_executor
// 1571:         future.default_executor
// 1572:       end
// 1573:
// 1574:       def state
// 1575:         future.state
// 1576:       end
// 1577:
// 1578:       def touch
// 1579:       end
// 1580:
// 1581:       def to_s
// 1582:         format '%s %s>', super[0..-2], @Future
// 1583:       end
// 1584:
// 1585:       alias_method :inspect, :to_s
// 1586:
// 1587:       def delayed_because
// 1588:         nil
// 1589:       end
// 1590:
// 1591:       private
// 1592:
// 1593:       def resolve_with(new_state, raise_on_reassign = true)
// 1594:         @Future.resolve_with(new_state, raise_on_reassign)
// 1595:       end
// 1596:
// 1597:       # @return [Future]
// 1598:       def evaluate_to(*args, block)
// 1599:         resolve_with Fulfilled.new(block.call(*args))
// 1600:       rescue Exception => error
// 1601:         resolve_with Rejected.new(error)
// 1602:         raise error unless error.is_a?(StandardError)
// 1603:       end
// 1604:     end
// 1605:
// 1606:     class ResolvableEventPromise < AbstractPromise
// 1607:       def initialize(default_executor)
// 1608:         super ResolvableEvent.new(self, default_executor)
// 1609:       end
// 1610:     end
// 1611:
// 1612:     class ResolvableFuturePromise < AbstractPromise
// 1613:       def initialize(default_executor)
// 1614:         super ResolvableFuture.new(self, default_executor)
// 1615:       end
// 1616:
// 1617:       public :evaluate_to
// 1618:     end
// 1619:
// 1620:     # @abstract
// 1621:     class InnerPromise < AbstractPromise
// 1622:     end
// 1623:
// 1624:     # @abstract
// 1625:     class BlockedPromise < InnerPromise
// 1626:
// 1627:       private_class_method :new
// 1628:
// 1629:       def self.new_blocked_by1(blocker, *args, &block)
// 1630:         blocker_delayed = blocker.promise.delayed_because
// 1631:         promise         = new(blocker_delayed, 1, *args, &block)
// 1632:         blocker.add_callback_notify_blocked promise, 0
// 1633:         promise
// 1634:       end
// 1635:
// 1636:       def self.new_blocked_by2(blocker1, blocker2, *args, &block)
// 1637:         blocker_delayed1 = blocker1.promise.delayed_because
// 1638:         blocker_delayed2 = blocker2.promise.delayed_because
// 1639:         delayed          = if blocker_delayed1 && blocker_delayed2
// 1640:                              # TODO (pitr-ch 23-Dec-2016): use arrays when we know it will not grow (only flat adds delay)
// 1641:                              LockFreeStack.of2(blocker_delayed1, blocker_delayed2)
// 1642:                            else
// 1643:                              blocker_delayed1 || blocker_delayed2
// 1644:                            end
// 1645:         promise          = new(delayed, 2, *args, &block)
// 1646:         blocker1.add_callback_notify_blocked promise, 0
// 1647:         blocker2.add_callback_notify_blocked promise, 1
// 1648:         promise
// 1649:       end
// 1650:
// 1651:       def self.new_blocked_by(blockers, *args, &block)
// 1652:         delayed = blockers.reduce(nil) { |d, f| add_delayed d, f.promise.delayed_because }
// 1653:         promise = new(delayed, blockers.size, *args, &block)
// 1654:         blockers.each_with_index { |f, i| f.add_callback_notify_blocked promise, i }
// 1655:         promise
// 1656:       end
// 1657:
// 1658:       def self.add_delayed(delayed1, delayed2)
// 1659:         if delayed1 && delayed2
// 1660:           delayed1.push delayed2
// 1661:           delayed1
// 1662:         else
// 1663:           delayed1 || delayed2
// 1664:         end
// 1665:       end
// 1666:
// 1667:       def initialize(delayed, blockers_count, future)
// 1668:         super(future)
// 1669:         @Delayed   = delayed
// 1670:         @Countdown = AtomicFixnum.new blockers_count
// 1671:       end
// 1672:
// 1673:       def on_blocker_resolution(future, index)
// 1674:         countdown  = process_on_blocker_resolution(future, index)
// 1675:         resolvable = resolvable?(countdown, future, index)
// 1676:
// 1677:         on_resolvable(future, index) if resolvable
// 1678:       end
// 1679:
// 1680:       def delayed_because
// 1681:         @Delayed
// 1682:       end
// 1683:
// 1684:       def touch
// 1685:         clear_and_propagate_touch
// 1686:       end
// 1687:
// 1688:       # for inspection only
// 1689:       def blocked_by
// 1690:         blocked_by = []
// 1691:         ObjectSpace.each_object(AbstractEventFuture) { |o| blocked_by.push o if o.blocks.include? self }
// 1692:         blocked_by
// 1693:       end
// 1694:
// 1695:       private
// 1696:
// 1697:       def clear_and_propagate_touch(stack_or_element = @Delayed)
// 1698:         return if stack_or_element.nil?
// 1699:
// 1700:         if stack_or_element.is_a? LockFreeStack
// 1701:           stack_or_element.clear_each { |element| clear_and_propagate_touch element }
// 1702:         else
// 1703:           stack_or_element.touch unless stack_or_element.nil? # if still present
// 1704:         end
// 1705:       end
// 1706:
// 1707:       # @return [true,false] if resolvable
// 1708:       def resolvable?(countdown, future, index)
// 1709:         countdown.zero?
// 1710:       end
// 1711:
// 1712:       def process_on_blocker_resolution(future, index)
// 1713:         @Countdown.decrement
// 1714:       end
// 1715:
// 1716:       def on_resolvable(resolved_future, index)
// 1717:         raise NotImplementedError
// 1718:       end
// 1719:     end
// 1720:
// 1721:     # @abstract
// 1722:     class BlockedTaskPromise < BlockedPromise
// 1723:       def initialize(delayed, blockers_count, default_executor, executor, args, &task)
// 1724:         raise ArgumentError, 'no block given' unless block_given?
// 1725:         super delayed, 1, Future.new(self, default_executor)
// 1726:         @Executor = executor
// 1727:         @Task     = task
// 1728:         @Args     = args
// 1729:       end
// 1730:
// 1731:       def executor
// 1732:         @Executor
// 1733:       end
// 1734:     end
// 1735:
// 1736:     class ThenPromise < BlockedTaskPromise
// 1737:       private
// 1738:
// 1739:       def initialize(delayed, blockers_count, default_executor, executor, args, &task)
// 1740:         super delayed, blockers_count, default_executor, executor, args, &task
// 1741:       end
// 1742:
// 1743:       def on_resolvable(resolved_future, index)
// 1744:         if resolved_future.fulfilled?
// 1745:           Concurrent.executor(@Executor).post(resolved_future, @Args, @Task) do |future, args, task|
// 1746:             evaluate_to lambda { future.apply args, task }
// 1747:           end
// 1748:         else
// 1749:           resolve_with resolved_future.internal_state
// 1750:         end
// 1751:       end
// 1752:     end
// 1753:
// 1754:     class RescuePromise < BlockedTaskPromise
// 1755:       private
// 1756:
// 1757:       def initialize(delayed, blockers_count, default_executor, executor, args, &task)
// 1758:         super delayed, blockers_count, default_executor, executor, args, &task
// 1759:       end
// 1760:
// 1761:       def on_resolvable(resolved_future, index)
// 1762:         if resolved_future.rejected?
// 1763:           Concurrent.executor(@Executor).post(resolved_future, @Args, @Task) do |future, args, task|
// 1764:             evaluate_to lambda { future.apply args, task }
// 1765:           end
// 1766:         else
// 1767:           resolve_with resolved_future.internal_state
// 1768:         end
// 1769:       end
// 1770:     end
// 1771:
// 1772:     class ChainPromise < BlockedTaskPromise
// 1773:       private
// 1774:
// 1775:       def on_resolvable(resolved_future, index)
// 1776:         if Future === resolved_future
// 1777:           Concurrent.executor(@Executor).post(resolved_future, @Args, @Task) do |future, args, task|
// 1778:             evaluate_to(*future.result, *args, task)
// 1779:           end
// 1780:         else
// 1781:           Concurrent.executor(@Executor).post(@Args, @Task) do |args, task|
// 1782:             evaluate_to(*args, task)
// 1783:           end
// 1784:         end
// 1785:       end
// 1786:     end
// 1787:
// 1788:     # will be immediately resolved
// 1789:     class ImmediateEventPromise < InnerPromise
// 1790:       def initialize(default_executor)
// 1791:         super Event.new(self, default_executor).resolve_with(RESOLVED)
// 1792:       end
// 1793:     end
// 1794:
// 1795:     class ImmediateFuturePromise < InnerPromise
// 1796:       def initialize(default_executor, fulfilled, value, reason)
// 1797:         super Future.new(self, default_executor).
// 1798:             resolve_with(fulfilled ? Fulfilled.new(value) : Rejected.new(reason))
// 1799:       end
// 1800:     end
// 1801:
// 1802:     class AbstractFlatPromise < BlockedPromise
// 1803:
// 1804:       def initialize(delayed_because, blockers_count, event_or_future)
// 1805:         delayed = LockFreeStack.of1(self)
// 1806:         super(delayed, blockers_count, event_or_future)
// 1807:         # noinspection RubyArgCount
// 1808:         @Touched        = AtomicBoolean.new false
// 1809:         @DelayedBecause = delayed_because || LockFreeStack.new
// 1810:
// 1811:         event_or_future.add_callback_clear_delayed_node delayed.peek
// 1812:       end
// 1813:
// 1814:       def touch
// 1815:         if @Touched.make_true
// 1816:           clear_and_propagate_touch @DelayedBecause
// 1817:         end
// 1818:       end
// 1819:
// 1820:       private
// 1821:
// 1822:       def touched?
// 1823:         @Touched.value
// 1824:       end
// 1825:
// 1826:       def on_resolvable(resolved_future, index)
// 1827:         resolve_with resolved_future.internal_state
// 1828:       end
// 1829:
// 1830:       def resolvable?(countdown, future, index)
// 1831:         !@Future.internal_state.resolved? && super(countdown, future, index)
// 1832:       end
// 1833:
// 1834:       def add_delayed_of(future)
// 1835:         delayed = future.promise.delayed_because
// 1836:         if touched?
// 1837:           clear_and_propagate_touch delayed
// 1838:         else
// 1839:           BlockedPromise.add_delayed @DelayedBecause, delayed
// 1840:           clear_and_propagate_touch @DelayedBecause if touched?
// 1841:         end
// 1842:       end
// 1843:
// 1844:     end
// 1845:
// 1846:     class FlatEventPromise < AbstractFlatPromise
// 1847:
// 1848:       private
// 1849:
// 1850:       def initialize(delayed, blockers_count, default_executor)
// 1851:         super delayed, 2, Event.new(self, default_executor)
// 1852:       end
// 1853:
// 1854:       def process_on_blocker_resolution(future, index)
// 1855:         countdown = super(future, index)
// 1856:         if countdown.nonzero?
// 1857:           internal_state = future.internal_state
// 1858:
// 1859:           unless internal_state.fulfilled?
// 1860:             resolve_with RESOLVED
// 1861:             return countdown
// 1862:           end
// 1863:
// 1864:           value = internal_state.value
// 1865:           case value
// 1866:           when AbstractEventFuture
// 1867:             add_delayed_of value
// 1868:             value.add_callback_notify_blocked self, nil
// 1869:             countdown
// 1870:           else
// 1871:             resolve_with RESOLVED
// 1872:           end
// 1873:         end
// 1874:         countdown
// 1875:       end
// 1876:
// 1877:     end
// 1878:
// 1879:     class FlatFuturePromise < AbstractFlatPromise
// 1880:
// 1881:       private
// 1882:
// 1883:       def initialize(delayed, blockers_count, levels, default_executor)
// 1884:         raise ArgumentError, 'levels has to be higher than 0' if levels < 1
// 1885:         # flat promise may result to a future having delayed futures, therefore we have to have empty stack
// 1886:         # to be able to add new delayed futures
// 1887:         super delayed || LockFreeStack.new, 1 + levels, Future.new(self, default_executor)
// 1888:       end
// 1889:
// 1890:       def process_on_blocker_resolution(future, index)
// 1891:         countdown = super(future, index)
// 1892:         if countdown.nonzero?
// 1893:           internal_state = future.internal_state
// 1894:
// 1895:           unless internal_state.fulfilled?
// 1896:             resolve_with internal_state
// 1897:             return countdown
// 1898:           end
// 1899:
// 1900:           value = internal_state.value
// 1901:           case value
// 1902:           when AbstractEventFuture
// 1903:             add_delayed_of value
// 1904:             value.add_callback_notify_blocked self, nil
// 1905:             countdown
// 1906:           else
// 1907:             evaluate_to(lambda { raise TypeError, "returned value #{value.inspect} is not a Future" })
// 1908:           end
// 1909:         end
// 1910:         countdown
// 1911:       end
// 1912:
// 1913:     end
// 1914:
// 1915:     class RunFuturePromise < AbstractFlatPromise
// 1916:
// 1917:       private
// 1918:
// 1919:       def initialize(delayed, blockers_count, default_executor, run_test)
// 1920:         super delayed, 1, Future.new(self, default_executor)
// 1921:         @RunTest = run_test
// 1922:       end
// 1923:
// 1924:       def process_on_blocker_resolution(future, index)
// 1925:         internal_state = future.internal_state
// 1926:
// 1927:         unless internal_state.fulfilled?
// 1928:           resolve_with internal_state
// 1929:           return 0
// 1930:         end
// 1931:
// 1932:         value               = internal_state.value
// 1933:         continuation_future = @RunTest.call value
// 1934:
// 1935:         if continuation_future
// 1936:           add_delayed_of continuation_future
// 1937:           continuation_future.add_callback_notify_blocked self, nil
// 1938:         else
// 1939:           resolve_with internal_state
// 1940:         end
// 1941:
// 1942:         1
// 1943:       end
// 1944:     end
// 1945:
// 1946:     class ZipEventEventPromise < BlockedPromise
// 1947:       def initialize(delayed, blockers_count, default_executor)
// 1948:         super delayed, 2, Event.new(self, default_executor)
// 1949:       end
// 1950:
// 1951:       private
// 1952:
// 1953:       def on_resolvable(resolved_future, index)
// 1954:         resolve_with RESOLVED
// 1955:       end
// 1956:     end
// 1957:
// 1958:     class ZipFutureEventPromise < BlockedPromise
// 1959:       def initialize(delayed, blockers_count, default_executor)
// 1960:         super delayed, 2, Future.new(self, default_executor)
// 1961:         @result = nil
// 1962:       end
// 1963:
// 1964:       private
// 1965:
// 1966:       def process_on_blocker_resolution(future, index)
// 1967:         # first blocking is future, take its result
// 1968:         @result = future.internal_state if index == 0
// 1969:         # super has to be called after above to piggyback on volatile @Countdown
// 1970:         super future, index
// 1971:       end
// 1972:
// 1973:       def on_resolvable(resolved_future, index)
// 1974:         resolve_with @result
// 1975:       end
// 1976:     end
// 1977:
// 1978:     class EventWrapperPromise < BlockedPromise
// 1979:       def initialize(delayed, blockers_count, default_executor)
// 1980:         super delayed, 1, Event.new(self, default_executor)
// 1981:       end
// 1982:
// 1983:       private
// 1984:
// 1985:       def on_resolvable(resolved_future, index)
// 1986:         resolve_with RESOLVED
// 1987:       end
// 1988:     end
// 1989:
// 1990:     class FutureWrapperPromise < BlockedPromise
// 1991:       def initialize(delayed, blockers_count, default_executor)
// 1992:         super delayed, 1, Future.new(self, default_executor)
// 1993:       end
// 1994:
// 1995:       private
// 1996:
// 1997:       def on_resolvable(resolved_future, index)
// 1998:         resolve_with resolved_future.internal_state
// 1999:       end
// 2000:     end
// 2001:
// 2002:     class ZipFuturesPromise < BlockedPromise
// 2003:
// 2004:       private
// 2005:
// 2006:       def initialize(delayed, blockers_count, default_executor)
// 2007:         super(delayed, blockers_count, Future.new(self, default_executor))
// 2008:         @Resolutions = ::Array.new(blockers_count, nil)
// 2009:
// 2010:         on_resolvable nil, nil if blockers_count == 0
// 2011:       end
// 2012:
// 2013:       def process_on_blocker_resolution(future, index)
// 2014:         # TODO (pitr-ch 18-Dec-2016): Can we assume that array will never break under parallel access when never re-sized?
// 2015:         @Resolutions[index] = future.internal_state # has to be set before countdown in super
// 2016:         super future, index
// 2017:       end
// 2018:
// 2019:       def on_resolvable(resolved_future, index)
// 2020:         all_fulfilled = true
// 2021:         values        = ::Array.new(@Resolutions.size)
// 2022:         reasons       = ::Array.new(@Resolutions.size)
// 2023:
// 2024:         @Resolutions.each_with_index do |internal_state, i|
// 2025:           fulfilled, values[i], reasons[i] = internal_state.result
// 2026:           all_fulfilled                    &&= fulfilled
// 2027:         end
// 2028:
// 2029:         if all_fulfilled
// 2030:           resolve_with FulfilledArray.new(values)
// 2031:         else
// 2032:           resolve_with PartiallyRejected.new(values, reasons)
// 2033:         end
// 2034:       end
// 2035:     end
// 2036:
// 2037:     class ZipEventsPromise < BlockedPromise
// 2038:
// 2039:       private
// 2040:
// 2041:       def initialize(delayed, blockers_count, default_executor)
// 2042:         super delayed, blockers_count, Event.new(self, default_executor)
// 2043:
// 2044:         on_resolvable nil, nil if blockers_count == 0
// 2045:       end
// 2046:
// 2047:       def on_resolvable(resolved_future, index)
// 2048:         resolve_with RESOLVED
// 2049:       end
// 2050:     end
// 2051:
// 2052:     # @abstract
// 2053:     class AbstractAnyPromise < BlockedPromise
// 2054:     end
// 2055:
// 2056:     class AnyResolvedEventPromise < AbstractAnyPromise
// 2057:
// 2058:       private
// 2059:
// 2060:       def initialize(delayed, blockers_count, default_executor)
// 2061:         super delayed, blockers_count, Event.new(self, default_executor)
// 2062:       end
// 2063:
// 2064:       def resolvable?(countdown, future, index)
// 2065:         true
// 2066:       end
// 2067:
// 2068:       def on_resolvable(resolved_future, index)
// 2069:         resolve_with RESOLVED, false
// 2070:       end
// 2071:     end
// 2072:
// 2073:     class AnyResolvedFuturePromise < AbstractAnyPromise
// 2074:
// 2075:       private
// 2076:
// 2077:       def initialize(delayed, blockers_count, default_executor)
// 2078:         super delayed, blockers_count, Future.new(self, default_executor)
// 2079:       end
// 2080:
// 2081:       def resolvable?(countdown, future, index)
// 2082:         true
// 2083:       end
// 2084:
// 2085:       def on_resolvable(resolved_future, index)
// 2086:         resolve_with resolved_future.internal_state, false
// 2087:       end
// 2088:     end
// 2089:
// 2090:     class AnyFulfilledFuturePromise < AnyResolvedFuturePromise
// 2091:
// 2092:       private
// 2093:
// 2094:       def resolvable?(countdown, event_or_future, index)
// 2095:         (event_or_future.is_a?(Event) ? event_or_future.resolved? : event_or_future.fulfilled?) ||
// 2096:             # inlined super from BlockedPromise
// 2097:             countdown.zero?
// 2098:       end
// 2099:     end
// 2100:
// 2101:     class DelayPromise < InnerPromise
// 2102:
// 2103:       def initialize(default_executor)
// 2104:         event    = Event.new(self, default_executor)
// 2105:         @Delayed = LockFreeStack.of1(self)
// 2106:         super event
// 2107:         event.add_callback_clear_delayed_node @Delayed.peek
// 2108:       end
// 2109:
// 2110:       def touch
// 2111:         @Future.resolve_with RESOLVED
// 2112:       end
// 2113:
// 2114:       def delayed_because
// 2115:         @Delayed
// 2116:       end
// 2117:
// 2118:     end
// 2119:
// 2120:     class ScheduledPromise < InnerPromise
// 2121:       def intended_time
// 2122:         @IntendedTime
// 2123:       end
// 2124:
// 2125:       def inspect
// 2126:         "#{to_s[0..-2]} intended_time: #{@IntendedTime}>"
// 2127:       end
// 2128:
// 2129:       private
// 2130:
// 2131:       def initialize(default_executor, intended_time)
// 2132:         super Event.new(self, default_executor)
// 2133:
// 2134:         @IntendedTime = intended_time
// 2135:
// 2136:         in_seconds = begin
// 2137:           now           = Time.now
// 2138:           schedule_time = if @IntendedTime.is_a? Time
// 2139:                             @IntendedTime
// 2140:                           else
// 2141:                             now + @IntendedTime
// 2142:                           end
// 2143:           [0, schedule_time.to_f - now.to_f].max
// 2144:         end
// 2145:
// 2146:         Concurrent.global_timer_set.post(in_seconds) do
// 2147:           @Future.resolve_with RESOLVED
// 2148:         end
// 2149:       end
// 2150:     end
// 2151:
// 2152:     extend FactoryMethods
// 2153:
// 2154:     private_constant :AbstractPromise,
// 2155:                      :ResolvableEventPromise,
// 2156:                      :ResolvableFuturePromise,
// 2157:                      :InnerPromise,
// 2158:                      :BlockedPromise,
// 2159:                      :BlockedTaskPromise,
// 2160:                      :ThenPromise,
// 2161:                      :RescuePromise,
// 2162:                      :ChainPromise,
// 2163:                      :ImmediateEventPromise,
// 2164:                      :ImmediateFuturePromise,
// 2165:                      :AbstractFlatPromise,
// 2166:                      :FlatFuturePromise,
// 2167:                      :FlatEventPromise,
// 2168:                      :RunFuturePromise,
// 2169:                      :ZipEventEventPromise,
// 2170:                      :ZipFutureEventPromise,
// 2171:                      :EventWrapperPromise,
// 2172:                      :FutureWrapperPromise,
// 2173:                      :ZipFuturesPromise,
// 2174:                      :ZipEventsPromise,
// 2175:                      :AbstractAnyPromise,
// 2176:                      :AnyResolvedFuturePromise,
// 2177:                      :AnyFulfilledFuturePromise,
// 2178:                      :AnyResolvedEventPromise,
// 2179:                      :DelayPromise,
// 2180:                      :ScheduledPromise
// 2181:
// 2182:
// 2183:   end
// 2184: end
