module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/compact_blank.rb`.
// The original source is retained below until every stub has a typed V body.
pub const compact_blank_message_template = 'Use `%s` instead.'

pub struct CompactBlankCall {
pub:
	method            string
	kind              string
	arguments         []string
	receiver_in_block string
	source            string
	selector_begin    int
	selector_end      int
	end_pos           int
	preferred_method  string
}

pub struct CompactBlankOffense {
pub:
	call        CompactBlankCall
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct CompactBlankAnalysis {
pub:
	offenses  []CompactBlankOffense
	corrected string
}

fn compact_blank_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn compact_blank_quoted_end(source string, start int) int {
	quote := source[start]
	mut escaped := false
	mut position := start + 1
	for position < source.len {
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
	return source.len
}

fn compact_blank_skip_comment(source string, start int) int {
	mut position := start
	for position < source.len && source[position] != `\n` {
		position++
	}
	return position
}

fn compact_blank_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	return position
}

fn compact_blank_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn compact_blank_matching_delimiter(source string, open int, opening u8, closing u8) ?int {
	mut depth := 1
	mut position := open + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if character == opening {
			depth++
		} else if character == closing {
			depth--
			if depth == 0 {
				return position
			}
		}
		position++
	}
	return none
}

fn compact_blank_word_at(source string, position int, word string) bool {
	if position < 0 || position + word.len > source.len || source[position..position + word.len] != word {
		return false
	}
	before_ok := position == 0 || !compact_blank_identifier_byte(source[position - 1])
	after := position + word.len
	after_ok := after == source.len || !compact_blank_identifier_byte(source[after])
	return before_ok && after_ok
}

fn compact_blank_matching_end(source string, opening_do int) ?int {
	mut depth := 1
	mut position := opening_do + 2
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if compact_blank_word_at(source, position, 'do') {
			depth++
			position += 2
			continue
		}
		if compact_blank_word_at(source, position, 'end') {
			depth--
			if depth == 0 {
				return position
			}
			position += 3
			continue
		}
		position++
	}
	return none
}

fn compact_blank_without_comments_and_space(source string) string {
	mut result := ''
	mut position := 0
	for position < source.len {
		character := source[position]
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		if !character.is_space() {
			result += character.ascii_str()
		}
		position++
	}
	return result
}

fn compact_blank_argument_sources(source string) []string {
	mut arguments := []string{}
	mut start := 0
	mut position := 0
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					argument_start, argument_end := compact_blank_trim_range(source, start, position)
					arguments << source[argument_start..argument_end]
					start = position + 1
				}
			}
			else {}
		}
		position++
	}
	argument_start, argument_end := compact_blank_trim_range(source, start, source.len)
	if argument_start < argument_end {
		arguments << source[argument_start..argument_end]
	}
	return arguments
}

fn compact_blank_local_variable(source string) bool {
	if source.len == 0 || !(source[0].is_letter() || source[0] == `_`) || source[0].is_capital() {
		return false
	}
	for character in source.bytes() {
		if !compact_blank_identifier_byte(character) {
			return false
		}
	}
	return true
}

fn compact_blank_block_parts(source string, body_begin int, body_end int) ?([]string, string) {
	mut position := compact_blank_skip_space(source, body_begin)
	if position >= body_end || source[position] != `|` {
		return none
	}
	arguments_begin := position + 1
	position = arguments_begin
	for position < body_end && source[position] != `|` {
		if source[position] in [`'`, `\"`] || source[position] == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		position++
	}
	if position >= body_end {
		return none
	}
	arguments := compact_blank_argument_sources(source[arguments_begin..position])
	body_start, body_finish := compact_blank_trim_range(source, position + 1, body_end)
	if body_start >= body_finish {
		return none
	}
	body := compact_blank_without_comments_and_space(source[body_start..body_finish])
	mut receiver := ''
	if body.ends_with('.blank?()') {
		receiver = body[..body.len - '.blank?()'.len]
	} else if body.ends_with('.blank?') {
		receiver = body[..body.len - '.blank?'.len]
	} else {
		return none
	}
	if !compact_blank_local_variable(receiver) {
		return none
	}
	return arguments, receiver
}

fn compact_blank_method_at(source string, selector int) ?string {
	if selector > 0 && compact_blank_identifier_byte(source[selector - 1]) {
		return none
	}
	if selector > 0 && source[selector - 1] == `:` {
		return none
	}
	if selector >= 2 && source[selector - 2..selector] == '&.' {
		return none
	}
	for method_name in ['delete_if', 'reject!', 'reject'] {
		if !source[selector..].starts_with(method_name) {
			continue
		}
		end_pos := selector + method_name.len
		if end_pos < source.len && (compact_blank_identifier_byte(source[end_pos]) || source[end_pos] in [
			`!`,
			`?`,
		]) {
			continue
		}
		return method_name
	}
	return none
}

