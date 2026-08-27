module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/type_validation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_rule_key?(key)` at line 15.
pub fn ruby_type_validation_l15_d1_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_rule_key?', ...args)
}

// Ruby method `prop_validate_definition!(name, _cls, rules, type)` at line 30.
pub fn ruby_type_validation_l30_d2_prop_validate_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prop_validate_definition!', ...args)
}

// Ruby method `validate_type(type, field_name)` at line 48.
pub fn ruby_type_validation_l48_d3_validate_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_type', ...args)
}

// Ruby method `find_invalid_subtype(type)` at line 62.
pub fn ruby_type_validation_l62_d4_find_invalid_subtype(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_invalid_subtype', ...args)
}

// Ruby method `type_error_message(type, field_name, orig_type)` at line 105.
pub fn ruby_type_validation_l105_d5_type_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_error_message', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::TypeValidation
// 5:   include T::Props::Plugin
// 6:
// 7:   BANNED_TYPES = [Object, BasicObject, Kernel].freeze
// 8:
// 9:   class UnderspecifiedType < ArgumentError; end
// 10:
// 11:   module DecoratorMethods
// 12:     extend T::Sig
// 13:
// 14:     sig { params(key: Symbol).returns(T::Boolean).checked(:never) }
// 15:     def valid_rule_key?(key)
// 16:       super || key == :DEPRECATED_underspecified_type
// 17:     end
// 18:
// 19:     # checked(:never) - Rules hash is expensive to check
// 20:     sig do
// 21:       params(
// 22:         name: T.any(Symbol, String),
// 23:         _cls: T::Module[T.anything],
// 24:         rules: T::Hash[Symbol, T.untyped],
// 25:         type: T.any(T::Types::Base, T::Module[T.anything])
// 26:       )
// 27:       .void
// 28:       .checked(:never)
// 29:     end
// 30:     def prop_validate_definition!(name, _cls, rules, type)
// 31:       super
// 32:
// 33:       if !rules[:DEPRECATED_underspecified_type]
// 34:         validate_type(type, name)
// 35:       elsif rules[:DEPRECATED_underspecified_type] && find_invalid_subtype(type).nil?
// 36:         raise ArgumentError.new("DEPRECATED_underspecified_type set unnecessarily for #{@class.name}.#{name} - #{type} is a valid type")
// 37:       end
// 38:     end
// 39:
// 40:     sig do
// 41:       params(
// 42:         type: T::Types::Base,
// 43:         field_name: T.any(Symbol, String),
// 44:       )
// 45:       .void
// 46:       .checked(:never)
// 47:     end
// 48:     private def validate_type(type, field_name)
// 49:       if (invalid_subtype = find_invalid_subtype(type))
// 50:         raise UnderspecifiedType.new(type_error_message(invalid_subtype, field_name, type))
// 51:       end
// 52:     end
// 53:
// 54:     # Returns an invalid type, if any, found in the given top-level type.
// 55:     # This might be the type itself, if it is e.g. "Object", or might be
// 56:     # a subtype like the type of the values of a typed hash.
// 57:     #
// 58:     # If the type is fully valid, returns nil.
// 59:     #
// 60:     # checked(:never) - called potentially many times recursively
// 61:     sig { params(type: T::Types::Base).returns(T.nilable(T::Types::Base)).checked(:never) }
// 62:     private def find_invalid_subtype(type)
// 63:       case type
// 64:       when T::Types::TypedEnumerable
// 65:         find_invalid_subtype(type.type)
// 66:       when T::Types::FixedHash
// 67:         type.types.values.map { |subtype| find_invalid_subtype(subtype) }.compact.first
// 68:       when T::Types::Union, T::Types::FixedArray
// 69:         # `T.any` is valid if all of the members are valid
// 70:         type.types.map { |subtype| find_invalid_subtype(subtype) }.compact.first
// 71:       when T::Types::Intersection
// 72:         # `T.all` is valid if at least one of the members is valid
// 73:         invalid = type.types.map { |subtype| find_invalid_subtype(subtype) }.compact
// 74:         if invalid.length == type.types.length
// 75:           invalid.first
// 76:         else
// 77:           nil
// 78:         end
// 79:       when T::Types::Enum, T::Types::ClassOf
// 80:         nil
// 81:       when T::Private::Types::TypeAlias
// 82:         find_invalid_subtype(type.aliased_type)
// 83:       when T::Types::Simple
// 84:         # TODO Could we manage to define a whitelist, consisting of something
// 85:         # like primitives, subdocs, DataInterfaces, and collections/enums/unions
// 86:         # thereof?
// 87:         if BANNED_TYPES.include?(type.raw_type)
// 88:           type
// 89:         else
// 90:           nil
// 91:         end
// 92:       else
// 93:         type
// 94:       end
// 95:     end
// 96:
// 97:     sig do
// 98:       params(
// 99:         type: T::Types::Base,
// 100:         field_name: T.any(Symbol, String),
// 101:         orig_type: T::Types::Base,
// 102:       )
// 103:       .returns(String)
// 104:     end
// 105:     private def type_error_message(type, field_name, orig_type)
// 106:       msg_prefix = "#{@class.name}.#{field_name}: #{orig_type} is invalid in prop definition"
// 107:       if type == orig_type
// 108:         "#{msg_prefix}. Please choose a more specific type (T.untyped and ~equivalents like Object are banned)."
// 109:       else
// 110:         "#{msg_prefix}. Please choose a subtype more specific than #{type} (T.untyped and ~equivalents like Object are banned)."
// 111:       end
// 112:     end
// 113:   end
// 114: end
