module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/unreferenced_let.rb`.
const unreferenced_let_definition_methods = ['let', 'let!', 'subject']
const unreferenced_let_reserved_names = ['cop_config', 'other_cops', 'cop_options', 'gem_versions']
const unreferenced_let_dispatch_methods = ['send', 'public_send', '__send__', 'try', 'try!', 'method',
	'public_method', 'respond_to?']
const unreferenced_let_shared_consumers = ['it_behaves_like', 'it_should_behave_like',
	'include_examples', 'include_context']
const unreferenced_let_shared_definitions = ['shared_examples', 'shared_examples_for',
	'shared_context']
const unreferenced_let_message = 'Remove unreferenced `let(:%s)` -- its name is never used, so the block never runs.'

struct UnreferencedLetLine {
pub:
	text        string
	start       int
	end         int
	newline_end int
	indent      int
}

pub struct UnreferencedLetDefinition {
pub:
	method             string
	name               string
	has_symbol_name    bool
	has_block          bool
	has_receiver       bool
	start_line         int
	end_line           int
	name_begin         int
	name_end           int
	within_shared      bool
	preceding_sig_line int = -1
}

pub struct UnreferencedLetRange {
pub:
	begin_pos  int
	end_pos    int
	first_line int
	last_line  int
}

pub struct UnreferencedLetOffense {
pub:
	name           string
	selector_begin int
	selector_end   int
	message        string
	removal        UnreferencedLetRange
}

pub struct UnreferencedLetAnalysis {
pub:
	source                   string
	definitions              []UnreferencedLetDefinition
	referenced_names         []string
	definitions_by_name      map[string]int
	consumes_shared_examples bool
	dynamic_dispatch         bool
	offenses                 []UnreferencedLetOffense
	corrected                string
}

fn unreferenced_let_lines(source string) []UnreferencedLetLine {
	mut lines := []UnreferencedLetLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && (text[indent] == ` ` || text[indent] == `\t`) {
			indent++
		}
		lines << UnreferencedLetLine{
			text: text
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			indent: indent
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return lines
}

fn unreferenced_let_identifier_byte(value u8, first bool) bool {
	return (value >= `A` && value <= `Z`) || (value >= `a` && value <= `z`) || value == `_` || (!first && value >= `0` && value <= `9`)
}

fn unreferenced_let_identifier_at(source string, start int) (string, int) {
	if start < 0 || start >= source.len || !unreferenced_let_identifier_byte(source[start], true) {
		return '', start
	}
	mut end := start + 1
	for end < source.len && unreferenced_let_identifier_byte(source[end], false) {
		end++
	}
	if end < source.len && (source[end] == `!` || source[end] == `?`) { end++ }
	return source[start..end], end
}

fn unreferenced_let_code(line string) string {
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
		} else if character == `"` || character == `'` {
			quote = character
		} else if character == `#` {
			return line[..index]
		}
	}
	return line
}

fn unreferenced_let_find_end(lines []UnreferencedLetLine, start int) int {
	indent := lines[start].indent
	for index := start + 1; index < lines.len; index++ {
		if lines[index].indent == indent && unreferenced_let_code(lines[index].text).trim_space() == 'end' {
			return index
		}
	}
	return start
}

fn unreferenced_let_shared_ranges(lines []UnreferencedLetLine) []UnreferencedLetRange {
	mut ranges := []UnreferencedLetRange{}
	for index, line in lines {
		trimmed := unreferenced_let_code(line.text).trim_space()
		for method in unreferenced_let_shared_definitions {
			is_shared_call := trimmed.starts_with('${method} ') || trimmed.starts_with('${method}(') || trimmed.contains('.${method} ') || trimmed.contains('.${method}(')
			if is_shared_call && (trimmed.ends_with(' do') || trimmed.contains(' do |')) {
				end_line := unreferenced_let_find_end(lines, index)
				ranges << UnreferencedLetRange{
					begin_pos: line.start
					end_pos: lines[end_line].newline_end
					first_line: index
					last_line: end_line
				}
			}
		}
	}
	return ranges
}

