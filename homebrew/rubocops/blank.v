module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/blank.rb`.
pub const blank_message_template = 'Use `%s` instead of `%s`.'

pub struct BlankOperand {
pub:
	source     string
	canonical  string
	has_source bool
}

pub struct BlankMatch {
pub:
	variable1   BlankOperand
	variable2   BlankOperand
	source      string
	begin_pos   int
	end_pos     int
	operator    string
	replacement string
	message     string
}

pub struct BlankOffense {
pub:
	matched     BlankMatch
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct BlankAnalysis {
pub:
	offenses  []BlankOffense
	corrected string
}

struct BlankOperator {
	begin_pos int
	end_pos   int
	source    string
}

fn blank_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `@`, `$`, `.`, `:`, `?`, `!`]
}

fn blank_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn blank_outer_parentheses(source string, begin_pos int, end_pos int) ?(int, int) {
	if end_pos - begin_pos < 2 || source[begin_pos] != `(` || source[end_pos - 1] != `)` {
		return none
	}
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for position := begin_pos; position < end_pos; position++ {
		character := source[position]
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
		} else if character == `(` {
			depth++
		} else if character == `)` {
			depth--
			if depth == 0 && position != end_pos - 1 {
				return none
			}
		}
	}
	if depth != 0 {
		return none
	}
	return blank_trim_range(source, begin_pos + 1, end_pos - 1)
}

fn blank_canonical(source string) string {
	mut start, mut finish := blank_trim_range(source, 0, source.len)
	for {
		inner_start, inner_end := blank_outer_parentheses(source, start, finish) or { break }
		start = inner_start
		finish = inner_end
	}
	mut canonical := ''
	mut quote := u8(0)
	mut escaped := false
	for character in source[start..finish].bytes() {
		if quote != 0 {
			canonical += character.ascii_str()
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
			canonical += character.ascii_str()
		} else if !character.is_space() {
			canonical += character.ascii_str()
		}
	}
	return canonical
}

fn blank_top_level_operator(source string, begin_pos int, end_pos int) ?BlankOperator {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut quote := u8(0)
	mut escaped := false
	mut position := begin_pos
	for position < end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			position++
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			else {}
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
			if position + 1 < end_pos && source[position..position + 2] == '||' {
				return BlankOperator{
					begin_pos: position
					end_pos: position + 2
					source: '||'
				}
			}
			if position + 2 <= end_pos && source[position..position + 2] == 'or' {
				before_word := position == begin_pos || !blank_identifier_byte(source[position - 1])
				after_word := position + 2 == end_pos || !blank_identifier_byte(source[position + 2])
				if before_word && after_word {
					return BlankOperator{
						begin_pos: position
						end_pos: position + 2
						source: 'or'
					}
				}
			}
		}
		position++
	}
	return none
}

fn blank_top_level_equal(source string, begin_pos int, end_pos int) ?int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut quote := u8(0)
	mut escaped := false
	mut position := begin_pos
	for position + 1 < end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			position++
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			else {}
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && source[position..position + 2] == '==' {
			return position
		}
		position++
	}
	return none
}

fn blank_operand(source string, has_source bool) BlankOperand {
	return BlankOperand{
		source: source
		canonical: if has_source { blank_canonical(source) } else { '' }
		has_source: has_source
	}
}

fn blank_receiver(source string, begin_pos int, end_pos int, method string) ?BlankOperand {
	start, finish := blank_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return none
	}
	text := source[start..finish]
	if text == method {
		return blank_operand('', false)
	}
	suffix := '.${method}'
	if !text.ends_with(suffix) {
		return none
	}
	receiver_start, receiver_end := blank_trim_range(source, start, finish - suffix.len)
	if receiver_start >= receiver_end || source[receiver_start] == `!` || source[receiver_end - 1] == `&` {
		return none
	}
	return blank_operand(source[receiver_start..receiver_end], true)
}

fn blank_left_operand(source string, begin_pos int, end_pos int) ?BlankOperand {
	start, finish := blank_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return none
	}
	if source[start] == `!` {
		mut receiver_start := start + 1
		for receiver_start < finish && source[receiver_start].is_space() {
			receiver_start++
		}
		if receiver_start >= finish {
			return none
		}
		return blank_operand(source[receiver_start..finish], true)
	}
	if receiver := blank_receiver(source, start, finish, 'nil?') {
		return receiver
	}
	if equal := blank_top_level_equal(source, start, finish) {
		left_start, left_end := blank_trim_range(source, start, equal)
		right_start, right_end := blank_trim_range(source, equal + 2, finish)
		if left_start >= left_end || right_start >= right_end {
			return none
		}
		if source[right_start..right_end] == 'nil' {
			return blank_operand(source[left_start..left_end], true)
		}
		if source[left_start..left_end] == 'nil' {
			return blank_operand(source[right_start..right_end], true)
		}
	}
	return none
}

fn blank_right_operand(source string, begin_pos int, end_pos int) ?BlankOperand {
	start, finish := blank_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return none
	}
	if receiver := blank_receiver(source, start, finish, 'empty?') {
		return receiver
	}
	if source[start] != `!` {
		return none
	}
	mut after_first := start + 1
	for after_first < finish && source[after_first].is_space() {
		after_first++
	}
	if after_first >= finish || source[after_first] != `!` {
		return none
	}
	mut receiver_start := after_first + 1
	for receiver_start < finish && source[receiver_start].is_space() {
		receiver_start++
	}
	return blank_receiver(source, receiver_start, finish, 'empty?')
}

fn blank_same_operand(first BlankOperand, second BlankOperand) bool {
	return first.has_source == second.has_source && first.canonical == second.canonical
}

pub fn match_blank_expression(source string) ?BlankMatch {
	mut start, mut finish := blank_trim_range(source, 0, source.len)
	for {
		inner_start, inner_end := blank_outer_parentheses(source, start, finish) or { break }
		start = inner_start
		finish = inner_end
	}
	operator := blank_top_level_operator(source, start, finish) or { return none }
	left := blank_left_operand(source, start, operator.begin_pos) or { return none }
	right := blank_right_operand(source, operator.end_pos, finish) or { return none }
	if !blank_same_operand(left, right) {
		return none
	}
	replacement := if left.has_source { '${left.source}.blank?' } else { 'blank?' }
	current := source[start..finish]
	message := blank_message_template.replace_once('%s', replacement).replace_once('%s', current)
	return BlankMatch{
		variable1: left
		variable2: right
		source: current
		begin_pos: start
		end_pos: finish
		operator: operator.source
		replacement: replacement
		message: message
	}
}

fn blank_code_end(line string) int {
	mut quote := u8(0)
	mut escaped := false
	for position, character in line.bytes() {
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
			return position
		}
	}
	return line.len
}

fn blank_append_range(mut ranges [][]int, begin_pos int, end_pos int) {
	if begin_pos < end_pos && !ranges.any(it[0] == begin_pos && it[1] == end_pos) {
		ranges << [begin_pos, end_pos]
	}
}

fn blank_candidate_ranges(line string) [][]int {
	code_end := blank_code_end(line)
	start, finish := blank_trim_range(line, 0, code_end)
	if start >= finish {
		return [][]int{}
	}
	mut ranges := [][]int{}
	blank_append_range(mut ranges, start, finish)
	for keyword in ['if ', 'unless ', 'while ', 'until ', 'return ', 'next ', 'break '] {
		if line[start..finish].starts_with(keyword) {
			candidate_start, candidate_end := blank_trim_range(line, start + keyword.len, finish)
			blank_append_range(mut ranges, candidate_start, candidate_end)
		}
		marker := ' ${keyword}'
		if relative := line[start..finish].index(marker) {
			candidate_start, candidate_end := blank_trim_range(line, start + relative + marker.len, finish)
			blank_append_range(mut ranges, candidate_start, candidate_end)
		}
	}
	mut round_opens := []int{}
	mut square_opens := []int{}
	mut brace_opens := []int{}
	mut quote := u8(0)
	mut escaped := false
	for position := start; position < finish; position++ {
		character := line[position]
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
			continue
		}
		match character {
			`(` { round_opens << position }
			`)` {
				if round_opens.len > 0 {
					open := round_opens.last()
					round_opens.delete_last()
					candidate_start, candidate_end := blank_trim_range(line, open + 1, position)
					blank_append_range(mut ranges, candidate_start, candidate_end)
				}
			}
			`[` { square_opens << position }
			`]` {
				if square_opens.len > 0 {
					open := square_opens.last()
					square_opens.delete_last()
					candidate_start, candidate_end := blank_trim_range(line, open + 1, position)
					blank_append_range(mut ranges, candidate_start, candidate_end)
				}
			}
			`{` { brace_opens << position }
			`}` {
				if brace_opens.len > 0 {
					open := brace_opens.last()
					brace_opens.delete_last()
					candidate_start, candidate_end := blank_trim_range(line, open + 1, position)
					blank_append_range(mut ranges, candidate_start, candidate_end)
				}
			}
			`=` {
				previous := if position > start { line[position - 1] } else { u8(0) }
				next := if position + 1 < finish { line[position + 1] } else { u8(0) }
				if round_opens.len == 0 && square_opens.len == 0 && brace_opens.len == 0 && previous !in [
					`=`,
					`!`,
					`<`,
					`>`,
				] && next !in [`=`, `>`] {
					candidate_start, candidate_end := blank_trim_range(line, position + 1, finish)
					blank_append_range(mut ranges, candidate_start, candidate_end)
				}
			}
			else {}
		}
	}
	return ranges
}

pub fn audit_blank(source string) []BlankOffense {
	mut offenses := []BlankOffense{}
	mut line_start := 0
	for line_start <= source.len {
		newline := source.index_after('\n', line_start) or { source.len }
		line_end := if newline < source.len { newline } else { source.len }
		line := source[line_start..line_end]
		for candidate in blank_candidate_ranges(line) {
			matched_local := match_blank_expression(line[candidate[0]..candidate[1]]) or {
				continue
			}
			begin_pos := line_start + candidate[0] + matched_local.begin_pos
			end_pos := line_start + candidate[0] + matched_local.end_pos
			if offenses.any(it.begin_pos == begin_pos && it.end_pos == end_pos) {
				continue
			}
			matched := BlankMatch{
				...matched_local
				begin_pos: begin_pos
				end_pos: end_pos
			}
			offenses << BlankOffense{
				matched: matched
				begin_pos: begin_pos
				end_pos: end_pos
				message: matched.message
				replacement: matched.replacement
			}
		}
		if newline >= source.len {
			break
		}
		line_start = newline + 1
	}
	offenses.sort_with_compare(fn (a &BlankOffense, b &BlankOffense) int {
		return a.begin_pos - b.begin_pos
	})
	return offenses
}

pub fn correct_blank(source string) string {
	offenses := audit_blank(source)
	mut corrected := source
	for index in 0 .. offenses.len {
		offense := offenses[offenses.len - 1 - index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn blank_match_value(matched BlankMatch, type_name string) ruby.Value {
	return ruby.structured_value(type_name, matched.source, {
		'variable1':   if matched.variable1.has_source { matched.variable1.source } else { 'nil' }
		'variable2':   if matched.variable2.has_source { matched.variable2.source } else { 'nil' }
		'begin_pos':   matched.begin_pos.str()
		'end_pos':     matched.end_pos.str()
		'operator':    matched.operator
		'message':     matched.message
		'replacement': matched.replacement
	})
}

fn blank_offense_value(offense BlankOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}
