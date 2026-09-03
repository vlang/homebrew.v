module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_fileutils_rmrf.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_fileutils_rmrf_message = 'Use `rm` or `rm_r` instead of `rm_rf`, `rm_f`, or `rmtree`.'

pub struct FileutilsCall {
pub:
	method       string
	receiver     string
	has_receiver bool
	argument     string
	begin_pos    int
	end_pos      int
}

pub struct FileutilsRmrfOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn fileutils_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn fileutils_code_end(line string) int {
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

fn fileutils_receiver_start(source string, line_start int, dot int) int {
	mut cursor := dot - 1
	mut depth := 0
	for cursor >= line_start {
		character := source[cursor]
		if character in [`)`, `]`, `}`] {
			depth++
		} else if character in [`(`, `[`, `{`] {
			if depth > 0 {
				depth--
			}
		}
		if depth == 0 && (character.is_space() || character in [`,`, `=`, `;`]) {
			return cursor + 1
		}
		cursor--
	}
	return line_start
}

fn fileutils_first_argument(source string, begin_pos int, end_pos int) string {
	range := source[begin_pos..end_pos]
	mut cursor := 0
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	for cursor < range.len {
		character := range[cursor]
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
		} else if character in [`(`, `[`, `{`] {
			depth++
		} else if character in [`)`, `]`, `}`] && depth > 0 {
			depth--
		} else if character == `,` && depth == 0 {
			return range[..cursor].trim_space()
		}
		cursor++
	}
	return range.trim_space()
}

fn fileutils_call_at(source string, line_start int, code_end int, method_start int, method string) ?FileutilsCall {
	method_end := method_start + method.len
	if method_end < code_end && fileutils_identifier(source[method_end]) {
		return none
	}
	mut has_receiver := false
	mut receiver := ''
	mut call_start := method_start
	if method_start > line_start && source[method_start - 1] == `.` {
		has_receiver = true
		call_start = fileutils_receiver_start(source, line_start, method_start - 1)
		receiver = source[call_start..method_start - 1].trim_space()
	} else if method_start > line_start && (fileutils_identifier(source[method_start - 1]) || source[method_start - 1] in [
		`:`,
		`@`,
	]) {
		return none
	}
	prefix := source[line_start..call_start].trim_space()
	if prefix == 'def' || prefix.ends_with(' def') || prefix == 'alias' || prefix.ends_with(' alias') {
		return none
	}
	mut cursor := method_end
	for cursor < code_end && source[cursor] in [` `, `\t`] {
		cursor++
	}
	mut argument := ''
	mut call_end := method_end
	if cursor < code_end && source[cursor] == `(` {
		arguments_begin := cursor + 1
		mut depth := 1
		mut quote := u8(0)
		mut escaped := false
		cursor++
		for cursor < code_end && depth > 0 {
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
				depth++
			} else if character == `)` {
				depth--
				if depth == 0 {
					argument = fileutils_first_argument(source, arguments_begin, cursor)
					call_end = cursor + 1
					break
				}
			}
			cursor++
		}
	} else if cursor < code_end {
		argument = fileutils_first_argument(source, cursor, code_end)
		call_end = code_end
	}
	return FileutilsCall{
		method: method
		receiver: receiver
		has_receiver: has_receiver
		argument: argument
		begin_pos: call_start
		end_pos: call_end
	}
}

