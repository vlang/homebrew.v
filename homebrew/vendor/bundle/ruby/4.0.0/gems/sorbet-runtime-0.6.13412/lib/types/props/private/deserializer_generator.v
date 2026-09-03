module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/deserializer_generator.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GeneratedDeserializeResult {
pub:
	found  int
	values map[string]brew_runtime.Value
}

fn apply_defaults_from_value(value brew_runtime.Value) map[string]ApplyDefaultDescriptor {
	mut defaults := map[string]ApplyDefaultDescriptor{}
	for prop, descriptor_value in value.map_data {
		if descriptor_value.type_name != 'NilClass' {
			defaults[prop.trim_left(':')] = *apply_default_descriptor_from_value(descriptor_value)
		}
	}
	return defaults
}

fn ruby_literal_value(value brew_runtime.Value) ?string {
	return match value.type_name {
		'String' { ruby_string_literal(value.as_string()) }
		'Integer' { value.int_data.str() }
		'Symbol' { value.as_string() }
		'Bool' { value.bool_data.str() }
		'NilClass' { 'nil' }
		else { none }
	}
}

pub fn generate_deserializer_nil_handler(prop CodegenProp,
	default_value ?ApplyDefaultDescriptor) string {
	if !prop.nilable_type {
		if descriptor := default_value {
			match descriptor.kind {
				.primitive {
					if literal := ruby_literal_value(descriptor.stored_default) {
						return literal
					}
				}
				.empty_array {
					return '[]'
				}
				.empty_hash {
					return '{}'
				}
				else {}
			}
			return 'self.class.decorator.props_with_defaults.fetch(${ruby_symbol_literal(prop.name)}).default'
		}
		return 'self.class.decorator.raise_nil_deserialize_error(${ruby_string_literal(prop.serialized_form)})'
	}
	if prop.raise_on_nil_write {
		return 'required_prop_missing_from_deserialize(${ruby_symbol_literal(prop.name)})'
	}
	return 'nil'
}

pub fn generate_deserializer_source(props []CodegenProp,
	defaults map[string]ApplyDefaultDescriptor) !string {
	mut parts := []string{}
	for prop in props {
		if prop.dont_store {
			continue
		}
		if !safe_codegen_name(prop.name) || !safe_codegen_name(prop.serialized_form) || !safe_accessor_name(prop.accessor_key) {
			return error('unsafe generated property name')
		}
		underlying := unwrap_setter_nilable(prop.type_object)
		transformed := generate_serde_transform(underlying, .deserialize, 'val') or { 'val' }
		nil_handler := generate_deserializer_nil_handler(prop, defaults[prop.name])
		parts << 'val = hash[${ruby_string_literal(prop.serialized_form)}]\n${prop.accessor_key} = if val.nil?\n  found -= 1 unless hash.key?(${ruby_string_literal(prop.serialized_form)}.freeze)\n  ${nil_handler}\nelse\n  ${transformed}\nend'
	}
	body := if parts.len == 0 {
		''
	} else {
		parts.join('\n\n').split('\n').map('  ${it}').join('\n')
	}
	return 'def __t_props_generated_deserialize(hash)\n  found = ${parts.len}\n  ${body}\n  found\nend\n'
}

fn deserializer_nil_value(prop CodegenProp, default_value ?ApplyDefaultDescriptor) !brew_runtime.Value {
	if !prop.nilable_type {
		if descriptor := default_value {
			return apply_default_value(descriptor)
		}
		return error('nil provided for non-optional serialized property `${prop.serialized_form}`')
	}
	if prop.raise_on_nil_write {
		return error('required prop `${prop.name}` missing from deserialize')
	}
	return private_nil_value()
}

pub fn generated_deserialize(props []CodegenProp, defaults map[string]ApplyDefaultDescriptor,
	hash map[string]brew_runtime.Value) !GeneratedDeserializeResult {
	mut found := props.filter(!it.dont_store).len
	mut values := map[string]brew_runtime.Value{}
	for prop in props {
		if prop.dont_store {
			continue
		}
		present := prop.serialized_form in hash
		value := hash[prop.serialized_form] or { private_nil_value() }
		if value.type_name == 'NilClass' {
			if !present {
				found--
			}
			values[prop.accessor_key] = deserializer_nil_value(prop, defaults[prop.name])!
		} else {
			values[prop.accessor_key] = apply_serde_transform(value, unwrap_setter_nilable(prop.type_object), .deserialize)!
		}
	}
	return GeneratedDeserializeResult{
		found: found
		values: values
	}
}

