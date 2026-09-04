module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/unreferenced_let.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby def_node_matcher `def_node_matcher :definition_name, <<~PATTERN` at line 79.
pub fn ruby_unreferenced_let_l79_d1_definition_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return unreferenced_let_nil()
	}
	if raw := args[0].map_data['name'] {
		return if raw.as_string() == '' { unreferenced_let_nil() } else { raw }
	}
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args))
	return if analysis.definitions.len == 0 || !analysis.definitions[0].has_symbol_name {
		unreferenced_let_nil()
	} else {
		ruby.Value{ type_name: 'Symbol', repr: analysis.definitions[0].name }
	}
}

// Ruby method `on_send(node)` at line 84.
pub fn ruby_unreferenced_let_l84_d2_on_send(args ...ruby.Value) ruby.Value {
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args))
	return ruby.array_value(analysis.offenses.map(unreferenced_let_offense_value(it)))
}

// Ruby method `exempt_from_deletion?(name, block)` at line 109.
pub fn ruby_unreferenced_let_l109_d3_exempt_from_deletion(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(true)
	}
	name := args[0].as_string().trim_left(':')
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args[1..]))
	definition := unreferenced_let_definition_for(analysis, name) or {
		return ruby.bool_value(true)
	}
	return ruby.bool_value(name in unreferenced_let_reserved_names || analysis.dynamic_dispatch || analysis.consumes_shared_examples || definition.within_shared || analysis.definitions_by_name[name] > 1 || name in analysis.referenced_names)
}

// Ruby method `removal_range(node)` at line 125.
pub fn ruby_unreferenced_let_l125_d4_removal_range(args ...ruby.Value) ruby.Value {
	source := unreferenced_let_source(args)
	analysis := analyze_unreferenced_lets(source)
	name := if args.len > 1 { args[1].as_string().trim_left(':') } else { '' }
	definition := if name != '' {
		unreferenced_let_definition_for(analysis, name) or { return unreferenced_let_nil() }
	} else if analysis.definitions.len > 0 {
		analysis.definitions[0]
	} else {
		return unreferenced_let_nil()
	}
	return unreferenced_let_range_value(unreferenced_let_removal_range(definition, unreferenced_let_lines(source)))
}

// Ruby method `absorbable_comment?(source_line)` at line 148.
pub fn ruby_unreferenced_let_l148_d5_absorbable_comment(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(unreferenced_let_absorbable_comment(args[0].as_string()))
}

// Ruby method `blank_line?(source_line)` at line 156.
pub fn ruby_unreferenced_let_l156_d6_blank_line(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(unreferenced_let_blank_line(args[0].as_string()))
}

// Ruby method `let_or_subject_line?(source_line)` at line 163.
pub fn ruby_unreferenced_let_l163_d7_let_or_subject_line(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(unreferenced_let_let_or_subject_line(args[0].as_string()))
}

// Ruby method `preceding_sig(node)` at line 170.
pub fn ruby_unreferenced_let_l170_d8_preceding_sig(args ...ruby.Value) ruby.Value {
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args))
	name := if args.len > 1 { args[1].as_string().trim_left(':') } else { '' }
	definition := if name != '' {
		unreferenced_let_definition_for(analysis, name) or { return unreferenced_let_nil() }
	} else if analysis.definitions.len > 0 {
		analysis.definitions[0]
	} else {
		return unreferenced_let_nil()
	}
	if definition.preceding_sig_line < 0 {
		return unreferenced_let_nil()
	}
	return ruby.Value{
		type_name: 'RuboCop::AST::BlockNode'
		repr: 'sig'
		attributes: {
			'line': (definition.preceding_sig_line + 1).str()
		}
	}
}

// Ruby method `within_shared_definition?(node)` at line 179.
pub fn ruby_unreferenced_let_l179_d9_within_shared_definition(args ...ruby.Value) ruby.Value {
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args))
	name := if args.len > 1 { args[1].as_string().trim_left(':') } else { '' }
	definition := unreferenced_let_definition_for(analysis, name) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(definition.within_shared)
}

