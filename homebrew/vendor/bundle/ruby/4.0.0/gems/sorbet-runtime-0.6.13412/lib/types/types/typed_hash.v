module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_hash.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TypedHashType {
pub:
	inner_keys   brew_runtime.Value
	inner_values brew_runtime.Value
	keys_type    &BaseType
	values_type  &BaseType
	pair_type    &FixedArrayType
	pair_base    &BaseType
	pair_value   brew_runtime.Value
	enumerable   &TypedEnumerableType
}

pub fn new_typed_hash_type(keys brew_runtime.Value, values brew_runtime.Value) !&TypedHashType {
	keys_type := union_coerce(keys)!
	values_type := union_coerce(values)!
	pair_type := &FixedArrayType{
		types: [keys_type, values_type]
	}
	pair_base := new_custom_base_type('T::Types::FixedArray', pair_type.name(), [], typed_hash_pair_supertypes(keys_type, values_type))
	pair_value := typed_hash_pair_value(pair_type, pair_base)
	return &TypedHashType{
		inner_keys: keys
		inner_values: values
		keys_type: keys_type
		values_type: values_type
		pair_type: pair_type
		pair_base: pair_base
		pair_value: pair_value
		enumerable: new_typed_enumerable_subtype(pair_value, 'Hash', 'T::Hash')
	}
}

fn typed_hash_component_names(type_value &BaseType) []string {
	mut names := [type_value.name() or { type_value.display_name }]
	for name in type_value.direct_supertype_names {
		if name !in names {
			names << name
		}
	}
	return names
}

// TypedEnumerable performs covariance through BaseType when its element value
// has one. A hash's enumerable element is its [key, value] tuple, so retain the
// FixedArray boundary for recursive traversal and attach the tuple's simple
// covariant supertypes for the inherited subtype path.
fn typed_hash_pair_supertypes(keys &BaseType, values &BaseType) []string {
	mut names := []string{}
	for key_name in typed_hash_component_names(keys) {
		for value_name in typed_hash_component_names(values) {
			name := '[${key_name}, ${value_name}]'
			if name !in names && name != '[${keys.name() or { keys.display_name }}, ${values.name() or {
				values.display_name}}]' {
				names << name
			}
		}
	}
	return names
}

fn typed_hash_pair_value(pair &FixedArrayType, pair_base &BaseType) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Types::FixedArray'
		repr: pair.name()
		array_data: pair.types.map(base_type_boundary_value(it))
		attributes: {
			'base_type_address':        u64(voidptr(pair_base)).str()
			'fixed_array_type_address': u64(voidptr(pair)).str()
		}
	}
}

pub fn (typed &TypedHashType) keys() &BaseType {
	return typed.keys_type
}

pub fn (typed &TypedHashType) values() &BaseType {
	return typed.values_type
}

pub fn (typed &TypedHashType) type_value() brew_runtime.Value {
	return typed.pair_value
}

pub fn (typed &TypedHashType) build_type() ! {
	typed.pair_type.build_type()!
}

pub fn (typed &TypedHashType) name() string {
	return 'T::Hash[${typed.keys_type.name() or { '' }}, ${typed.values_type.name() or { '' }}]'
}

pub fn (typed &TypedHashType) recursively_valid(value brew_runtime.Value) !bool {
	if !typed.valid(value) {
		return false
	}
	for key, item in value.map_data {
		key_value := if key.starts_with(':') && key.len > 1 {
			brew_runtime.object_value('Symbol', key)
		} else {
			brew_runtime.string_value(key)
		}
		if !typed.pair_type.recursively_valid(brew_runtime.array_value([key_value, item]))! {
			return false
		}
	}
	return true
}

pub fn (typed &TypedHashType) valid(value brew_runtime.Value) bool {
	return typed.enumerable.valid(value)
}

pub fn (typed &TypedHashType) subtype_of_single(other brew_runtime.Value) !bool {
	if other.type_name == 'T::Types::TypedHash' {
		other_keys := union_coerce(other.map_data['keys'] or { return false })!
		other_values := union_coerce(other.map_data['values'] or { return false })!
		return typed.keys_type.subtype_of(other_keys)! == .yes && typed.values_type.subtype_of(other_values)! == .yes
	}
	return typed.enumerable.subtype_of_single(other)
}

pub fn typed_hash_new(args []brew_runtime.Value) !brew_runtime.Value {
	if args.len > 1 {
		return error('wrong number of arguments (given ${args.len}, expected 0..1)')
	}
	return brew_runtime.Value{
		type_name: 'Hash'
		repr: '{}'
		array_data: args.clone()
		map_data: map[string]brew_runtime.Value{}
		attributes: {
			'has_default': (args.len == 1).str()
		}
	}
}

fn typed_hash_value(typed &TypedHashType, frozen bool) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'T::Types::TypedHash'
		repr: typed.name()
		map_data: {
			'keys':   base_type_boundary_value(typed.keys_type)
			'values': base_type_boundary_value(typed.values_type)
			'type':   typed.pair_value
		}
		attributes: {
			'frozen':                   frozen.str()
			'typed_enumerable_address': u64(voidptr(typed.enumerable)).str()
			'typed_hash_type_address':  u64(voidptr(typed)).str()
			'underlying_class':         'Hash'
		}
	}
}

fn typed_hash_type_from_value(value brew_runtime.Value) &TypedHashType {
	address := value.attribute('typed_hash_type_address') or {
		panic('invalid TypedHash receiver')
	}
	return unsafe { &TypedHashType(voidptr(address.u64())) }
}

