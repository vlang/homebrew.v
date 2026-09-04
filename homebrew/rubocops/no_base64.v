module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/no_base64.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_base64_message = 'Homebrew no longer includes the `base64` gem; use `String#unpack1` or `Array#pack` instead.'

pub enum NoBase64OffenseKind {
	require_call
	base64_call
	base64_const
}

pub struct NoBase64Argument {
pub:
	source    string
	begin_pos int
	end_pos   int
}

pub struct NoBase64Call {
pub:
	receiver        string
	method          string
	begin_pos       int
	end_pos         int
	safe_navigation bool
	arguments       []NoBase64Argument
}

pub struct NoBase64Offense {
pub:
	kind             NoBase64OffenseKind
	begin_pos        int
	end_pos          int
	message          string
	method           string
	replacement      string
	correction_begin int
	correction_end   int
	correctable      bool
}

fn no_base64_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn no_base64_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn no_base64_skip_space(source string, start int, include_newlines bool) int {
	mut position := start
	for position < source.len && source[position].is_space() && (include_newlines || source[position] != `\n`) {
		position++
	}
	return position
}

fn no_base64_previous_nonspace(source string, start int) int {
	mut position := start - 1
	for position >= 0 && source[position].is_space() {
		position--
	}
	return position
}

fn no_base64_quoted_end(source string, start int, limit int) int {
	if start >= limit || source[start] !in [`'`, `\"`] {
		return start
	}
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

fn no_base64_trim_range(source string, begin_pos int, end_pos int) (int, int) {
	mut start := begin_pos
	mut finish := end_pos
	for start < finish && source[start].is_space() {
		start++
	}
	for finish > start && source[finish - 1].is_space() {
		finish--
	}
	return start, finish
}

fn no_base64_matching_paren(source string, opening int) int {
	mut depth := 1
	mut position := opening + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_base64_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if character == `(` {
			depth++
		} else if character == `)` {
			depth--
			if depth == 0 {
				return position
			}
		}
		position++
	}
	return source.len
}

fn no_base64_command_end(source string, start int) int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := start
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_base64_quoted_end(source, position, source.len)
			continue
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && character.is_space() {
			for keyword in ['if', 'unless', 'while', 'until', 'rescue'] {
				keyword_start := no_base64_skip_space(source, position, false)
				keyword_end := keyword_start + keyword.len
				if keyword_end <= source.len && source[keyword_start..keyword_end] == keyword && (keyword_end == source.len || !no_base64_identifier_byte(source[keyword_end])) {
					return position
				}
			}
		}
		match character {
			`(` { round_depth++ }
			`)` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					break
				}
				round_depth--
			}
			`[` { square_depth++ }
			`]` {
				if square_depth == 0 && round_depth == 0 && brace_depth == 0 {
					break
				}
				square_depth--
			}
			`{` { brace_depth++ }
			`}` {
				if brace_depth == 0 && round_depth == 0 && square_depth == 0 {
					break
				}
				brace_depth--
			}
			`#` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					break
				}
			}
			`\n`, `;` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					break
				}
			}
			else {}
		}
		position++
	}
	return position
}

fn no_base64_split_arguments(source string, begin_pos int, end_pos int) []NoBase64Argument {
	mut arguments := []NoBase64Argument{}
	mut argument_start := begin_pos
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := begin_pos
	for position <= end_pos {
		if position < end_pos && source[position] in [`'`, `\"`] {
			position = no_base64_quoted_end(source, position, end_pos)
			continue
		}
		if position < end_pos {
			match source[position] {
				`(` { round_depth++ }
				`)` { round_depth-- }
				`[` { square_depth++ }
				`]` { square_depth-- }
				`{` { brace_depth++ }
				`}` { brace_depth-- }
				else {}
			}
		}
		if position == end_pos || (source[position] == `,` && round_depth == 0 && square_depth == 0 && brace_depth == 0) {
			start, finish := no_base64_trim_range(source, argument_start, position)
			if start < finish {
				arguments << NoBase64Argument{
					source: source[start..finish]
					begin_pos: start
					end_pos: finish
				}
			}
			argument_start = position + 1
		}
		position++
	}
	return arguments
}

