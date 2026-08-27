module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/serializer_generator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.generate(props)` at line 28.
pub fn ruby_serializer_generator_l28_d1_self_generate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate', ...args)
}

// Ruby method `__t_props_generated_serialize(strict)` at line 71.
pub fn ruby_serializer_generator_l71_d2_t_props_generated_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('__t_props_generated_serialize', ...args)
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
