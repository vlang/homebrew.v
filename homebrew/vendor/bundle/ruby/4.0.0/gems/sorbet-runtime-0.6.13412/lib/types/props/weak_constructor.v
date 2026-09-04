module props

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/weak_constructor.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PropDefinition {
pub:
	name          string
	expected_type string
	required      bool
	has_default   bool
	default_value ruby.Value
	has_factory   bool
	factory_value ruby.Value
}

pub struct PropInstance {
pub:
	class_name string
pub mut:
	values map[string]ruby.Value
}

fn prop_value_matches(definition PropDefinition, value ruby.Value) bool {
	if value.type_name == 'NilClass' {
		return !definition.required
	}
	return definition.expected_type == '' || definition.expected_type in ['T.untyped',
		'T::Types::Untyped'] || value.type_name == definition.expected_type
}

fn set_prop_value(mut instance PropInstance, definition PropDefinition,
	value ruby.Value) ! {
	if !prop_value_matches(definition, value) {
		return error('Expected type ${definition.expected_type} for prop `${definition.name}`, got ${value.type_name}')
	}
	instance.values[definition.name] = value
}

// construct_props_without_defaults implements WeakConstructor's present-key
// assignment and deliberately ignores missing keys.
pub fn construct_props_without_defaults(mut instance PropInstance, definitions []PropDefinition,
	hash map[string]ruby.Value) !int {
	mut result := 0
	for definition in definitions {
		if definition.has_default || definition.has_factory || definition.name !in hash {
			continue
		}
		set_prop_value(mut instance, definition, hash[definition.name])!
		result++
	}
	return result
}

// construct_props_with_defaults uses an input value only when the input hash
// actually contains the key, including when that value is nil.
pub fn construct_props_with_defaults(mut instance PropInstance, definitions []PropDefinition,
	hash map[string]ruby.Value) !int {
	mut result := 0
	for definition in definitions {
		if !definition.has_default && !definition.has_factory {
			continue
		}
		if definition.name in hash {
			set_prop_value(mut instance, definition, hash[definition.name])!
			result++
		} else {
			value := if definition.has_factory {
				deep_clone(definition.factory_value)
			} else {
				deep_clone(definition.default_value)
			}
			set_prop_value(mut instance, definition, value)!
		}
	}
	return result
}

pub fn weak_construct(class_name string, definitions []PropDefinition,
	hash map[string]ruby.Value) !PropInstance {
	mut instance := PropInstance{
		class_name: class_name
		values: map[string]ruby.Value{}
	}
	matched := construct_props_with_defaults(mut instance, definitions, hash)! + construct_props_without_defaults(mut instance, definitions, hash)!
	if matched < hash.len {
		known := definitions.map(it.name)
		mut unknown := []string{}
		for key in hash.keys() {
			if key !in known {
				unknown << key
			}
		}
		unknown.sort()
		return error('${class_name}: Unrecognized properties: ${unknown.join(', ')}')
	}
	return instance
}

fn prop_definition_from_value(value ruby.Value) PropDefinition {
	return PropDefinition{
		name: value.attribute('name') or { value.as_string() }
		expected_type: value.attribute('expected_type') or { '' }
		required: value.attribute('required') or { 'false' } == 'true'
		has_default: 'default' in value.map_data
		default_value: value.map_data['default'] or { props_nil_value() }
		has_factory: 'factory' in value.map_data
		factory_value: value.map_data['factory'] or { props_nil_value() }
	}
}

fn prop_definitions_from_value(value ruby.Value) []PropDefinition {
	return value.array_data.map(prop_definition_from_value(it))
}

fn prop_instance_from_value(value ruby.Value) PropInstance {
	return PropInstance{
		class_name: value.attribute('class_name') or { value.type_name }
		values: value.map_data.clone()
	}
}

fn prop_instance_value(instance PropInstance) ruby.Value {
	return ruby.Value{
		type_name: instance.class_name
		repr: '<${instance.class_name}>'
		map_data: instance.values.clone()
		attributes: {
			'class_name': instance.class_name
		}
	}
}

// Ruby method `initialize(hash=EMPTY_HASH)` at line 15.
pub fn ruby_weak_constructor_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('WeakConstructor#initialize requires a receiver')
	}
	hash := if args.len > 1 {
		args[1].as_map() or { panic(err) }
	} else {
		map[string]ruby.Value{}
	}
	return prop_instance_value(weak_construct(args[0].attribute('class_name') or {
		args[0].type_name
	}, prop_definitions_from_value(args[0]), hash) or { panic(err) })
}

