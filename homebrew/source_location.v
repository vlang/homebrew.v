module homebrew

import ruby

// Translated from Homebrew/brew `source_location.rb`.
// The original source is retained below until every stub has a typed V body.

// SourceLocation translates a line and optional column in source code.
pub struct SourceLocation {
pub:
	line       int
	has_column bool
	column     int
}

// new_source_location translates SourceLocation#initialize without a column.
pub fn new_source_location(line int) SourceLocation {
	return SourceLocation{
		line: line
	}
}

// new_source_location_with_column translates SourceLocation#initialize with a
// concrete column.
pub fn new_source_location_with_column(line int, column int) SourceLocation {
	return SourceLocation{
		line:       line
		has_column: true
		column:     column
	}
}

// str translates SourceLocation#to_s.
pub fn (location SourceLocation) str() string {
	return if location.has_column {
		'${location.line}:${location.column}'
	} else {
		location.line.str()
	}
}

fn source_location_boundary_value(location SourceLocation) ruby.Value {
	return ruby.structured_value('SourceLocation', location.str(), {
		'line':       location.line.str()
		'has_column': location.has_column.str()
		'column':     location.column.str()
	})
}

fn source_location_from_boundary(value ruby.Value) SourceLocation {
	if value.type_name != 'SourceLocation' {
		panic('expected SourceLocation, got ${value.type_name}')
	}
	line := (value.attribute('line') or { panic(err) }).int()
	has_column := (value.attribute('has_column') or { panic(err) }) == 'true'
	column := (value.attribute('column') or { panic(err) }).int()
	return SourceLocation{
		line:       line
		has_column: has_column
		column:     column
	}
}

// Ruby attr_reader `attr_reader :line` at line 8.
pub fn ruby_source_location_l8_d1_line(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SourceLocation#line requires a receiver')
	}
	return ruby.int_value(source_location_from_boundary(args[0]).line)
}

// Ruby attr_reader `attr_reader :column` at line 11.
pub fn ruby_source_location_l11_d2_column(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SourceLocation#column requires a receiver')
	}
	location := source_location_from_boundary(args[0])
	return if location.has_column {
		ruby.int_value(location.column)
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby method `initialize(line, column = nil)` at line 14.
pub fn ruby_source_location_l14_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SourceLocation#initialize requires a line')
	}
	line := args[0].as_int() or { panic(err) }
	location := if args.len > 1 && args[1].type_name != 'NilClass' {
		column := args[1].as_int() or { panic(err) }
		new_source_location_with_column(int(line), int(column))
	} else {
		new_source_location(int(line))
	}
	return source_location_boundary_value(location)
}

// Ruby method `to_s` at line 20.
pub fn ruby_source_location_l20_d4_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SourceLocation#to_s requires a receiver')
	}
	return ruby.string_value(source_location_from_boundary(args[0]).str())
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
