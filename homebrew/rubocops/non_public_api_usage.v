module rubocops

import ruby
import homebrew.rubocops.@shared as api_annotations
import os

// Translated from Homebrew/brew `rubocops/non_public_api_usage.rb`.
// The original source is retained below until every stub has a typed V body.
pub const non_public_api_internal_message = 'Do not use `%s` in official tap formulae; it is an internal API (`@api internal`).'
pub const non_public_api_private_message = 'Do not use `%s` in official tap formulae; it is a private API (`@api private`).'

pub struct NonPublicApiCall {
pub:
	method    string
	receiver  string
	begin_pos int
	end_pos   int
	line      int
	column    int
}

pub struct NonPublicApiUsageOffense {
pub:
	method    string
	receiver  string
	begin_pos int
	end_pos   int
	line      int
	column    int
	message   string
}

struct NonPublicApiLine {
	start       int
	end         int
	newline_end int
	indent      int
	text        string
}

struct NonPublicApiSpan {
	found     bool
	begin_pos int
	end_pos   int
}

struct NonPublicApiToken {
	text      string
	begin_pos int
	end_pos   int
	line      int
	column    int
}

struct NonPublicApiMethodScope {
	begin_pos  int
	body_begin int
	end_pos    int
	parameters []string
}

struct NonPublicApiBlockScope {
	header_begin int
	body_begin   int
	end_pos      int
	parameters   []string
}

fn non_public_api_lines(source string) []NonPublicApiLine {
	mut lines := []NonPublicApiLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && text[indent] in [` `, `\t`] {
			indent++
		}
		lines << NonPublicApiLine{
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			indent: indent
			text: text
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return lines
}

fn non_public_api_code(line string) string {
	mut quote := u8(0)
	mut escaped := false
	for index, character in line.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
		} else if character == `#` {
			return line[..index].trim_right(' \t')
		}
	}
	return line.trim_right(' \t')
}

fn non_public_api_formula_body(source string, lines []NonPublicApiLine) NonPublicApiSpan {
	for class_index, line in lines {
		code := non_public_api_code(line.text).trim_space()
		if !code.starts_with('class ') || (!code.contains('< Formula') && !code.contains('< ::Formula')) {
			continue
		}
		if first_separator := code.index(';') {
			if code.ends_with('; end') || code.ends_with(';end') {
				last_separator := code.last_index(';') or { first_separator }
				line_offset := line.text.index(code) or { line.indent }
				return NonPublicApiSpan{
					found: true
					begin_pos: line.start + line_offset + first_separator + 1
					end_pos: line.start + line_offset + last_separator
				}
			}
		}
		for closing_index in class_index + 1 .. lines.len {
			closing := lines[closing_index]
			if closing.indent == line.indent && non_public_api_code(closing.text).trim_space() == 'end' {
				return NonPublicApiSpan{
					found: true
					begin_pos: line.newline_end
					end_pos: closing.start
				}
			}
		}
		return NonPublicApiSpan{}
	}
	return NonPublicApiSpan{
		found: source.trim_space() != ''
		begin_pos: 0
		end_pos: source.len
	}
}

fn non_public_api_line_and_column(source string, position int) (int, int) {
	limit := if position < source.len { position } else { source.len }
	mut line := 1
	mut line_start := 0
	for index, character in source[..limit].bytes() {
		if character == `\n` {
			line++
			line_start = index + 1
		}
	}
	return line, limit - line_start
}

fn non_public_api_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn non_public_api_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn non_public_api_skip_quoted(source string, start int, limit int) int {
	quote := source[start]
	mut position := start + 1
	mut escaped := false
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return position + 1
		}
		position++
	}
	return limit
}

fn non_public_api_paired_delimiter(character u8) u8 {
	return match character {
		`(` { `)` }
		`[` { `]` }
		`{` { `}` }
		`<` { `>` }
		else { character }
	}
}

