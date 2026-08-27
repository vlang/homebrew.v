module dsl

import brew_runtime

// Translated from Homebrew/brew `cask/dsl/conflicts_with.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(**options)` at line 15.
pub fn ruby_conflicts_with_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `merge!(other)` at line 25.
pub fn ruby_conflicts_with_l25_d2_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge!', ...args)
}

// Ruby method `to_h` at line 31.
pub fn ruby_conflicts_with_l31_d3_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `to_json(generator)` at line 36.
pub fn ruby_conflicts_with_l36_d4_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_json', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5: require "extend/hash/keys"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class DSL
// 10:     # Class corresponding to the `conflicts_with` stanza.
// 11:     class ConflictsWith < SimpleDelegator
// 12:       VALID_KEYS = [:cask].freeze
// 13:
// 14:       sig { params(options: T.anything).void }
// 15:       def initialize(**options)
// 16:         options.assert_valid_keys(*VALID_KEYS)
// 17:
// 18:         conflicts = options.transform_values { |v| Set.new(Kernel.Array(v)) }
// 19:         conflicts.default = Set.new
// 20:
// 21:         super(conflicts)
// 22:       end
// 23:
// 24:       sig { params(other: ConflictsWith).returns(T.self_type) }
// 25:       def merge!(other)
// 26:         other.to_h.each { |key, values| __getobj__[key] |= Set.new(values) }
// 27:         self
// 28:       end
// 29:
// 30:       sig { returns(T::Hash[Symbol, T::Array[String]]) }
// 31:       def to_h
// 32:         __getobj__.transform_values(&:to_a)
// 33:       end
// 34:
// 35:       sig { params(generator: T.anything).returns(String) }
// 36:       def to_json(generator)
// 37:         to_h.to_json(generator)
// 38:       end
// 39:     end
// 40:   end
// 41: end
