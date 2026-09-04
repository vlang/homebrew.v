module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/class_of.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct ClassOfType {
pub:
	type_value ruby.Value
}

pub fn new_class_of_type(type_value ruby.Value) &ClassOfType {
	return &ClassOfType{
		type_value: type_value
	}
}

pub fn (_ &ClassOfType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (class_type &ClassOfType) name() string {
	return 'T.class_of(${class_type.type_value.as_string()})'
}

fn class_value_is_a(value ruby.Value, target string) bool {
	if value.as_string() == target || value.type_name == target {
		return true
	}
	ancestors := value.attribute('ancestors') or { return false }
	return ancestors.split(',').map(it.trim_space()).any(it == target)
}

pub fn (class_type &ClassOfType) valid(value ruby.Value) bool {
	if value.type_name != 'Class' && value.type_name != 'Module' {
		return false
	}
	return class_value_is_a(value, class_type.type_value.as_string())
}

pub fn (class_type &ClassOfType) subtype_of_single(other ruby.Value) bool {
	match other.type_name {
		'T::Types::ClassOf' {
			other_type := other.map_data['type'] or { return false }
			return class_value_is_a(class_type.type_value, other_type.as_string())
		}
		'T::Types::Simple' {
			raw_type := other.attribute('raw_type') or { return false }
			return class_value_is_a(class_type.type_value, raw_type)
		}
		'T::Types::TypedClass', 'T::Types::TypedModule' {
			underlying_class := other.attribute('underlying_class') or { return false }
			return class_value_is_a(class_type.type_value, underlying_class)
		}
		else {
			return false
		}
	}
}

pub fn (_ &ClassOfType) describe_obj(value ruby.Value) string {
	return value.as_string()
}

fn class_of_type_value(class_type &ClassOfType) ruby.Value {
	return ruby.Value{
		type_name: 'T::Types::ClassOf'
		repr: class_type.name()
		map_data: {
			'type': class_type.type_value
		}
		attributes: {
			'class_of_type_address': u64(voidptr(class_type)).str()
		}
	}
}

fn class_of_type_from_args(args []ruby.Value) &ClassOfType {
	if args.len == 0 {
		panic('ClassOf method requires a receiver')
	}
	address := args[0].attribute('class_of_type_address') or {
		panic('invalid ClassOf receiver')
	}
	return unsafe { &ClassOfType(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :type` at line 7.
pub fn ruby_class_of_l7_d1_type(args ...ruby.Value) ruby.Value {
	return class_of_type_from_args(args).type_value
}

// Ruby method `initialize(type)` at line 9.
pub fn ruby_class_of_l9_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ClassOf#initialize requires a type')
	}
	return class_of_type_value(new_class_of_type(args[0]))
}

// Ruby method `build_type` at line 13.
pub fn ruby_class_of_l13_d3_build_type(args ...ruby.Value) ruby.Value {
	return class_of_type_from_args(args).build_type()
}

// Ruby method `name` at line 18.
pub fn ruby_class_of_l18_d4_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(class_of_type_from_args(args).name())
}

// Ruby method `valid?(obj)` at line 23.
pub fn ruby_class_of_l23_d5_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ClassOf#valid? requires an object')
	}
	return ruby.bool_value(class_of_type_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 28.
pub fn ruby_class_of_l28_d6_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ClassOf#subtype_of_single? requires another type')
	}
	return ruby.bool_value(class_of_type_from_args(args).subtype_of_single(args[1]))
}

// Ruby method `describe_obj(obj)` at line 42.
pub fn ruby_class_of_l42_d7_describe_obj(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ClassOf#describe_obj requires an object')
	}
	return ruby.string_value(class_of_type_from_args(args).describe_obj(args[1]))
}

// Ruby method `[](*types)` at line 51.
pub fn ruby_class_of_l51_d8_anonymous(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ClassOf#[] requires a receiver')
	}
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object belongs to the specified class.
// 6:   class ClassOf < Base
// 7:     attr_reader :type
// 8:
// 9:     def initialize(type)
// 10:       @type = type
// 11:     end
// 12:
// 13:     def build_type
// 14:       nil
// 15:     end
// 16:
// 17:     # overrides Base
// 18:     def name
// 19:       "T.class_of(#{@type})"
// 20:     end
// 21:
// 22:     # overrides Base
// 23:     def valid?(obj)
// 24:       obj.is_a?(@type.singleton_class)
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     def subtype_of_single?(other)
// 29:       case other
// 30:       when ClassOf
// 31:         @type.is_a?(other.type.singleton_class)
// 32:       when Simple
// 33:         @type.is_a?(other.raw_type)
// 34:       when TypedClass, TypedModule
// 35:         @type.is_a?(other.underlying_class)
// 36:       else
// 37:         false
// 38:       end
// 39:     end
// 40:
// 41:     # overrides Base
// 42:     def describe_obj(obj)
// 43:       obj.inspect
// 44:     end
// 45:
// 46:     # So that `T.class_of(...)[...]` syntax is valid.
// 47:     # Mirrors the definition of T::Generic#[] (generics are erased).
// 48:     #
// 49:     # We avoid simply writing `include T::Generic` because we don't want any of
// 50:     # the other methods to appear (`T.class_of(A).type_member` doesn't make sense)
// 51:     def [](*types)
// 52:       self
// 53:     end
// 54:   end
// 55: end
