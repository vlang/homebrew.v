module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/conflicts.rb`.
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
