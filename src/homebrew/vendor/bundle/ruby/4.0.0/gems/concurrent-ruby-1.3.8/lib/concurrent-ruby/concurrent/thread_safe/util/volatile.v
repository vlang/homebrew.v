module util

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/volatile.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `attr_volatile(*attr_names)` at line 33.
pub fn ruby_volatile_l33_d1_attr_volatile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_volatile', ...args)
}

// Ruby method `initialize(*)` at line 41.
pub fn ruby_volatile_l41_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize_copy(other)` at line 46.
pub fn ruby_volatile_l46_d3_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_copy', ...args)
}

// Ruby method `#{attr_name}` at line 54.
pub fn ruby_volatile_l54_d4_attr_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{attr_name}', ...args)
}

// Ruby method `#{attr_name}=(value)` at line 58.
pub fn ruby_volatile_l58_d5_attr_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{attr_name}=', ...args)
}

// Ruby method `compare_and_set_#{attr_name}(old_value, new_value)` at line 62.
pub fn ruby_volatile_l62_d6_compare_and_set_attr_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_#{attr_name}', ...args)
}

// Ruby alias_method `alias_method :"cas_#{attr_name}", :"compare_and_set_#{attr_name}"` at line 67.
pub fn ruby_volatile_l67_d7_cas_attr_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cas_#{attr_name}', ...args)
}

// Ruby alias_method `alias_method :"lazy_set_#{attr_name}", :"#{attr_name}="` at line 68.
pub fn ruby_volatile_l68_d8_lazy_set_attr_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lazy_set_#{attr_name}', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module ThreadSafe
// 7:
// 8:     # @!visibility private
// 9:     module Util
// 10:
// 11:       # @!visibility private
// 12:       module Volatile
// 13:
// 14:         # Provides +volatile+ (in the JVM's sense) attribute accessors implemented
// 15:         # atop of +Concurrent::AtomicReference+.
// 16:         #
// 17:         # Usage:
// 18:         #   class Foo
// 19:         #     extend Concurrent::ThreadSafe::Util::Volatile
// 20:         #     attr_volatile :foo, :bar
// 21:         #
// 22:         #     def initialize(bar)
// 23:         #       super() # must super() into parent initializers before using the volatile attribute accessors
// 24:         #       self.bar = bar
// 25:         #     end
// 26:         #
// 27:         #     def hello
// 28:         #       my_foo = foo # volatile read
// 29:         #       self.foo = 1 # volatile write
// 30:         #       cas_foo(1, 2) # => true | a strong CAS
// 31:         #     end
// 32:         #   end
// 33:         def attr_volatile(*attr_names)
// 34:           return if attr_names.empty?
// 35:           include(Module.new do
// 36:             atomic_ref_setup = attr_names.map {|attr_name| "@__#{attr_name} = Concurrent::AtomicReference.new"}
// 37:             initialize_copy_setup = attr_names.zip(atomic_ref_setup).map do |attr_name, ref_setup|
// 38:               "#{ref_setup}(other.instance_variable_get(:@__#{attr_name}).get)"
// 39:             end
// 40:             class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
// 41:             def initialize(*)
// 42:               super
// 43:             #{atomic_ref_setup.join('; ')}
// 44:             end
// 45:
// 46:             def initialize_copy(other)
// 47:               super
// 48:             #{initialize_copy_setup.join('; ')}
// 49:             end
// 50:             RUBY_EVAL
// 51:
// 52:             attr_names.each do |attr_name|
// 53:               class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
// 54:               def #{attr_name}
// 55:                 @__#{attr_name}.get
// 56:               end
// 57:
// 58:               def #{attr_name}=(value)
// 59:                 @__#{attr_name}.set(value)
// 60:               end
// 61:
// 62:               def compare_and_set_#{attr_name}(old_value, new_value)
// 63:                 @__#{attr_name}.compare_and_set(old_value, new_value)
// 64:               end
// 65:               RUBY_EVAL
// 66:
// 67:               alias_method :"cas_#{attr_name}", :"compare_and_set_#{attr_name}"
// 68:               alias_method :"lazy_set_#{attr_name}", :"#{attr_name}="
// 69:             end
// 70:           end)
// 71:         end
// 72:       end
// 73:     end
// 74:   end
// 75: end
