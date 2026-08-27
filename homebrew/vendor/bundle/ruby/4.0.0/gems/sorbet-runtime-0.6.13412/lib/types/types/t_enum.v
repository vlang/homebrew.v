module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/t_enum.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :val` at line 7.
pub fn ruby_t_enum_l7_d1_val(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('val', ...args)
}

// Ruby method `initialize(val)` at line 9.
pub fn ruby_t_enum_l9_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 13.
pub fn ruby_t_enum_l13_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 18.
pub fn ruby_t_enum_l18_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 28.
pub fn ruby_t_enum_l28_d5_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 33.
pub fn ruby_t_enum_l33_d6_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object is equal to another T::Enum singleton value.
// 6:   class TEnum < Base
// 7:     attr_reader :val
// 8:
// 9:     def initialize(val)
// 10:       @val = val
// 11:     end
// 12:
// 13:     def build_type
// 14:       nil
// 15:     end
// 16:
// 17:     # overrides Base
// 18:     def name
// 19:       # Strips the #<...> off, just leaving the ...
// 20:       # Reasoning: the user will have written something like
// 21:       #   T.any(MyEnum::A, MyEnum::B)
// 22:       # in the type, so we should print what they wrote in errors, not:
// 23:       #   T.any(#<MyEnum::A>, #<MyEnum::B>)
// 24:       @val.inspect[2..-2]
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     def valid?(obj)
// 29:       @val == obj
// 30:     end
// 31:
// 32:     # overrides Base
// 33:     private def subtype_of_single?(other)
// 34:       case other
// 35:       when TEnum
// 36:         @val == other.val
// 37:       when Simple
// 38:         other.raw_type.===(@val)
// 39:       else
// 40:         false
// 41:       end
// 42:     end
// 43:   end
// 44: end
