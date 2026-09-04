module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/full_name_split.rb`.
// The original source is retained below until every stub has a typed V body.
pub const full_name_split_message = 'Use `Utils.name_from_full_name` instead of splitting formula or cask full names.'

const full_name_split_receiver_names = ['cask_full_name', 'cask_token', 'dep_full_name', 'dep_name',
	'formula_full_name', 'formula_name', 'full_name', 'name', 'new_full_name', 'new_name',
	'old_full_name', 'old_name', 'resolved_full_name', 'service_name', 'token']

pub struct FullNameSplitCall {
pub:
	begin_pos       int
	end_pos         int
	method          string
	safe_navigation bool
	receiver        string
	receiver_begin  int
	receiver_end    int
	split_begin     int
	split_end       int
}

pub struct FullNameSplitOffense {
pub:
	call        FullNameSplitCall
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct FullNameSplitOuterCall {
	method          string
	safe_navigation bool
	end_pos         int
}

fn full_name_split_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn full_name_split_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn full_name_split_skip_space(source string, start int, include_newlines bool) int {
	mut position := start
	for position < source.len && source[position].is_space() && (include_newlines || source[position] != `\n`) {
		position++
	}
	return position
}

fn full_name_split_quoted_end(source string, start int, limit int) int {
	if start >= limit || (source[start] !in [`'`, `\"`] && source[start] != 96) {
		return start
	}
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

fn full_name_split_percent_literal_end(source string, start int, limit int) int {
	if start >= limit || source[start] != `%` {
		return start
	}
	mut delimiter_pos := start + 1
	if delimiter_pos < limit && source[delimiter_pos].is_letter() {
		delimiter_pos++
	}
	if delimiter_pos >= limit || source[delimiter_pos].is_alnum() || source[delimiter_pos].is_space() {
		return start
	}
	opening := source[delimiter_pos]
	closing := match opening {
		`(` { u8(`)`) }
		`[` { u8(`]`) }
		`{` { u8(`}`) }
		`<` { u8(`>`) }
		else { opening }
	}
	mut depth := 1
	mut escaped := false
	mut position := delimiter_pos + 1
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == opening && opening != closing {
			depth++
		} else if character == closing {
			depth--
			if depth == 0 {
				return position + 1
			}
		}
		position++
	}
	return limit
}

fn full_name_split_regexp_end(source string, start int) int {
	mut escaped := false
	mut in_character_class := false
	mut position := start + 1
	for position < source.len {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == `[` {
			in_character_class = true
		} else if character == `]` {
			in_character_class = false
		} else if character == `/` && !in_character_class {
			position++
			for position < source.len && source[position].is_letter() {
				position++
			}
			return position
		} else if character == `\n` {
			return start
		}
		position++
	}
	return start
}

fn full_name_split_starts_regexp(source string, position int) bool {
	if source[position] != `/` {
		return false
	}
	previous := full_name_split_previous_nonspace(source, position)
	if previous < 0 || source[previous] in [`(`, `[`, `{`, `=`, `,`, `;`, `!`, `?`, `:`, `|`, `&`] {
		return true
	}
	line_start := source[..position].last_index_u8(`\n`) + 1
	prefix := source[line_start..position].trim_space()
	return prefix in ['return', 'when', 'if', 'unless', 'while', 'until']
}

fn full_name_split_matching_delimiter(source string, opening int, open u8, close u8) int {
	mut depth := 1
	mut position := opening + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == 96 {
			position = full_name_split_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return position
			}
		}
		position++
	}
	return source.len
}

fn full_name_split_previous_nonspace(source string, before int) int {
	mut position := before - 1
	for position >= 0 && source[position].is_space() {
		position--
	}
	return position
}

fn full_name_split_next_nonspace(source string, after int, limit int) int {
	mut position := after
	for position < limit && source[position].is_space() {
		position++
	}
	return position
}

