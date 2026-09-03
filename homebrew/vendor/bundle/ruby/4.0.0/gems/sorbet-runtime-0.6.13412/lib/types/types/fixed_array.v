module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/fixed_array.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct FixedArrayType {
pub:
	types []&BaseType
}

pub fn new_fixed_array_type(values []brew_runtime.Value) !&FixedArrayType {
	mut types := []&BaseType{cap: values.len}
	for value in values {
		types << union_coerce(value)!
	}
	return &FixedArrayType{
		types: types
	}
}

pub fn (fixed &FixedArrayType) build_type() ! {
	for type_value in fixed.types {
		type_value.build_type()!
	}
}

pub fn (fixed &FixedArrayType) name() string {
	mut names := []string{cap: fixed.types.len}
	for type_value in fixed.types {
		names << (type_value.name() or { '' })
	}
	return '[${names.join(', ')}]'
}

pub fn (fixed &FixedArrayType) recursively_valid(value brew_runtime.Value) !bool {
	return fixed.validate_elements(value, true)
}

pub fn (fixed &FixedArrayType) valid(value brew_runtime.Value) !bool {
	return fixed.validate_elements(value, false)
}

fn (fixed &FixedArrayType) validate_elements(value brew_runtime.Value, recursive bool) !bool {
	if value.type_name != 'Array' {
		return false
	}
	elements := value.as_array()!
	if elements.len != fixed.types.len {
		return false
	}
	for index, type_value in fixed.types {
		valid := if recursive {
			type_value.recursively_valid(elements[index])!
		} else {
			type_value.valid(elements[index])!
		}
		if !valid {
			return false
		}
	}
	return true
}

pub fn (fixed &FixedArrayType) subtype_of_single(other brew_runtime.Value) !bool {
	if other.type_name == 'T::Types::FixedArray' {
		other_fixed := fixed_array_type_from_value(other)
		if fixed.types.len != other_fixed.types.len {
			return false
		}
		for index, type_value in fixed.types {
			if type_value.subtype_of(other_fixed.types[index])! != .yes {
				return false
			}
		}
		return true
	}
	if other.type_name == 'T::Types::TypedArray' {
		other_type_value := other.map_data['type'] or { return false }
		other_type := union_coerce(other_type_value)!
		value_type := match fixed.types.len {
			0 { base_untyped_type() }
			1 { fixed.types[0] }
			else { new_union_base_type(fixed.types) }
		}
		return value_type.subtype_of(other_type)! == .yes
	}
	return false
}

pub fn (fixed &FixedArrayType) describe_obj(value brew_runtime.Value) string {
	if value.type_name != 'Array' {
		return new_custom_base_type('T::Types::FixedArray', fixed.name(), [], []).describe_obj(value)
	}
	elements := value.as_array() or { return 'array of size 0' }
	if elements.len != fixed.types.len {
		return 'array of size ${elements.len}'
	}
	return 'type [${elements.map(it.type_name).join(', ')}]'
}

fn fixed_array_type_value(fixed &FixedArrayType) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Types::FixedArray'
		repr: fixed.name()
		array_data: fixed.types.map(base_type_boundary_value(it))
		attributes: {
			'fixed_array_type_address': u64(voidptr(fixed)).str()
		}
	}
}

fn fixed_array_type_from_value(value brew_runtime.Value) &FixedArrayType {
	address := value.attribute('fixed_array_type_address') or {
		panic('invalid FixedArray receiver')
	}
	return unsafe { &FixedArrayType(voidptr(address.u64())) }
}

fn fixed_array_type_from_args(args []brew_runtime.Value) &FixedArrayType {
	if args.len == 0 {
		panic('FixedArray method requires a receiver')
	}
	return fixed_array_type_from_value(args[0])
}

// Ruby method `initialize(types)` at line 9.
pub fn ruby_fixed_array_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('FixedArray#initialize requires types')
	}
	return fixed_array_type_value(new_fixed_array_type(args[0].as_array() or { panic(err) }) or {
		panic(err)
	})
}

// Ruby method `types` at line 13.
pub fn ruby_fixed_array_l13_d2_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(fixed_array_type_from_args(args).types.map(base_type_boundary_value(it)))
}