// Ruby method `consumes_shared_examples?` at line 184.
pub fn ruby_unreferenced_let_l184_d10_consumes_shared_examples(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(analyze_unreferenced_lets(unreferenced_let_source(args)).consumes_shared_examples)
}

// Ruby method `dynamic_dispatch?` at line 197.
pub fn ruby_unreferenced_let_l197_d11_dynamic_dispatch(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(analyze_unreferenced_lets(unreferenced_let_source(args)).dynamic_dispatch)
}

// Ruby method `overridden?(name)` at line 211.
pub fn ruby_unreferenced_let_l211_d12_overridden(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	name := args[0].as_string().trim_left(':')
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args[1..]))
	return ruby.bool_value(analysis.definitions_by_name[name] > 1)
}

// Ruby method `definitions_by_name` at line 216.
pub fn ruby_unreferenced_let_l216_d13_definitions_by_name(args ...ruby.Value) ruby.Value {
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args))
	mut values := map[string]ruby.Value{}
	for name, count in analysis.definitions_by_name {
		values[name] = ruby.int_value(count)
	}
	return ruby.map_value(values)
}

// Ruby method `referenced?(name)` at line 232.
pub fn ruby_unreferenced_let_l232_d14_referenced(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	name := args[0].as_string().trim_left(':')
	return ruby.bool_value(name in analyze_unreferenced_lets(unreferenced_let_source(args[1..])).referenced_names)
}

// Ruby method `referenced_names` at line 246.
pub fn ruby_unreferenced_let_l246_d15_referenced_names(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(analyze_unreferenced_lets(unreferenced_let_source(args)).referenced_names)
}