fn full_name_split_receiver_start(source string, end_pos int) int {
	mut position := end_pos - 1
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position >= 0 {
		character := source[position]
		match character {
			`)` { round_depth++ }
			`]` { square_depth++ }
			`}` { brace_depth++ }
			`(` {
				if round_depth > 0 {
					round_depth--
				} else {
					break
				}
			}
			`[` {
				if square_depth > 0 {
					square_depth--
				} else {
					break
				}
			}
			`{` {
				if brace_depth > 0 {
					brace_depth--
				} else {
					break
				}
			}
			else {}
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
			if character in [`\n`, `;`, `,`, `=`, `+`, `*`, `/`, `%`, `!`, `<`, `>`, `?`, `|`, `{`,
				`}`] {
				break
			}
			if character == `-` && (position == 0 || source[position - 1] != `&`) {
				break
			}
			if character.is_space() {
				previous := full_name_split_previous_nonspace(source, position)
				next := full_name_split_next_nonspace(source, position + 1, end_pos)
				previous_is_chain := previous >= 0 && (source[previous] == `.` || (source[previous] == `&` && previous + 1 < source.len && source[previous + 1] == `.`))
				next_is_chain := next < end_pos && (source[next] == `.` || (source[next] == `&` && next + 1 < end_pos && source[next + 1] == `.`) || source[next] == `[`)
				if !previous_is_chain && !next_is_chain {
					break
				}
			}
		}
		position--
	}
	mut start := position + 1
	for start < end_pos && source[start].is_space() {
		start++
	}
	return start
}

fn full_name_split_literal_value(raw string) ?string {
	literal := raw.trim_space()
	if literal.starts_with('%') {
		end := full_name_split_percent_literal_end(literal, 0, literal.len)
		if end != literal.len {
			return none
		}
		mut delimiter_pos := 1
		mut interpolated := true
		if delimiter_pos < literal.len && literal[delimiter_pos].is_letter() {
			kind := literal[delimiter_pos]
			if kind !in [`q`, `Q`] {
				return none
			}
			interpolated = kind == `Q`
			delimiter_pos++
		}
		content := literal[delimiter_pos + 1..literal.len - 1]
		if interpolated && content.contains('#{') {
			return none
		}
		closing := literal[literal.len - 1].ascii_str()
		return content.replace('\\' + closing, closing).replace('\\\\', '\\')
	}
	if literal.len < 2 || literal[0] !in [`'`, `\"`] || literal[literal.len - 1] != literal[0] {
		return none
	}
	content := literal[1..literal.len - 1]
	if literal[0] == `\"` && content.contains('#{') {
		return none
	}
	mut value := ''
	mut position := 0
	for position < content.len {
		if content[position] != `\\` {
			value += content[position].ascii_str()
			position++
			continue
		}
		if position + 1 >= content.len {
			value += '\\'
			break
		}
		next := content[position + 1]
		if literal[0] == `'` {
			if next in [`'`, `\\`] {
				value += next.ascii_str()
			} else {
				value += '\\'
				value += next.ascii_str()
			}
		} else {
			match next {
				`n` {
					value += '\n'
				}
				`t` {
					value += '\t'
				}
				`r` {
					value += '\r'
				}
				else {
					value += next.ascii_str()
				}
			}
		}
		position += 2
	}
	return value
}

fn full_name_split_single_argument(source string, begin_pos int, end_pos int) ?string {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := begin_pos
	for position < end_pos {
		character := source[position]
		if character in [`'`, `\"`] || character == 96 {
			position = full_name_split_quoted_end(source, position, end_pos)
			continue
		}
		if character == `%` {
			literal_end := full_name_split_percent_literal_end(source, position, end_pos)
			if literal_end > position {
				position = literal_end
				continue
			}
		}
		if character == `#` {
			for position < end_pos && source[position] != `\n` {
				position++
			}
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
					tail := full_name_split_without_comments(source[position + 1..end_pos]).trim_space()
					if tail != '' {
						return none
					}
					argument := source[begin_pos..position].trim_space()
					if argument == '' {
						return none
					}
					return argument
				}
			}
			else {}
		}
		position++
	}
	argument := source[begin_pos..end_pos].trim_space()
	if argument == '' {
		return none
	}
	return argument
}

fn full_name_split_without_comments(source string) string {
	mut result := ''
	mut position := 0
	for position < source.len {
		if source[position] in [`'`, `\"`] || source[position] == 96 {
			end := full_name_split_quoted_end(source, position, source.len)
			result += source[position..end]
			position = end
			continue
		}
		if source[position] == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		result += source[position].ascii_str()
		position++
	}
	return result
}