fn typed_hash_type_from_args(args []brew_runtime.Value) &TypedHashType {
	if args.len == 0 {
		panic('TypedHash method requires a receiver')
	}
	return typed_hash_type_from_value(args[0])
}

fn typed_hash_initialize_types(args []brew_runtime.Value) (brew_runtime.Value, brew_runtime.Value) {
	if args.len == 2 {
		return args[0], args[1]
	}
	if args.len == 1 && args[0].type_name == 'Hash' {
		keys := args[0].map_data['keys'] or { panic('TypedHash#initialize requires keys:') }
		values := args[0].map_data['values'] or { panic('TypedHash#initialize requires values:') }
		return keys, values
	}
	panic('TypedHash#initialize requires keys: and values:')
}

// Ruby method `underlying_class` at line 6.
pub fn ruby_typed_hash_l6_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	typed_hash_type_from_args(args)
	return brew_runtime.object_value('Class', 'Hash')
}

// Ruby method `initialize(keys:, values:)` at line 10.
pub fn ruby_typed_hash_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	keys, values := typed_hash_initialize_types(args)
	return typed_hash_value(new_typed_hash_type(keys, values) or { panic(err) }, false)
}

// Ruby method `keys` at line 16.
pub fn ruby_typed_hash_l16_d3_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return base_type_boundary_value(typed_hash_type_from_args(args).keys())
}

// Ruby method `values` at line 21.
pub fn ruby_typed_hash_l21_d4_values(args ...brew_runtime.Value) brew_runtime.Value {
	return base_type_boundary_value(typed_hash_type_from_args(args).values())
}

// Ruby method `type` at line 25.
pub fn ruby_typed_hash_l25_d5_type(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_hash_type_from_args(args).type_value()
}

// Ruby method `name` at line 30.
pub fn ruby_typed_hash_l30_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_hash_type_from_args(args).name())
}

// Ruby method `recursively_valid?(obj)` at line 35.
pub fn ruby_typed_hash_l35_d7_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedHash#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(typed_hash_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 40.
pub fn ruby_typed_hash_l40_d8_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedHash#valid? requires an object')
	}
	return brew_runtime.bool_value(typed_hash_type_from_args(args).valid(args[1]))
}

// Ruby method `new(...)` at line 44.
pub fn ruby_typed_hash_l44_d9_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedHash#new requires a receiver')
	}
	typed_hash_type_from_args(args)
	return typed_hash_new(args[1..]) or { panic(err) }
}

// Ruby method `initialize` at line 49.
pub fn ruby_typed_hash_l49_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	untyped := base_type_boundary_value(base_untyped_type())
	return typed_hash_value(new_typed_hash_type(untyped, untyped) or { panic(err) }, false)
}

// Ruby method `valid?(obj)` at line 55.
pub fn ruby_typed_hash_l55_d11_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedHash::Untyped#valid? requires an object')
	}
	typed_hash_type_from_args(args)
	return brew_runtime.bool_value(enumerable_value_is_a(args[1], 'Hash'))
}

// Ruby method `freeze` at line 59.
pub fn ruby_typed_hash_l59_d12_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	typed := typed_hash_type_from_args(args)
	typed.build_type() or { panic(err) }
	return typed_hash_value(typed, true)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedHash < TypedEnumerable
// 6:     def underlying_class
// 7:       Hash
// 8:     end
// 9:
// 10:     def initialize(keys:, values:)
// 11:       @inner_keys = keys
// 12:       @inner_values = values
// 13:     end
// 14:
// 15:     # Technically we don't need this, but it is a nice api
// 16:     def keys
// 17:       @keys ||= T::Utils.coerce(@inner_keys)
// 18:     end
// 19:
// 20:     # Technically we don't need this, but it is a nice api
// 21:     def values
// 22:       @values ||= T::Utils.coerce(@inner_values)
// 23:     end
// 24:
// 25:     def type
// 26:       @type ||= T::Utils.coerce([keys, values])
// 27:     end
// 28:
// 29:     # overrides Base
// 30:     def name
// 31:       "T::Hash[#{keys.name}, #{values.name}]"
// 32:     end
// 33:
// 34:     # overrides Base
// 35:     def recursively_valid?(obj)
// 36:       obj.is_a?(Hash) && super
// 37:     end
// 38:
// 39:     # overrides Base
// 40:     def valid?(obj)
// 41:       obj.is_a?(Hash)
// 42:     end
// 43:
// 44:     def new(...)
// 45:       Hash.new(...)
// 46:     end
// 47:
// 48:     class Untyped < TypedHash
// 49:       def initialize
// 50:         # Use the INSTANCE constant directly (rather than `T.untyped`) so this
// 51:         # can be built at load time, mirroring TypedArray::Untyped.
// 52:         super(keys: T::Types::Untyped::Private::INSTANCE, values: T::Types::Untyped::Private::INSTANCE)
// 53:       end
// 54:
// 55:       def valid?(obj)
// 56:         obj.is_a?(Hash)
// 57:       end
// 58:
// 59:       def freeze
// 60:         build_type # force lazy initialization before freezing the object
// 61:         super
// 62:       end
// 63:
// 64:       module Private
// 65:         INSTANCE = Untyped.new.freeze
// 66:       end
// 67:     end
// 68:   end
// 69: end
