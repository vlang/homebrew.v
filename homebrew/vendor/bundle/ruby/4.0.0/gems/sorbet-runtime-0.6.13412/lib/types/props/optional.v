module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/optional.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_rule_key?(key)` at line 32.
pub fn ruby_optional_l32_d1_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_rule_key?', ...args)
}

// Ruby method `prop_optional?(prop)` at line 36.
pub fn ruby_optional_l36_d2_prop_optional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prop_optional?', ...args)
}

// Ruby method `compute_derived_rules(rules)` at line 40.
pub fn ruby_optional_l40_d3_compute_derived_rules(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_derived_rules', ...args)
}

// Ruby attr_reader `attr_reader :props_with_defaults` at line 47.
pub fn ruby_optional_l47_d4_props_with_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('props_with_defaults', ...args)
}

// Ruby attr_reader `attr_reader :props_without_defaults` at line 51.
pub fn ruby_optional_l51_d5_props_without_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('props_without_defaults', ...args)
}

// Ruby method `add_prop_definition(prop, rules)` at line 53.
pub fn ruby_optional_l53_d6_add_prop_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_prop_definition', ...args)
}

// Ruby method `prop_validate_definition!(name, cls, rules, type)` at line 72.
pub fn ruby_optional_l72_d7_prop_validate_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prop_validate_definition!', ...args)
}

// Ruby method `has_default?(rules)` at line 82.
pub fn ruby_optional_l82_d8_has_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has_default?', ...args)
}

// Ruby method `get_default(rules, instance_class)` at line 86.
pub fn ruby_optional_l86_d9_get_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_default', ...args)
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
