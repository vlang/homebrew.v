module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/abstract_object.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 7.
pub fn ruby_abstract_object_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `full_memory_barrier` at line 13.
pub fn ruby_abstract_object_l13_d2_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_memory_barrier', ...args)
}

// Ruby method `self.attr_volatile(*names)` at line 17.
pub fn ruby_abstract_object_l17_d3_self_attr_volatile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.attr_volatile', ...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Synchronization
// 3:
// 4:     # @!visibility private
// 5:     # @!macro internal_implementation_note
// 6:     class AbstractObject
// 7:       def initialize
// 8:         # nothing to do
// 9:       end
// 10:
// 11:       # @!visibility private
// 12:       # @abstract
// 13:       def full_memory_barrier
// 14:         raise NotImplementedError
// 15:       end
// 16:
// 17:       def self.attr_volatile(*names)
// 18:         raise NotImplementedError
// 19:       end
// 20:     end
// 21:   end
// 22: end