fn unreferenced_let_preceding_sig(lines []UnreferencedLetLine, start_line int) int {
	if start_line <= 0 {
		return -1
	}
	mut index := start_line - 1
	for index >= 0 {
		trimmed := lines[index].text.trim_space()
		if trimmed == '' || trimmed.starts_with('#') {
			index--
			continue
		}
		return if trimmed.starts_with('sig {') || trimmed.starts_with('sig do') {
			index
		} else {
			-1
		}
	}
	return -1
}

fn unreferenced_let_definitions(source string, lines []UnreferencedLetLine) []UnreferencedLetDefinition {
	shared_ranges := unreferenced_let_shared_ranges(lines)
	mut definitions := []UnreferencedLetDefinition{}
	for line_index, line in lines {
		code := unreferenced_let_code(line.text)
		trimmed := code.trim_space()
		mut method := ''
		for candidate in unreferenced_let_definition_methods {
			if trimmed == candidate || trimmed.starts_with('${candidate}(') || trimmed.starts_with('${candidate} ') || trimmed.starts_with('${candidate}{') {
				method = candidate
				break
			}
		}
		if method == '' {
			continue
		}
		method_offset := code.index(method) or { continue }
		after_method := method_offset + method.len
		mut cursor := after_method
		for cursor < code.len && (code[cursor] == ` ` || code[cursor] == `\t`) {
			cursor++
		}
		mut name := ''
		mut name_begin := 0
		mut name_end := 0
		if cursor < code.len && code[cursor] == `(` {
			cursor++
			for cursor < code.len && (code[cursor] == ` ` || code[cursor] == `\t`) {
				cursor++
			}
			if cursor < code.len && code[cursor] == `:` {
				name, name_end = unreferenced_let_identifier_at(code, cursor + 1)
				name_begin = line.start + cursor + 1
				name_end += line.start
			}
		}
		has_block := code.contains('{') || code.trim_space().ends_with(' do') || code.contains(' do |')
		end_line := if has_block && !code.contains('{') {
			unreferenced_let_find_end(lines, line_index)
		} else {
			line_index
		}
		definitions << UnreferencedLetDefinition{
			method: method
			name: name
			has_symbol_name: name != ''
			has_block: has_block
			has_receiver: method_offset > line.indent
			start_line: line_index
			end_line: end_line
			name_begin: name_begin
			name_end: name_end
			within_shared: shared_ranges.any(line_index > it.first_line && line_index < it.last_line)
			preceding_sig_line: unreferenced_let_preceding_sig(lines, line_index)
		}
	}
	return definitions
}

fn unreferenced_let_absorbable_comment(source_line ?string) bool {
	line := source_line or { return false }
	stripped := line.trim_space()
	return stripped.starts_with('#') && !stripped.starts_with('# rubocop:')
}

fn unreferenced_let_blank_line(source_line ?string) bool {
	line := source_line or { return false }
	return line.trim_space() == ''
}

fn unreferenced_let_let_or_subject_line(source_line ?string) bool {
	line := source_line or { return false }
	trimmed := line.trim_space()
	return trimmed == 'let' || trimmed.starts_with('let(') || trimmed.starts_with('let!') || trimmed == 'subject' || trimmed.starts_with('subject(')
}

fn unreferenced_let_removal_range(definition UnreferencedLetDefinition, lines []UnreferencedLetLine) UnreferencedLetRange {
	mut start_line := definition.start_line
	mut end_line := definition.end_line
	if definition.preceding_sig_line >= 0 {
		start_line = definition.preceding_sig_line
	}
	for start_line > 0 && unreferenced_let_absorbable_comment(lines[start_line - 1].text) {
		start_line--
	}
	if end_line + 1 < lines.len && unreferenced_let_blank_line(lines[end_line + 1].text) && !(start_line > 0 && unreferenced_let_let_or_subject_line(lines[start_line - 1].text)) {
		end_line++
	}
	return UnreferencedLetRange{
		begin_pos: lines[start_line].start
		end_pos: lines[end_line].newline_end
		first_line: start_line
		last_line: end_line
	}
}

fn unreferenced_let_add_name(mut names map[string]bool, value string) {
	if value != '' {
		names[value] = true
	}
}

