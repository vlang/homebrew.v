module cask

import ruby
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `rubocops/cask/stanza_grouping.rb`.
pub const stanza_grouping_missing_line_message = 'stanza groups should be separated by a single empty line'
pub const stanza_grouping_extra_line_message = 'stanzas within the same group should have no lines between them'

pub struct StanzaGroupingStanza {
pub:
	name          string
	begin_pos     int
	end_pos       int
	last_line     int
	is_block      bool
	is_assignment bool
}

pub struct StanzaGroupingOffense {
pub:
	kind              string
	line_index        int
	begin_pos         int
	end_pos           int
	message           string
	replacement_begin int
	replacement_end   int
	replacement       string
}

struct StanzaGroupingLine {
	start       int
	end         int
	newline_end int
	text        string
}

struct StanzaGroupingBlock {
	open_line  int
	close_line int
}

fn stanza_grouping_lines(source string) []StanzaGroupingLine {
	mut lines := []StanzaGroupingLine{}
	mut start := 0
	for start <= source.len {
		newline_offset := source[start..].index_u8(`\n`)
		end := if newline_offset < 0 { source.len } else { start + newline_offset }
		lines << StanzaGroupingLine{
			start: start
			end: end
			newline_end: if end < source.len { end + 1 } else { end }
			text: source[start..end]
		}
		if newline_offset < 0 {
			break
		}
		start = end + 1
	}
	return lines
}

fn stanza_grouping_code_end(text string) int {
	mut quote := u8(0)
	mut escaped := false
	mut interpolation_depth := 0
	for index, character in text.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if quote == `"` && character == `#` && index + 1 < text.len && text[index + 1] == `{` {
				interpolation_depth++
			} else if interpolation_depth > 0 && character == `}` {
				interpolation_depth--
			} else if interpolation_depth == 0 && character == quote {
				quote = 0
			}
		} else if character == `'` || character == `"` || character == u8(96) {
			quote = character
		} else if character == `#` {
			return index
		}
	}
	return text.len
}

fn stanza_grouping_code(line StanzaGroupingLine) string {
	return line.text[..stanza_grouping_code_end(line.text)].trim_right(' \t\r')
}

