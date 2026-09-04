module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/present.rb`.
// The original source is retained below until every stub has a typed V body.
pub const present_message_template = 'Use `%s` instead of `%s`.'

pub struct PresentOperand {
pub:
	source     string
	canonical  string
	has_source bool
}

pub struct PresentMatch {
pub:
	variable1   PresentOperand
	variable2   PresentOperand
	source      string
	begin_pos   int
	end_pos     int
	operator    string
	replacement string
	message     string
}

pub struct PresentOffense {
pub:
	matched     PresentMatch
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct PresentAnalysis {
pub:
	offenses  []PresentOffense
	corrected string
}

struct PresentOperator {
	begin_pos int
	end_pos   int
	source    string
}

fn present_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `@`, `$`, `.`, `:`, `?`, `!`]
}

fn present_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn present_canonical(source string) string {
	mut canonical := ''
	mut quote := u8(0)
	mut escaped := false
	for character in source.bytes() {
		if quote != 0 {
			canonical += character.ascii_str()
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			canonical += character.ascii_str()
		} else if !character.is_space() {
			canonical += character.ascii_str()
		}
	}
	return canonical
}

fn present_outer_parentheses(source string, begin_pos int, end_pos int) ?(int, int) {
	if end_pos - begin_pos < 2 || source[begin_pos] != `(` || source[end_pos - 1] != `)` {
		return none
	}
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for position := begin_pos; position < end_pos; position++ {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
		} else if character == `(` {
			depth++
		} else if character == `)` {
			depth--
			if depth == 0 && position != end_pos - 1 {
				return none
			}
		}
	}
	if depth != 0 {
		return none
	}
	return present_trim_range(source, begin_pos + 1, end_pos - 1)
}

fn present_top_level_operator(source string, begin_pos int, end_pos int) ?PresentOperator {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut quote := u8(0)
	mut escaped := false
	mut position := begin_pos
	for position < end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			position++
			continue
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
			if position + 1 < end_pos && source[position..position + 2] == '&&' {
				return PresentOperator{
					begin_pos: position
					end_pos: position + 2
					source: '&&'
				}
			}
			if position + 3 <= end_pos && source[position..position + 3] == 'and' {
				before_word := position == begin_pos || !present_identifier_byte(source[position - 1])
				after_word := position + 3 == end_pos || !present_identifier_byte(source[position + 3])
				if before_word && after_word {
					return PresentOperator{
						begin_pos: position
						end_pos: position + 3
						source: 'and'
					}
				}
			}
		}
		position++
	}
	return none
}

fn present_top_level_not_equal(source string, begin_pos int, end_pos int) ?int {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut quote := u8(0)
	mut escaped := false
	mut position := begin_pos
	for position + 1 < end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			position++
			continue
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
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && source[position..position + 2] == '!=' {
			return position
		}
		position++
	}
	return none
}

fn present_operand(source string, has_source bool) PresentOperand {
	return PresentOperand{
		source: source
		canonical: if has_source { present_canonical(source) } else { '' }
		has_source: has_source
	}
}

fn present_receiver(source string, begin_pos int, end_pos int, method string) ?PresentOperand {
	start, finish := present_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return none
	}
	text := source[start..finish]
	if text == method {
		return present_operand('', false)
	}
	suffix := '.${method}'
	if !text.ends_with(suffix) {
		return none
	}
	receiver_start, receiver_end := present_trim_range(source, start, finish - suffix.len)
	if receiver_start >= receiver_end || source[receiver_end - 1] == `&` {
		return none
	}
	return present_operand(source[receiver_start..receiver_end], true)
}

fn present_left_operand(source string, begin_pos int, end_pos int) ?PresentOperand {
	start, finish := present_trim_range(source, begin_pos, end_pos)
	if start >= finish {
		return none
	}
	if source[start] == `!` {
		mut after_first := start + 1
		for after_first < finish && source[after_first].is_space() {
			after_first++
		}
		if after_first < finish && source[after_first] == `!` {
			mut receiver_start := after_first + 1
			for receiver_start < finish && source[receiver_start].is_space() {
				receiver_start++
			}
			if receiver_start >= finish {
				return none
			}
			return present_operand(source[receiver_start..finish], true)
		}
		return present_receiver(source, after_first, finish, 'nil?')
	}
	if not_equal := present_top_level_not_equal(source, start, finish) {
		right_start, right_end := present_trim_range(source, not_equal + 2, finish)
		left_start, left_end := present_trim_range(source, start, not_equal)
		if source[right_start..right_end] != 'nil' || left_start >= left_end {
			return none
		}
		return present_operand(source[left_start..left_end], true)
	}
	return present_operand(source[start..finish], true)
}

fn present_right_operand(source string, begin_pos int, end_pos int) ?PresentOperand {
	start, finish := present_trim_range(source, begin_pos, end_pos)
	if start >= finish || source[start] != `!` {
		return none
	}
	mut receiver_start := start + 1
	for receiver_start < finish && source[receiver_start].is_space() {
		receiver_start++
	}
	return present_receiver(source, receiver_start, finish, 'empty?')
}

fn present_same_operand(first PresentOperand, second PresentOperand) bool {
	return first.has_source == second.has_source && first.canonical == second.canonical
}

pub fn match_present_expression(source string) ?PresentMatch {
	mut start, mut finish := present_trim_range(source, 0, source.len)
	for {
		inner_start, inner_end := present_outer_parentheses(source, start, finish) or { break }
		start = inner_start
		finish = inner_end
	}
	operator := present_top_level_operator(source, start, finish) or { return none }
	left := present_left_operand(source, start, operator.begin_pos) or { return none }
	right := present_right_operand(source, operator.end_pos, finish) or { return none }
	if !present_same_operand(left, right) {
		return none
	}
	replacement := if left.has_source { '${left.source}.present?' } else { 'present?' }
	current := source[start..finish]
	message := present_message_template.replace_once('%s', replacement).replace_once('%s', current)
	return PresentMatch{
		variable1: left
		variable2: right
		source: current
		begin_pos: start
		end_pos: finish
		operator: operator.source
		replacement: replacement
		message: message
	}
}

fn present_code_end(line string) int {
	mut quote := u8(0)
	mut escaped := false
	for position, character in line.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
		} else if character == `#` {
			return position
		}
	}
	return line.len
}

