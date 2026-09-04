module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/no_send_in_tests.rb`.
pub const no_send_in_tests_message_template = 'Make the method public and call it directly instead of using `%s` in tests.'
pub const no_send_in_tests_dynamic_message_template = 'Use `public_send` instead of `%s` in tests; `%s` bypasses method visibility.'
pub const no_send_in_tests_public_send_message = 'Call the method directly instead of using `public_send` with a static method name.'

const no_send_in_tests_methods = ['send', '__send__', 'public_send']
const no_send_in_tests_operators = ['[]', '[]=', '+', '-', '*', '/', '%', '**', '==', '!=', '<',
	'<=', '>', '>=', '<=>', '===', '=~', '!~', '&', '|', '^', '<<', '>>', '~', '!', '+@', '-@']

pub struct NoSendInTestsArgument {
pub:
	kind      string
	value     string
	begin_pos int
	end_pos   int
}

pub struct NoSendInTestsCall {
pub:
	method          string
	begin_pos       int
	end_pos         int
	safe_navigation bool
	argument        NoSendInTestsArgument
}

pub struct NoSendInTestsOffense {
pub:
	call      NoSendInTestsCall
	begin_pos int
	end_pos   int
	message   string
}

fn no_send_in_tests_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn no_send_in_tests_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn no_send_in_tests_skip_space(source string, start int, include_newlines bool) int {
	mut position := start
	for position < source.len && source[position].is_space() && (include_newlines || source[position] != `\n`) {
		position++
	}
	return position
}

fn no_send_in_tests_quoted_end(source string, start int, limit int) int {
	quote := source[start]
	mut escaped := false
	mut position := start + 1
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

fn no_send_in_tests_literal_value(raw string) NoSendInTestsArgument {
	if raw.len >= 2 && raw[0] == `:` {
		if raw.len >= 3 && raw[1] in [`'`, `\"`] {
			end := no_send_in_tests_quoted_end(raw, 1, raw.len)
			if end == raw.len && !raw[2..raw.len - 1].contains('#{') {
				return NoSendInTestsArgument{
					kind: 'symbol'
					value: raw[2..raw.len - 1]
				}
			}
			return NoSendInTestsArgument{ kind: 'dynamic' }
		}
		if !raw[1..].contains_any(' \t\r\n,') {
			return NoSendInTestsArgument{
				kind: 'symbol'
				value: raw[1..]
			}
		}
	}
	if raw.len >= 2 && raw[0] in [`'`, `\"`] {
		end := no_send_in_tests_quoted_end(raw, 0, raw.len)
		if end == raw.len && (raw[0] == `'` || !raw[1..raw.len - 1].contains('#{')) {
			return NoSendInTestsArgument{
				kind: 'string'
				value: raw[1..raw.len - 1]
			}
		}
	}
	return NoSendInTestsArgument{ kind: 'dynamic' }
}

fn no_send_in_tests_argument_end(source string, start int, closing u8) int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := start
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_send_in_tests_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` {
				if closing == `)` && round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
				round_depth--
			}
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			`\n` {
				if closing == `\n` && round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			else {}
		}
		position++
	}
	return source.len
}

fn no_send_in_tests_first_argument(source string, method_end int) NoSendInTestsArgument {
	mut position := no_send_in_tests_skip_space(source, method_end, false)
	mut closing := u8(`\n`)
	if position < source.len && source[position] == `(` {
		position = no_send_in_tests_skip_space(source, position + 1, true)
		closing = `)`
	} else if position == method_end {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	if position >= source.len || source[position] == closing || source[position] == `\n` {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	end := no_send_in_tests_argument_end(source, position, closing)
	mut finish := end
	for finish > position && source[finish - 1].is_space() {
		finish--
	}
	if finish <= position {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	mut argument := no_send_in_tests_literal_value(source[position..finish])
	argument = NoSendInTestsArgument{
		...argument
		begin_pos: position
		end_pos: finish
	}
	return argument
}

pub fn directly_callable_no_send_name(argument NoSendInTestsArgument) bool {
	if argument.kind !in ['symbol', 'string'] {
		return false
	}
	name := argument.value
	if name in no_send_in_tests_operators {
		return true
	}
	if name.len == 0 || !no_send_in_tests_identifier_start(name[0]) {
		return false
	}
	mut position := 1
	for position < name.len && no_send_in_tests_identifier_byte(name[position]) {
		position++
	}
	if position < name.len && name[position] in [`?`, `!`, `=`] {
		position++
	}
	return position == name.len
}

fn no_send_in_tests_declaration(source string, begin_pos int) bool {
	line_start := source[..begin_pos].last_index_u8(`\n`)
	prefix := source[line_start + 1..begin_pos].trim_space()
	return prefix == 'def' || prefix.starts_with('def ') || prefix == 'alias' || prefix.starts_with('alias ')
}

fn no_send_in_tests_call_at(source string, begin_pos int, method string) ?NoSendInTestsCall {
	if begin_pos > 0 && no_send_in_tests_identifier_byte(source[begin_pos - 1]) {
		return none
	}
	end_pos := begin_pos + method.len
	if end_pos < source.len && no_send_in_tests_identifier_byte(source[end_pos]) {
		return none
	}
	if no_send_in_tests_declaration(source, begin_pos) {
		return none
	}
	mut previous := begin_pos - 1
	for previous >= 0 && source[previous].is_space() && source[previous] != `\n` {
		previous--
	}
	if previous >= 0 && source[previous] == `:` {
		return none
	}
	after := no_send_in_tests_skip_space(source, end_pos, false)
	if after < source.len && ((after == end_pos && source[after] == `:`) || (source[after] == `=` && (after + 1 >= source.len || source[after + 1] !in [
		`=`,
		`>`,
		`~`,
	]))) {
		return none
	}
	return NoSendInTestsCall{
		method: method
		begin_pos: begin_pos
		end_pos: end_pos
		safe_navigation: begin_pos >= 2 && source[begin_pos - 2..begin_pos] == '&.'
		argument: no_send_in_tests_first_argument(source, end_pos)
	}
}

pub fn audit_no_send_in_tests(source string) []NoSendInTestsOffense {
	mut offenses := []NoSendInTestsOffense{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_send_in_tests_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if no_send_in_tests_identifier_start(character) {
			mut token_end := position + 1
			for token_end < source.len && no_send_in_tests_identifier_byte(source[token_end]) {
				token_end++
			}
			method := source[position..token_end]
			if method in no_send_in_tests_methods {
				if call := no_send_in_tests_call_at(source, position, method) {
					directly_callable := directly_callable_no_send_name(call.argument)
					if method != 'public_send' || directly_callable {
						message := if method == 'public_send' {
							no_send_in_tests_public_send_message
						} else if directly_callable {
							no_send_in_tests_message_template.replace('%s', method)
						} else {
							no_send_in_tests_dynamic_message_template.replace_once('%s', method).replace_once('%s', method)
						}
						offenses << NoSendInTestsOffense{
							call: call
							begin_pos: call.begin_pos
							end_pos: call.end_pos
							message: message
						}
					}
				}
			}
			position = token_end
			continue
		}
		position++
	}
	return offenses
}

fn no_send_in_tests_offense_value(offense NoSendInTestsOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':          offense.call.method
		'begin_pos':       offense.begin_pos.str()
		'end_pos':         offense.end_pos.str()
		'message':         offense.message
		'argument_kind':   offense.call.argument.kind
		'argument':        offense.call.argument.value
		'safe_navigation': offense.call.safe_navigation.str()
	})
}
