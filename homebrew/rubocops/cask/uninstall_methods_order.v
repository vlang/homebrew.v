module cask

import brew_runtime
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `rubocops/cask/uninstall_methods_order.rb`.
// The original source is retained below until every stub has a typed V body.
pub const uninstall_methods_order_message = '`%s` method out of order'
pub const uninstall_methods_order_useless_metadata_message = '`on_upgrade` has no effect without matching `uninstall signal:` directive'
pub const uninstall_methods_order_partial_metadata_message = '`on_upgrade` lists %s without matching `uninstall` directives'
pub const uninstall_methods_order_invalid_metadata_message = '`on_upgrade` value must be :signal or an array [:signal]'

pub struct UninstallMethodsOrderPair {
pub:
	method         string
	key_begin      int
	key_end        int
	value_begin    int
	value_end      int
	source_begin   int
	source_end     int
	inline_comment string
}

pub struct UninstallMethodsOrderProblem {
pub:
	kind              string
	method            string
	begin_pos         int
	end_pos           int
	message           string
	has_correction    bool
	replacement_begin int
	replacement_end   int
	replacement       string
}

struct UninstallMethodsOrderCall {
	method     string
	hash_begin int
	hash_end   int
	pairs      []UninstallMethodsOrderPair
}

struct UninstallMethodsOrderKey {
	method      string
	key_begin   int
	key_end     int
	pair_begin  int
	value_begin int
}

struct UninstallMethodsOrderValueEnd {
	value_end int
	delimiter int
	finished  bool
}

