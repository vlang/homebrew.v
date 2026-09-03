module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/fixed_hash.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct FixedHashType {
pub:
	types map[string]&BaseType
}

pub fn new_fixed_hash_type(values map[string]brew_runtime.Value) !&FixedHashType {
	mut types := map[string]&BaseType{}
	for key, value in values {
		types[key] = union_coerce(value)!
	}
	return &FixedHashType{
		types: types
	}
}

pub fn (fixed &FixedHashType) build_type() ! {
	for _, type_value in fixed.types {
		type_value.build_type()!
	}
}

fn fixed_hash_key_inspect(key string) string {
	if key.starts_with(':') && key.len > 1 {
		return '${key[1..]}:'
	}
	return '"${key.replace('\\', '\\\\').replace('"', '\\"')}" =>'
}

pub fn fixed_hash_serialize(types map[string]&BaseType) string {
	mut entries := []string{cap: types.len}
	for key, value in types {
		entries << '${fixed_hash_key_inspect(key)} ${value.name() or { '' }}'
	}
	return '{${entries.join(', ')}}'
}

pub fn (fixed &FixedHashType) name() string {
	return fixed_hash_serialize(fixed.types)
}

pub fn (fixed &FixedHashType) recursively_valid(value brew_runtime.Value) !bool {
	return fixed.validate_fields(value, true)
}

pub fn (fixed &FixedHashType) valid(value brew_runtime.Value) !bool {
	return fixed.validate_fields(value, false)
}

fn (fixed &FixedHashType) validate_fields(value brew_runtime.Value, recursive bool) !bool {
	if value.type_name != 'Hash' {
		return false
	}
	fields := value.as_map()!
	for key, type_value in fixed.types {
		field := fields[key] or { brew_runtime.object_value('NilClass', 'nil') }
		valid := if recursive {
			type_value.recursively_valid(field)!
		} else {
			type_value.valid(field)!
		}
		if !valid {
			return false
		}
	}
	if fields.len > fixed.types.len {
		return false
	}
	for key, _ in fields {
		if key !in fixed.types {
			return false
		}
	}
	return true
}

fn fixed_hash_types_equal(left map[string]&BaseType, right map[string]&BaseType) !bool {
	if left.len != right.len {
		return false
	}
	for key, left_type in left {
		right_type := right[key] or { return false }
		if !left_type.equals(right_type)! {
			return false
		}
	}
	return true
}

fn fixed_hash_union(types []&BaseType) &BaseType {
	return match types.len {
		0 { base_untyped_type() }
		1 { types[0] }
		else { new_union_base_type(types) }
	}
}

pub fn (fixed &FixedHashType) subtype_of_single(other brew_runtime.Value) !bool {
	if other.type_name == 'T::Types::FixedHash' {
		return fixed_hash_types_equal(fixed.types, fixed_hash_type_from_value(other).types)
	}
	if other.type_name == 'T::Types::TypedHash' {
		other_key := union_coerce(other.map_data['keys'] or { return false })!
		other_value := union_coerce(other.map_data['values'] or { return false })!
		mut key_types := []&BaseType{cap: fixed.types.len}
		mut value_types := []&BaseType{cap: fixed.types.len}
		for key, value in fixed.types {
			key_types << new_simple_base_type(if key.starts_with(':') { 'Symbol' } else { 'String' }, [
				'Object',
			])
			value_types << value
		}
		return fixed_hash_union(key_types).subtype_of(other_key)! == .yes && fixed_hash_union(value_types).subtype_of(other_value)! == .yes
	}
	return false
}

pub fn (fixed &FixedHashType) describe_obj(value brew_runtime.Value) string {
	if value.type_name != 'Hash' {
		return new_custom_base_type('T::Types::FixedHash', fixed.name(), [], []).describe_obj(value)
	}
	mut actual_types := map[string]&BaseType{}
	for key, field in value.map_data {
		actual_types[key] = new_simple_base_type(field.type_name, [])
	}
	return 'type ${fixed_hash_serialize(actual_types)}'
}

fn fixed_hash_type_value(fixed &FixedHashType) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for key, type_value in fixed.types {
		values[key] = base_type_boundary_value(type_value)
	}
	return brew_runtime.Value{
		type_name: 'T::Types::FixedHash'
		repr: fixed.name()
		map_data: values
		attributes: {
			'fixed_hash_type_address': u64(voidptr(fixed)).str()
		}
	}
}

fn fixed_hash_type_from_value(value brew_runtime.Value) &FixedHashType {
	address := value.attribute('fixed_hash_type_address') or {
		panic('invalid FixedHash receiver')
	}
	return unsafe { &FixedHashType(voidptr(address.u64())) }
}

fn fixed_hash_type_from_args(args []brew_runtime.Value) &FixedHashType {
	if args.len == 0 {
		panic('FixedHash method requires a receiver')
	}
	return fixed_hash_type_from_value(args[0])
}

// Ruby method `initialize(types)` at line 8.
pub fn ruby_fixed_hash_l8_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('FixedHash#initialize requires types')
	}
	return fixed_hash_type_value(new_fixed_hash_type(args[0].as_map() or { panic(err) }) or {
		panic(err)
	})
}