fn full_name_split_ruby_int_is_minus_one(raw string) bool {
	mut literal := raw.replace(' ', '').replace('\t', '').replace('\r', '').replace('\n', '').replace('_', '')
	if !literal.starts_with('-') {
		return false
	}
	literal = literal[1..]
	if literal == '' {
		return false
	}
	if literal.starts_with('0x') || literal.starts_with('0X') {
		return literal[2..].to_lower() == '1'
	}
	if literal.starts_with('0b') || literal.starts_with('0B') {
		return literal[2..] == '1'
	}
	if literal.starts_with('0o') || literal.starts_with('0O') {
		return literal[2..] == '1'
	}
	return literal.trim_left('0') == '1'
}

fn full_name_split_command_end(source string, start int) int {
	mut position := start
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == 96 {
			position = full_name_split_quoted_end(source, position, source.len)
			continue
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && character.is_space() {
			keyword_start := full_name_split_skip_space(source, position, false)
			for keyword in ['if', 'unless', 'while', 'until', 'rescue'] {
				keyword_end := keyword_start + keyword.len
				if keyword_end <= source.len && source[keyword_start..keyword_end] == keyword && (keyword_end == source.len || !full_name_split_identifier_byte(source[keyword_end])) {
					mut end := position
					for end > start && source[end - 1].is_space() {
						end--
					}
					return end
				}
			}
		}
		match character {
			`(` { round_depth++ }
			`)` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					break
				}
				round_depth--
			}
			`[` { square_depth++ }
			`]` {
				if square_depth == 0 && round_depth == 0 && brace_depth == 0 {
					break
				}
				square_depth--
			}
			`{` { brace_depth++ }
			`}` {
				if brace_depth == 0 && round_depth == 0 && square_depth == 0 {
					break
				}
				brace_depth--
			}
			`#`, `\n`, `;`, `,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					break
				}
			}
			else {}
		}
		position++
	}
	mut end := position
	for end > start && source[end - 1].is_space() {
		end--
	}
	return end
}

fn full_name_split_parse_outer(source string, start int, expected_safe bool) ?FullNameSplitOuterCall {
	mut position := full_name_split_skip_space(source, start, true)
	mut safe_navigation := false
	if position + 1 < source.len && source[position..position + 2] == '&.' {
		safe_navigation = true
		position += 2
	} else if position < source.len && source[position] == `.` {
		position++
	} else {
		return none
	}
	if safe_navigation != expected_safe {
		return none
	}
	position = full_name_split_skip_space(source, position, true)
	if position >= source.len || !full_name_split_identifier_start(source[position]) {
		return none
	}
	method_start := position
	position++
	for position < source.len && full_name_split_identifier_byte(source[position]) {
		position++
	}
	method := source[method_start..position]
	if method !in ['last', 'fetch'] {
		return none
	}
	mut end_pos := position
	argument_start := full_name_split_skip_space(source, position, false)
	if argument_start < source.len && source[argument_start] == `(` {
		closing := full_name_split_matching_delimiter(source, argument_start, `(`, `)`)
		if closing >= source.len {
			return none
		}
		contents := full_name_split_without_comments(source[argument_start + 1..closing]).trim_space()
		if method == 'last' {
			if contents != '' {
				return none
			}
		} else {
			argument := full_name_split_single_argument(source, argument_start + 1, closing) or {
				return none
			}
			clean_argument := full_name_split_without_comments(argument).trim_space()
			if !full_name_split_ruby_int_is_minus_one(clean_argument) {
				return none
			}
		}
		end_pos = closing + 1
	} else if method == 'fetch' {
		if argument_start == position || argument_start >= source.len || source[argument_start] == `\n` {
			return none
		}
		end_pos = full_name_split_command_end(source, argument_start)
		argument := full_name_split_single_argument(source, argument_start, end_pos) or {
			return none
		}
		if !full_name_split_ruby_int_is_minus_one(argument) {
			return none
		}
	} else if argument_start > position && argument_start < source.len && source[argument_start] !in [
		`\n`,
		`#`,
		`;`,
		`.`,
		`&`,
		`)`,
		`]`,
		`}`,
		`,`,
	] {
		tail := source[argument_start..]
		if !tail.starts_with('if ') && !tail.starts_with('unless ') && !tail.starts_with('while ') && !tail.starts_with('until ') && !tail.starts_with('rescue ') {
			return none
		}
	}
	return FullNameSplitOuterCall{
		method: method
		safe_navigation: safe_navigation
		end_pos: end_pos
	}
}