fn uninstall_methods_order_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn uninstall_methods_order_identifier_character(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn uninstall_methods_order_skip_string(source string, start int, limit int) int {
	quote := source[start]
	mut cursor := start + 1
	mut escaped := false
	for cursor < limit {
		if escaped {
			escaped = false
		} else if source[cursor] == `\\` {
			escaped = true
		} else if source[cursor] == quote {
			return cursor + 1
		}
		cursor++
	}
	return limit
}

fn uninstall_methods_order_skip_comment(source string, start int, limit int) int {
	mut cursor := start
	for cursor < limit && source[cursor] != `\n` {
		cursor++
	}
	return cursor
}

fn uninstall_methods_order_skip_space_and_comments(source string, start int, limit int) int {
	mut cursor := start
	for cursor < limit {
		if source[cursor].is_space() {
			cursor++
			continue
		}
		if source[cursor] == `#` {
			cursor = uninstall_methods_order_skip_comment(source, cursor, limit)
			continue
		}
		break
	}
	return cursor
}

fn uninstall_methods_order_trim_end(source string, start int, end int) int {
	mut cursor := end
	for cursor > start && source[cursor - 1].is_space() {
		cursor--
	}
	return cursor
}

fn uninstall_methods_order_matching_close(source string, start int, limit int) int {
	mut expected := []u8{}
	match source[start] {
		`(` { expected << `)` }
		`[` { expected << `]` }
		`{` { expected << `}` }
		else {
			return limit
		}
	}
	mut cursor := start + 1
	for cursor < limit {
		character := source[cursor]
		if character in [`'`, `"`, u8(96)] {
			cursor = uninstall_methods_order_skip_string(source, cursor, limit)
			continue
		}
		if character == `#` {
			cursor = uninstall_methods_order_skip_comment(source, cursor, limit)
			continue
		}
		if character == `(` {
			expected << `)`
		} else if character == `[` {
			expected << `]`
		} else if character == `{` {
			expected << `}`
		} else if expected.len > 0 && character == expected[expected.len - 1] {
			expected.delete_last()
			if expected.len == 0 {
				return cursor
			}
		}
		cursor++
	}
	return limit
}

fn uninstall_methods_order_parse_key(source string, start int, limit int) ?UninstallMethodsOrderKey {
	cursor := uninstall_methods_order_skip_space_and_comments(source, start, limit)
	if cursor >= limit {
		return none
	}
	if uninstall_methods_order_identifier_start(source[cursor]) {
		mut identifier_end := cursor + 1
		for identifier_end < limit && uninstall_methods_order_identifier_character(source[identifier_end]) {
			identifier_end++
		}
		mut separator := identifier_end
		for separator < limit && source[separator] in [` `, `\t`] {
			separator++
		}
		if separator < limit && source[separator] == `:` && (separator + 1 >= limit || source[separator + 1] != `:`) {
			return UninstallMethodsOrderKey{
				method: source[cursor..identifier_end]
				key_begin: cursor
				key_end: identifier_end
				pair_begin: cursor
				value_begin: uninstall_methods_order_skip_space_and_comments(source, separator + 1, limit)
			}
		}
	}
	if source[cursor] != `:` || cursor + 1 >= limit || !uninstall_methods_order_identifier_start(source[cursor + 1]) {
		return none
	}
	mut symbol_end := cursor + 2
	for symbol_end < limit && uninstall_methods_order_identifier_character(source[symbol_end]) {
		symbol_end++
	}
	mut separator := symbol_end
	for separator < limit && source[separator] in [` `, `\t`] {
		separator++
	}
	if separator + 1 >= limit || source[separator..separator + 2] != '=>' {
		return none
	}
	return UninstallMethodsOrderKey{
		method: source[cursor + 1..symbol_end]
		key_begin: cursor
		key_end: symbol_end
		pair_begin: cursor
		value_begin: uninstall_methods_order_skip_space_and_comments(source, separator + 2, limit)
	}
}

fn uninstall_methods_order_value_end(source string, start int, limit int, terminator u8) UninstallMethodsOrderValueEnd {
	mut expected := []u8{}
	mut cursor := start
	mut significant_end := start
	for cursor < limit {
		character := source[cursor]
		if character in [`'`, `"`, u8(96)] {
			cursor = uninstall_methods_order_skip_string(source, cursor, limit)
			significant_end = cursor
			continue
		}
		if character == `#` {
			if expected.len == 0 {
				return UninstallMethodsOrderValueEnd{
					value_end: significant_end
					delimiter: cursor
					finished: true
				}
			}
			cursor = uninstall_methods_order_skip_comment(source, cursor, limit)
			continue
		}
		if character == `(` {
			expected << `)`
		} else if character == `[` {
			expected << `]`
		} else if character == `{` {
			expected << `}`
		} else if expected.len > 0 && character == expected[expected.len - 1] {
			expected.delete_last()
		} else if expected.len == 0 {
			if character == `,` {
				return UninstallMethodsOrderValueEnd{
					value_end: uninstall_methods_order_trim_end(source, start, cursor)
					delimiter: cursor
				}
			}
			if character == `\n` || (terminator != 0 && character == terminator) {
				return UninstallMethodsOrderValueEnd{
					value_end: uninstall_methods_order_trim_end(source, start, cursor)
					delimiter: cursor
					finished: true
				}
			}
		}
		if !character.is_space() {
			significant_end = cursor + 1
		}
		cursor++
	}
	return UninstallMethodsOrderValueEnd{
		value_end: uninstall_methods_order_trim_end(source, start, limit)
		delimiter: limit
		finished: true
	}
}

fn uninstall_methods_order_inline_comment(source string, pair_begin int, pair_end int) string {
	line_end_offset := source[pair_begin..].index_u8(`\n`)
	line_end := if line_end_offset < 0 { source.len } else { pair_begin + line_end_offset }
	mut cursor := pair_begin
	for cursor < line_end {
		if source[cursor] in [`'`, `"`, u8(96)] {
			cursor = uninstall_methods_order_skip_string(source, cursor, line_end)
			continue
		}
		if source[cursor] == `#` && cursor >= pair_end {
			return source[cursor..line_end]
		}
		cursor++
	}
	return ''
}

fn uninstall_methods_order_pairs(source string, start int, limit int, terminator u8) []UninstallMethodsOrderPair {
	mut pairs := []UninstallMethodsOrderPair{}
	mut cursor := start
	for cursor < limit {
		key := uninstall_methods_order_parse_key(source, cursor, limit) or { break }
		if key.value_begin >= limit {
			break
		}
		value := uninstall_methods_order_value_end(source, key.value_begin, limit, terminator)
		if value.value_end <= key.value_begin {
			break
		}
		pairs << UninstallMethodsOrderPair{
			method: key.method
			key_begin: key.key_begin
			key_end: key.key_end
			value_begin: key.value_begin
			value_end: value.value_end
			source_begin: key.pair_begin
			source_end: value.value_end
			inline_comment: uninstall_methods_order_inline_comment(source, key.pair_begin, value.value_end)
		}
		if value.finished || value.delimiter >= limit {
			break
		}
		cursor = value.delimiter + 1
		candidate := uninstall_methods_order_skip_space_and_comments(source, cursor, limit)
		if candidate >= limit || (terminator != 0 && source[candidate] == terminator) {
			break
		}
		cursor = candidate
	}
	return pairs
}

fn uninstall_methods_order_calls(source string) []UninstallMethodsOrderCall {
	mut calls := []UninstallMethodsOrderCall{}
	mut cursor := 0
	for cursor < source.len {
		character := source[cursor]
		if character in [`'`, `"`, u8(96)] {
			cursor = uninstall_methods_order_skip_string(source, cursor, source.len)
			continue
		}
		if character == `#` {
			cursor = uninstall_methods_order_skip_comment(source, cursor, source.len)
			continue
		}
		if !uninstall_methods_order_identifier_start(character) {
			cursor++
			continue
		}
		method_begin := cursor
		cursor++
		for cursor < source.len && uninstall_methods_order_identifier_character(source[cursor]) {
			cursor++
		}
		method := source[method_begin..cursor]
		if method !in ['uninstall', 'zap'] || (method_begin > 0 && source[method_begin - 1] == `:`) {
			continue
		}
		mut arguments_start := cursor
		for arguments_start < source.len && source[arguments_start] in [` `, `\t`] {
			arguments_start++
		}
		if arguments_start >= source.len || source[arguments_start] == `\n` {
			continue
		}
		mut content_start := arguments_start
		mut content_limit := source.len
		mut terminator := u8(0)
		mut explicit_hash := false
		mut explicit_hash_begin := -1
		mut parenthesized := false
		if source[content_start] == `(` {
			parenthesized = true
			closing := uninstall_methods_order_matching_close(source, content_start, source.len)
			if closing >= source.len {
				continue
			}
			content_start = uninstall_methods_order_skip_space_and_comments(source, content_start + 1, closing)
			content_limit = closing
			terminator = `)`
		}
		if content_start < content_limit && source[content_start] == `{` {
			explicit_hash = true
			explicit_hash_begin = content_start
			closing := uninstall_methods_order_matching_close(source, content_start, content_limit)
			if closing >= content_limit {
				continue
			}
			content_limit = closing
			content_start = uninstall_methods_order_skip_space_and_comments(source, content_start + 1, closing)
			terminator = `}`
		}
		pairs := uninstall_methods_order_pairs(source, content_start, content_limit, terminator)
		if pairs.len == 0 {
			continue
		}
		hash_begin := if explicit_hash {
			explicit_hash_begin
		} else {
			pairs[0].source_begin
		}
		hash_end := if explicit_hash {
			content_limit + 1
		} else {
			pairs[pairs.len - 1].source_end
		}
		calls << UninstallMethodsOrderCall{
			method: method
			hash_begin: hash_begin
			hash_end: hash_end
			pairs: pairs
		}
		if parenthesized && content_limit + 1 > cursor {
			cursor = content_limit + 1
		}
	}
	return calls
}

// method_order_index mirrors Array#index(... ) || -1 from the Ruby cop.
pub fn uninstall_method_order_index(method string) int {
	for index, expected in stanza_constants.uninstall_methods_order {
		if method == expected {
			return index
		}
	}
	return -1
}

fn uninstall_methods_order_sort_pairs(pairs []UninstallMethodsOrderPair) []UninstallMethodsOrderPair {
	mut ordered := []UninstallMethodsOrderPair{}
	for pair in pairs {
		index := uninstall_method_order_index(pair.method)
		mut inserted := false
		for position, existing in ordered {
			if uninstall_method_order_index(existing.method) > index {
				ordered.insert(position, pair)
				inserted = true
				break
			}
		}
		if !inserted {
			ordered << pair
		}
	}
	return ordered
}

fn uninstall_methods_order_same_pair(left UninstallMethodsOrderPair, right UninstallMethodsOrderPair) bool {
	return left.source_begin == right.source_begin && left.source_end == right.source_end
}

fn uninstall_methods_order_column(source string, position int) int {
	line_start := source[..position].last_index('\n') or { -1 }
	return position - line_start - 1
}

pub fn build_uninstall_methods_order_body(source string, pairs []UninstallMethodsOrderPair, indentation string) string {
	mut entries := []string{cap: pairs.len}
	for pair in pairs {
		mut entry := source[pair.source_begin..pair.source_end]
		if pair.inline_comment != '' {
			entry += ' ${pair.inline_comment}'
		}
		entries << entry
	}
	return entries.join(',\n${indentation}')
}

fn uninstall_methods_order_ordering_problems(source string, call UninstallMethodsOrderCall) []UninstallMethodsOrderProblem {
	methods := call.pairs.filter(it.method != 'on_upgrade')
	expected := uninstall_methods_order_sort_pairs(methods)
	if methods.len != expected.len {
		return []UninstallMethodsOrderProblem{}
	}
	mut problems := []UninstallMethodsOrderProblem{}
	for index, method in methods {
		if uninstall_methods_order_same_pair(method, expected[index]) {
			continue
		}
		problems << UninstallMethodsOrderProblem{
			kind: 'ordering'
			method: method.method
			begin_pos: method.key_begin
			end_pos: method.key_end
			message: uninstall_methods_order_message.replace('%s', method.method)
			has_correction: true
			replacement_begin: call.hash_begin
			replacement_end: call.hash_end
			replacement: build_uninstall_methods_order_body(source, expected, ' '.repeat(uninstall_methods_order_column(source, method.key_begin)))
		}
	}
	return problems
}

fn uninstall_methods_order_direct_symbol(source string) ?string {
	mut cursor := uninstall_methods_order_skip_space_and_comments(source, 0, source.len)
	if cursor + 1 >= source.len || source[cursor] != `:` {
		return none
	}
	if source[cursor + 1] in [`'`, `"`] {
		end := uninstall_methods_order_skip_string(source, cursor + 1, source.len)
		if uninstall_methods_order_skip_space_and_comments(source, end, source.len) != source.len {
			return none
		}
		return source[cursor + 2..end - 1]
	}
	if !uninstall_methods_order_identifier_start(source[cursor + 1]) {
		return none
	}
	begin := cursor + 1
	cursor += 2
	for cursor < source.len && uninstall_methods_order_identifier_character(source[cursor]) {
		cursor++
	}
	end := cursor
	if uninstall_methods_order_skip_space_and_comments(source, cursor, source.len) != source.len {
		return none
	}
	return source[begin..end]
}

pub fn uninstall_methods_order_on_upgrade_symbols(value_source string) []string {
	if symbol := uninstall_methods_order_direct_symbol(value_source) {
		return [symbol]
	}
	trimmed := value_source.trim_space()
	if trimmed.len < 2 || trimmed[0] != `[` || trimmed[trimmed.len - 1] != `]` {
		return []string{}
	}
	mut symbols := []string{}
	mut element_start := 1
	mut cursor := 1
	mut expected := []u8{}
	for cursor <= trimmed.len - 1 {
		at_end := cursor == trimmed.len - 1
		if !at_end {
			character := trimmed[cursor]
			if character in [`'`, `"`, u8(96)] {
				cursor = uninstall_methods_order_skip_string(trimmed, cursor, trimmed.len - 1)
				continue
			}
			if character == `#` {
				cursor = uninstall_methods_order_skip_comment(trimmed, cursor, trimmed.len - 1)
				continue
			}
			if character == `(` {
				expected << `)`
			} else if character == `[` {
				expected << `]`
			} else if character == `{` {
				expected << `}`
			} else if expected.len > 0 && character == expected[expected.len - 1] {
				expected.delete_last()
			}
		}
		if at_end || (expected.len == 0 && trimmed[cursor] == `,`) {
			if symbol := uninstall_methods_order_direct_symbol(trimmed[element_start..cursor]) {
				symbols << symbol
			}
			element_start = cursor + 1
		}
		cursor++
	}
	return symbols
}

fn uninstall_methods_order_metadata_problem(source string, call UninstallMethodsOrderCall) ?UninstallMethodsOrderProblem {
	mut metadata_index := -1
	for index, pair in call.pairs {
		if pair.method == 'on_upgrade' {
			metadata_index = index
			break
		}
	}
	if metadata_index < 0 {
		return none
	}
	metadata := call.pairs[metadata_index]
	requested := uninstall_methods_order_on_upgrade_symbols(source[metadata.value_begin..metadata.value_end])
	if requested.len == 0 {
		return UninstallMethodsOrderProblem{
			kind: 'fully_invalid_metadata'
			method: 'on_upgrade'
			begin_pos: metadata.value_begin
			end_pos: metadata.value_end
			message: uninstall_methods_order_invalid_metadata_message
		}
	}
	has_signal := call.pairs.any(it.method == 'signal')
	mut invalid := []string{}
	mut valid := []string{}
	for symbol in requested {
		if symbol == 'signal' && has_signal {
			if symbol !in valid {
				valid << symbol
			}
		} else {
			invalid << symbol
		}
	}
	if valid.len == 0 {
		remaining := call.pairs.filter(it.source_begin != metadata.source_begin)
		if remaining.len == 0 {
			// Only on_upgrade is present: report but do not attempt autocorrect
			// to avoid generating an empty uninstall hash or removing the stanza.
			return UninstallMethodsOrderProblem{
				kind: 'useless_metadata'
				method: 'on_upgrade'
				begin_pos: metadata.key_begin
				end_pos: metadata.key_end
				message: uninstall_methods_order_useless_metadata_message
			}
		}
		indentation := ' '.repeat(uninstall_methods_order_column(source, remaining[0].key_begin))
		return UninstallMethodsOrderProblem{
			kind: 'useless_metadata'
			method: 'on_upgrade'
			begin_pos: metadata.key_begin
			end_pos: metadata.key_end
			message: uninstall_methods_order_useless_metadata_message
			has_correction: true
			replacement_begin: call.hash_begin
			replacement_end: call.hash_end
			replacement: build_uninstall_methods_order_body(source, remaining, indentation)
		}
	}
	if invalid.len > 0 {
		symbols := invalid.map(':${it}').join(', ')
		return UninstallMethodsOrderProblem{
			kind: 'partially_invalid_metadata'
			method: 'on_upgrade'
			begin_pos: metadata.value_begin
			end_pos: metadata.value_end
			message: uninstall_methods_order_partial_metadata_message.replace('%s', symbols)
		}
	}
	return none
}

pub fn audit_uninstall_methods_order(source string) []UninstallMethodsOrderProblem {
	mut problems := []UninstallMethodsOrderProblem{}
	for call in uninstall_methods_order_calls(source) {
		problems << uninstall_methods_order_ordering_problems(source, call)
		if metadata := uninstall_methods_order_metadata_problem(source, call) {
			problems << metadata
		}
	}
	return problems
}

pub fn correct_uninstall_methods_order(source string) string {
	mut corrections := []UninstallMethodsOrderProblem{}
	mut correction_indices := map[string]int{}
	for problem in audit_uninstall_methods_order(source) {
		if !problem.has_correction {
			continue
		}
		key := '${problem.replacement_begin}:${problem.replacement_end}'
		if key in correction_indices {
			corrections[correction_indices[key]] = problem
			continue
		}
		correction_indices[key] = corrections.len
		corrections << problem
	}
	corrections.sort_with_compare(fn (left &UninstallMethodsOrderProblem, right &UninstallMethodsOrderProblem) int {
		return right.replacement_begin - left.replacement_begin
	})
	mut corrected := source
	for correction in corrections {
		corrected = corrected[..correction.replacement_begin] + correction.replacement + corrected[correction.replacement_end..]
	}
	return corrected
}

fn uninstall_methods_order_problem_value(problem UninstallMethodsOrderProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', problem.message, {
		'kind':              problem.kind
		'method':            problem.method
		'begin_pos':         problem.begin_pos.str()
		'end_pos':           problem.end_pos.str()
		'message':           problem.message
		'has_correction':    problem.has_correction.str()
		'replacement_begin': problem.replacement_begin.str()
		'replacement_end':   problem.replacement_end.str()
		'replacement':       problem.replacement
	})
}

