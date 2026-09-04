module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/t_enum.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TEnumType {
pub:
	value ruby.Value
}

pub fn new_t_enum_type(value ruby.Value) &TEnumType {
	return &TEnumType{
		value: value
	}
}

fn t_enum_values_equal(left ruby.Value, right ruby.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr && left.attributes == right.attributes && left.int_data == right.int_data
}

pub fn (_ &TEnumType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (enum_type &TEnumType) name() string {
	representation := enum_type.value.as_string()
	if representation.starts_with('#<') && representation.ends_with('>') && representation.len >= 3 {
		return representation[2..representation.len - 1]
	}
	return representation
}

pub fn (enum_type &TEnumType) valid(value ruby.Value) bool {
	return t_enum_values_equal(enum_type.value, value)
}

pub fn (enum_type &TEnumType) subtype_of_single(other ruby.Value) bool {
	if other.type_name == 'T::Types::TEnum' {
		other_value := other.map_data['value'] or { return false }
		return enum_type.valid(other_value)
	}
	if other.type_name == 'T::Types::Simple' {
		raw_type := other.attribute('raw_type') or { return false }
		return enum_type.value.type_name == raw_type
	}
	return false
}

fn t_enum_type_value(enum_type &TEnumType) ruby.Value {
	return ruby.Value{
		type_name: 'T::Types::TEnum'
		repr: enum_type.name()
		map_data: {
			'value': enum_type.value
		}
		attributes: {
			't_enum_type_address': u64(voidptr(enum_type)).str()
		}
	}
}

fn t_enum_type_from_args(args []ruby.Value) &TEnumType {
	if args.len == 0 {
		panic('TEnum method requires a receiver')
	}
	address := args[0].attribute('t_enum_type_address') or { panic('invalid TEnum receiver') }
	return unsafe { &TEnumType(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :val` at line 7.
pub fn ruby_t_enum_l7_d1_val(args ...ruby.Value) ruby.Value {
	return t_enum_type_from_args(args).value
}

// Ruby method `initialize(val)` at line 9.
pub fn ruby_t_enum_l9_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TEnum#initialize requires an enum value')
	}
	return t_enum_type_value(new_t_enum_type(args[0]))
}

// Ruby method `build_type` at line 13.
pub fn ruby_t_enum_l13_d3_build_type(args ...ruby.Value) ruby.Value {
	return t_enum_type_from_args(args).build_type()
}

// Ruby method `name` at line 18.
pub fn ruby_t_enum_l18_d4_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(t_enum_type_from_args(args).name())
}

// Ruby method `valid?(obj)` at line 28.
pub fn ruby_t_enum_l28_d5_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TEnum#valid? requires an object')
	}
	return ruby.bool_value(t_enum_type_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 33.
pub fn ruby_t_enum_l33_d6_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TEnum#subtype_of_single? requires another type')
	}
	return ruby.bool_value(t_enum_type_from_args(args).subtype_of_single(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object is equal to another T::Enum singleton value.
// 6:   class TEnum < Base
// 7:     attr_reader :val
// 8:
// 9:     def initialize(val)
// 10:       @val = val
// 11:     end
// 12:
// 13:     def build_type
// 14:       nil
// 15:     end
// 16:
// 17:     # overrides Base
// 18:     def name
// 19:       # Strips the #<...> off, just leaving the ...
// 20:       # Reasoning: the user will have written something like
// 21:       #   T.any(MyEnum::A, MyEnum::B)
// 22:       # in the type, so we should print what they wrote in errors, not:
// 23:       #   T.any(#<MyEnum::A>, #<MyEnum::B>)
// 24:       @val.inspect[2..-2]
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     def valid?(obj)
// 29:       @val == obj
// 30:     end
// 31:
// 32:     # overrides Base
// 33:     private def subtype_of_single?(other)
// 34:       case other
// 35:       when TEnum
// 36:         @val == other.val
// 37:       when Simple
// 38:         other.raw_type.===(@val)
// 39:       else
// 40:         false
// 41:       end
// 42:     end
// 43:   end
// 44: end