fn non_public_api_skip_percent_literal(source string, start int, limit int) ?int {
	if start + 1 >= limit || source[start] != `%` {
		return none
	}
	mut delimiter_position := start + 1
	if source[delimiter_position] in [`q`, `Q`, `r`, `w`, `W`, `x`, `i`, `I`, `s`] {
		delimiter_position++
	}
	if delimiter_position >= limit || source[delimiter_position].is_alnum() || source[delimiter_position] == `_` || source[delimiter_position].is_space() {
		return none
	}
	open := source[delimiter_position]
	close := non_public_api_paired_delimiter(open)
	paired := close != open
	mut depth := 1
	mut escaped := false
	mut position := delimiter_position + 1
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if paired && character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return position + 1
			}
		}
		position++
	}
	return limit
}

fn non_public_api_regex_start(tokens []NonPublicApiToken) bool {
	if tokens.len == 0 {
		return true
	}
	previous := tokens.last().text
	return previous in ['=', '(', '[', '{', ',', ';', '!', '&&', '||', 'and', 'or', 'not', 'return',
		'yield', 'when', 'then', 'if', 'elsif', 'unless', '=~', '!~', 'puts', 'print', 'raise']
}

fn non_public_api_skip_regex(source string, start int, limit int) int {
	mut position := start + 1
	mut escaped := false
	mut in_class := false
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == `[` {
			in_class = true
		} else if character == `]` {
			in_class = false
		} else if character == `/` && !in_class {
			position++
			for position < limit && source[position].is_letter() {
				position++
			}
			return position
		} else if character == `\n` {
			return start + 1
		}
		position++
	}
	return start + 1
}

fn non_public_api_heredoc_end(source string, start int, limit int) ?int {
	if start + 2 >= limit || source[start..start + 2] != '<<' {
		return none
	}
	mut position := start + 2
	if position < limit && source[position] in [`-`, `~`] {
		position++
	}
	mut quote := u8(0)
	if position < limit && source[position] in [`'`, `\"`, 96] {
		quote = source[position]
		position++
	}
	marker_begin := position
	for position < limit && non_public_api_identifier_byte(source[position]) {
		position++
	}
	if position == marker_begin {
		return none
	}
	marker := source[marker_begin..position]
	if quote != 0 {
		if position >= limit || source[position] != quote {
			return none
		}
		position++
	}
	line_end := source.index_after('\n', position) or { return limit }
	mut line_start := line_end + 1
	for line_start <= limit {
		newline := source.index_after('\n', line_start) or { limit }
		end := if newline < limit { newline } else { limit }
		if source[line_start..end].trim_space() == marker {
			return if newline < limit { newline + 1 } else { newline }
		}
		if newline >= limit {
			break
		}
		line_start = newline + 1
	}
	return limit
}

fn non_public_api_tokens(source string, start int, limit int) []NonPublicApiToken {
	mut tokens := []NonPublicApiToken{}
	mut position := start
	for position < limit {
		character := source[position]
		if character.is_space() {
			position++
			continue
		}
		if character == `#` {
			position = source.index_after('\n', position) or { limit }
			continue
		}
		if character in [`'`, `\"`, 96] {
			position = non_public_api_skip_quoted(source, position, limit)
			continue
		}
		if character == `%` {
			if end := non_public_api_skip_percent_literal(source, position, limit) {
				position = end
				continue
			}
		}
		if character == `<` && position + 1 < limit && source[position + 1] == `<` {
			if end := non_public_api_heredoc_end(source, position, limit) {
				position = end
				continue
			}
		}
		if character == `/` && non_public_api_regex_start(tokens) {
			end := non_public_api_skip_regex(source, position, limit)
			if end > position + 1 {
				position = end
				continue
			}
		}
		begin := position
		if non_public_api_identifier_start(character) {
			position++
			for position < limit && non_public_api_identifier_byte(source[position]) {
				position++
			}
			if position < limit && source[position] in [`!`, `?`] {
				position++
			}
		} else {
			position++
			for operator in ['&&=', '||=', '...', '&.', '::', '=>', '==', '!=', '<=', '>=', '=~',
				'!~', '+=', '-=', '*=', '/=', '%=', '&&', '||', '<<', '>>', '**'] {
				if begin + operator.len <= limit && source[begin..begin + operator.len] == operator {
					position = begin + operator.len
					break
				}
			}
		}
		line, column := non_public_api_line_and_column(source, begin)
		tokens << NonPublicApiToken{
			text: source[begin..position]
			begin_pos: begin
			end_pos: position
			line: line
			column: column
		}
	}
	return tokens
}

