module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/variables.rb`.
pub struct CaskVariableAssignment {
pub:
	variable       string
	arch_condition string
	true_source    string
	false_source   string
	begin_pos      int
	end_pos        int
	source         string
}

pub struct CaskVariableOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn cask_variable_code_end(line string) int {
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

fn cask_variable_ternary_separator(source string) ?int {
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	mut has_value := false
	for index, character in source.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
				has_value = true
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		if character in [`(`, `[`, `{`] {
			depth++
			has_value = true
			continue
		}
		if character in [`)`, `]`, `}`] {
			if depth > 0 {
				depth--
			}
			has_value = true
			continue
		}
		if depth == 0 && character == `:` {
			previous_colon := index > 0 && source[index - 1] == `:`
			next_colon := index + 1 < source.len && source[index + 1] == `:`
			if has_value && !previous_colon && !next_colon {
				return index
			}
			continue
		}
		if !character.is_space() {
			has_value = true
		}
	}
	return none
}

fn parse_cask_variable_line(line string, line_start int) ?CaskVariableAssignment {
	code_end := cask_variable_code_end(line)
	code := line[..code_end]
	trimmed := code.trim_space()
	equals := trimmed.index('=') or { return none }
	variable := trimmed[..equals].trim_space()
	if variable.len == 0 || !variable[0].is_letter() || variable.bytes().any(!it.is_alnum() && it != `_`) {
		return none
	}
	right := trimmed[equals + 1..].trim_space()
	mut arch_condition := ''
	mut condition_end := 0
	for condition in ['arm?', 'intel?'] {
		prefix := 'Hardware::CPU.${condition}'
		if right.starts_with(prefix) {
			arch_condition = condition
			condition_end = prefix.len
			break
		}
	}
	if arch_condition == '' {
		return none
	}
	mut question := condition_end
	for question < right.len && right[question].is_space() {
		question++
	}
	if question >= right.len || right[question] != `?` {
		return none
	}
	branches := right[question + 1..].trim_space()
	separator := cask_variable_ternary_separator(branches) or { return none }
	true_source := branches[..separator].trim_space()
	false_source := branches[separator + 1..].trim_space()
	if true_source == '' || false_source == '' {
		return none
	}
	indent := code.len - code.trim_left(' \t').len
	begin_pos := line_start + indent
	return CaskVariableAssignment{
		variable: variable
		arch_condition: arch_condition
		true_source: true_source
		false_source: false_source
		begin_pos: begin_pos
		end_pos: line_start + code.trim_right(' \t').len
		source: source_for_cask_variable(trimmed)
	}
}

fn source_for_cask_variable(source string) string {
	return source
}

pub fn find_cask_variable_assignments(source string) []CaskVariableAssignment {
	mut assignments := []CaskVariableAssignment{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if assignment := parse_cask_variable_line(source[line_start..line_end], line_start) {
			assignments << assignment
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return assignments
}

pub fn cask_variable_blank_node(source string) bool {
	trimmed := source.trim_space()
	return trimmed == 'nil' || trimmed == '""' || trimmed == "''"
}

fn cask_variable_replacement(assignment CaskVariableAssignment) string {
	mut arm_source := assignment.true_source
	mut intel_source := assignment.false_source
	if assignment.arch_condition == 'intel?' {
		arm_source = assignment.false_source
		intel_source = assignment.true_source
	}
	mut replacement := if assignment.variable == 'arch' {
		'arch '
	} else {
		'${assignment.variable} = on_arch_conditional '
	}
	mut parameters := []string{}
	if !cask_variable_blank_node(arm_source) {
		parameters << 'arm: ${arm_source}'
	}
	if !cask_variable_blank_node(intel_source) {
		parameters << 'intel: ${intel_source}'
	}
	replacement += parameters.join(', ')
	return replacement
}

pub fn audit_cask_variables(source string) []CaskVariableOffense {
	mut offenses := []CaskVariableOffense{}
	for assignment in find_cask_variable_assignments(source) {
		replacement := cask_variable_replacement(assignment)
		offenses << CaskVariableOffense{
			begin_pos: assignment.begin_pos
			end_pos: assignment.end_pos
			message: 'Use `${replacement}` instead of `${assignment.source}`.'
			replacement: replacement
		}
	}
	return offenses
}

pub fn correct_cask_variables(source string) string {
	mut offenses := audit_cask_variables(source)
	offenses.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for offense in offenses {
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn cask_variable_offense_value(offense CaskVariableOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

fn cask_variable_assignment_value(assignment CaskVariableAssignment) ruby.Value {
	return ruby.structured_value('RuboCop::AST::LocalVariableAssignmentNode', assignment.source, {
		'variable':       assignment.variable
		'arch_condition': assignment.arch_condition
		'true_source':    assignment.true_source
		'false_source':   assignment.false_source
		'begin_pos':      assignment.begin_pos.str()
		'end_pos':        assignment.end_pos.str()
	})
}
