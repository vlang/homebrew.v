module executor

import brew_runtime
import os
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/ruby_thread_pool_executor.rb`.
// The original source is retained below until every stub has a typed V body.
pub const ruby_thread_pool_default_max_pool_size = 2_147_483_647
pub const ruby_thread_pool_default_min_pool_size = 0
pub const ruby_thread_pool_default_max_queue_size = 0
pub const ruby_thread_pool_default_thread_idletime = 60
pub const ruby_thread_pool_default_synchronous = false

pub struct RubyThreadPoolOptions {
pub:
	min_length      int
	max_length      int = ruby_thread_pool_default_max_pool_size
	idletime        int = ruby_thread_pool_default_thread_idletime
	max_queue       int
	synchronous     bool
	auto_terminate  bool = true
	name            string
	fallback_policy FallbackPolicy = .abort
}

struct RubyThreadPoolTask {
	task ExecutorTask @[required]
	args []brew_runtime.Value
}

struct RubyThreadPoolReadyWorker {
	id           int
	last_message u64
}

@[heap]
struct RubyThreadPoolState {
	mutex &sync.Mutex
mut:
	running              bool
	stopped              bool
	pool                 []int
	ready                []RubyThreadPoolReadyWorker
	queue                []RubyThreadPoolTask
	assignments          map[int][]RubyThreadPoolTask
	stop_requests        map[int]bool
	scheduled_task_count i64
	completed_task_count i64
	largest_length       int
	workers_counter      int
	ruby_pid             int
	generation           int
}

@[heap]
pub struct RubyThreadPoolExecutor {
pub:
	max_length      int
	min_length      int
	idletime        int
	max_queue       int
	synchronous     bool
	auto_terminate  bool
	name            string
	fallback_policy FallbackPolicy
mut:
	state &RubyThreadPoolState
}

@[heap]
pub struct RubyThreadPoolWorker {
mut:
	state &RubyThreadPoolState
pub:
	id         int
	generation int
}

fn thread_pool_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_ruby_thread_pool_executor(options RubyThreadPoolOptions) !&RubyThreadPoolExecutor {
	if options.synchronous && options.max_queue > 0 {
		return error('`synchronous` cannot be set unless `max_queue` is 0')
	}
	if options.max_length < ruby_thread_pool_default_min_pool_size {
		return error('`max_threads` cannot be less than ${ruby_thread_pool_default_min_pool_size}')
	}
	if options.max_length > ruby_thread_pool_default_max_pool_size {
		return error('`max_threads` cannot be greater than ${ruby_thread_pool_default_max_pool_size}')
	}
	if options.min_length < ruby_thread_pool_default_min_pool_size {
		return error('`min_threads` cannot be less than ${ruby_thread_pool_default_min_pool_size}')
	}
	if options.min_length > options.max_length {
		return error('`min_threads` cannot be more than `max_threads`')
	}
	return &RubyThreadPoolExecutor{
		max_length: options.max_length
		min_length: options.min_length
		idletime: options.idletime
		max_queue: options.max_queue
		synchronous: options.synchronous
		auto_terminate: options.auto_terminate
		name: options.name
		fallback_policy: options.fallback_policy
		state: &RubyThreadPoolState{
			mutex: sync.new_mutex()
			running: true
			assignments: map[int][]RubyThreadPoolTask{}
			stop_requests: map[int]bool{}
			ruby_pid: os.getpid()
			generation: 1
		}
	}
}

fn thread_pool_contains_worker(pool []int, id int) bool {
	for worker_id in pool {
		if worker_id == id {
			return true
		}
	}
	return false
}

fn thread_pool_remove_ready_locked(mut state RubyThreadPoolState, id int) {
	for index, ready_worker in state.ready {
		if ready_worker.id == id {
			state.ready.delete(index)
			return
		}
	}
}

fn thread_pool_remove_busy_locked(mut state RubyThreadPoolState, id int, generation int) bool {
	if generation != state.generation {
		return true
	}
	for index, worker_id in state.pool {
		if worker_id == id {
			state.pool.delete(index)
			break
		}
	}
	state.assignments.delete(id)
	state.stop_requests.delete(id)
	if state.pool.len == 0 && !state.running {
		state.stopped = true
	}
	return true
}

fn thread_pool_prunable_capacity_locked(state &RubyThreadPoolState, min_length int) int {
	if state.running {
		excess := state.pool.len - min_length
		return if excess < state.ready.len { excess } else { state.ready.len }
	}
	return state.pool.len
}

fn thread_pool_add_busy_locked(mut executor RubyThreadPoolExecutor) ?&RubyThreadPoolWorker {
	if executor.state.pool.len >= executor.max_length {
		return none
	}
	executor.state.workers_counter++
	id := executor.state.workers_counter
	executor.state.pool << id
	if executor.state.pool.len > executor.state.largest_length {
		executor.state.largest_length = executor.state.pool.len
	}
	mut worker := &RubyThreadPoolWorker{
		state: executor.state
		id: id
		generation: executor.state.generation
	}
	spawn run_ruby_thread_pool_worker(mut executor.state, worker.id, worker.generation, executor.idletime, executor.min_length)
	return worker
}

fn thread_pool_assign_locked(mut executor RubyThreadPoolExecutor, job RubyThreadPoolTask) bool {
	mut worker_id := 0
	if executor.state.pool.len >= executor.min_length && executor.state.ready.len > 0 {
		ready_worker := executor.state.ready.pop()
		worker_id = ready_worker.id
	} else if worker := thread_pool_add_busy_locked(mut executor) {
		worker_id = worker.id
	}
	if worker_id == 0 {
		return false
	}
	executor.state.assignments[worker_id] << job
	return true
}

fn thread_pool_enqueue_locked(mut executor RubyThreadPoolExecutor, job RubyThreadPoolTask) bool {
	if executor.synchronous {
		return false
	}
	if executor.max_queue == 0 || executor.state.queue.len < executor.max_queue {
		executor.state.queue << job
		return true
	}
	return false
}

fn thread_pool_reset_if_forked_locked(mut executor RubyThreadPoolExecutor) {
	pid := os.getpid()
	if pid == executor.state.ruby_pid {
		return
	}
	executor.state.generation++
	executor.state.queue.clear()
	executor.state.ready.clear()
	executor.state.pool.clear()
	executor.state.assignments.clear()
	executor.state.stop_requests.clear()
	executor.state.scheduled_task_count = 0
	executor.state.completed_task_count = 0
	executor.state.largest_length = 0
	executor.state.workers_counter = 0
	executor.state.ruby_pid = pid
}

fn run_ruby_thread_pool_worker(mut state RubyThreadPoolState, worker_id int, generation int, idletime int, min_length int) {
	for {
		state.mutex.lock()
		if generation != state.generation || !thread_pool_contains_worker(state.pool, worker_id) {
			state.mutex.unlock()
			return
		}
		mut job := RubyThreadPoolTask{
			task: boundary_noop_executor_task
		}
		mut has_job := false
		if worker_id in state.assignments && state.assignments[worker_id].len > 0 {
			job = state.assignments[worker_id][0]
			state.assignments[worker_id].delete(0)
			has_job = true
		}
		if !has_job && state.stop_requests[worker_id] {
			thread_pool_remove_ready_locked(mut state, worker_id)
			thread_pool_remove_busy_locked(mut state, worker_id, generation)
			state.mutex.unlock()
			return
		}
		if !has_job && !state.running {
			thread_pool_remove_ready_locked(mut state, worker_id)
			thread_pool_remove_busy_locked(mut state, worker_id, generation)
			state.mutex.unlock()
			return
		}
		if !has_job {
			mut ready_since := u64(0)
			for ready_worker in state.ready {
				if ready_worker.id == worker_id {
					ready_since = ready_worker.last_message
					break
				}
			}
			idle_duration := u64(if idletime > 0 { idletime } else { 0 }) * u64(time.second)
			if ready_since > 0 && time.sys_mono_now() - ready_since >= idle_duration && thread_pool_prunable_capacity_locked(state, min_length) > 0 {
				thread_pool_remove_ready_locked(mut state, worker_id)
				thread_pool_remove_busy_locked(mut state, worker_id, generation)
				state.mutex.unlock()
				return
			}
			state.mutex.unlock()
			time.sleep(time.millisecond)
			continue
		}
		state.mutex.unlock()
		mut succeeded := true
		job.task(job.args) or {
			// Ruby rescues StandardError, logs it at DEBUG, and keeps the worker alive.
			succeeded = false
		}
		state.mutex.lock()
		if generation != state.generation || !thread_pool_contains_worker(state.pool, worker_id) {
			state.mutex.unlock()
			return
		}
		if succeeded {
			state.completed_task_count++
		}
		if state.queue.len > 0 {
			next_job := state.queue[0]
			state.queue.delete(0)
			state.assignments[worker_id] << next_job
		} else if state.running {
			state.ready << RubyThreadPoolReadyWorker{
				id: worker_id
				last_message: time.sys_mono_now()
			}
		} else {
			thread_pool_remove_busy_locked(mut state, worker_id, generation)
			state.mutex.unlock()
			return
		}
		state.mutex.unlock()
	}
}

pub fn (mut executor RubyThreadPoolExecutor) post(task ExecutorTask, args []brew_runtime.Value) !bool {
	job := RubyThreadPoolTask{
		task: task
		args: args.clone()
	}
	executor.state.mutex.lock()
	thread_pool_reset_if_forked_locked(mut executor)
	accepted := executor.state.running && (thread_pool_assign_locked(mut executor, job) || thread_pool_enqueue_locked(mut executor, job))
	if accepted {
		executor.state.scheduled_task_count++
		executor.state.mutex.unlock()
		return true
	}
	policy := executor.fallback_policy
	executor.state.mutex.unlock()
	return match policy {
		.abort { error('RejectedExecutionError') }
		.discard { false }
		.caller_runs {
			task(args) or {
				// The Ruby caller-runs fallback logs task failures and still reports success.
			}
			true
		}
	}
}

pub fn (mut executor RubyThreadPoolExecutor) running() bool {
	executor.state.mutex.lock()
	value := executor.state.running
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) shutting_down() bool {
	executor.state.mutex.lock()
	value := !executor.state.running && !executor.state.stopped
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) is_shutdown() bool {
	executor.state.mutex.lock()
	value := executor.state.stopped
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) shutdown() bool {
	executor.state.mutex.lock()
	thread_pool_reset_if_forked_locked(mut executor)
	if executor.state.running {
		executor.state.running = false
		if executor.state.pool.len == 0 {
			executor.state.stopped = true
		}
		if executor.state.queue.len == 0 {
			ready_workers := executor.state.ready.clone()
			for ready_worker in ready_workers {
				thread_pool_remove_busy_locked(mut executor.state, ready_worker.id, executor.state.generation)
			}
			executor.state.ready.clear()
			for worker_id in executor.state.pool.clone() {
				executor.state.stop_requests[worker_id] = true
			}
			if executor.state.pool.len == 0 {
				executor.state.stopped = true
			}
		}
	}
	executor.state.mutex.unlock()
	return true
}

pub fn (mut executor RubyThreadPoolExecutor) kill() bool {
	executor.state.mutex.lock()
	executor.state.running = false
	executor.state.stopped = true
	executor.state.generation++
	executor.state.pool.clear()
	executor.state.ready.clear()
	executor.state.queue.clear()
	executor.state.assignments.clear()
	executor.state.stop_requests.clear()
	executor.state.mutex.unlock()
	return true
}

pub fn (mut executor RubyThreadPoolExecutor) wait_for_termination(timeout ?time.Duration) bool {
	started := time.sys_mono_now()
	for {
		if executor.is_shutdown() {
			return true
		}
		if duration := timeout {
			if time.sys_mono_now() - started >= u64(if duration > 0 { duration } else { 0 }) {
				return false
			}
		}
		time.sleep(time.millisecond)
	}
	return false
}

pub fn (mut executor RubyThreadPoolExecutor) stats() (int, int, int, int, i64, i64) {
	executor.state.mutex.lock()
	length := executor.state.pool.len
	active := executor.state.pool.len - executor.state.ready.len
	queue_length := executor.state.queue.len
	largest := executor.state.largest_length
	scheduled := executor.state.scheduled_task_count
	completed := executor.state.completed_task_count
	executor.state.mutex.unlock()
	return length, active, queue_length, largest, scheduled, completed
}

pub fn (mut executor RubyThreadPoolExecutor) remaining_capacity() int {
	executor.state.mutex.lock()
	capacity := if executor.max_queue != 0 {
		executor.max_queue - executor.state.queue.len
	} else {
		-1
	}
	executor.state.mutex.unlock()
	return capacity
}

pub fn (mut executor RubyThreadPoolExecutor) prune_worker(worker &RubyThreadPoolWorker) bool {
	executor.state.mutex.lock()
	if worker.generation == executor.state.generation && thread_pool_prunable_capacity_locked(executor.state, executor.min_length) > 0 {
		thread_pool_remove_ready_locked(mut executor.state, worker.id)
		thread_pool_remove_busy_locked(mut executor.state, worker.id, worker.generation)
		executor.state.mutex.unlock()
		return true
	}
	executor.state.mutex.unlock()
	return false
}

pub fn (mut executor RubyThreadPoolExecutor) remove_worker(worker &RubyThreadPoolWorker) bool {
	executor.state.mutex.lock()
	thread_pool_remove_ready_locked(mut executor.state, worker.id)
	result := thread_pool_remove_busy_locked(mut executor.state, worker.id, worker.generation)
	executor.state.mutex.unlock()
	return result
}

pub fn (mut executor RubyThreadPoolExecutor) ready_worker(worker &RubyThreadPoolWorker, last_message u64) {
	executor.state.mutex.lock()
	if executor.state.queue.len > 0 {
		job := executor.state.queue[0]
		executor.state.queue.delete(0)
		executor.state.assignments[worker.id] << job
	} else if executor.state.running {
		if last_message == 0 {
			executor.state.mutex.unlock()
			panic('RubyThreadPoolExecutor#ready_worker requires last_message')
		}
		executor.state.ready << RubyThreadPoolReadyWorker{
			id: worker.id
			last_message: last_message
		}
	} else {
		executor.state.stop_requests[worker.id] = true
	}
	executor.state.mutex.unlock()
}

pub fn (mut executor RubyThreadPoolExecutor) worker_died(worker &RubyThreadPoolWorker) {
	executor.state.mutex.lock()
	thread_pool_remove_busy_locked(mut executor.state, worker.id, worker.generation)
	if replacement := thread_pool_add_busy_locked(mut executor) {
		if executor.state.queue.len > 0 {
			job := executor.state.queue[0]
			executor.state.queue.delete(0)
			executor.state.assignments[replacement.id] << job
		} else if executor.state.running {
			executor.state.ready << RubyThreadPoolReadyWorker{
				id: replacement.id
				last_message: time.sys_mono_now()
			}
		} else {
			executor.state.stop_requests[replacement.id] = true
		}
	}
	executor.state.mutex.unlock()
}

pub fn (mut executor RubyThreadPoolExecutor) worker_task_completed() i64 {
	executor.state.mutex.lock()
	executor.state.completed_task_count++
	value := executor.state.completed_task_count
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) prunable_capacity() int {
	executor.state.mutex.lock()
	value := thread_pool_prunable_capacity_locked(executor.state, executor.min_length)
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) add_busy_worker() ?&RubyThreadPoolWorker {
	executor.state.mutex.lock()
	worker := thread_pool_add_busy_locked(mut executor)
	executor.state.mutex.unlock()
	return worker
}

pub fn (mut executor RubyThreadPoolExecutor) assign_worker(task ExecutorTask, args []brew_runtime.Value) bool {
	job := RubyThreadPoolTask{
		task: task
		args: args.clone()
	}
	executor.state.mutex.lock()
	value := thread_pool_assign_locked(mut executor, job)
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) enqueue(task ExecutorTask, args []brew_runtime.Value) bool {
	job := RubyThreadPoolTask{
		task: task
		args: args.clone()
	}
	executor.state.mutex.lock()
	value := thread_pool_enqueue_locked(mut executor, job)
	executor.state.mutex.unlock()
	return value
}

pub fn (mut executor RubyThreadPoolExecutor) reset_if_forked() {
	executor.state.mutex.lock()
	thread_pool_reset_if_forked_locked(mut executor)
	executor.state.mutex.unlock()
}

pub fn (mut worker RubyThreadPoolWorker) push(task ExecutorTask, args []brew_runtime.Value) {
	worker.state.mutex.lock()
	if worker.generation == worker.state.generation {
		worker.state.assignments[worker.id] << RubyThreadPoolTask{
			task: task
			args: args.clone()
		}
	}
	worker.state.mutex.unlock()
}

pub fn (mut worker RubyThreadPoolWorker) stop() {
	worker.state.mutex.lock()
	if worker.generation == worker.state.generation {
		worker.state.stop_requests[worker.id] = true
	}
	worker.state.mutex.unlock()
}

pub fn (mut worker RubyThreadPoolWorker) kill() {
	worker.state.mutex.lock()
	thread_pool_remove_ready_locked(mut worker.state, worker.id)
	thread_pool_remove_busy_locked(mut worker.state, worker.id, worker.generation)
	worker.state.mutex.unlock()
}

pub fn (mut worker RubyThreadPoolWorker) run_task(mut executor RubyThreadPoolExecutor, task ExecutorTask, args []brew_runtime.Value) bool {
	task(args) or {
		// Match the Ruby StandardError rescue: log and leave the completion count unchanged.
		return false
	}
	executor.worker_task_completed()
	return true
}

fn ruby_thread_pool_options_from_boundary(args []brew_runtime.Value, index int) !RubyThreadPoolOptions {
	if index >= args.len || args[index].type_name != 'Hash' {
		return RubyThreadPoolOptions{}
	}
	options := args[index].as_map()!
	mut fallback_policy := FallbackPolicy.abort
	if 'fallback_policy' in options {
		policy_name := options['fallback_policy'].as_string().trim_left(':')
		fallback_policy = match policy_name {
			'abort' { .abort }
			'discard' { .discard }
			'caller_runs' { .caller_runs }
			else {
				return error('${options['fallback_policy'].as_string()} is not a valid fallback policy')
			}
		}
	}
	return RubyThreadPoolOptions{
		min_length: if 'min_threads' in options { int(options['min_threads'].as_int()!) } else { 0 }
		max_length: if 'max_threads' in options {
			int(options['max_threads'].as_int()!)} else {
			ruby_thread_pool_default_max_pool_size}
		idletime: if 'idletime' in options {
			int(options['idletime'].as_int()!)} else {
			ruby_thread_pool_default_thread_idletime}
		max_queue: if 'max_queue' in options { int(options['max_queue'].as_int()!) } else { 0 }
		synchronous: if 'synchronous' in options {
			options['synchronous'].as_bool()!} else {
			false}
		auto_terminate: if 'auto_terminate' in options {
			options['auto_terminate'].as_bool()!} else {
			true}
		name: if 'name' in options { options['name'].as_string() } else { '' }
		fallback_policy: fallback_policy
	}
}

fn ruby_thread_pool_boundary_value(executor &RubyThreadPoolExecutor) brew_runtime.Value {
	representation := if executor.name.len > 0 {
		'#<Concurrent::RubyThreadPoolExecutor name: ${executor.name}>'
	} else {
		'#<Concurrent::RubyThreadPoolExecutor>'
	}
	return brew_runtime.structured_value('Concurrent::RubyThreadPoolExecutor', representation, {
		'ruby_thread_pool_state_address':   u64(voidptr(executor.state)).str()
		'ruby_thread_pool_max_length':      executor.max_length.str()
		'ruby_thread_pool_min_length':      executor.min_length.str()
		'ruby_thread_pool_idletime':        executor.idletime.str()
		'ruby_thread_pool_max_queue':       executor.max_queue.str()
		'ruby_thread_pool_synchronous':     executor.synchronous.str()
		'ruby_thread_pool_auto_terminate':  executor.auto_terminate.str()
		'ruby_thread_pool_name':            executor.name
		'ruby_thread_pool_fallback_policy': executor.fallback_policy.str()
	})
}

fn ruby_thread_pool_boundary_receiver(args []brew_runtime.Value) &RubyThreadPoolExecutor {
	if args.len == 0 {
		panic('RubyThreadPoolExecutor method requires a receiver')
	}
	state_address := (args[0].attribute('ruby_thread_pool_state_address') or {
		panic('${args[0].type_name} has no translated RubyThreadPoolExecutor state')
	}).u64()
	return &RubyThreadPoolExecutor{
		max_length: (args[0].attribute('ruby_thread_pool_max_length') or { '0' }).int()
		min_length: (args[0].attribute('ruby_thread_pool_min_length') or { '0' }).int()
		idletime: (args[0].attribute('ruby_thread_pool_idletime') or { '0' }).int()
		max_queue: (args[0].attribute('ruby_thread_pool_max_queue') or { '0' }).int()
		synchronous: (args[0].attribute('ruby_thread_pool_synchronous') or { 'false' }) == 'true'
		auto_terminate: (args[0].attribute('ruby_thread_pool_auto_terminate') or { 'true' }) == 'true'
		name: args[0].attribute('ruby_thread_pool_name') or { '' }
		fallback_policy: fallback_policy_from_string(args[0].attribute('ruby_thread_pool_fallback_policy') or {
			'abort'})
		state: unsafe { &RubyThreadPoolState(voidptr(state_address)) }
	}
}

fn ruby_thread_pool_worker_boundary_value(worker &RubyThreadPoolWorker) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::RubyThreadPoolExecutor::Worker', '#<Concurrent::RubyThreadPoolExecutor::Worker>', {
		'ruby_thread_pool_worker_state_address': u64(voidptr(worker.state)).str()
		'ruby_thread_pool_worker_id':            worker.id.str()
		'ruby_thread_pool_worker_generation':    worker.generation.str()
	})
}

fn ruby_thread_pool_worker_boundary_receiver(args []brew_runtime.Value, index int) &RubyThreadPoolWorker {
	if index >= args.len {
		panic('RubyThreadPoolExecutor::Worker method requires a receiver')
	}
	state_address := (args[index].attribute('ruby_thread_pool_worker_state_address') or {
		panic('${args[index].type_name} has no translated RubyThreadPoolExecutor::Worker state')
	}).u64()
	id := (args[index].attribute('ruby_thread_pool_worker_id') or {
		panic('${args[index].type_name} has no translated RubyThreadPoolExecutor::Worker id')
	}).int()
	generation := (args[index].attribute('ruby_thread_pool_worker_generation') or {
		panic('${args[index].type_name} has no translated RubyThreadPoolExecutor::Worker generation')
	}).int()
	return &RubyThreadPoolWorker{
		state: unsafe { &RubyThreadPoolState(voidptr(state_address)) }
		id: id
		generation: generation
	}
}

fn ruby_thread_pool_boundary_timeout(args []brew_runtime.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	return time.Duration((args[index].as_float() or { panic(err) }) * f64(time.second))
}

// Ruby attr_reader `attr_reader :max_length` at line 32.
pub fn ruby_ruby_thread_pool_executor_l32_d1_max_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(ruby_thread_pool_boundary_receiver(args).max_length)
}

// Ruby attr_reader `attr_reader :min_length` at line 35.
pub fn ruby_ruby_thread_pool_executor_l35_d2_min_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(ruby_thread_pool_boundary_receiver(args).min_length)
}

// Ruby attr_reader `attr_reader :idletime` at line 38.
pub fn ruby_ruby_thread_pool_executor_l38_d3_idletime(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(ruby_thread_pool_boundary_receiver(args).idletime)
}

// Ruby attr_reader `attr_reader :max_queue` at line 41.
pub fn ruby_ruby_thread_pool_executor_l41_d4_max_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(ruby_thread_pool_boundary_receiver(args).max_queue)
}

// Ruby attr_reader `attr_reader :synchronous` at line 44.
pub fn ruby_ruby_thread_pool_executor_l44_d5_synchronous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_thread_pool_boundary_receiver(args).synchronous)
}

// Ruby method `initialize(opts = {})` at line 47.
pub fn ruby_ruby_thread_pool_executor_l47_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_thread_pool_boundary_value(new_ruby_thread_pool_executor(ruby_thread_pool_options_from_boundary(args, 0) or { panic(err) }) or { panic(err) })
}

// Ruby method `largest_length` at line 52.
pub fn ruby_ruby_thread_pool_executor_l52_d7_largest_length(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	_, _, _, largest, _, _ := executor.stats()
	return brew_runtime.int_value(largest)
}

// Ruby method `scheduled_task_count` at line 57.
pub fn ruby_ruby_thread_pool_executor_l57_d8_scheduled_task_count(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	_, _, _, _, scheduled, _ := executor.stats()
	return brew_runtime.int_value(scheduled)
}

// Ruby method `completed_task_count` at line 62.
pub fn ruby_ruby_thread_pool_executor_l62_d9_completed_task_count(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	_, _, _, _, _, completed := executor.stats()
	return brew_runtime.int_value(completed)
}

// Ruby method `active_count` at line 67.
pub fn ruby_ruby_thread_pool_executor_l67_d10_active_count(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	_, active, _, _, _, _ := executor.stats()
	return brew_runtime.int_value(active)
}

// Ruby method `can_overflow?` at line 74.
pub fn ruby_ruby_thread_pool_executor_l74_d11_can_overflow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_thread_pool_boundary_receiver(args).max_queue != 0)
}

// Ruby method `length` at line 79.
pub fn ruby_ruby_thread_pool_executor_l79_d12_length(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	length, _, _, _, _, _ := executor.stats()
	return brew_runtime.int_value(length)
}

// Ruby method `queue_length` at line 84.
pub fn ruby_ruby_thread_pool_executor_l84_d13_queue_length(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	_, _, queue_length, _, _, _ := executor.stats()
	return brew_runtime.int_value(queue_length)
}

// Ruby method `remaining_capacity` at line 89.
pub fn ruby_ruby_thread_pool_executor_l89_d14_remaining_capacity(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	return brew_runtime.int_value(executor.remaining_capacity())
}

// Ruby method `prune_worker(worker)` at line 104.
pub fn ruby_ruby_thread_pool_executor_l104_d15_prune_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	return brew_runtime.bool_value(executor.prune_worker(worker))
}

// Ruby method `remove_worker(worker)` at line 116.
pub fn ruby_ruby_thread_pool_executor_l116_d16_remove_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	return brew_runtime.bool_value(executor.remove_worker(worker))
}

// Ruby method `ready_worker(worker, last_message)` at line 124.
pub fn ruby_ruby_thread_pool_executor_l124_d17_ready_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	last_message := if args.len > 2 {
		u64((args[2].as_float() or { panic(err) }) * f64(time.second))
	} else {
		time.sys_mono_now()
	}
	executor.ready_worker(worker, last_message)
	return thread_pool_nil_value()
}

// Ruby method `worker_died(worker)` at line 129.
pub fn ruby_ruby_thread_pool_executor_l129_d18_worker_died(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	executor.worker_died(worker)
	return thread_pool_nil_value()
}

// Ruby method `worker_task_completed` at line 134.
pub fn ruby_ruby_thread_pool_executor_l134_d19_worker_task_completed(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	return brew_runtime.int_value(executor.worker_task_completed())
}

// Ruby method `prune_pool` at line 139.
pub fn ruby_ruby_thread_pool_executor_l139_d20_prune_pool(args ...brew_runtime.Value) brew_runtime.Value {
	_ = ruby_thread_pool_boundary_receiver(args)
	// The source method is deprecated and intentionally has no effect.
	return thread_pool_nil_value()
}

// Ruby method `ns_initialize(opts)` at line 146.
pub fn ruby_ruby_thread_pool_executor_l146_d21_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	index := if args.len > 0 && args[0].type_name == 'Concurrent::RubyThreadPoolExecutor' {
		1
	} else {
		0
	}
	return ruby_thread_pool_boundary_value(new_ruby_thread_pool_executor(ruby_thread_pool_options_from_boundary(args, index) or { panic(err) }) or { panic(err) })
}

// Ruby method `ns_limited_queue?` at line 173.
pub fn ruby_ruby_thread_pool_executor_l173_d22_ns_limited_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_thread_pool_boundary_receiver(args).max_queue != 0)
}

// Ruby method `ns_execute(*args, &task)` at line 178.
pub fn ruby_ruby_thread_pool_executor_l178_d23_ns_execute(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	accepted := executor.post(boundary_noop_executor_task, if args.len > 1 {
		args[1..].clone()
	} else {
		[]brew_runtime.Value{}
	}) or { panic(err) }
	return if accepted { thread_pool_nil_value() } else { brew_runtime.bool_value(false) }
}

// Ruby method `ns_shutdown_execution` at line 190.
pub fn ruby_ruby_thread_pool_executor_l190_d24_ns_shutdown_execution(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	executor.shutdown()
	return thread_pool_nil_value()
}

// Ruby method `ns_kill_execution` at line 205.
pub fn ruby_ruby_thread_pool_executor_l205_d25_ns_kill_execution(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	executor.kill()
	return thread_pool_nil_value()
}

// Ruby method `ns_assign_worker(*args, &task)` at line 217.
pub fn ruby_ruby_thread_pool_executor_l217_d26_ns_assign_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	return brew_runtime.bool_value(executor.assign_worker(boundary_noop_executor_task, if args.len > 1 {
		args[1..].clone()
	} else {
		[]brew_runtime.Value{}
	}))
}

// Ruby method `ns_enqueue(*args, &task)` at line 235.
pub fn ruby_ruby_thread_pool_executor_l235_d27_ns_enqueue(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	return brew_runtime.bool_value(executor.enqueue(boundary_noop_executor_task, if args.len > 1 {
		args[1..].clone()
	} else {
		[]brew_runtime.Value{}
	}))
}

// Ruby method `ns_worker_died(worker)` at line 247.
pub fn ruby_ruby_thread_pool_executor_l247_d28_ns_worker_died(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_thread_pool_executor_l129_d18_worker_died(...args)
}

// Ruby method `ns_add_busy_worker` at line 257.
pub fn ruby_ruby_thread_pool_executor_l257_d29_ns_add_busy_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	if worker := executor.add_busy_worker() {
		return ruby_thread_pool_worker_boundary_value(worker)
	}
	return thread_pool_nil_value()
}

// Ruby method `ns_ready_worker(worker, last_message, success = true)` at line 269.
pub fn ruby_ruby_thread_pool_executor_l269_d30_ns_ready_worker(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_thread_pool_executor_l124_d17_ready_worker(...args)
}

// Ruby method `ns_remove_busy_worker(worker)` at line 287.
pub fn ruby_ruby_thread_pool_executor_l287_d31_ns_remove_busy_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	executor.state.mutex.lock()
	result := thread_pool_remove_busy_locked(mut executor.state, worker.id, worker.generation)
	executor.state.mutex.unlock()
	return brew_runtime.bool_value(result)
}

// Ruby method `ns_remove_ready_worker(worker)` at line 294.
pub fn ruby_ruby_thread_pool_executor_l294_d32_ns_remove_ready_worker(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	worker := ruby_thread_pool_worker_boundary_receiver(args, 1)
	executor.state.mutex.lock()
	thread_pool_remove_ready_locked(mut executor.state, worker.id)
	executor.state.mutex.unlock()
	return brew_runtime.bool_value(true)
}

// Ruby method `ns_prunable_capacity` at line 305.
pub fn ruby_ruby_thread_pool_executor_l305_d33_ns_prunable_capacity(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	return brew_runtime.int_value(executor.prunable_capacity())
}

// Ruby method `ns_reset_if_forked` at line 314.
pub fn ruby_ruby_thread_pool_executor_l314_d34_ns_reset_if_forked(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	executor.reset_if_forked()
	return thread_pool_nil_value()
}

// Ruby method `initialize(pool, id)` at line 331.
pub fn ruby_ruby_thread_pool_executor_l331_d35_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut executor := ruby_thread_pool_boundary_receiver(args)
	if worker := executor.add_busy_worker() {
		return ruby_thread_pool_worker_boundary_value(worker)
	}
	return thread_pool_nil_value()
}

// Ruby method `<<(message)` at line 342.
pub fn ruby_ruby_thread_pool_executor_l342_d36_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	mut worker := ruby_thread_pool_worker_boundary_receiver(args, 0)
	worker.push(boundary_noop_executor_task, if args.len > 1 {
		args[1..].clone()
	} else {
		[]brew_runtime.Value{}
	})
	return args[0]
}

// Ruby method `stop` at line 346.
pub fn ruby_ruby_thread_pool_executor_l346_d37_stop(args ...brew_runtime.Value) brew_runtime.Value {
	mut worker := ruby_thread_pool_worker_boundary_receiver(args, 0)
	worker.stop()
	return thread_pool_nil_value()
}

// Ruby method `kill` at line 350.
pub fn ruby_ruby_thread_pool_executor_l350_d38_kill(args ...brew_runtime.Value) brew_runtime.Value {
	mut worker := ruby_thread_pool_worker_boundary_receiver(args, 0)
	worker.kill()
	return thread_pool_nil_value()
}

// Ruby method `create_worker(queue, pool, idletime)` at line 356.
pub fn ruby_ruby_thread_pool_executor_l356_d39_create_worker(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_thread_pool_worker_boundary_value(ruby_thread_pool_worker_boundary_receiver(args, 0))
}

// Ruby method `run_task(pool, task, args)` at line 381.
pub fn ruby_ruby_thread_pool_executor_l381_d40_run_task(args ...brew_runtime.Value) brew_runtime.Value {
	mut worker := ruby_thread_pool_worker_boundary_receiver(args, 0)
	if args.len < 2 {
		panic('RubyThreadPoolExecutor::Worker#run_task requires pool')
	}
	mut executor := ruby_thread_pool_boundary_receiver(args[1..])
	succeeded := worker.run_task(mut executor, boundary_noop_executor_task, if args.len > 2 {
		args[2..].clone()
	} else {
		[]brew_runtime.Value{}
	})
	return if succeeded { thread_pool_nil_value() } else { brew_runtime.bool_value(false) }
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/atomic/event'
// 3: require 'concurrent/concern/logging'
// 4: require 'concurrent/executor/ruby_executor_service'
// 5: require 'concurrent/utility/monotonic_time'
// 6: require 'concurrent/collection/timeout_queue'
// 7:
// 8: module Concurrent
// 9:
// 10:   # @!macro thread_pool_executor
// 11:   # @!macro thread_pool_options
// 12:   # @!visibility private
// 13:   class RubyThreadPoolExecutor < RubyExecutorService
// 14:     include Concern::Deprecation
// 15:
// 16:     # @!macro thread_pool_executor_constant_default_max_pool_size
// 17:     DEFAULT_MAX_POOL_SIZE      = 2_147_483_647 # java.lang.Integer::MAX_VALUE
// 18:
// 19:     # @!macro thread_pool_executor_constant_default_min_pool_size
// 20:     DEFAULT_MIN_POOL_SIZE      = 0
// 21:
// 22:     # @!macro thread_pool_executor_constant_default_max_queue_size
// 23:     DEFAULT_MAX_QUEUE_SIZE     = 0
// 24:
// 25:     # @!macro thread_pool_executor_constant_default_thread_timeout
// 26:     DEFAULT_THREAD_IDLETIMEOUT = 60
// 27:
// 28:     # @!macro thread_pool_executor_constant_default_synchronous
// 29:     DEFAULT_SYNCHRONOUS = false
// 30:
// 31:     # @!macro thread_pool_executor_attr_reader_max_length
// 32:     attr_reader :max_length
// 33:
// 34:     # @!macro thread_pool_executor_attr_reader_min_length
// 35:     attr_reader :min_length
// 36:
// 37:     # @!macro thread_pool_executor_attr_reader_idletime
// 38:     attr_reader :idletime
// 39:
// 40:     # @!macro thread_pool_executor_attr_reader_max_queue
// 41:     attr_reader :max_queue
// 42:
// 43:     # @!macro thread_pool_executor_attr_reader_synchronous
// 44:     attr_reader :synchronous
// 45:
// 46:     # @!macro thread_pool_executor_method_initialize
// 47:     def initialize(opts = {})
// 48:       super(opts)
// 49:     end
// 50:
// 51:     # @!macro thread_pool_executor_attr_reader_largest_length
// 52:     def largest_length
// 53:       synchronize { @largest_length }
// 54:     end
// 55:
// 56:     # @!macro thread_pool_executor_attr_reader_scheduled_task_count
// 57:     def scheduled_task_count
// 58:       synchronize { @scheduled_task_count }
// 59:     end
// 60:
// 61:     # @!macro thread_pool_executor_attr_reader_completed_task_count
// 62:     def completed_task_count
// 63:       synchronize { @completed_task_count }
// 64:     end
// 65:
// 66:     # @!macro thread_pool_executor_method_active_count
// 67:     def active_count
// 68:       synchronize do
// 69:         @pool.length - @ready.length
// 70:       end
// 71:     end
// 72:
// 73:     # @!macro executor_service_method_can_overflow_question
// 74:     def can_overflow?
// 75:       synchronize { ns_limited_queue? }
// 76:     end
// 77:
// 78:     # @!macro thread_pool_executor_attr_reader_length
// 79:     def length
// 80:       synchronize { @pool.length }
// 81:     end
// 82:
// 83:     # @!macro thread_pool_executor_attr_reader_queue_length
// 84:     def queue_length
// 85:       synchronize { @queue.length }
// 86:     end
// 87:
// 88:     # @!macro thread_pool_executor_attr_reader_remaining_capacity
// 89:     def remaining_capacity
// 90:       synchronize do
// 91:         if ns_limited_queue?
// 92:           @max_queue - @queue.length
// 93:         else
// 94:           -1
// 95:         end
// 96:       end
// 97:     end
// 98:
// 99:     # removes the worker if it can be pruned
// 100:     #
// 101:     # @return [true, false] if the worker was pruned
// 102:     #
// 103:     # @!visibility private
// 104:     def prune_worker(worker)
// 105:       synchronize do
// 106:         if ns_prunable_capacity > 0
// 107:           remove_worker worker
// 108:           true
// 109:         else
// 110:           false
// 111:         end
// 112:       end
// 113:     end
// 114:
// 115:     # @!visibility private
// 116:     def remove_worker(worker)
// 117:       synchronize do
// 118:         ns_remove_ready_worker worker
// 119:         ns_remove_busy_worker worker
// 120:       end
// 121:     end
// 122:
// 123:     # @!visibility private
// 124:     def ready_worker(worker, last_message)
// 125:       synchronize { ns_ready_worker worker, last_message }
// 126:     end
// 127:
// 128:     # @!visibility private
// 129:     def worker_died(worker)
// 130:       synchronize { ns_worker_died worker }
// 131:     end
// 132:
// 133:     # @!visibility private
// 134:     def worker_task_completed
// 135:       synchronize { @completed_task_count += 1 }
// 136:     end
// 137:
// 138:     # @!macro thread_pool_executor_method_prune_pool
// 139:     def prune_pool
// 140:       deprecated "#prune_pool has no effect and will be removed in next the release, see https://github.com/ruby-concurrency/concurrent-ruby/pull/1082."
// 141:     end
// 142:
// 143:     private
// 144:
// 145:     # @!visibility private
// 146:     def ns_initialize(opts)
// 147:       @min_length      = opts.fetch(:min_threads, DEFAULT_MIN_POOL_SIZE).to_i
// 148:       @max_length      = opts.fetch(:max_threads, DEFAULT_MAX_POOL_SIZE).to_i
// 149:       @idletime        = opts.fetch(:idletime, DEFAULT_THREAD_IDLETIMEOUT).to_i
// 150:       @max_queue       = opts.fetch(:max_queue, DEFAULT_MAX_QUEUE_SIZE).to_i
// 151:       @synchronous     = opts.fetch(:synchronous, DEFAULT_SYNCHRONOUS)
// 152:       @fallback_policy = opts.fetch(:fallback_policy, :abort)
// 153:
// 154:       raise ArgumentError.new("`synchronous` cannot be set unless `max_queue` is 0") if @synchronous && @max_queue > 0
// 155:       raise ArgumentError.new("#{@fallback_policy} is not a valid fallback policy") unless FALLBACK_POLICIES.include?(@fallback_policy)
// 156:       raise ArgumentError.new("`max_threads` cannot be less than #{DEFAULT_MIN_POOL_SIZE}") if @max_length < DEFAULT_MIN_POOL_SIZE
// 157:       raise ArgumentError.new("`max_threads` cannot be greater than #{DEFAULT_MAX_POOL_SIZE}") if @max_length > DEFAULT_MAX_POOL_SIZE
// 158:       raise ArgumentError.new("`min_threads` cannot be less than #{DEFAULT_MIN_POOL_SIZE}") if @min_length < DEFAULT_MIN_POOL_SIZE
// 159:       raise ArgumentError.new("`min_threads` cannot be more than `max_threads`") if min_length > max_length
// 160:
// 161:       @pool                 = [] # all workers
// 162:       @ready                = [] # used as a stash (most idle worker is at the start)
// 163:       @queue                = [] # used as queue
// 164:       # @ready or @queue is empty at all times
// 165:       @scheduled_task_count = 0
// 166:       @completed_task_count = 0
// 167:       @largest_length       = 0
// 168:       @workers_counter      = 0
// 169:       @ruby_pid             = $$ # detects if Ruby has forked
// 170:     end
// 171:
// 172:     # @!visibility private
// 173:     def ns_limited_queue?
// 174:       @max_queue != 0
// 175:     end
// 176:
// 177:     # @!visibility private
// 178:     def ns_execute(*args, &task)
// 179:       ns_reset_if_forked
// 180:
// 181:       if ns_assign_worker(*args, &task) || ns_enqueue(*args, &task)
// 182:         @scheduled_task_count += 1
// 183:         nil
// 184:       else
// 185:         fallback_action(*args, &task)
// 186:       end
// 187:     end
// 188:
// 189:     # @!visibility private
// 190:     def ns_shutdown_execution
// 191:       ns_reset_if_forked
// 192:
// 193:       if @pool.empty?
// 194:         # nothing to do
// 195:         stopped_event.set
// 196:       end
// 197:
// 198:       if @queue.empty?
// 199:         # no more tasks will be accepted, just stop all workers
// 200:         @pool.each(&:stop)
// 201:       end
// 202:     end
// 203:
// 204:     # @!visibility private
// 205:     def ns_kill_execution
// 206:       # TODO log out unprocessed tasks in queue
// 207:       # TODO try to shutdown first?
// 208:       @pool.each(&:kill)
// 209:       @pool.clear
// 210:       @ready.clear
// 211:     end
// 212:
// 213:     # tries to assign task to a worker, tries to get one from @ready or to create new one
// 214:     # @return [true, false] if task is assigned to a worker
// 215:     #
// 216:     # @!visibility private
// 217:     def ns_assign_worker(*args, &task)
// 218:       # keep growing if the pool is not at the minimum yet
// 219:       worker, _ = (@ready.pop if @pool.size >= @min_length) || ns_add_busy_worker
// 220:       if worker
// 221:         worker << [task, args]
// 222:         true
// 223:       else
// 224:         false
// 225:       end
// 226:     rescue ThreadError
// 227:       # Raised when the operating system refuses to create the new thread
// 228:       return false
// 229:     end
// 230:
// 231:     # tries to enqueue task
// 232:     # @return [true, false] if enqueued
// 233:     #
// 234:     # @!visibility private
// 235:     def ns_enqueue(*args, &task)
// 236:       return false if @synchronous
// 237:
// 238:       if !ns_limited_queue? || @queue.size < @max_queue
// 239:         @queue << [task, args]
// 240:         true
// 241:       else
// 242:         false
// 243:       end
// 244:     end
// 245:
// 246:     # @!visibility private
// 247:     def ns_worker_died(worker)
// 248:       ns_remove_busy_worker worker
// 249:       replacement_worker = ns_add_busy_worker
// 250:       ns_ready_worker replacement_worker, Concurrent.monotonic_time, false if replacement_worker
// 251:     end
// 252:
// 253:     # creates new worker which has to receive work to do after it's added
// 254:     # @return [nil, Worker] nil of max capacity is reached
// 255:     #
// 256:     # @!visibility private
// 257:     def ns_add_busy_worker
// 258:       return if @pool.size >= @max_length
// 259:
// 260:       @workers_counter += 1
// 261:       @pool << (worker = Worker.new(self, @workers_counter))
// 262:       @largest_length = @pool.length if @pool.length > @largest_length
// 263:       worker
// 264:     end
// 265:
// 266:     # handle ready worker, giving it new job or assigning back to @ready
// 267:     #
// 268:     # @!visibility private
// 269:     def ns_ready_worker(worker, last_message, success = true)
// 270:       task_and_args = @queue.shift
// 271:       if task_and_args
// 272:         worker << task_and_args
// 273:       else
// 274:         # stop workers when !running?, do not return them to @ready
// 275:         if running?
// 276:           raise unless last_message
// 277:           @ready.push([worker, last_message])
// 278:         else
// 279:           worker.stop
// 280:         end
// 281:       end
// 282:     end
// 283:
// 284:     # removes a worker which is not tracked in @ready
// 285:     #
// 286:     # @!visibility private
// 287:     def ns_remove_busy_worker(worker)
// 288:       @pool.delete(worker)
// 289:       stopped_event.set if @pool.empty? && !running?
// 290:       true
// 291:     end
// 292:
// 293:     # @!visibility private
// 294:     def ns_remove_ready_worker(worker)
// 295:       if index = @ready.index { |rw, _| rw == worker }
// 296:         @ready.delete_at(index)
// 297:       end
// 298:       true
// 299:     end
// 300:
// 301:     # @return [Integer] number of excess idle workers which can be removed without
// 302:     #                   going below min_length, or all workers if not running
// 303:     #
// 304:     # @!visibility private
// 305:     def ns_prunable_capacity
// 306:       if running?
// 307:         [@pool.size - @min_length, @ready.size].min
// 308:       else
// 309:         @pool.size
// 310:       end
// 311:     end
// 312:
// 313:     # @!visibility private
// 314:     def ns_reset_if_forked
// 315:       if $$ != @ruby_pid
// 316:         @queue.clear
// 317:         @ready.clear
// 318:         @pool.clear
// 319:         @scheduled_task_count = 0
// 320:         @completed_task_count = 0
// 321:         @largest_length       = 0
// 322:         @workers_counter      = 0
// 323:         @ruby_pid             = $$
// 324:       end
// 325:     end
// 326:
// 327:     # @!visibility private
// 328:     class Worker
// 329:       include Concern::Logging
// 330:
// 331:       def initialize(pool, id)
// 332:         # instance variables accessed only under pool's lock so no need to sync here again
// 333:         @queue  = Collection::TimeoutQueue.new
// 334:         @pool   = pool
// 335:         @thread = create_worker @queue, pool, pool.idletime
// 336:
// 337:         if @thread.respond_to?(:name=)
// 338:           @thread.name = [pool.name, 'worker', id].compact.join('-')
// 339:         end
// 340:       end
// 341:
// 342:       def <<(message)
// 343:         @queue << message
// 344:       end
// 345:
// 346:       def stop
// 347:         @queue << :stop
// 348:       end
// 349:
// 350:       def kill
// 351:         @thread.kill
// 352:       end
// 353:
// 354:       private
// 355:
// 356:       def create_worker(queue, pool, idletime)
// 357:         Thread.new(queue, pool, idletime) do |my_queue, my_pool, my_idletime|
// 358:           catch(:stop) do
// 359:             prunable = true
// 360:
// 361:             loop do
// 362:               timeout = prunable && my_pool.running? ? my_idletime : nil
// 363:               case message = my_queue.pop(timeout: timeout)
// 364:               when nil
// 365:                 throw :stop if my_pool.prune_worker(self)
// 366:                 prunable = false
// 367:               when :stop
// 368:                 my_pool.remove_worker(self)
// 369:                 throw :stop
// 370:               else
// 371:                 task, args = message
// 372:                 run_task my_pool, task, args
// 373:                 my_pool.ready_worker(self, Concurrent.monotonic_time)
// 374:                 prunable = true
// 375:               end
// 376:             end
// 377:           end
// 378:         end
// 379:       end
// 380:
// 381:       def run_task(pool, task, args)
// 382:         task.call(*args)
// 383:         pool.worker_task_completed
// 384:       rescue => ex
// 385:         # let it fail
// 386:         log DEBUG, ex
// 387:       rescue Exception => ex
// 388:         log ERROR, ex
// 389:         pool.worker_died(self)
// 390:         throw :stop
// 391:       end
// 392:     end
// 393:
// 394:     private_constant :Worker
// 395:   end
// 396: end