fn unreferenced_let_string_tokens(value string, mut names map[string]bool) {
	mut index := 0
	for index < value.len {
		if unreferenced_let_identifier_byte(value[index], true) {
			token, end := unreferenced_let_identifier_at(value, index)
			unreferenced_let_add_name(mut names, token)
			index = end
		} else {
			index++
		}
	}
}

fn unreferenced_let_name_argument_position(definitions []UnreferencedLetDefinition, position int) bool {
	return definitions.any(position >= it.name_begin && position < it.name_end)
}

fn unreferenced_let_referenced_names(source string, definitions []UnreferencedLetDefinition) []string {
	keywords := ['do', 'end', 'if', 'else', 'elsif', 'unless', 'while', 'until', 'case', 'when',
		'class', 'module', 'def', 'return', 'next', 'break', 'true', 'false', 'nil', 'super', 'self']
	mut names := map[string]bool{}
	mut index := 0
	for index < source.len {
		character := source[index]
		if character == `#` {
			index = source.index_after('\n', index) or { source.len }
			continue
		}
		if character == `"` || character == `'` {
			quote := character
			mut cursor := index + 1
			mut body := ''
			mut escaped := false
			for cursor < source.len {
				current := source[cursor]
				if escaped {
					body += current.ascii_str()
					escaped = false
				} else if current == `\\` {
					escaped = true
				} else if current == quote {
					break
				} else {
					body += current.ascii_str()
				}
				cursor++
			}
			unreferenced_let_string_tokens(body, mut names)
			index = if cursor < source.len { cursor + 1 } else { cursor }
			continue
		}
		if character == `:` && index + 1 < source.len && unreferenced_let_identifier_byte(source[index + 1], true) {
			name, end := unreferenced_let_identifier_at(source, index + 1)
			if !unreferenced_let_name_argument_position(definitions, index + 1) {
				unreferenced_let_add_name(mut names, name)
			}
			index = end
			continue
		}
		if unreferenced_let_identifier_byte(character, true) {
			name, end := unreferenced_let_identifier_at(source, index)
			previous := if index > 0 { source[index - 1] } else { u8(0) }
			if name !in keywords && previous != `.` && previous != `:` && previous != `@` && !unreferenced_let_name_argument_position(definitions, index) {
				unreferenced_let_add_name(mut names, name)
			}
			index = end
			continue
		}
		index++
	}
	mut result := names.keys()
	result.sort()
	return result
}

fn unreferenced_let_contains_call(source string, methods []string) bool {
	for method in methods {
		mut start := 0
		needle := '${method}'
		for start < source.len {
			position := source.index_after(needle, start) or { break }
			before_ok := position == 0 || !unreferenced_let_identifier_byte(source[position - 1], false)
			mut cursor := position + needle.len
			for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
				cursor++
			}
			if before_ok && cursor < source.len && (source[cursor] == `(` || source[cursor] == ` ` || source[cursor] == `"` || source[cursor] == `'`) {
				return true
			}
			start = position + needle.len
		}
	}
	return false
}

fn unreferenced_let_dynamic_dispatch(source string) bool {
	for method in unreferenced_let_dispatch_methods {
		mut start := 0
		for start < source.len {
			position := source.index_after(method, start) or { break }
			if position > 0 && unreferenced_let_identifier_byte(source[position - 1], false) {
				start = position + method.len
				continue
			}
			mut cursor := position + method.len
			for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
				cursor++
			}
			if cursor >= source.len || source[cursor] != `(` {
				start = position + method.len
				continue
			}
			cursor++
			for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
				cursor++
			}
			if cursor >= source.len || source[cursor] == `)` {
				start = position + method.len
				continue
			}
			if source[cursor] == `:` {
				start = position + method.len
				continue
			}
			if source[cursor] == `"` || source[cursor] == `'` {
				quote := source[cursor]
				mut interpolated := false
				cursor++
				for cursor < source.len && source[cursor] != quote {
					if source[cursor] == `#` && cursor + 1 < source.len && source[cursor + 1] == `{` {
						interpolated = true
					}
					if source[cursor] == `\\` { cursor++ }
					cursor++
				}
				if interpolated {
					return true
				}
				start = position + method.len
				continue
			}
			return true
		}
	}
	return false
}

