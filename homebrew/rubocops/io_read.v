module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/io_read.rb`.
pub const io_read_message_template = 'The use of `IO.%s` is a security risk.'

pub enum IoReadArgumentKind {
	string_literal
	dynamic_string
	concatenation
	other
}

pub struct IoReadArgument {
pub:
	source          string
	kind            IoReadArgumentKind
	first_is_string bool
	first_string    string
}

pub struct IoReadCall {
pub:
	method    string
	argument  IoReadArgument
	begin_pos int
	end_pos   int
}

pub struct IoReadOffense {
pub:
	method    string
	begin_pos int
	end_pos   int
	message   string
}

fn io_read_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn io_read_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() && source[position] != `\n` {
		position++
	}
	return position
}

fn io_read_quoted_end(source string, start int) int {
	if start >= source.len || source[start] !in [`'`, `\"`] {
		return start
	}
	quote := source[start]
	mut escaped := false
	mut position := start + 1
	for position < source.len {
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
	return source.len
}

fn io_read_trim_range(source string, begin_pos int, end_pos int) (int, int) {
	mut start := begin_pos
	mut finish := end_pos
	for start < finish && source[start].is_space() {
		start++
	}
	for finish > start && source[finish - 1].is_space() {
		finish--
	}
	return start, finish
}

fn io_read_top_level_plus(source string) ?int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = io_read_quoted_end(source, position)
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`+` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			else {}
		}
		position++
	}
	return none
}

fn io_read_dynamic_prefix(raw string) (bool, string) {
	mut escaped := false
	mut position := 0
	for position < raw.len {
		character := raw[position]
		if escaped {
			escaped = false
			position++
			continue
		}
		if character == `\\` {
			escaped = true
			position++
			continue
		}
		if character == `#` && position + 1 < raw.len && raw[position + 1] == `{` {
			return true, io_read_unescape_string(raw[..position])
		}
		position++
	}
	return false, io_read_unescape_string(raw)
}

fn io_read_unescape_string(raw string) string {
	mut content := []u8{cap: raw.len}
	mut position := 0
	for position < raw.len {
		if raw[position] == `\\` && position + 1 < raw.len {
			position++
			match raw[position] {
				`n` { content << `\n` }
				`r` { content << `\r` }
				`t` { content << `\t` }
				else { content << raw[position] }
			}
		} else {
			content << raw[position]
		}
		position++
	}
	return content.bytestr()
}

pub fn parse_io_read_argument(expression string) IoReadArgument {
	start, finish := io_read_trim_range(expression, 0, expression.len)
	trimmed := expression[start..finish]
	if plus := io_read_top_level_plus(trimmed) {
		left := parse_io_read_argument(trimmed[..plus])
		return IoReadArgument{
			source: trimmed
			kind: .concatenation
			first_is_string: left.first_is_string
			first_string: left.first_string
		}
	}
	if trimmed.len >= 2 && trimmed[0] in [`'`, `\"`] {
		quoted_end := io_read_quoted_end(trimmed, 0)
		if quoted_end == trimmed.len {
			raw := trimmed[1..trimmed.len - 1]
			if trimmed[0] == `\"` {
				is_dynamic, prefix := io_read_dynamic_prefix(raw)
				return IoReadArgument{
					source: trimmed
					kind: if is_dynamic { .dynamic_string } else { .string_literal }
					first_is_string: !is_dynamic || prefix != ''
					first_string: prefix
				}
			}
			return IoReadArgument{
				source: trimmed
				kind: .string_literal
				first_is_string: true
				first_string: io_read_unescape_string(raw)
			}
		}
	}
	return IoReadArgument{
		source: trimmed
		kind: .other
	}
}

pub fn io_read_argument_safe(argument IoReadArgument) bool {
	return argument.first_is_string && argument.first_string != '' && !argument.first_string.starts_with('|')
}

fn io_read_argument_end(source string, start int, close int) int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := start
	for position < close {
		character := source[position]
		if character in [`'`, `\"`] {
			position = io_read_quoted_end(source, position)
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			else {}
		}
		position++
	}
	return close
}

fn io_read_closing_parenthesis(source string, open int) ?int {
	mut depth := 1
	mut position := open + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = io_read_quoted_end(source, position)
			continue
		}
		if character == `(` {
			depth++
		} else if character == `)` {
			depth--
			if depth == 0 {
				return position
			}
		}
		position++
	}
	return none
}

fn io_read_line_end(source string, start int) int {
	mut position := start
	for position < source.len && source[position] != `\n` && source[position] != `#` {
		position++
	}
	_, finish := io_read_trim_range(source, start, position)
	return finish
}

pub fn io_read_calls(source string) []IoReadCall {
	mut calls := []IoReadCall{}
	mut position := 0
	for position < source.len {
		if source[position] in [`'`, `\"`] {
			position = io_read_quoted_end(source, position)
			continue
		}
		if source[position] == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if !source[position..].starts_with('IO') || (position > 0 && (io_read_identifier_byte(source[position - 1]) || source[position - 1] == `:`)) {
			position++
			continue
		}
		mut cursor := io_read_skip_space(source, position + 2)
		if cursor >= source.len || source[cursor] != `.` {
			position++
			continue
		}
		cursor = io_read_skip_space(source, cursor + 1)
		method_begin := cursor
		for cursor < source.len && io_read_identifier_byte(source[cursor]) {
			cursor++
		}
		method := source[method_begin..cursor]
		if method !in ['read', 'readlines'] {
			position++
			continue
		}
		cursor = io_read_skip_space(source, cursor)
		mut argument_begin := cursor
		mut argument_finish := cursor
		mut call_end := cursor
		if cursor < source.len && source[cursor] == `(` {
			close := io_read_closing_parenthesis(source, cursor) or {
				position++
				continue
			}
			argument_begin = io_read_skip_space(source, cursor + 1)
			argument_finish = io_read_argument_end(source, argument_begin, close)
			call_end = close + 1
		} else {
			argument_finish = io_read_line_end(source, cursor)
			call_end = argument_finish
		}
		calls << IoReadCall{
			method: method
			argument: parse_io_read_argument(source[argument_begin..argument_finish])
			begin_pos: position
			end_pos: call_end
		}
		position = if call_end > position { call_end } else { position + 1 }
	}
	return calls
}

pub fn audit_io_reads(source string) []IoReadOffense {
	mut offenses := []IoReadOffense{}
	for call in io_read_calls(source) {
		if io_read_argument_safe(call.argument) {
			continue
		}
		offenses << IoReadOffense{
			method: call.method
			begin_pos: call.begin_pos
			end_pos: call.end_pos
			message: io_read_message_template.replace('%s', call.method)
		}
	}
	return offenses
}

fn io_read_offense_value(offense IoReadOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':    offense.method
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
	})
}
