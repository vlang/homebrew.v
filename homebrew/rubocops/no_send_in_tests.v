module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_send_in_tests.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_send_in_tests_message_template = 'Make the method public and call it directly instead of using `%s` in tests.'
pub const no_send_in_tests_dynamic_message_template = 'Use `public_send` instead of `%s` in tests; `%s` bypasses method visibility.'
pub const no_send_in_tests_public_send_message = 'Call the method directly instead of using `public_send` with a static method name.'

const no_send_in_tests_methods = ['send', '__send__', 'public_send']
const no_send_in_tests_operators = ['[]', '[]=', '+', '-', '*', '/', '%', '**', '==', '!=', '<',
	'<=', '>', '>=', '<=>', '===', '=~', '!~', '&', '|', '^', '<<', '>>', '~', '!', '+@', '-@']

pub struct NoSendInTestsArgument {
pub:
	kind      string
	value     string
	begin_pos int
	end_pos   int
}

pub struct NoSendInTestsCall {
pub:
	method          string
	begin_pos       int
	end_pos         int
	safe_navigation bool
	argument        NoSendInTestsArgument
}

pub struct NoSendInTestsOffense {
pub:
	call      NoSendInTestsCall
	begin_pos int
	end_pos   int
	message   string
}

fn no_send_in_tests_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn no_send_in_tests_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn no_send_in_tests_skip_space(source string, start int, include_newlines bool) int {
	mut position := start
	for position < source.len && source[position].is_space() && (include_newlines || source[position] != `\n`) {
		position++
	}
	return position
}

fn no_send_in_tests_quoted_end(source string, start int, limit int) int {
	quote := source[start]
	mut escaped := false
	mut position := start + 1
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return position + 1
		}
		position++
	}
	return limit
}

fn no_send_in_tests_literal_value(raw string) NoSendInTestsArgument {
	if raw.len >= 2 && raw[0] == `:` {
		if raw.len >= 3 && raw[1] in [`'`, `\"`] {
			end := no_send_in_tests_quoted_end(raw, 1, raw.len)
			if end == raw.len && !raw[2..raw.len - 1].contains('#{') {
				return NoSendInTestsArgument{
					kind: 'symbol'
					value: raw[2..raw.len - 1]
				}
			}
			return NoSendInTestsArgument{ kind: 'dynamic' }
		}
		if !raw[1..].contains_any(' \t\r\n,') {
			return NoSendInTestsArgument{
				kind: 'symbol'
				value: raw[1..]
			}
		}
	}
	if raw.len >= 2 && raw[0] in [`'`, `\"`] {
		end := no_send_in_tests_quoted_end(raw, 0, raw.len)
		if end == raw.len && (raw[0] == `'` || !raw[1..raw.len - 1].contains('#{')) {
			return NoSendInTestsArgument{
				kind: 'string'
				value: raw[1..raw.len - 1]
			}
		}
	}
	return NoSendInTestsArgument{ kind: 'dynamic' }
}

