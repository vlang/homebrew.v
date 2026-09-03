module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_set.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn new_typed_set_type(type_value brew_runtime.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Set', 'T::Set')
}

fn typed_set_value(type_value brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_value(new_typed_set_type(type_value))
}

pub fn typed_set_new(args []brew_runtime.Value) !brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.Value{
			type_name: 'Set'
			repr: '#<Set: {}>'
		}
	}
	values := args[0].as_array()!
	mut unique := []brew_runtime.Value{}
	for value in values {
		if !enum_members_contain(unique, value) {
			unique << value
		}
	}
	return brew_runtime.Value{
		type_name: 'Set'
		repr: '#<Set: {${unique.map(it.repr).join(', ')} }>'
		array_data: unique
	}
}

// Ruby method `underlying_class` at line 11.
pub fn ruby_typed_set_l11_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	typed_enumerable_from_args(args)
	return brew_runtime.object_value('Class', 'Set')
}

// Ruby method `name` at line 16.
pub fn ruby_typed_set_l16_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 21.
pub fn ruby_typed_set_l21_d3_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedSet#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 26.
pub fn ruby_typed_set_l26_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedSet#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Set')
}

// Ruby method `new(...)` at line 30.
pub fn ruby_typed_set_l30_d5_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedSet#new requires a receiver')
	}
	typed_enumerable_from_args(args)
	return typed_set_new(args[1..]) or { panic(err) }
}

// Ruby method `initialize` at line 35.
pub fn ruby_typed_set_l35_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_set_value(base_type_boundary_value(base_untyped_type()))
}

// Ruby method `valid?(obj)` at line 39.
pub fn ruby_typed_set_l39_d7_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedSet::Untyped#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Set')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedSet < TypedEnumerable
// 6:     # We can reference `Set` directly without a load guard: as of Ruby 3.2 it
// 7:     # ships as a default-autoloaded constant (Ruby registers `autoload :Set,
// 8:     # "set"`), so the first reference here transparently loads it. Ruby 3.3 --
// 9:     # the most recently supported release -- keeps this behavior, and Ruby 3.1
// 10:     # and earlier (which required an explicit `require "set"`) are past EOL.
// 11:     def underlying_class
// 12:       Set
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def name
// 17:       "T::Set[#{type.name}]"
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def recursively_valid?(obj)
// 22:       obj.is_a?(Set) && super
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     def valid?(obj)
// 27:       obj.is_a?(Set)
// 28:     end
// 29:
// 30:     def new(...)
// 31:       Set.new(...)
// 32:     end
// 33:
// 34:     class Untyped < TypedSet
// 35:       def initialize
// 36:         super(T::Types::Untyped::Private::INSTANCE)
// 37:       end
// 38:
// 39:       def valid?(obj)
// 40:         obj.is_a?(Set)
// 41:       end
// 42:     end
// 43:   end
// 44: end