fn compact_blank_is_block_pass(source string) bool {
	return compact_blank_without_comments_and_space(source) == '&:blank?'
}

fn compact_blank_candidate_at(source string, selector int, method_name string) ?CompactBlankCall {
	selector_end := selector + method_name.len
	mut position := compact_blank_skip_space(source, selector_end)
	mut parenthesized_empty := false
	if position < source.len && source[position] == `(` {
		close := compact_blank_matching_delimiter(source, position, `(`, `)`) or { return none }
		inner_start, inner_end := compact_blank_trim_range(source, position + 1, close)
		if compact_blank_is_block_pass(source[inner_start..inner_end]) {
			return CompactBlankCall{
				method: method_name
				kind: 'block_pass'
				source: source[selector..close + 1]
				selector_begin: selector
				selector_end: selector_end
				end_pos: close + 1
				preferred_method: if method_name == 'reject' {
					'compact_blank'
				} else {
					'compact_blank!'
				}
			}
		}
		if inner_start < inner_end {
			return none
		}
		parenthesized_empty = true
		position = compact_blank_skip_space(source, close + 1)
	}
	if !parenthesized_empty && position < source.len && source[position..].starts_with('&:blank?') {
		end_pos := position + '&:blank?'.len
		if end_pos == source.len || !compact_blank_identifier_byte(source[end_pos]) {
			return CompactBlankCall{
				method: method_name
				kind: 'block_pass'
				source: source[selector..end_pos]
				selector_begin: selector
				selector_end: selector_end
				end_pos: end_pos
				preferred_method: if method_name == 'reject' {
					'compact_blank'
				} else {
					'compact_blank!'
				}
			}
		}
	}
	mut body_begin := 0
	mut body_end := 0
	mut call_end := 0
	if position < source.len && source[position] == `{` {
		close := compact_blank_matching_delimiter(source, position, `{`, `}`) or { return none }
		body_begin = position + 1
		body_end = close
		call_end = close + 1
	} else if compact_blank_word_at(source, position, 'do') {
		closing_end := compact_blank_matching_end(source, position) or { return none }
		body_begin = position + 2
		body_end = closing_end
		call_end = closing_end + 3
	} else {
		return none
	}
	arguments, receiver := compact_blank_block_parts(source, body_begin, body_end) or { return none }
	return CompactBlankCall{
		method: method_name
		kind: 'block'
		arguments: arguments
		receiver_in_block: receiver
		source: source[selector..call_end]
		selector_begin: selector
		selector_end: selector_end
		end_pos: call_end
		preferred_method: if method_name == 'reject' { 'compact_blank' } else { 'compact_blank!' }
	}
}

pub fn compact_blank_uses_single_value(arguments []string, receiver_in_block string) bool {
	return arguments.len == 1 && arguments[0] == receiver_in_block
}

pub fn compact_blank_uses_hash_value(arguments []string, receiver_in_block string) bool {
	return arguments.len == 2 && arguments[1] == receiver_in_block
}

pub fn compact_blank_bad_method(call CompactBlankCall) bool {
	return call.kind == 'block_pass' || compact_blank_uses_single_value(call.arguments, call.receiver_in_block) || compact_blank_uses_hash_value(call.arguments, call.receiver_in_block)
}

pub fn compact_blank_candidates(source string) []CompactBlankCall {
	mut calls := []CompactBlankCall{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] || character == u8(0x60) {
			position = compact_blank_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = compact_blank_skip_comment(source, position)
			continue
		}
		method_name := compact_blank_method_at(source, position) or {
			position++
			continue
		}
		if call := compact_blank_candidate_at(source, position, method_name) {
			calls << call
		}
		position += method_name.len
	}
	return calls
}

pub fn audit_compact_blank(source string) []CompactBlankOffense {
	mut offenses := []CompactBlankOffense{}
	for call in compact_blank_candidates(source) {
		if !compact_blank_bad_method(call) {
			continue
		}
		message := compact_blank_message_template.replace_once('%s', call.preferred_method)
		offenses << CompactBlankOffense{
			call: call
			begin_pos: call.selector_begin
			end_pos: call.end_pos
			message: message
			replacement: call.preferred_method
		}
	}
	return offenses
}

