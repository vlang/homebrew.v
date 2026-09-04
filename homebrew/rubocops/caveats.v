module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/caveats.rb`.
pub struct CaveatsProblem {
pub:
	kind      string
	begin_pos int
	end_pos   int
	message   string
}

fn caveats_word_boundary(character u8) bool {
	return !character.is_alnum() && character != `_`
}

fn caveats_contains_setuid(value string) ?[]int {
	lower := value.to_lower()
	mut cursor := 0
	for cursor < lower.len {
		relative := lower[cursor..].index('setuid') or { break }
		start := cursor + relative
		end := start + 'setuid'.len
		before_ok := start == 0 || caveats_word_boundary(lower[start - 1])
		after_ok := end == lower.len || caveats_word_boundary(lower[end])
		if before_ok && after_ok {
			return [start, end]
		}
		cursor = end
	}
	return none
}

fn caveats_has_escape(value string) bool {
	return value.contains('\x1b') || value.to_lower().contains('\\x1b') || value.to_lower().contains('\\u001b')
}

fn caveats_method_range(source string) ?[]int {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.trim_space()
		if trimmed == 'def caveats' || trimmed.starts_with('def caveats(') {
			indent := line.len - line.trim_left(' \t').len
			mut candidate_start := if newline < 0 { source.len } else { line_end + 1 }
			for candidate_start < source.len {
				candidate_newline := source[candidate_start..].index_u8(`\n`)
				candidate_end := if candidate_newline < 0 {
					source.len
				} else {
					candidate_start + candidate_newline
				}
				candidate := source[candidate_start..candidate_end]
				candidate_indent := candidate.len - candidate.trim_left(' \t').len
				if candidate.trim_space() == 'end' && candidate_indent == indent {
					return [line_end + 1, candidate_start]
				}
				if candidate_newline < 0 {
					break
				}
				candidate_start = candidate_end + 1
			}
			return [line_end + 1, source.len]
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

pub fn audit_formula_caveats(source string, formula_tap string) []CaveatsProblem {
	method_range := caveats_method_range(source) or { return []CaveatsProblem{} }
	mut problems := []CaveatsProblem{}
	mut cursor := method_range[0]
	for cursor < method_range[1] {
		if source[cursor] == `"` || source[cursor] == `'` {
			quote := source[cursor]
			start := cursor
			cursor++
			mut escaped := false
			for cursor < method_range[1] {
				if escaped {
					escaped = false
				} else if source[cursor] == `\\` {
					escaped = true
				} else if source[cursor] == quote {
					break
				}
				cursor++
			}
			if cursor >= method_range[1] {
				break
			}
			value := source[start + 1..cursor]
			if _ := caveats_contains_setuid(value) {
				problems << CaveatsProblem{
					kind: 'setuid'
					begin_pos: start
					end_pos: cursor + 1
					message: 'Instead of recommending `setuid` in the caveats, suggest `sudo`.'
				}
			}
			if caveats_has_escape(value) {
				problems << CaveatsProblem{
					kind: 'ansi_escape'
					begin_pos: start
					end_pos: cursor + 1
					message: "Don't use ANSI escape codes in the caveats."
				}
			}
		}
		cursor++
	}
	if formula_tap == 'homebrew-core' {
		mut line_start := method_range[0]
		for line_start < method_range[1] {
			newline := source[line_start..method_range[1]].index_u8(`\n`)
			line_end := if newline < 0 { method_range[1] } else { line_start + newline }
			trimmed := source[line_start..line_end].trim_space()
			if trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('elsif ') {
				indent := source[line_start..line_end].len - source[line_start..line_end].trim_left(' \t').len
				problems << CaveatsProblem{
					kind: 'dynamic_logic'
					begin_pos: line_start + indent
					end_pos: line_end
					message: "Don't use dynamic logic (if/else/unless) in caveats."
				}
			}
			if newline < 0 {
				break
			}
			line_start = line_end + 1
		}
	}
	return problems
}

fn caveats_problem_value(problem CaveatsProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':      problem.kind
		'begin_pos': problem.begin_pos.str()
		'end_pos':   problem.end_pos.str()
		'message':   problem.message
	})
}
