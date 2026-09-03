module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_enumerator_lazy.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn new_typed_enumerator_lazy_type(type_value brew_runtime.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Enumerator::Lazy', 'T::Enumerator::Lazy')
}

fn typed_enumerator_lazy_value(type_value brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_value(new_typed_enumerator_lazy_type(type_value))
}

// Ruby method `underlying_class` at line 6.
pub fn ruby_typed_enumerator_lazy_l6_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	typed_enumerable_from_args(args)
	return brew_runtime.object_value('Class', 'Enumerator::Lazy')
}

// Ruby method `name` at line 11.
pub fn ruby_typed_enumerator_lazy_l11_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 16.
pub fn ruby_typed_enumerator_lazy_l16_d3_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorLazy#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Lazy')
}

// Ruby method `valid?(obj)` at line 21.
pub fn ruby_typed_enumerator_lazy_l21_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorLazy#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Lazy')
}

// Ruby method `new(...)` at line 25.
pub fn ruby_typed_enumerator_lazy_l25_d5_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedEnumeratorLazy#new requires a receiver')
	}
	typed_enumerable_from_args(args)
	return typed_enumerator_new('Enumerator::Lazy', args[1..])
}

// Ruby method `initialize` at line 30.
pub fn ruby_typed_enumerator_lazy_l30_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_enumerator_lazy_value(base_type_boundary_value(base_untyped_type()))
}

// Ruby method `valid?(obj)` at line 34.
pub fn ruby_typed_enumerator_lazy_l34_d7_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorLazy::Untyped#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Lazy')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedEnumeratorLazy < TypedEnumerable
// 6:     def underlying_class
// 7:       Enumerator::Lazy
// 8:     end
// 9:
// 10:     # overrides Base
// 11:     def name
// 12:       "T::Enumerator::Lazy[#{type.name}]"
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def recursively_valid?(obj)
// 17:       obj.is_a?(Enumerator::Lazy) && super
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def valid?(obj)
// 22:       obj.is_a?(Enumerator::Lazy)
// 23:     end
// 24:
// 25:     def new(...)
// 26:       Enumerator::Lazy.new(...)
// 27:     end
// 28:
// 29:     class Untyped < TypedEnumeratorLazy
// 30:       def initialize
// 31:         super(T::Types::Untyped::Private::INSTANCE)
// 32:       end
// 33:
// 34:       def valid?(obj)
// 35:         obj.is_a?(Enumerator::Lazy)
// 36:       end
// 37:     end
// 38:   end
// 39: end
