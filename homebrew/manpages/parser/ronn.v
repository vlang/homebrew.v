module parser

import ruby

// Translated from Homebrew/brew `manpages/parser/ronn.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(source, options)` at line 12.
pub fn ruby_ronn_l12_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Ronn#initialize requires source')
	}
	mut blocks := ['block_html', 'table']
	mut spans := ['span_html', 'typographic_syms']
	if args.len > 1 && args[1].type_name == 'Hash' {
		options := args[1].map_data.clone()
		if value := options['block_parsers'] {
			blocks = value.as_string_array() or { blocks }
		}
		if value := options['span_parsers'] {
			spans = value.as_string_array() or { spans }
		}
	}
	return ronn_parser_value(new_ronn_parser(args[0].as_string(), blocks, spans))
}

// Ruby method `parse_variable` at line 30.
pub fn ruby_ronn_l30_d2_parse_variable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Ronn#parse_variable requires a receiver')
	}
	mut parser := ronn_parser_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	line := parser.parse_variable() or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.Value{
		type_name: 'RonnParseResult'
		repr: line.str()
		int_data: i64(line)
		map_data: {
			'parser': ronn_parser_value(parser)
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "kramdown/parser/kramdown"
// 5:
// 6: module Homebrew
// 7:   module Manpages
// 8:     module Parser
// 9:       # Kramdown parser with compatibility for ronn variable syntax.
// 10:       class Ronn < ::Kramdown::Parser::Kramdown
// 11:         sig { params(source: String, options: T::Hash[Symbol, T.untyped]).void }
// 12:         def initialize(source, options)
// 13:           super
// 14:           @block_parsers = T.let(@block_parsers, T::Array[Symbol])
// 15:           @span_parsers = T.let(@span_parsers, T::Array[Symbol])
// 16:           # Disable HTML parsing and replace it with variable parsing.
// 17:           # Also disable table parsing too because it depends on HTML parsing
// 18:           # and existing command descriptions may get misinterpreted as tables.
// 19:           # Typographic symbols is disabled as it detects `--` as en-dash.
// 20:           @block_parsers.delete(:block_html)
// 21:           @block_parsers.delete(:table)
// 22:           @span_parsers.delete(:span_html)
// 23:           @span_parsers.delete(:typographic_syms)
// 24:           @span_parsers << :variable
// 25:         end
// 26:
// 27:         # HTML-like tags denote variables instead, except <br>.
// 28:         VARIABLE_REGEX = /<([\w\-|]+)>/
// 29:         sig { returns(T.nilable(Integer)) }
// 30:         def parse_variable
// 31:           @src = T.let(@src, T.nilable(Kramdown::Utils::StringScanner))
// 32:           raise "Ronn src is nil" if @src.nil?
// 33:
// 34:           start_line_number = @src.current_line_number
// 35:           @src.scan(VARIABLE_REGEX)
// 36:           variable = @src[1]
// 37:           @tree = T.let(@tree, T.nilable(Kramdown::Element))
// 38:           raise "Ronn tree is nil" if @tree.nil?
// 39:
// 40:           if variable == "br"
// 41:             @src.skip(/\n/)
// 42:             @tree.children << Element.new(:br, nil, nil, location: start_line_number)
// 43:           else
// 44:             @tree.children << Element.new(:variable, variable, nil, location: start_line_number)
// 45:           end
// 46:           start_line_number
// 47:         end
// 48:         define_parser(:variable, VARIABLE_REGEX, "<")
// 49:       end
// 50:     end
// 51:   end
// 52: end
