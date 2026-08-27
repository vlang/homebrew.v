module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/cyclic_barrier.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(parties, &block)` at line 40.
pub fn ruby_cyclic_barrier_l40_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `parties` at line 49.
pub fn ruby_cyclic_barrier_l49_d2_parties(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parties', ...args)
}

// Ruby method `number_waiting` at line 54.
pub fn ruby_cyclic_barrier_l54_d3_number_waiting(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('number_waiting', ...args)
}

// Ruby method `wait(timeout = nil)` at line 66.
pub fn ruby_cyclic_barrier_l66_d4_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `reset` at line 95.
pub fn ruby_cyclic_barrier_l95_d5_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset', ...args)
}

// Ruby method `broken?` at line 105.
pub fn ruby_cyclic_barrier_l105_d6_broken(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('broken?', ...args)
}

// Ruby method `ns_generation_done(generation, status, continue = true)` at line 111.
pub fn ruby_cyclic_barrier_l111_d7_ns_generation_done(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_generation_done', ...args)
}

// Ruby method `ns_next_generation` at line 117.
pub fn ruby_cyclic_barrier_l117_d8_ns_next_generation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_next_generation', ...args)
}

// Ruby method `ns_initialize(parties, &block)` at line 122.
pub fn ruby_cyclic_barrier_l122_d9_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
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
