module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/void.rb`.
// The original source is retained below until every stub has a typed V body.
const void_validation_error = 'Validation is being done on an `Void`. Please report this bug at https://github.com/sorbet/sorbet/issues'

pub fn void_build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn void_name() string {
	return '<VOID>'
}

pub fn void_valid(_ brew_runtime.Value) !bool {
	return error(void_validation_error)
}

pub fn void_subtype_of_single(_ brew_runtime.Value) !bool {
	return error(void_validation_error)
}

// Ruby method `build_type` at line 21.
pub fn ruby_void_l21_d1_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return void_build_type()
}

// Ruby method `name` at line 26.
pub fn ruby_void_l26_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(void_name())
}

// Ruby method `valid?(obj)` at line 31.
pub fn ruby_void_l31_d3_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Void#valid? requires an object')
	}
	return brew_runtime.bool_value(void_valid(args[1]) or { panic(err) })
}

// Ruby method `subtype_of_single?(other)` at line 36.
pub fn ruby_void_l36_d4_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Void#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(void_subtype_of_single(args[1]) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # A marking class for when methods return void.
// 5: # Should never appear in types directly.
// 6: module T::Private::Types
// 7:   class Void < T::Types::Base
// 8:     ERROR_MESSAGE = "Validation is being done on an `Void`. Please report this bug at https://github.com/sorbet/sorbet/issues"
// 9:
// 10:     # The actual return value of `.void` methods.
// 11:     #
// 12:     # Uses `module VOID` because this gives it a readable name when someone
// 13:     # examines it in Pry or with `#inspect` like:
// 14:     #
// 15:     #     T::Private::Types::Void::VOID
// 16:     #
// 17:     module VOID
// 18:       freeze
// 19:     end
// 20:
// 21:     def build_type
// 22:       nil
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     def name
// 27:       "<VOID>"
// 28:     end
// 29:
// 30:     # overrides Base
// 31:     def valid?(obj)
// 32:       raise ERROR_MESSAGE
// 33:     end
// 34:
// 35:     # overrides Base
// 36:     private def subtype_of_single?(other)
// 37:       raise ERROR_MESSAGE
// 38:     end
// 39:
// 40:     module Private
// 41:       INSTANCE = Void.new.freeze
// 42:     end
// 43:   end
// 44: end