fn present_candidate_ranges(line string) [][]int {
	code_end := present_code_end(line)
	start, finish := present_trim_range(line, 0, code_end)
	if start >= finish {
		return [][]int{}
	}
	mut ranges := [[start, finish]]
	for keyword in ['if ', 'unless ', 'while ', 'until '] {
		if line[start..finish].starts_with(keyword) {
			candidate_start, candidate_end := present_trim_range(line, start + keyword.len, finish)
			ranges << [candidate_start, candidate_end]
		}
		marker := ' ${keyword}'
		if relative := line[start..finish].index(marker) {
			candidate_start, candidate_end := present_trim_range(line, start + relative + marker.len, finish)
			ranges << [candidate_start, candidate_end]
		}
	}
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for position := start; position < finish; position++ {
		character := line[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			depth++
		} else if character in [`)`, `]`, `}`] {
			depth--
		} else if character == `=` && depth == 0 {
			previous := if position > start { line[position - 1] } else { u8(0) }
			next := if position + 1 < finish { line[position + 1] } else { u8(0) }
			if previous !in [`=`, `!`, `<`, `>`] && next !in [`=`, `>`] {
				candidate_start, candidate_end := present_trim_range(line, position + 1, finish)
				ranges << [candidate_start, candidate_end]
			}
		}
	}
	return ranges
}

pub fn audit_present(source string) []PresentOffense {
	mut offenses := []PresentOffense{}
	mut line_start := 0
	for line_start <= source.len {
		newline := source.index_after('\n', line_start) or { source.len }
		line_end := if newline < source.len { newline } else { source.len }
		line := source[line_start..line_end]
		for candidate in present_candidate_ranges(line) {
			matched_local := match_present_expression(line[candidate[0]..candidate[1]]) or {
				continue
			}
			begin_pos := line_start + candidate[0] + matched_local.begin_pos
			end_pos := line_start + candidate[0] + matched_local.end_pos
			if offenses.any(it.begin_pos == begin_pos && it.end_pos == end_pos) {
				continue
			}
			matched := PresentMatch{
				...matched_local
				begin_pos: begin_pos
				end_pos: end_pos
			}
			offenses << PresentOffense{
				matched: matched
				begin_pos: begin_pos
				end_pos: end_pos
				message: matched.message
				replacement: matched.replacement
			}
		}
		if newline >= source.len {
			break
		}
		line_start = newline + 1
	}
	return offenses
}