fn no_base64_parse_call(source string, begin_pos int, receiver string, method_start int,
	method_end int, safe_navigation bool) NoBase64Call {
	mut call_end := method_end
	mut arguments := []NoBase64Argument{}
	mut position := no_base64_skip_space(source, method_end, false)
	if position < source.len && source[position] == `(` {
		closing := no_base64_matching_paren(source, position)
		argument_end := if closing < source.len { closing } else { source.len }
		arguments = no_base64_split_arguments(source, position + 1, argument_end)
		call_end = if closing < source.len { closing + 1 } else { source.len }
	} else if position > method_end && position < source.len && source[position] !in [
		`\n`,
		`#`,
		`;`,
	] {
		argument_end := no_base64_command_end(source, position)
		arguments = no_base64_split_arguments(source, position, argument_end)
		_, call_end = no_base64_trim_range(source, position, argument_end)
	}
	return NoBase64Call{
		receiver: receiver
		method: source[method_start..method_end]
		begin_pos: begin_pos
		end_pos: call_end
		safe_navigation: safe_navigation
		arguments: arguments
	}
}

fn no_base64_top_level_const_at(source string, start int, name string) bool {
	if start < 0 || start + name.len > source.len || source[start..start + name.len] != name {
		return false
	}
	if start > 0 && no_base64_identifier_byte(source[start - 1]) {
		return false
	}
	if start + name.len < source.len && no_base64_identifier_byte(source[start + name.len]) {
		return false
	}
	previous := no_base64_previous_nonspace(source, start)
	if previous >= 0 && source[previous] == `:` {
		before_colons := no_base64_previous_nonspace(source, previous - 1)
		if previous == 0 || source[previous - 1] != `:` {
			return false
		}
		if before_colons >= 0 && (no_base64_identifier_byte(source[before_colons]) || source[before_colons] in [
			`)`,
			`]`,
		]) {
			return false
		}
	}
	return true
}

fn no_base64_receiver_call(source string, receiver_start int, receiver_end int,
	receiver string) ?NoBase64Call {
	mut position := no_base64_skip_space(source, receiver_end, true)
	mut safe_navigation := false
	if position + 1 < source.len && source[position..position + 2] == '&.' {
		safe_navigation = true
		position += 2
	} else if position < source.len && source[position] == `.` {
		position++
	} else {
		return none
	}
	position = no_base64_skip_space(source, position, true)
	if position >= source.len || !no_base64_identifier_start(source[position]) {
		return none
	}
	method_start := position
	position++
	for position < source.len && no_base64_identifier_byte(source[position]) {
		position++
	}
	if position < source.len && source[position] in [`?`, `!`] {
		position++
	}
	return no_base64_parse_call(source, receiver_start, receiver, method_start, position, safe_navigation)
}

fn no_base64_line_start(source string, position int) int {
	newline := source[..position].last_index_u8(`\n`)
	return newline + 1
}

fn no_base64_line_end(source string, position int, include_newline bool) int {
	relative := source[position..].index_u8(`\n`)
	if relative < 0 {
		return source.len
	}
	return position + relative + if include_newline { 1 } else { 0 }
}

fn no_base64_standalone_call(source string, call NoBase64Call) bool {
	line_start := no_base64_line_start(source, call.begin_pos)
	line_end := no_base64_line_end(source, call.end_pos, false)
	before := source[line_start..call.begin_pos].trim_space()
	after := source[call.end_pos..line_end].trim_space()
	return before == '' && (after == '' || after.starts_with('#'))
}

fn no_base64_require_call_at(source string, method_start int, method_end int) ?NoBase64Call {
	mut begin_pos := method_start
	mut receiver := ''
	previous := no_base64_previous_nonspace(source, method_start)
	if previous >= 0 && source[previous] == `.` {
		receiver_end := previous
		mut receiver_start := receiver_end
		for receiver_start > 0 && no_base64_identifier_byte(source[receiver_start - 1]) {
			receiver_start--
		}
		if receiver_start >= 2 && source[receiver_start - 2..receiver_start] == '::' {
			receiver_start -= 2
		}
		receiver = source[receiver_start..receiver_end].replace(' ', '')
		if receiver !in ['Kernel', '::Kernel'] {
			return none
		}
		begin_pos = receiver_start
	} else {
		if previous >= 0 && source[previous] in [`.`, `:`, `@`, `$`] {
			return none
		}
		line_start := no_base64_line_start(source, method_start)
		prefix := source[line_start..method_start].trim_space()
		if prefix == 'def' || prefix.ends_with(' def') || prefix == 'alias' || prefix.ends_with(' alias') {
			return none
		}
	}
	call := no_base64_parse_call(source, begin_pos, receiver, method_start, method_end, false)
	if call.arguments.len != 1 || !no_base64_string_literal_is_base64(call.arguments[0].source) {
		return none
	}
	return call
}

