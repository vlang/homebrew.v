module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/compact_blank.rb`.
pub const compact_blank_message_template = 'Use `%s` instead.'

pub struct CompactBlankCall {
pub:
	method            string
	kind              string
	arguments         []string
	receiver_in_block string
	source            string
	selector_begin    int
	selector_end      int
	end_pos           int
	preferred_method  string
}

pub struct CompactBlankOffense {
pub:
	call        CompactBlankCall
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct CompactBlankAnalysis {
pub:
	offenses  []CompactBlankOffense
	corrected string
}

fn compact_blank_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn compact_blank_quoted_end(source string, start int) int {
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

fn compact_blank_skip_comment(source string, start int) int {
	mut position := start
	for position < source.len && source[position] != `\n` {
		position++
	}
	return position
}

fn compact_blank_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	return position
}

fn compact_blank_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn compact_blank_matching_delimiter(source string, open int, opening u8, closing u8) ?int {
	mut depth := 1
	mut position := open + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if character == opening {
			depth++
		} else if character == closing {
			depth--
			if depth == 0 {
				return position
			}
		}
		position++
	}
	return none
}

fn compact_blank_word_at(source string, position int, word string) bool {
	if position < 0 || position + word.len > source.len || source[position..position + word.len] != word {
		return false
	}
	before_ok := position == 0 || !compact_blank_identifier_byte(source[position - 1])
	after := position + word.len
	after_ok := after == source.len || !compact_blank_identifier_byte(source[after])
	return before_ok && after_ok
}

fn compact_blank_matching_end(source string, opening_do int) ?int {
	mut depth := 1
	mut position := opening_do + 2
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if compact_blank_word_at(source, position, 'do') {
			depth++
			position += 2
			continue
		}
		if compact_blank_word_at(source, position, 'end') {
			depth--
			if depth == 0 {
				return position
			}
			position += 3
			continue
		}
		position++
	}
	return none
}

fn compact_blank_without_comments_and_space(source string) string {
	mut result := ''
	mut position := 0
	for position < source.len {
		character := source[position]
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if !character.is_space() {
			result += character.ascii_str()
		}
		position++
	}
	return result
}

fn compact_blank_argument_sources(source string) []string {
	mut arguments := []string{}
	mut start := 0
	mut position := 0
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
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
					argument_start, argument_end := compact_blank_trim_range(source, start, position)
					arguments << source[argument_start..argument_end]
					start = position + 1
				}
			}
			else {}
		}
		position++
	}
	argument_start, argument_end := compact_blank_trim_range(source, start, source.len)
	if argument_start < argument_end {
		arguments << source[argument_start..argument_end]
	}
	return arguments
}

fn compact_blank_local_variable(source string) bool {
	if source.len == 0 || !(source[0].is_letter() || source[0] == `_`) || source[0].is_capital() {
		return false
	}
	for character in source.bytes() {
		if !compact_blank_identifier_byte(character) {
			return false
		}
	}
	return true
}

fn compact_blank_block_parts(source string, body_begin int, body_end int) ?([]string, string) {
	mut position := compact_blank_skip_space(source, body_begin)
	if position >= body_end || source[position] != `|` {
		return none
	}
	arguments_begin := position + 1
	position = arguments_begin
	for position < body_end && source[position] != `|` {
		if source[position] in [`'`, `\"`] || source[position] == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		position++
	}
	if position >= body_end {
		return none
	}
	arguments := compact_blank_argument_sources(source[arguments_begin..position])
	body_start, body_finish := compact_blank_trim_range(source, position + 1, body_end)
	if body_start >= body_finish {
		return none
	}
	body := compact_blank_without_comments_and_space(source[body_start..body_finish])
	mut receiver := ''
	if body.ends_with('.blank?()') {
		receiver = body[..body.len - '.blank?()'.len]
	} else if body.ends_with('.blank?') {
		receiver = body[..body.len - '.blank?'.len]
	} else {
		return none
	}
	if !compact_blank_local_variable(receiver) {
		return none
	}
	return arguments, receiver
}

fn compact_blank_method_at(source string, selector int) ?string {
	if selector > 0 && compact_blank_identifier_byte(source[selector - 1]) {
		return none
	}
	if selector > 0 && source[selector - 1] == `:` {
		return none
	}
	if selector >= 2 && source[selector - 2..selector] == '&.' {
		return none
	}
	for method_name in ['delete_if', 'reject!', 'reject'] {
		if !source[selector..].starts_with(method_name) {
			continue
		}
		end_pos := selector + method_name.len
		if end_pos < source.len && (compact_blank_identifier_byte(source[end_pos]) || source[end_pos] in [
			`!`,
			`?`,
		]) {
			continue
		}
		return method_name
	}
	return none
}

fn compact_blank_is_block_pass(source string) bool {
	return compact_blank_without_comments_and_space(source) == '&:blank?'
}