// Ruby method `definition_name_argument?(sym_node)` at line 273.
pub fn ruby_unreferenced_let_l273_d16_definition_name_argument(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	if raw := args[0].map_data['definition_name_argument'] {
		return raw
	}
	position := (args[0].attributes['begin_pos'] or { '-1' }).int()
	analysis := analyze_unreferenced_lets(unreferenced_let_source(args[1..]))
	return ruby.bool_value(unreferenced_let_name_argument_position(analysis.definitions, position))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop-rspec"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Homebrew
// 9:       # Flags lazy `let` declarations whose name is never referenced. A lazy `let(:name) { ... }`
// 10:       # is only evaluated when `name` is called, so an unreferenced one is dead code -- its block
// 11:       # never runs -- and is deleted.
// 12:       #
// 13:       # Eager `let!` is intentionally out of scope: it runs its block before every example for its
// 14:       # side effect even when unreferenced, so it cannot simply be deleted. Only plain `let` is
// 15:       # handled here.
// 16:       #
// 17:       # Detection is file-scoped: a `let` referenced only from another file (through a shared
// 18:       # example or an included test harness) cannot be seen, so the cop stays conservative and
// 19:       # prefers false negatives over false positives:
// 20:       # - a name defined more than once in the file by `let`/`let!`/`subject` (an override /
// 21:       #   `super` chain, including a `subject` that overrides a `let` of the same name) is never
// 22:       #   flagged;
// 23:       # - a `let` declared lexically inside a `shared_examples` / `shared_examples_for` /
// 24:       #   `shared_context` block is skipped (its consumers live in other files);
// 25:       # - every `let` in a file that uses `it_behaves_like` / `it_should_behave_like` /
// 26:       #   `include_examples` / `include_context` is skipped, because an included shared block may
// 27:       #   reference the binding by a name we cannot follow statically;
// 28:       # - `let(:cop_config)` is skipped: it is a rubocop-rspec contract consumed by the `:config`
// 29:       #   shared context, not by a reference in the spec file; and
// 30:       # - every `let` in a file that reflectively dispatches through a name we cannot resolve
// 31:       #   statically (e.g. `send("expected_#{type}")`) is skipped, since any `let` could be the
// 32:       #   target.
// 33:       # A name counts as referenced if it is called bare (`foo`), appears as a symbol (`:foo`)
// 34:       # anywhere but the let's own name argument, or appears as an identifier-shaped token inside
// 35:       # any string/heredoc literal -- covering dynamic dispatch, `:foo` entries in data tables the
// 36:       # spec later dispatches on, and bindings named only inside raw SQL/GraphQL text.
// 37:       #
// 38:       # Because a bare `:foo` symbol anywhere counts as a reference, commonly-named lets
// 39:       # (`let(:formula)`, `let(:cask)`, `let(:id)`) are essentially never flagged. This conservative
// 40:       # bias means the cop realistically only deletes distinctively-named dead lets; it is not a
// 41:       # complete dead-`let` finder.
// 42:       #
// 43:       # ### Example
// 44:       #
// 45:       # ```ruby
// 46:       # # bad (name never referenced -- deleted, the block never runs)
// 47:       # let(:unused) { create(:thing) }
// 48:       #
// 49:       # # good
// 50:       # let(:thing) { create(:thing) }
// 51:       # it { expect(thing).to be_present }
// 52:       # ```
// 53:       class UnreferencedLet < ::RuboCop::Cop::RSpec::Base
// 54:         extend AutoCorrector
// 55:         include RangeHelp
// 56:
// 57:         DEFINITION_METHODS = [:let, :let!, :subject].freeze
// 58:         # `let`s consumed by a test framework rather than by a reference in the spec file. RuboCop's
// 59:         # own `:config` shared context (used by every cop spec) reads `cop_config`, `other_cops`,
// 60:         # `cop_options` and `gem_versions` by name from inside the framework, so they are live even
// 61:         # though the spec never names them.
// 62:         FRAMEWORK_RESERVED_NAMES = [:cop_config, :other_cops, :cop_options, :gem_versions].freeze
// 63:         # Reflective dispatch methods whose target is the first argument. When that argument is not
// 64:         # a statically-resolvable name (a `sym` or plain `str`) -- e.g. `send("expected_#{type}")` --
// 65:         # the called name cannot be known, so the whole file is left untouched.
// 66:         DYNAMIC_DISPATCH_METHODS = [:send, :public_send, :__send__, :try, :try!, :method, :public_method,
// 67:                                     :respond_to?].freeze
// 68:         # Identifier-shaped tokens inside a string/heredoc literal. A `let` whose name appears only
// 69:         # inside string text -- e.g. a binding or column referenced in raw SQL/GraphQL the spec
// 70:         # later executes -- counts as referenced, so it is not deleted.
// 71:         IDENTIFIER_IN_STRING = /[A-Za-z_]\w*[!?]?/
// 72:         MSG = "Remove unreferenced `let(:%<name>s)` -- its name is never used, so the block never runs."
// 73:         RESTRICT_ON_SEND = [:let].freeze
// 74:
// 75:         # The name symbol of any definition (`let`/`let!`/`subject`) in any block form -- used to
// 76:         # count how many times a name is defined, so override / `super` chains (including a
// 77:         # `subject` that overrides a `let` of the same name) are never flagged.
// 78:         # @!method definition_name(node)
// 79:         def_node_matcher :definition_name, <<~PATTERN
// 80:           (any_block (send nil? {#{DEFINITION_METHODS.map { |method| ":#{method}" }.join(" ")}} (sym $_) ...) ...)
// 81:         PATTERN
// 82:
// 83:         sig { params(node: RuboCop::AST::SendNode).void }
// 84:         def on_send(node)
// 85:           return unless node.receiver.nil?
// 86:
// 87:           name_argument = node.first_argument
// 88:           return unless name_argument&.sym_type?
// 89:
// 90:           block = node.block_node
// 91:           return unless block
// 92:
// 93:           name = name_argument.value
// 94:           return if exempt_from_deletion?(name, block)
// 95:
// 96:           add_offense(node.loc.selector, message: format(MSG, name:)) do |corrector|
// 97:             corrector.remove(removal_range(block))
// 98:           end
// 99:         end
// 100:
// 101:         private
// 102:
// 103:         # A lazy `let` is exempt from deletion whenever file-scoped analysis cannot prove its name
// 104:         # is dead: its name is a framework-reserved contract (e.g. `cop_config`), the file
// 105:         # dispatches through a name we cannot resolve statically, it consumes shared examples, the
// 106:         # `let` is lexically inside a shared-example definition, it is overridden by another
// 107:         # definition of the same name, or it is referenced somewhere in the file.
// 108:         sig { params(name: Symbol, block: RuboCop::AST::BlockNode).returns(T::Boolean) }
// 109:         def exempt_from_deletion?(name, block)
// 110:           FRAMEWORK_RESERVED_NAMES.include?(name) ||
// 111:             dynamic_dispatch? ||
// 112:             consumes_shared_examples? ||
// 113:             within_shared_definition?(block) ||
// 114:             overridden?(name) ||
// 115:             referenced?(name)
// 116:         end
// 117:
// 118:         # Delete the `let` block, plus:
// 119:         # - an immediately-preceding `sig { ... }` (so a Sorbet signature is not left dangling),
// 120:         # - explanatory comment lines attached directly above it (so they are not orphaned), and
// 121:         # - a single trailing blank line where removal would otherwise leave a stray/duplicate
// 122:         #   blank -- unless the line above is a `let`/`subject`, where that blank is the required
// 123:         #   separator after the now-final let and must stay.
// 124:         sig { params(node: RuboCop::AST::BlockNode).returns(Parser::Source::Range) }
// 125:         def removal_range(node)
// 126:           lines = processed_source.lines
// 127:           start_line = node.source_range.first_line
// 128:           end_line = node.source_range.last_line
// 129:
// 130:           sig = preceding_sig(node)
// 131:           start_line = sig.source_range.first_line if sig
// 132:
// 133:           start_line -= 1 while start_line > 1 && absorbable_comment?(lines[start_line - 2])
// 134:
// 135:           if end_line < lines.size && blank_line?(lines[end_line]) &&
// 136:              !(start_line > 1 && let_or_subject_line?(lines[start_line - 2]))
// 137:             end_line += 1
// 138:           end
// 139:
// 140:           buffer = processed_source.buffer
// 141:           range_by_whole_lines(
// 142:             buffer.line_range(start_line).join(buffer.line_range(end_line)),
// 143:             include_final_newline: true,
// 144:           )
// 145:         end
// 146:
// 147:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 148:         def absorbable_comment?(source_line)
// 149:           return false if source_line.nil?
// 150:
// 151:           stripped = source_line.strip
// 152:           stripped.start_with?("#") && !stripped.start_with?("# rubocop:")
// 153:         end
// 154:
// 155:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 156:         def blank_line?(source_line)
// 157:           return false if source_line.nil?
// 158:
// 159:           source_line.strip.empty?
// 160:         end
// 161:
// 162:         sig { params(source_line: T.nilable(String)).returns(T::Boolean) }
// 163:         def let_or_subject_line?(source_line)
// 164:           return false if source_line.nil?
// 165:
// 166:           source_line.match?(/\A\s*(?:let!?|subject)\b/)
// 167:         end
// 168:
// 169:         sig { params(node: RuboCop::AST::BlockNode).returns(T.nilable(RuboCop::AST::BlockNode)) }
// 170:         def preceding_sig(node)
// 171:           sibling = node.left_sibling
// 172:           return unless sibling.is_a?(::RuboCop::AST::BlockNode)
// 173:           return unless sibling.method?(:sig)
// 174:
// 175:           sibling
// 176:         end
// 177:
// 178:         sig { params(node: RuboCop::AST::BlockNode).returns(T::Boolean) }
// 179:         def within_shared_definition?(node)
// 180:           node.each_ancestor(:any_block).any? { |ancestor| shared_group?(ancestor) }
// 181:         end
// 182:
// 183:         sig { returns(T::Boolean) }
// 184:         def consumes_shared_examples?
// 185:           @consumes_shared_examples = T.let(@consumes_shared_examples, T.nilable(T::Boolean))
// 186:           return @consumes_shared_examples unless @consumes_shared_examples.nil?
// 187:
// 188:           ast = processed_source.ast
// 189:           @consumes_shared_examples = !ast.nil? && ast.each_node(:call).any? { |send_node| include?(send_node) }
// 190:         end
// 191:
// 192:         # True when the file reflectively dispatches through a name we cannot resolve statically --
// 193:         # `send`/`public_send`/`method`/etc. called with anything other than a `sym` or plain `str`
// 194:         # first argument (most commonly an interpolated string, `send("expected_#{type}")`). In
// 195:         # that case any `let` in the file could be the dispatch target, so none are deleted.
// 196:         sig { returns(T::Boolean) }
// 197:         def dynamic_dispatch?
// 198:           @dynamic_dispatch = T.let(@dynamic_dispatch, T.nilable(T::Boolean))
// 199:           return @dynamic_dispatch unless @dynamic_dispatch.nil?
// 200:
// 201:           ast = processed_source.ast
// 202:           @dynamic_dispatch = !ast.nil? && ast.each_node(:call).any? do |send_node|
// 203:             next false unless DYNAMIC_DISPATCH_METHODS.include?(send_node.method_name)
// 204:
// 205:             target = send_node.first_argument
// 206:             !target.nil? && !target.sym_type? && !target.str_type?
// 207:           end
// 208:         end
// 209:
// 210:         sig { params(name: Symbol).returns(T::Boolean) }
// 211:         def overridden?(name)
// 212:           definitions_by_name.fetch(name, 0) > 1
// 213:         end
// 214:
// 215:         sig { returns(T::Hash[Symbol, Integer]) }
// 216:         def definitions_by_name
// 217:           @definitions_by_name ||= T.let(
// 218:             begin
// 219:               ast = processed_source.ast
// 220:               counts = Hash.new(0)
// 221:               ast&.each_node(:any_block) do |node|
// 222:                 name = definition_name(node)
// 223:                 counts[name] += 1 if name
// 224:               end
// 225:               counts
// 226:             end,
// 227:             T.nilable(T::Hash[Symbol, Integer]),
// 228:           )
// 229:         end
// 230:
// 231:         sig { params(name: Symbol).returns(T::Boolean) }
// 232:         def referenced?(name)
// 233:           referenced_names.include?(name)
// 234:         end
// 235:
// 236:         # A name is "referenced" if it is called as a bare method (`foo`), appears as a symbol
// 237:         # literal (`:foo`) other than the let/subject's own name argument, or appears as an
// 238:         # identifier-shaped token inside any string/heredoc literal. The symbol and string cases
// 239:         # cover indirect invocation -- `send(:foo)` / `send("foo")`, a `:foo`/`"foo"` listed in a
// 240:         # data table the spec later dispatches on, or a binding named only inside raw SQL/GraphQL
// 241:         # text the spec executes -- which file-scoped analysis cannot otherwise follow. (Tokenizing
// 242:         # string bodies, rather than matching the whole string, keeps a `let` referenced only from
// 243:         # inside a multi-word heredoc from being deleted.) Interpolated-string *dispatch* is handled
// 244:         # separately by `dynamic_dispatch?`, which exempts the whole file.
// 245:         sig { returns(T::Set[Symbol]) }
// 246:         def referenced_names
// 247:           @referenced_names ||= T.let(
// 248:             begin
// 249:               ast = processed_source.ast
// 250:               names = Set.new
// 251:               ast&.each_node(:sym, :str, :call) do |node|
// 252:                 if node.sym_type?
// 253:                   names << node.value unless definition_name_argument?(node)
// 254:                 elsif node.str_type?
// 255:                   # A string with invalid encoding (e.g. a deliberate bad-UTF-8 test fixture) cannot
// 256:                   # contain an identifier-shaped reference and would raise on `scan`, so skip it.
// 257:                   if node.value.valid_encoding?
// 258:                     node.value.scan(IDENTIFIER_IN_STRING) do |token|
// 259:                       names << token.to_sym
// 260:                     end
// 261:                   end
// 262:                 elsif node.receiver.nil? && node.arguments.empty?
// 263:                   names << node.method_name
// 264:                 end
// 265:               end
// 266:               names
// 267:             end,
// 268:             T.nilable(T::Set[Symbol]),
// 269:           )
// 270:         end
// 271:
// 272:         sig { params(sym_node: RuboCop::AST::Node).returns(T::Boolean) }
// 273:         def definition_name_argument?(sym_node)
// 274:           parent = sym_node.parent
// 275:           return false if parent.nil? || !parent.send_type? || !parent.receiver.nil?
// 276:
// 277:           DEFINITION_METHODS.include?(parent.method_name)
// 278:         end
// 279:       end
// 280:     end
// 281:   end
// 282: end
