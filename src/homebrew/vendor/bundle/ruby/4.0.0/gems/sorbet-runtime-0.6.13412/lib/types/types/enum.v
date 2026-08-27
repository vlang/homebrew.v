module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/enum.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :values` at line 9.
pub fn ruby_enum_l9_d1_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values', ...args)
}

// Ruby method `initialize(values)` at line 11.
pub fn ruby_enum_l11_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 21.
pub fn ruby_enum_l21_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `valid?(obj)` at line 26.
pub fn ruby_enum_l26_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 31.
pub fn ruby_enum_l31_d5_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `name` at line 41.
pub fn ruby_enum_l41_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `describe_obj(obj)` at line 46.
pub fn ruby_enum_l46_d7_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_obj', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # validates that the provided value is within a given set/enum
// 6:   class Enum < Base
// 7:     extend T::Sig
// 8:
// 9:     attr_reader :values
// 10:
// 11:     def initialize(values)
// 12:       case values
// 13:       when Hash
// 14:         @values = values
// 15:       else
// 16:         require "set" unless defined?(Set)
// 17:         @values = values.to_set
// 18:       end
// 19:     end
// 20:
// 21:     def build_type
// 22:       nil
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     def valid?(obj)
// 27:       @values.member?(obj)
// 28:     end
// 29:
// 30:     # overrides Base
// 31:     private def subtype_of_single?(other)
// 32:       case other
// 33:       when Enum
// 34:         (@values - other.values).empty?
// 35:       else
// 36:         false
// 37:       end
// 38:     end
// 39:
// 40:     # overrides Base
// 41:     def name
// 42:       @name ||= "T.deprecated_enum([#{@values.map(&:inspect).sort.join(', ')}])"
// 43:     end
// 44:
// 45:     # overrides Base
// 46:     def describe_obj(obj)
// 47:       obj.inspect
// 48:     end
// 49:   end
// 50: end
