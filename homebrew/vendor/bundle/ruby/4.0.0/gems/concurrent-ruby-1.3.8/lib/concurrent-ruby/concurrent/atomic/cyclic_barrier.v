module atomic

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/cyclic_barrier.rb`.
// The original source is retained below until every stub has a typed V body.
pub type BarrierAction = fn() !

pub enum BarrierStatus {
	waiting
	fulfilled
	broken
	reset
}

@[heap]
struct CyclicBarrierState {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	parties        int
	number_waiting int
	generation     u64
	statuses       map[u64]BarrierStatus
	action         ?BarrierAction
}

@[heap]
pub struct CyclicBarrier {
mut:
	state &CyclicBarrierState
}

fn validate_barrier_parties(parties i64) !int {
	if parties < 1 {
		return error('${parties} cannot be negative or zero')
	}
	if parties > i64(4_611_686_018_427_387_903) {
		return error('${parties} is greater than the native integer maximum')
	}
	return int(parties)
}

pub fn new_cyclic_barrier(parties int, action ?BarrierAction) !&CyclicBarrier {
	validate_barrier_parties(parties)!
	mutex := sync.new_mutex()
	return &CyclicBarrier{
		state: &CyclicBarrierState{
			mutex: mutex
			condition: sync.new_cond(mutex)
			parties: parties
			statuses: {
				u64(0): BarrierStatus.waiting
			}
			action: action
		}
	}
}

pub fn (mut barrier CyclicBarrier) parties() int {
	barrier.state.mutex.lock()
	defer {
		barrier.state.mutex.unlock()
	}
	return barrier.state.parties
}

pub fn (mut barrier CyclicBarrier) number_waiting() int {
	barrier.state.mutex.lock()
	defer {
		barrier.state.mutex.unlock()
	}
	return barrier.state.number_waiting
}

fn (mut barrier CyclicBarrier) next_generation_locked() {
	barrier.state.generation++
	barrier.state.statuses[barrier.state.generation] = .waiting
	barrier.state.number_waiting = 0
}

fn (mut barrier CyclicBarrier) generation_done_locked(generation u64, status BarrierStatus, continue_generation bool) {
	barrier.state.statuses[generation] = status
	if continue_generation {
		barrier.next_generation_locked()
	}
	barrier.state.condition.broadcast()
}

fn (mut barrier CyclicBarrier) wait_for_generation_locked(generation u64, timeout ?time.Duration) bool {
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for barrier.state.statuses[generation] == .waiting {
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
			barrier.state.mutex.unlock()
			time.sleep(sleep_for)
			barrier.state.mutex.lock()
		}
		return true
	}
	for barrier.state.statuses[generation] == .waiting {
		barrier.state.condition.wait()
	}
	return true
}

pub fn (mut barrier CyclicBarrier) wait(timeout ?time.Duration) !bool {
	barrier.state.mutex.lock()
	defer {
		barrier.state.mutex.unlock()
	}
	generation := barrier.state.generation
	if barrier.state.statuses[generation] != .waiting {
		return false
	}
	barrier.state.number_waiting++
	if barrier.state.number_waiting == barrier.state.parties {
		if action := barrier.state.action {
			action()!
		}
		barrier.generation_done_locked(generation, .fulfilled, true)
		return true
	}
	if barrier.wait_for_generation_locked(generation, timeout) {
		return barrier.state.statuses[generation] == .fulfilled
	}
	barrier.generation_done_locked(generation, .broken, false)
	return false
}

pub fn (mut barrier CyclicBarrier) reset() {
	barrier.state.mutex.lock()
	generation := barrier.state.generation
	barrier.generation_done_locked(generation, .reset, true)
	barrier.state.mutex.unlock()
}

pub fn (mut barrier CyclicBarrier) is_broken() bool {
	barrier.state.mutex.lock()
	defer {
		barrier.state.mutex.unlock()
	}
	return barrier.state.statuses[barrier.state.generation] != .waiting
}

pub fn (mut barrier CyclicBarrier) ns_initialize(parties int, action ?BarrierAction) ! {
	validate_barrier_parties(parties)!
	barrier.state.mutex.lock()
	barrier.state.parties = parties
	barrier.state.number_waiting = 0
	barrier.state.generation = 0
	barrier.state.statuses = {
		u64(0): BarrierStatus.waiting
	}
	barrier.state.action = action
	barrier.state.mutex.unlock()
}

fn barrier_boundary_new(parties int) ruby.Value {
	barrier := new_cyclic_barrier(parties, none) or { panic(err) }
	return ruby.structured_value('Concurrent::CyclicBarrier', '#<Concurrent::CyclicBarrier>', {
		'barrier_address': u64(voidptr(barrier)).str()
	})
}

fn barrier_boundary_receiver(args []ruby.Value) &CyclicBarrier {
	if args.len == 0 {
		panic('CyclicBarrier method requires a receiver')
	}
	address := (args[0].attribute('barrier_address') or {
		panic('${args[0].type_name} has no translated CyclicBarrier state')
	}).u64()
	return unsafe { &CyclicBarrier(voidptr(address)) }
}

fn barrier_boundary_timeout(args []ruby.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

fn barrier_status_from_value(value ruby.Value) BarrierStatus {
	return match value.as_string().trim_left(':') {
		'fulfilled' { .fulfilled }
		'broken' { .broken }
		'reset' { .reset }
		else { .waiting }
	}
}

// Ruby method `initialize(parties, &block)` at line 40.
pub fn ruby_cyclic_barrier_l40_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CyclicBarrier#initialize requires parties')
	}
	parties := validate_barrier_parties(args[0].as_int() or { panic(err) }) or { panic(err) }
	return barrier_boundary_new(parties)
}

// Ruby method `parties` at line 49.
pub fn ruby_cyclic_barrier_l49_d2_parties(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	return ruby.int_value(barrier.parties())
}

// Ruby method `number_waiting` at line 54.
pub fn ruby_cyclic_barrier_l54_d3_number_waiting(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	return ruby.int_value(barrier.number_waiting())
}

// Ruby method `wait(timeout = nil)` at line 66.
pub fn ruby_cyclic_barrier_l66_d4_wait(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	return ruby.bool_value(barrier.wait(barrier_boundary_timeout(args, 1)) or { panic(err) })
}

// Ruby method `reset` at line 95.
pub fn ruby_cyclic_barrier_l95_d5_reset(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	barrier.reset()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `broken?` at line 105.
pub fn ruby_cyclic_barrier_l105_d6_broken(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	return ruby.bool_value(barrier.is_broken())
}

// Ruby method `ns_generation_done(generation, status, continue = true)` at line 111.
pub fn ruby_cyclic_barrier_l111_d7_ns_generation_done(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('CyclicBarrier#ns_generation_done requires generation and status')
	}
	mut barrier := barrier_boundary_receiver(args)
	generation := u64(args[1].as_int() or { panic(err) })
	continue_generation := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	barrier.state.mutex.lock()
	barrier.generation_done_locked(generation, barrier_status_from_value(args[2]), continue_generation)
	barrier.state.mutex.unlock()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `ns_next_generation` at line 117.
pub fn ruby_cyclic_barrier_l117_d8_ns_next_generation(args ...ruby.Value) ruby.Value {
	mut barrier := barrier_boundary_receiver(args)
	barrier.state.mutex.lock()
	barrier.next_generation_locked()
	barrier.state.mutex.unlock()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `ns_initialize(parties, &block)` at line 122.
pub fn ruby_cyclic_barrier_l122_d9_ns_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CyclicBarrier#ns_initialize requires parties')
	}
	mut barrier := barrier_boundary_receiver(args)
	parties := validate_barrier_parties(args[1].as_int() or { panic(err) }) or { panic(err) }
	barrier.ns_initialize(parties, none) or { panic(err) }
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A synchronization aid that allows a set of threads to all wait for each
// 7:   # other to reach a common barrier point.
// 8:   # @example
// 9:   #   barrier = Concurrent::CyclicBarrier.new(3)
// 10:   #   jobs    = Array.new(3) { |i| -> { sleep i; p done: i } }
// 11:   #   process = -> (i) do
// 12:   #     # waiting to start at the same time
// 13:   #     barrier.wait
// 14:   #     # execute job
// 15:   #     jobs[i].call
// 16:   #     # wait for others to finish
// 17:   #     barrier.wait
// 18:   #   end
// 19:   #   threads = 2.times.map do |i|
// 20:   #     Thread.new(i, &process)
// 21:   #   end
// 22:   #
// 23:   #   # use main as well
// 24:   #   process.call 2
// 25:   #
// 26:   #   # here we can be sure that all jobs are processed
// 27:   class CyclicBarrier < Synchronization::LockableObject
// 28:
// 29:     # @!visibility private
// 30:     Generation = Struct.new(:status)
// 31:     private_constant :Generation
// 32:
// 33:     # Create a new `CyclicBarrier` that waits for `parties` threads
// 34:     #
// 35:     # @param [Fixnum] parties the number of parties
// 36:     # @yield an optional block that will be executed that will be executed after
// 37:     #  the last thread arrives and before the others are released
// 38:     #
// 39:     # @raise [ArgumentError] if `parties` is not an integer or is less than zero
// 40:     def initialize(parties, &block)
// 41:       Utility::NativeInteger.ensure_integer_and_bounds parties
// 42:       Utility::NativeInteger.ensure_positive_and_no_zero parties
// 43:
// 44:       super(&nil)
// 45:       synchronize { ns_initialize parties, &block }
// 46:     end
// 47:
// 48:     # @return [Fixnum] the number of threads needed to pass the barrier
// 49:     def parties
// 50:       synchronize { @parties }
// 51:     end
// 52:
// 53:     # @return [Fixnum] the number of threads currently waiting on the barrier
// 54:     def number_waiting
// 55:       synchronize { @number_waiting }
// 56:     end
// 57:
// 58:     # Blocks on the barrier until the number of waiting threads is equal to
// 59:     # `parties` or until `timeout` is reached or `reset` is called
// 60:     # If a block has been passed to the constructor, it will be executed once by
// 61:     #  the last arrived thread before releasing the others
// 62:     # @param [Fixnum] timeout the number of seconds to wait for the counter or
// 63:     #  `nil` to block indefinitely
// 64:     # @return [Boolean] `true` if the `count` reaches zero else false on
// 65:     #  `timeout` or on `reset` or if the barrier is broken
// 66:     def wait(timeout = nil)
// 67:       synchronize do
// 68:
// 69:         return false unless @generation.status == :waiting
// 70:
// 71:         @number_waiting += 1
// 72:
// 73:         if @number_waiting == @parties
// 74:           @action.call if @action
// 75:           ns_generation_done @generation, :fulfilled
// 76:           true
// 77:         else
// 78:           generation = @generation
// 79:           if ns_wait_until(timeout) { generation.status != :waiting }
// 80:             generation.status == :fulfilled
// 81:           else
// 82:             ns_generation_done generation, :broken, false
// 83:             false
// 84:           end
// 85:         end
// 86:       end
// 87:     end
// 88:
// 89:     # resets the barrier to its initial state
// 90:     # If there is at least one waiting thread, it will be woken up, the `wait`
// 91:     # method will return false and the barrier will be broken
// 92:     # If the barrier is broken, this method restores it to the original state
// 93:     #
// 94:     # @return [nil]
// 95:     def reset
// 96:       synchronize { ns_generation_done @generation, :reset }
// 97:     end
// 98:
// 99:     # A barrier can be broken when:
// 100:     # - a thread called the `reset` method while at least one other thread was waiting
// 101:     # - at least one thread timed out on `wait` method
// 102:     #
// 103:     # A broken barrier can be restored using `reset` it's safer to create a new one
// 104:     # @return [Boolean] true if the barrier is broken otherwise false
// 105:     def broken?
// 106:       synchronize { @generation.status != :waiting }
// 107:     end
// 108:
// 109:     protected
// 110:
// 111:     def ns_generation_done(generation, status, continue = true)
// 112:       generation.status = status
// 113:       ns_next_generation if continue
// 114:       ns_broadcast
// 115:     end
// 116:
// 117:     def ns_next_generation
// 118:       @generation     = Generation.new(:waiting)
// 119:       @number_waiting = 0
// 120:     end
// 121:
// 122:     def ns_initialize(parties, &block)
// 123:       @parties = parties
// 124:       @action  = block
// 125:       ns_next_generation
// 126:     end
// 127:   end
// 128: end