fn compact_blank_candidate_at(source string, selector int, method_name string) ?CompactBlankCall {
	selector_end := selector + method_name.len
	mut position := compact_blank_skip_space(source, selector_end)
	mut parenthesized_empty := false
	if position < source.len && source[position] == `(` {
		close := compact_blank_matching_delimiter(source, position, `(`, `)`) or { return none }
		inner_start, inner_end := compact_blank_trim_range(source, position + 1, close)
		if compact_blank_is_block_pass(source[inner_start..inner_end]) {
			return CompactBlankCall{
				method: method_name
				kind: 'block_pass'
				source: source[selector..close + 1]
				selector_begin: selector
				selector_end: selector_end
				end_pos: close + 1
				preferred_method: if method_name == 'reject' {
					'compact_blank'
				} else {
					'compact_blank!'
				}
			}
		}
		if inner_start < inner_end {
			return none
		}
		parenthesized_empty = true
		position = compact_blank_skip_space(source, close + 1)
	}
	if !parenthesized_empty && position < source.len && source[position..].starts_with('&:blank?') {
		end_pos := position + '&:blank?'.len
		if end_pos == source.len || !compact_blank_identifier_byte(source[end_pos]) {
			return CompactBlankCall{
				method: method_name
				kind: 'block_pass'
				source: source[selector..end_pos]
				selector_begin: selector
				selector_end: selector_end
				end_pos: end_pos
				preferred_method: if method_name == 'reject' {
					'compact_blank'
				} else {
					'compact_blank!'
				}
			}
		}
	}
	mut body_begin := 0
	mut body_end := 0
	mut call_end := 0
	if position < source.len && source[position] == `{` {
		close := compact_blank_matching_delimiter(source, position, `{`, `}`) or { return none }
		body_begin = position + 1
		body_end = close
		call_end = close + 1
	} else if compact_blank_word_at(source, position, 'do') {
		closing_end := compact_blank_matching_end(source, position) or { return none }
		body_begin = position + 2
		body_end = closing_end
		call_end = closing_end + 3
	} else {
		return none
	}
	arguments, receiver := compact_blank_block_parts(source, body_begin, body_end) or { return none }
	return CompactBlankCall{
		method: method_name
		kind: 'block'
		arguments: arguments
		receiver_in_block: receiver
		source: source[selector..call_end]
		selector_begin: selector
		selector_end: selector_end
		end_pos: call_end
		preferred_method: if method_name == 'reject' { 'compact_blank' } else { 'compact_blank!' }
	}
}

pub fn compact_blank_uses_single_value(arguments []string, receiver_in_block string) bool {
	return arguments.len == 1 && arguments[0] == receiver_in_block
}

pub fn compact_blank_uses_hash_value(arguments []string, receiver_in_block string) bool {
	return arguments.len == 2 && arguments[1] == receiver_in_block
}

pub fn compact_blank_bad_method(call CompactBlankCall) bool {
	return call.kind == 'block_pass' || compact_blank_uses_single_value(call.arguments, call.receiver_in_block) || compact_blank_uses_hash_value(call.arguments, call.receiver_in_block)
}

pub fn compact_blank_candidates(source string) []CompactBlankCall {
	mut calls := []CompactBlankCall{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		method_name := compact_blank_method_at(source, position) or {
			position++
			continue
		}
		if call := compact_blank_candidate_at(source, position, method_name) {
			calls << call
		}
		position += method_name.len
	}
	return calls
}

pub fn audit_compact_blank(source string) []CompactBlankOffense {
	mut offenses := []CompactBlankOffense{}
	for call in compact_blank_candidates(source) {
		if !compact_blank_bad_method(call) {
			continue
		}
		message := compact_blank_message_template.replace_once('%s', call.preferred_method)
		offenses << CompactBlankOffense{
			call: call
			begin_pos: call.selector_begin
			end_pos: call.end_pos
			message: message
			replacement: call.preferred_method
		}
	}
	return offenses
}

pub fn correct_compact_blank(source string) string {
	offenses := audit_compact_blank(source)
	mut corrected := source
	for index in 0 .. offenses.len {
		offense := offenses[offenses.len - 1 - index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

pub fn analyze_compact_blank(source string) CompactBlankAnalysis {
	return CompactBlankAnalysis{
		offenses: audit_compact_blank(source)
		corrected: correct_compact_blank(source)
	}
}

fn compact_blank_call_value(call CompactBlankCall, type_name string) ruby.Value {
	return ruby.structured_value(type_name, call.source, {
		'method':            call.method
		'kind':              call.kind
		'arguments':         call.arguments.join(',')
		'receiver_in_block': call.receiver_in_block
		'begin_pos':         call.selector_begin.str()
		'selector_end':      call.selector_end.str()
		'end_pos':           call.end_pos.str()
		'preferred_method':  call.preferred_method
	})
}

fn compact_blank_offense_value(offense CompactBlankOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':      offense.call.method
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}
