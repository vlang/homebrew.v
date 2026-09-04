module homebrew

import ruby

// Translated from Homebrew/brew `source_location.rb`.

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
		line: line
		has_column: true
		column: column
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
		line: line
		has_column: has_column
		column: column
	}
}
