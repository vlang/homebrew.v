module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/anything.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AnythingType {}

pub fn new_anything_type() AnythingType {
	return AnythingType{}
}

pub fn (_ AnythingType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (_ AnythingType) name() string {
	return 'T.anything'
}

pub fn (_ AnythingType) valid(_ ruby.Value) bool {
	return true
}

pub fn (_ AnythingType) subtype_of_single(other ruby.Value) bool {
	return other.type_name == 'T::Types::Anything'
}

fn anything_type_value() ruby.Value {
	return ruby.object_value('T::Types::Anything', 'T.anything')
}

// Ruby method `initialize; end` at line 7.
pub fn ruby_anything_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `build_type` at line 9.
pub fn ruby_anything_l9_d2_build_type(args ...ruby.Value) ruby.Value {
	return new_anything_type().build_type()
}

// Ruby method `name` at line 14.
pub fn ruby_anything_l14_d3_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(new_anything_type().name())
}

// Ruby method `valid?(obj)` at line 19.
pub fn ruby_anything_l19_d4_valid(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby method `subtype_of_single?(other)` at line 24.
pub fn ruby_anything_l24_d5_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Anything#subtype_of_single? requires another type')
	}
	return ruby.bool_value(new_anything_type().subtype_of_single(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # The top type
// 6:   class Anything < Base
// 7:     def initialize; end
// 8:
// 9:     def build_type
// 10:       nil
// 11:     end
// 12:
// 13:     # overrides Base
// 14:     def name
// 15:       "T.anything"
// 16:     end
// 17:
// 18:     # overrides Base
// 19:     def valid?(obj)
// 20:       true
// 21:     end
// 22:
// 23:     # overrides Base
// 24:     private def subtype_of_single?(other)
// 25:       case other
// 26:       when T::Types::Anything then true
// 27:       else false
// 28:       end
// 29:     end
// 30:
// 31:     module Private
// 32:       INSTANCE = Anything.new.freeze
// 33:     end
// 34:   end
// 35: end
