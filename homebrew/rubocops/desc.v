module rubocops

import brew_runtime
import homebrew.rubocops.@shared as desc_shared

// Translated from Homebrew/brew `rubocops/desc.rb`.
// The original source is retained below for line-level provenance.
struct FormulaDescLiteral {
	quote     u8
	content   string
	begin_pos int
	end_pos   int
}

fn formula_desc_identifier(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn formula_desc_space(character u8) bool {
	return character in [` `, `\t`, `\n`, `\r`, `\v`, `\f`]
}

fn formula_desc_literal(source string, begin_pos int) ?FormulaDescLiteral {
	if begin_pos >= source.len || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut cursor := begin_pos + 1
	mut escaped := false
	for cursor < source.len {
		character := source[cursor]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return FormulaDescLiteral{
				quote: quote
				content: source[begin_pos + 1..cursor]
				begin_pos: begin_pos
				end_pos: cursor + 1
			}
		}
		cursor++
	}
	return none
}

fn formula_desc_call_at(source string, begin_pos int, line_end int) desc_shared.DescCall {
	mut cursor := begin_pos + 'desc'.len
	for cursor < source.len && formula_desc_space(source[cursor]) {
		cursor++
	}
	mut parenthesized := false
	if cursor < source.len && source[cursor] == `(` {
		parenthesized = true
		cursor++
		for cursor < source.len && formula_desc_space(source[cursor]) {
			cursor++
		}
	}
	first := formula_desc_literal(source, cursor) or {
		return desc_shared.DescCall{
			begin_pos: begin_pos
			end_pos: line_end
			literal_begin_pos: cursor
			literal_end_pos: cursor
			content_begin_pos: cursor
			correctable: false
		}
	}
	mut description := first.content
	mut literal_end := first.end_pos
	mut literal_count := 1
	mut scan := first.end_pos
	for scan < source.len {
		for scan < source.len && source[scan] in [` `, `\t`] {
			scan++
		}
		mut continues := false
		if scan < source.len && source[scan] == `\\` {
			scan++
			if scan < source.len && source[scan] == `\r` {
				scan++
			}
			if scan < source.len && source[scan] == `\n` {
				scan++
				continues = true
			}
		} else if scan < source.len && source[scan] == `+` {
			scan++
			continues = true
		}
		if !continues {
			break
		}
		for scan < source.len && formula_desc_space(source[scan]) {
			scan++
		}
		next := formula_desc_literal(source, scan) or { break }
		description += next.content
		literal_end = next.end_pos
		literal_count++
		scan = next.end_pos
	}
	mut call_end := literal_end
	if parenthesized {
		mut close := literal_end
		for close < source.len && source[close] in [` `, `\t`] {
			close++
		}
		if close < source.len && source[close] == `)` {
			call_end = close + 1
		}
	}
	return desc_shared.DescCall{
		description: description
		begin_pos: begin_pos
		end_pos: call_end
		literal_begin_pos: first.begin_pos
		literal_end_pos: literal_end
		content_begin_pos: first.begin_pos + 1
		quote: first.quote
		correctable: literal_count == 1
	}
}

fn find_formula_desc_call(source string) ?desc_shared.DescCall {
	mut line_start := 0
	for line_start <= source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut cursor := line_start
		for cursor < line_end && source[cursor] in [` `, `\t`] {
			cursor++
		}
		if cursor < line_end && source[cursor] != `#` && source[cursor..line_end].starts_with('desc') {
			after := cursor + 'desc'.len
			if after == line_end || !formula_desc_identifier(source[after]) {
				return formula_desc_call_at(source, cursor, line_end)
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn formula_desc_class_details(source string) ([]int, string) {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut begin_pos := line_start
		for begin_pos < line_end && source[begin_pos] in [` `, `\t`] {
			begin_pos++
		}
		line := source[begin_pos..line_end]
		if line.starts_with('class ') {
			mut name_end := 'class '.len
			for name_end < line.len && (line[name_end].is_alnum() || line[name_end] == `_`) {
				name_end++
			}
			return [begin_pos, line_end], line['class '.len..name_end].to_lower()
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return [0, source.len], ''
}

pub fn audit_formula_desc(source string, formula_name string) []desc_shared.DescProblem {
	class_range, class_name := formula_desc_class_details(source)
	name := if formula_name == '' { class_name } else { formula_name }
	call := find_formula_desc_call(source) or {
		return desc_shared.audit_desc('formula', name, desc_shared.DescCall{}, false, class_range[0], class_range[1])
	}
	return desc_shared.audit_desc('formula', name, call, true, class_range[0], class_range[1])
}

pub fn correct_formula_desc(source string, formula_name string) string {
	problems := audit_formula_desc(source, formula_name)
	mut corrected := source
	mut corrected_literals := map[int]bool{}
	for index := problems.len - 1; index >= 0; index-- {
		problem := problems[index]
		if problem.replacement == '' || corrected_literals[problem.literal_begin_pos] {
			continue
		}
		corrected = corrected[..problem.literal_begin_pos] + problem.replacement + corrected[problem.literal_end_pos..]
		corrected_literals[problem.literal_begin_pos] = true
	}
	return corrected
}

fn formula_desc_problem_value(problem desc_shared.DescProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', problem.message, {
		'kind':          problem.kind
		'desc_type':     problem.desc_type
		'name':          problem.name
		'description':   problem.description
		'begin_pos':     problem.begin_pos.str()
		'end_pos':       problem.end_pos.str()
		'message':       problem.message
		'replacement':   problem.replacement
		'literal_begin': problem.literal_begin_pos.str()
		'literal_end':   problem.literal_end_pos.str()
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_desc_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_name := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_desc(source, formula_name).map(formula_desc_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/desc_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `desc` in formulae.
// 11:       # See the {DescHelper} module for details of the checks.
// 12:       class Desc < FormulaCop
// 13:         include DescHelper
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:
// 20:           @name = T.let(@formula_name, T.nilable(String))
// 21:           desc_call = find_node_method_by_name(body_node, :desc)
// 22:           offending_node(formula_nodes.class_node) if body_node.nil?
// 23:           audit_desc(:formula, @name, desc_call)
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
