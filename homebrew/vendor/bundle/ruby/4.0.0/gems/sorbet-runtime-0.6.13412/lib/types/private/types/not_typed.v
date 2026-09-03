module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/not_typed.rb`.
// The original source is retained below until every stub has a typed V body.
const not_typed_validation_error = 'Validation is being done on a `NotTyped`. Please report this bug at https://github.com/sorbet/sorbet/issues'

pub fn not_typed_build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn not_typed_name() string {
	return '<NOT-TYPED>'
}

pub fn not_typed_valid(_ brew_runtime.Value) !bool {
	return error(not_typed_validation_error)
}

pub fn not_typed_subtype_of_single(_ brew_runtime.Value) !bool {
	return error(not_typed_validation_error)
}

// Ruby method `build_type` at line 9.
pub fn ruby_not_typed_l9_d1_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return not_typed_build_type()
}

// Ruby method `name` at line 14.
pub fn ruby_not_typed_l14_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(not_typed_name())
}

// Ruby method `valid?(obj)` at line 19.
pub fn ruby_not_typed_l19_d3_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('NotTyped#valid? requires an object')
	}
	return brew_runtime.bool_value(not_typed_valid(args[1]) or { panic(err) })
}

// Ruby method `subtype_of_single?(other)` at line 24.
pub fn ruby_not_typed_l24_d4_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('NotTyped#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(not_typed_subtype_of_single(args[1]) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # A placeholder for when an untyped thing must provide a type.
// 5: # Raises an exception if it is ever used for validation.
// 6: class T::Private::Types::NotTyped < T::Types::Base
// 7:   ERROR_MESSAGE = "Validation is being done on a `NotTyped`. Please report this bug at https://github.com/sorbet/sorbet/issues"
// 8:
// 9:   def build_type
// 10:     nil
// 11:   end
// 12:
// 13:   # overrides Base
// 14:   def name
// 15:     "<NOT-TYPED>"
// 16:   end
// 17:
// 18:   # overrides Base
// 19:   def valid?(obj)
// 20:     raise ERROR_MESSAGE
// 21:   end
// 22:
// 23:   # overrides Base
// 24:   private def subtype_of_single?(other)
// 25:     raise ERROR_MESSAGE
// 26:   end
// 27:
// 28:   INSTANCE = ::T::Private::Types::NotTyped.new.freeze
// 29: end
