module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/fixed_array.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(types)` at line 9.
pub fn ruby_fixed_array_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `types` at line 13.
pub fn ruby_fixed_array_l13_d2_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('types', ...args)
}

// Ruby method `build_type` at line 17.
pub fn ruby_fixed_array_l17_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 23.
pub fn ruby_fixed_array_l23_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 28.
pub fn ruby_fixed_array_l28_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 46.
pub fn ruby_fixed_array_l46_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 64.
pub fn ruby_fixed_array_l64_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `describe_obj(obj)` at line 97.
pub fn ruby_fixed_array_l97_d8_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_obj', ...args)
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