fn full_name_split_parse_split_at(source string, operator_pos int, safe_navigation bool) ?FullNameSplitCall {
	operator_length := if safe_navigation { 2 } else { 1 }
	mut method_start := full_name_split_skip_space(source, operator_pos + operator_length, true)
	if method_start + 'split'.len > source.len || source[method_start..method_start + 'split'.len] != 'split' {
		return none
	}
	method_end := method_start + 'split'.len
	if method_end < source.len && full_name_split_identifier_byte(source[method_end]) {
		return none
	}
	mut position := full_name_split_skip_space(source, method_end, false)
	if position >= source.len || source[position] != `(` {
		return none
	}
	closing := full_name_split_matching_delimiter(source, position, `(`, `)`)
	if closing >= source.len {
		return none
	}
	argument := full_name_split_single_argument(source, position + 1, closing) or { return none }
	clean_argument := full_name_split_without_comments(argument).trim_space()
	literal := full_name_split_literal_value(clean_argument) or { return none }
	if literal != '/' {
		return none
	}
	receiver_end := operator_pos
	receiver_begin := full_name_split_receiver_start(source, receiver_end)
	if receiver_begin >= receiver_end {
		return none
	}
	receiver := source[receiver_begin..receiver_end].trim_space()
	if receiver == '' {
		return none
	}
	return FullNameSplitCall{
		begin_pos: receiver_begin
		end_pos: closing + 1
		safe_navigation: safe_navigation
		receiver: receiver
		receiver_begin: receiver_begin
		receiver_end: receiver_end
		split_begin: operator_pos
		split_end: closing + 1
	}
}

fn full_name_split_tap_full_name(receiver string) bool {
	return receiver == 'tap.full_name' || receiver == 'tap&.full_name' || receiver.ends_with('.tap.full_name') || receiver.ends_with('.tap&.full_name')
}

fn full_name_split_matching_open_square(source string) int {
	if !source.ends_with(']') {
		return -1
	}
	mut depth := 1
	mut position := source.len - 2
	for position >= 0 {
		if source[position] == `]` {
			depth++
		} else if source[position] == `[` {
			depth--
			if depth == 0 {
				return position
			}
		}
		position--
	}
	return -1
}

fn full_name_split_receiver_method_name(receiver string) ?string {
	mut source := receiver.trim_space()
	if source == '' {
		return none
	}
	if source.ends_with(']') {
		opening := full_name_split_matching_open_square(source)
		if opening < 0 {
			return none
		}
		argument := full_name_split_single_argument(source, opening + 1, source.len - 1) or {
			return none
		}
		return full_name_split_literal_value(full_name_split_without_comments(argument).trim_space())
	}
	if source.ends_with(')') {
		mut depth := 1
		mut opening := source.len - 2
		for opening >= 0 {
			if source[opening] == `)` {
				depth++
			} else if source[opening] == `(` {
				depth--
				if depth == 0 {
					break
				}
			}
			opening--
		}
		if opening < 0 {
			return none
		}
		method_source := source[..opening].trim_space()
		if method_source.ends_with('.[]') {
			argument := full_name_split_single_argument(source, opening + 1, source.len - 1) or {
				return none
			}
			return full_name_split_literal_value(full_name_split_without_comments(argument).trim_space())
		}
		source = source[..opening].trim_space()
	}
	method_end := source.len
	if method_end == 0 {
		return none
	}
	mut bare_end := method_end
	if source[bare_end - 1] in [`?`, `!`, `=`] {
		bare_end--
	}
	mut start := bare_end
	for start > 0 && full_name_split_identifier_byte(source[start - 1]) {
		start--
	}
	if start == bare_end || !full_name_split_identifier_start(source[start]) {
		return none
	}
	identifier := source[start..method_end]
	if start > 0 && source[start - 1] in [`@`, `$`] {
		mut prefix := start - 1
		if source[prefix] == `@` && prefix > 0 && source[prefix - 1] == `@` {
			prefix--
		}
		if prefix == 0 {
			return identifier
		}
	}
	if start == 0 || source[..start].trim_space().ends_with('.') || source[..start].trim_space().ends_with('::') {
		return identifier
	}
	return none
}

