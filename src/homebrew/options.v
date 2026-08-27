module homebrew

import brew_runtime

// Translated from Homebrew/brew `options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :name` at line 7.
pub fn ruby_options_l7_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :description, :flag` at line 10.
pub fn ruby_options_l10_d2_description(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('description', ...args)
}

// Ruby attr_reader `attr_reader :description, :flag` at line 10.
pub fn ruby_options_l10_d3_flag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('flag', ...args)
}

// Ruby method `initialize(name, description = "")` at line 13.
pub fn ruby_options_l13_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s = flag` at line 20.
pub fn ruby_options_l20_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `<=>(other)` at line 23.
pub fn ruby_options_l23_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `==(other)` at line 31.
pub fn ruby_options_l31_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 39.
pub fn ruby_options_l39_d8_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `hash` at line 42.
pub fn ruby_options_l42_d9_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash', ...args)
}

// Ruby method `inspect` at line 47.
pub fn ruby_options_l47_d10_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A formula option.
// 5: class Option
// 6:   sig { returns(String) }
// 7:   attr_reader :name
// 8:
// 9:   sig { returns(String) }
// 10:   attr_reader :description, :flag
// 11:
// 12:   sig { params(name: String, description: String).void }
// 13:   def initialize(name, description = "")
// 14:     @name = name
// 15:     @flag = T.let("--#{name}", String)
// 16:     @description = description
// 17:   end
// 18:
// 19:   sig { returns(String) }
// 20:   def to_s = flag
// 21:
// 22:   sig { params(other: T.anything).returns(T.nilable(Integer)) }
// 23:   def <=>(other)
// 24:     case other
// 25:     when Option
// 26:       name <=> other.name
// 27:     end
// 28:   end
// 29:
// 30:   sig { params(other: T.anything).returns(T::Boolean) }
// 31:   def ==(other)
// 32:     case other
// 33:     when Option
// 34:       instance_of?(other.class) && name == other.name
// 35:     else
// 36:       false
// 37:     end
// 38:   end
// 39:   alias eql? ==
// 40:
// 41:   sig { returns(Integer) }
// 42:   def hash
// 43:     name.hash
// 44:   end
// 45:
// 46:   sig { returns(String) }
// 47:   def inspect
// 48:     "#<#{self.class.name}: #{flag.inspect}>"
// 49:   end
// 50: end
// 51: require "options/deprecated_option"
// 52: require "options/options"
