module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/class_of.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :type` at line 7.
pub fn ruby_class_of_l7_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `initialize(type)` at line 9.
pub fn ruby_class_of_l9_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 13.
pub fn ruby_class_of_l13_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 18.
pub fn ruby_class_of_l18_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 23.
pub fn ruby_class_of_l23_d5_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 28.
pub fn ruby_class_of_l28_d6_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `describe_obj(obj)` at line 42.
pub fn ruby_class_of_l42_d7_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_obj', ...args)
}

// Ruby method `[](*types)` at line 51.
pub fn ruby_class_of_l51_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object belongs to the specified class.
// 6:   class ClassOf < Base
// 7:     attr_reader :type
// 8:
// 9:     def initialize(type)
// 10:       @type = type
// 11:     end
// 12:
// 13:     def build_type
// 14:       nil
// 15:     end
// 16:
// 17:     # overrides Base
// 18:     def name
// 19:       "T.class_of(#{@type})"
// 20:     end
// 21:
// 22:     # overrides Base
// 23:     def valid?(obj)
// 24:       obj.is_a?(@type.singleton_class)
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     def subtype_of_single?(other)
// 29:       case other
// 30:       when ClassOf
// 31:         @type.is_a?(other.type.singleton_class)
// 32:       when Simple
// 33:         @type.is_a?(other.raw_type)
// 34:       when TypedClass, TypedModule
// 35:         @type.is_a?(other.underlying_class)
// 36:       else
// 37:         false
// 38:       end
// 39:     end
// 40:
// 41:     # overrides Base
// 42:     def describe_obj(obj)
// 43:       obj.inspect
// 44:     end
// 45:
// 46:     # So that `T.class_of(...)[...]` syntax is valid.
// 47:     # Mirrors the definition of T::Generic#[] (generics are erased).
// 48:     #
// 49:     # We avoid simply writing `include T::Generic` because we don't want any of
// 50:     # the other methods to appear (`T.class_of(A).type_member` doesn't make sense)
// 51:     def [](*types)
// 52:       self
// 53:     end
// 54:   end
// 55: end
