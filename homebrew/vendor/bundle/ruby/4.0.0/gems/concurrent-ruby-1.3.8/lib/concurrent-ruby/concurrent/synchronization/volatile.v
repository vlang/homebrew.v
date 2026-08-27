module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/volatile.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.included(base)` at line 29.
pub fn ruby_volatile_l29_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `full_memory_barrier` at line 33.
pub fn ruby_volatile_l33_d2_full_memory_barrier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_memory_barrier', ...args)
}

// Ruby method `attr_volatile(*names)` at line 39.
pub fn ruby_volatile_l39_d3_attr_volatile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_volatile', ...args)
}

// Ruby method `#{name}` at line 43.
pub fn ruby_volatile_l43_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}', ...args)
}

// Ruby method `#{name}=(value)` at line 47.
pub fn ruby_volatile_l47_d5_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}=', ...args)
}

// Ruby method `attr_volatile(*names)` at line 56.
pub fn ruby_volatile_l56_d6_attr_volatile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_volatile', ...args)
}

// Ruby method `#{name}` at line 61.
pub fn ruby_volatile_l61_d7_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}', ...args)
}

// Ruby method `#{name}=(value)` at line 65.
pub fn ruby_volatile_l65_d8_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}=', ...args)
}

// Ruby method `attr_volatile(*names)` at line 77.
pub fn ruby_volatile_l77_d9_attr_volatile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_volatile', ...args)
}

// Ruby method `#{name}` at line 82.
pub fn ruby_volatile_l82_d10_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}', ...args)
}

// Ruby method `#{name}=(value)` at line 87.
pub fn ruby_volatile_l87_d11_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{name}=', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2: require 'concurrent/utility/engine'
// 3: require 'concurrent/synchronization/full_memory_barrier'
// 4:
// 5: module Concurrent
// 6:   module Synchronization
// 7:
// 8:     # Volatile adds the attr_volatile class method when included.
// 9:     #
// 10:     # @example
// 11:     #   class Foo
// 12:     #     include Concurrent::Synchronization::Volatile
// 13:     #
// 14:     #     attr_volatile :bar
// 15:     #
// 16:     #     def initialize
// 17:     #       self.bar = 1
// 18:     #     end
// 19:     #   end
// 20:     #
// 21:     #  foo = Foo.new
// 22:     #  foo.bar
// 23:     #  => 1
// 24:     #  foo.bar = 2
// 25:     #  => 2
// 26:     #
// 27:     # @!visibility private
// 28:     module Volatile
// 29:       def self.included(base)
// 30:         base.extend(ClassMethods)
// 31:       end
// 32:
// 33:       def full_memory_barrier
// 34:         Synchronization.full_memory_barrier
// 35:       end
// 36:
// 37:       module ClassMethods
// 38:         if Concurrent.on_cruby?
// 39:           def attr_volatile(*names)
// 40:             names.each do |name|
// 41:               ivar = :"@volatile_#{name}"
// 42:               class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 43:                 def #{name}
// 44:                   #{ivar}
// 45:                 end
// 46:
// 47:                 def #{name}=(value)
// 48:                   #{ivar} = value
// 49:                 end
// 50:               RUBY
// 51:             end
// 52:             names.map { |n| [n, :"#{n}="] }.flatten
// 53:           end
// 54:
// 55:         elsif Concurrent.on_jruby?
// 56:           def attr_volatile(*names)
// 57:             names.each do |name|
// 58:               ivar = :"@volatile_#{name}"
// 59:
// 60:               class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 61:                 def #{name}
// 62:                   ::Concurrent::Synchronization::JRubyAttrVolatile.instance_variable_get_volatile(self, :#{ivar})
// 63:                 end
// 64:
// 65:                 def #{name}=(value)
// 66:                   ::Concurrent::Synchronization::JRubyAttrVolatile.instance_variable_set_volatile(self, :#{ivar}, value)
// 67:                 end
// 68:               RUBY
// 69:
// 70:             end
// 71:             names.map { |n| [n, :"#{n}="] }.flatten
// 72:           end
// 73:
// 74:         else
// 75:           warn 'Possibly unsupported Ruby implementation' unless Concurrent.on_truffleruby?
// 76:
// 77:           def attr_volatile(*names)
// 78:             names.each do |name|
// 79:               ivar = :"@volatile_#{name}"
// 80:
// 81:               class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 82:                 def #{name}
// 83:                   ::Concurrent::Synchronization.full_memory_barrier
// 84:                   #{ivar}
// 85:                 end
// 86:
// 87:                 def #{name}=(value)
// 88:                   #{ivar} = value
// 89:                   ::Concurrent::Synchronization.full_memory_barrier
// 90:                 end
// 91:               RUBY
// 92:             end
// 93:
// 94:             names.map { |n| [n, :"#{n}="] }.flatten
// 95:           end
// 96:         end
// 97:       end
// 98:
// 99:     end
// 100:   end
// 101: end
