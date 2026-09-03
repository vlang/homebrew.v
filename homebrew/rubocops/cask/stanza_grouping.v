module cask

import brew_runtime
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `rubocops/cask/stanza_grouping.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn stanza_grouping_source(args []brew_runtime.Value) string {
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

fn stanza_grouping_stanza_value(source string, stanza StanzaGroupingStanza) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cask::AST::Stanza', source[stanza.begin_pos..stanza.end_pos], {
		'name':            stanza.name
		'begin_pos':       stanza.begin_pos.str()
		'end_pos':         stanza.end_pos.str()
		'last_line':       stanza.last_line.str()
		'is_block':        stanza.is_block.str()
		'is_assignment':   stanza.is_assignment.str()
		'document_source': source
	})
}

fn stanza_grouping_stanza_from_value(value brew_runtime.Value) StanzaGroupingStanza {
	return StanzaGroupingStanza{
		name: value.attributes['name'] or { stanza_grouping_stanza_name(value.as_string()) }
		begin_pos: (value.attributes['begin_pos'] or { '0' }).int()
		end_pos: (value.attributes['end_pos'] or { value.as_string().len.str() }).int()
		last_line: (value.attributes['last_line'] or { value.as_string().count('\n').str() }).int()
		is_block: (value.attributes['is_block'] or { 'false' }).bool()
		is_assignment: (value.attributes['is_assignment'] or { 'false' }).bool()
	}
}

fn stanza_grouping_offense_value(offense StanzaGroupingOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
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

fn stanza_grouping_offense_values(offenses []StanzaGroupingOffense) brew_runtime.Value {
	return brew_runtime.array_value(offenses.map(stanza_grouping_offense_value(it)))
}

// Ruby method `on_cask(cask_block)` at line 21.
pub fn ruby_stanza_grouping_l21_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return stanza_grouping_offense_values(audit_stanza_grouping(stanza_grouping_source(args)))
}

// Ruby attr_reader `attr_reader :cask_block` at line 38.
pub fn ruby_stanza_grouping_l38_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := stanza_grouping_source(args)
	return brew_runtime.structured_value('RuboCop::Cask::AST::CaskBlock', source, {
		'source': source
	})
}

// Ruby def_delegators `def_delegators :cask_block, :cask_node, :toplevel_stanzas` at line 40.
pub fn ruby_stanza_grouping_l40_d3_cask_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := stanza_grouping_source(args)
	return brew_runtime.structured_value('RuboCop::AST::BlockNode', source, {
		'name':   'cask'
		'source': source
	})
}

// Ruby def_delegators `def_delegators :cask_block, :cask_node, :toplevel_stanzas` at line 40.
pub fn ruby_stanza_grouping_l40_d4_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	source := stanza_grouping_source(args)
	return brew_runtime.array_value(stanza_grouping_toplevel_stanzas(source).map(stanza_grouping_stanza_value(source, it)))
}

// Ruby method `add_offenses(stanzas)` at line 43.
pub fn ruby_stanza_grouping_l43_d5_add_offenses(args ...brew_runtime.Value) brew_runtime.Value {
	source := stanza_grouping_source(args)
	stanzas := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].array_data.map(stanza_grouping_stanza_from_value(it))
	} else {
		stanza_grouping_toplevel_stanzas(source)
	}
	return stanza_grouping_offense_values(stanza_grouping_add_offenses(source, stanzas))
}

// Ruby method `line_ops` at line 56.
pub fn ruby_stanza_grouping_l56_d6_line_ops(args ...brew_runtime.Value) brew_runtime.Value {
	mut operations := map[string]brew_runtime.Value{}
	for offense in audit_stanza_grouping(stanza_grouping_source(args)) {
		operations[offense.line_index.str()] = brew_runtime.object_value('Symbol', ':${offense.kind}')
	}
	return brew_runtime.map_value(operations)
}

// Ruby method `missing_line_after?(stanza, next_stanza)` at line 61.
pub fn ruby_stanza_grouping_l61_d7_missing_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return brew_runtime.bool_value(stanza_grouping_missing_line_after(source, stanza_grouping_stanza_from_value(args[0]), stanza_grouping_stanza_from_value(args[1])))
}

// Ruby method `extra_line_after?(stanza, next_stanza)` at line 67.
pub fn ruby_stanza_grouping_l67_d8_extra_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return brew_runtime.bool_value(stanza_grouping_extra_line_after(source, stanza_grouping_stanza_from_value(args[0]), stanza_grouping_stanza_from_value(args[1])))
}

// Ruby method `empty_line_after?(stanza)` at line 73.
pub fn ruby_stanza_grouping_l73_d9_empty_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return brew_runtime.bool_value(stanza_grouping_empty_line_after(source, stanza_grouping_stanza_from_value(args[0])))
}

// Ruby method `source_line_after(stanza)` at line 78.
pub fn ruby_stanza_grouping_l78_d10_source_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return brew_runtime.string_value(stanza_grouping_source_line_after(source, stanza_grouping_stanza_from_value(args[0])))
}

// Ruby method `index_of_line_after(stanza)` at line 83.
pub fn ruby_stanza_grouping_l83_d11_index_of_line_after(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.int_value(0)
	}
	return brew_runtime.int_value(stanza_grouping_index_of_line_after(stanza_grouping_stanza_from_value(args[0])))
}

// Ruby method `add_offense_missing_line(stanza)` at line 88.
pub fn ruby_stanza_grouping_l88_d12_add_offense_missing_line(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return stanza_grouping_offense_value(stanza_grouping_offense(source, stanza_grouping_stanza_from_value(args[0]), 'insert', stanza_grouping_missing_line_message))
}

// Ruby method `add_offense_extra_line(stanza)` at line 97.
pub fn ruby_stanza_grouping_l97_d13_add_offense_extra_line(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	source := args[0].attributes['document_source'] or { stanza_grouping_source(args) }
	return stanza_grouping_offense_value(stanza_grouping_offense(source, stanza_grouping_stanza_from_value(args[0]), 'remove', stanza_grouping_extra_line_message))
}

// Ruby method `add_offense(line_index, message:, &block)` at line 106.
pub fn ruby_stanza_grouping_l106_d14_add_offense(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	source := args[0].as_string()
	line_index := int(args[1].as_int() or { 0 })
	lines := stanza_grouping_lines(source)
	if line_index < 0 || line_index >= lines.len {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	line := lines[line_index]
	line_length := if line.text.len > 0 { line.text.len } else { 1 }
	return stanza_grouping_offense_value(StanzaGroupingOffense{
		kind: 'custom'
		line_index: line_index
		begin_pos: line.start
		end_pos: line.start + line_length
		message: args[2].as_string()
		replacement_begin: line.start
		replacement_end: line.start
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks that a cask's stanzas are grouped correctly, including nested within `on_*` blocks.
// 10:       # @see https://docs.brew.sh/Cask-Cookbook#stanza-order
// 11:       class StanzaGrouping < Base
// 12:         extend Forwardable
// 13:         extend AutoCorrector
// 14:         include CaskHelp
// 15:         include RangeHelp
// 16:
// 17:         MISSING_LINE_MSG = "stanza groups should be separated by a single empty line"
// 18:         EXTRA_LINE_MSG = "stanzas within the same group should have no lines between them"
// 19:
// 20:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 21:         def on_cask(cask_block)
// 22:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 23:           @line_ops = T.let({}, T.nilable(T::Hash[Integer, Symbol]))
// 24:           cask_stanzas = cask_block.toplevel_stanzas
// 25:           add_offenses(cask_stanzas)
// 26:
// 27:           return if (on_blocks = on_system_methods(cask_stanzas)).none?
// 28:
// 29:           on_blocks.map(&:method_node).select(&:block_type?).each do |on_block|
// 30:             stanzas = inner_stanzas(T.cast(on_block, RuboCop::AST::BlockNode), processed_source.comments)
// 31:             add_offenses(stanzas)
// 32:           end
// 33:         end
// 34:
// 35:         private
// 36:
// 37:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 38:         attr_reader :cask_block
// 39:
// 40:         def_delegators :cask_block, :cask_node, :toplevel_stanzas
// 41:
// 42:         sig { params(stanzas: T::Array[RuboCop::Cask::AST::Stanza]).void }
// 43:         def add_offenses(stanzas)
// 44:           stanzas.each_cons(2) do |stanza, next_stanza|
// 45:             next if !stanza || !next_stanza
// 46:
// 47:             if missing_line_after?(stanza, next_stanza)
// 48:               add_offense_missing_line(stanza)
// 49:             elsif extra_line_after?(stanza, next_stanza)
// 50:               add_offense_extra_line(stanza)
// 51:             end
// 52:           end
// 53:         end
// 54:
// 55:         sig { returns(T::Hash[Integer, Symbol]) }
// 56:         def line_ops
// 57:           @line_ops || raise("Call to line_ops before it has been initialized")
// 58:         end
// 59:
// 60:         sig { params(stanza: RuboCop::Cask::AST::Stanza, next_stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 61:         def missing_line_after?(stanza, next_stanza)
// 62:           !(stanza.same_group?(next_stanza) ||
// 63:             empty_line_after?(stanza))
// 64:         end
// 65:
// 66:         sig { params(stanza: RuboCop::Cask::AST::Stanza, next_stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 67:         def extra_line_after?(stanza, next_stanza)
// 68:           stanza.same_group?(next_stanza) &&
// 69:             empty_line_after?(stanza)
// 70:         end
// 71:
// 72:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(T::Boolean) }
// 73:         def empty_line_after?(stanza)
// 74:           source_line_after(stanza).empty?
// 75:         end
// 76:
// 77:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(String) }
// 78:         def source_line_after(stanza)
// 79:           processed_source[index_of_line_after(stanza)]
// 80:         end
// 81:
// 82:         sig { params(stanza: RuboCop::Cask::AST::Stanza).returns(Integer) }
// 83:         def index_of_line_after(stanza)
// 84:           stanza.source_range.last_line
// 85:         end
// 86:
// 87:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 88:         def add_offense_missing_line(stanza)
// 89:           line_index = index_of_line_after(stanza)
// 90:           line_ops[line_index] = :insert
// 91:           add_offense(line_index, message: MISSING_LINE_MSG) do |corrector|
// 92:             corrector.insert_before(@range, "\n")
// 93:           end
// 94:         end
// 95:
// 96:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 97:         def add_offense_extra_line(stanza)
// 98:           line_index = index_of_line_after(stanza)
// 99:           line_ops[line_index] = :remove
// 100:           add_offense(line_index, message: EXTRA_LINE_MSG) do |corrector|
// 101:             corrector.remove(@range)
// 102:           end
// 103:         end
// 104:
// 105:         sig { params(line_index: Integer, message: String, block: T.proc.params(corrector: RuboCop::Cop::Corrector).void).void }
// 106:         def add_offense(line_index, message:, &block)
// 107:           line_length = [processed_source[line_index].size, 1].max
// 108:           @range = T.let(
// 109:             source_range(processed_source.buffer, line_index + 1, 0, line_length),
// 110:             T.nilable(Parser::Source::Range),
// 111:           )
// 112:           super(@range, message:, &block)
// 113:         end
// 114:       end
// 115:     end
// 116:   end
// 117: end
