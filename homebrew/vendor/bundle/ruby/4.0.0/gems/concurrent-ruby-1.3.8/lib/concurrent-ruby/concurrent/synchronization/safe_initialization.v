module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/safe_initialization.rb`.
// The original source is retained below until every stub has a typed V body.

// safely_initialize mirrors the Ruby ensure clause: construction errors are
// propagated, but the publication fence always runs.
pub fn safely_initialize[T](constructor fn() !T) !T {
	defer {
		full_memory_barrier()
	}
	return constructor()
}

// Ruby method `new(*args, &block)` at line 29.
pub fn ruby_safe_initialization_l29_d1_new(args ...brew_runtime.Value) brew_runtime.Value {
	defer {
		full_memory_barrier()
	}
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/full_memory_barrier'
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:
// 6:     # @!visibility private
// 7:     # @!macro internal_implementation_note
// 8:     #
// 9:     # By extending this module, a class and all its children are marked to be constructed safely. Meaning that
// 10:     # all writes (ivar initializations) are made visible to all readers of newly constructed object. It ensures
// 11:     # same behaviour as Java's final fields.
// 12:     #
// 13:     # Due to using Kernel#extend, the module is not included again if already present in the ancestors,
// 14:     # which avoids extra overhead.
// 15:     #
// 16:     # @example
// 17:     #   class AClass < Concurrent::Synchronization::Object
// 18:     #     extend Concurrent::Synchronization::SafeInitialization
// 19:     #
// 20:     #     def initialize
// 21:     #       @AFinalValue = 'value' # published safely, #foo will never return nil
// 22:     #     end
// 23:     #
// 24:     #     def foo
// 25:     #       @AFinalValue
// 26:     #     end
// 27:     #   end
// 28:     module SafeInitialization
// 29:       def new(*args, &block)
// 30:         super(*args, &block)
// 31:       ensure
// 32:         Concurrent::Synchronization.full_memory_barrier
// 33:       end
// 34:     end
// 35:   end
// 36: end
