module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_enumerator.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn new_typed_enumerator_type(type_value ruby.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Enumerator', 'T::Enumerator')
}

fn typed_enumerator_value(type_value ruby.Value) ruby.Value {
	return typed_enumerable_value(new_typed_enumerator_type(type_value))
}

pub fn typed_enumerator_new(kind string, args []ruby.Value) ruby.Value {
	mut yielded := []ruby.Value{}
	for arg in args {
		if arg.type_name in ['Array', 'Set', 'Enumerator', 'Enumerator::Lazy', 'Enumerator::Chain'] {
			yielded << arg.array_data
		} else {
			yielded << arg
		}
	}
	return ruby.Value{
		type_name: kind
		repr: '#<${kind}>'
		array_data: yielded
	}
}

// Ruby method `underlying_class` at line 6.
pub fn ruby_typed_enumerator_l6_d1_underlying_class(args ...ruby.Value) ruby.Value {
	typed_enumerable_from_args(args)
	return ruby.object_value('Class', 'Enumerator')
}

// Ruby method `name` at line 11.
pub fn ruby_typed_enumerator_l11_d2_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 16.
pub fn ruby_typed_enumerator_l16_d3_recursively_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypedEnumerator#recursively_valid? requires an object')
	}
	return ruby.bool_value(args[1].type_name.starts_with('Enumerator'))
}

// Ruby method `valid?(obj)` at line 21.
pub fn ruby_typed_enumerator_l21_d4_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypedEnumerator#valid? requires an object')
	}
	return ruby.bool_value(args[1].type_name.starts_with('Enumerator'))
}

// Ruby method `new(...)` at line 25.
pub fn ruby_typed_enumerator_l25_d5_new(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypedEnumerator#new requires a receiver')
	}
	typed_enumerable_from_args(args)
	return typed_enumerator_new('Enumerator', args[1..])
}

// Ruby method `initialize` at line 30.
pub fn ruby_typed_enumerator_l30_d6_initialize(args ...ruby.Value) ruby.Value {
	return typed_enumerator_value(base_type_boundary_value(base_untyped_type()))
}

// Ruby method `valid?(obj)` at line 34.
pub fn ruby_typed_enumerator_l34_d7_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypedEnumerator::Untyped#valid? requires an object')
	}
	return ruby.bool_value(args[1].type_name.starts_with('Enumerator'))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedEnumerator < TypedEnumerable
// 6:     def underlying_class
// 7:       Enumerator
// 8:     end
// 9:
// 10:     # overrides Base
// 11:     def name
// 12:       "T::Enumerator[#{type.name}]"
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def recursively_valid?(obj)
// 17:       obj.is_a?(Enumerator) && super
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def valid?(obj)
// 22:       obj.is_a?(Enumerator)
// 23:     end
// 24:
// 25:     def new(...)
// 26:       Enumerator.new(...)
// 27:     end
// 28:
// 29:     class Untyped < TypedEnumerator
// 30:       def initialize
// 31:         super(T::Types::Untyped::Private::INSTANCE)
// 32:       end
// 33:
// 34:       def valid?(obj)
// 35:         obj.is_a?(Enumerator)
// 36:       end
// 37:     end
// 38:   end
// 39: end