fn deserialize_result_value(result GeneratedDeserializeResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Integer'
		repr: result.found.str()
		int_data: result.found
		map_data: result.values.clone()
	}
}

// Ruby method `self.generate(props, defaults)` at line 33.
pub fn ruby_deserializer_generator_l33_d1_self_generate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DeserializerGenerator.generate requires props and defaults')
	}
	return brew_runtime.string_value(generate_deserializer_source(codegen_props_from_value(args[0]) or {
		panic(err)
	}, apply_defaults_from_value(args[1])) or { panic(err) })
}

// Ruby method `__t_props_generated_deserialize(hash)` at line 83.
pub fn ruby_deserializer_generator_l83_d2_t_props_generated_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('__t_props_generated_deserialize requires a receiver and hash')
	}
	props_value := args[0].map_data['_props'] or { panic('generated receiver has no _props') }
	defaults_value := args[0].map_data['_defaults'] or {
		brew_runtime.map_value(map[string]brew_runtime.Value{})
	}
	return deserialize_result_value(generated_deserialize(codegen_props_from_value(props_value) or {
		panic(err)
	}, apply_defaults_from_value(defaults_value), args[1].as_map() or { panic(err) }) or {
		panic(err)
	})
}

// Ruby method `self.generate_nil_handler(` at line 117.
pub fn ruby_deserializer_generator_l117_d3_self_generate_nil_handler(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('generate_nil_handler requires prop, serialized form, default, nilable type, and raise_on_nil_write')
	}
	prop := CodegenProp{
		name: args[0].as_string().trim_left(':')
		serialized_form: args[1].as_string()
		nilable_type: args[3].as_bool() or { panic(err) }
		raise_on_nil_write: args[4].as_bool() or { panic(err) }
	}
	default_value := if args[2].type_name == 'NilClass' {
		none
	} else {
		?ApplyDefaultDescriptor(*apply_default_descriptor_from_value(args[2]))
	}
	return brew_runtime.string_value(generate_deserializer_nil_handler(prop, default_value))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module Private
