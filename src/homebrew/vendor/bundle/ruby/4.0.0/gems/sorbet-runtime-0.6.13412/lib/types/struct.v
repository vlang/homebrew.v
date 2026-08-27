module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/struct.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.inherited(subclass)` at line 11.
pub fn ruby_struct_l11_d1_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.inherited', ...args)
}

// Ruby method `self.inherited(subclass)` at line 24.
pub fn ruby_struct_l24_d2_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.inherited', ...args)
}

// Ruby method `initialize(hash={})` at line 36.
pub fn ruby_struct_l36_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.prop(name, cls, **rules)` at line 44.
pub fn ruby_struct_l44_d4_self_prop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.prop', ...args)
}

// Ruby method `with(changed_props)` at line 50.
pub fn ruby_struct_l50_d5_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: class T::InexactStruct
// 5:   include T::Props
// 6:   include T::Props::Serializable
// 7:   include T::Props::Constructor
// 8: end
// 9:
// 10: class T::Struct < T::InexactStruct
// 11:   def self.inherited(subclass)
// 12:     super(subclass)
// 13:     original_method = subclass.singleton_class.instance_method(:inherited)
// 14:     T::Private::ClassUtils.replace_method(original_method, subclass.singleton_class, :inherited) do |s|
// 15:       super(s)
// 16:       raise "#{self.name} is a subclass of T::Struct and cannot be subclassed"
// 17:     end
// 18:   end
// 19: end
// 20:
// 21: class T::ImmutableStruct < T::InexactStruct
// 22:   extend T::Sig
// 23:
// 24:   def self.inherited(subclass)
// 25:     super(subclass)
// 26:
// 27:     original_method = subclass.singleton_class.instance_method(:inherited)
// 28:     T::Private::ClassUtils.replace_method(original_method, subclass.singleton_class, :inherited) do |s|
// 29:       super(s)
// 30:       raise "#{self.name} is a subclass of T::ImmutableStruct and cannot be subclassed"
// 31:     end
// 32:   end
// 33:
// 34:   # Matches the one in WeakConstructor, but freezes the object
// 35:   sig { params(hash: T::Hash[Symbol, T.untyped]).void.checked(:never) }
// 36:   def initialize(hash={})
// 37:     super
// 38:
// 39:     freeze
// 40:   end
// 41:
// 42:   # Matches the signature in Props, but raises since this is an immutable struct and only const is allowed
// 43:   sig { params(name: Symbol, cls: T.untyped, rules: T.untyped).void }
// 44:   def self.prop(name, cls, **rules)
// 45:     return super if (cls.is_a?(Hash) && cls[:immutable]) || rules[:immutable]
// 46:
// 47:     raise "Cannot use `prop` in #{self.name} because it is an immutable struct. Use `const` instead"
// 48:   end
// 49:
// 50:   def with(changed_props)
// 51:     raise "Cannot use `with` in #{self.class.name} because it is an immutable struct"
// 52:   end
// 53: end
