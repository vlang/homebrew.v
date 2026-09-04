module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/self_type.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SelfType {}

pub fn new_self_type() SelfType {
	return SelfType{}
}

pub fn (_ SelfType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (_ SelfType) name() string {
	return 'T.self_type'
}

pub fn (_ SelfType) valid(_ ruby.Value) bool {
	return true
}

pub fn (_ SelfType) subtype_of_single(other ruby.Value) bool {
	return other.type_name == 'T::Types::SelfType'
}

fn self_type_value() ruby.Value {
	return ruby.object_value('T::Types::SelfType', 'T.self_type')
}

// Ruby method `initialize(); end` at line 9.
pub fn ruby_self_type_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `build_type` at line 11.
pub fn ruby_self_type_l11_d2_build_type(args ...ruby.Value) ruby.Value {
	return new_self_type().build_type()
}

// Ruby method `name` at line 16.
pub fn ruby_self_type_l16_d3_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(new_self_type().name())
}

// Ruby method `valid?(obj)` at line 21.
pub fn ruby_self_type_l21_d4_valid(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby method `subtype_of_single?(other)` at line 26.
pub fn ruby_self_type_l26_d5_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('SelfType#subtype_of_single? requires another type')
	}
	return ruby.bool_value(new_self_type().subtype_of_single(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Modeling self-types properly at runtime would require additional tracking,
// 6:   # so at runtime we permit all values and rely on the static checker.
// 7:   class SelfType < Base
// 8:
// 9:     def initialize(); end
// 10:
// 11:     def build_type
// 12:       nil
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def name
// 17:       "T.self_type"
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def valid?(obj)
// 22:       true
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     private def subtype_of_single?(other)
// 27:       case other
// 28:       when SelfType
// 29:         true
// 30:       else
// 31:         false
// 32:       end
// 33:     end
// 34:
// 35:     module Private
// 36:       INSTANCE = SelfType.new.freeze
// 37:     end
// 38:   end
// 39: end