fn non_public_api_parameter_names(header string) []string {
	mut parameters := []string{}
	mut position := 0
	for position < header.len {
		if !non_public_api_identifier_start(header[position]) {
			position++
			continue
		}
		begin := position
		position++
		for position < header.len && non_public_api_identifier_byte(header[position]) {
			position++
		}
		name := header[begin..position]
		if name !in ['def', 'self', 'nil', 'true', 'false'] && name !in parameters {
			parameters << name
		}
	}
	return parameters
}

fn non_public_api_method_scopes(lines []NonPublicApiLine, body NonPublicApiSpan) []NonPublicApiMethodScope {
	mut scopes := []NonPublicApiMethodScope{}
	for method_index, line in lines {
		if line.start < body.begin_pos || line.start >= body.end_pos {
			continue
		}
		code := non_public_api_code(line.text).trim_space()
		if !code.starts_with('def ') {
			continue
		}
		declaration := code[4..]
		mut name_end := 0
		for name_end < declaration.len && (non_public_api_identifier_byte(declaration[name_end]) || declaration[name_end] in [
			`!`,
			`?`,
			`.`,
			`=`,
		]) {
			name_end++
		}
		parameters := non_public_api_parameter_names(if name_end < declaration.len {
			declaration[name_end..]
		} else {
			''
		})
		if first_separator := code.index(';') {
			if code.ends_with('; end') || code.ends_with(';end') {
				last_separator := code.last_index(';') or { first_separator }
				line_offset := line.text.index(code) or { line.indent }
				scopes << NonPublicApiMethodScope{
					begin_pos: line.start + line_offset
					body_begin: line.start + line_offset + first_separator + 1
					end_pos: line.start + line_offset + last_separator
					parameters: parameters
				}
				continue
			}
		}
		for closing_index in method_index + 1 .. lines.len {
			closing := lines[closing_index]
			if closing.start >= body.end_pos {
				break
			}
			if closing.indent == line.indent && non_public_api_code(closing.text).trim_space() == 'end' {
				scopes << NonPublicApiMethodScope{
					begin_pos: line.start
					body_begin: line.newline_end
					end_pos: closing.start
					parameters: parameters
				}
				break
			}
		}
	}
	return scopes
}

fn non_public_api_block_scopes(lines []NonPublicApiLine, body NonPublicApiSpan) []NonPublicApiBlockScope {
	mut scopes := []NonPublicApiBlockScope{}
	for block_index, line in lines {
		if line.start < body.begin_pos || line.start >= body.end_pos {
			continue
		}
		code := non_public_api_code(line.text)
		pipe_begin := code.index('|') or { continue }
		pipe_end_relative := code[pipe_begin + 1..].index('|') or { continue }
		pipe_end := pipe_begin + 1 + pipe_end_relative
		prefix := code[..pipe_begin]
		if !prefix.contains(' do ') && !prefix.trim_space().ends_with('do') && !prefix.contains('{') {
			continue
		}
		parameters := non_public_api_parameter_names(code[pipe_begin + 1..pipe_end])
		if parameters.len == 0 {
			continue
		}
		line_offset := line.text.index(code) or { 0 }
		header_begin := line.start + line_offset + pipe_begin
		begin_pos := line.start + line_offset + pipe_end + 1
		if prefix.contains('{') {
			if brace_end := code.last_index('}') {
				scopes << NonPublicApiBlockScope{
					header_begin: header_begin
					body_begin: begin_pos
					end_pos: line.start + line_offset + brace_end
					parameters: parameters
				}
				continue
			}
		}
		for closing_index in block_index + 1 .. lines.len {
			closing := lines[closing_index]
			if closing.start >= body.end_pos {
				break
			}
			if closing.indent == line.indent && non_public_api_code(closing.text).trim_space() == 'end' {
				scopes << NonPublicApiBlockScope{
					header_begin: header_begin
					body_begin: begin_pos
					end_pos: closing.start
					parameters: parameters
				}
				break
			}
		}
	}
	return scopes
}

fn non_public_api_method_scope_at(scopes []NonPublicApiMethodScope, position int) int {
	mut selected := -1
	mut selected_begin := -1
	for index, scope in scopes {
		if position >= scope.body_begin && position < scope.end_pos && scope.begin_pos > selected_begin {
			selected = index
			selected_begin = scope.begin_pos
		}
	}
	return selected
}