pub fn find_fileutils_calls(source string) []FileutilsCall {
	mut calls := []FileutilsCall{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		code_end := line_start + fileutils_code_end(source[line_start..line_end])
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
			mut found := false
			for method in ['rm_rf', 'rm_f', 'rmtree'] {
				if source[cursor..code_end].starts_with(method) {
					if call := fileutils_call_at(source, line_start, code_end, cursor, method) {
						calls << call
						cursor = if call.end_pos > cursor {
							call.end_pos
						} else {
							cursor + method.len
						}
						found = true
						break
					}
				}
			}
			if !found {
				cursor++
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return calls
}

pub fn any_receiver_rm_r_f(call FileutilsCall) bool {
	return call.has_receiver && call.method in ['rm_rf', 'rm_f'] && call.receiver in [
		'FileUtils',
		'::FileUtils',
		'self',
	]
}

pub fn no_receiver_rm_r_f(call FileutilsCall) bool {
	return !call.has_receiver && call.method in ['rm_rf', 'rm_f']
}

pub fn no_receiver_rmtree(call FileutilsCall) bool {
	return !call.has_receiver && call.method == 'rmtree'
}

pub fn any_receiver_rmtree(call FileutilsCall) bool {
	return call.has_receiver && call.method == 'rmtree'
}

pub fn neither_rm_rf_nor_rmtree(call FileutilsCall) bool {
	return !any_receiver_rm_r_f(call) && !no_receiver_rm_r_f(call) && !any_receiver_rmtree(call) && !no_receiver_rmtree(call)
}

pub fn audit_no_fileutils_rmrf(source string) []FileutilsRmrfOffense {
	mut offenses := []FileutilsRmrfOffense{}
	for call in find_fileutils_calls(source) {
		if neither_rm_rf_nor_rmtree(call) {
			continue
		}
		class_name := if any_receiver_rm_r_f(call) || any_receiver_rmtree(call) {
			'FileUtils.'
		} else {
			''
		}
		new_method := if call.method in ['rm_rf', 'rmtree'] { 'rm_r' } else { 'rm' }
		mut argument := if any_receiver_rmtree(call) { call.receiver } else { call.argument }
		if !argument.starts_with('(') {
			argument = '(${argument})'
		}
		offenses << FileutilsRmrfOffense{
			begin_pos: call.begin_pos
			end_pos: call.end_pos
			message: no_fileutils_rmrf_message
			replacement: '${class_name}${new_method}${argument}'
		}
	}
	return offenses
}

pub fn correct_no_fileutils_rmrf(source string) string {
	mut offenses := audit_no_fileutils_rmrf(source)
	offenses.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for offense in offenses {
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn fileutils_call_argument(args []brew_runtime.Value) ?FileutilsCall {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	calls := find_fileutils_calls(source)
	if calls.len == 0 {
		return none
	}
	return calls[0]
}

fn fileutils_call_value(call FileutilsCall) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::AST::SendNode', call.method, {
		'method':       call.method
		'receiver':     call.receiver
		'has_receiver': call.has_receiver.str()
		'argument':     call.argument
		'begin_pos':    call.begin_pos.str()
		'end_pos':      call.end_pos.str()
	})
}

fn fileutils_offense_value(offense FileutilsRmrfOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby def_node_matcher `def_node_matcher :any_receiver_rm_r_f?, <<~PATTERN` at line 14.
pub fn ruby_no_fileutils_rmrf_l14_d1_any_receiver_rm_r_f(args ...brew_runtime.Value) brew_runtime.Value {
	call := fileutils_call_argument(args) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(any_receiver_rm_r_f(call))
}

// Ruby def_node_matcher `def_node_matcher :no_receiver_rm_r_f?, <<~PATTERN` at line 21.
pub fn ruby_no_fileutils_rmrf_l21_d2_no_receiver_rm_r_f(args ...brew_runtime.Value) brew_runtime.Value {
	call := fileutils_call_argument(args) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(no_receiver_rm_r_f(call))
}

// Ruby def_node_matcher `def_node_matcher :no_receiver_rmtree?, <<~PATTERN` at line 25.
pub fn ruby_no_fileutils_rmrf_l25_d3_no_receiver_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	call := fileutils_call_argument(args) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(no_receiver_rmtree(call))
}

// Ruby def_node_matcher `def_node_matcher :any_receiver_rmtree?, <<~PATTERN` at line 29.
pub fn ruby_no_fileutils_rmrf_l29_d4_any_receiver_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	call := fileutils_call_argument(args) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(any_receiver_rmtree(call))
}

// Ruby method `on_send(node)` at line 34.
pub fn ruby_no_fileutils_rmrf_l34_d5_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_no_fileutils_rmrf(source).map(fileutils_offense_value(it)))
}

// Ruby method `neither_rm_rf_nor_rmtree?(node)` at line 56.
pub fn ruby_no_fileutils_rmrf_l56_d6_neither_rm_rf_nor_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	call := fileutils_call_argument(args) or { return brew_runtime.bool_value(true) }
	return brew_runtime.bool_value(neither_rm_rf_nor_rmtree(call))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # This cop checks for the use of `FileUtils.rm_f`, `FileUtils.rm_rf`, or `{FileUtils,instance}.rmtree`
// 8:       # and recommends the safer versions.
// 9:       class NoFileutilsRmrf < Base
// 10:         extend AutoCorrector
// 11:
// 12:         MSG = "Use `rm` or `rm_r` instead of `rm_rf`, `rm_f`, or `rmtree`."
// 13:
// 14:         def_node_matcher :any_receiver_rm_r_f?, <<~PATTERN
// 15:           (send
// 16:             {(const {nil? cbase} :FileUtils) (self)}
// 17:             {:rm_rf :rm_f}
// 18:             ...)
// 19:         PATTERN
// 20:
// 21:         def_node_matcher :no_receiver_rm_r_f?, <<~PATTERN
// 22:           (send nil? {:rm_rf :rm_f} ...)
// 23:         PATTERN
// 24:
// 25:         def_node_matcher :no_receiver_rmtree?, <<~PATTERN
// 26:           (send nil? :rmtree ...)
// 27:         PATTERN
// 28:
// 29:         def_node_matcher :any_receiver_rmtree?, <<~PATTERN
// 30:           (send !nil? :rmtree ...)
// 31:         PATTERN
// 32:
// 33:         sig { params(node: RuboCop::AST::SendNode).void }
// 34:         def on_send(node)
// 35:           return if neither_rm_rf_nor_rmtree?(node)
// 36:
// 37:           add_offense(node) do |corrector|
// 38:             class_name = "FileUtils." if any_receiver_rm_r_f?(node) || any_receiver_rmtree?(node)
// 39:             new_method = if node.method?(:rm_rf) || node.method?(:rmtree)
// 40:               "rm_r"
// 41:             else
// 42:               "rm"
// 43:             end
// 44:
// 45:             args = if any_receiver_rmtree?(node)
// 46:               node.receiver&.source || node.arguments.first&.source
// 47:             else
// 48:               node.arguments.first.source
// 49:             end
// 50:             args = "(#{args})" unless args.start_with?("(")
// 51:             corrector.replace(node.loc.expression, "#{class_name}#{new_method}#{args}")
// 52:           end
// 53:         end
// 54:
// 55:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 56:         def neither_rm_rf_nor_rmtree?(node)
// 57:           !any_receiver_rm_r_f?(node) && !no_receiver_rm_r_f?(node) &&
// 58:             !any_receiver_rmtree?(node) && !no_receiver_rmtree?(node)
// 59:         end
// 60:       end
// 61:     end
// 62:   end
// 63: end
