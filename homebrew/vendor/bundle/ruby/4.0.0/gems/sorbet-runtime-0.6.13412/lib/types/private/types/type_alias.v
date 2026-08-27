module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/type_alias.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(callable)` at line 8.
pub fn ruby_type_alias_l8_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `checked(level)` at line 13.
pub fn ruby_type_alias_l13_d2_checked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checked', ...args)
}

// Ruby method `build_type` at line 24.
pub fn ruby_type_alias_l24_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `aliased_type` at line 28.
pub fn ruby_type_alias_l28_d4_aliased_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aliased_type', ...args)
}

// Ruby method `effective_aliased_type` at line 32.
pub fn ruby_type_alias_l32_d5_effective_aliased_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('effective_aliased_type', ...args)
}

// Ruby method `name` at line 45.
pub fn ruby_type_alias_l45_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 50.
pub fn ruby_type_alias_l50_d7_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 55.
pub fn ruby_type_alias_l55_d8_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Types
// 5:   # Wraps a proc for a type alias to defer its evaluation.
// 6:   class TypeAlias < T::Types::Base
// 7:
// 8:     def initialize(callable)
// 9:       @callable = callable
// 10:       @checked_level = nil
// 11:     end
// 12:
// 13:     def checked(level)
// 14:       if !@checked_level.nil?
// 15:         raise "You can't call .checked multiple times on a type alias."
// 16:       end
// 17:       if !T::Private::RuntimeLevels::LEVELS.include?(level)
// 18:         raise ArgumentError.new("Invalid `checked` level '#{level}'. Use one of: #{T::Private::RuntimeLevels::LEVELS}.")
// 19:       end
// 20:       @checked_level = level
// 21:       self
// 22:     end
// 23:
// 24:     def build_type
// 25:       nil
// 26:     end
// 27:
// 28:     def aliased_type
// 29:       @aliased_type ||= T::Utils.coerce(@callable.call)
// 30:     end
// 31:
// 32:     def effective_aliased_type
// 33:       @effective_aliased_type ||= begin
// 34:         real_type = aliased_type
// 35:         level = @checked_level.nil? ? T::Private::RuntimeLevels.default_checked_level : @checked_level
// 36:         if level == :always || (level == :tests && T::Private::RuntimeLevels.check_tests?)
// 37:           real_type
// 38:         else
// 39:           T::Types::Anything::Private::INSTANCE
// 40:         end
// 41:       end
// 42:     end
// 43:
// 44:     # overrides Base
// 45:     def name
// 46:       aliased_type.name
// 47:     end
// 48:
// 49:     # overrides Base
// 50:     def recursively_valid?(obj)
// 51:       effective_aliased_type.recursively_valid?(obj)
// 52:     end
// 53:
// 54:     # overrides Base
// 55:     def valid?(obj)
// 56:       effective_aliased_type.valid?(obj)
// 57:     end
// 58:   end
// 59: end
