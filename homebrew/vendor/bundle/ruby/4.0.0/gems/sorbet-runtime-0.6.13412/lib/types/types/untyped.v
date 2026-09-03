module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/untyped.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct UntypedType {}

pub fn new_untyped_type() UntypedType {
	return UntypedType{}
}

pub fn (_ UntypedType) build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn (_ UntypedType) name() string {
	return 'T.untyped'
}

pub fn (_ UntypedType) valid(_ brew_runtime.Value) bool {
	return true
}

pub fn (_ UntypedType) subtype_of_single(_ brew_runtime.Value) bool {
	return true
}

fn untyped_type_value() brew_runtime.Value {
	return brew_runtime.object_value('T::Types::Untyped', 'T.untyped')
}

// Ruby method `initialize; end` at line 8.
pub fn ruby_untyped_l8_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `build_type` at line 10.
pub fn ruby_untyped_l10_d2_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return new_untyped_type().build_type()
}

// Ruby method `name` at line 15.
pub fn ruby_untyped_l15_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(new_untyped_type().name())
}

// Ruby method `valid?(obj)` at line 20.
pub fn ruby_untyped_l20_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `subtype_of_single?(other)` at line 25.
pub fn ruby_untyped_l25_d5_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # A dynamic type, which permits whatever
// 6:   class Untyped < Base
// 7:
// 8:     def initialize; end
// 9:
// 10:     def build_type
// 11:       nil
// 12:     end
// 13:
// 14:     # overrides Base
// 15:     def name
// 16:       "T.untyped"
// 17:     end
// 18:
// 19:     # overrides Base
// 20:     def valid?(obj)
// 21:       true
// 22:     end
// 23:
// 24:     # overrides Base
// 25:     private def subtype_of_single?(other)
// 26:       true
// 27:     end
// 28:
// 29:     module Private
// 30:       INSTANCE = Untyped.new.freeze
// 31:     end
// 32:   end
// 33: end
