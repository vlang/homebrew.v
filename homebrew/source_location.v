module homebrew

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
