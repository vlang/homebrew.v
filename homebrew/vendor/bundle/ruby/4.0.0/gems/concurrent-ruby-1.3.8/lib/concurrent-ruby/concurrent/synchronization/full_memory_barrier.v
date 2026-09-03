module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/full_memory_barrier.rb`.
// The original source is retained below until every stub has a typed V body.

// full_memory_barrier publishes all writes made by the calling thread before any
// reads which follow the barrier. V's C backend exposes the same sequentially
// consistent fence used by its lock-free collections.
pub fn full_memory_barrier() {
	// C11 memory_order_seq_cst. V's generated C preamble declares the fence.
	C.atomic_thread_fence(5)
}

fn full_memory_barrier_value() brew_runtime.Value {
	full_memory_barrier()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.full_memory_barrier` at line 7.
pub fn ruby_full_memory_barrier_l7_d1_self_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return full_memory_barrier_value()
}

// Ruby method `self.full_memory_barrier` at line 14.
pub fn ruby_full_memory_barrier_l14_d2_self_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return full_memory_barrier_value()
}

// Ruby method `self.full_memory_barrier` at line 19.
pub fn ruby_full_memory_barrier_l19_d3_self_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return full_memory_barrier_value()
}

// Ruby method `self.full_memory_barrier` at line 25.
pub fn ruby_full_memory_barrier_l25_d4_self_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return full_memory_barrier_value()
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:     case
// 6:     when Concurrent.on_cruby?
// 7:       def self.full_memory_barrier
// 8:         # relying on undocumented behavior of CRuby, GVL acquire has lock which ensures visibility of ivars
// 9:         # https://github.com/ruby/ruby/blob/ruby_2_2/thread_pthread.c#L204-L211
// 10:       end
// 11:
// 12:     when Concurrent.on_jruby?
// 13:       require 'concurrent/utility/native_extension_loader'
// 14:       def self.full_memory_barrier
// 15:         JRubyAttrVolatile.full_memory_barrier
// 16:       end
// 17:
// 18:     when Concurrent.on_truffleruby?
// 19:       def self.full_memory_barrier
// 20:         TruffleRuby.full_memory_barrier
// 21:       end
// 22:
// 23:     else
// 24:       warn 'Possibly unsupported Ruby implementation'
// 25:       def self.full_memory_barrier
// 26:       end
// 27:     end
// 28:   end
// 29: end
