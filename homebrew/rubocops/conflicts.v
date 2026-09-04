module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/conflicts.rb`.
// The original source is retained below until every stub has a typed V body.
pub const conflicts_versioned_formula_message = 'Versioned formulae should not use `conflicts_with`. Use `keg_only :versioned_formula` instead.'

pub struct FormulaConflictProblem {
pub:
	kind        string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct FormulaConflictCall {
	begin_pos    int
	end_pos      int
	reason_begin int
	reason_end   int
	reason       string
}

fn formula_conflict_call(line string, line_start int) ?FormulaConflictCall {
	mut cursor := 0
	for cursor < line.len && (line[cursor] == ` ` || line[cursor] == `\t`) {
		cursor++
	}
	if !line[cursor..].starts_with('conflicts_with') {
		return none
	}
	after := cursor + 'conflicts_with'.len
	if after < line.len && line[after] != ` ` && line[after] != `\t` && line[after] != `(` {
		return none
	}
	mut reason_marker := -1
	for marker in [':because', 'because:'] {
		if relative := line[after..].index(marker) {
			position := after + relative
			if position > reason_marker {
				reason_marker = position
			}
		}
	}
	mut reason_begin := -1
	mut reason_end := -1
	mut reason := ''
	if reason_marker >= 0 {
		mut quote_position := reason_marker
		for quote_position < line.len && line[quote_position] != `"` && line[quote_position] != `'` {
			quote_position++
		}
		if quote_position < line.len {
			quote := line[quote_position]
			mut end := quote_position + 1
			mut escaped := false
			for end < line.len {
				if escaped {
					escaped = false
				} else if line[end] == `\\` {
					escaped = true
				} else if line[end] == quote {
					reason_begin = line_start + quote_position
					reason_end = line_start + end + 1
					reason = line[quote_position + 1..end]
					break
				}
				end++
			}
		}
	}
	return FormulaConflictCall{
		begin_pos: line_start + cursor
		end_pos: line_start + line.len
		reason_begin: reason_begin
		reason_end: reason_end
		reason: reason
	}
}

fn conflict_remove_formula_name(reason string, formula_name string) string {
	if formula_name == '' {
		return reason
	}
	relative := reason.to_lower().index(formula_name.to_lower()) or { return reason }
	return reason[..relative] + reason[relative + formula_name.len..]
}

fn conflict_first_word(reason string) string {
	trimmed := reason.trim_space()
	mut end := 0
	for end < trimmed.len && trimmed[end] != ` ` && trimmed[end] != `\t` && trimmed[end] != `\n` {
		end++
	}
	return trimmed[..end]
}

pub fn audit_formula_conflicts(source string, formula_name string, versioned_formula bool, allowlisted bool) []FormulaConflictProblem {
	mut calls := []FormulaConflictCall{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if call := formula_conflict_call(source[line_start..line_end], line_start) {
			calls << call
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	mut problems := []FormulaConflictProblem{}
	for call in calls {
		if call.reason_begin < 0 {
			continue
		}
		mut reason_text := conflict_remove_formula_name(call.reason, formula_name)
		if reason_text.len > 0 && reason_text[0] >= `A` && reason_text[0] <= `Z` {
			first_word := conflict_first_word(reason_text)
			reason_text = reason_text[..1].to_lower() + reason_text[1..]
			problems << FormulaConflictProblem{
				kind: 'capitalized_reason'
				begin_pos: call.reason_begin
				end_pos: call.reason_end
				message: "'${first_word}' from the `conflicts_with` reason should be '${first_word.to_lower()}'."
				replacement: '"${reason_text}"'
			}
		}
		if reason_text.ends_with('.') {
			problems << FormulaConflictProblem{
				kind: 'trailing_period'
				begin_pos: call.reason_begin
				end_pos: call.reason_end
				message: '`conflicts_with` reason should not end with a period.'
				replacement: '"${reason_text[..reason_text.len - 1]}"'
			}
		}
	}
	if versioned_formula && !allowlisted && calls.len > 0 {
		problems << FormulaConflictProblem{
			kind: 'versioned_formula'
			begin_pos: calls[0].begin_pos
			end_pos: calls[0].end_pos
			message: conflicts_versioned_formula_message
			replacement: 'keg_only :versioned_formula'
		}
	}
	return problems
}

pub fn correct_formula_conflicts(source string, formula_name string, versioned_formula bool, allowlisted bool) string {
	mut problems := audit_formula_conflicts(source, formula_name, versioned_formula, allowlisted).filter(it.replacement != '')
	problems.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	mut last_begin := source.len + 1
	for problem in problems {
		if problem.end_pos > last_begin {
			continue
		}
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
		last_begin = problem.begin_pos
	}
	return corrected
}

fn formula_conflict_problem_value(problem FormulaConflictProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_conflicts_l17_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_name := if args.len > 1 { args[1].as_string() } else { '' }
	versioned := if args.len > 2 { args[2].bool_data } else { false }
	allowlisted := if args.len > 3 { args[3].bool_data } else { false }
	return ruby.array_value(audit_formula_conflicts(source, formula_name, versioned, allowlisted).map(formula_conflict_problem_value(it)))
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
// 9:       # This cop audits versioned formulae for `conflicts_with`.
// 10:       class Conflicts < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         MSG = "Versioned formulae should not use `conflicts_with`. " \
// 14:               "Use `keg_only :versioned_formula` instead."
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           return if (body_node = formula_nodes.body_node).nil?
// 19:
// 20:           find_method_calls_by_name(body_node, :conflicts_with).each do |conflicts_with_call|
// 21:             next unless parameters(conflicts_with_call).last.respond_to? :values
// 22:
// 23:             reason = T.cast(parameters(conflicts_with_call).fetch(-1), RuboCop::AST::HashNode).values.first
// 24:             offending_node(reason)
// 25:             name = Regexp.new(T.must(@formula_name), Regexp::IGNORECASE)
// 26:             reason_text = string_content(reason).sub(name, "")
// 27:             first_word = reason_text.split.fetch(0)
// 28:
// 29:             if reason_text.match?(/\A[A-Z]/)
// 30:               problem "'#{first_word}' from the `conflicts_with` reason " \
// 31:                       "should be '#{first_word.downcase}'." do |corrector|
// 32:                 reason_text[0] = T.must(reason_text[0]).downcase
// 33:                 corrector.replace(reason.source_range, "\"#{reason_text}\"")
// 34:               end
// 35:             end
// 36:             next unless reason_text.end_with?(".")
// 37:
// 38:             problem "`conflicts_with` reason should not end with a period." do |corrector|
// 39:               corrector.replace(reason.source_range, "\"#{reason_text.chop}\"")
// 40:             end
// 41:           end
// 42:
// 43:           return unless versioned_formula?
// 44:
// 45:           if !tap_style_exception?(:versioned_formulae_conflicts_allowlist) && method_called_ever?(body_node,
// 46:                                                                                                    :conflicts_with)
// 47:             problem MSG do |corrector|
// 48:               corrector.replace(T.must(@offensive_node).source_range, "keg_only :versioned_formula")
// 49:             end
// 50:           end
// 51:         end
// 52:       end
// 53:     end
// 54:   end
// 55: end