pub fn full_name_split_receiver_identifier(receiver string) ?string {
	if full_name_split_tap_full_name(receiver) {
		return none
	}
	return full_name_split_receiver_method_name(receiver)
}

pub fn is_full_name_split_receiver(receiver string) bool {
	identifier := full_name_split_receiver_identifier(receiver) or { return false }
	return identifier in full_name_split_receiver_names
}

pub fn audit_full_name_split(source string) []FullNameSplitOffense {
	mut offenses := []FullNameSplitOffense{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == 96 {
			position = full_name_split_quoted_end(source, position, source.len)
			continue
		}
		if character == `%` {
			literal_end := full_name_split_percent_literal_end(source, position, source.len)
			if literal_end > position {
				position = literal_end
				continue
			}
		}
		if character == `/` && full_name_split_starts_regexp(source, position) {
			regexp_end := full_name_split_regexp_end(source, position)
			if regexp_end > position {
				position = regexp_end
				continue
			}
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		mut safe_navigation := false
		mut operator := false
		if position + 1 < source.len && source[position..position + 2] == '&.' {
			safe_navigation = true
			operator = true
		} else if character == `.` && (position == 0 || source[position - 1] !in [`&`, `.`]) {
			operator = true
		}
		if !operator {
			position++
			continue
		}
		split_call := full_name_split_parse_split_at(source, position, safe_navigation) or {
			position++
			continue
		}
		outer := full_name_split_parse_outer(source, split_call.split_end, safe_navigation) or {
			position = split_call.split_end
			continue
		}
		if !is_full_name_split_receiver(split_call.receiver) {
			position = outer.end_pos
			continue
		}
		replacement := if outer.safe_navigation {
			'${split_call.receiver}&.then { ::Utils.name_from_full_name(it) }'
		} else {
			'::Utils.name_from_full_name(${split_call.receiver})'
		}
		call := FullNameSplitCall{
			...split_call
			end_pos: outer.end_pos
			method: outer.method
		}
		offenses << FullNameSplitOffense{
			call: call
			begin_pos: call.begin_pos
			end_pos: call.end_pos
			message: full_name_split_message
			replacement: replacement
		}
		position = outer.end_pos
	}
	return offenses
}

pub fn correct_full_name_split(source string) string {
	offenses := audit_full_name_split(source)
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn full_name_split_offense_value(offense FullNameSplitOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':       offense.begin_pos.str()
		'end_pos':         offense.end_pos.str()
		'message':         offense.message
		'method':          offense.call.method
		'receiver':        offense.call.receiver
		'safe_navigation': offense.call.safe_navigation.str()
		'replacement':     offense.replacement
	})
}

fn full_name_split_first_offense(source string, safe_navigation ?bool) ruby.Value {
	for offense in audit_full_name_split(source) {
		if navigation := safe_navigation {
			if offense.call.safe_navigation != navigation {
				continue
			}
		}
		return full_name_split_offense_value(offense)
	}
	return ruby.object_value('NilClass', 'nil')
}

fn full_name_split_outer_call(source string) ?FullNameSplitOuterCall {
	mut position := 0
	for position < source.len {
		mut safe_navigation := false
		if position + 1 < source.len && source[position..position + 2] == '&.' {
			safe_navigation = true
		} else if source[position] != `.` || (position > 0 && source[position - 1] == `&`) {
			position++
			continue
		}
		outer := full_name_split_parse_outer(source, position, safe_navigation) or {
			position++
			continue
		}
		if source[outer.end_pos..].trim_space() == '' {
			return outer
		}
		position++
	}
	return none
}

fn full_name_split_basename_call(source string) bool {
	_ := full_name_split_outer_call(source) or { return false }
	return true
}

