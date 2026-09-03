module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/serializer_generator.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CodegenProp {
pub:
	name               string
	serialized_form    string
	accessor_key       string
	type_object        brew_runtime.Value
	dont_store         bool
	fully_optional     bool
	nilable_type       bool
	raise_on_nil_write bool
}

fn safe_codegen_name(name string) bool {
	if name.len == 0 || !((name[0] >= `A` && name[0] <= `Z`) || (name[0] >= `a` && name[0] <= `z`) || name[0] == `_`) {
		return false
	}
	for character in name[1..] {
		if !((character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character in [
			`_`,
			`-`,
		]) {
			return false
		}
	}
	return true
}

fn safe_accessor_name(name string) bool {
	return name.starts_with('@') && safe_codegen_name(name[1..])
}

fn ruby_string_literal(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"')}"'
}

fn ruby_symbol_literal(value string) string {
	return ':${value.trim_left(':')}'
}

fn codegen_prop_from_rules(name string, rules map[string]brew_runtime.Value) !CodegenProp {
	serialized_form := (private_rule(rules, 'serialized_form') or {
		return error('key not found: serialized_form')
	}).as_string()
	accessor_key := (private_rule(rules, 'accessor_key') or {
		return error('key not found: accessor_key')
	}).as_string()
	type_object := private_rule(rules, 'type_object') or {
		return error('key not found: type_object')
	}
	if !safe_codegen_name(name) || !safe_codegen_name(serialized_form) || !safe_accessor_name(accessor_key) {
		return error('unsafe generated property name')
	}
	return CodegenProp{
		name: name
		serialized_form: serialized_form
		accessor_key: accessor_key
		type_object: type_object
		dont_store: private_rule_enabled(rules, 'dont_store')
		fully_optional: private_rule_enabled(rules, 'fully_optional')
		nilable_type: private_rule_enabled(rules, '_tnilable')
		raise_on_nil_write: private_rule_enabled(rules, 'raise_on_nil_write')
	}
}

fn codegen_props_from_value(value brew_runtime.Value) ![]CodegenProp {
	mut props := []CodegenProp{}
	for name, rules_value in value.map_data {
		props << codegen_prop_from_rules(name.trim_left(':'), rules_value.as_map()!)!
	}
	props.sort_with_compare(fn (left &CodegenProp, right &CodegenProp) int {
		return left.name.compare(right.name)
	})
	return props
}

pub fn generate_serializer_source(props []CodegenProp) !string {
	mut parts := []string{}
	for prop in props {
		if prop.dont_store {
			continue
		}
		if !safe_codegen_name(prop.name) || !safe_codegen_name(prop.serialized_form) || !safe_accessor_name(prop.accessor_key) {
			return error('unsafe generated property name')
		}
		underlying := unwrap_setter_nilable(prop.type_object)
		transformed := generate_serde_transform(underlying, .serialize, prop.accessor_key) or {
			prop.accessor_key
		}
		nil_asserter := if prop.fully_optional {
			''
		} else {
			'required_prop_missing_from_serialize(${ruby_symbol_literal(prop.name)}) if strict'
		}
		parts << 'if ${prop.accessor_key}.nil?\n  ${nil_asserter}\nelse\n  h[${ruby_string_literal(prop.serialized_form)}] = ${transformed}\nend'
	}
	body := if parts.len == 0 {
		''
	} else {
		parts.join('\n\n').split('\n').map('  ${it}').join('\n')
	}
	return 'def __t_props_generated_serialize(strict)\n  h = {}\n  ${body}\n  h\nend\n'
}

pub fn generated_serialize(props []CodegenProp, values map[string]brew_runtime.Value,
	strict bool) !map[string]brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for prop in props {
		if prop.dont_store {
			continue
		}
		value := values[prop.accessor_key] or { values[prop.name] or { private_nil_value() } }
		if value.type_name == 'NilClass' {
			if strict && !prop.fully_optional {
				return error('${prop.name} not set for non-optional prop')
			}
			continue
		}
		result[prop.serialized_form] = apply_serde_transform(value, unwrap_setter_nilable(prop.type_object), .serialize)!
	}
	return result
}

