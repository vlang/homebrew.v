module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/class.rb`.
// The original source is retained below until every stub has a typed V body.
pub const deprecated_formula_classes = [
	'GithubGistFormula',
	'ScriptFileFormula',
	'AmazonWebServicesFormula',
]

pub struct ClassAuditProblem {
pub:
	kind        string
	call_name   string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct FormulaTestCall {
pub:
	name          string
	begin_pos     int
	end_pos       int
	first_source  string
	first_content string
	first_begin   int
	first_end     int
	second_source string
	second_begin  int
	second_end    int
}

struct FormulaTestBlock {
	begin_pos  int
	line_end   int
	body_begin int
	body_end   int
}

fn class_declaration_parent(source string) ?[]string {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		code := line.all_before('#')
		trimmed := code.trim_space()
		if trimmed.starts_with('class ') {
			separator := trimmed.index('<') or { return none }
			mut parent_offset := separator + 1
			for parent_offset < trimmed.len && trimmed[parent_offset].is_space() {
				parent_offset++
			}
			mut parent_end := parent_offset
			for parent_end < trimmed.len && (trimmed[parent_end].is_alnum() || trimmed[parent_end] in [
				`_`,
				`:`,
			]) {
				parent_end++
			}
			parent := trimmed[parent_offset..parent_end].trim_space()
			position := line_start + code.index(parent) or { return none }
			return [parent, position.str(), (position + parent.len).str()]
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

pub fn audit_formula_class_name(source string) []ClassAuditProblem {
	declaration := class_declaration_parent(source) or { return []ClassAuditProblem{} }
	parent := declaration[0]
	if parent !in deprecated_formula_classes {
		return []ClassAuditProblem{}
	}
	return [ClassAuditProblem{
		kind: 'deprecated_class'
		begin_pos: declaration[1].int()
		end_pos: declaration[2].int()
		message: '`${parent}` is deprecated, use `Formula` instead'
		replacement: 'Formula'
	}]
}

fn class_apply_corrections(source string, problems []ClassAuditProblem) string {
	mut corrections := problems.filter(it.replacement != '')
	corrections.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in corrections {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

pub fn correct_formula_class_name(source string) string {
	return class_apply_corrections(source, audit_formula_class_name(source))
}

fn formula_test_block(source string) ?FormulaTestBlock {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.trim_space()
		if trimmed.starts_with('test do') && (trimmed.len == 'test do'.len || trimmed['test do'.len] in [
			` `,
			`\t`,
			`#`,
			`;`,
		]) {
			indent := line.len - line.trim_left(' \t').len
			mut close_start := if newline < 0 { source.len } else { line_end + 1 }
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
					return FormulaTestBlock{
						begin_pos: line_start + indent
						line_end: line_end
						body_begin: if newline < 0 { line_end } else { line_end + 1 }
						body_end: close_start
					}
				}
				if close_newline < 0 {
					break
				}
				close_start = close_end + 1
			}
			return FormulaTestBlock{
				begin_pos: line_start + indent
				line_end: line_end
				body_begin: line_end
				body_end: source.len
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn formula_test_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn formula_test_quote_end(source string, begin_pos int, limit int) int {
	quote := source[begin_pos]
	mut cursor := begin_pos + 1
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

fn formula_test_trim_range(source string, begin_pos int, end_pos int) []int {
	mut start := begin_pos
	mut end := end_pos
	for start < end && source[start].is_space() {
		start++
	}
	for end > start && source[end - 1].is_space() {
		end--
	}
	return [start, end]
}

fn formula_test_argument_ranges(source string, begin_pos int, end_pos int) [][]int {
	mut ranges := [][]int{}
	mut argument_start := begin_pos
	mut cursor := begin_pos
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	for cursor <= end_pos {
		at_end := cursor == end_pos
		if !at_end {
			character := source[cursor]
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
			} else if character in [`(`, `[`, `{`] {
				depth++
			} else if character in [`)`, `]`, `}`] && depth > 0 {
				depth--
			}
		}
		if at_end || (source[cursor] == `,` && quote == 0 && depth == 0) {
			range := formula_test_trim_range(source, argument_start, cursor)
			if range[0] < range[1] {
				ranges << range
			}
			argument_start = cursor + 1
		}
		cursor++
	}
	return ranges
}

fn formula_test_string_content(source string) string {
	if source.len < 2 || source[0] !in [`'`, `"`] || source[source.len - 1] != source[0] {
		return ''
	}
	return source[1..source.len - 1]
}

fn formula_test_call_at(source string, begin_pos int, body_end int, name string) ?FormulaTestCall {
	after_name := begin_pos + name.len
	if after_name < source.len && formula_test_identifier(source[after_name]) {
		return none
	}
	if begin_pos > 0 {
		mut previous := begin_pos - 1
		for previous > 0 && source[previous].is_space() && source[previous] != `\n` {
			previous--
		}
		if formula_test_identifier(source[begin_pos - 1]) || source[previous] == `.` {
			return none
		}
	}
	mut cursor := after_name
	for cursor < body_end && source[cursor] in [` `, `\t`] {
		cursor++
	}
	mut arguments_begin := cursor
	mut arguments_end := cursor
	mut call_end := cursor
	if cursor < body_end && source[cursor] == `(` {
		arguments_begin = cursor + 1
		mut depth := 1
		cursor++
		for cursor < body_end && depth > 0 {
			if source[cursor] in [`'`, `"`] {
				cursor = formula_test_quote_end(source, cursor, body_end)
				continue
			}
			if source[cursor] == `(` {
				depth++
			} else if source[cursor] == `)` {
				depth--
				if depth == 0 {
					arguments_end = cursor
					call_end = cursor + 1
					break
				}
			}
			cursor++
		}
		if depth > 0 {
			arguments_end = body_end
			call_end = body_end
		}
	} else {
		line_relative := source[cursor..body_end].index_u8(`\n`)
		arguments_end = if line_relative < 0 { body_end } else { cursor + line_relative }
		call_end = arguments_end
	}
	ranges := formula_test_argument_ranges(source, arguments_begin, arguments_end)
	first := if ranges.len > 0 { source[ranges[0][0]..ranges[0][1]] } else { '' }
	second := if ranges.len > 1 { source[ranges[1][0]..ranges[1][1]] } else { '' }
	return FormulaTestCall{
		name: name
		begin_pos: begin_pos
		end_pos: call_end
		first_source: first
		first_content: formula_test_string_content(first)
		first_begin: if ranges.len > 0 { ranges[0][0] } else { 0 }
		first_end: if ranges.len > 0 { ranges[0][1] } else { 0 }
		second_source: second
		second_begin: if ranges.len > 1 { ranges[1][0] } else { 0 }
		second_end: if ranges.len > 1 { ranges[1][1] } else { 0 }
	}
}

pub fn find_formula_test_calls(source string) []FormulaTestCall {
	block := formula_test_block(source) or { return []FormulaTestCall{} }
	mut calls := []FormulaTestCall{}
	mut cursor := block.body_begin
	for cursor < block.body_end {
		if source[cursor] == `#` {
			newline := source[cursor..block.body_end].index_u8(`\n`)
			cursor = if newline < 0 { block.body_end } else { cursor + newline + 1 }
			continue
		}
		if source[cursor] in [`'`, `"`] {
			cursor = formula_test_quote_end(source, cursor, block.body_end)
			continue
		}
		mut found := false
		for name in ['system', 'shell_output', 'pipe_output'] {
			if source[cursor..block.body_end].starts_with(name) {
				if call := formula_test_call_at(source, cursor, block.body_end, name) {
					calls << call
					cursor = if call.end_pos > cursor { call.end_pos } else { cursor + name.len }
					found = true
					break
				}
			}
		}
		if !found {
			cursor++
		}
	}
	return calls
}

fn formula_test_significant_body(source string, block FormulaTestBlock) string {
	mut lines := []string{}
	for line in source[block.body_begin..block.body_end].split_into_lines() {
		code := line.all_before('#').trim_space()
		if code != '' {
			lines << code
		}
	}
	return lines.join('\n')
}

pub fn audit_formula_test(source string) []ClassAuditProblem {
	block := formula_test_block(source) or { return []ClassAuditProblem{} }
	body := formula_test_significant_body(source, block)
	if body == '' {
		return [ClassAuditProblem{
			kind: 'empty_test'
			begin_pos: block.begin_pos
			end_pos: block.line_end
			message: '`test do` should not be empty'
		}]
	}
	mut problems := []ClassAuditProblem{}
	if body == 'true' {
		problems << ClassAuditProblem{
			kind: 'false_test'
			begin_pos: block.begin_pos
			end_pos: block.line_end
			message: '`test do` should contain a real test'
		}
	}
	for call in find_formula_test_calls(source) {
		mut match_start := call.first_content.index('/usr/local/sbin') or { -1 }
		mut directory := 'sbin'
		if match_start < 0 {
			match_start = call.first_content.index('/usr/local/bin') or { -1 }
			directory = 'bin'
		}
		if match_start >= 0 {
			matched := '/usr/local/${directory}'
			problems << ClassAuditProblem{
				kind: 'usr_local'
				call_name: call.name
				begin_pos: call.first_begin
				end_pos: call.first_end
				message: 'Use `#{${directory}}` instead of `${matched}` in `${call.name}`'
				replacement: call.first_source.replace_once(matched, '#{${directory}}')
			}
		}
		if call.name == 'shell_output' && call.second_source == '0' {
			mut removal_begin := call.second_begin
			for removal_begin > call.first_end && source[removal_begin - 1].is_space() {
				removal_begin--
			}
			if removal_begin > 0 && source[removal_begin - 1] == `,` {
				removal_begin--
			}
			problems << ClassAuditProblem{
				kind: 'redundant_status'
				call_name: call.name
				begin_pos: removal_begin
				end_pos: call.second_end
				message: 'Passing 0 to `shell_output` is redundant'
			}
		}
	}
	return problems
}

pub fn correct_formula_test(source string) string {
	mut problems := audit_formula_test(source)
	for index, problem in problems {
		if problem.kind == 'redundant_status' {
			problems[index] = ClassAuditProblem{
				...problem
				replacement: ''
			}
		}
	}
	mut corrections := problems.filter(it.replacement != '' || it.kind == 'redundant_status')
	corrections.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in corrections {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

fn formula_has_named_line(source string, name string) bool {
	for line in source.split_into_lines() {
		trimmed := line.all_before('#').trim_space()
		if trimmed.starts_with(name) && (trimmed.len == name.len || trimmed[name.len] in [
			` `,
			`\t`,
			`(`,
		]) {
			return true
		}
	}
	return false
}

pub fn audit_formula_test_present(source string) []ClassAuditProblem {
	if _ := formula_test_block(source) {
		return []ClassAuditProblem{}
	}
	if formula_has_named_line(source, 'disable!') {
		return []ClassAuditProblem{}
	}
	mut begin_pos := 0
	mut end_pos := source.len
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('class ') {
			begin_pos = source.index(line) or { 0 } + (line.len - line.trim_left(' \t').len)
			end_pos = begin_pos + trimmed.len
			break
		}
	}
	return [ClassAuditProblem{
		kind: 'missing_test'
		begin_pos: begin_pos
		end_pos: end_pos
		message: 'A `test do` test block should be added'
	}]
}

fn class_problem_value(problem ClassAuditProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'call_name':   problem.call_name
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

fn formula_test_call_value(call FormulaTestCall) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::AST::SendNode', call.name, {
		'name':          call.name
		'begin_pos':     call.begin_pos.str()
		'end_pos':       call.end_pos.str()
		'first_source':  call.first_source
		'first_content': call.first_content
		'second_source': call.second_source
		'second_begin':  call.second_begin.str()
		'second_end':    call.second_end.str()
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 20.
pub fn ruby_class_l20_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_class_name(source).map(class_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 37.
pub fn ruby_class_l37_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_test(source).map(class_problem_value(it)))
}

// Ruby def_node_search `def_node_search :test_calls, <<~EOS` at line 67.
pub fn ruby_class_l67_d3_test_calls(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(find_formula_test_calls(source).map(formula_test_call_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 77.
pub fn ruby_class_l77_d4_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_test_present(source).map(class_problem_value(it)))
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
// 9:       # This cop makes sure that {Formula} is used as superclass.
// 10:       class ClassName < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         DEPRECATED_CLASSES = %w[
// 14:           GithubGistFormula
// 15:           ScriptFileFormula
// 16:           AmazonWebServicesFormula
// 17:         ].freeze
// 18:
// 19:         sig { override.params(formula_nodes: FormulaNodes).void }
// 20:         def audit_formula(formula_nodes)
// 21:           parent_class_node = formula_nodes.parent_class_node
// 22:
// 23:           parent_class = class_name(parent_class_node)
// 24:           return unless DEPRECATED_CLASSES.include?(parent_class)
// 25:
// 26:           problem "`#{parent_class}` is deprecated, use `Formula` instead" do |corrector|
// 27:             corrector.replace(parent_class_node.source_range, "Formula")
// 28:           end
// 29:         end
// 30:       end
// 31:
// 32:       # This cop makes sure that a `test` block contains a proper test.
// 33:       class Test < FormulaCop
// 34:         extend AutoCorrector
// 35:
// 36:         sig { override.params(formula_nodes: FormulaNodes).void }
// 37:         def audit_formula(formula_nodes)
// 38:           test = find_block(formula_nodes.body_node, :test)
// 39:           return unless test
// 40:
// 41:           if test.body.nil?
// 42:             problem "`test do` should not be empty"
// 43:             return
// 44:           end
// 45:
// 46:           problem "`test do` should contain a real test" if test.body.single_line? && test.body.source.to_s == "true"
// 47:
// 48:           test_calls(test) do |node, params|
// 49:             p1, p2 = params
// 50:             if (match = string_content(p1).match(%r{(/usr/local/(s?bin))}))
// 51:               offending_node(p1)
// 52:               problem "Use `\#{#{match[2]}}` instead of `#{match[1]}` in `#{node}`" do |corrector|
// 53:                 corrector.replace(p1.source_range, p1.source.sub(match[1], "\#{#{match[2]}}"))
// 54:               end
// 55:             end
// 56:
// 57:             if node == :shell_output && node_equals?(p2, 0)
// 58:               offending_node(p2)
// 59:               problem "Passing 0 to `shell_output` is redundant" do |corrector|
// 60:                 corrector.remove(range_with_surrounding_comma(range_with_surrounding_space(range: p2.source_range,
// 61:                                                                                            side:  :left)))
// 62:               end
// 63:             end
// 64:           end
// 65:         end
// 66:
// 67:         def_node_search :test_calls, <<~EOS
// 68:           (send nil? ${:system :shell_output :pipe_output} $...)
// 69:         EOS
// 70:       end
// 71:     end
// 72:
// 73:     module FormulaAuditStrict
// 74:       # This cop makes sure that a `test` block exists.
// 75:       class TestPresent < FormulaCop
// 76:         sig { override.params(formula_nodes: FormulaNodes).void }
// 77:         def audit_formula(formula_nodes)
// 78:           body_node = formula_nodes.body_node
// 79:           return if find_block(body_node, :test)
// 80:           return if find_node_method_by_name(body_node, :disable!)
// 81:
// 82:           offending_node(formula_nodes.class_node) if body_node.nil?
// 83:           problem "A `test do` test block should be added"
// 84:         end
// 85:       end
// 86:     end
// 87:   end
// 88: end
