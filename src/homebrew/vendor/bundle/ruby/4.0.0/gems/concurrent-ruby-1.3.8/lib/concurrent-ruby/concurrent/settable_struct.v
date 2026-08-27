module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/settable_struct.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `values` at line 18.
pub fn ruby_settable_struct_l18_d1_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values', ...args)
}

// Ruby alias_method `alias_method :to_a, :values` at line 21.
pub fn ruby_settable_struct_l21_d2_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_a', ...args)
}

// Ruby method `values_at(*indexes)` at line 24.
pub fn ruby_settable_struct_l24_d3_values_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values_at', ...args)
}

// Ruby method `inspect` at line 29.
pub fn ruby_settable_struct_l29_d4_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby alias_method `alias_method :to_s, :inspect` at line 32.
pub fn ruby_settable_struct_l32_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `merge(other, &block)` at line 35.
pub fn ruby_settable_struct_l35_d6_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge', ...args)
}

// Ruby method `to_h` at line 40.
pub fn ruby_settable_struct_l40_d7_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `[](member)` at line 45.
pub fn ruby_settable_struct_l45_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `==(other)` at line 50.
pub fn ruby_settable_struct_l50_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby method `each(&block)` at line 55.
pub fn ruby_settable_struct_l55_d10_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each', ...args)
}

// Ruby method `each_pair(&block)` at line 61.
pub fn ruby_settable_struct_l61_d11_each_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_pair', ...args)
}

// Ruby method `select(&block)` at line 67.
pub fn ruby_settable_struct_l67_d12_select(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select', ...args)
}

// Ruby method `[]=(member, value)` at line 75.
pub fn ruby_settable_struct_l75_d13_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]=', ...args)
}

// Ruby method `initialize_copy(original)` at line 97.
pub fn ruby_settable_struct_l97_d14_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_copy', ...args)
}

// Ruby method `self.new(*args, &block)` at line 105.
pub fn ruby_settable_struct_l105_d15_self_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.new', ...args)
}

// Ruby method `define_struct(name, members, &block)` at line 116.
pub fn ruby_settable_struct_l116_d16_define_struct(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_struct', ...args)
}

// Ruby define_method `clazz.send(:define_method, member) do` at line 121.
pub fn ruby_settable_struct_l121_d17_member(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('member', ...args)
}

// Ruby define_method `clazz.send(:define_method, "#{member}=") do |value|` at line 124.
pub fn ruby_settable_struct_l124_d18_member(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{member}=', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/errors'
// 2: require 'concurrent/synchronization/abstract_struct'
// 3: require 'concurrent/synchronization/lockable_object'
// 4:
// 5: module Concurrent
// 6:
// 7:   # An thread-safe, write-once variation of Ruby's standard `Struct`.
// 8:   # Each member can have its value set at most once, either at construction
// 9:   # or any time thereafter. Attempting to assign a value to a member
// 10:   # that has already been set will result in a `Concurrent::ImmutabilityError`.
// 11:   #
// 12:   # @see http://ruby-doc.org/core/Struct.html Ruby standard library `Struct`
// 13:   # @see http://en.wikipedia.org/wiki/Final_(Java) Java `final` keyword
// 14:   module SettableStruct
// 15:     include Synchronization::AbstractStruct
// 16:
// 17:     # @!macro struct_values
// 18:     def values
// 19:       synchronize { ns_values }
// 20:     end
// 21:     alias_method :to_a, :values
// 22:
// 23:     # @!macro struct_values_at
// 24:     def values_at(*indexes)
// 25:       synchronize { ns_values_at(indexes) }
// 26:     end
// 27:
// 28:     # @!macro struct_inspect
// 29:     def inspect
// 30:       synchronize { ns_inspect }
// 31:     end
// 32:     alias_method :to_s, :inspect
// 33:
// 34:     # @!macro struct_merge
// 35:     def merge(other, &block)
// 36:       synchronize { ns_merge(other, &block) }
// 37:     end
// 38:
// 39:     # @!macro struct_to_h
// 40:     def to_h
// 41:       synchronize { ns_to_h }
// 42:     end
// 43:
// 44:     # @!macro struct_get
// 45:     def [](member)
// 46:       synchronize { ns_get(member) }
// 47:     end
// 48:
// 49:     # @!macro struct_equality
// 50:     def ==(other)
// 51:       synchronize { ns_equality(other) }
// 52:     end
// 53:
// 54:     # @!macro struct_each
// 55:     def each(&block)
// 56:       return enum_for(:each) unless block_given?
// 57:       synchronize { ns_each(&block) }
// 58:     end
// 59:
// 60:     # @!macro struct_each_pair
// 61:     def each_pair(&block)
// 62:       return enum_for(:each_pair) unless block_given?
// 63:       synchronize { ns_each_pair(&block) }
// 64:     end
// 65:
// 66:     # @!macro struct_select
// 67:     def select(&block)
// 68:       return enum_for(:select) unless block_given?
// 69:       synchronize { ns_select(&block) }
// 70:     end
// 71:
// 72:     # @!macro struct_set
// 73:     #
// 74:     # @raise [Concurrent::ImmutabilityError] if the given member has already been set
// 75:     def []=(member, value)
// 76:       if member.is_a? Integer
// 77:         length = synchronize { @values.length }
// 78:         if member >= length
// 79:           raise IndexError.new("offset #{member} too large for struct(size:#{length})")
// 80:         end
// 81:         synchronize do
// 82:           unless @values[member].nil?
// 83:             raise Concurrent::ImmutabilityError.new('struct member has already been set')
// 84:           end
// 85:           @values[member] = value
// 86:         end
// 87:       else
// 88:         send("#{member}=", value)
// 89:       end
// 90:     rescue NoMethodError
// 91:       raise NameError.new("no member '#{member}' in struct")
// 92:     end
// 93:
// 94:     private
// 95:
// 96:     # @!visibility private
// 97:     def initialize_copy(original)
// 98:       synchronize do
// 99:         super(original)
// 100:         ns_initialize_copy
// 101:       end
// 102:     end
// 103:
// 104:     # @!macro struct_new
// 105:     def self.new(*args, &block)
// 106:       clazz_name = nil
// 107:       if args.length == 0
// 108:         raise ArgumentError.new('wrong number of arguments (0 for 1+)')
// 109:       elsif args.length > 0 && args.first.is_a?(String)
// 110:         clazz_name = args.shift
// 111:       end
// 112:       FACTORY.define_struct(clazz_name, args, &block)
// 113:     end
// 114:
// 115:     FACTORY = Class.new(Synchronization::LockableObject) do
// 116:       def define_struct(name, members, &block)
// 117:         synchronize do
// 118:           clazz = Synchronization::AbstractStruct.define_struct_class(SettableStruct, Synchronization::LockableObject, name, members, &block)
// 119:           members.each_with_index do |member, index|
// 120:             clazz.send :remove_method, member if clazz.instance_methods.include? member
// 121:             clazz.send(:define_method, member) do
// 122:               synchronize { @values[index] }
// 123:             end
// 124:             clazz.send(:define_method, "#{member}=") do |value|
// 125:               synchronize do
// 126:                 unless @values[index].nil?
// 127:                   raise Concurrent::ImmutabilityError.new('struct member has already been set')
// 128:                 end
// 129:                 @values[index] = value
// 130:               end
// 131:             end
// 132:           end
// 133:           clazz
// 134:         end
// 135:       end
// 136:     end.new
// 137:     private_constant :FACTORY
// 138:   end
// 139: end
