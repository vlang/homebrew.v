module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/immutable_struct.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.included(base)` at line 12.
pub fn ruby_immutable_struct_l12_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `values` at line 17.
pub fn ruby_immutable_struct_l17_d2_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values', ...args)
}

// Ruby alias_method `alias_method :to_a, :values` at line 21.
pub fn ruby_immutable_struct_l21_d3_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_a', ...args)
}

// Ruby method `values_at(*indexes)` at line 24.
pub fn ruby_immutable_struct_l24_d4_values_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values_at', ...args)
}

// Ruby method `inspect` at line 29.
pub fn ruby_immutable_struct_l29_d5_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby alias_method `alias_method :to_s, :inspect` at line 33.
pub fn ruby_immutable_struct_l33_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `merge(other, &block)` at line 36.
pub fn ruby_immutable_struct_l36_d7_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge', ...args)
}

// Ruby method `to_h` at line 41.
pub fn ruby_immutable_struct_l41_d8_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `[](member)` at line 46.
pub fn ruby_immutable_struct_l46_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `==(other)` at line 51.
pub fn ruby_immutable_struct_l51_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby method `each(&block)` at line 56.
pub fn ruby_immutable_struct_l56_d11_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each', ...args)
}

// Ruby method `each_pair(&block)` at line 62.
pub fn ruby_immutable_struct_l62_d12_each_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_pair', ...args)
}

// Ruby method `select(&block)` at line 68.
pub fn ruby_immutable_struct_l68_d13_select(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select', ...args)
}

// Ruby method `initialize_copy(original)` at line 76.
pub fn ruby_immutable_struct_l76_d14_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_copy', ...args)
}

// Ruby method `self.new(*args, &block)` at line 82.
pub fn ruby_immutable_struct_l82_d15_self_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.new', ...args)
}

// Ruby method `define_struct(name, members, &block)` at line 93.
pub fn ruby_immutable_struct_l93_d16_define_struct(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_struct', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/abstract_struct'
// 2: require 'concurrent/synchronization/lockable_object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A thread-safe, immutable variation of Ruby's standard `Struct`.
// 7:   #
// 8:   # @see http://ruby-doc.org/core/Struct.html Ruby standard library `Struct`
// 9:   module ImmutableStruct
// 10:     include Synchronization::AbstractStruct
// 11:
// 12:     def self.included(base)
// 13:       base.safe_initialization!
// 14:     end
// 15:
// 16:     # @!macro struct_values
// 17:     def values
// 18:       ns_values
// 19:     end
// 20:
// 21:     alias_method :to_a, :values
// 22:
// 23:     # @!macro struct_values_at
// 24:     def values_at(*indexes)
// 25:       ns_values_at(indexes)
// 26:     end
// 27:
// 28:     # @!macro struct_inspect
// 29:     def inspect
// 30:       ns_inspect
// 31:     end
// 32:
// 33:     alias_method :to_s, :inspect
// 34:
// 35:     # @!macro struct_merge
// 36:     def merge(other, &block)
// 37:       ns_merge(other, &block)
// 38:     end
// 39:
// 40:     # @!macro struct_to_h
// 41:     def to_h
// 42:       ns_to_h
// 43:     end
// 44:
// 45:     # @!macro struct_get
// 46:     def [](member)
// 47:       ns_get(member)
// 48:     end
// 49:
// 50:     # @!macro struct_equality
// 51:     def ==(other)
// 52:       ns_equality(other)
// 53:     end
// 54:
// 55:     # @!macro struct_each
// 56:     def each(&block)
// 57:       return enum_for(:each) unless block_given?
// 58:       ns_each(&block)
// 59:     end
// 60:
// 61:     # @!macro struct_each_pair
// 62:     def each_pair(&block)
// 63:       return enum_for(:each_pair) unless block_given?
// 64:       ns_each_pair(&block)
// 65:     end
// 66:
// 67:     # @!macro struct_select
// 68:     def select(&block)
// 69:       return enum_for(:select) unless block_given?
// 70:       ns_select(&block)
// 71:     end
// 72:
// 73:     private
// 74:
// 75:     # @!visibility private
// 76:     def initialize_copy(original)
// 77:       super(original)
// 78:       ns_initialize_copy
// 79:     end
// 80:
// 81:     # @!macro struct_new
// 82:     def self.new(*args, &block)
// 83:       clazz_name = nil
// 84:       if args.length == 0
// 85:         raise ArgumentError.new('wrong number of arguments (0 for 1+)')
// 86:       elsif args.length > 0 && args.first.is_a?(String)
// 87:         clazz_name = args.shift
// 88:       end
// 89:       FACTORY.define_struct(clazz_name, args, &block)
// 90:     end
// 91:
// 92:     FACTORY = Class.new(Synchronization::LockableObject) do
// 93:       def define_struct(name, members, &block)
// 94:         synchronize do
// 95:           Synchronization::AbstractStruct.define_struct_class(ImmutableStruct, Synchronization::Object, name, members, &block)
// 96:         end
// 97:       end
// 98:     end.new
// 99:     private_constant :FACTORY
// 100:   end
// 101: end