fn no_base64_string_literal_is_base64(expression string) bool {
	if expression.len < 2 || expression[0] !in [`'`, `\"`] || no_base64_quoted_end(expression, 0, expression.len) != expression.len {
		return false
	}
	if expression[0] == `\"` && expression[1..expression.len - 1].contains('#{') {
		return false
	}
	return expression[1..expression.len - 1] == 'base64'
}

fn no_base64_entire_parenthesized(expression string) bool {
	if expression.len < 2 || expression[0] != `(` || expression[expression.len - 1] != `)` {
		return false
	}
	return no_base64_matching_paren(expression, 0) == expression.len - 1
}

fn no_base64_has_top_level_operator(expression string) bool {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := 0
	for position < expression.len {
		character := expression[position]
		if character in [`'`, `\"`] {
			position = no_base64_quoted_end(expression, position, expression.len)
			continue
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && character == `[` && position > 0 {
			return true
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			else {}
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
			if character in [`!`, `?`] && position == expression.len - 1 && position > 0 && no_base64_identifier_byte(expression[position - 1]) {
				position++
				continue
			}
			if character in [`+`, `*`, `/`, `%`, `<`, `>`, `|`, `&`, `^`, `~`, `!`, `?`, `=`] {
				return true
			}
			if character == `-` && (position == 0 || expression[position - 1] != `e`) {
				return true
			}
			if character == `.` && position + 1 < expression.len && expression[position + 1] == `.` {
				return true
			}
		}
		position++
	}
	return false
}

fn no_base64_numeric_literal(expression string) bool {
	if expression == '' {
		return false
	}
	mut position := 0
	if expression[position] in [`+`, `-`] {
		position++
	}
	if position >= expression.len || !expression[position].is_digit() {
		return false
	}
	for position < expression.len {
		character := expression[position]
		if !character.is_alnum() && character !in [`_`, `.`, `+`, `-`] {
			return false
		}
		position++
	}
	return true
}

fn no_base64_literal(expression string) bool {
	if expression in ['nil', 'true', 'false', '__FILE__', '__LINE__', '__ENCODING__'] {
		return true
	}
	if no_base64_numeric_literal(expression) {
		return true
	}
	if expression.len >= 2 && expression[0] in [`'`, `\"`] && no_base64_quoted_end(expression, 0, expression.len) == expression.len {
		return true
	}
	if expression.len >= 2 && expression[0] == `:` && expression[1] != `:` {
		return true
	}
	if expression.len >= 2 && ((expression[0] == `[` && expression[expression.len - 1] == `]`) || (expression[0] == `{` && expression[expression.len - 1] == `}`)) {
		return true
	}
	return false
}

pub fn no_base64_chainable(expression string) bool {
	trimmed := expression.trim_space()
	if trimmed == '' {
		return false
	}
	if no_base64_entire_parenthesized(trimmed) {
		return true
	}
	if no_base64_literal(trimmed) {
		return true
	}
	if no_base64_has_top_level_operator(trimmed) {
		return false
	}
	if trimmed.starts_with('*') || trimmed.starts_with('&') {
		return false
	}
	return true
}

pub fn no_base64_call_replacement(call NoBase64Call) string {
	if call.arguments.len != 1 {
		return ''
	}
	argument := call.arguments[0].source
	match call.method {
		'decode64', 'strict_decode64' {
			if !no_base64_chainable(argument) {
				return ''
			}
			directive := if call.method == 'decode64' { 'm' } else { 'm0' }
			return '${argument}.unpack1("${directive}")'
		}
		'encode64', 'strict_encode64' {
			trimmed := argument.trim_space()
			if trimmed.starts_with('*') || trimmed.starts_with('&') {
				return ''
			}
			directive := if call.method == 'encode64' { 'm' } else { 'm0' }
			return '[${argument}].pack("${directive}")'
		}
		else {
			return ''
		}
	}
}

fn no_base64_formula_class_identifier(source string, const_start int) bool {
	line_start := no_base64_line_start(source, const_start)
	return source[line_start..const_start].trim_space() in ['class', 'class ::']
}

pub fn audit_no_base64(source string) []NoBase64Offense {
	mut offenses := []NoBase64Offense{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = no_base64_quoted_end(source, position, source.len)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if no_base64_identifier_start(character) {
			mut token_end := position + 1
			for token_end < source.len && no_base64_identifier_byte(source[token_end]) {
				token_end++
			}
			token := source[position..token_end]
			if token == 'require' {
				if call := no_base64_require_call_at(source, position, token_end) {
					correctable := no_base64_standalone_call(source, call)
					offenses << NoBase64Offense{
						kind: .require_call
						begin_pos: call.begin_pos
						end_pos: call.end_pos
						message: no_base64_message
						method: call.method
						correction_begin: if correctable {
							no_base64_line_start(source, call.begin_pos)
						} else {
							call.begin_pos
						}
						correction_end: if correctable {
							no_base64_line_end(source, call.end_pos, true)
						} else {
							call.end_pos
						}
						correctable: correctable
					}
				}
			} else if token == 'Base64' && no_base64_top_level_const_at(source, position, 'Base64') {
				receiver_start := if position >= 2 && source[position - 2..position] == '::' {
					position - 2
				} else {
					position
				}
				if call := no_base64_receiver_call(source, receiver_start, token_end, source[receiver_start..token_end]) {
					replacement := no_base64_call_replacement(call)
					offenses << NoBase64Offense{
						kind: .base64_call
						begin_pos: call.begin_pos
						end_pos: call.end_pos
						message: no_base64_message
						method: call.method
						replacement: replacement
						correction_begin: call.begin_pos
						correction_end: call.end_pos
						correctable: replacement != ''
					}
				} else if !no_base64_formula_class_identifier(source, receiver_start) {
					offenses << NoBase64Offense{
						kind: .base64_const
						begin_pos: receiver_start
						end_pos: token_end
						message: no_base64_message
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

pub fn correct_no_base64(source string) string {
	offenses := audit_no_base64(source)
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		if !offense.correctable {
			continue
		}
		corrected = corrected[..offense.correction_begin] + offense.replacement + corrected[offense.correction_end..]
	}
	return corrected
}

fn no_base64_offense_value(offense NoBase64Offense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':        offense.kind.str()
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'method':      offense.method
		'replacement': offense.replacement
		'correctable': offense.correctable.str()
	})
}

// Ruby method `on_send(node)` at line 30.
pub fn ruby_no_base64_l30_d1_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[args.len - 1].as_string() } else { '' }
	for offense in audit_no_base64(source) {
		if offense.kind in [.require_call, .base64_call] {
			return no_base64_offense_value(offense)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby alias `alias on_csend on_send` at line 44.
pub fn ruby_no_base64_l44_d2_on_csend(args ...ruby.Value) ruby.Value {
	return ruby_no_base64_l30_d1_on_send(...args)
}

// Ruby method `on_const(node)` at line 47.
pub fn ruby_no_base64_l47_d3_on_const(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[args.len - 1].as_string() } else { '' }
	for offense in audit_no_base64(source) {
		if offense.kind == .base64_const {
			return no_base64_offense_value(offense)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `require_base64?(node)` at line 61.
pub fn ruby_no_base64_l61_d4_require_base64(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[args.len - 1].as_string() } else { '' }
	return ruby.bool_value(audit_no_base64(source).any(it.kind == .require_call))
}

// Ruby method `top_level_const?(node, name)` at line 72.
pub fn ruby_no_base64_l72_d5_top_level_const(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.bool_value(false)
	}
	source := args[0].as_string().trim_space()
	mut name := if args.len > 1 { args[1].as_string().trim_space() } else { 'Base64' }
	if name.starts_with(':') {
		name = name[1..]
	}
	if source == name {
		return ruby.bool_value(true)
	}
	if source == '::${name}' {
		return ruby.bool_value(true)
	}
	return ruby.bool_value(false)
}

// Ruby method `autocorrect_base64_call(corrector, node)` at line 81.
pub fn ruby_no_base64_l81_d6_autocorrect_base64_call(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[args.len - 1].as_string() } else { '' }
	for offense in audit_no_base64(source) {
		if offense.kind == .base64_call && offense.correctable {
			return ruby.string_value(offense.replacement)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `chainable?(node)` at line 99.
pub fn ruby_no_base64_l99_d7_chainable(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(no_base64_chainable(source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `String#unpack1` and `Array#pack` over the
// 8:       # `base64` gem, which Homebrew no longer includes.
// 9:       #
// 10:       # ### Example
// 11:       #
// 12:       # ```ruby
// 13:       # # bad
// 14:       # require "base64"
// 15:       # Base64.decode64(encoded)
// 16:       # Base64.strict_encode64(decoded)
// 17:       #
// 18:       # # good
// 19:       # encoded.unpack1("m")
// 20:       # [decoded].pack("m0")
// 21:       # ```
// 22:       class NoBase64 < Base
// 23:         include RangeHelp
// 24:         extend AutoCorrector
// 25:
// 26:         MSG = "Homebrew no longer includes the `base64` gem; " \
// 27:               "use `String#unpack1` or `Array#pack` instead."
// 28:
// 29:         sig { params(node: RuboCop::AST::SendNode).void }
// 30:         def on_send(node)
// 31:           if require_base64?(node)
// 32:             add_offense(node) do |corrector|
// 33:               parent = node.parent
// 34:               next if parent && !parent.begin_type?
// 35:
// 36:               corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 37:             end
// 38:           elsif top_level_const?(node.receiver, :Base64)
// 39:             add_offense(node) do |corrector|
// 40:               autocorrect_base64_call(corrector, node)
// 41:             end
// 42:           end
// 43:         end
// 44:         alias on_csend on_send
// 45:
// 46:         sig { params(node: RuboCop::AST::ConstNode).void }
// 47:         def on_const(node)
// 48:           return unless top_level_const?(node, :Base64)
// 49:
// 50:           parent = node.parent
// 51:           return if parent.is_a?(RuboCop::AST::SendNode) && parent.receiver == node
// 52:           # Formulae for base64 tools are legitimately named `Base64`.
// 53:           return if parent.is_a?(RuboCop::AST::ClassNode) && parent.identifier == node
// 54:
// 55:           add_offense(node)
// 56:         end
// 57:
// 58:         private
// 59:
// 60:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 61:         def require_base64?(node)
// 62:           return false unless node.method?(:require)
// 63:
// 64:           receiver = node.receiver
// 65:           return false if receiver && !top_level_const?(receiver, :Kernel)
// 66:
// 67:           arg = node.first_argument
// 68:           node.arguments.one? && arg.is_a?(RuboCop::AST::StrNode) && arg.value == "base64"
// 69:         end
// 70:
// 71:         sig { params(node: T.nilable(RuboCop::AST::Node), name: Symbol).returns(T::Boolean) }
// 72:         def top_level_const?(node, name)
// 73:           return false unless node.is_a?(RuboCop::AST::ConstNode)
// 74:           return false if node.short_name != name
// 75:
// 76:           namespace = node.namespace
// 77:           namespace.nil? || namespace.cbase_type?
// 78:         end
// 79:
// 80:         sig { params(corrector: RuboCop::Cop::Corrector, node: RuboCop::AST::SendNode).void }
// 81:         def autocorrect_base64_call(corrector, node)
// 82:           return unless node.arguments.one?
// 83:
// 84:           arg = node.first_argument
// 85:           replacement = case node.method_name
// 86:           when :decode64, :strict_decode64
// 87:             directive = (node.method_name == :decode64) ? "m" : "m0"
// 88:             "#{arg.source}.unpack1(\"#{directive}\")" if chainable?(arg)
// 89:           when :encode64, :strict_encode64
// 90:             directive = (node.method_name == :encode64) ? "m" : "m0"
// 91:             "[#{arg.source}].pack(\"#{directive}\")" if !arg.splat_type? && !arg.block_pass_type?
// 92:           end
// 93:           return if replacement.nil?
// 94:
// 95:           corrector.replace(node, replacement)
// 96:         end
// 97:
// 98:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 99:         def chainable?(node)
// 100:           if node.is_a?(RuboCop::AST::SendNode)
// 101:             !node.operator_method? && !node.assignment_method?
// 102:           else
// 103:             node.variable? || node.const_type? || node.begin_type? ||
// 104:               (node.literal? && !node.range_type?)
// 105:           end
// 106:         end
// 107:       end
// 108:     end
// 109:   end
// 110: end
