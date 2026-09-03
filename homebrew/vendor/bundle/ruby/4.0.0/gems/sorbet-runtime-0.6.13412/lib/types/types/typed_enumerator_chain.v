module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_enumerator_chain.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn new_typed_enumerator_chain_type(type_value brew_runtime.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Enumerator::Chain', 'T::Enumerator::Chain')
}

fn typed_enumerator_chain_value(type_value brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_value(new_typed_enumerator_chain_type(type_value))
}

// Ruby method `underlying_class` at line 6.
pub fn ruby_typed_enumerator_chain_l6_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	typed_enumerable_from_args(args)
	return brew_runtime.object_value('Class', 'Enumerator::Chain')
}

// Ruby method `name` at line 11.
pub fn ruby_typed_enumerator_chain_l11_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 16.
pub fn ruby_typed_enumerator_chain_l16_d3_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorChain#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Chain')
}

// Ruby method `valid?(obj)` at line 21.
pub fn ruby_typed_enumerator_chain_l21_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorChain#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Chain')
}

// Ruby method `new(...)` at line 25.
pub fn ruby_typed_enumerator_chain_l25_d5_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedEnumeratorChain#new requires a receiver')
	}
	typed_enumerable_from_args(args)
	return typed_enumerator_new('Enumerator::Chain', args[1..])
}

// Ruby method `initialize` at line 30.
pub fn ruby_typed_enumerator_chain_l30_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_enumerator_chain_value(base_type_boundary_value(base_untyped_type()))
}

// Ruby method `valid?(obj)` at line 34.
pub fn ruby_typed_enumerator_chain_l34_d7_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumeratorChain::Untyped#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Enumerator::Chain')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedEnumeratorChain < TypedEnumerable
// 6:     def underlying_class
// 7:       Enumerator::Chain
// 8:     end
// 9:
// 10:     # overrides Base
// 11:     def name
// 12:       "T::Enumerator::Chain[#{type.name}]"
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def recursively_valid?(obj)
// 17:       obj.is_a?(Enumerator::Chain) && super
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def valid?(obj)
// 22:       obj.is_a?(Enumerator::Chain)
// 23:     end
// 24:
// 25:     def new(...)
// 26:       Enumerator::Chain.new(...)
// 27:     end
// 28:
// 29:     class Untyped < TypedEnumeratorChain
// 30:       def initialize
// 31:         super(T::Types::Untyped::Private::INSTANCE)
// 32:       end
// 33:
// 34:       def valid?(obj)
// 35:         obj.is_a?(Enumerator::Chain)
// 36:       end
// 37:     end
// 38:   end
// 39: end
