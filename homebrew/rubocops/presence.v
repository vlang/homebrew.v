module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/presence.rb`.
pub struct PresenceNode {
pub:
	kind                 string
	source               string
	begin_pos            int
	end_pos              int
	receiver             string
	method_name          string
	arguments            []string
	parenthesized        bool
	arithmetic_operation bool
}

pub struct PresenceConditional {
pub:
	source       string
	begin_pos    int
	end_pos      int
	condition    PresenceNode
	if_branch    PresenceNode
	else_branch  PresenceNode
	keyword      string
	ternary      bool
	elsif        bool
	left_sibling bool
}

pub struct PresenceMatch {
pub:
	matched  bool
	receiver PresenceNode
	other    PresenceNode
}

pub struct PresenceOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct PresenceAnalysis {
pub:
	offenses  []PresenceOffense
	corrected string
}

struct PresenceLine {
	start       int
	end         int
	newline_end int
	text        string
}

fn presence_lines(source string) []PresenceLine {
	mut lines := []PresenceLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		lines << PresenceLine{
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			text: source[start..end]
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return lines
}

fn presence_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn presence_expression_lines_are_begin(source string) bool {
	lines := source.split('\n').map(it.trim_space()).filter(it != '')
	if lines.len <= 1 {
		return source.contains(';')
	}
	for line in lines[1..] {
		if !line.starts_with('.') {
			return true
		}
	}
	return false
}

fn presence_top_level_arithmetic(source string) bool {
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	for index, character in source.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`+`, `*`, `/`, `%` {
				if round == 0 && square == 0 && brace == 0 && index > 0 && index + 1 < source.len && source[index - 1].is_space() && source[index + 1].is_space() {
					return true
				}
			}
			`-` {
				if round == 0 && square == 0 && brace == 0 && index > 0 && index + 1 < source.len && source[index - 1].is_space() && source[index + 1].is_space() {
					return true
				}
			}
			else {}
		}
	}
	return false
}

fn presence_split_arguments(source string) []string {
	mut arguments := []string{}
	mut start := 0
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	for index, character in source.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`,` {
				if round == 0 && square == 0 && brace == 0 {
					argument := source[start..index].trim_space()
					if argument != '' {
						arguments << argument
					}
					start = index + 1
				}
			}
			else {}
		}
	}
	argument := source[start..].trim_space()
	if argument != '' {
		arguments << argument
	}
	return arguments
}

fn presence_parse_send(source string, begin_pos int, end_pos int) PresenceNode {
	start, finish := presence_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return PresenceNode{ kind: 'nil', source: 'nil', begin_pos: start, end_pos: finish }
	}
	raw := source[start..finish]
	if raw == 'nil' {
		return PresenceNode{ kind: 'nil', source: raw, begin_pos: start, end_pos: finish }
	}
	if presence_expression_lines_are_begin(raw) {
		return PresenceNode{ kind: 'begin', source: raw, begin_pos: start, end_pos: finish }
	}
	if raw.contains(' rescue ') {
		return PresenceNode{ kind: 'rescue', source: raw, begin_pos: start, end_pos: finish }
	}
	if raw.contains(' while ') {
		return PresenceNode{ kind: 'while', source: raw, begin_pos: start, end_pos: finish }
	}
	if raw.contains(' if ') || raw.contains(' unless ') {
		return PresenceNode{ kind: 'if', source: raw, begin_pos: start, end_pos: finish }
	}
	if raw[0].is_digit() || (raw[0] == `-` && raw.len > 1 && raw[1].is_digit()) {
		return PresenceNode{ kind: 'literal', source: raw, begin_pos: start, end_pos: finish }
	}
	if presence_top_level_arithmetic(raw) {
		return PresenceNode{
			kind: 'send'
			source: raw
			begin_pos: start
			end_pos: finish
			method_name: raw
			arithmetic_operation: true
		}
	}
	if raw.ends_with(']') && raw.contains('[') {
		return PresenceNode{
			kind: 'send'
			source: raw
			begin_pos: start
			end_pos: finish
			method_name: '[]'
		}
	}
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	mut argument_space := -1
	mut parenthesis := -1
	for index, character in raw.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		if character == `(` && round == 0 && square == 0 && brace == 0 && parenthesis < 0 {
			parenthesis = index
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			` `, `\t`, `\n` {
				if round == 0 && square == 0 && brace == 0 && argument_space < 0 {
					mut next := index
					for next < raw.len && raw[next].is_space() {
						next++
					}
					if next < raw.len && raw[next] != `.` {
						argument_space = index
					}
				}
			}
			else {}
		}
	}
	if parenthesis > 0 && raw.ends_with(')') {
		return PresenceNode{
			kind: 'send'
			source: raw
			begin_pos: start
			end_pos: finish
			method_name: raw[..parenthesis].trim_space()
			arguments: presence_split_arguments(raw[parenthesis + 1..raw.len - 1])
			parenthesized: true
		}
	}
	if argument_space > 0 {
		method := raw[..argument_space].trim_space()
		return PresenceNode{
			kind: 'send'
			source: raw
			begin_pos: start
			end_pos: finish
			method_name: method
			arguments: presence_split_arguments(raw[argument_space..])
		}
	}
	return PresenceNode{
		kind: 'send'
		source: raw
		begin_pos: start
		end_pos: finish
		method_name: raw
	}
}

fn presence_condition_node(source string, begin_pos int, end_pos int) PresenceNode {
	start, finish := presence_trim_range(source, begin_pos, end_pos)
	mut raw := source[start..finish]
	mut negated := false
	if raw.starts_with('!') {
		negated = true
		raw = raw[1..].trim_space()
	}
	for method in ['present?', 'blank?'] {
		suffix := '.${method}'
		if raw.ends_with(suffix) {
			receiver := raw[..raw.len - suffix.len].trim_right(' \t\r\n')
			return PresenceNode{
				kind: if negated { 'negative_send' } else { 'send' }
				source: source[start..finish]
				begin_pos: start
				end_pos: finish
				receiver: receiver
				method_name: method
			}
		}
		if raw == method {
			return PresenceNode{
				kind: if negated { 'negative_send' } else { 'send' }
				source: source[start..finish]
				begin_pos: start
				end_pos: finish
				method_name: method
			}
		}
	}
	return presence_parse_send(source, start, finish)
}

fn presence_structural_source(source string) string {
	mut result := ''
	mut quote := u8(0)
	mut escaped := false
	for character in source.bytes() {
		if escaped {
			result += character.ascii_str()
			escaped = false
			continue
		}
		if character == `\\` {
			result += character.ascii_str()
			escaped = true
			continue
		}
		if quote != 0 {
			result += character.ascii_str()
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			result += character.ascii_str()
		} else if !character.is_space() {
			result += character.ascii_str()
		}
	}
	return result
}

fn presence_same_expression(left string, right string) bool {
	return presence_structural_source(left) == presence_structural_source(right)
}

fn presence_find_ternary(source string) ?(int, int) {
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	mut question := -1
	for index, character in source.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`?` {
				if round == 0 && square == 0 && brace == 0 && index > 0 && source[index - 1].is_space() {
					question = index
				}
			}
			`:` {
				if question >= 0 && round == 0 && square == 0 && brace == 0 {
					return question, index
				}
			}
			else {}
		}
	}
	return none
}

fn presence_word_at(line string, word string) int {
	mut start := 0
	for start <= line.len - word.len {
		index := line.index_after(word, start) or { return -1 }
		before_ok := index == 0 || !(line[index - 1].is_alnum() || line[index - 1] == `_`)
		after := index + word.len
		after_ok := after >= line.len || !(line[after].is_alnum() || line[after] == `_`)
		if before_ok && after_ok {
			return index
		}
		start = index + word.len
	}
	return -1
}

fn presence_deindented_node(source string, begin_pos int, end_pos int) PresenceNode {
	start, finish := presence_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return PresenceNode{ kind: 'nil', source: 'nil', begin_pos: start, end_pos: finish }
	}
	raw := source[start..finish]
	lines := raw.split('\n')
	mut value := raw
	if lines.len > 0 {
		indent := lines[0].len - lines[0].trim_left(' \t').len
		mut normalized := []string{}
		for line in lines {
			normalized << if line.len >= indent { line[indent..] } else { line.trim_left(' \t') }
		}
		value = normalized.join('\n').trim_space()
	}
	return presence_parse_send(value, 0, value.len)
}

fn presence_parse_ternary(source string, question int, colon int) PresenceConditional {
	start, finish := presence_trim_range(source, 0, source.len)
	return PresenceConditional{
		source: source[start..finish]
		begin_pos: start
		end_pos: finish
		condition: presence_condition_node(source, start, question)
		if_branch: presence_deindented_node(source, question + 1, colon)
		else_branch: presence_deindented_node(source, colon + 1, finish)
		keyword: 'if'
		ternary: true
	}
}

fn presence_parse_block(source string, lines []PresenceLine, header_index int, keyword_offset int,
	keyword string, closing_index int) PresenceConditional {
	header := lines[header_index]
	keyword_begin := header.start + keyword_offset
	mut condition_last := header_index
	for condition_last + 1 < closing_index && lines[condition_last + 1].text.trim_space().starts_with('.') {
		condition_last++
	}
	condition_begin := keyword_begin + keyword.len
	condition_end := lines[condition_last].end
	mut separator := -1
	mut elsif := false
	for index := condition_last + 1; index < closing_index; index++ {
		trimmed := lines[index].text.trim_space()
		if trimmed == 'else' || trimmed.starts_with('elsif ') {
			separator = index
			elsif = trimmed.starts_with('elsif ')
			break
		}
	}
	then_begin := if condition_last + 1 < closing_index {
		lines[condition_last + 1].start
	} else {
		condition_end
	}
	then_end := if separator >= 0 { lines[separator].start } else { lines[closing_index].start }
	else_begin := if separator >= 0 { lines[separator].newline_end } else { then_end }
	else_end := lines[closing_index].start
	physical_then := presence_deindented_node(source, then_begin, then_end)
	physical_else := presence_deindented_node(source, else_begin, else_end)
	if_branch := if keyword == 'unless' { physical_else } else { physical_then }
	else_branch := if keyword == 'unless' { physical_then } else { physical_else }
	end_pos := lines[closing_index].start + (lines[closing_index].text.index('end') or { 0 }) + 3
	return PresenceConditional{
		source: source[keyword_begin..end_pos]
		begin_pos: keyword_begin
		end_pos: end_pos
		condition: presence_condition_node(source, condition_begin, condition_end)
		if_branch: if_branch
		else_branch: else_branch
		keyword: keyword
		elsif: elsif
		left_sibling: header.text[..keyword_offset].trim_space() != ''
	}
}

fn presence_parse_modifier(source string, line PresenceLine, keyword_offset int,
	keyword string) PresenceConditional {
	line_start, line_end := presence_trim_range(source, line.start, line.end)
	keyword_begin := line.start + keyword_offset
	physical_then := presence_parse_send(source, line_start, keyword_begin)
	physical_else := PresenceNode{ kind: 'nil', source: 'nil', begin_pos: keyword_begin, end_pos: keyword_begin }
	return PresenceConditional{
		source: source[line_start..line_end]
		begin_pos: line_start
		end_pos: line_end
		condition: presence_condition_node(source, keyword_begin + keyword.len, line_end)
		if_branch: if keyword == 'unless' { physical_else } else { physical_then }
		else_branch: if keyword == 'unless' { physical_then } else { physical_else }
		keyword: keyword
	}
}

pub fn parse_presence_conditionals(source string) []PresenceConditional {
	if question, colon := presence_find_ternary(source) {
		return [presence_parse_ternary(source, question, colon)]
	}
	lines := presence_lines(source)
	mut conditionals := []PresenceConditional{}
	mut index := 0
	for index < lines.len {
		line := lines[index]
		mut keyword := 'if'
		mut offset := presence_word_at(line.text, 'if')
		unless_offset := presence_word_at(line.text, 'unless')
		if offset < 0 || (unless_offset >= 0 && unless_offset < offset) {
			keyword = 'unless'
			offset = unless_offset
		}
		if offset < 0 || line.text.trim_space().starts_with('elsif ') {
			index++
			continue
		}
		mut closing := -1
		for candidate := index + 1; candidate < lines.len; candidate++ {
			if lines[candidate].text.trim_space() == 'end' {
				closing = candidate
				break
			}
		}
		if closing >= 0 {
			conditionals << presence_parse_block(source, lines, index, offset, keyword, closing)
			index = closing + 1
		} else if offset > 0 {
			conditionals << presence_parse_modifier(source, line, offset, keyword)
			index++
		} else {
			index++
		}
	}
	return conditionals
}

fn presence_match(node PresenceConditional, negative bool) PresenceMatch {
	condition := node.condition
	if (condition.kind == 'negative_send') != negative || condition.method_name !in [
		'present?',
		'blank?',
	] {
		return PresenceMatch{}
	}
	if condition.receiver == '' {
		return PresenceMatch{ matched: true }
	}
	if condition.method_name == 'present?' {
		receiver_branch := if negative { node.else_branch } else { node.if_branch }
		other := if negative { node.if_branch } else { node.else_branch }
		if presence_same_expression(condition.receiver, receiver_branch.source) {
			return PresenceMatch{
				matched: true
				receiver: presence_parse_send(condition.receiver, 0, condition.receiver.len)
				other: other
			}
		}
	} else {
		receiver_branch := if negative { node.if_branch } else { node.else_branch }
		other := if negative { node.else_branch } else { node.if_branch }
		if presence_same_expression(condition.receiver, receiver_branch.source) {
			return PresenceMatch{
				matched: true
				receiver: presence_parse_send(condition.receiver, 0, condition.receiver.len)
				other: other
			}
		}
	}
	return PresenceMatch{}
}

fn presence_ignore_if_node(node PresenceConditional) bool {
	return node.elsif
}

fn presence_ignore_other_node(node PresenceNode) bool {
	return node.kind in ['if', 'rescue', 'while', 'begin']
}

fn presence_build_source_for_or_method(other PresenceNode) string {
	if other.parenthesized || other.method_name == '[]' || other.arithmetic_operation || other.arguments.len == 0 {
		return ' || ${other.source}'
	}
	return ' || ${presence_method_range(other)}(${other.arguments.join(', ')})'
}

fn presence_method_range(node PresenceNode) string {
	if node.arguments.len == 0 {
		return node.source
	}
	first_argument := node.arguments[0]
	argument_index := node.source.index(first_argument) or { return node.method_name }
	return node.source[..argument_index].trim_right(' \t\r\n')
}

fn presence_replacement(receiver PresenceNode, other PresenceNode, left_sibling bool) string {
	or_source := if other.kind == 'send' {
		presence_build_source_for_or_method(other)
	} else if other.kind == 'nil' {
		''
	} else {
		' || ${other.source}'
	}
	replaced := '${receiver.source}.presence${or_source}'
	return if left_sibling { '(${replaced})' } else { replaced }
}

fn presence_current(node PresenceConditional) string {
	if !node.ternary && node.source.contains('\n') {
		return '${node.keyword} ${node.condition.source} ... end'
	}
	mut current := node.source
	for current.contains('\n') {
		newline := current.index('\n') or { break }
		mut after := newline + 1
		for after < current.len && current[after].is_space() {
			after++
		}
		current = current[..newline] + ' ' + current[after..]
	}
	return current
}

fn presence_message_clean(value string) string {
	return value.trim_left(' \t\r\n').replace('\n', '')
}

fn presence_message(node PresenceConditional, receiver PresenceNode, other PresenceNode) string {
	prefer := presence_message_clean(presence_replacement(receiver, other, node.left_sibling))
	current := presence_message_clean(presence_current(node))
	return 'Use `${prefer}` instead of `${current}`.'
}

fn presence_register_offense(node PresenceConditional, receiver PresenceNode,
	other PresenceNode) PresenceOffense {
	return PresenceOffense{
		begin_pos: node.begin_pos
		end_pos: node.end_pos
		message: presence_message(node, receiver, other)
		replacement: presence_replacement(receiver, other, node.left_sibling)
	}
}

fn presence_apply_corrections(source string, offenses []PresenceOffense) string {
	mut corrected := source
	mut sorted := offenses.clone()
	sorted.sort(a.begin_pos > b.begin_pos)
	for offense in sorted {
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

pub fn analyze_presence(source string) !PresenceAnalysis {
	mut offenses := []PresenceOffense{}
	for node in parse_presence_conditionals(source) {
		if presence_ignore_if_node(node) {
			continue
		}
		mut matched := presence_match(node, false)
		if !matched.matched {
			matched = presence_match(node, true)
		}
		if !matched.matched || matched.receiver.source == '' || presence_ignore_other_node(matched.other) {
			continue
		}
		offenses << presence_register_offense(node, matched.receiver, matched.other)
	}
	return PresenceAnalysis{
		offenses: offenses
		corrected: presence_apply_corrections(source, offenses)
	}
}

fn presence_match_value(matched PresenceMatch) ruby.Value {
	return ruby.map_value({
		'matched':  ruby.bool_value(matched.matched)
		'receiver': ruby.string_value(matched.receiver.source)
		'other':    ruby.string_value(matched.other.source)
	})
}

pub fn presence_analysis_value(analysis PresenceAnalysis) ruby.Value {
	offenses := analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
	}))
	return ruby.map_value({
		'offenses':  ruby.array_value(offenses)
		'corrected': ruby.string_value(analysis.corrected)
	})
}