pub fn correct_present(source string) string {
	offenses := audit_present(source)
	mut corrected := source
	for index in 0 .. offenses.len {
		offense := offenses[offenses.len - 1 - index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn present_match_value(matched PresentMatch, type_name string) ruby.Value {
	return ruby.structured_value(type_name, matched.source, {
		'variable1':   if matched.variable1.has_source { matched.variable1.source } else { 'nil' }
		'variable2':   if matched.variable2.has_source { matched.variable2.source } else { 'nil' }
		'begin_pos':   matched.begin_pos.str()
		'end_pos':     matched.end_pos.str()
		'operator':    matched.operator
		'message':     matched.message
		'replacement': matched.replacement
	})
}

fn present_offense_value(offense PresentOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby def_node_matcher `def_node_matcher :exists_and_not_empty?, <<~PATTERN` at line 26.
pub fn ruby_present_l26_d1_exists_and_not_empty(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	matched := match_present_expression(source) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return present_match_value(matched, 'RuboCop::AST::NodeMatch')
}

// Ruby method `on_and(node)` at line 41.
pub fn ruby_present_l41_d2_on_and(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_present(source)
	if offenses.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return present_offense_value(offenses[0])
}

// Ruby method `on_or(node)` at line 54.
pub fn ruby_present_l54_d3_on_or(args ...ruby.Value) ruby.Value {
	// The retained matcher only accepts an `and` node, so invoking it for an `or`
	// node never yields the block arguments used to register an offense.
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `autocorrect(corrector, node)` at line 65.
pub fn ruby_present_l65_d4_autocorrect(args ...ruby.Value) ruby.Value {
	source := if args.len > 1 {
		args[1].as_string()
	} else if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}
	matched := match_present_expression(source) or {
		return ruby.string_value(source)
	}
	return ruby.string_value(source[..matched.begin_pos] + matched.replacement + source[matched.end_pos..])
}

// Ruby method `replacement(node)` at line 74.
pub fn ruby_present_l74_d5_replacement(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' || args[0].as_string() == '' {
		return ruby.string_value('present?')
	}
	return ruby.string_value('${args[0].as_string()}.present?')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for code that can be simplified using `Object#present?`.
// 8:       #
// 9:       # ### Example
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # !foo.nil? && !foo.empty?
// 14:       #
// 15:       # # bad
// 16:       # foo != nil && !foo.empty?
// 17:       #
// 18:       # # good
// 19:       # foo.present?
// 20:       # ```
// 21:       class Present < Base
// 22:         extend AutoCorrector
// 23:
// 24:         MSG = "Use `%<prefer>s` instead of `%<current>s`."
// 25:
// 26:         def_node_matcher :exists_and_not_empty?, <<~PATTERN
// 27:           (and
// 28:               {
// 29:                 (send (send $_ :nil?) :!)
// 30:                 (send (send $_ :!) :!)
// 31:                 (send $_ :!= nil)
// 32:                 $_
// 33:               }
// 34:               {
// 35:                 (send (send $_ :empty?) :!)
// 36:               }
// 37:           )
// 38:         PATTERN
// 39:
// 40:         sig { params(node: RuboCop::AST::AndNode).void }
// 41:         def on_and(node)
// 42:           exists_and_not_empty?(node) do |var1, var2|
// 43:             return if var1 != var2
// 44:
// 45:             message = format(MSG, prefer: replacement(var1), current: node.source)
// 46:
// 47:             add_offense(node, message:) do |corrector|
// 48:               autocorrect(corrector, node)
// 49:             end
// 50:           end
// 51:         end
// 52:
// 53:         sig { params(node: RuboCop::AST::OrNode).void }
// 54:         def on_or(node)
// 55:           exists_and_not_empty?(node) do |var1, var2|
// 56:             return if var1 != var2
// 57:
// 58:             add_offense(node, message: MSG) do |corrector|
// 59:               autocorrect(corrector, node)
// 60:             end
// 61:           end
// 62:         end
// 63:
// 64:         sig { params(corrector: RuboCop::Cop::Corrector, node: RuboCop::AST::Node).void }
// 65:         def autocorrect(corrector, node)
// 66:           variable1, _variable2 = exists_and_not_empty?(node)
// 67:           range = node.source_range
// 68:           corrector.replace(range, replacement(variable1))
// 69:         end
// 70:
// 71:         private
// 72:
// 73:         sig { params(node: T.nilable(RuboCop::AST::Node)).returns(String) }
// 74:         def replacement(node)
// 75:           node.respond_to?(:source) ? "#{node&.source}.present?" : "present?"
// 76:         end
// 77:       end
// 78:     end
// 79:   end
// 80: end
