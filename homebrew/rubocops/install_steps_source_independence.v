module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/install_steps_source_independence.rb`.
pub const install_steps_source_independence_message = 'Install-step runners must use bottled files and API context without loading formula source or resources.'

pub struct InstallStepsSourceOffense {
pub:
	kind       string
	expression string
	begin_pos  int
	end_pos    int
	message    string
}

fn install_steps_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_` || character == `:`
}

pub fn install_steps_source_dependent(expression string) bool {
	trimmed := expression.trim_space()
	if trimmed.starts_with('resource(') || trimmed.contains('.resource(') || trimmed.contains('&.resource(') {
		return true
	}
	for receiver in ['Formula', 'Formulary', 'Resource'] {
		if trimmed.starts_with('${receiver}.') || trimmed.starts_with('${receiver}[') || trimmed.starts_with('${receiver}&.') {
			return true
		}
	}
	if trimmed.starts_with('Utils::Curl.') || trimmed.starts_with('Utils::Curl&.') {
		return true
	}
	return trimmed.starts_with('URI.open(') || trimmed.starts_with('URI.read(') || trimmed.starts_with('URI&.open(') || trimmed.starts_with('URI&.read(')
}

fn install_steps_standalone_constants(line string, line_start int) []InstallStepsSourceOffense {
	mut offenses := []InstallStepsSourceOffense{}
	for constant in ['Formula', 'Formulary', 'Resource'] {
		mut cursor := 0
		for cursor < line.len {
			relative := line[cursor..].index(constant) or { break }
			start := cursor + relative
			end := start + constant.len
			before_ok := start == 0 || !install_steps_identifier_byte(line[start - 1])
			after_ok := end == line.len || !install_steps_identifier_byte(line[end])
			mut following := end
			for following < line.len && (line[following] == ` ` || line[following] == `\t`) {
				following++
			}
			receiver := following < line.len && (line[following] == `.` || line[following] == `[` || (line[following] == `&` && following + 1 < line.len && line[following + 1] == `.`))
			if before_ok && after_ok && !receiver {
				offenses << InstallStepsSourceOffense{
					kind: 'source_constant'
					expression: constant
					begin_pos: line_start + start
					end_pos: line_start + end
					message: install_steps_source_independence_message
				}
			}
			cursor = end
		}
	}
	offenses.sort(a.begin_pos < b.begin_pos)
	return offenses
}

pub fn audit_install_steps_source_independence(source string) []InstallStepsSourceOffense {
	mut offenses := []InstallStepsSourceOffense{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.trim_space()
		indent := line.len - line.trim_left(' \t').len
		if install_steps_source_dependent(trimmed) {
			offenses << InstallStepsSourceOffense{
				kind: 'source_dependent_send'
				expression: trimmed
				begin_pos: line_start + indent
				end_pos: line_end
				message: install_steps_source_independence_message
			}
		} else {
			offenses << install_steps_standalone_constants(line, line_start)
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return offenses
}

fn install_steps_source_offense_value(offense InstallStepsSourceOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':       offense.kind
		'expression': offense.expression
		'begin_pos':  offense.begin_pos.str()
		'end_pos':    offense.end_pos.str()
		'message':    offense.message
	})
}