pub fn correct_compact_blank(source string) string {
	offenses := audit_compact_blank(source)
	mut corrected := source
	for index in 0 .. offenses.len {
		offense := offenses[offenses.len - 1 - index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

pub fn analyze_compact_blank(source string) CompactBlankAnalysis {
	return CompactBlankAnalysis{
		offenses: audit_compact_blank(source)
		corrected: correct_compact_blank(source)
	}
}

fn compact_blank_call_value(call CompactBlankCall, type_name string) ruby.Value {
	return ruby.structured_value(type_name, call.source, {
		'method':            call.method
		'kind':              call.kind
		'arguments':         call.arguments.join(',')
		'receiver_in_block': call.receiver_in_block
		'begin_pos':         call.selector_begin.str()
		'selector_end':      call.selector_end.str()
		'end_pos':           call.end_pos.str()
		'preferred_method':  call.preferred_method
	})
}

fn compact_blank_offense_value(offense CompactBlankOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':      offense.call.method
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby def_node_matcher `def_node_matcher :reject_with_block?, <<~PATTERN` at line 51.
pub fn ruby_compact_blank_l51_d1_reject_with_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	for call in compact_blank_candidates(source) {
		if call.kind == 'block' {
			return compact_blank_call_value(call, 'RuboCop::AST::NodeMatch')
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby def_node_matcher `def_node_matcher :reject_with_block_pass?, <<~PATTERN` at line 59.
pub fn ruby_compact_blank_l59_d2_reject_with_block_pass(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	for call in compact_blank_candidates(source) {
		if call.kind == 'block_pass' {
			return compact_blank_call_value(call, 'RuboCop::AST::NodeMatch')
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `on_send(node)` at line 66.
pub fn ruby_compact_blank_l66_d3_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_compact_blank(source)
	if offenses.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return compact_blank_offense_value(offenses[0])
}

// Ruby method `bad_method?(node)` at line 79.
pub fn ruby_compact_blank_l79_d4_bad_method(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	calls := compact_blank_candidates(source)
	return ruby.bool_value(calls.len > 0 && compact_blank_bad_method(calls[0]))
}

// Ruby method `use_single_value_block_argument?(arguments, receiver_in_block)` at line 93.
pub fn ruby_compact_blank_l93_d5_use_single_value_block_argument(args ...ruby.Value) ruby.Value {
	arguments := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].string_array_data
	} else if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string().split(',').map(it.trim_space())
	} else {
		[]string{}
	}
	receiver := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.bool_value(compact_blank_uses_single_value(arguments, receiver))
}

// Ruby method `use_hash_value_block_argument?(arguments, receiver_in_block)` at line 100.
pub fn ruby_compact_blank_l100_d6_use_hash_value_block_argument(args ...ruby.Value) ruby.Value {
	arguments := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].string_array_data
	} else if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string().split(',').map(it.trim_space())
	} else {
		[]string{}
	}
	receiver := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.bool_value(compact_blank_uses_hash_value(arguments, receiver))
}

// Ruby method `offense_range(node)` at line 105.
pub fn ruby_compact_blank_l105_d7_offense_range(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	calls := compact_blank_candidates(source)
	if calls.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	call := calls[0]
	return ruby.structured_value('Parser::Source::Range', call.source, {
		'begin_pos': call.selector_begin.str()
		'end_pos':   call.end_pos.str()
	})
}

// Ruby method `preferred_method(node)` at line 116.
pub fn ruby_compact_blank_l116_d8_preferred_method(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('compact_blank!')
	}
	if args[0].attributes['method'] == 'reject' || args[0].as_string() == 'reject' {
		return ruby.string_value('compact_blank')
	}
	calls := compact_blank_candidates(args[0].as_string())
	if calls.len > 0 && calls[0].method == 'reject' {
		return ruby.string_value('compact_blank')
	}
	return ruby.string_value('compact_blank!')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks if collection can be blank-compacted with `compact_blank`.
// 8:       #
// 9:       # NOTE: It is unsafe by default because false positives may occur in the
// 10:       #       blank check of block arguments to the receiver object.
// 11:       #
// 12:       #       For example, `[[1, 2], [3, nil]].reject { |first, second| second.blank? }` and
// 13:       #       `[[1, 2], [3, nil]].compact_blank` are not compatible. The same is true for `blank?`.
// 14:       #       This will work fine when the receiver is a hash object.
// 15:       #
// 16:       #       And `compact_blank!` has different implementations for `Array`, `Hash` and
// 17:       #       `ActionController::Parameters`.
// 18:       #       `Array#compact_blank!`, `Hash#compact_blank!` are equivalent to `delete_if(&:blank?)`.
// 19:       #       `ActionController::Parameters#compact_blank!` is equivalent to `reject!(&:blank?)`.
// 20:       #       If the cop makes a mistake, autocorrected code may get unexpected behavior.
// 21:       #
// 22:       # ### Examples
// 23:       #
// 24:       # ```ruby
// 25:       # # bad
// 26:       # collection.reject(&:blank?)
// 27:       # collection.reject { |_k, v| v.blank? }
// 28:       #
// 29:       # # good
// 30:       # collection.compact_blank
// 31:       # ```
// 32:       #
// 33:       # ```ruby
// 34:       # # bad
// 35:       # collection.delete_if(&:blank?)           # Same behavior as `Array#compact_blank!` and `Hash#compact_blank!`
// 36:       # collection.delete_if { |_, v| v.blank? } # Same behavior as `Array#compact_blank!` and `Hash#compact_blank!`
// 37:       # collection.reject!(&:blank?)             # Same behavior as `ActionController::Parameters#compact_blank!`
// 38:       # collection.reject! { |_k, v| v.blank? }  # Same behavior as `ActionController::Parameters#compact_blank!`
// 39:       #
// 40:       # # good
// 41:       # collection.compact_blank!
// 42:       # ```
// 43:       class CompactBlank < Base
// 44:         include RangeHelp
// 45:         extend AutoCorrector
// 46:
// 47:         MSG = "Use `%<preferred_method>s` instead."
// 48:
// 49:         RESTRICT_ON_SEND = [:reject, :delete_if, :reject!].freeze
// 50:
// 51:         def_node_matcher :reject_with_block?, <<~PATTERN
// 52:           (block
// 53:             (send _ {:reject :delete_if :reject!})
// 54:             $(args ...)
// 55:             (send
// 56:               $(lvar _) :blank?))
// 57:         PATTERN
// 58:
// 59:         def_node_matcher :reject_with_block_pass?, <<~PATTERN
// 60:           (send _ {:reject :delete_if :reject!}
// 61:             (block_pass
// 62:               (sym :blank?)))
// 63:         PATTERN
// 64:
// 65:         sig { params(node: RuboCop::AST::SendNode).void }
// 66:         def on_send(node)
// 67:           return unless bad_method?(node)
// 68:
// 69:           range = offense_range(node)
// 70:           preferred_method = preferred_method(node)
// 71:           add_offense(range, message: format(MSG, preferred_method:)) do |corrector|
// 72:             corrector.replace(range, preferred_method)
// 73:           end
// 74:         end
// 75:
// 76:         private
// 77:
// 78:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 79:         def bad_method?(node)
// 80:           return true if reject_with_block_pass?(node)
// 81:
// 82:           if (arguments, receiver_in_block = reject_with_block?(node.parent))
// 83:             return use_single_value_block_argument?(arguments, receiver_in_block) ||
// 84:                    use_hash_value_block_argument?(arguments, receiver_in_block)
// 85:           end
// 86:
// 87:           false
// 88:         end
// 89:
// 90:         sig {
// 91:           params(arguments: RuboCop::AST::ArgsNode, receiver_in_block: RuboCop::AST::Node).returns(T::Boolean)
// 92:         }
// 93:         def use_single_value_block_argument?(arguments, receiver_in_block)
// 94:           arguments.length == 1 && arguments.fetch(0).source == receiver_in_block.source
// 95:         end
// 96:
// 97:         sig {
// 98:           params(arguments: RuboCop::AST::ArgsNode, receiver_in_block: RuboCop::AST::Node).returns(T::Boolean)
// 99:         }
// 100:         def use_hash_value_block_argument?(arguments, receiver_in_block)
// 101:           arguments.length == 2 && arguments.fetch(1).source == receiver_in_block.source
// 102:         end
// 103:
// 104:         sig { params(node: RuboCop::AST::SendNode).returns(Parser::Source::Range) }
// 105:         def offense_range(node)
// 106:           end_pos = if node.parent&.block_type? && node.parent&.send_node == node
// 107:             node.parent.source_range.end_pos
// 108:           else
// 109:             node.source_range.end_pos
// 110:           end
// 111:
// 112:           range_between(node.loc.selector.begin_pos, end_pos)
// 113:         end
// 114:
// 115:         sig { params(node: RuboCop::AST::SendNode).returns(String) }
// 116:         def preferred_method(node)
// 117:           node.method?(:reject) ? "compact_blank" : "compact_blank!"
// 118:         end
// 119:       end
// 120:     end
// 121:   end
// 122: end