fn non_public_api_in_method_header(scopes []NonPublicApiMethodScope, position int) bool {
	return scopes.any(position >= it.begin_pos && position < it.body_begin)
}

fn non_public_api_in_block_parameters(scopes []NonPublicApiBlockScope, position int) bool {
	return scopes.any(position >= it.header_begin && position < it.body_begin)
}

fn non_public_api_assignment_operator(text string) bool {
	return text in ['=', '&&=', '||=', '+=', '-=', '*=', '/=', '%=']
}

fn non_public_api_local_reference(tokens []NonPublicApiToken, index int, method_scopes []NonPublicApiMethodScope,
	block_scopes []NonPublicApiBlockScope, body NonPublicApiSpan) bool {
	token := tokens[index]
	if index + 1 < tokens.len && tokens[index + 1].text == '(' {
		return false
	}
	scope_index := non_public_api_method_scope_at(method_scopes, token.begin_pos)
	scope_begin := if scope_index >= 0 {
		method_scopes[scope_index].body_begin
	} else {
		body.begin_pos
	}
	if scope_index >= 0 && token.text in method_scopes[scope_index].parameters {
		return true
	}
	for scope in block_scopes {
		if token.begin_pos >= scope.body_begin && token.begin_pos < scope.end_pos && token.text in scope.parameters {
			return true
		}
	}
	for prior_index in 0 .. index + 1 {
		prior := tokens[prior_index]
		if prior.begin_pos < scope_begin || prior.text != token.text || non_public_api_method_scope_at(method_scopes, prior.begin_pos) != scope_index {
			continue
		}
		if prior_index + 1 < tokens.len && non_public_api_assignment_operator(tokens[prior_index + 1].text) {
			if prior_index == 0 || tokens[prior_index - 1].text !in ['.', '&.', '::', '@', '@@',
				'\$', ':'] {
				return true
			}
		}
		if prior_index > 0 && tokens[prior_index - 1].text == '=>' {
			return true
		}
		if prior_index > 0 && tokens[prior_index - 1].text == 'for' {
			return true
		}
	}
	return false
}

fn non_public_api_matching_parenthesis(tokens []NonPublicApiToken, open_index int) ?int {
	mut depth := 0
	for index in open_index .. tokens.len {
		if tokens[index].text == '(' {
			depth++
		} else if tokens[index].text == ')' {
			depth--
			if depth == 0 {
				return index
			}
		}
	}
	return none
}

pub fn find_non_public_api_method_calls(source string, methods []string) []NonPublicApiCall {
	lines := non_public_api_lines(source)
	body := non_public_api_formula_body(source, lines)
	if !body.found || body.end_pos <= body.begin_pos || methods.len == 0 {
		return []
	}
	tokens := non_public_api_tokens(source, body.begin_pos, body.end_pos)
	method_scopes := non_public_api_method_scopes(lines, body)
	block_scopes := non_public_api_block_scopes(lines, body)
	mut calls := []NonPublicApiCall{}
	for method in methods {
		for index, token in tokens {
			if token.text != method {
				continue
			}
			if non_public_api_in_method_header(method_scopes, token.begin_pos) || non_public_api_in_block_parameters(block_scopes, token.begin_pos) {
				continue
			}
			previous := if index > 0 { tokens[index - 1].text } else { '' }
			next := if index + 1 < tokens.len { tokens[index + 1].text } else { '' }
			if previous in ['def', 'alias', 'undef', '@', '@@', '\$', ':', '&.'] || next == ':' || non_public_api_assignment_operator(next) {
				continue
			}
			mut receiver := ''
			mut begin_pos := token.begin_pos
			if previous in ['.', '::'] {
				if index < 2 || tokens[index - 2].text != 'self' {
					continue
				}
				receiver = 'self'
				begin_pos = tokens[index - 2].begin_pos
			} else if non_public_api_local_reference(tokens, index, method_scopes, block_scopes, body) {
				continue
			}
			mut end_pos := token.end_pos
			if index + 1 < tokens.len && tokens[index + 1].text == '(' {
				if closing_index := non_public_api_matching_parenthesis(tokens, index + 1) {
					end_pos = tokens[closing_index].end_pos
				}
			}
			line, column := non_public_api_line_and_column(source, begin_pos)
			calls << NonPublicApiCall{
				method: method
				receiver: receiver
				begin_pos: begin_pos
				end_pos: end_pos
				line: line
				column: column
			}
		}
	}
	return calls
}