fn unreferenced_let_apply_corrections(source string, offenses []UnreferencedLetOffense) string {
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		range := offenses[index].removal
		corrected = corrected[..range.begin_pos] + corrected[range.end_pos..]
	}
	return corrected
}

pub fn analyze_unreferenced_lets(source string) UnreferencedLetAnalysis {
	lines := unreferenced_let_lines(source)
	definitions := unreferenced_let_definitions(source, lines)
	referenced_names := unreferenced_let_referenced_names(source, definitions)
	mut counts := map[string]int{}
	for definition in definitions {
		if definition.has_symbol_name { counts[definition.name]++ }
	}
	consumes_shared := unreferenced_let_contains_call(source, unreferenced_let_shared_consumers)
	dynamic_dispatch := unreferenced_let_dynamic_dispatch(source)
	mut offenses := []UnreferencedLetOffense{}
	for definition in definitions {
		if definition.method != 'let' || definition.has_receiver || !definition.has_symbol_name || !definition.has_block {
			continue
		}
		if definition.name in unreferenced_let_reserved_names || dynamic_dispatch || consumes_shared || definition.within_shared || counts[definition.name] > 1 || definition.name in referenced_names {
			continue
		}
		selector_begin := lines[definition.start_line].start + lines[definition.start_line].indent
		offenses << UnreferencedLetOffense{
			name: definition.name
			selector_begin: selector_begin
			selector_end: selector_begin + 3
			message: unreferenced_let_message.replace('%s', definition.name)
			removal: unreferenced_let_removal_range(definition, lines)
		}
	}
	return UnreferencedLetAnalysis{
		source: source
		definitions: definitions
		referenced_names: referenced_names
		definitions_by_name: counts
		consumes_shared_examples: consumes_shared
		dynamic_dispatch: dynamic_dispatch
		offenses: offenses
		corrected: unreferenced_let_apply_corrections(source, offenses)
	}
}

fn unreferenced_let_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn unreferenced_let_definition_value(definition UnreferencedLetDefinition) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::AST::BlockNode'
		repr: definition.name
		map_data: {
			'method':          ruby.string_value(definition.method)
			'name':            ruby.string_value(definition.name)
			'has_symbol_name': ruby.bool_value(definition.has_symbol_name)
			'has_block':       ruby.bool_value(definition.has_block)
			'has_receiver':    ruby.bool_value(definition.has_receiver)
			'within_shared':   ruby.bool_value(definition.within_shared)
		}
		attributes: {
			'start_line':         definition.start_line.str()
			'end_line':           definition.end_line.str()
			'name_begin':         definition.name_begin.str()
			'name_end':           definition.name_end.str()
			'preceding_sig_line': definition.preceding_sig_line.str()
		}
	}
}

fn unreferenced_let_range_value(value UnreferencedLetRange) ruby.Value {
	return ruby.Value{
		type_name: 'Parser::Source::Range'
		repr: '${value.begin_pos}...${value.end_pos}'
		attributes: {
			'begin_pos':  value.begin_pos.str()
			'end_pos':    value.end_pos.str()
			'first_line': (value.first_line + 1).str()
			'last_line':  (value.last_line + 1).str()
		}
	}
}

fn unreferenced_let_offense_value(offense UnreferencedLetOffense) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::Offense'
		repr: offense.message
		map_data: {
			'name':    ruby.string_value(offense.name)
			'message': ruby.string_value(offense.message)
			'range':   unreferenced_let_range_value(offense.removal)
		}
		attributes: {
			'selector_begin': offense.selector_begin.str()
			'selector_end':   offense.selector_end.str()
		}
	}
}

fn unreferenced_let_source(args []ruby.Value) string {
	for value in args {
		if value.type_name == 'String' || value.type_name == 'RuboCop::AST::ProcessedSource' {
			return value.as_string()
		}
		if raw := value.map_data['source'] {
			return raw.as_string()
		}
	}
	return ''
}

fn unreferenced_let_definition_for(analysis UnreferencedLetAnalysis, name string) ?UnreferencedLetDefinition {
	for definition in analysis.definitions {
		if definition.name == name {
			return definition
		}
	}
	return none
}
