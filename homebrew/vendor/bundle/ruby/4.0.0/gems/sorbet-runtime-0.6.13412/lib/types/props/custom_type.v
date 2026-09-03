module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/custom_type.rb`.
// The original source is retained below until every stub has a typed V body.
pub type CustomTypePredicate = fn(brew_runtime.Value) bool

pub type CustomTypeSerialize = fn(brew_runtime.Value) !brew_runtime.Value

const custom_type_default_scalar_types = ['NilClass', 'TrueClass', 'FalseClass', 'Integer', 'Float',
	'String', 'Symbol', 'Time', 'T::Enum']

pub fn custom_type_instance(value brew_runtime.Value, predicate CustomTypePredicate) bool {
	return predicate(value)
}

pub fn custom_type_valid(value brew_runtime.Value, predicate CustomTypePredicate) bool {
	return custom_type_instance(value, predicate)
}

pub fn custom_type_abstract_serialize(_ brew_runtime.Value) !brew_runtime.Value {
	return error('CustomType.serialize is abstract')
}

pub fn custom_type_abstract_deserialize(_ brew_runtime.Value) !brew_runtime.Value {
	return error('CustomType.deserialize is abstract')
}

pub fn custom_type_included() ! {
	return error('Please use "extend", not "include" to attach this module')
}

fn ruby_class_name(value brew_runtime.Value) string {
	return match value.type_name {
		'Bool' {
			if value.bool_data { 'TrueClass' } else { 'FalseClass' }
		}
		else { value.type_name }
	}
}

// scalar_type follows the Ruby class and superclass name chain. Included
// modules are intentionally ignored because Configuration scalar types are
// class names, not modules.
pub fn custom_type_scalar_type(value brew_runtime.Value, scalar_types []string) bool {
	if ruby_class_name(value) in scalar_types {
		return true
	}
	ancestors := value.attribute('class_ancestors') or { '' }
	for class_name in ancestors.split(',') {
		if class_name != '' && class_name in scalar_types {
			return true
		}
	}
	return false
}

pub fn custom_type_valid_serialization(value brew_runtime.Value, scalar_types []string) bool {
	if value.type_name == 'Array' {
		for item in value.array_data {
			if !custom_type_scalar_type(item, scalar_types) {
				return false
			}
		}
		return true
	}
	return custom_type_scalar_type(value, scalar_types)
}

pub fn custom_type_checked_serialize(instance brew_runtime.Value, serialize CustomTypeSerialize,
	scalar_types []string) !brew_runtime.Value {
	value := serialize(instance)!
	if !custom_type_valid_serialization(value, scalar_types) {
		mut message := '${ruby_class_name(instance)} did not serialize to a valid scalar type. It became a: ${ruby_class_name(value)}'
		if value.type_name == 'Hash' {
			message += '\nIf you want to store a structured Hash, consider using a T::Struct as your type.'
		}
		return error(message)
	}
	return value
}

fn custom_type_boundary_predicate(receiver brew_runtime.Value, value brew_runtime.Value) bool {
	expected_type := receiver.attribute('expected_type') or { receiver.as_string() }
	return ruby_class_name(value) == expected_type || expected_type in (value.attribute('class_ancestors') or { '' }).split(',')
}

fn custom_type_scalar_types_from_args(args []brew_runtime.Value, index int) []string {
	if args.len > index {
		return args[index].as_string_array() or { panic(err) }
	}
	return custom_type_default_scalar_types.clone()
}

// Ruby method `instance?(value)` at line 21.
pub fn ruby_custom_type_l21_d1_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CustomType#instance? requires a value')
	}
	return brew_runtime.bool_value(custom_type_boundary_predicate(args[0], args[1]))
}

// Ruby method `valid?(value)` at line 33.
pub fn ruby_custom_type_l33_d2_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CustomType#valid? requires a value')
	}
	return brew_runtime.bool_value(custom_type_boundary_predicate(args[0], args[1]))
}

// Ruby method `serialize(instance); end` at line 43.
pub fn ruby_custom_type_l43_d3_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CustomType#serialize requires an instance')
	}
	return custom_type_abstract_serialize(args[1]) or { panic(err) }
}

// Ruby method `deserialize(scalar); end` at line 51.
pub fn ruby_custom_type_l51_d4_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CustomType#deserialize requires a scalar')
	}
	return custom_type_abstract_deserialize(args[1]) or { panic(err) }
}

// Ruby method `self.included(_base)` at line 54.
pub fn ruby_custom_type_l54_d5_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	custom_type_included() or { panic(err) }
	return props_nil_value()
}

// Ruby method `self.scalar_type?(val)` at line 61.
pub fn ruby_custom_type_l61_d6_self_scalar_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CustomType.scalar_type? requires a value')
	}
	return brew_runtime.bool_value(custom_type_scalar_type(args[0], custom_type_scalar_types_from_args(args, 1)))
}

// Ruby method `self.valid_serialization?(val)` at line 84.
pub fn ruby_custom_type_l84_d7_self_valid_serialization(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CustomType.valid_serialization? requires a value')
	}
	return brew_runtime.bool_value(custom_type_valid_serialization(args[0], custom_type_scalar_types_from_args(args, 1)))
}

// Ruby method `self.checked_serialize(instance)` at line 102.
pub fn ruby_custom_type_l102_d8_self_checked_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CustomType.checked_serialize requires an instance')
	}
	instance := args[0]
	serialized := instance.map_data['serialized'] or {
		panic('${ruby_class_name(instance)} has no translated serialize result')
	}
	if !custom_type_valid_serialization(serialized, custom_type_scalar_types_from_args(args, 1)) {
		mut message := '${ruby_class_name(instance)} did not serialize to a valid scalar type. It became a: ${ruby_class_name(serialized)}'
		if serialized.type_name == 'Hash' {
			message += '\nIf you want to store a structured Hash, consider using a T::Struct as your type.'
		}
		panic(message)
	}
	return serialized
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module CustomType
// 6:     extend T::Sig
// 7:     extend T::Helpers
// 8:
// 9:     abstract!
// 10:
// 11:     include Kernel # for `is_a?`
// 12:
// 13:     # Alias for backwards compatibility
// 14:     sig(:final) do
// 15:       params(
// 16:         value: BasicObject,
// 17:       )
// 18:       .returns(T::Boolean)
// 19:       .checked(:never)
// 20:     end
// 21:     def instance?(value)
// 22:       self.===(value)
// 23:     end
// 24:
// 25:     # Alias for backwards compatibility
// 26:     sig(:final) do
// 27:       params(
// 28:         value: BasicObject,
// 29:       )
// 30:       .returns(T::Boolean)
// 31:       .checked(:never)
// 32:     end
// 33:     def valid?(value)
// 34:       instance?(value)
// 35:     end
// 36:
// 37:     # Given an instance of this type, serialize that into a scalar type
// 38:     # supported by T::Props.
// 39:     #
// 40:     # @param [Object] instance
// 41:     # @return An instance of one of T::Configuration.scalar_types
// 42:     sig { abstract.params(instance: T.untyped).returns(T.untyped).checked(:never) }
// 43:     def serialize(instance); end
// 44:
// 45:     # Given the serialized form of your type, this returns an instance
// 46:     # of that custom type representing that value.
// 47:     #
// 48:     # @param scalar One of T::Configuration.scalar_types
// 49:     # @return Object
// 50:     sig { abstract.params(scalar: T.untyped).returns(T.untyped).checked(:never) }
// 51:     def deserialize(scalar); end
// 52:
// 53:     sig { override.params(_base: T::Module[T.anything]).void }
// 54:     def self.included(_base)
// 55:       super
// 56:
// 57:       raise 'Please use "extend", not "include" to attach this module'
// 58:     end
// 59:
// 60:     sig(:final) { params(val: T.untyped).returns(T::Boolean).checked(:never) }
// 61:     def self.scalar_type?(val)
// 62:       # We don't need to check for val's included modules in
// 63:       # T::Configuration.scalar_types, because T::Configuration.scalar_types
// 64:       # are all classes.
// 65:       #
// 66:       # `name` rather than `to_s`: identical for real classes, but returns the
// 67:       # cached frozen string (Ruby 3.2+) where to_s allocates per call.
// 68:       # Anonymous classes yield nil, and `include?(nil)` is false (an
// 69:       # anonymous class can never be a registered scalar type).
// 70:       scalar_types = T::Configuration.scalar_types
// 71:       klass = val.class
// 72:       until klass.nil?
// 73:         return true if scalar_types.include?(klass.name)
// 74:         klass = klass.superclass
// 75:       end
// 76:       false
// 77:     end
// 78:
// 79:     # We allow custom types to serialize to Arrays, so that we can
// 80:     # implement set-like fields that store a unique-array, but forbid
// 81:     # hashes; Custom hash types should be implemented via an emebdded
// 82:     # T::Struct (or a subclass like Chalk::ODM::Document) or via T.
// 83:     sig(:final) { params(val: Object).returns(T::Boolean).checked(:never) }
// 84:     def self.valid_serialization?(val)
// 85:       case val
// 86:       when Array
// 87:         val.each do |v|
// 88:           return false unless scalar_type?(v)
// 89:         end
// 90:
// 91:         true
// 92:       else
// 93:         scalar_type?(val)
// 94:       end
// 95:     end
// 96:
// 97:     sig(:final) do
// 98:       params(instance: Object)
// 99:       .returns(T.untyped)
// 100:       .checked(:never)
// 101:     end
// 102:     def self.checked_serialize(instance)
// 103:       val = T.cast(instance.class, T::Props::CustomType).serialize(instance)
// 104:       unless valid_serialization?(val)
// 105:         msg = "#{instance.class} did not serialize to a valid scalar type. It became a: #{val.class}"
// 106:         if val.is_a?(Hash)
// 107:           msg += "\nIf you want to store a structured Hash, consider using a T::Struct as your type."
// 108:         end
// 109:         raise TypeError.new(msg)
// 110:       end
// 111:       val
// 112:     end
// 113:   end
// 114: end