// Ruby method `build_type` at line 17.
pub fn ruby_fixed_array_l17_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	fixed_array_type_from_args(args).build_type() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `name` at line 23.
pub fn ruby_fixed_array_l23_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(fixed_array_type_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 28.
pub fn ruby_fixed_array_l28_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedArray#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(fixed_array_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 46.
pub fn ruby_fixed_array_l46_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedArray#valid? requires an object')
	}
	return brew_runtime.bool_value(fixed_array_type_from_args(args).valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `subtype_of_single?(other)` at line 64.
pub fn ruby_fixed_array_l64_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedArray#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(fixed_array_type_from_args(args).subtype_of_single(args[1]) or {
		panic(err)
	})
}

// Ruby method `describe_obj(obj)` at line 97.
pub fn ruby_fixed_array_l97_d8_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedArray#describe_obj requires an object')
	}
	return brew_runtime.string_value(fixed_array_type_from_args(args).describe_obj(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # https://jira.corp.stripe.com/browse/RUBYPLAT-1107
// 3: # typed: true
// 4:
// 5: module T::Types
// 6:   # Takes a list of types. Validates each item in an array using the type in the same position
// 7:   # in the list.
// 8:   class FixedArray < Base
// 9:     def initialize(types)
// 10:       @inner_types = types
// 11:     end
// 12:
// 13:     def types
// 14:       @types ||= @inner_types.map { |type| T::Utils.coerce(type) }
// 15:     end
// 16:
// 17:     def build_type
// 18:       types
// 19:       nil
// 20:     end
// 21:
// 22:     # overrides Base
// 23:     def name
// 24:       "[#{types.join(', ')}]"
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     def recursively_valid?(obj)
// 29:       element_types = types
// 30:       length = element_types.length
// 31:       if obj.is_a?(Array) && obj.length == length
// 32:         index = 0
// 33:         while index < length
// 34:           if !element_types.fetch(index).recursively_valid?(obj[index])
// 35:             return false
// 36:           end
// 37:           index += 1
// 38:         end
// 39:         true
// 40:       else
// 41:         false
// 42:       end
// 43:     end
// 44:
// 45:     # overrides Base
// 46:     def valid?(obj)
// 47:       element_types = types
// 48:       length = element_types.length
// 49:       if obj.is_a?(Array) && obj.length == length
// 50:         index = 0
// 51:         while index < length
// 52:           if !element_types.fetch(index).valid?(obj[index])
// 53:             return false
// 54:           end
// 55:           index += 1
// 56:         end
// 57:         true
// 58:       else
// 59:         false
// 60:       end
// 61:     end
// 62:
// 63:     # overrides Base
// 64:     private def subtype_of_single?(other)
// 65:       case other
// 66:       when FixedArray
// 67:         # Properly speaking, covariance here is unsound since arrays
// 68:         # can be mutated, but sorbet implements covariant tuples for
// 69:         # ease of adoption.
// 70:         types.size == other.types.size && types.zip(other.types).all? do |t1, t2|
// 71:           t1.subtype_of?(t2)
// 72:         end
// 73:       when TypedArray
// 74:         # warning: covariant arrays
// 75:
// 76:         value1, value2, *values_rest = types
// 77:         value_type = if !value2.nil?
// 78:           T::Types::Union::Private::Pool.union_of_types(value1, value2, values_rest)
// 79:         elsif value1.nil?
// 80:           T.untyped
// 81:         else
// 82:           value1
// 83:         end
// 84:
// 85:         T::Types::TypedArray.new(value_type).subtype_of?(other)
// 86:       else
// 87:         false
// 88:       end
// 89:     end
// 90:
// 91:     # This gives us better errors, e.g.:
// 92:     # "Expected [String, Symbol], got [String, String]"
// 93:     # instead of
// 94:     # "Expected [String, Symbol], got Array".
// 95:     #
// 96:     # overrides Base
// 97:     def describe_obj(obj)
// 98:       if obj.is_a?(Array)
// 99:         if obj.length == types.length
// 100:           item_classes = obj.map(&:class).join(', ')
// 101:           "type [#{item_classes}]"
// 102:         else
// 103:           "array of size #{obj.length}"
// 104:         end
// 105:       else
// 106:         super
// 107:       end
// 108:     end
// 109:   end
// 110: end