// Ruby method `construct_props_without_defaults(instance, hash)` at line 37.
pub fn ruby_weak_constructor_l37_d2_construct_props_without_defaults(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('construct_props_without_defaults requires decorator, instance, and hash')
	}
	mut instance := prop_instance_from_value(args[1])
	count := construct_props_without_defaults(mut instance, prop_definitions_from_value(args[0]), args[2].as_map() or { panic(err) }) or { panic(err) }
	return ruby.int_value(count)
}

// Ruby method `construct_props_with_defaults(instance, hash)` at line 58.
pub fn ruby_weak_constructor_l58_d3_construct_props_with_defaults(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('construct_props_with_defaults requires decorator, instance, and hash')
	}
	mut instance := prop_instance_from_value(args[1])
	count := construct_props_with_defaults(mut instance, prop_definitions_from_value(args[0]), args[2].as_map() or { panic(err) }) or { panic(err) }
	return ruby.int_value(count)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::WeakConstructor
// 5:   include T::Props::Optional
// 6:   extend T::Sig
// 7:
// 8:   # Shared default so zero-arg construction doesn't allocate a fresh Hash;
// 9:   # the construct_props_* methods only ever read from `hash`.
// 10:   EMPTY_HASH = T.let({}.freeze, T::Hash[Symbol, T.untyped])
// 11:   private_constant :EMPTY_HASH
// 12:
// 13:   # checked(:never) - O(runtime object construction)
// 14:   sig { params(hash: T::Hash[Symbol, T.untyped]).void.checked(:never) }
// 15:   def initialize(hash=EMPTY_HASH)
// 16:     decorator = self.class.decorator
// 17:
// 18:     hash_keys_matching_props = decorator.construct_props_with_defaults(self, hash) +
// 19:       decorator.construct_props_without_defaults(self, hash)
// 20:
// 21:     if hash_keys_matching_props < hash.size
// 22:       raise ArgumentError.new("#{self.class}: Unrecognized properties: #{(hash.keys - decorator.props.keys).join(', ')}")
// 23:     end
// 24:   end
// 25: end
// 26:
// 27: module T::Props::WeakConstructor::DecoratorMethods
// 28:   extend T::Sig
// 29:
// 30:   # Set values for all props that have no defaults. Ignore any not present.
// 31:   #
// 32:   # @return [Integer] A count of props that we successfully initialized (which
// 33:   # we'll use to check for any unrecognized input.)
// 34:   #
// 35:   # checked(:never) - O(runtime object construction)
// 36:   sig { params(instance: T::Props::WeakConstructor, hash: T::Hash[Symbol, T.untyped]).returns(Integer).checked(:never) }
// 37:   def construct_props_without_defaults(instance, hash)
// 38:     # Use `each_pair` rather than `count` because, as of Ruby 2.6, the latter delegates to Enumerator
// 39:     # and therefore allocates for each entry.
// 40:     result = 0
// 41:     props_without_defaults&.each_pair do |p, bound_setter|
// 42:       if hash.key?(p)
// 43:         bound_setter.call(instance, hash[p])
// 44:         result += 1
// 45:       end
// 46:     end
// 47:     result
// 48:   end
// 49:
// 50:   # Set values for all props that have defaults. Use the default if and only if
// 51:   # the prop key isn't in the input.
// 52:   #
// 53:   # @return [Integer] A count of props that we successfully initialized (which
// 54:   # we'll use to check for any unrecognized input.)
// 55:   #
// 56:   # checked(:never) - O(runtime object construction)
// 57:   sig { params(instance: T::Props::WeakConstructor, hash: T::Hash[Symbol, T.untyped]).returns(Integer).checked(:never) }
// 58:   def construct_props_with_defaults(instance, hash)
// 59:     # Use `each_pair` rather than `count` because, as of Ruby 2.6, the latter delegates to Enumerator
// 60:     # and therefore allocates for each entry.
// 61:     result = 0
// 62:     props_with_defaults&.each_pair do |p, default_struct|
// 63:       if hash.key?(p)
// 64:         default_struct.bound_setter_proc.call(instance, hash[p])
// 65:         result += 1
// 66:       else
// 67:         default_struct.set_default(instance)
// 68:       end
// 69:     end
// 70:     result
// 71:   end
// 72: end
