module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/intersection.rb`.
// The original source is retained below until every stub has a typed V body.
fn intersection_coerce(value brew_runtime.Value) !&BaseType {
	if type_value := base_type_from_value(value) {
		return type_value
	}
	if value.type_name in ['Class', 'Module'] {
		ancestors := value.attribute('ancestors') or { '' }
		return new_simple_base_type(value.as_string(), ancestors.split(',').filter(it.len > 0))
	}
	return error('${value.type_name} cannot be coerced to a Sorbet type')
}

fn intersection_contains(types []&BaseType, candidate &BaseType) bool {
	for type_value in types {
		if type_value.equals(candidate) or { false } {
			return true
		}
	}
	return false
}

pub fn new_intersection_type(values []brew_runtime.Value) !&BaseType {
	mut members := []&BaseType{}
	for value in values {
		type_value := intersection_coerce(value)!
		if type_value.kind == .intersection_type {
			for nested in type_value.members {
				if !intersection_contains(members, nested) {
					members << nested
				}
			}
		} else if !intersection_contains(members, type_value) {
			members << type_value
		}
	}
	return new_intersection_base_type(members)
}

fn intersection_type_from_args(args []brew_runtime.Value) &BaseType {
	if args.len == 0 {
		panic('Intersection method requires a receiver')
	}
	type_value := base_type_from_value(args[0]) or { panic(err) }
	if type_value.kind != .intersection_type {
		panic('invalid Intersection receiver')
	}
	return type_value
}

fn intersection_members_value(type_value &BaseType) brew_runtime.Value {
	return brew_runtime.array_value(type_value.members.map(base_type_boundary_value(it)))
}

// Ruby method `initialize(types)` at line 7.
pub fn ruby_intersection_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Intersection#initialize requires types')
	}
	return base_type_boundary_value(new_intersection_type(args[0].as_array() or {
		panic(err)
	}) or { panic(err) })
}

// Ruby method `types` at line 11.
pub fn ruby_intersection_l11_d2_types(args ...brew_runtime.Value) brew_runtime.Value {
	return intersection_members_value(intersection_type_from_args(args))
}

// Ruby method `build_type` at line 23.
pub fn ruby_intersection_l23_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	intersection_type_from_args(args).build_type() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `name` at line 29.
pub fn ruby_intersection_l29_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(intersection_type_from_args(args).name() or { panic(err) })
}

// Ruby method `recursively_valid?(obj)` at line 34.
pub fn ruby_intersection_l34_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Intersection#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(intersection_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 45.
pub fn ruby_intersection_l45_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Intersection#valid? requires an object')
	}
	return brew_runtime.bool_value(intersection_type_from_args(args).valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `subtype_of_single?(other)` at line 56.
pub fn ruby_intersection_l56_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	intersection_type_from_args(args)
	panic("This should never be reached if you're going through `subtype_of?` (and you should be)")
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Takes a list of types. Validates that an object matches all of the types.
// 6:   class Intersection < Base
// 7:     def initialize(types)
// 8:       @inner_types = types
// 9:     end
// 10:
// 11:     def types
// 12:       @types ||= @inner_types.flat_map do |type|
// 13:         type = T::Utils.resolve_alias(type)
// 14:         if type.is_a?(Intersection)
// 15:           # Simplify nested intersections (mostly so `name` returns a nicer value)
// 16:           type.types
// 17:         else
// 18:           T::Utils.coerce(type)
// 19:         end
// 20:       end.uniq
// 21:     end
// 22:
// 23:     def build_type
// 24:       types
// 25:       nil
// 26:     end
// 27:
// 28:     # overrides Base
// 29:     def name
// 30:       "T.all(#{types.map(&:name).compact.sort.join(', ')})"
// 31:     end
// 32:
// 33:     # overrides Base
// 34:     def recursively_valid?(obj)
// 35:       members = types
// 36:       index = 0
// 37:       while index < members.length
// 38:         return false unless members.fetch(index).recursively_valid?(obj)
// 39:         index += 1
// 40:       end
// 41:       true
// 42:     end
// 43:
// 44:     # overrides Base
// 45:     def valid?(obj)
// 46:       members = types
// 47:       index = 0
// 48:       while index < members.length
// 49:         return false unless members.fetch(index).valid?(obj)
// 50:         index += 1
// 51:       end
// 52:       true
// 53:     end
// 54:
// 55:     # overrides Base
// 56:     private def subtype_of_single?(other)
// 57:       raise "This should never be reached if you're going through `subtype_of?` (and you should be)"
// 58:     end
// 59:
// 60:   end
// 61: end
