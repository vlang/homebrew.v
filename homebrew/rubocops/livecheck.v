module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/livecheck.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `audit_formula(formula_nodes)` at line 15.
pub fn ruby_livecheck_l15_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_skip(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 45.
pub fn ruby_livecheck_l45_d2_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_url_provided(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 69.
pub fn ruby_livecheck_l69_d3_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_url_symbol(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 128.
pub fn ruby_livecheck_l128_d4_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_regex_parentheses(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 156.
pub fn ruby_livecheck_l156_d5_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_regex_extension(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 184.
pub fn ruby_livecheck_l184_d6_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_livecheck_regex_if_page_match(source).map(livecheck_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 213.
pub fn ruby_livecheck_l213_d7_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	allowlisted := args.len > 1 && args[1].bool_data
	return ruby.array_value(audit_livecheck_regex_case_insensitive(source, allowlisted).map(livecheck_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop ensures that no other livecheck information is provided for
// 10:       # skipped formulae.
// 11:       class LivecheckSkip < FormulaCop
// 12:         extend AutoCorrector
// 13:
// 14:         sig { override.params(formula_nodes: FormulaNodes).void }
// 15:         def audit_formula(formula_nodes)
// 16:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 17:           return if livecheck_node.blank?
// 18:
// 19:           skip = T.let(find_every_method_call_by_name(livecheck_node, :skip).first,
// 20:                        T.nilable(T.any(RuboCop::AST::Node, String)))
// 21:           return if skip.blank?
// 22:
// 23:           return if find_every_method_call_by_name(livecheck_node).length < 3
// 24:
// 25:           offending_node(livecheck_node)
// 26:           problem "Skipped formulae must not contain other livecheck information." do |corrector|
// 27:             skip = find_every_method_call_by_name(livecheck_node, :skip).fetch(0)
// 28:             skip = find_strings(skip).fetch(0)
// 29:             skip = string_content(skip) if skip.present?
// 30:             corrector.replace(
// 31:               livecheck_node.source_range,
// 32:               <<~EOS.strip,
// 33:                 livecheck do
// 34:                     skip#{" \"#{skip}\"" if skip.present?}
// 35:                   end
// 36:               EOS
// 37:             )
// 38:           end
// 39:         end
// 40:       end
// 41:
// 42:       # This cop ensures that a `url` is specified in the `livecheck` block.
// 43:       class LivecheckUrlProvided < FormulaCop
// 44:         sig { override.params(formula_nodes: FormulaNodes).void }
// 45:         def audit_formula(formula_nodes)
// 46:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 47:           return unless livecheck_node
// 48:
// 49:           url_node = find_every_method_call_by_name(livecheck_node, :url).first
// 50:           return if url_node
// 51:
// 52:           # A regex and/or strategy is specific to a particular URL, so we
// 53:           # should require an explicit URL.
// 54:           regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 55:           strategy_node = find_every_method_call_by_name(livecheck_node, :strategy).first
// 56:           return if !regex_node && !strategy_node
// 57:
// 58:           offending_node(livecheck_node)
// 59:           problem "A `url` should be provided when `regex` or `strategy` are used."
// 60:         end
// 61:       end
// 62:
// 63:       # This cop ensures that a supported symbol (`head`, `stable, `homepage`)
// 64:       # is used when the livecheck `url` is identical to one of these formula URLs.
// 65:       class LivecheckUrlSymbol < FormulaCop
// 66:         extend AutoCorrector
// 67:
// 68:         sig { override.params(formula_nodes: FormulaNodes).void }
// 69:         def audit_formula(formula_nodes)
// 70:           body_node = formula_nodes.body_node
// 71:           livecheck_node = find_block(body_node, :livecheck)
// 72:           return if livecheck_node.blank?
// 73:
// 74:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 75:           return if skip.present?
// 76:
// 77:           livecheck_url_node = find_every_method_call_by_name(livecheck_node, :url).first
// 78:           return if livecheck_url_node.blank?
// 79:
// 80:           livecheck_url = find_strings(livecheck_url_node).first
// 81:           return if livecheck_url.blank?
// 82:
// 83:           livecheck_url = string_content(livecheck_url)
// 84:
// 85:           head = find_every_method_call_by_name(body_node, :head).first
// 86:           head_url = find_strings(head).first
// 87:
// 88:           if head.present? && head_url.blank?
// 89:             head = find_every_method_call_by_name(head, :url).first
// 90:             head_url = find_strings(head).first
// 91:           end
// 92:
// 93:           head_url = string_content(head_url) if head_url.present?
// 94:
// 95:           stable = find_every_method_call_by_name(body_node, :url).first
// 96:           stable_url = find_strings(stable).first
// 97:
// 98:           if stable_url.blank?
// 99:             stable = find_every_method_call_by_name(body_node, :stable).first
// 100:             stable = find_every_method_call_by_name(stable, :url).first
// 101:             stable_url = find_strings(stable).first
// 102:           end
// 103:
// 104:           stable_url = string_content(stable_url) if stable_url.present?
// 105:
// 106:           homepage = find_every_method_call_by_name(body_node, :homepage).first
// 107:           homepage_url = string_content(find_strings(homepage).fetch(0)) if homepage.present?
// 108:
// 109:           formula_urls = { head: head_url, stable: stable_url, homepage: homepage_url }.compact
// 110:
// 111:           formula_urls.each do |symbol, url|
// 112:             next if url != livecheck_url && url != "#{livecheck_url}/" && "#{url}/" != livecheck_url
// 113:
// 114:             offending_node(livecheck_url_node)
// 115:             problem "Use `url :#{symbol}`" do |corrector|
// 116:               corrector.replace(livecheck_url_node.source_range, "url :#{symbol}")
// 117:             end
// 118:             break
// 119:           end
// 120:         end
// 121:       end
// 122:
// 123:       # This cop ensures that the `regex` call in the `livecheck` block uses parentheses.
// 124:       class LivecheckRegexParentheses < FormulaCop
// 125:         extend AutoCorrector
// 126:
// 127:         sig { override.params(formula_nodes: FormulaNodes).void }
// 128:         def audit_formula(formula_nodes)
// 129:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 130:           return if livecheck_node.blank?
// 131:
// 132:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 133:           return if skip.present?
// 134:
// 135:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 136:           return if livecheck_regex_node.blank?
// 137:
// 138:           return if parentheses?(livecheck_regex_node)
// 139:
// 140:           offending_node(livecheck_regex_node)
// 141:           problem "The `regex` call should always use parentheses." do |corrector|
// 142:             pattern = livecheck_regex_node.source.split[1..].join
// 143:             corrector.replace(livecheck_regex_node.source_range, "regex(#{pattern})")
// 144:           end
// 145:         end
// 146:       end
// 147:
// 148:       # This cop ensures that the pattern provided to livecheck's `regex` uses `\.t` instead of
// 149:       # `\.tgz`, `\.tar.gz` and variants.
// 150:       class LivecheckRegexExtension < FormulaCop
// 151:         extend AutoCorrector
// 152:
// 153:         TAR_PATTERN = /\\?\.t(ar|(g|l|x)z$|[bz2]{2,4}$)(\\?\.((g|l|x)z)|[bz2]{2,4}|Z)?$/i
// 154:
// 155:         sig { override.params(formula_nodes: FormulaNodes).void }
// 156:         def audit_formula(formula_nodes)
// 157:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 158:           return if livecheck_node.blank?
// 159:
// 160:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 161:           return if skip.present?
// 162:
// 163:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 164:           return if livecheck_regex_node.blank?
// 165:
// 166:           regex_node = livecheck_regex_node.descendants.first
// 167:           pattern = string_content(find_strings(regex_node).fetch(0))
// 168:           match = pattern.match(TAR_PATTERN)
// 169:           return if match.blank?
// 170:
// 171:           offending_node(regex_node)
// 172:           problem "Use `\\.t` instead of `#{match}`" do |corrector|
// 173:             node = find_strings(regex_node).fetch(0)
// 174:             correct = node.source.gsub(TAR_PATTERN, "\\.t")
// 175:             corrector.replace(node.source_range, correct)
// 176:           end
// 177:         end
// 178:       end
// 179:
// 180:       # This cop ensures that a `regex` is provided when `strategy :page_match` is specified
// 181:       # in the `livecheck` block.
// 182:       class LivecheckRegexIfPageMatch < FormulaCop
// 183:         sig { override.params(formula_nodes: FormulaNodes).void }
// 184:         def audit_formula(formula_nodes)
// 185:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 186:           return if livecheck_node.blank?
// 187:
// 188:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 189:           return if skip.present?
// 190:
// 191:           livecheck_strategy_node = find_every_method_call_by_name(livecheck_node, :strategy).first
// 192:           return if livecheck_strategy_node.blank?
// 193:
// 194:           strategy = livecheck_strategy_node.descendants.first.source
// 195:           return if strategy != ":page_match"
// 196:
// 197:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 198:           return if livecheck_regex_node.present?
// 199:
// 200:           offending_node(livecheck_node)
// 201:           problem "A `regex` is required if `strategy :page_match` is present."
// 202:         end
// 203:       end
// 204:
// 205:       # This cop ensures that the `regex` provided to livecheck is case-insensitive,
// 206:       # unless sensitivity is explicitly required for proper matching.
// 207:       class LivecheckRegexCaseInsensitive < FormulaCop
// 208:         extend AutoCorrector
// 209:
// 210:         MSG = "Regexes should be case-insensitive unless sensitivity is explicitly required for proper matching."
// 211:
// 212:         sig { override.params(formula_nodes: FormulaNodes).void }
// 213:         def audit_formula(formula_nodes)
// 214:           return if tap_style_exception? :regex_case_sensitive_allowlist
// 215:
// 216:           livecheck_node = find_block(formula_nodes.body_node, :livecheck)
// 217:           return if livecheck_node.blank?
// 218:
// 219:           skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
// 220:           return if skip.present?
// 221:
// 222:           livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
// 223:           return if livecheck_regex_node.blank?
// 224:
// 225:           regex_node = livecheck_regex_node.descendants.first
// 226:           options_node = regex_node.regopt
// 227:           return if options_node.source.include?("i")
// 228:
// 229:           offending_node(regex_node)
// 230:           problem MSG do |corrector|
// 231:             node = regex_node.regopt
// 232:             corrector.replace(node.source_range, "i#{node.source}".chars.sort.join)
// 233:           end
// 234:         end
// 235:       end
// 236:     end
// 237:   end
// 238: end
