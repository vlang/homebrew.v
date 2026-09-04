module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/zero_zero_zero_zero.rb`.
// The original source is retained below until every stub has a typed V body.
pub const zero_zero_zero_zero_message = 'Do not use 0.0.0.0 as it can be a security risk.'

pub struct ZeroZeroZeroZeroStringLiteral {
pub:
	content   string
	begin_pos int
	end_pos   int
	line      int
	column    int
}

pub struct ZeroZeroZeroZeroOffense {
pub:
	content   string
	begin_pos int
	end_pos   int
	line      int
	column    int
	message   string
}

struct ZeroZeroZeroZeroLine {
	start       int
	end         int
	newline_end int
	indent      int
	text        string
}

struct ZeroZeroZeroZeroSpan {
	found     bool
	begin_pos int
	end_pos   int
	indent    int
}

fn zero_zero_zero_zero_lines(source string) []ZeroZeroZeroZeroLine {
	mut lines := []ZeroZeroZeroZeroLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && text[indent] in [` `, `\t`] {
			indent++
		}
		lines << ZeroZeroZeroZeroLine{
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

fn zero_zero_zero_zero_code(line string) string {
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
			return line[..index].trim_space()
		}
	}
	return line.trim_space()
}

fn zero_zero_zero_zero_formula_body(source string, lines []ZeroZeroZeroZeroLine) ZeroZeroZeroZeroSpan {
	for class_index, line in lines {
		code := zero_zero_zero_zero_code(line.text)
		if !code.starts_with('class ') || !code.contains('< Formula') {
			continue
		}
		for closing_index in class_index + 1 .. lines.len {
			closing := lines[closing_index]
			if closing.indent == line.indent && zero_zero_zero_zero_code(closing.text) == 'end' {
				return ZeroZeroZeroZeroSpan{
					found: true
					begin_pos: line.newline_end
					end_pos: closing.start
					indent: line.indent
				}
			}
		}
	}
	return ZeroZeroZeroZeroSpan{
		found: source.trim_space() != ''
		begin_pos: 0
		end_pos: source.len
		indent: -1
	}
}

fn zero_zero_zero_zero_test_block(lines []ZeroZeroZeroZeroLine, body ZeroZeroZeroZeroSpan) ZeroZeroZeroZeroSpan {
	mut direct_indent := int(1 << 30)
	for line in lines {
		if line.start < body.begin_pos || line.start >= body.end_pos || line.indent <= body.indent {
			continue
		}
		code := zero_zero_zero_zero_code(line.text)
		if code != '' && code != 'end' && line.indent < direct_indent {
			direct_indent = line.indent
		}
	}
	if body.indent < 0 {
		for line in lines {
			if line.start < body.begin_pos || line.start >= body.end_pos {
				continue
			}
			code := zero_zero_zero_zero_code(line.text)
			if code != '' && code != 'end' && line.indent < direct_indent {
				direct_indent = line.indent
			}
		}
	}
	if direct_indent == 1 << 30 {
		return ZeroZeroZeroZeroSpan{}
	}
	for test_index, line in lines {
		if line.start < body.begin_pos || line.start >= body.end_pos || line.indent != direct_indent {
			continue
		}
		code := zero_zero_zero_zero_code(line.text)
		if code != 'test do' && !code.starts_with('test do |') {
			continue
		}
		for closing_index in test_index + 1 .. lines.len {
			closing := lines[closing_index]
			if closing.start >= body.end_pos {
				break
			}
			if closing.indent == line.indent && zero_zero_zero_zero_code(closing.text) == 'end' {
				return ZeroZeroZeroZeroSpan{
					found: true
					begin_pos: line.newline_end
					end_pos: closing.start
					indent: line.indent
				}
			}
		}
		break
	}
	return ZeroZeroZeroZeroSpan{}
}

fn zero_zero_zero_zero_string_content(raw string, quote u8) string {
	mut content := ''
	mut index := 0
	for index < raw.len {
		if raw[index] != `\\` || index + 1 >= raw.len {
			content += raw[index].ascii_str()
			index++
			continue
		}
		next := raw[index + 1]
		if quote == `'` && next !in [`'`, `\\`] {
			content += '\\'
			content += next.ascii_str()
			index += 2
			continue
		}
		content += match next {
			`n` { '\n' }
			`r` { '\r' }
			`t` { '\t' }
			else { next.ascii_str() }
		}
		index += 2
	}
	return content
}

fn zero_zero_zero_zero_line_and_column(source string, position int) (int, int) {
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

pub fn zero_zero_zero_zero_string_literals(source string) []ZeroZeroZeroZeroStringLiteral {
	mut literals := []ZeroZeroZeroZeroStringLiteral{}
	mut index := 0
	for index < source.len {
		character := source[index]
		if character == `#` {
			index = source.index_after('\n', index) or { source.len }
			continue
		}
		if character == 96 {
			mut end := index + 1
			mut escaped := false
			for end < source.len {
				if escaped {
					escaped = false
				} else if source[end] == `\\` {
					escaped = true
				} else if source[end] == character {
					end++
					break
				}
				end++
			}
			index = end
			continue
		}
		if character !in [`'`, `\"`] {
			index++
			continue
		}
		mut end := index + 1
		mut escaped := false
		for end < source.len {
			if escaped {
				escaped = false
			} else if source[end] == `\\` {
				escaped = true
			} else if source[end] == character {
				break
			}
			end++
		}
		if end >= source.len {
			break
		}
		if index == 0 || source[index - 1] != `:` {
			line, column := zero_zero_zero_zero_line_and_column(source, index)
			literals << ZeroZeroZeroZeroStringLiteral{
				content: zero_zero_zero_zero_string_content(source[index + 1..end], character)
				begin_pos: index
				end_pos: end + 1
				line: line
				column: column
			}
		}
		index = end + 1
	}
	return literals
}

