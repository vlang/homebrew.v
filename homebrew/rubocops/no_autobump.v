module rubocops

import ruby
import homebrew.rubocops.@shared as no_autobump_shared

// Translated from Homebrew/brew `rubocops/no_autobump.rb`.
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

fn no_autobump_problem_value(problem no_autobump_shared.NoAutobumpReasonProblem) ruby.Value {
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
