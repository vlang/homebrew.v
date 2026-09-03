module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/string_holder.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct StringHolder {
pub:
	text string
}

pub fn new_string_holder(value string) &StringHolder {
	return &StringHolder{
		text: value
	}
}

pub fn (_ &StringHolder) build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn (holder &StringHolder) name() string {
	return holder.text
}

pub fn (_ &StringHolder) valid(_ brew_runtime.Value) bool {
	return false
}

pub fn (_ &StringHolder) subtype_of_single(_ brew_runtime.Value) bool {
	return false
}

fn string_holder_value(holder &StringHolder) brew_runtime.Value {
	return brew_runtime.structured_value('T::Private::Types::StringHolder', holder.text, {
		'string_holder_address': u64(voidptr(holder)).str()
	})
}

fn string_holder_from_args(args []brew_runtime.Value) &StringHolder {
	if args.len == 0 {
		panic('StringHolder method requires a receiver')
	}
	address := args[0].attribute('string_holder_address') or {
		panic('invalid StringHolder receiver')
	}
	return unsafe { &StringHolder(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :string` at line 6.
pub fn ruby_string_holder_l6_d1_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(string_holder_from_args(args).text)
}

// Ruby method `initialize(string)` at line 8.
pub fn ruby_string_holder_l8_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('StringHolder#initialize requires a string')
	}
	return string_holder_value(new_string_holder(args[0].as_string()))
}

// Ruby method `build_type` at line 12.
pub fn ruby_string_holder_l12_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return string_holder_from_args(args).build_type()
}

// Ruby method `name` at line 17.
pub fn ruby_string_holder_l17_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(string_holder_from_args(args).name())
}

// Ruby method `valid?(obj)` at line 22.
pub fn ruby_string_holder_l22_d5_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StringHolder#valid? requires an object')
	}
	return brew_runtime.bool_value(string_holder_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 27.
pub fn ruby_string_holder_l27_d6_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StringHolder#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(string_holder_from_args(args).subtype_of_single(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Holds a string. Useful for showing type aliases in error messages
// 5: class T::Private::Types::StringHolder < T::Types::Base
// 6:   attr_reader :string
// 7:
// 8:   def initialize(string)
// 9:     @string = string
// 10:   end
// 11:
// 12:   def build_type
// 13:     nil
// 14:   end
// 15:
// 16:   # overrides Base
// 17:   def name
// 18:     string
// 19:   end
// 20:
// 21:   # overrides Base
// 22:   def valid?(obj)
// 23:     false
// 24:   end
// 25:
// 26:   # overrides Base
// 27:   private def subtype_of_single?(other)
// 28:     false
// 29:   end
// 30: end
