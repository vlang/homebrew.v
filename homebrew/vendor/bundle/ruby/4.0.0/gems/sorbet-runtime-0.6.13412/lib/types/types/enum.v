module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/enum.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct EnumType {
pub:
	values  ruby.Value
	members []ruby.Value
}

pub fn new_enum_type(values ruby.Value) !&EnumType {
	mut members := []ruby.Value{}
	if values.type_name == 'Hash' {
		for key, _ in values.map_data {
			members << ruby.string_value(key)
		}
	} else {
		for value in values.as_array()! {
			if !enum_members_contain(members, value) {
				members << value
			}
		}
	}
	return &EnumType{
		values: values
		members: members
	}
}

fn enum_values_equal(left ruby.Value, right ruby.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr && left.bool_data == right.bool_data && left.int_data == right.int_data && left.float_data == right.float_data && left.string_array_data == right.string_array_data && left.array_data == right.array_data && left.map_data == right.map_data && left.attributes == right.attributes
}

fn enum_members_contain(values []ruby.Value, candidate ruby.Value) bool {
	return values.any(enum_values_equal(it, candidate))
}

pub fn (_ &EnumType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (enum_type &EnumType) valid(value ruby.Value) bool {
	return enum_members_contain(enum_type.members, value)
}

pub fn (enum_type &EnumType) subtype_of(other &EnumType) bool {
	return enum_type.members.all(enum_members_contain(other.members, it))
}

fn enum_inspect(value ruby.Value) string {
	if value.type_name == 'String' {
		return '"${value.repr.replace('\\', '\\\\').replace('"', '\\"')}"'
	}
	return value.repr
}

pub fn (enum_type &EnumType) name() string {
	mut names := enum_type.members.map(enum_inspect(it))
	names.sort()
	return 'T.deprecated_enum([${names.join(', ')}])'
}

pub fn (_ &EnumType) describe_obj(value ruby.Value) string {
	return enum_inspect(value)
}

fn enum_type_value(enum_type &EnumType) ruby.Value {
	return ruby.Value{
		type_name: 'T::Types::Enum'
		repr: enum_type.name()
		map_data: {
			'values': enum_type.values
		}
		attributes: {
			'enum_type_address': u64(voidptr(enum_type)).str()
		}
	}
}

fn enum_type_from_args(args []ruby.Value) &EnumType {
	if args.len == 0 {
		panic('Enum method requires a receiver')
	}
	address := args[0].attribute('enum_type_address') or { panic('invalid Enum receiver') }
	return unsafe { &EnumType(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :values` at line 9.
pub fn ruby_enum_l9_d1_values(args ...ruby.Value) ruby.Value {
	return enum_type_from_args(args).values
}

// Ruby method `initialize(values)` at line 11.
pub fn ruby_enum_l11_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Enum#initialize requires values')
	}
	return enum_type_value(new_enum_type(args[0]) or { panic(err.msg()) })
}

// Ruby method `build_type` at line 21.
pub fn ruby_enum_l21_d3_build_type(args ...ruby.Value) ruby.Value {
	return enum_type_from_args(args).build_type()
}

// Ruby method `valid?(obj)` at line 26.
pub fn ruby_enum_l26_d4_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Enum#valid? requires an object')
	}
	return ruby.bool_value(enum_type_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 31.
pub fn ruby_enum_l31_d5_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'T::Types::Enum' {
		return ruby.bool_value(false)
	}
	other := enum_type_from_args(args[1..])
	return ruby.bool_value(enum_type_from_args(args).subtype_of(other))
}

// Ruby method `name` at line 41.
pub fn ruby_enum_l41_d6_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(enum_type_from_args(args).name())
}

// Ruby method `describe_obj(obj)` at line 46.
pub fn ruby_enum_l46_d7_describe_obj(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Enum#describe_obj requires an object')
	}
	return ruby.string_value(enum_type_from_args(args).describe_obj(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # validates that the provided value is within a given set/enum
// 6:   class Enum < Base
// 7:     extend T::Sig
// 8:
// 9:     attr_reader :values
// 10:
// 11:     def initialize(values)
// 12:       case values
// 13:       when Hash
// 14:         @values = values
// 15:       else
// 16:         require "set" unless defined?(Set)
// 17:         @values = values.to_set
// 18:       end
// 19:     end
// 20:
// 21:     def build_type
// 22:       nil
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     def valid?(obj)
// 27:       @values.member?(obj)
// 28:     end
// 29:
// 30:     # overrides Base
// 31:     private def subtype_of_single?(other)
// 32:       case other
// 33:       when Enum
// 34:         (@values - other.values).empty?
// 35:       else
// 36:         false
// 37:       end
// 38:     end
// 39:
// 40:     # overrides Base
// 41:     def name
// 42:       @name ||= "T.deprecated_enum([#{@values.map(&:inspect).sort.join(', ')}])"
// 43:     end
// 44:
// 45:     # overrides Base
// 46:     def describe_obj(obj)
// 47:       obj.inspect
// 48:     end
// 49:   end
// 50: end
