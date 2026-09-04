module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/no_autobump_helper.rb`.
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

fn no_autobump_reason_problem_value(problem NoAutobumpReasonProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'reason':      problem.reason
		'is_symbol':   problem.is_symbol.str()
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}