fn uninstall_methods_order_problem_values(problems []UninstallMethodsOrderProblem) brew_runtime.Value {
	return brew_runtime.array_value(problems.map(uninstall_methods_order_problem_value(it)))
}

// Ruby method `on_send(node)` at line 27.
pub fn ruby_uninstall_methods_order_l27_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return uninstall_methods_order_problem_values(audit_uninstall_methods_order(source))
}

// Ruby method `check_ordering(hash_node, comments)` at line 47.
pub fn ruby_uninstall_methods_order_l47_d2_check_ordering(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return uninstall_methods_order_problem_values(audit_uninstall_methods_order(source).filter(it.kind == 'ordering'))
}

// Ruby method `report_and_correct_ordering_offense(method, hash_node, expected_order, comments)` at line 67.
pub fn ruby_uninstall_methods_order_l67_d3_report_and_correct_ordering_offense(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	problems := audit_uninstall_methods_order(source).filter(it.kind == 'ordering')
	return if problems.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		uninstall_methods_order_problem_value(problems[0])
	}
}

// Ruby method `check_metadata(hash_node, comments)` at line 86.
pub fn ruby_uninstall_methods_order_l86_d4_check_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return uninstall_methods_order_problem_values(audit_uninstall_methods_order(source).filter(it.kind != 'ordering'))
}

