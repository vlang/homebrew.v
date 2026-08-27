module homebrew

import brew_runtime

// Translated from Homebrew/brew `source_location.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :line` at line 8.
pub fn ruby_source_location_l8_d1_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('line', ...args)
}

// Ruby attr_reader `attr_reader :column` at line 11.
pub fn ruby_source_location_l11_d2_column(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('column', ...args)
}

// Ruby method `initialize(line, column = nil)` at line 14.
pub fn ruby_source_location_l14_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 20.
pub fn ruby_source_location_l20_d4_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # A location in source code.
// 6:   class SourceLocation
// 7:     sig { returns(Integer) }
// 8:     attr_reader :line
// 9:
// 10:     sig { returns(T.nilable(Integer)) }
// 11:     attr_reader :column
// 12:
// 13:     sig { params(line: Integer, column: T.nilable(Integer)).void }
// 14:     def initialize(line, column = nil)
// 15:       @line = line
// 16:       @column = column
// 17:     end
// 18:
// 19:     sig { returns(String) }
// 20:     def to_s
// 21:       "#{line}#{column&.to_s&.prepend(":")}"
// 22:     end
// 23:   end
// 24: end