pub fn load_non_public_api_methods_for_level(homebrew_dir string, level string) []string {
	mut methods := []string{}
	for source_file in api_annotations.api_source_files {
		for method in api_annotations.methods_with_api_level(os.join_path(homebrew_dir, source_file), level) {
			if method !in methods {
				methods << method
			}
		}
	}
	return methods
}

pub fn non_public_api_internal_methods(homebrew_dir string) []string {
	return load_non_public_api_methods_for_level(homebrew_dir, 'internal')
}

pub fn non_public_api_private_methods(homebrew_dir string) []string {
	return load_non_public_api_methods_for_level(homebrew_dir, 'private')
}

pub fn check_non_public_api_method_calls(source string, methods []string, message_template string) []NonPublicApiUsageOffense {
	return find_non_public_api_method_calls(source, methods).map(NonPublicApiUsageOffense{
		method: it.method
		receiver: it.receiver
		begin_pos: it.begin_pos
		end_pos: it.end_pos
		line: it.line
		column: it.column
		message: message_template.replace_once('%s', it.method)
	})
}

pub fn audit_non_public_api_usage_with_methods(source string, formula_tap string, internal_methods []string,
	private_methods []string) []NonPublicApiUsageOffense {
	if formula_tap !in api_annotations.official_taps {
		return []
	}
	mut offenses := check_non_public_api_method_calls(source, internal_methods, non_public_api_internal_message)
	offenses << check_non_public_api_method_calls(source, private_methods, non_public_api_private_message)
	return offenses
}

pub fn audit_non_public_api_usage(source string, formula_tap string, homebrew_dir string) []NonPublicApiUsageOffense {
	if formula_tap !in api_annotations.official_taps {
		return []
	}
	return audit_non_public_api_usage_with_methods(source, formula_tap, non_public_api_internal_methods(homebrew_dir), non_public_api_private_methods(homebrew_dir))
}

fn non_public_api_offense_value(offense NonPublicApiUsageOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':    offense.method
		'receiver':  offense.receiver
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'line':      offense.line.str()
		'column':    offense.column.str()
		'message':   offense.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 40.
pub fn ruby_non_public_api_usage_l40_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_tap := if args.len > 1 { args[1].as_string() } else { '' }
	offenses := if args.len > 3 && args[2].type_name == 'Array' && args[3].type_name == 'Array' {
		audit_non_public_api_usage_with_methods(source, formula_tap, args[2].as_string_array() or {
			[]
		}, args[3].as_string_array() or { [] })
	} else {
		homebrew_dir := if args.len > 2 {
			args[2].as_string()
		} else {
			api_annotations.api_annotation_homebrew_dir()
		}
		audit_non_public_api_usage(source, formula_tap, homebrew_dir)
	}
	return ruby.array_value(offenses.map(non_public_api_offense_value(it)))
}

// Ruby method `internal_methods` at line 51.
pub fn ruby_non_public_api_usage_l51_d2_internal_methods(args ...ruby.Value) ruby.Value {
	homebrew_dir := if args.len > 0 {
		args[0].as_string()
	} else {
		api_annotations.api_annotation_homebrew_dir()
	}
	return ruby.string_array_value(non_public_api_internal_methods(homebrew_dir))
}

// Ruby method `private_methods` at line 59.
pub fn ruby_non_public_api_usage_l59_d3_private_methods(args ...ruby.Value) ruby.Value {
	homebrew_dir := if args.len > 0 {
		args[0].as_string()
	} else {
		api_annotations.api_annotation_homebrew_dir()
	}
	return ruby.string_array_value(non_public_api_private_methods(homebrew_dir))
}

// Ruby method `load_methods_for_level(level)` at line 67.
pub fn ruby_non_public_api_usage_l67_d4_load_methods_for_level(args ...ruby.Value) ruby.Value {
	level := if args.len > 0 { args[0].as_string() } else { '' }
	homebrew_dir := if args.len > 1 {
		args[1].as_string()
	} else {
		api_annotations.api_annotation_homebrew_dir()
	}
	return ruby.string_array_value(load_non_public_api_methods_for_level(homebrew_dir, level))
}