// Ruby method `report_fully_invalid_metadata(on_upgrade_pair)` at line 108.
pub fn ruby_uninstall_methods_order_l108_d5_report_fully_invalid_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	problems := audit_uninstall_methods_order(source).filter(it.kind == 'fully_invalid_metadata')
	return if problems.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		uninstall_methods_order_problem_value(problems[0])
	}
}

// Ruby method `report_and_correct_useless_metadata(` at line 121.
pub fn ruby_uninstall_methods_order_l121_d6_report_and_correct_useless_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	problems := audit_uninstall_methods_order(source).filter(it.kind == 'useless_metadata')
	return if problems.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		uninstall_methods_order_problem_value(problems[0])
	}
}

// Ruby method `report_partially_invalid_metadata(value_node, invalid_syms)` at line 146.
pub fn ruby_uninstall_methods_order_l146_d7_report_partially_invalid_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	problems := audit_uninstall_methods_order(source).filter(it.kind == 'partially_invalid_metadata')
	return if problems.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		uninstall_methods_order_problem_value(problems[0])
	}
}

// Ruby method `build_uninstall_body(pairs, comments, indentation)` at line 159.
pub fn ruby_uninstall_methods_order_l159_d8_build_uninstall_body(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	mut entries := args[0].as_string_array() or { args[0].as_string().split('\n') }
	if args.len > 2 {
		comments := args[1].as_string_array() or { []string{} }
		for index, comment in comments {
			if index < entries.len && comment != '' {
				entries[index] += ' ${comment}'
			}
		}
	}
	indentation := if args.len > 2 {
		args[2].as_string()
	} else if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}
	return brew_runtime.string_value(entries.join(',\n${indentation}'))
}

