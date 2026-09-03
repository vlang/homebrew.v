module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/optional.rb`.
// The original source is retained below until every stub has a typed V body.
const optional_default_setter_rule_key = '_t_props_private_apply_default'

pub struct OptionalDecoratorState {
pub:
	class_name string
pub mut:
	rules       map[string]map[string]brew_runtime.Value
	definitions map[string]PropDefinition
}

pub fn optional_valid_rule_key(super_valid bool, key string) bool {
	return super_valid || key.trim_left(':') in ['default', 'factory']
}

pub fn compute_derived_rules(mut rules map[string]brew_runtime.Value) {
	rules['fully_optional'] = brew_runtime.bool_value(!need_nil_write_check(rules))
	rules['need_nil_read_check'] = brew_runtime.bool_value(need_nil_read_check(rules))
}

fn default_setter_value(definition PropDefinition) brew_runtime.Value {
	mut data := map[string]brew_runtime.Value{}
	if definition.has_factory {
		data['factory'] = definition.factory_value
	} else {
		data['default'] = definition.default_value
	}
	return brew_runtime.Value{
		type_name: 'T::Props::Private::ApplyDefault'
		repr: definition.name
		map_data: data
		attributes: {
			'prop': definition.name
		}
	}
}

fn definition_from_rules(prop string, rules map[string]brew_runtime.Value) !PropDefinition {
	has_default_value := prop_rule(rules, 'default') != none
	has_factory_value := prop_rule(rules, 'factory') != none
	if has_default_value && has_factory_value {
		return error('Setting both :default and :factory is invalid. See: go/chalk-docs')
	}
	if !has_default_value && !has_factory_value && prop_rule(rules, '_bound_setter_proc') == none {
		return error('key not found: _bound_setter_proc')
	}
	return PropDefinition{
		name: prop
		expected_type: prop_rule(rules, 'type') or { brew_runtime.string_value('') }.as_string()
		required: need_nil_write_check(rules)
		has_default: has_default_value
		default_value: prop_rule(rules, 'default') or { props_nil_value() }
		has_factory: has_factory_value
		factory_value: prop_rule(rules, 'factory') or { props_nil_value() }
	}
}

pub fn optional_add_prop_definition(mut state OptionalDecoratorState, prop string,
	mut rules map[string]brew_runtime.Value) ! {
	compute_derived_rules(mut rules)
	definition := definition_from_rules(prop, rules)!
	state.definitions[prop] = definition
	if definition.has_default || definition.has_factory {
		rules[optional_default_setter_rule_key] = default_setter_value(definition)
	}
	state.rules[prop] = rules.clone()
}

pub fn optional_prop_is_optional(state OptionalDecoratorState, prop string) bool {
	rules := (state.rules[prop] or { return false }).clone()
	return prop_rule_enabled(rules, 'fully_optional')
}

pub fn optional_props_with_defaults(state OptionalDecoratorState) map[string]PropDefinition {
	mut result := map[string]PropDefinition{}
	for prop, definition in state.definitions {
		if definition.has_default || definition.has_factory {
			result[prop] = definition
		}
	}
	return result
}

pub fn optional_props_without_defaults(state OptionalDecoratorState) map[string]PropDefinition {
	mut result := map[string]PropDefinition{}
	for prop, definition in state.definitions {
		if !definition.has_default && !definition.has_factory {
			result[prop] = definition
		}
	}
	return result
}

pub fn optional_validate_definition(rules map[string]brew_runtime.Value) ! {
	if prop_rule(rules, 'default') != none && prop_rule(rules, 'factory') != none {
		return error('Setting both :default and :factory is invalid. See: go/chalk-docs')
	}
}

pub fn optional_has_default(rules map[string]brew_runtime.Value) bool {
	return prop_rule(rules, optional_default_setter_rule_key) != none
}

pub fn optional_get_default(rules map[string]brew_runtime.Value) brew_runtime.Value {
	setter := prop_rule(rules, optional_default_setter_rule_key) or { return props_nil_value() }
	return setter.map_data['default'] or { setter.map_data['factory'] or { props_nil_value() } }
}

fn optional_rules_value(definitions map[string]PropDefinition, with_defaults bool) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for name, definition in definitions {
		if (definition.has_default || definition.has_factory) == with_defaults {
			result[name] = if with_defaults {
				default_setter_value(definition)
			} else {
				brew_runtime.structured_value('BoundSetterProc', name, {
					'prop': name
				})
			}
		}
	}
	return brew_runtime.map_value(result)
}

fn optional_state_from_value(value brew_runtime.Value) OptionalDecoratorState {
	mut definitions := map[string]PropDefinition{}
	for definition_value in value.array_data {
		definition := prop_definition_from_value(definition_value)
		definitions[definition.name] = definition
	}
	mut rules := map[string]map[string]brew_runtime.Value{}
	for prop, rule_value in value.map_data {
		if rule_value.type_name == 'Hash' {
			rules[prop] = rule_value.map_data.clone()
		}
	}
	return OptionalDecoratorState{
		class_name: value.attribute('class_name') or { value.type_name }
		rules: rules
		definitions: definitions
	}
}

// Ruby method `valid_rule_key?(key)` at line 32.
pub fn ruby_optional_l32_d1_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Optional#valid_rule_key? requires a key')
	}
	super_valid := args[0].attribute('super_valid') or { 'false' } == 'true'
	return brew_runtime.bool_value(optional_valid_rule_key(super_valid, args[1].as_string()))
}

// Ruby method `prop_optional?(prop)` at line 36.
pub fn ruby_optional_l36_d2_prop_optional(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Optional#prop_optional? requires a prop')
	}
	return brew_runtime.bool_value(optional_prop_is_optional(optional_state_from_value(args[0]), args[1].as_string()))
}

// Ruby method `compute_derived_rules(rules)` at line 40.
pub fn ruby_optional_l40_d3_compute_derived_rules(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Optional#compute_derived_rules requires rules')
	}
	mut rules := args[1].as_map() or { panic(err) }
	compute_derived_rules(mut rules)
	return brew_runtime.map_value(rules)
}

// Ruby attr_reader `attr_reader :props_with_defaults` at line 47.
pub fn ruby_optional_l47_d4_props_with_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Optional#props_with_defaults requires a receiver')
	}
	state := optional_state_from_value(args[0])
	return optional_rules_value(state.definitions, true)
}

// Ruby attr_reader `attr_reader :props_without_defaults` at line 51.
pub fn ruby_optional_l51_d5_props_without_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Optional#props_without_defaults requires a receiver')
	}
	state := optional_state_from_value(args[0])
	return optional_rules_value(state.definitions, false)
}

// Ruby method `add_prop_definition(prop, rules)` at line 53.
pub fn ruby_optional_l53_d6_add_prop_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Optional#add_prop_definition requires a prop and rules')
	}
	mut state := optional_state_from_value(args[0])
	mut rules := args[2].as_map() or { panic(err) }
	optional_add_prop_definition(mut state, args[1].as_string(), mut rules) or { panic(err) }
	return brew_runtime.map_value(rules)
}

// Ruby method `prop_validate_definition!(name, cls, rules, type)` at line 72.
pub fn ruby_optional_l72_d7_prop_validate_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('Optional#prop_validate_definition! requires name, class, rules, and type')
	}
	optional_validate_definition(args[3].as_map() or { panic(err) }) or { panic(err) }
	return props_nil_value()
}

// Ruby method `has_default?(rules)` at line 82.
pub fn ruby_optional_l82_d8_has_default(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Optional#has_default? requires rules')
	}
	return brew_runtime.bool_value(optional_has_default(args[1].as_map() or { panic(err) }))
}

// Ruby method `get_default(rules, instance_class)` at line 86.
pub fn ruby_optional_l86_d9_get_default(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Optional#get_default requires rules')
	}
	return optional_get_default(args[1].as_map() or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::Optional
// 5:   include T::Props::Plugin
// 6: end
// 7:
// 8: ##############################################
// 9:
// 10: # NB: This must stay in the same file where T::Props::Optional is defined due to
// 11: # T::Props::Decorator#apply_plugin; see https://git.corp.stripe.com/stripe-internal/pay-server/blob/fc7f15593b49875f2d0499ffecfd19798bac05b3/chalk/odm/lib/chalk-odm/document_decorator.rb#L716-L717
// 12: module T::Props::Optional::DecoratorMethods
// 13:   extend T::Sig
// 14:
// 15:   # Heads up!
// 16:   #
// 17:   # There are already too many ad-hoc options on the prop DSL.
// 18:   #
// 19:   # We have already done a lot of work to remove unnecessary and confusing
// 20:   # options. If you're considering adding a new rule key, please come chat with
// 21:   # the Sorbet team first, as we'd really like to learn more about how to best
// 22:   # solve the problem you're encountering.
// 23:   VALID_RULE_KEYS = {
// 24:     default: true,
// 25:     factory: true,
// 26:   }.freeze
// 27:   private_constant :VALID_RULE_KEYS
// 28:
// 29:   DEFAULT_SETTER_RULE_KEY = :_t_props_private_apply_default
// 30:   private_constant :DEFAULT_SETTER_RULE_KEY
// 31:
// 32:   def valid_rule_key?(key)
// 33:     super || VALID_RULE_KEYS[key]
// 34:   end
// 35:
// 36:   def prop_optional?(prop)
// 37:     prop_rules(prop)[:fully_optional]
// 38:   end
// 39:
// 40:   def compute_derived_rules(rules)
// 41:     rules[:fully_optional] = !T::Props::Utils.need_nil_write_check?(rules)
// 42:     rules[:need_nil_read_check] = T::Props::Utils.need_nil_read_check?(rules)
// 43:   end
// 44:
// 45:   # checked(:never) - O(runtime object construction)
// 46:   sig { returns(T::Hash[Symbol, T::Props::Private::ApplyDefault]).checked(:never) }
// 47:   attr_reader :props_with_defaults
// 48:
// 49:   # checked(:never) - O(runtime object construction)
// 50:   sig { returns(T::Hash[Symbol, T::Props::Private::SetterFactory::BoundSetterProc]).checked(:never) }
// 51:   attr_reader :props_without_defaults
// 52:
// 53:   def add_prop_definition(prop, rules)
// 54:     compute_derived_rules(rules)
// 55:
// 56:     default_setter = T::Props::Private::ApplyDefault.for(decorated_class, rules)
// 57:     if default_setter
// 58:       @props_with_defaults ||= {}
// 59:       @props_with_defaults[prop] = default_setter
// 60:       props_without_defaults&.delete(prop) # Handle potential override
// 61:
// 62:       rules[DEFAULT_SETTER_RULE_KEY] = default_setter
// 63:     else
// 64:       @props_without_defaults ||= {}
// 65:       @props_without_defaults[prop] = rules.fetch(:_bound_setter_proc)
// 66:       props_with_defaults&.delete(prop) # Handle potential override
// 67:     end
// 68:
// 69:     super
// 70:   end
// 71:
// 72:   def prop_validate_definition!(name, cls, rules, type)
// 73:     result = super
// 74:
// 75:     if rules.key?(:default) && rules.key?(:factory)
// 76:       raise ArgumentError.new("Setting both :default and :factory is invalid. See: go/chalk-docs")
// 77:     end
// 78:
// 79:     result
// 80:   end
// 81:
// 82:   def has_default?(rules)
// 83:     rules.include?(DEFAULT_SETTER_RULE_KEY)
// 84:   end
// 85:
// 86:   def get_default(rules, instance_class)
// 87:     rules[DEFAULT_SETTER_RULE_KEY]&.default
// 88:   end
// 89: end
