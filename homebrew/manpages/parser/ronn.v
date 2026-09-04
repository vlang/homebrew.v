module parser

import ruby

// Translated from Homebrew/brew `manpages/parser/ronn.rb`.
pub struct RonnElement {
pub:
	kind     string
	value    string
	location int
}

pub struct RonnParser {
pub:
	source        string
	block_parsers []string
	span_parsers  []string
pub mut:
	cursor   int
	elements []RonnElement
}

pub fn new_ronn_parser(source string, block_parsers []string, span_parsers []string) RonnParser {
	mut blocks := block_parsers.filter(it !in ['block_html', 'table'])
	mut spans := span_parsers.filter(it !in ['span_html', 'typographic_syms', 'variable'])
	spans << 'variable'
	return RonnParser{
		source: source
		block_parsers: blocks
		span_parsers: spans
	}
}

fn ronn_variable_character(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
		`_`,
		`-`,
		`|`,
	]
}

fn ronn_line_number(source string, cursor int) int {
	mut line := 1
	for index in 0 .. cursor {
		if source[index] == `\n` {
			line++
		}
	}
	return line
}

// parse_variable scans one ronn variable at the current cursor and appends the
// equivalent Kramdown element. The special <br> token also consumes one
// immediately following newline.
pub fn (mut parser RonnParser) parse_variable() !int {
	if parser.cursor >= parser.source.len || parser.source[parser.cursor] != `<` {
		return error('expected a ronn variable at byte ${parser.cursor}')
	}
	start := parser.cursor
	mut end := start + 1
	for end < parser.source.len && ronn_variable_character(parser.source[end]) {
		end++
	}
	if end == start + 1 || end >= parser.source.len || parser.source[end] != `>` {
		return error('invalid ronn variable at byte ${start}')
	}
	variable := parser.source[start + 1..end]
	location := ronn_line_number(parser.source, start)
	parser.cursor = end + 1
	if variable == 'br' {
		if parser.cursor < parser.source.len && parser.source[parser.cursor] == `\n` {
			parser.cursor++
		}
		parser.elements << RonnElement{
			kind: 'br'
			location: location
		}
	} else {
		parser.elements << RonnElement{
			kind: 'variable'
			value: variable
			location: location
		}
	}
	return location
}

pub fn ronn_parser_value(parser RonnParser) ruby.Value {
	mut element_values := []ruby.Value{}
	for element in parser.elements {
		element_values << ruby.structured_value('Kramdown::Element', element.value, {
			'kind':     element.kind
			'value':    element.value
			'location': element.location.str()
		})
	}
	return ruby.Value{
		type_name: 'Homebrew::Manpages::Parser::Ronn'
		repr: parser.source
		attributes: {
			'cursor': parser.cursor.str()
		}
		map_data: {
			'block_parsers': ruby.string_array_value(parser.block_parsers)
			'span_parsers':  ruby.string_array_value(parser.span_parsers)
			'elements':      ruby.array_value(element_values)
		}
	}
}

pub fn ronn_parser_from_value(value ruby.Value) !RonnParser {
	if value.type_name != 'Homebrew::Manpages::Parser::Ronn' {
		return error('expected Ronn parser, got ${value.type_name}')
	}
	mut elements := []RonnElement{}
	for element in (value.map_data['elements'] or { ruby.array_value([]) }).as_array()! {
		elements << RonnElement{
			kind: element.attribute('kind')!
			value: element.attribute('value') or { '' }
			location: (element.attribute('location') or { '1' }).int()
		}
	}
	return RonnParser{
		source: value.repr
		block_parsers: (value.map_data['block_parsers'] or { ruby.string_array_value([]) }).as_string_array()!
		span_parsers: (value.map_data['span_parsers'] or {
			ruby.string_array_value([
				'variable',
			])
		}).as_string_array()!
		cursor: (value.attribute('cursor') or { '0' }).int()
		elements: elements
	}
}
