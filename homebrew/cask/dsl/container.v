module dsl

import brew_runtime

// Translated from Homebrew/brew `cask/dsl/container.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :nested` at line 11.
pub fn ruby_container_l11_d1_nested(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nested', ...args)
}

// Ruby attr_accessor `attr_accessor :nested` at line 11.
pub fn ruby_container_l11_d2_nested(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nested=', ...args)
}

// Ruby attr_accessor `attr_accessor :type` at line 14.
pub fn ruby_container_l14_d3_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby attr_accessor `attr_accessor :type` at line 14.
pub fn ruby_container_l14_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type=', ...args)
}

// Ruby method `initialize(nested: nil, type: nil)` at line 17.
pub fn ruby_container_l17_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `pairs` at line 28.
pub fn ruby_container_l28_d6_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pairs', ...args)
}

// Ruby method `to_yaml` at line 33.
pub fn ruby_container_l33_d7_to_yaml(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_yaml', ...args)
}

// Ruby method `to_s = pairs.inspect` at line 38.
pub fn ruby_container_l38_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "unpack_strategy"
// 5:
// 6: module Cask
// 7:   class DSL
// 8:     # Class corresponding to the `container` stanza.
// 9:     class Container
// 10:       sig { returns(T.nilable(String)) }
// 11:       attr_accessor :nested
// 12:
// 13:       sig { returns(T.nilable(Symbol)) }
// 14:       attr_accessor :type
// 15:
// 16:       sig { params(nested: T.nilable(String), type: T.nilable(Symbol)).void }
// 17:       def initialize(nested: nil, type: nil)
// 18:         @nested = nested
// 19:         @type = type
// 20:
// 21:         return if type.nil?
// 22:         return unless UnpackStrategy.from_type(type).nil?
// 23:
// 24:         raise "invalid container type: #{type.inspect}"
// 25:       end
// 26:
// 27:       sig { returns(T::Hash[Symbol, T.nilable(T.any(String, Symbol))]) }
// 28:       def pairs
// 29:         instance_variables.to_h { |ivar| [ivar[1..].to_sym, instance_variable_get(ivar)] }.compact
// 30:       end
// 31:
// 32:       sig { returns(String) }
// 33:       def to_yaml
// 34:         pairs.to_yaml
// 35:       end
// 36:
// 37:       sig { returns(String) }
// 38:       def to_s = pairs.inspect
// 39:     end
// 40:   end
// 41: end
