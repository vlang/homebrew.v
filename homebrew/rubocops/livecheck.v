module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/livecheck.rb`.
pub struct LivecheckProblem {
pub:
	kind        string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct LivecheckCall {
	name        string
	source      string
	argument    string
	begin_pos   int
	end_pos     int
	parentheses bool
}

struct LivecheckBlock {
	begin_pos  int
	end_pos    int
	body_begin int
	body_end   int
	indent     int
	calls      []LivecheckCall
}

struct LivecheckRegexLiteral {
	pattern       string
	begin_pos     int
	end_pos       int
	options       string
	options_begin int
	options_end   int
}

fn livecheck_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn livecheck_code_end(line string) int {
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
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			return index
		}
	}
	return line.len
}

fn livecheck_call_from_line(line string, line_start int) ?LivecheckCall {
	code_end := livecheck_code_end(line)
	code := line[..code_end]
	indent := code.len - code.trim_left(' \t').len
	trimmed := code[indent..].trim_right(' \t')
	if trimmed == '' {
		return none
	}
	mut name_end := 0
	for name_end < trimmed.len && livecheck_identifier(trimmed[name_end]) {
		name_end++
	}
	if name_end == 0 {
		return none
	}
	name := trimmed[..name_end]
	mut argument_start := name_end
	for argument_start < trimmed.len && trimmed[argument_start] in [` `, `\t`] {
		argument_start++
	}
	parentheses := argument_start < trimmed.len && trimmed[argument_start] == `(`
	if parentheses {
		argument_start++
	}
	mut argument_end := trimmed.len
	if parentheses {
		for argument_end > argument_start && trimmed[argument_end - 1].is_space() {
			argument_end--
		}
		if argument_end > argument_start && trimmed[argument_end - 1] == `)` {
			argument_end--
		}
	}
	return LivecheckCall{
		name: name
		source: trimmed
		argument: trimmed[argument_start..argument_end].trim_space()
		begin_pos: line_start + indent
		end_pos: line_start + indent + trimmed.len
		parentheses: parentheses
	}
}

fn find_livecheck_block(source string) ?LivecheckBlock {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		indent := line.len - line.trim_left(' \t').len
		trimmed := line.trim_space()
		if trimmed.starts_with('livecheck do') && (trimmed.len == 'livecheck do'.len || trimmed['livecheck do'.len] in [
			` `,
			`\t`,
			`#`,
		]) {
			body_begin := if newline < 0 { line_end } else { line_end + 1 }
			mut close_start := body_begin
			mut calls := []LivecheckCall{}
			for close_start < source.len {
				close_newline := source[close_start..].index_u8(`\n`)
				close_end := if close_newline < 0 {
					source.len
				} else {
					close_start + close_newline
				}
				close_line := source[close_start..close_end]
				close_indent := close_line.len - close_line.trim_left(' \t').len
				if close_indent == indent && close_line.trim_space() == 'end' {
					return LivecheckBlock{
						begin_pos: line_start + indent
						end_pos: close_end
						body_begin: body_begin
						body_end: close_start
						indent: indent
						calls: calls
					}
				}
				if call := livecheck_call_from_line(close_line, close_start) {
					calls << call
				}
				if close_newline < 0 {
					break
				}
				close_start = close_end + 1
			}
			return LivecheckBlock{
				begin_pos: line_start + indent
				end_pos: source.len
				body_begin: body_begin
				body_end: source.len
				indent: indent
				calls: calls
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn livecheck_unquote(source string) ?string {
	trimmed := source.trim_space()
	if trimmed.len < 2 || trimmed[0] !in [`'`, `"`] || trimmed[trimmed.len - 1] != trimmed[0] {
		return none
	}
	return trimmed[1..trimmed.len - 1]
}

fn livecheck_first_call(block LivecheckBlock, name string) ?LivecheckCall {
	for call in block.calls {
		if call.name == name {
			return call
		}
	}
	return none
}

fn livecheck_regex_literal(source string, call LivecheckCall) ?LivecheckRegexLiteral {
	relative := call.source.index('%r') or { return none }
	begin_pos := call.begin_pos + relative
	delimiter_position := begin_pos + 2
	if delimiter_position >= source.len {
		return none
	}
	open := source[delimiter_position]
	close := match open {
		`{` { `}` }
		`(` { `)` }
		`[` { `]` }
		`<` { `>` }
		else { open }
	}
	mut cursor := delimiter_position + 1
	mut escaped := false
	mut depth := 1
	for cursor < call.end_pos {
		character := source[cursor]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if open != close && character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				mut options_end := cursor + 1
				for options_end < call.end_pos && source[options_end].is_letter() {
					options_end++
				}
				return LivecheckRegexLiteral{
					pattern: source[delimiter_position + 1..cursor]
					begin_pos: begin_pos
					end_pos: options_end
					options: source[cursor + 1..options_end]
					options_begin: cursor + 1
					options_end: options_end
				}
			}
		}
		cursor++
	}
	return none
}