fn generated_receiver_parts(receiver brew_runtime.Value) !([]CodegenProp, map[string]brew_runtime.Value) {
	props_value := receiver.map_data['_props'] or { return error('generated receiver has no _props') }
	values_value := receiver.map_data['_values'] or { return error('generated receiver has no _values') }
	return codegen_props_from_value(props_value)!, values_value.as_map()!
}

// Ruby method `self.generate(props)` at line 28.
pub fn ruby_serializer_generator_l28_d1_self_generate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SerializerGenerator.generate requires props')
	}
	return brew_runtime.string_value(generate_serializer_source(codegen_props_from_value(args[0]) or {
		panic(err)
	}) or { panic(err) })
}

// Ruby method `__t_props_generated_serialize(strict)` at line 71.
pub fn ruby_serializer_generator_l71_d2_t_props_generated_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('__t_props_generated_serialize requires a receiver')
	}
	props, values := generated_receiver_parts(args[0]) or { panic(err) }
	strict := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { true }
	return brew_runtime.map_value(generated_serialize(props, values, strict) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module Private
// 6:
// 7:     # Generates a specialized `serialize` implementation for a subclass of
// 8:     # T::Props::Serializable.
// 9:     #
// 10:     # The basic idea is that we analyze the props and for each prop, generate
// 11:     # the simplest possible logic as a block of Ruby source, so that we don't
// 12:     # pay the cost of supporting types like T:::Hash[CustomType, SubstructType]
// 13:     # when serializing a simple Integer. Then we join those together,
// 14:     # with a little shared logic to be able to detect when we get input keys
// 15:     # that don't match any prop.
// 16:     module SerializerGenerator
// 17:       extend T::Sig
// 18:
// 19:       CAN_USE_SYMBOL_NAME = T.let(RUBY_VERSION >= "3.3.0", T::Boolean)
// 20:
// 21:       sig do
// 22:         params(
// 23:           props: T::Hash[Symbol, T::Hash[Symbol, T.untyped]],
// 24:         )
// 25:         .returns(String)
// 26:         .checked(:never)
// 27:       end
// 28:       def self.generate(props)
// 29:         parts = props.filter_map do |prop, rules|
// 30:           next if rules[:dont_store]
// 31:
// 32:           # All of these strings should already be validated (directly or
// 33:           # indirectly) in `validate_prop_name`, so we don't bother with a nice
// 34:           # error message, but we double check here to prevent a refactoring
// 35:           # from introducing a security vulnerability.
// 36:           raise unless T::Props::Decorator::SAFE_NAME.match?(CAN_USE_SYMBOL_NAME ? prop.name : prop.to_s)
// 37:
// 38:           hash_key = rules.fetch(:serialized_form)
// 39:           raise unless T::Props::Decorator::SAFE_NAME.match?(hash_key)
// 40:
// 41:           key = rules.fetch(:accessor_key)
// 42:           ivar_name = CAN_USE_SYMBOL_NAME ? key.name : key.to_s
// 43:           raise unless ivar_name.start_with?('@') && T::Props::Decorator::SAFE_ACCESSOR_KEY_NAME.match?(ivar_name)
// 44:
// 45:           transformed_val = SerdeTransform.generate(
// 46:             T::Utils::Nilable.get_underlying_type_object(rules.fetch(:type_object)),
// 47:             SerdeTransform::Mode::SERIALIZE,
// 48:             ivar_name
// 49:           ) || ivar_name
// 50:
// 51:           nil_asserter =
// 52:             if rules[:fully_optional]
// 53:               ''
// 54:             else
// 55:               "required_prop_missing_from_serialize(#{prop.inspect}) if strict"
// 56:             end
// 57:
// 58:           # Don't serialize values that are nil to save space (both the
// 59:           # nil value itself and the field name in the serialized BSON
// 60:           # document)
// 61:           <<~RUBY
// 62:             if #{ivar_name}.nil?
// 63:               #{nil_asserter}
// 64:             else
// 65:               h[#{hash_key.inspect}] = #{transformed_val}
// 66:             end
// 67:           RUBY
// 68:         end
// 69:
// 70:         <<~RUBY
// 71:           def __t_props_generated_serialize(strict)
// 72:             h = {}
// 73:             #{parts.join("\n\n")}
// 74:             h
// 75:           end
// 76:         RUBY
// 77:       end
// 78:     end
// 79:   end
// 80: end