fn full_name_split_valid_split_call(source string) ?FullNameSplitCall {
	mut position := 0
	for position < source.len {
		mut safe_navigation := false
		if position + 1 < source.len && source[position..position + 2] == '&.' {
			safe_navigation = true
		} else if source[position] != `.` || (position > 0 && source[position - 1] == `&`) {
			position++
			continue
		}
		call := full_name_split_parse_split_at(source, position, safe_navigation) or {
			position++
			continue
		}
		if source[call.end_pos..].trim_space() == '' {
			return call
		}
		position++
	}
	return none
}

// Ruby method `on_send(node)` at line 46.
pub fn ruby_full_name_split_l46_d1_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return full_name_split_first_offense(source, false)
}

// Ruby method `on_csend(node)` at line 51.
pub fn ruby_full_name_split_l51_d2_on_csend(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return full_name_split_first_offense(source, true)
}

// Ruby method `check_full_name_split(node)` at line 58.
pub fn ruby_full_name_split_l58_d3_check_full_name_split(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return full_name_split_first_offense(source, none)
}

// Ruby method `basename_call?(node)` at line 75.
pub fn ruby_full_name_split_l75_d4_basename_call(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(full_name_split_basename_call(source))
}

// Ruby method `split_call?(node, split_call)` at line 87.
pub fn ruby_full_name_split_l87_d5_split_call(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	outer_source := args[0].as_string()
	split_source := args[1].as_string()
	call := full_name_split_valid_split_call(split_source) or {
		return ruby.bool_value(false)
	}
	outer := full_name_split_outer_call(outer_source) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(outer.safe_navigation == call.safe_navigation)
}