// Ruby method `check_method_calls(body_node, methods, msg)` at line 84.
pub fn ruby_non_public_api_usage_l84_d5_check_method_calls(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	methods := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	message := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.array_value(check_non_public_api_method_calls(source, methods, message).map(non_public_api_offense_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/api_annotation_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # Ensures that formulae in official taps (homebrew-core, homebrew-cask)
// 11:       # only use methods that are part of the public API (`@api public`) and
// 12:       # do not call methods marked as `@api private` or `@api internal`.
// 13:       #
// 14:       # The lists of internal/private methods are derived dynamically from
// 15:       # `@api` annotations in the source files rather than hardcoded, so
// 16:       # they stay in sync automatically.
// 17:       #
// 18:       # ### Example
// 19:       #
// 20:       # ```ruby
// 21:       # # bad - `tap` is @api internal
// 22:       # class Foo < Formula
// 23:       #   def install
// 24:       #     puts tap
// 25:       #   end
// 26:       # end
// 27:       #
// 28:       # # good - `bin` is @api public
// 29:       # class Foo < Formula
// 30:       #   def install
// 31:       #     bin.install "foo"
// 32:       #   end
// 33:       # end
// 34:       # ```
// 35:       class NonPublicApiUsage < FormulaCop
// 36:         INTERNAL_MSG = "Do not use `%<method>s` in official tap formulae; it is an internal API (`@api internal`)."
// 37:         PRIVATE_MSG = "Do not use `%<method>s` in official tap formulae; it is a private API (`@api private`)."
// 38:
// 39:         sig { override.params(formula_nodes: FormulaNodes).void }
// 40:         def audit_formula(formula_nodes)
// 41:           return if ApiAnnotationHelper::OFFICIAL_TAPS.none?(formula_tap)
// 42:           return if (body_node = formula_nodes.body_node).nil?
// 43:
// 44:           check_method_calls(body_node, internal_methods, INTERNAL_MSG)
// 45:           check_method_calls(body_node, private_methods, PRIVATE_MSG)
// 46:         end
// 47:
// 48:         private
// 49:
// 50:         sig { returns(T::Set[String]) }
// 51:         def internal_methods
// 52:           @internal_methods ||= T.let(
// 53:             load_methods_for_level("internal"),
// 54:             T.nilable(T::Set[String]),
// 55:           )
// 56:         end
// 57:
// 58:         sig { returns(T::Set[String]) }
// 59:         def private_methods
// 60:           @private_methods ||= T.let(
// 61:             load_methods_for_level("private"),
// 62:             T.nilable(T::Set[String]),
// 63:           )
// 64:         end
// 65:
// 66:         sig { params(level: String).returns(T::Set[String]) }
// 67:         def load_methods_for_level(level)
// 68:           methods = T.let(Set.new, T::Set[String])
// 69:           ApiAnnotationHelper::API_SOURCE_FILES.each do |source_file|
// 70:             methods.merge(ApiAnnotationHelper.methods_with_api_level(
// 71:                             File.join(ApiAnnotationHelper.homebrew_dir, source_file), level
// 72:                           ))
// 73:           end
// 74:           methods
// 75:         end
// 76:
// 77:         sig {
// 78:           params(
// 79:             body_node: RuboCop::AST::Node,
// 80:             methods:   T::Set[String],
// 81:             msg:       String,
// 82:           ).void
// 83:         }
// 84:         def check_method_calls(body_node, methods, msg)
// 85:           methods.each do |method_name|
// 86:             find_every_method_call_by_name(body_node, method_name.to_sym).each do |node|
// 87:               # Only flag implicit receiver calls (i.e. `tap` not `foo.tap`)
// 88:               # to reduce false positives from local variables or other objects.
// 89:               next if node.receiver && !node.receiver.self_type?
// 90:
// 91:               @offensive_node = node
// 92:               problem format(msg, method: method_name)
// 93:             end
// 94:           end
// 95:         end
// 96:       end
// 97:     end
// 98:   end
// 99: end