fn no_send_in_tests_argument_end(source string, start int, closing u8) int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := start
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_send_in_tests_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` {
				if closing == `)` && round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
				round_depth--
			}
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			`\n` {
				if closing == `\n` && round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
			}
			else {}
		}
		position++
	}
	return source.len
}

fn no_send_in_tests_first_argument(source string, method_end int) NoSendInTestsArgument {
	mut position := no_send_in_tests_skip_space(source, method_end, false)
	mut closing := u8(`\n`)
	if position < source.len && source[position] == `(` {
		position = no_send_in_tests_skip_space(source, position + 1, true)
		closing = `)`
	} else if position == method_end {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	if position >= source.len || source[position] == closing || source[position] == `\n` {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	end := no_send_in_tests_argument_end(source, position, closing)
	mut finish := end
	for finish > position && source[finish - 1].is_space() {
		finish--
	}
	if finish <= position {
		return NoSendInTestsArgument{ kind: 'missing' }
	}
	mut argument := no_send_in_tests_literal_value(source[position..finish])
	argument = NoSendInTestsArgument{
		...argument
		begin_pos: position
		end_pos: finish
	}
	return argument
}

pub fn directly_callable_no_send_name(argument NoSendInTestsArgument) bool {
	if argument.kind !in ['symbol', 'string'] {
		return false
	}
	name := argument.value
	if name in no_send_in_tests_operators {
		return true
	}
	if name.len == 0 || !no_send_in_tests_identifier_start(name[0]) {
		return false
	}
	mut position := 1
	for position < name.len && no_send_in_tests_identifier_byte(name[position]) {
		position++
	}
	if position < name.len && name[position] in [`?`, `!`, `=`] {
		position++
	}
	return position == name.len
}

fn no_send_in_tests_declaration(source string, begin_pos int) bool {
	line_start := source[..begin_pos].last_index_u8(`\n`)
	prefix := source[line_start + 1..begin_pos].trim_space()
	return prefix == 'def' || prefix.starts_with('def ') || prefix == 'alias' || prefix.starts_with('alias ')
}

fn no_send_in_tests_call_at(source string, begin_pos int, method string) ?NoSendInTestsCall {
	if begin_pos > 0 && no_send_in_tests_identifier_byte(source[begin_pos - 1]) {
		return none
	}
	end_pos := begin_pos + method.len
	if end_pos < source.len && no_send_in_tests_identifier_byte(source[end_pos]) {
		return none
	}
	if no_send_in_tests_declaration(source, begin_pos) {
		return none
	}
	mut previous := begin_pos - 1
	for previous >= 0 && source[previous].is_space() && source[previous] != `\n` {
		previous--
	}
	if previous >= 0 && source[previous] == `:` {
		return none
	}
	after := no_send_in_tests_skip_space(source, end_pos, false)
	if after < source.len && ((after == end_pos && source[after] == `:`) || (source[after] == `=` && (after + 1 >= source.len || source[after + 1] !in [
		`=`,
		`>`,
		`~`,
	]))) {
		return none
	}
	return NoSendInTestsCall{
		method: method
		begin_pos: begin_pos
		end_pos: end_pos
		safe_navigation: begin_pos >= 2 && source[begin_pos - 2..begin_pos] == '&.'
		argument: no_send_in_tests_first_argument(source, end_pos)
	}
}

pub fn audit_no_send_in_tests(source string) []NoSendInTestsOffense {
	mut offenses := []NoSendInTestsOffense{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_send_in_tests_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if no_send_in_tests_identifier_start(character) {
			mut token_end := position + 1
			for token_end < source.len && no_send_in_tests_identifier_byte(source[token_end]) {
				token_end++
			}
			method := source[position..token_end]
			if method in no_send_in_tests_methods {
				if call := no_send_in_tests_call_at(source, position, method) {
					directly_callable := directly_callable_no_send_name(call.argument)
					if method != 'public_send' || directly_callable {
						message := if method == 'public_send' {
							no_send_in_tests_public_send_message
						} else if directly_callable {
							no_send_in_tests_message_template.replace('%s', method)
						} else {
							no_send_in_tests_dynamic_message_template.replace_once('%s', method).replace_once('%s', method)
						}
						offenses << NoSendInTestsOffense{
							call: call
							begin_pos: call.begin_pos
							end_pos: call.end_pos
							message: message
						}
					}
				}
			}
			position = token_end
			continue
		}
		position++
	}
	return offenses
}

fn no_send_in_tests_offense_value(offense NoSendInTestsOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':          offense.call.method
		'begin_pos':       offense.begin_pos.str()
		'end_pos':         offense.end_pos.str()
		'message':         offense.message
		'argument_kind':   offense.call.argument.kind
		'argument':        offense.call.argument.value
		'safe_navigation': offense.call.safe_navigation.str()
	})
}

// Ruby method `on_send(node)` at line 52.
pub fn ruby_no_send_in_tests_l52_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_no_send_in_tests(source)
	return if offenses.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		no_send_in_tests_offense_value(offenses[0])
	}
}

// Ruby alias `alias on_csend on_send` at line 67.
pub fn ruby_no_send_in_tests_l67_d2_on_csend(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_no_send_in_tests_l52_d1_on_send(...args)
}

// Ruby method `directly_callable_name?(argument)` at line 72.
pub fn ruby_no_send_in_tests_l72_d3_directly_callable_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name !in ['Symbol', 'String'] {
		return brew_runtime.bool_value(false)
	}
	mut value := args[0].as_string()
	kind := if args[0].type_name == 'Symbol' { 'symbol' } else { 'string' }
	if kind == 'symbol' && value.starts_with(':') {
		value = value[1..]
	}
	if value.len >= 2 && value[0] in [`'`, `\"`] && value[value.len - 1] == value[0] {
		value = value[1..value.len - 1]
	}
	return brew_runtime.bool_value(directly_callable_no_send_name(NoSendInTestsArgument{
		kind: kind
		value: value
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Flags `send`-family dispatch in tests. Tests should exercise methods the way real
// 8:       # callers do: a private method poked via `send` should be made public and called
// 9:       # directly instead.
// 10:       #
// 11:       # - `send`/`__send__` are always flagged: with a static method name the call can be
// 12:       #   written directly (after making the method public if needed); with a dynamic one
// 13:       #   it must go through `public_send` so it cannot bypass method visibility.
// 14:       # - `public_send` is flagged only when the method name is a literal that could have
// 15:       #   been written as a direct call: an identifier, setter or operator name such as
// 16:       #   `:[]` or `:<<`. A dynamic name (`public_send(method_name)`,
// 17:       #   `public_send(:"#{artifact_dsl_key}_phase")`) is the one legitimate use:
// 18:       #   parameterised dispatch to public API. A literal name with no direct call syntax
// 19:       #   (e.g. `:"gcc-9"`) is also allowed, as no direct call can spell it.
// 20:       #
// 21:       # ### Example
// 22:       #
// 23:       # ```ruby
// 24:       # # bad
// 25:       # formula.send(:active_spec)
// 26:       #
// 27:       # # good (with `active_spec` made public)
// 28:       # formula.active_spec
// 29:       #
// 30:       # # good (dynamic dispatch to public API in a parameterised example)
// 31:       # subject.public_send(:"#{artifact_dsl_key}_phase")
// 32:       # ```
// 33:       class NoSendInTests < Base
// 34:         MSG_SEND = "Make the method public and call it directly instead of using `%<method>s` in tests."
// 35:         MSG_SEND_DYNAMIC = "Use `public_send` instead of `%<method>s` in tests; " \
// 36:                            "`%<method>s` bypasses method visibility."
// 37:         MSG_PUBLIC_SEND = "Call the method directly instead of using `public_send` with a static method name."
// 38:         RESTRICT_ON_SEND = [:send, :__send__, :public_send].freeze
// 39:
// 40:         # A literal method name that direct call syntax can spell, including setters
// 41:         # (`public_send(:foo=, value)` can be written `receiver.foo = value`).
// 42:         DIRECTLY_CALLABLE_NAME = /\A[a-zA-Z_][a-zA-Z0-9_]*[?!=]?\z/
// 43:         # Operator method names that direct call syntax can also spell, e.g.
// 44:         # `receiver[key]`, `receiver[key] = value`, `receiver << value`, `!receiver`.
// 45:         # `rubocop-ast`'s `OPERATOR_METHODS` is a private constant and includes
// 46:         # `` ` ``, which no direct call on an explicit receiver can spell.
// 47:         DIRECTLY_CALLABLE_OPERATORS = %w(
// 48:           [] []= + - * / % ** == != < <= > >= <=> === =~ !~ & | ^ << >> ~ ! +@ -@
// 49:         ).freeze
// 50:
// 51:         sig { params(node: RuboCop::AST::SendNode).void }
// 52:         def on_send(node)
// 53:           directly_callable = directly_callable_name?(node.first_argument)
// 54:
// 55:           message = if node.method_name == :public_send
// 56:             return unless directly_callable
// 57:
// 58:             MSG_PUBLIC_SEND
// 59:           elsif directly_callable
// 60:             format(MSG_SEND, method: node.method_name)
// 61:           else
// 62:             format(MSG_SEND_DYNAMIC, method: node.method_name)
// 63:           end
// 64:
// 65:           add_offense(node.loc.selector, message:)
// 66:         end
// 67:         alias on_csend on_send
// 68:
// 69:         private
// 70:
// 71:         sig { params(argument: T.nilable(RuboCop::AST::Node)).returns(T::Boolean) }
// 72:         def directly_callable_name?(argument)
// 73:           return false unless argument
// 74:           return false if !argument.sym_type? && !argument.str_type?
// 75:
// 76:           name = argument.children.first.to_s
// 77:           name.match?(DIRECTLY_CALLABLE_NAME) || DIRECTLY_CALLABLE_OPERATORS.include?(name)
// 78:         end
// 79:       end
// 80:     end
// 81:   end
// 82: end