// Ruby method `full_name_receiver?(receiver)` at line 99.
pub fn ruby_full_name_split_l99_d6_full_name_receiver(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name.contains('ConstNode') || args[0].type_name.contains('StrNode') {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(is_full_name_split_receiver(args[0].as_string()))
}

// Ruby method `receiver_identifier(receiver)` at line 108.
pub fn ruby_full_name_split_l108_d7_receiver_identifier(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name.contains('ConstNode') || args[0].type_name.contains('StrNode') {
		return ruby.object_value('NilClass', 'nil')
	}
	identifier := full_name_split_receiver_identifier(args[0].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(identifier)
}

// Ruby method `receiver_method_name(receiver)` at line 118.
pub fn ruby_full_name_split_l118_d8_receiver_method_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	identifier := full_name_split_receiver_method_name(args[0].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(identifier)
}

// Ruby method `replacement(node, receiver)` at line 130.
pub fn ruby_full_name_split_l130_d9_replacement(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	node := args[0].as_string()
	receiver := args[1].as_string()
	outer := full_name_split_outer_call(node) or { FullNameSplitOuterCall{} }
	safe_navigation := outer.safe_navigation
	return ruby.string_value(if safe_navigation {
		'${receiver}&.then { ::Utils.name_from_full_name(it) }'
	} else {
		'::Utils.name_from_full_name(${receiver})'
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for formula or cask full-name parsing that should use `Utils.name_from_full_name`.
// 8:       #
// 9:       # ### Examples
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # name.split("/").last
// 14:       # token.split("/").fetch(-1)
// 15:       #
// 16:       # # good
// 17:       # Utils.name_from_full_name(name)
// 18:       # Utils.name_from_full_name(token)
// 19:       # ```
// 20:       class FullNameSplit < Base
// 21:         extend AutoCorrector
// 22:
// 23:         MSG = "Use `Utils.name_from_full_name` instead of splitting formula or cask full names."
// 24:
// 25:         RESTRICT_ON_SEND = [:last, :fetch].freeze
// 26:         FULL_NAME_RECEIVER_NAMES = %w[
// 27:           cask_full_name
// 28:           cask_token
// 29:           dep_full_name
// 30:           dep_name
// 31:           formula_full_name
// 32:           formula_name
// 33:           full_name
// 34:           name
// 35:           new_full_name
// 36:           new_name
// 37:           old_full_name
// 38:           old_name
// 39:           resolved_full_name
// 40:           service_name
// 41:           token
// 42:         ].freeze
// 43:         private_constant :FULL_NAME_RECEIVER_NAMES
// 44:
// 45:         sig { params(node: RuboCop::AST::SendNode).void }
// 46:         def on_send(node)
// 47:           check_full_name_split(node)
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::SendNode).void }
// 51:         def on_csend(node)
// 52:           check_full_name_split(node)
// 53:         end
// 54:
// 55:         private
// 56:
// 57:         sig { params(node: RuboCop::AST::SendNode).void }
// 58:         def check_full_name_split(node)
// 59:           return unless basename_call?(node)
// 60:
// 61:           split_call = node.receiver
// 62:           return unless split_call.is_a?(RuboCop::AST::SendNode)
// 63:           return unless split_call?(node, split_call)
// 64:
// 65:           receiver = split_call.receiver
// 66:           return unless receiver
// 67:           return unless full_name_receiver?(receiver)
// 68:
// 69:           add_offense(node) do |corrector|
// 70:             corrector.replace(node.source_range, replacement(node, receiver))
// 71:           end
// 72:         end
// 73:
// 74:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 75:         def basename_call?(node)
// 76:           return true if node.method?(:last) && node.arguments.empty?
// 77:           return false unless node.method?(:fetch)
// 78:           return false if node.arguments.length != 1
// 79:
// 80:           argument = node.first_argument
// 81:           argument.is_a?(RuboCop::AST::Node) &&
// 82:             argument.int_type? &&
// 83:             T.cast(argument, RuboCop::AST::IntNode).value == -1
// 84:         end
// 85:
// 86:         sig { params(node: RuboCop::AST::SendNode, split_call: RuboCop::AST::SendNode).returns(T::Boolean) }
// 87:         def split_call?(node, split_call)
// 88:           return false unless split_call.method?(:split)
// 89:           return false if split_call.arguments.length != 1
// 90:           return false if split_call.csend_type? != node.csend_type?
// 91:
// 92:           argument = split_call.first_argument
// 93:           argument.is_a?(RuboCop::AST::Node) &&
// 94:             argument.str_type? &&
// 95:             T.cast(argument, RuboCop::AST::StrNode).value == "/"
// 96:         end
// 97:
// 98:         sig { params(receiver: RuboCop::AST::Node).returns(T::Boolean) }
// 99:         def full_name_receiver?(receiver)
// 100:           return false if receiver.source.match?(/(?:\A|[.])tap(?:\.|&\.)full_name\z/)
// 101:
// 102:           identifier = receiver_identifier(receiver)
// 103:
// 104:           !identifier.nil? && FULL_NAME_RECEIVER_NAMES.include?(identifier)
// 105:         end
// 106:
// 107:         sig { params(receiver: RuboCop::AST::Node).returns(T.nilable(String)) }
// 108:         def receiver_identifier(receiver)
// 109:           case receiver.type
// 110:           when :lvar, :ivar, :cvar, :gvar
// 111:             receiver.source.delete_prefix("@@").delete_prefix("@").delete_prefix("$")
// 112:           when :send, :csend
// 113:             receiver_method_name(T.cast(receiver, RuboCop::AST::SendNode))
// 114:           end
// 115:         end
// 116:
// 117:         sig { params(receiver: RuboCop::AST::SendNode).returns(T.nilable(String)) }
// 118:         def receiver_method_name(receiver)
// 119:           return receiver.method_name.to_s unless receiver.method?(:[])
// 120:           return if receiver.arguments.length != 1
// 121:
// 122:           argument = receiver.first_argument
// 123:           return unless argument.is_a?(RuboCop::AST::Node)
// 124:           return unless argument.str_type?
// 125:
// 126:           T.cast(argument, RuboCop::AST::StrNode).value.to_s
// 127:         end
// 128:
// 129:         sig { params(node: RuboCop::AST::SendNode, receiver: RuboCop::AST::Node).returns(String) }
// 130:         def replacement(node, receiver)
// 131:           if node.csend_type?
// 132:             "#{receiver.source}&.then { ::Utils.name_from_full_name(it) }"
// 133:           else
// 134:             "::Utils.name_from_full_name(#{receiver.source})"
// 135:           end
// 136:         end
// 137:       end
// 138:     end
// 139:   end
// 140: end
