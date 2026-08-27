module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/type_parameter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.cached_entry(name)` at line 9.
pub fn ruby_type_parameter_l9_d1_self_cached_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_entry', ...args)
}

// Ruby method `self.set_entry_for(name, type)` at line 13.
pub fn ruby_type_parameter_l13_d2_self_set_entry_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.set_entry_for', ...args)
}

// Ruby method `initialize(name)` at line 18.
pub fn ruby_type_parameter_l18_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 23.
pub fn ruby_type_parameter_l23_d4_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `self.make(name)` at line 27.
pub fn ruby_type_parameter_l27_d5_self_make(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.make', ...args)
}

// Ruby method `valid?(obj)` at line 34.
pub fn ruby_type_parameter_l34_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(type)` at line 38.
pub fn ruby_type_parameter_l38_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `name` at line 42.
pub fn ruby_type_parameter_l42_d8_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypeParameter < Base
// 6:     module Private
// 7:       @pool = {}
// 8:
// 9:       def self.cached_entry(name)
// 10:         @pool[name]
// 11:       end
// 12:
// 13:       def self.set_entry_for(name, type)
// 14:         @pool[name] = type
// 15:       end
// 16:     end
// 17:
// 18:     def initialize(name)
// 19:       raise ArgumentError.new("not a symbol: #{name}") unless name.is_a?(Symbol)
// 20:       @name = name
// 21:     end
// 22:
// 23:     def build_type
// 24:       nil
// 25:     end
// 26:
// 27:     def self.make(name)
// 28:       cached = Private.cached_entry(name)
// 29:       return cached if cached
// 30:
// 31:       Private.set_entry_for(name, new(name))
// 32:     end
// 33:
// 34:     def valid?(obj)
// 35:       true
// 36:     end
// 37:
// 38:     def subtype_of_single?(type)
// 39:       true
// 40:     end
// 41:
// 42:     def name
// 43:       "T.type_parameter(:#{@name})"
// 44:     end
// 45:   end
// 46: end
