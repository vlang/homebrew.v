module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/install_steps_source_independence.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `on_send(node)` at line 15.
pub fn ruby_install_steps_source_independence_l15_d1_on_send(args ...ruby.Value) ruby.Value {
	expression := if args.len > 0 { args[0].as_string() } else { '' }
	return if install_steps_source_dependent(expression) {
		install_steps_source_offense_value(InstallStepsSourceOffense{
			kind: 'source_dependent_send'
			expression: expression
			end_pos: expression.len
			message: install_steps_source_independence_message
		})
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby alias `alias on_csend on_send` at line 18.
pub fn ruby_install_steps_source_independence_l18_d2_on_csend(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_source_independence_l15_d1_on_send(...args)
}

// Ruby method `on_const(node)` at line 21.
pub fn ruby_install_steps_source_independence_l21_d3_on_const(args ...ruby.Value) ruby.Value {
	constant := if args.len > 0 { args[0].as_string() } else { '' }
	is_send_receiver := if args.len > 1 { args[1].bool_data } else { false }
	return if constant in ['Formula', 'Formulary', 'Resource'] && !is_send_receiver {
		install_steps_source_offense_value(InstallStepsSourceOffense{
			kind: 'source_constant'
			expression: constant
			end_pos: constant.len
			message: install_steps_source_independence_message
		})
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `source_dependent?(node)` at line 33.
pub fn ruby_install_steps_source_independence_l33_d4_source_dependent(args ...ruby.Value) ruby.Value {
	expression := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(install_steps_source_dependent(expression))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Prevents structured install-step runners from depending on formula
// 8:       # source, formula resources or direct downloads after a bottle is poured.
// 9:       class InstallStepsSourceIndependence < Base
// 10:         MSG = "Install-step runners must use bottled files and API context " \
// 11:               "without loading formula source or resources."
// 12:         SOURCE_CONSTANTS = %w[Formula Formulary Resource].freeze
// 13:
// 14:         sig { params(node: RuboCop::AST::SendNode).void }
// 15:         def on_send(node)
// 16:           add_offense(node) if source_dependent?(node)
// 17:         end
// 18:         alias on_csend on_send
// 19:
// 20:         sig { params(node: RuboCop::AST::ConstNode).void }
// 21:         def on_const(node)
// 22:           return unless SOURCE_CONSTANTS.include?(node.const_name)
// 23:
// 24:           parent = node.parent
// 25:           return if parent.is_a?(RuboCop::AST::SendNode) && parent.receiver == node
// 26:
// 27:           add_offense(node)
// 28:         end
// 29:
// 30:         private
// 31:
// 32:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 33:         def source_dependent?(node)
// 34:           return true if node.method?(:resource)
// 35:
// 36:           receiver = node.receiver
// 37:           return false unless receiver.is_a?(RuboCop::AST::ConstNode)
// 38:           return true if SOURCE_CONSTANTS.include?(receiver.const_name)
// 39:           return true if receiver.const_name == "Utils::Curl"
// 40:
// 41:           receiver.const_name == "URI" && (node.method?(:open) || node.method?(:read))
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
