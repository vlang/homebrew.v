module rubocops

import brew_runtime
import homebrew.rubocops.@shared as homepage_shared

// Translated from Homebrew/brew `rubocops/homepage.rb`.
// The original source is retained below until every stub has a typed V body.
struct FormulaHomepageCall {
	begin_pos       int
	end_pos         int
	parameter_begin int
	parameter_end   int
	content         string
}

fn formula_homepage_identifier(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn formula_homepage_literal(source string, begin_pos int) ?FormulaHomepageCall {
	if begin_pos >= source.len || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut cursor := begin_pos + 1
	mut escaped := false
	mut content := []u8{}
	for cursor < source.len {
		character := source[cursor]
		if escaped {
			if quote == `'` {
				if character == `\\` || character == `'` {
					content << character
				} else {
					content << `\\`
					content << character
				}
			} else {
				match character {
					`n` { content << `\n` }
					`r` { content << `\r` }
					`t` { content << `\t` }
					`\\`, `"` { content << character }
					else {
						content << `\\`
						content << character
					}
				}
			}
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return FormulaHomepageCall{
				parameter_begin: begin_pos
				parameter_end: cursor + 1
				content: content.bytestr()
			}
		} else {
			content << character
		}
		cursor++
	}
	return none
}

fn find_formula_homepage(source string) ?FormulaHomepageCall {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut cursor := line_start
		for cursor < line_end && source[cursor] in [` `, `\t`] {
			cursor++
		}
		if cursor < line_end && source[cursor] != `#` && source[cursor..line_end].starts_with('homepage') {
			after := cursor + 'homepage'.len
			if after == line_end || !formula_homepage_identifier(source[after]) {
				mut argument := after
				for argument < source.len && source[argument] in [` `, `\t`, `\n`, `\r`] {
					argument++
				}
				if argument < source.len && source[argument] == `(` {
					argument++
					for argument < source.len && source[argument] in [` `, `\t`, `\n`, `\r`] {
						argument++
					}
				}
				literal := formula_homepage_literal(source, argument) or { return none }
				return FormulaHomepageCall{
					...literal
					begin_pos: cursor
					end_pos: line_end
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

fn formula_class_range(source string) []int {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut begin_pos := line_start
		for begin_pos < line_end && source[begin_pos] in [` `, `\t`] {
			begin_pos++
		}
		if source[begin_pos..line_end].starts_with('class ') {
			return [begin_pos, line_end]
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return [0, source.len]
}

pub fn audit_formula_homepage(source string) []homepage_shared.HomepageProblem {
	call := find_formula_homepage(source) or {
		class_range := formula_class_range(source)
		return [homepage_shared.HomepageProblem{
			kind: 'missing'
			homepage_type: 'formula'
			begin_pos: class_range[0]
			end_pos: class_range[1]
			message: 'Formula should have a homepage.'
		}]
	}
	return homepage_shared.audit_homepage_content('formula', call.content, call.begin_pos, call.end_pos, call.parameter_begin, call.parameter_end)
}

pub fn correct_formula_homepage(source string) string {
	mut problems := audit_formula_homepage(source).filter(it.replacement != '')
	problems.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in problems {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

fn formula_homepage_problem_value(problem homepage_shared.HomepageProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'content':     problem.content
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 16.
pub fn ruby_homepage_l16_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_homepage(source).map(formula_homepage_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/homepage_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits the `homepage` URL in formulae.
// 11:       class Homepage < FormulaCop
// 12:         include HomepageHelper
// 13:         extend AutoCorrector
// 14:
// 15:         sig { override.params(formula_nodes: FormulaNodes).void }
// 16:         def audit_formula(formula_nodes)
// 17:           body_node = formula_nodes.body_node
// 18:           homepage_node = find_node_method_by_name(body_node, :homepage)
// 19:
// 20:           if homepage_node.nil?
// 21:             offending_node(formula_nodes.class_node) if body_node.nil?
// 22:             problem "Formula should have a homepage."
// 23:             return
// 24:           end
// 25:
// 26:           homepage_parameter_node = parameters(homepage_node).fetch(0)
// 27:           offending_node(homepage_parameter_node)
// 28:           content = string_content(homepage_parameter_node)
// 29:
// 30:           audit_homepage(:formula, content, homepage_node, homepage_parameter_node)
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
