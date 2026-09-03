module ast

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/ast/cask_header.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskHeader {
pub:
	method_source string
	begin_pos     int
	end_pos       int
	cask_token    string
	hash_source   string
	hash_begin    int
	hash_end      int
}

fn cask_header_expression_end(line string, begin_pos int) int {
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	mut cursor := begin_pos
	for cursor < line.len {
		character := line[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			depth++
		} else if character in [`)`, `]`, `}`] && depth > 0 {
			depth--
		} else if depth == 0 && line[cursor..].starts_with(' do') {
			return cursor
		} else if depth == 0 && character == `#` {
			return cursor
		}
		cursor++
	}
	return line.len
}

fn cask_header_quoted_end(source string, begin_pos int, limit int) ?int {
	if begin_pos >= limit || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut escaped := false
	mut cursor := begin_pos + 1
	for cursor < limit {
		if escaped {
			escaped = false
		} else if source[cursor] == `\\` {
			escaped = true
		} else if source[cursor] == quote {
			return cursor + 1
		}
		cursor++
	}
	return none
}

fn cask_header_decode_token(source string) string {
	if source.len < 2 {
		return ''
	}
	quote := source[0]
	mut decoded := []u8{}
	mut escaped := false
	for character in source[1..source.len - 1].bytes() {
		if escaped {
			if quote == `'` && character !in [`'`, `\\`] {
				decoded << `\\`
			}
			decoded << character
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else {
			decoded << character
		}
	}
	if escaped {
		decoded << `\\`
	}
	return decoded.bytestr()
}

pub fn parse_cask_header(source string) ?CaskHeader {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		indent := line.len - line.trim_left(' \t').len
		if line[indent..].starts_with('cask') {
			after_method := indent + 'cask'.len
			if after_method < line.len && line[after_method] !in [` `, `\t`, `(`] {
				return none
			}
			expression_end := cask_header_expression_end(line, after_method)
			mut argument := after_method
			for argument < expression_end && line[argument] in [` `, `\t`, `(`] {
				argument++
			}
			token_end := cask_header_quoted_end(line, argument, expression_end) or { return none }
			token_source := line[argument..token_end]
			mut extra := token_end
			for extra < expression_end && line[extra] in [` `, `\t`, `,`] {
				extra++
			}
			mut hash_end := expression_end
			for hash_end > extra && line[hash_end - 1].is_space() {
				hash_end--
			}
			hash_source := if extra < hash_end && (line[extra] == `{` || line[extra..hash_end].contains(':')) {
				line[extra..hash_end]
			} else {
				''
			}
			return CaskHeader{
				method_source: line[indent..expression_end].trim_right(' \t')
				begin_pos: line_start + indent
				end_pos: line_start + expression_end
				cask_token: cask_header_decode_token(token_source)
				hash_source: hash_source
				hash_begin: if hash_source == '' { 0 } else { line_start + extra }
				hash_end: if hash_source == '' { 0 } else { line_start + hash_end }
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn cask_header_value(header CaskHeader) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cask::AST::CaskHeader', header.cask_token, {
		'method_source': header.method_source
		'begin_pos':     header.begin_pos.str()
		'end_pos':       header.end_pos.str()
		'cask_token':    header.cask_token
		'hash_source':   header.hash_source
		'hash_begin':    header.hash_begin.str()
		'hash_end':      header.hash_end.str()
	})
}

fn cask_header_argument(args []brew_runtime.Value) ?CaskHeader {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return parse_cask_header(source)
}

// Ruby method `initialize(method_node)` at line 11.
pub fn ruby_cask_header_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	header := cask_header_argument(args) or {
		return brew_runtime.object_value('ArgumentError', 'expected a cask method node')
	}
	return cask_header_value(header)
}

// Ruby attr_reader `attr_reader :method_node` at line 16.
pub fn ruby_cask_header_l16_d2_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	header := cask_header_argument(args) or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.structured_value('RuboCop::AST::SendNode', header.method_source, {
		'source':    header.method_source
		'begin_pos': header.begin_pos.str()
		'end_pos':   header.end_pos.str()
	})
}

// Ruby method `source_range` at line 19.
pub fn ruby_cask_header_l19_d3_source_range(args ...brew_runtime.Value) brew_runtime.Value {
	header := cask_header_argument(args) or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.structured_value('Parser::Source::Range', header.method_source, {
		'begin_pos': header.begin_pos.str()
		'end_pos':   header.end_pos.str()
		'source':    header.method_source
	})
}

// Ruby method `cask_token` at line 24.
pub fn ruby_cask_header_l24_d4_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	header := cask_header_argument(args) or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.string_value(header.cask_token)
}

// Ruby method `hash_node` at line 29.
pub fn ruby_cask_header_l29_d5_hash_node(args ...brew_runtime.Value) brew_runtime.Value {
	header := cask_header_argument(args) or { return brew_runtime.object_value('NilClass', 'nil') }
	if header.hash_source == '' {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.structured_value('RuboCop::AST::HashNode', header.hash_source, {
		'source':    header.hash_source
		'begin_pos': header.hash_begin.str()
		'end_pos':   header.hash_end.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cask
// 6:     module AST
// 7:       # This class wraps the AST method node that represents the cask header. It
// 8:       # includes various helper methods to aid cops in their analysis.
// 9:       class CaskHeader
// 10:         sig { params(method_node: T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)).void }
// 11:         def initialize(method_node)
// 12:           @method_node = method_node
// 13:         end
// 14:
// 15:         sig { returns(T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)) }
// 16:         attr_reader :method_node
// 17:
// 18:         sig { returns(Parser::Source::Range) }
// 19:         def source_range
// 20:           @source_range ||= T.let(method_node.loc.expression, T.nilable(Parser::Source::Range))
// 21:         end
// 22:
// 23:         sig { returns(String) }
// 24:         def cask_token
// 25:           @cask_token ||= T.let(method_node.first_argument.str_content, T.nilable(String))
// 26:         end
// 27:
// 28:         sig { returns(T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)) }
// 29:         def hash_node
// 30:           @hash_node ||= T.let(method_node.each_child_node(:hash).first, T.nilable(RuboCop::AST::Node))
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