// 6:
// 7:     # Generates a specialized `deserialize` implementation for a subclass of
// 8:     # T::Props::Serializable.
// 9:     #
// 10:     # The basic idea is that we analyze the props and for each prop, generate
// 11:     # the simplest possible logic as a block of Ruby source, so that we don't
// 12:     # pay the cost of supporting types like T:::Hash[CustomType, SubstructType]
// 13:     # when deserializing a simple Integer. Then we join those together,
// 14:     # with a little shared logic to be able to detect when we get input keys
// 15:     # that don't match any prop.
// 16:     module DeserializerGenerator
// 17:       extend T::Sig
// 18:
// 19:       CAN_USE_SYMBOL_NAME = T.let(RUBY_VERSION >= "3.3.0", T::Boolean)
// 20:
// 21:       # Generate a method that takes a T::Hash[String, T.untyped] representing
// 22:       # serialized props, sets instance variables for each prop found in the
// 23:       # input, and returns the count of we props set (which we can use to check
// 24:       # for unexpected input keys with minimal effect on the fast path).
// 25:       sig do
// 26:         params(
// 27:           props: T::Hash[Symbol, T::Hash[Symbol, T.untyped]],
// 28:           defaults: T::Hash[Symbol, T::Props::Private::ApplyDefault],
// 29:         )
// 30:         .returns(String)
// 31:         .checked(:never)
// 32:       end
// 33:       def self.generate(props, defaults)
// 34:         parts = props.filter_map do |prop, rules|
// 35:           next if rules[:dont_store]
// 36:
// 37:           # All of these strings should already be validated (directly or
// 38:           # indirectly) in `validate_prop_name`, so we don't bother with a nice
// 39:           # error message, but we double check here to prevent a refactoring
// 40:           # from introducing a security vulnerability.
// 41:           raise unless T::Props::Decorator::SAFE_NAME.match?(CAN_USE_SYMBOL_NAME ? prop.name : prop.to_s)
// 42:
// 43:           hash_key = rules.fetch(:serialized_form)
// 44:           raise unless T::Props::Decorator::SAFE_NAME.match?(hash_key)
// 45:
// 46:           key = rules.fetch(:accessor_key)
// 47:           ivar_name = CAN_USE_SYMBOL_NAME ? key.name : key.to_s
// 48:           raise unless ivar_name.start_with?('@') && T::Props::Decorator::SAFE_ACCESSOR_KEY_NAME.match?(ivar_name)
// 49:
// 50:           transformation = SerdeTransform.generate(
// 51:             T::Utils::Nilable.get_underlying_type_object(rules.fetch(:type_object)),
// 52:             SerdeTransform::Mode::DESERIALIZE,
// 53:             'val'
// 54:           )
// 55:           transformed_val = transformation || 'val'
// 56:
// 57:           nil_handler = generate_nil_handler(
// 58:             prop: prop,
// 59:             serialized_form: hash_key,
// 60:             default: defaults[prop],
// 61:             nilable_type: T::Props::Utils.optional_prop?(rules),
// 62:             raise_on_nil_write: !!rules[:raise_on_nil_write],
// 63:           )
// 64:
// 65:           # The `.freeze` on the `hash.key?` argument matters: when this source
// 66:           # is eval'd lazily (without a frozen-string-literal prefix, unlike
// 67:           # `eagerly_define_lazy_methods!`), a bare literal here would allocate
// 68:           # a new String on every call for each nil/missing prop. `"str".freeze`
// 69:           # compiles to a no-allocation VM instruction (opt_str_freeze). The
// 70:           # `hash[...]` read doesn't need it because of opt_aref_with.
// 71:           <<~RUBY
// 72:             val = hash[#{hash_key.inspect}]
// 73:             #{ivar_name} = if val.nil?
// 74:               found -= 1 unless hash.key?(#{hash_key.inspect}.freeze)
// 75:               #{nil_handler}
// 76:             else
// 77:               #{transformed_val}
// 78:             end
// 79:           RUBY
// 80:         end
// 81:
// 82:         <<~RUBY
// 83:           def __t_props_generated_deserialize(hash)
// 84:             found = #{parts.size}
// 85:             #{parts.join("\n\n")}
// 86:             found
// 87:           end
// 88:         RUBY
// 89:       end
// 90:
// 91:       # This is very similar to what we do in ApplyDefault, but has a few
// 92:       # key differences that mean we don't just re-use the code:
// 93:       #
// 94:       # 1. Where the logic in construction is that we generate a default
// 95:       #    if & only if the prop key isn't present in the input, here we'll
// 96:       #    generate a default even to override an explicit nil, but only
// 97:       #    if the prop is actually required.
// 98:       # 2. Since we're generating raw Ruby source, we can remove a layer
// 99:       #    of indirection for marginally better performance; this seems worth
// 100:       #    it for the common cases of literals and empty arrays/hashes.
// 101:       # 3. We need to care about the distinction between `raise_on_nil_write`
// 102:       #    and actually non-nilable, where new-instance construction doesn't.
// 103:       #
// 104:       # So we fall back to ApplyDefault only when one of the cases just
// 105:       # mentioned doesn't apply.
// 106:       sig do
// 107:         params(
// 108:           prop: Symbol,
// 109:           serialized_form: String,
// 110:           default: T.nilable(ApplyDefault),
// 111:           nilable_type: T::Boolean,
// 112:           raise_on_nil_write: T::Boolean,
// 113:         )
// 114:         .returns(String)
// 115:         .checked(:never)
// 116:       end
// 117:       private_class_method def self.generate_nil_handler(
// 118:         prop:,
// 119:         serialized_form:,
// 120:         default:,
// 121:         nilable_type:,
// 122:         raise_on_nil_write:
// 123:       )
// 124:         if !nilable_type
// 125:           case default
// 126:           when NilClass
// 127:             "self.class.decorator.raise_nil_deserialize_error(#{serialized_form.inspect})"
// 128:           when ApplyPrimitiveDefault
// 129:             literal = default.default
// 130:             case literal
// 131:             # `Float` is intentionally left out here because `.inspect` does not produce the correct code
// 132:             # representation for non-finite values like `Float::INFINITY` and `Float::NAN` and it's not totally
// 133:             # clear that it won't cause issues with floating point precision.
// 134:             when String, Integer, Symbol, TrueClass, FalseClass, NilClass
// 135:               literal.inspect
// 136:             else
// 137:               "self.class.decorator.props_with_defaults.fetch(#{prop.inspect}).default"
// 138:             end
// 139:           when ApplyEmptyArrayDefault
// 140:             '[]'
// 141:           when ApplyEmptyHashDefault
// 142:             '{}'
// 143:           else
// 144:             "self.class.decorator.props_with_defaults.fetch(#{prop.inspect}).default"
// 145:           end
// 146:         elsif raise_on_nil_write
// 147:           "required_prop_missing_from_deserialize(#{prop.inspect})"
// 148:         else
// 149:           'nil'
// 150:         end
// 151:       end
// 152:     end
// 153:   end
// 154: end
