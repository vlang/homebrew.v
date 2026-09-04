module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/noreturn.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct NoReturnType {}

pub fn new_no_return_type() NoReturnType {
	return NoReturnType{}
}

pub fn (_ NoReturnType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (_ NoReturnType) name() string {
	return 'T.noreturn'
}

pub fn (_ NoReturnType) valid(_ ruby.Value) bool {
	return false
}

pub fn (_ NoReturnType) subtype_of_single(_ ruby.Value) bool {
	return true
}

fn no_return_type_value() ruby.Value {
	return ruby.object_value('T::Types::NoReturn', 'T.noreturn')
}

// Ruby method `initialize; end` at line 7.
pub fn ruby_noreturn_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `build_type` at line 9.
pub fn ruby_noreturn_l9_d2_build_type(args ...ruby.Value) ruby.Value {
	return new_no_return_type().build_type()
}

// Ruby method `name` at line 14.
pub fn ruby_noreturn_l14_d3_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(new_no_return_type().name())
}

// Ruby method `valid?(obj)` at line 19.
pub fn ruby_noreturn_l19_d4_valid(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
}

// Ruby method `subtype_of_single?(other)` at line 24.
pub fn ruby_noreturn_l24_d5_subtype_of_single(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # The bottom type
// 6:   class NoReturn < Base
// 7:     def initialize; end
// 8:
// 9:     def build_type
// 10:       nil
// 11:     end
// 12:
// 13:     # overrides Base
// 14:     def name
// 15:       "T.noreturn"
// 16:     end
// 17:
// 18:     # overrides Base
// 19:     def valid?(obj)
// 20:       false
// 21:     end
// 22:
// 23:     # overrides Base
// 24:     private def subtype_of_single?(other)
// 25:       true
// 26:     end
// 27:
// 28:     module Private
// 29:       INSTANCE = NoReturn.new.freeze
// 30:     end
// 31:   end
// 32: end
