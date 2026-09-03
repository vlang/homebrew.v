module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/no_autobump_helper.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct NoAutobumpReasonProblem {
pub:
	kind        string
	reason      string
	is_symbol   bool
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub fn audit_no_autobump_reason(reason string, is_symbol bool, begin_pos int, end_pos int) []NoAutobumpReasonProblem {
	if is_symbol {
		if reason in ['extract_plist', 'latest_version'] {
			return [NoAutobumpReasonProblem{
				kind: 'disallowed_symbol'
				reason: reason
				is_symbol: true
				begin_pos: begin_pos
				end_pos: end_pos
				message: '`:${reason}` reason should not be used'
			}]
		}
		return []NoAutobumpReasonProblem{}
	}
	mut problems := []NoAutobumpReasonProblem{}
	if reason.starts_with('it ') {
		problems << NoAutobumpReasonProblem{
			kind: 'starts_with_it'
			reason: reason
			begin_pos: begin_pos
			end_pos: end_pos
			message: 'Do not start the reason with `it`'
			replacement: '"${reason[3..]}"'
		}
	}
	if reason.len > 0 && reason[reason.len - 1] in [`.`, `!`, `?`] {
		problems << NoAutobumpReasonProblem{
			kind: 'trailing_punctuation'
			reason: reason
			begin_pos: begin_pos
			end_pos: end_pos
			message: 'Do not end the reason with a punctuation mark'
			replacement: '"${reason[..reason.len - 1]}"'
		}
	}
	return problems
}

fn no_autobump_reason_problem_value(problem NoAutobumpReasonProblem) brew_runtime.Value {
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

// Ruby method `audit_no_autobump(_type, reason_node)` at line 16.
pub fn ruby_no_autobump_helper_l16_d1_audit_no_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string().trim_space() } else { '' }
	is_symbol := source.starts_with(':')
	reason := if is_symbol {
		source.trim_string_left(':')
	} else {
		source.trim('"\'')
	}
	return brew_runtime.array_value(audit_no_autobump_reason(reason, is_symbol, 0, source.len).map(no_autobump_reason_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # This cop audits `no_autobump!` reason.
// 9:     module NoAutobumpHelper
// 10:       include HelperFunctions
// 11:
// 12:       PUNCTUATION_MARKS = %w[. ! ?].freeze
// 13:       DISALLOWED_NO_AUTOBUMP_REASONS = %w[extract_plist latest_version].freeze
// 14:
// 15:       sig { params(_type: Symbol, reason_node: RuboCop::AST::Node).void }
// 16:       def audit_no_autobump(_type, reason_node)
// 17:         @offensive_node = T.let(reason_node, T.nilable(RuboCop::AST::Node))
// 18:
// 19:         reason_string = string_content(reason_node)
// 20:
// 21:         if reason_node.sym_type? && DISALLOWED_NO_AUTOBUMP_REASONS.include?(reason_string)
// 22:           problem "`:#{reason_string}` reason should not be used"
// 23:         end
// 24:
// 25:         return if reason_node.sym_type?
// 26:
// 27:         if reason_string.start_with?("it ")
// 28:           problem "Do not start the reason with `it`" do |corrector|
// 29:             corrector.replace(T.must(@offensive_node).source_range, "\"#{reason_string[3..]}\"")
// 30:           end
// 31:         end
// 32:
// 33:         return unless PUNCTUATION_MARKS.include?(reason_string[-1])
// 34:
// 35:         problem "Do not end the reason with a punctuation mark" do |corrector|
// 36:           corrector.replace(T.must(@offensive_node).source_range, "\"#{reason_string.chop}\"")
// 37:         end
// 38:       end
// 39:     end
// 40:   end
// 41: end
