module rubocops

import brew_runtime
import homebrew.rubocops.@shared as no_autobump_shared

// Translated from Homebrew/brew `rubocops/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_autobump_missing_reason_message = 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'

pub struct NoAutobumpCall {
pub:
	begin_pos     int
	end_pos       int
	has_reason    bool
	reason        string
	reason_symbol bool
	reason_begin  int
	reason_end    int
}

pub fn find_no_autobump_call(source string) ?NoAutobumpCall {
	position := source.index('no_autobump!') or { return none }
	mut line_end := position
	for line_end < source.len && source[line_end] != `\n` {
		line_end++
	}
	line := source[position..line_end]
	because := line.index('because:') or {
		return NoAutobumpCall{ begin_pos: position, end_pos: line_end }
	}
	mut cursor := position + because + 'because:'.len
	for cursor < line_end && (source[cursor] == ` ` || source[cursor] == `\t`) {
		cursor++
	}
	if cursor >= line_end {
		return NoAutobumpCall{ begin_pos: position, end_pos: line_end }
	}
	if source[cursor] == `:` {
		mut end := cursor + 1
		for end < line_end && (source[end].is_alnum() || source[end] == `_`) {
			end++
		}
		return NoAutobumpCall{
			begin_pos: position
			end_pos: line_end
			has_reason: end > cursor + 1
			reason: source[cursor + 1..end]
			reason_symbol: true
			reason_begin: cursor
			reason_end: end
		}
	}
	if source[cursor] == `"` || source[cursor] == `'` {
		quote := source[cursor]
		mut end := cursor + 1
		mut escaped := false
		for end < line_end {
			if escaped {
				escaped = false
			} else if source[end] == `\\` {
				escaped = true
			} else if source[end] == quote {
				return NoAutobumpCall{
					begin_pos: position
					end_pos: line_end
					has_reason: true
					reason: source[cursor + 1..end]
					reason_begin: cursor
					reason_end: end + 1
				}
			}
			end++
		}
	}
	return NoAutobumpCall{ begin_pos: position, end_pos: line_end }
}

pub fn audit_formula_no_autobump(source string) []no_autobump_shared.NoAutobumpReasonProblem {
	call := find_no_autobump_call(source) or { return []no_autobump_shared.NoAutobumpReasonProblem{} }
	if !call.has_reason {
		return [no_autobump_shared.NoAutobumpReasonProblem{
			kind: 'missing_reason'
			begin_pos: call.begin_pos
			end_pos: call.end_pos
			message: no_autobump_missing_reason_message
		}]
	}
	return no_autobump_shared.audit_no_autobump_reason(call.reason, call.reason_symbol, call.reason_begin, call.reason_end)
}

pub fn correct_formula_no_autobump(source string) string {
	mut problems := audit_formula_no_autobump(source).filter(it.replacement != '')
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

fn no_autobump_problem_value(problem no_autobump_shared.NoAutobumpReasonProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'reason':      problem.reason
		'is_symbol':   problem.is_symbol.str()
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_no_autobump_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_no_autobump(source).map(no_autobump_problem_value(it)))
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 35.
pub fn ruby_no_autobump_l35_d2_reason(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	call := find_no_autobump_call(source) or { return brew_runtime.object_value('NilClass', 'nil') }
	return if call.has_reason {
		brew_runtime.structured_value(if call.reason_symbol { 'Symbol' } else { 'String' }, call.reason, {
			'begin_pos': call.reason_begin.str()
			'end_pos':   call.reason_end.str()
		})
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/no_autobump_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `no_autobump!` reason.
// 11:       # See the {NoAutobumpHelper} module for details of the checks.
// 12:       class NoAutobump < FormulaCop
// 13:         include NoAutobumpHelper
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:           no_autobump_call = find_node_method_by_name(body_node, :no_autobump!)
// 20:
// 21:           return if no_autobump_call.nil?
// 22:
// 23:           reason_found = T.let(false, T::Boolean)
// 24:           reason(no_autobump_call) do |reason_node|
// 25:             reason_found = true
// 26:             offending_node(reason_node)
// 27:             audit_no_autobump(:formula, reason_node)
// 28:           end
// 29:
// 30:           return if reason_found
// 31:
// 32:           problem 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'
// 33:         end
// 34:
// 35:         def_node_search :reason, <<~EOS
// 36:           (pair (sym :because) ${str sym})
// 37:         EOS
// 38:       end
// 39:     end
// 40:   end
// 41: end
