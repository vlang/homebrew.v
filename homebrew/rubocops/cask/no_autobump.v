module cask

import ruby
import homebrew.rubocops as formula_no_autobump_core
import homebrew.rubocops.@shared as no_autobump_shared

// Translated from Homebrew/brew `rubocops/cask/no_autobump.rb`.
pub const cask_no_autobump_missing_reason_message = 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'

fn cask_no_autobump_opens_block(line string) bool {
	code := line.all_before('#').trim_space()
	if code.ends_with(' do') || code.contains(' do |') {
		return true
	}
	for keyword in ['if ', 'unless ', 'case ', 'begin', 'while ', 'until ', 'for ', 'def ', 'class '] {
		if code == keyword.trim_space() || code.starts_with(keyword) {
			return true
		}
	}
	return false
}

pub fn cask_no_autobump_stanzas(source string) []formula_no_autobump_core.NoAutobumpCall {
	mut stanzas := []formula_no_autobump_core.NoAutobumpCall{}
	mut depth := 0
	mut in_cask := false
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.all_before('#').trim_space()
		if !in_cask {
			if trimmed.starts_with('cask ') && cask_no_autobump_opens_block(trimmed) {
				in_cask = true
				depth = 1
			}
		} else {
			if trimmed == 'end' || trimmed.starts_with('end ') {
				depth--
				if depth == 0 {
					in_cask = false
				}
			} else {
				if depth == 1 && trimmed.starts_with('no_autobump!') && (trimmed.len == 'no_autobump!'.len || trimmed['no_autobump!'.len] in [
					` `,
					`\t`,
					`(`,
				]) {
					indent := line.len - line.trim_left(' \t').len
					call := formula_no_autobump_core.find_no_autobump_call(line) or {
						formula_no_autobump_core.NoAutobumpCall{}
					}
					stanzas << formula_no_autobump_core.NoAutobumpCall{
						...call
						begin_pos: line_start + call.begin_pos
						end_pos: line_start + call.end_pos
						reason_begin: if call.has_reason {
							line_start + call.reason_begin
						} else {
							line_start + indent
						}
						reason_end: if call.has_reason {
							line_start + call.reason_end
						} else {
							line_start + indent
						}
					}
				}
				if cask_no_autobump_opens_block(trimmed) {
					depth++
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return stanzas
}

pub fn audit_cask_no_autobump(source string) []no_autobump_shared.NoAutobumpReasonProblem {
	mut problems := []no_autobump_shared.NoAutobumpReasonProblem{}
	for call in cask_no_autobump_stanzas(source) {
		if !call.has_reason {
			problems << no_autobump_shared.NoAutobumpReasonProblem{
				kind: 'missing_reason'
				begin_pos: call.begin_pos
				end_pos: call.end_pos
				message: cask_no_autobump_missing_reason_message
			}
			continue
		}
		problems << no_autobump_shared.audit_no_autobump_reason(call.reason, call.reason_symbol, call.reason_begin, call.reason_end)
	}
	return problems
}

pub fn correct_cask_no_autobump(source string) string {
	mut problems := audit_cask_no_autobump(source).filter(it.replacement != '')
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

fn cask_no_autobump_problem_value(problem no_autobump_shared.NoAutobumpReasonProblem) ruby.Value {
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

fn cask_no_autobump_stanza_value(call formula_no_autobump_core.NoAutobumpCall) ruby.Value {
	return ruby.structured_value('RuboCop::Cask::AST::Stanza', 'no_autobump!', {
		'name':          'no_autobump!'
		'begin_pos':     call.begin_pos.str()
		'end_pos':       call.end_pos.str()
		'has_reason':    call.has_reason.str()
		'reason':        call.reason
		'reason_symbol': call.reason_symbol.str()
	})
}