fn livecheck_problem_value(problem LivecheckProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

fn livecheck_apply(source string, problems []LivecheckProblem) string {
	mut corrections := problems.filter(it.replacement != '')
	corrections.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in corrections {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

pub fn audit_livecheck_skip(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	skip := livecheck_first_call(block, 'skip') or { return []LivecheckProblem{} }
	if block.calls.len < 2 {
		return []LivecheckProblem{}
	}
	reason := livecheck_unquote(skip.argument) or { '' }
	skip_line := if reason == '' { 'skip' } else { 'skip "${reason}"' }
	replacement := 'livecheck do\n${' '.repeat(block.indent + 2)}${skip_line}\n${' '.repeat(block.indent)}end'
	return [LivecheckProblem{
		kind: 'skip_with_information'
		begin_pos: block.begin_pos
		end_pos: block.end_pos
		message: 'Skipped formulae must not contain other livecheck information.'
		replacement: replacement
	}]
}

pub fn audit_livecheck_url_provided(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if _ := livecheck_first_call(block, 'url') {
		return []LivecheckProblem{}
	}
	if livecheck_first_call(block, 'regex') == none && livecheck_first_call(block, 'strategy') == none {
		return []LivecheckProblem{}
	}
	return [LivecheckProblem{
		kind: 'url_required'
		begin_pos: block.begin_pos
		end_pos: block.end_pos
		message: 'A `url` should be provided when `regex` or `strategy` are used.'
	}]
}

fn livecheck_nested_formula_url(source string, block_start int, block_indent int) ?string {
	mut line_start := block_start
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		indent := line.len - line.trim_left(' \t').len
		if line_start > block_start && indent == block_indent && line.trim_space() == 'end' {
			return none
		}
		if line_start > block_start && indent > block_indent {
			if call := livecheck_call_from_line(line, line_start) {
				if call.name == 'url' {
					if value := livecheck_unquote(call.argument) {
						return value
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn livecheck_formula_url(source string, block LivecheckBlock, name string) ?string {
	fallback_block := if name == 'url' { 'stable' } else { name }
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if line_start >= block.begin_pos && line_start <= block.end_pos {
			line_start = if newline < 0 { source.len } else { line_end + 1 }
			continue
		}
		line := source[line_start..line_end]
		indent := line.len - line.trim_left(' \t').len
		if indent == block.indent {
			if call := livecheck_call_from_line(line, line_start) {
				if call.name == name {
					if value := livecheck_unquote(call.argument) {
						return value
					}
				}
				if call.name == fallback_block && call.argument.trim_space().ends_with('do') {
					if value := livecheck_nested_formula_url(source, line_start, indent) {
						return value
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn livecheck_urls_equal(first string, second string) bool {
	return first == second || first == second + '/' || first + '/' == second
}

pub fn audit_livecheck_url_symbol(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if livecheck_first_call(block, 'skip') != none {
		return []LivecheckProblem{}
	}
	url_call := livecheck_first_call(block, 'url') or { return []LivecheckProblem{} }
	livecheck_url := livecheck_unquote(url_call.argument) or { return []LivecheckProblem{} }
	for symbol in ['head', 'stable', 'homepage'] {
		name := if symbol == 'stable' { 'url' } else { symbol }
		formula_url := livecheck_formula_url(source, block, name) or { continue }
		if livecheck_urls_equal(formula_url, livecheck_url) {
			return [LivecheckProblem{
				kind: 'url_symbol'
				begin_pos: url_call.begin_pos
				end_pos: url_call.end_pos
				message: 'Use `url :${symbol}`'
				replacement: 'url :${symbol}'
			}]
		}
	}
	return []LivecheckProblem{}
}

pub fn audit_livecheck_regex_parentheses(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if livecheck_first_call(block, 'skip') != none {
		return []LivecheckProblem{}
	}
	call := livecheck_first_call(block, 'regex') or { return []LivecheckProblem{} }
	if call.parentheses {
		return []LivecheckProblem{}
	}
	pattern := call.argument.split_any(' \t').join('')
	return [LivecheckProblem{
		kind: 'regex_parentheses'
		begin_pos: call.begin_pos
		end_pos: call.end_pos
		message: 'The `regex` call should always use parentheses.'
		replacement: 'regex(${pattern})'
	}]
}

fn livecheck_bz2_sequence(value string) bool {
	return value.len >= 2 && value.len <= 4 && value.bytes().all(it in [`b`, `z`, `2`])
}

fn livecheck_tar_suffix_match(candidate string) bool {
	lower := candidate.to_lower()
	mut cursor := 0
	if cursor < lower.len && lower[cursor] == `\\` {
		cursor++
	}
	if cursor + 2 > lower.len || lower[cursor] != `.` || lower[cursor + 1] != `t` {
		return false
	}
	cursor += 2
	remainder := lower[cursor..]
	if remainder.starts_with('ar') {
		following := remainder[2..]
		if following == '' || following == 'z' || livecheck_bz2_sequence(following) {
			return true
		}
		mut extension := following
		if extension.starts_with('\\') {
			extension = extension[1..]
		}
		return extension.len == 3 && extension[0] == `.` && extension[2] == `z` && extension[1] in [
			`g`,
			`l`,
			`x`,
		]
	}
	return (remainder.len == 2 && remainder[1] == `z` && remainder[0] in [`g`, `l`, `x`]) || livecheck_bz2_sequence(remainder)
}

fn livecheck_tar_suffix(pattern string) ?string {
	for start in 0 .. pattern.len {
		candidate := pattern[start..]
		if livecheck_tar_suffix_match(candidate) {
			return candidate
		}
	}
	return none
}

pub fn audit_livecheck_regex_extension(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if livecheck_first_call(block, 'skip') != none {
		return []LivecheckProblem{}
	}
	call := livecheck_first_call(block, 'regex') or { return []LivecheckProblem{} }
	literal := livecheck_regex_literal(source, call) or { return []LivecheckProblem{} }
	suffix := livecheck_tar_suffix(literal.pattern) or { return []LivecheckProblem{} }
	pattern_end := literal.options_begin - 1
	begin_pos := pattern_end - suffix.len
	return [LivecheckProblem{
		kind: 'regex_extension'
		begin_pos: literal.begin_pos
		end_pos: literal.end_pos
		message: 'Use `\\.t` instead of `${suffix}`'
		replacement: source[literal.begin_pos..begin_pos] + '\\.t' + source[pattern_end..literal.end_pos]
	}]
}

pub fn audit_livecheck_regex_if_page_match(source string) []LivecheckProblem {
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if livecheck_first_call(block, 'skip') != none || livecheck_first_call(block, 'regex') != none {
		return []LivecheckProblem{}
	}
	strategy := livecheck_first_call(block, 'strategy') or { return []LivecheckProblem{} }
	if strategy.argument != ':page_match' {
		return []LivecheckProblem{}
	}
	return [LivecheckProblem{
		kind: 'page_match_regex_required'
		begin_pos: block.begin_pos
		end_pos: block.end_pos
		message: 'A `regex` is required if `strategy :page_match` is present.'
	}]
}

pub fn audit_livecheck_regex_case_insensitive(source string, allowlisted bool) []LivecheckProblem {
	if allowlisted {
		return []LivecheckProblem{}
	}
	block := find_livecheck_block(source) or { return []LivecheckProblem{} }
	if livecheck_first_call(block, 'skip') != none {
		return []LivecheckProblem{}
	}
	call := livecheck_first_call(block, 'regex') or { return []LivecheckProblem{} }
	literal := livecheck_regex_literal(source, call) or { return []LivecheckProblem{} }
	if literal.options.contains('i') {
		return []LivecheckProblem{}
	}
	mut options := (literal.options + 'i').bytes()
	options.sort()
	return [LivecheckProblem{
		kind: 'regex_case_insensitive'
		begin_pos: literal.begin_pos
		end_pos: literal.end_pos
		message: 'Regexes should be case-insensitive unless sensitivity is explicitly required for proper matching.'
		replacement: source[literal.begin_pos..literal.options_begin] + options.bytestr()
	}]
}

pub fn correct_livecheck(source string, problems []LivecheckProblem) string {
	return livecheck_apply(source, problems)
}