// Ruby method `types` at line 12.
pub fn ruby_fixed_hash_l12_d2_types(args ...brew_runtime.Value) brew_runtime.Value {
	fixed := fixed_hash_type_from_args(args)
	mut values := map[string]brew_runtime.Value{}
	for key, type_value in fixed.types {
		values[key] = base_type_boundary_value(type_value)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `build_type` at line 16.
pub fn ruby_fixed_hash_l16_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	fixed_hash_type_from_args(args).build_type() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `name` at line 22.
pub fn ruby_fixed_hash_l22_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(fixed_hash_type_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 27.
pub fn ruby_fixed_hash_l27_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedHash#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(fixed_hash_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 42.
pub fn ruby_fixed_hash_l42_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedHash#valid? requires an object')
	}
	return brew_runtime.bool_value(fixed_hash_type_from_args(args).valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `subtype_of_single?(other)` at line 57.
pub fn ruby_fixed_hash_l57_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedHash#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(fixed_hash_type_from_args(args).subtype_of_single(args[1]) or {
		panic(err)
	})
}

// Ruby method `describe_obj(obj)` at line 95.
pub fn ruby_fixed_hash_l95_d8_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedHash#describe_obj requires an object')
	}
	return brew_runtime.string_value(fixed_hash_type_from_args(args).describe_obj(args[1]))
}

// Ruby method `serialize_hash(hash)` at line 105.
pub fn ruby_fixed_hash_l105_d9_serialize_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('FixedHash#serialize_hash requires a hash')
	}
	values := args[1].as_map() or { panic(err) }
	mut types := map[string]&BaseType{}
	for key, value in values {
		types[key] = union_coerce(value) or { panic(err) }
	}
	return brew_runtime.string_value(fixed_hash_serialize(types))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Takes a hash of types. Validates each item in a hash using the type in the same position
// 6:   # in the list.
// 7:   class FixedHash < Base
// 8:     def initialize(types)
// 9:       @inner_types = types
// 10:     end
// 11:
// 12:     def types
// 13:       @types ||= @inner_types.transform_values { |v| T::Utils.coerce(v) }
// 14:     end
// 15:
// 16:     def build_type
// 17:       types
// 18:       nil
// 19:     end
// 20:
// 21:     # overrides Base
// 22:     def name
// 23:       serialize_hash(types)
// 24:     end
// 25:
// 26:     # overrides Base
// 27:     def recursively_valid?(obj)
// 28:       return false unless obj.is_a?(Hash)
// 29:       field_types = types
// 30:       field_types.each_pair do |key, type|
// 31:         return false unless type.recursively_valid?(obj[key])
// 32:       end
// 33:       # Pigeonhole: more entries than declared keys guarantees an undeclared key.
// 34:       return false if obj.size > field_types.size
// 35:       obj.each_key do |key|
// 36:         return false unless field_types.key?(key)
// 37:       end
// 38:       true
// 39:     end
// 40:
// 41:     # overrides Base
// 42:     def valid?(obj)
// 43:       return false unless obj.is_a?(Hash)
// 44:       field_types = types
// 45:       field_types.each_pair do |key, type|
// 46:         return false unless type.valid?(obj[key])
// 47:       end
// 48:       # Pigeonhole: more entries than declared keys guarantees an undeclared key.
// 49:       return false if obj.size > field_types.size
// 50:       obj.each_key do |key|
// 51:         return false unless field_types.key?(key)
// 52:       end
// 53:       true
// 54:     end
// 55:
// 56:     # overrides Base
// 57:     private def subtype_of_single?(other)
// 58:       case other
// 59:       when FixedHash
// 60:         # Using `subtype_of?` here instead of == would be unsound
// 61:         types == other.types
// 62:       when TypedHash
// 63:         # warning: covariant hashes
// 64:
// 65:         key1, key2, *keys_rest = types.keys.map { |key| T::Utils.coerce(key.class) }
// 66:         key_type = if !key2.nil?
// 67:           T::Types::Union::Private::Pool.union_of_types(key1, key2, keys_rest)
// 68:         elsif key1.nil?
// 69:           T.untyped
// 70:         else
// 71:           key1
// 72:         end
// 73:
// 74:         value1, value2, *values_rest = types.values
// 75:         value_type = if !value2.nil?
// 76:           T::Types::Union::Private::Pool.union_of_types(value1, value2, values_rest)
// 77:         elsif value1.nil?
// 78:           T.untyped
// 79:         else
// 80:           value1
// 81:         end
// 82:
// 83:         T::Types::TypedHash.new(keys: key_type, values: value_type).subtype_of?(other)
// 84:       else
// 85:         false
// 86:       end
// 87:     end
// 88:
// 89:     # This gives us better errors, e.g.:
// 90:     # `Expected {a: String}, got {a: TrueClass}`
// 91:     # instead of
// 92:     # `Expected {a: String}, got Hash`.
// 93:     #
// 94:     # overrides Base
// 95:     def describe_obj(obj)
// 96:       if obj.is_a?(Hash)
// 97:         "type #{serialize_hash(obj.transform_values(&:class))}"
// 98:       else
// 99:         super
// 100:       end
// 101:     end
// 102:
// 103:     private
// 104:
// 105:     def serialize_hash(hash)
// 106:       entries = hash.map do |(k, v)|
// 107:         if Symbol === k && ":#{k}" == k.inspect
// 108:           "#{k}: #{v}"
// 109:         else
// 110:           "#{k.inspect} => #{v}"
// 111:         end
// 112:       end
// 113:
// 114:       "{#{entries.join(', ')}}"
// 115:     end
// 116:   end
// 117: end
