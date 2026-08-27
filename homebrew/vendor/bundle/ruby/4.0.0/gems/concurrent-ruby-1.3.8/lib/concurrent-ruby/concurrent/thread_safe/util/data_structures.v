module util

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/data_structures.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.synchronized(object, &block)` at line 7.
pub fn ruby_data_structures_l7_d1_self_synchronized(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.synchronized', ...args)
}

// Ruby method `self.make_synchronized_on_cruby(klass)` at line 16.
pub fn ruby_data_structures_l16_d2_self_make_synchronized_on_cruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.make_synchronized_on_cruby', ...args)
}

// Ruby method `initialize(*args, &block)` at line 18.
pub fn ruby_data_structures_l18_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize_copy(other)` at line 23.
pub fn ruby_data_structures_l23_d4_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_copy', ...args)
}

// Ruby method `#{method}(*args)` at line 32.
pub fn ruby_data_structures_l32_d5_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{method}', ...args)
}

// Ruby method `self.make_synchronized_on_truffleruby(klass)` at line 41.
pub fn ruby_data_structures_l41_d6_self_make_synchronized_on_truffleruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.make_synchronized_on_truffleruby', ...args)
}

// Ruby method `#{method}(*args, &block)` at line 44.
pub fn ruby_data_structures_l44_d7_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{method}', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/utility/engine'
// 3:
// 4: # Shim for TruffleRuby.synchronized
// 5: if Concurrent.on_truffleruby? && !TruffleRuby.respond_to?(:synchronized)
// 6:   module TruffleRuby
// 7:     def self.synchronized(object, &block)
// 8:       Truffle::System.synchronized(object, &block)
// 9:     end
// 10:   end
// 11: end
// 12:
// 13: module Concurrent
// 14:   module ThreadSafe
// 15:     module Util
// 16:       def self.make_synchronized_on_cruby(klass)
// 17:         klass.class_eval do
// 18:           def initialize(*args, &block)
// 19:             @_monitor = Monitor.new
// 20:             super
// 21:           end
// 22:
// 23:           def initialize_copy(other)
// 24:             # make sure a copy is not sharing a monitor with the original object!
// 25:             @_monitor = Monitor.new
// 26:             super
// 27:           end
// 28:         end
// 29:
// 30:         klass.superclass.instance_methods(false).each do |method|
// 31:           klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 32:             def #{method}(*args)
// 33:               monitor = @_monitor
// 34:               monitor or raise("BUG: Internal monitor was not properly initialized. Please report this to the concurrent-ruby developers.")
// 35:               monitor.synchronize { super }
// 36:             end
// 37:           RUBY
// 38:         end
// 39:       end
// 40:
// 41:       def self.make_synchronized_on_truffleruby(klass)
// 42:         klass.superclass.instance_methods(false).each do |method|
// 43:           klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 44:             def #{method}(*args, &block)
// 45:               TruffleRuby.synchronized(self) { super(*args, &block) }
// 46:             end
// 47:           RUBY
// 48:         end
// 49:       end
// 50:     end
// 51:   end
// 52: end
