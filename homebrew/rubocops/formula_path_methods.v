module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/formula_path_methods.rb`.
pub struct FormulaPathProblem {
pub:
	begin_pos   int
	end_pos     int
	current     string
	preferred   string
	message     string
	replacement string
}

pub struct FormulaPathCandidate {
pub:
	begin_pos    int
	end_pos      int
	source       string
	receiver     string
	method_name  string
	argument     string
	formula_name string
	cask_token   string
	in_formula   bool
	in_cask      bool
	in_service   bool
	in_rescue    bool
}

struct FormulaPathContext {
	kind string
}

fn formula_path_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn formula_path_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `?`, `!`]
}

fn formula_path_code_end(line string) int {
	mut quote := u8(0)
	mut escaped := false
	for index, character in line.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			return index
		}
	}
	return line.len
}

fn formula_path_matching_delimiter(source string, open_pos int, limit int) ?int {
	if open_pos >= limit || source[open_pos] !in [`[`, `(`] {
		return none
	}
	open := source[open_pos]
	close := if open == `[` { `]` } else { `)` }
	mut depth := 1
	mut cursor := open_pos + 1
	mut quote := u8(0)
	mut escaped := false
	for cursor < limit {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return cursor
			}
		}
		cursor++
	}
	return none
}

fn formula_path_top_level_arguments(source string) []string {
	mut arguments := []string{}
	mut start := 0
	mut cursor := 0
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut curly_depth := 0
	for cursor < source.len {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `(` {
			round_depth++
		} else if character == `)` {
			round_depth--
		} else if character == `[` {
			square_depth++
		} else if character == `]` {
			square_depth--
		} else if character == `{` {
			curly_depth++
		} else if character == `}` {
			curly_depth--
		} else if character == `,` && round_depth == 0 && square_depth == 0 && curly_depth == 0 {
			arguments << source[start..cursor].trim_space()
			start = cursor + 1
		}
		cursor++
	}
	last := source[start..].trim_space()
	if last != '' {
		arguments << last
	}
	return arguments
}

fn formula_path_contexts(source string, position int) []FormulaPathContext {
	mut contexts := []FormulaPathContext{}
	mut line_start := 0
	for line_start < position {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if line_end > position {
			break
		}
		trimmed := source[line_start..line_end].trim_space()
		if trimmed == 'end' || trimmed.starts_with('end ') {
			if contexts.len > 0 {
				contexts.delete_last()
			}
		} else {
			mut kind := ''
			if trimmed.starts_with('class ') && trimmed.contains('< Formula') {
				kind = 'formula'
			} else if trimmed.starts_with('cask ') && trimmed.contains(' do') {
				kind = 'cask'
			} else if trimmed == 'service do' || trimmed.starts_with('service do ') {
				kind = 'service'
			} else if trimmed == 'begin' {
				kind = 'begin'
			} else if trimmed.starts_with('class ') || trimmed.starts_with('module ') || trimmed.starts_with('def ') || trimmed.starts_with('case ') || trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('while ') || trimmed.starts_with('until ') || trimmed.starts_with('for ') || trimmed.ends_with(' do') || (trimmed.contains(' do |') && !trimmed.contains(' end')) {
				kind = 'other'
			}
			if kind != '' {
				contexts << FormulaPathContext{
					kind: kind
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return contexts
}

fn formula_path_inside_rescue(source string, position int) bool {
	mut block_kinds := []string{}
	mut block_starts := []int{}
	mut rescued_begins := map[int]bool{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		trimmed := source[line_start..line_end].trim_space()
		if trimmed == 'rescue' || trimmed.starts_with('rescue ') {
			for index := block_kinds.len - 1; index >= 0; index-- {
				if block_kinds[index] == 'begin' {
					rescued_begins[block_starts[index]] = true
					break
				}
			}
		} else if trimmed == 'end' || trimmed.starts_with('end ') {
			if block_kinds.len > 0 {
				kind := block_kinds.last()
				start := block_starts.last()
				block_kinds.delete_last()
				block_starts.delete_last()
				if kind == 'begin' && start < position && position < line_end && rescued_begins[start] {
					return true
				}
			}
		} else {
			mut kind := ''
			if trimmed == 'begin' {
				kind = 'begin'
			} else if trimmed.starts_with('class ') || trimmed.starts_with('module ') || trimmed.starts_with('def ') || trimmed.starts_with('case ') || trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('while ') || trimmed.starts_with('until ') || trimmed.starts_with('for ') || trimmed.ends_with(' do') || (trimmed.contains(' do |') && !trimmed.contains(' end')) {
				kind = 'other'
			}
			if kind != '' {
				block_kinds << kind
				block_starts << line_start
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return false
}

fn formula_path_method_end(source string, start int, limit int) int {
	mut cursor := start
	for cursor < limit && formula_path_identifier(source[cursor]) {
		cursor++
	}
	return cursor
}

fn formula_path_candidate_at(source string, start int, limit int) ?FormulaPathCandidate {
	contexts := formula_path_contexts(source, start)
	in_formula := contexts.any(it.kind == 'formula')
	in_cask := contexts.any(it.kind == 'cask')
	in_service := contexts.any(it.kind == 'service')
	mut receiver := ''
	mut method_name := ''
	mut argument := ''
	mut formula_name := ''
	mut cask_token := ''
	mut end_pos := 0
	mut receiver_end := 0
	mut kind := ''

	formula_prefix := if source[start..limit].starts_with('::Formula[') {
		'::Formula['
	} else {
		'Formula['
	}
	if source[start..limit].starts_with(formula_prefix) {
		open_pos := start + formula_prefix.len - 1
		close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
		formula_name = source[open_pos + 1..close_pos].trim_space()
		receiver_end = close_pos + 1
		kind = 'formula'
	} else {
		formulary_prefix := if source[start..limit].starts_with('::Formulary.factory(') {
			'::Formulary.factory('
		} else {
			'Formulary.factory('
		}
		if source[start..limit].starts_with(formulary_prefix) {
			open_pos := start + formulary_prefix.len - 1
			close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
			arguments := formula_path_top_level_arguments(source[open_pos + 1..close_pos])
			if arguments.len != 1 {
				return none
			}
			formula_name = arguments[0]
			receiver_end = close_pos + 1
			kind = 'formula'
		} else {
			cask_prefix := if source[start..limit].starts_with('::Cask::Cask.new(') {
				'::Cask::Cask.new('
			} else {
				'Cask::Cask.new('
			}
			if source[start..limit].starts_with(cask_prefix) {
				open_pos := start + cask_prefix.len - 1
				close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
				arguments := formula_path_top_level_arguments(source[open_pos + 1..close_pos])
				if arguments.len == 0 {
					return none
				}
				cask_token = arguments[0]
				receiver_end = close_pos + 1
				kind = 'cask'
			} else if source[start..limit].starts_with('Utils::Path.') || source[start..limit].starts_with('::Utils::Path.') {
				prefix := if source[start..limit].starts_with('::') {
					'::Utils::Path.'
				} else {
					'Utils::Path.'
				}
				method_start := start + prefix.len
				method_end := formula_path_method_end(source, method_start, limit)
				method_name = source[method_start..method_end]
				if method_end >= limit || source[method_end] != `(` {
					return none
				}
				close_pos := formula_path_matching_delimiter(source, method_end, limit) or { return none }
				argument = source[method_end + 1..close_pos].trim_space()
				receiver = source[start..method_start - 1]
				end_pos = close_pos + 1
				kind = 'utils'
			}
		}
	}

	if kind == '' {
		return none
	}
	if kind in ['formula', 'cask'] {
		if receiver_end >= limit || source[receiver_end] != `.` {
			return none
		}
		method_start := receiver_end + 1
		end_pos = formula_path_method_end(source, method_start, limit)
		if end_pos == method_start {
			return none
		}
		method_name = source[method_start..end_pos]
		receiver = source[start..receiver_end]
	}
	return FormulaPathCandidate{
		begin_pos: start
		end_pos: end_pos
		source: source[start..end_pos]
		receiver: receiver
		method_name: method_name
		argument: argument
		formula_name: formula_name
		cask_token: cask_token
		in_formula: in_formula
		in_cask: in_cask
		in_service: in_service
		in_rescue: formula_path_inside_rescue(source, start)
	}
}

pub fn formula_path_candidates(source string) []FormulaPathCandidate {
	mut candidates := []FormulaPathCandidate{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		code_end := line_start + formula_path_code_end(line)
		mut cursor := line_start
		mut quote := u8(0)
		mut escaped := false
		for cursor < code_end {
			character := source[cursor]
			if quote != 0 {
				if escaped {
					escaped = false
				} else if character == `\\` {
					escaped = true
				} else if character == quote {
					quote = 0
				}
				cursor++
				continue
			}
			if character in [`'`, `"`] {
				quote = character
				cursor++
				continue
			}
			if cursor > line_start && formula_path_identifier(source[cursor - 1]) {
				cursor++
				continue
			}
			if candidate := formula_path_candidate_at(source, cursor, code_end) {
				candidates << candidate
				cursor = candidate.end_pos
				continue
			}
			cursor++
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return candidates
}