fn zero_zero_zero_zero_word_character(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn zero_zero_zero_zero_boundary_before(content string, position int) bool {
	return position == 0 || !zero_zero_zero_zero_word_character(content[position - 1])
}

fn zero_zero_zero_zero_boundary_after(content string, position int) bool {
	return position >= content.len || !zero_zero_zero_zero_word_character(content[position])
}

fn zero_zero_zero_zero_digits_end(content string, start int) int {
	mut end := start
	for end < content.len && content[end].is_digit() {
		end++
	}
	return if end > start { end } else { -1 }
}

fn zero_zero_zero_zero_private_range_from(content string, start int) int {
	mut position := start
	if content[start..].starts_with('10.') {
		position += 3
	} else if content[start..].starts_with('172.') {
		second_end := zero_zero_zero_zero_digits_end(content, start + 4)
		if second_end < 0 || second_end >= content.len || content[second_end] != `.` {
			return -1
		}
		second := content[start + 4..second_end].int()
		if second < 16 || second > 31 {
			return -1
		}
		position = second_end + 1
	} else if content[start..].starts_with('192.168.') {
		position += '192.168.'.len
	} else {
		return -1
	}
	first_end := zero_zero_zero_zero_digits_end(content, position)
	if first_end < 0 || first_end >= content.len || content[first_end] != `.` {
		return -1
	}
	return zero_zero_zero_zero_digits_end(content, first_end + 1)
}

fn zero_zero_zero_zero_has_private_range(content string) bool {
	for start in 0 .. content.len {
		if !content[start].is_digit() || !zero_zero_zero_zero_boundary_before(content, start) {
			continue
		}
		end := zero_zero_zero_zero_private_range_from(content, start)
		if end >= 0 && zero_zero_zero_zero_boundary_after(content, end) {
			return true
		}
	}
	return false
}

fn zero_zero_zero_zero_has_full_ip_range(content string) bool {
	first_address := '0.0.0.0'
	last_address := '255.255.255.255'
	mut search_start := 0
	for search_start < content.len {
		relative := content[search_start..].index(first_address) or { return false }
		start := search_start + relative
		mut position := start + first_address.len
		if !zero_zero_zero_zero_boundary_before(content, start) {
			search_start = start + 1
			continue
		}
		for position < content.len && content[position].is_space() {
			position++
		}
		if position >= content.len || content[position] != `-` {
			search_start = start + 1
			continue
		}
		position++
		for position < content.len && content[position].is_space() {
			position++
		}
		if !content[position..].starts_with(last_address) {
			search_start = start + 1
			continue
		}
		position += last_address.len
		if zero_zero_zero_zero_boundary_after(content, position) {
			return true
		}
		search_start = start + 1
	}
	return false
}

pub fn valid_zero_zero_zero_zero_ip_range(content string) bool {
	// Allow private IP ranges like 10.0.0.0, 172.16.0.0-172.31.255.255, 192.168.0.0-192.168.255.255
	if zero_zero_zero_zero_has_private_range(content) {
		return true
	}
	// Allow IP range notation like 0.0.0.0-255.255.255.255
	if zero_zero_zero_zero_has_full_ip_range(content) {
		return true
	}
	return false
}

pub fn audit_zero_zero_zero_zero(source string, formula_tap string) []ZeroZeroZeroZeroOffense {
	if formula_tap != 'homebrew-core' {
		return []
	}
	lines := zero_zero_zero_zero_lines(source)
	body := zero_zero_zero_zero_formula_body(source, lines)
	if !body.found {
		return []
	}
	test_block := zero_zero_zero_zero_test_block(lines, body)
	mut offenses := []ZeroZeroZeroZeroOffense{}
	for literal in zero_zero_zero_zero_string_literals(source) {
		if literal.begin_pos < body.begin_pos || literal.end_pos > body.end_pos {
			continue
		}
		if !literal.content.contains('0.0.0.0') {
			continue
		}
		if test_block.found && literal.begin_pos >= test_block.begin_pos && literal.end_pos <= test_block.end_pos {
			continue
		}
		if valid_zero_zero_zero_zero_ip_range(literal.content) {
			continue
		}
		offenses << ZeroZeroZeroZeroOffense{
			content: literal.content
			begin_pos: literal.begin_pos
			end_pos: literal.end_pos
			line: literal.line
			column: literal.column
			message: zero_zero_zero_zero_message
		}
	}
	return offenses
}

fn zero_zero_zero_zero_offense_value(offense ZeroZeroZeroZeroOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'content':   offense.content
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'line':      offense.line.str()
		'column':    offense.column.str()
		'message':   offense.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 13.
pub fn ruby_zero_zero_zero_zero_l13_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_tap := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.array_value(audit_zero_zero_zero_zero(source, formula_tap).map(zero_zero_zero_zero_offense_value(it)))
}

// Ruby method `valid_ip_range?(content)` at line 37.
pub fn ruby_zero_zero_zero_zero_l37_d2_valid_ip_range(args ...ruby.Value) ruby.Value {
	content := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(valid_zero_zero_zero_zero_ip_range(content))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop audits the use of 0.0.0.0 in formulae.
// 10:       # 0.0.0.0 should not be used outside of test do blocks as it can be a security risk.
// 11:       class ZeroZeroZeroZero < FormulaCop
// 12:         sig { override.params(formula_nodes: FormulaNodes).void }
// 13:         def audit_formula(formula_nodes)
// 14:           return if formula_tap != "homebrew-core"
// 15:
// 16:           body_node = formula_nodes.body_node
// 17:           return if body_node.nil?
// 18:
// 19:           test_block = find_block(body_node, :test)
// 20:
// 21:           # Find all string literals in the formula
// 22:           body_node.each_descendant(:str) do |str_node|
// 23:             content = string_content(str_node)
// 24:             next unless content.include?("0.0.0.0")
// 25:             next if test_block && str_node.ancestors.any?(test_block)
// 26:
// 27:             next if valid_ip_range?(content)
// 28:
// 29:             offending_node(str_node)
// 30:             problem "Do not use 0.0.0.0 as it can be a security risk."
// 31:           end
// 32:         end
// 33:
// 34:         private
// 35:
// 36:         sig { params(content: String).returns(T::Boolean) }
// 37:         def valid_ip_range?(content)
// 38:           # Allow private IP ranges like 10.0.0.0, 172.16.0.0-172.31.255.255, 192.168.0.0-192.168.255.255
// 39:           return true if content.match?(/\b(?:10|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.\d+\.\d+\b/)
// 40:           # Allow IP range notation like 0.0.0.0-255.255.255.255
// 41:           return true if content.match?(/\b0\.0\.0\.0\s*-\s*255\.255\.255\.255\b/)
// 42:
// 43:           false
// 44:         end
// 45:       end
// 46:     end
// 47:   end
// 48: end