fn stanza_grouping_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn stanza_grouping_identifier_character(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn stanza_grouping_leading_name(code string) string {
	trimmed := code.trim_space()
	if trimmed == '' {
		return ''
	}
	mut cursor := 0
	if !stanza_grouping_identifier_start(trimmed[cursor]) {
		return ''
	}
	mut name := ''
	for {
		start := cursor
		cursor++
		for cursor < trimmed.len && stanza_grouping_identifier_character(trimmed[cursor]) {
			cursor++
		}
		name = trimmed[start..cursor]
		if cursor < trimmed.len && trimmed[cursor] == `.` && cursor + 1 < trimmed.len && stanza_grouping_identifier_start(trimmed[cursor + 1]) {
			cursor++
			continue
		}
		break
	}
	return name
}

fn stanza_grouping_assignment_rhs(code string) string {
	mut quote := u8(0)
	mut escaped := false
	mut nesting := 0
	for index, character in code.bytes() {
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
		if character == `'` || character == `"` || character == u8(96) {
			quote = character
			continue
		}
		if character in [`(`, `[`, `{`] {
			nesting++
			continue
		}
		if character in [`)`, `]`, `}`] {
			nesting--
			continue
		}
		if character != `=` || nesting != 0 {
			continue
		}
		if (index > 0 && code[index - 1] in [`=`, `!`, `<`, `>`, `~`]) || (index + 1 < code.len && code[index + 1] in [
			`=`,
			`>`,
			`~`,
		]) {
			continue
		}
		left := code[..index].trim_space()
		if left == '' || !stanza_grouping_identifier_start(left[0]) || !left.bytes().all(stanza_grouping_identifier_character(it)) {
			return ''
		}
		return code[index + 1..].trim_space()
	}
	return ''
}

fn stanza_grouping_stanza_name(code string) string {
	rhs := stanza_grouping_assignment_rhs(code)
	if rhs != '' {
		name := stanza_grouping_leading_name(rhs)
		return if name in ['on_arch_conditional', 'on_system_conditional'] { name } else { '' }
	}
	name := stanza_grouping_leading_name(code)
	return if name in stanza_constants.stanza_order { name } else { '' }
}

fn stanza_grouping_heredoc_markers(code string) []string {
	mut markers := []string{}
	mut cursor := 0
	mut quote := u8(0)
	mut escaped := false
	for cursor < code.len {
		character := code[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			cursor++
			continue
		}
		if character == `'` || character == `"` || character == u8(96) {
			quote = character
			cursor++
			continue
		}
		if character == `#` {
			break
		}
		if character != `<` || cursor + 1 >= code.len || code[cursor + 1] != `<` {
			cursor++
			continue
		}
		cursor += 2
		if cursor < code.len && code[cursor] in [`~`, `-`] {
			cursor++
		}
		// Ruby heredoc delimiters immediately follow `<<`, `<<-`, or `<<~`.
		// Whitespace here means this is the ordinary left-shift/append operator.
		if cursor >= code.len || code[cursor].is_space() {
			continue
		}
		mut marker_quote := u8(0)
		if cursor < code.len && code[cursor] in [`'`, `"`] {
			marker_quote = code[cursor]
			cursor++
		}
		start := cursor
		for cursor < code.len && (code[cursor].is_alnum() || code[cursor] == `_`) {
			cursor++
		}
		if cursor > start && (marker_quote == 0 || (cursor < code.len && code[cursor] == marker_quote)) {
			markers << code[start..cursor]
		}
		if marker_quote != 0 && cursor < code.len && code[cursor] == marker_quote {
			cursor++
		}
	}
	return markers
}

fn stanza_grouping_heredoc_end(lines []StanzaGroupingLine, start_line int, markers []string, limit int) int {
	mut line_index := start_line + 1
	for marker in markers {
		mut found := false
		for line_index < limit {
			if lines[line_index].text.trim_space() == marker {
				found = true
				break
			}
			line_index++
		}
		if !found {
			return limit - 1
		}
		line_index++
	}
	return line_index - 1
}

fn stanza_grouping_opens_block(code string) bool {
	trimmed := code.trim_space()
	if trimmed == '' {
		return false
	}
	if trimmed.ends_with(' do') || trimmed.contains(' do |') {
		return true
	}
	for keyword in ['if ', 'unless ', 'case ', 'while ', 'until ', 'for ', 'def ', 'class ', 'module '] {
		if trimmed.starts_with(keyword) {
			return true
		}
	}
	return trimmed == 'begin'
}

fn stanza_grouping_is_end(code string) bool {
	trimmed := code.trim_space()
	return trimmed == 'end' || trimmed.starts_with('end ') || trimmed.starts_with('end;')
}

fn stanza_grouping_find_block_end(lines []StanzaGroupingLine, open_line int, limit int) int {
	mut depth := 1
	mut line_index := open_line + 1
	for line_index < limit {
		code := stanza_grouping_code(lines[line_index])
		markers := stanza_grouping_heredoc_markers(code)
		if markers.len > 0 {
			line_index = stanza_grouping_heredoc_end(lines, line_index, markers, limit) + 1
			continue
		}
		if stanza_grouping_is_end(code) {
			depth--
			if depth == 0 {
				return line_index
			}
		} else if stanza_grouping_opens_block(code) {
			depth++
		}
		line_index++
	}
	return limit - 1
}

fn stanza_grouping_bracket_delta(code string) int {
	mut delta := 0
	mut quote := u8(0)
	mut escaped := false
	for character in code.bytes() {
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
		if character == `'` || character == `"` || character == u8(96) {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			delta++
		} else if character in [`)`, `]`, `}`] {
			delta--
		}
	}
	return delta
}

fn stanza_grouping_statement_end(lines []StanzaGroupingLine, start_line int, limit int) int {
	code := stanza_grouping_code(lines[start_line])
	markers := stanza_grouping_heredoc_markers(code)
	if markers.len > 0 {
		return stanza_grouping_heredoc_end(lines, start_line, markers, limit)
	}
	if stanza_grouping_opens_block(code) {
		return stanza_grouping_find_block_end(lines, start_line, limit)
	}
	mut last_line := start_line
	mut balance := stanza_grouping_bracket_delta(code)
	mut continuation := code.trim_space().ends_with(',') || code.trim_space().ends_with('\\')
	for last_line + 1 < limit && (balance > 0 || continuation) {
		last_line++
		next_code := stanza_grouping_code(lines[last_line])
		balance += stanza_grouping_bracket_delta(next_code)
		continuation = next_code.trim_space().ends_with(',') || next_code.trim_space().ends_with('\\')
		continuation_markers := stanza_grouping_heredoc_markers(next_code)
		if continuation_markers.len > 0 {
			last_line = stanza_grouping_heredoc_end(lines, last_line, continuation_markers, limit)
			break
		}
	}
	return last_line
}

fn stanza_grouping_cask_blocks(lines []StanzaGroupingLine) []StanzaGroupingBlock {
	mut blocks := []StanzaGroupingBlock{}
	mut line_index := 0
	for line_index < lines.len {
		code := stanza_grouping_code(lines[line_index]).trim_space()
		if stanza_grouping_leading_name(code) == 'cask' && stanza_grouping_opens_block(code) {
			close_line := stanza_grouping_find_block_end(lines, line_index, lines.len)
			blocks << StanzaGroupingBlock{
				open_line: line_index
				close_line: close_line
			}
			line_index = close_line + 1
			continue
		}
		line_index++
	}
	return blocks
}

fn stanza_grouping_direct_stanzas(lines []StanzaGroupingLine, open_line int, close_line int) []StanzaGroupingStanza {
	mut stanzas := []StanzaGroupingStanza{}
	mut line_index := open_line + 1
	for line_index < close_line {
		code := stanza_grouping_code(lines[line_index])
		trimmed := code.trim_space()
		if trimmed == '' {
			line_index++
			continue
		}
		last_line := stanza_grouping_statement_end(lines, line_index, close_line)
		name := stanza_grouping_stanza_name(code)
		if name != '' {
			mut begin_pos := lines[line_index].start
			for begin_pos < lines[line_index].end && source_space(lines[line_index].text[begin_pos - lines[line_index].start]) {
				begin_pos++
			}
			end_pos := lines[last_line].start + stanza_grouping_code(lines[last_line]).len
			stanzas << StanzaGroupingStanza{
				name: name
				begin_pos: begin_pos
				end_pos: end_pos
				last_line: last_line
				is_block: stanza_grouping_opens_block(code)
				is_assignment: stanza_grouping_assignment_rhs(code) != ''
			}
		}
		line_index = last_line + 1
	}
	return stanzas
}

fn source_space(character u8) bool {
	return character == ` ` || character == `\t`
}

fn stanza_grouping_group_index(name string) int {
	groups := stanza_constants.stanza_groups()
	for index, group in groups {
		if name in group {
			return index
		}
	}
	return -1
}

pub fn stanza_grouping_same_group(stanza StanzaGroupingStanza, next_stanza StanzaGroupingStanza) bool {
	return stanza_grouping_group_index(stanza.name) == stanza_grouping_group_index(next_stanza.name)
}

pub fn stanza_grouping_index_of_line_after(stanza StanzaGroupingStanza) int {
	// Parser ranges are one-based by line, while ProcessedSource#[] is zero-based.
	return stanza.last_line + 1
}

pub fn stanza_grouping_source_line_after(source string, stanza StanzaGroupingStanza) string {
	lines := stanza_grouping_lines(source)
	line_index := stanza_grouping_index_of_line_after(stanza)
	return if line_index < lines.len { lines[line_index].text } else { '' }
}

pub fn stanza_grouping_empty_line_after(source string, stanza StanzaGroupingStanza) bool {
	return stanza_grouping_source_line_after(source, stanza) == ''
}

pub fn stanza_grouping_missing_line_after(source string, stanza StanzaGroupingStanza,
	next_stanza StanzaGroupingStanza) bool {
	return !(stanza_grouping_same_group(stanza, next_stanza) || stanza_grouping_empty_line_after(source, stanza))
}

pub fn stanza_grouping_extra_line_after(source string, stanza StanzaGroupingStanza,
	next_stanza StanzaGroupingStanza) bool {
	return stanza_grouping_same_group(stanza, next_stanza) && stanza_grouping_empty_line_after(source, stanza)
}

fn stanza_grouping_offense(source string, stanza StanzaGroupingStanza, kind string,
	message string) StanzaGroupingOffense {
	lines := stanza_grouping_lines(source)
	line_index := stanza_grouping_index_of_line_after(stanza)
	line := lines[line_index]
	line_length := if line.text.len > 0 { line.text.len } else { 1 }
	return StanzaGroupingOffense{
		kind: kind
		line_index: line_index
		begin_pos: line.start
		end_pos: line.start + line_length
		message: message
		replacement_begin: line.start
		replacement_end: if kind == 'insert' { line.start } else { line.start + line_length }
		replacement: if kind == 'insert' { '\n' } else { '' }
	}
}

pub fn stanza_grouping_add_offenses(source string, stanzas []StanzaGroupingStanza) []StanzaGroupingOffense {
	mut offenses := []StanzaGroupingOffense{}
	if stanzas.len < 2 {
		return offenses
	}
	for index in 0 .. stanzas.len - 1 {
		stanza := stanzas[index]
		next_stanza := stanzas[index + 1]
		if stanza_grouping_missing_line_after(source, stanza, next_stanza) {
			offenses << stanza_grouping_offense(source, stanza, 'insert', stanza_grouping_missing_line_message)
		} else if stanza_grouping_extra_line_after(source, stanza, next_stanza) {
			offenses << stanza_grouping_offense(source, stanza, 'remove', stanza_grouping_extra_line_message)
		}
	}
	return offenses
}

pub fn stanza_grouping_toplevel_stanzas(source string) []StanzaGroupingStanza {
	lines := stanza_grouping_lines(source)
	blocks := stanza_grouping_cask_blocks(lines)
	if blocks.len == 0 {
		return []StanzaGroupingStanza{}
	}
	return stanza_grouping_direct_stanzas(lines, blocks[0].open_line, blocks[0].close_line)
}

pub fn audit_stanza_grouping(source string) []StanzaGroupingOffense {
	lines := stanza_grouping_lines(source)
	mut offenses := []StanzaGroupingOffense{}
	for block in stanza_grouping_cask_blocks(lines) {
		toplevel := stanza_grouping_direct_stanzas(lines, block.open_line, block.close_line)
		offenses << stanza_grouping_add_offenses(source, toplevel)
		for stanza in toplevel {
			if stanza.name !in stanza_constants.on_system_methods {
				continue
			}
			inner_open_line := stanza.last_line - source[stanza.begin_pos..stanza.end_pos].count('\n')
			if stanza.last_line <= inner_open_line {
				continue
			}
			// CaskHelp#inner_stanzas selects only direct SendNode children of the
			// begin body; nested BlockNode and assignment stanzas are intentionally omitted.
			inner := stanza_grouping_direct_stanzas(lines, inner_open_line, stanza.last_line).filter(!it.is_block && !it.is_assignment)
			offenses << stanza_grouping_add_offenses(source, inner)
		}
	}
	offenses.sort_with_compare(fn (left &StanzaGroupingOffense, right &StanzaGroupingOffense) int {
		return left.begin_pos - right.begin_pos
	})
	return offenses
}

pub fn correct_stanza_grouping(source string) string {
	mut offenses := audit_stanza_grouping(source)
	offenses.sort_with_compare(fn (left &StanzaGroupingOffense, right &StanzaGroupingOffense) int {
		return right.replacement_begin - left.replacement_begin
	})
	mut corrected := source
	for offense in offenses {
		corrected = corrected[..offense.replacement_begin] + offense.replacement + corrected[offense.replacement_end..]
	}
	return corrected
}

fn stanza_grouping_source(args []ruby.Value) string {
	if args.len == 0 {
		return ''
	}
	if args[0].type_name == 'Array' && args[0].array_data.len > 0 {
		return args[0].array_data[0].attributes['document_source'] or { args[0].as_string() }
	}
	return args[0].attributes['document_source'] or {
		args[0].attributes['source'] or { args[0].as_string() }
	}
}

fn stanza_grouping_stanza_value(source string, stanza StanzaGroupingStanza) ruby.Value {
	return ruby.structured_value('RuboCop::Cask::AST::Stanza', source[stanza.begin_pos..stanza.end_pos], {
		'name':            stanza.name
		'begin_pos':       stanza.begin_pos.str()
		'end_pos':         stanza.end_pos.str()
		'last_line':       stanza.last_line.str()
		'is_block':        stanza.is_block.str()
		'is_assignment':   stanza.is_assignment.str()
		'document_source': source
	})
}

fn stanza_grouping_stanza_from_value(value ruby.Value) StanzaGroupingStanza {
	return StanzaGroupingStanza{
		name: value.attributes['name'] or { stanza_grouping_stanza_name(value.as_string()) }
		begin_pos: (value.attributes['begin_pos'] or { '0' }).int()
		end_pos: (value.attributes['end_pos'] or { value.as_string().len.str() }).int()
		last_line: (value.attributes['last_line'] or { value.as_string().count('\n').str() }).int()
		is_block: (value.attributes['is_block'] or { 'false' }).bool()
		is_assignment: (value.attributes['is_assignment'] or { 'false' }).bool()
	}
}

fn stanza_grouping_offense_value(offense StanzaGroupingOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':              offense.kind
		'line_index':        offense.line_index.str()
		'begin_pos':         offense.begin_pos.str()
		'end_pos':           offense.end_pos.str()
		'message':           offense.message
		'replacement_begin': offense.replacement_begin.str()
		'replacement_end':   offense.replacement_end.str()
		'replacement':       offense.replacement
	})
}

fn stanza_grouping_offense_values(offenses []StanzaGroupingOffense) ruby.Value {
	return ruby.array_value(offenses.map(stanza_grouping_offense_value(it)))
}