// Ruby method `on_upgrade_symbols(value_node)` at line 174.
pub fn ruby_uninstall_methods_order_l174_d9_on_upgrade_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	value_source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_array_value(uninstall_methods_order_on_upgrade_symbols(value_source))
}

// Ruby method `method_order_index(method_node)` at line 187.
pub fn ruby_uninstall_methods_order_l187_d10_method_order_index(args ...brew_runtime.Value) brew_runtime.Value {
	method := if args.len > 0 { args[0].as_string().trim_space().trim_left(':') } else { '' }
	return brew_runtime.int_value(uninstall_method_order_index(method))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks for the correct order of methods within the
// 10:       # 'uninstall' and 'zap' stanzas and validates related metadata.
// 11:       class UninstallMethodsOrder < Base
// 12:         extend AutoCorrector
// 13:         include HelperFunctions
// 14:
// 15:         MSG = "`%<method>s` method out of order"
// 16:
// 17:         # These keys are ignored when checking method order.
// 18:         # Mirrors AbstractUninstall::METADATA_KEYS.
// 19:         METADATA_KEYS = [:on_upgrade].freeze
// 20:
// 21:         USELESS_METADATA_MSG =
// 22:           "`on_upgrade` has no effect without matching `uninstall signal:` directive"
// 23:
// 24:         PARTIAL_METADATA_MSG = "`on_upgrade` lists %<symbols>s without matching `uninstall` directives"
// 25:
// 26:         sig { params(node: AST::SendNode).void }
// 27:         def on_send(node)
// 28:           return unless [:zap, :uninstall].include?(node.method_name)
// 29:
// 30:           hash_node = node.arguments.first
// 31:           return if hash_node.nil? || (!hash_node.is_a?(AST::Node) && !hash_node.hash_type?)
// 32:
// 33:           comments = processed_source.comments
// 34:
// 35:           check_ordering(hash_node, comments)
// 36:           check_metadata(hash_node, comments)
// 37:         end
// 38:
// 39:         private
// 40:
// 41:         sig {
// 42:           params(
// 43:             hash_node: AST::HashNode,
// 44:             comments:  T::Array[Parser::Source::Comment],
// 45:           ).void
// 46:         }
// 47:         def check_ordering(hash_node, comments)
// 48:           method_nodes = hash_node.pairs.map(&:key).reject do |method|
// 49:             name = method.children.first
// 50:             METADATA_KEYS.include?(name)
// 51:           end
// 52:
// 53:           expected_order = method_nodes.sort_by { |method| method_order_index(method) }
// 54:           method_nodes.each_with_index do |method, index|
// 55:             next if method == expected_order[index]
// 56:
// 57:             report_and_correct_ordering_offense(method, hash_node, expected_order, comments)
// 58:           end
// 59:         end
// 60:
// 61:         sig {
// 62:           params(method:         AST::Node,
// 63:                  hash_node:      AST::HashNode,
// 64:                  expected_order: T::Array[AST::Node],
// 65:                  comments:       T::Array[Parser::Source::Comment]).void
// 66:         }
// 67:         def report_and_correct_ordering_offense(method, hash_node, expected_order, comments)
// 68:           add_offense(method, message: format(MSG, method: method.children.first)) do |corrector|
// 69:             ordered_pairs = expected_order.map do |expected_method|
// 70:               hash_node.pairs.find { |pair| pair.key == expected_method }
// 71:             end
// 72:
// 73:             indentation = " " * (start_column(method) - line_start_column(method))
// 74:             new_code = build_uninstall_body(ordered_pairs, comments, indentation)
// 75:
// 76:             corrector.replace(hash_node.source_range, new_code)
// 77:           end
// 78:         end
// 79:
// 80:         sig {
// 81:           params(
// 82:             hash_node: AST::HashNode,
// 83:             comments:  T::Array[Parser::Source::Comment],
// 84:           ).void
// 85:         }
// 86:         def check_metadata(hash_node, comments)
// 87:           on_upgrade_pair = hash_node.pairs.find { |p| p.key.value == :on_upgrade }
// 88:           return unless on_upgrade_pair
// 89:
// 90:           requested = on_upgrade_symbols(on_upgrade_pair.value)
// 91:           return report_fully_invalid_metadata(on_upgrade_pair) if requested.empty?
// 92:
// 93:           available = []
// 94:           available << :signal if hash_node.pairs.any? { |p| p.key.value == :signal }
// 95:
// 96:           valid_syms   = requested & available
// 97:           invalid_syms = requested - available
// 98:
// 99:           if valid_syms.empty?
// 100:             remaining_pairs = hash_node.pairs.reject { |p| p == on_upgrade_pair }
// 101:             report_and_correct_useless_metadata(hash_node, on_upgrade_pair, remaining_pairs, comments)
// 102:           elsif invalid_syms.any?
// 103:             report_partially_invalid_metadata(on_upgrade_pair.value, invalid_syms)
// 104:           end
// 105:         end
// 106:
// 107:         sig { params(on_upgrade_pair: AST::PairNode).void }
// 108:         def report_fully_invalid_metadata(on_upgrade_pair)
// 109:           add_offense(on_upgrade_pair.value,
// 110:                       message: "`on_upgrade` value must be :signal or an array [:signal]")
// 111:         end
// 112:
// 113:         sig {
// 114:           params(
// 115:             hash_node:       AST::HashNode,
// 116:             on_upgrade_pair: AST::PairNode,
// 117:             remaining_pairs: T::Array[AST::PairNode],
// 118:             comments:        T::Array[Parser::Source::Comment],
// 119:           ).void
// 120:         }
// 121:         def report_and_correct_useless_metadata(
// 122:           hash_node,
// 123:           on_upgrade_pair,
// 124:           remaining_pairs,
// 125:           comments
// 126:         )
// 127:           if remaining_pairs.empty?
// 128:             # Only on_upgrade is present: report but do not attempt autocorrect
// 129:             # to avoid generating an empty uninstall hash or removing the stanza.
// 130:             add_offense(on_upgrade_pair.key, message: USELESS_METADATA_MSG)
// 131:             return
// 132:           end
// 133:
// 134:           add_offense(on_upgrade_pair.key, message: USELESS_METADATA_MSG) do |corrector|
// 135:             first_pair = remaining_pairs.fetch(0)
// 136:             indentation = " " * (start_column(first_pair.key) - line_start_column(first_pair.key))
// 137:
// 138:             new_code = build_uninstall_body(remaining_pairs, comments, indentation)
// 139:             corrector.replace(hash_node.source_range, new_code)
// 140:           end
// 141:         end
// 142:
// 143:         sig {
// 144:           params(value_node: AST::Node, invalid_syms: T::Array[Symbol]).void
// 145:         }
// 146:         def report_partially_invalid_metadata(value_node, invalid_syms)
// 147:           symbols_str = invalid_syms.map { |s| ":#{s}" }.join(", ")
// 148:           add_offense(value_node,
// 149:                       message: format(PARTIAL_METADATA_MSG, symbols: symbols_str))
// 150:         end
// 151:
// 152:         sig {
// 153:           params(
// 154:             pairs:       T::Array[AST::PairNode],
// 155:             comments:    T::Array[Parser::Source::Comment],
// 156:             indentation: String,
// 157:           ).returns(String)
// 158:         }
// 159:         def build_uninstall_body(pairs, comments, indentation)
// 160:           pairs.map do |pair|
// 161:             source = pair.source
// 162:
// 163:             # Find and attach a comment on the same line as the pair, if any
// 164:             inline_comment = comments.find do |comment|
// 165:               comment.location.line == pair.loc.line &&
// 166:                 comment.location.column > pair.loc.column
// 167:             end
// 168:
// 169:             inline_comment ? "#{source} #{inline_comment.text}" : source
// 170:           end.join(",\n#{indentation}")
// 171:         end
// 172:
// 173:         sig { params(value_node: AST::Node).returns(T::Array[Symbol]) }
// 174:         def on_upgrade_symbols(value_node)
// 175:           if value_node.sym_type?
// 176:             [T.cast(value_node, AST::SymbolNode).value]
// 177:           elsif value_node.array_type?
// 178:             value_node.children.select(&:sym_type?).map do |child|
// 179:               T.cast(child, AST::SymbolNode).value
// 180:             end
// 181:           else
// 182:             []
// 183:           end
// 184:         end
// 185:
// 186:         sig { params(method_node: AST::SymbolNode).returns(Integer) }
// 187:         def method_order_index(method_node)
// 188:           method_name = method_node.children.first
// 189:           RuboCop::Cask::Constants::UNINSTALL_METHODS_ORDER.index(method_name) || -1
// 190:         end
// 191:       end
// 192:     end
// 193:   end
// 194: end