fn formula_path_is_string_literal(value string) bool {
	trimmed := value.trim_space()
	return trimmed.len >= 2 && trimmed[0] in [`'`, `"`] && trimmed[trimmed.len - 1] == trimmed[0]
}

pub fn preferred_formula_path_call(candidate FormulaPathCandidate) ?string {
	if candidate.method_name == 'any_version_installed?' {
		if candidate.in_rescue {
			return none
		}
		if candidate.formula_name != '' && formula_path_is_string_literal(candidate.formula_name) {
			helper_receiver := if candidate.in_formula || candidate.in_cask {
				''
			} else {
				'Utils::Path.'
			}
			return '${helper_receiver}formula_any_version_installed?(${candidate.formula_name})'
		}
		if candidate.cask_token != '' {
			return 'Cask::Caskroom.cask_installed?(${candidate.cask_token})'
		}
		return none
	}
	if candidate.method_name == 'installed?' && candidate.cask_token != '' {
		return 'Cask::Caskroom.cask_installed?(${candidate.cask_token})'
	}
	if candidate.method_name == 'installed_version' && candidate.cask_token != '' {
		return 'Cask::Caskroom.cask_installed_version(${candidate.cask_token})'
	}
	scoped_helpers := ['formula_any_version_installed?', 'formula_opt_bin', 'formula_opt_include',
		'formula_opt_lib', 'formula_opt_libexec', 'formula_opt_prefix']
	if candidate.receiver in ['Utils::Path', '::Utils::Path'] && candidate.method_name in scoped_helpers {
		if candidate.in_service {
			return '${candidate.method_name}(${candidate.argument})'
		}
		return none
	}
	if candidate.in_rescue || candidate.formula_name == '' {
		return none
	}
	helper := match candidate.method_name {
		'opt_bin' { 'formula_opt_bin' }
		'opt_lib' { 'formula_opt_lib' }
		'opt_libexec' { 'formula_opt_libexec' }
		'opt_include' { 'formula_opt_include' }
		'opt_prefix' { 'formula_opt_prefix' }
		else {
			return none
		}
	}
	helper_receiver := if candidate.in_formula || candidate.in_cask { '' } else { 'Utils::Path.' }
	return '${helper_receiver}${helper}(${candidate.formula_name})'
}

pub fn audit_formula_path_methods(source string) []FormulaPathProblem {
	mut problems := []FormulaPathProblem{}
	for candidate in formula_path_candidates(source) {
		preferred := preferred_formula_path_call(candidate) or { continue }
		problems << FormulaPathProblem{
			begin_pos: candidate.begin_pos
			end_pos: candidate.end_pos
			current: candidate.source
			preferred: preferred
			message: 'Use `${preferred}` instead of `${candidate.source}`.'
			replacement: preferred
		}
	}
	return problems
}

pub fn correct_formula_path_methods(source string) string {
	mut problems := audit_formula_path_methods(source)
	problems.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in problems {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

fn formula_path_problem_value(problem FormulaPathProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', problem.message, {
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'current':     problem.current
		'preferred':   problem.preferred
		'message':     problem.message
		'replacement': problem.replacement
	})
}
