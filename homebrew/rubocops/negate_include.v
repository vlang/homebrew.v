module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/negate_include.rb`.
// The original source is retained below until every stub has a typed V body.
pub const negate_include_message = 'Use `.exclude?` and remove the negation part.'

pub struct NegateIncludeCall {
pub:
	receiver       string
	object         string
	source         string
	begin_pos      int
	end_pos        int
	receiver_begin int
	receiver_end   int
	object_begin   int
	object_end     int
}

pub struct NegateIncludeOffense {
pub:
	call        NegateIncludeCall
	message     string
	begin_pos   int
	end_pos     int
	replacement string
}

pub struct NegateIncludeAnalysis {
pub:
	offenses  []NegateIncludeOffense
	corrected string
}

fn negate_include_skip_horizontal_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() && source[position] != `\n` {
		position++
	}
	return position
}

fn negate_include_trim_range(source string, begin_pos int, end_pos int) (int, int) {
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

fn negate_include_quoted_end(source string, start int) int {
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

fn negate_include_closing_parenthesis(source string, open int) ?int {
	mut depth := 1
	mut position := open + 1
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = negate_include_quoted_end(source, position)
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
	return none
}

fn negate_include_has_top_level_comma(source string, begin_pos int, end_pos int) bool {
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	mut position := begin_pos
	for position < end_pos {
		character := source[position]
		if character in [`'`, `\"`] {
			position = negate_include_quoted_end(source, position)
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
					return true
				}
			}
			else {}
		}
		position++
	}
	return false
}

fn negate_include_match_at(source string, bang int) ?NegateIncludeCall {
	if bang < 0 || bang >= source.len || source[bang] != `!` {
		return none
	}
	if bang + 1 < source.len && source[bang + 1] in [`=`, `~`] {
		return none
	}
	expression_start := negate_include_skip_horizontal_space(source, bang + 1)
	if expression_start >= source.len || source[expression_start] == `\n` {
		return none
	}
	mut round_opens := []int{}
	mut square_depth := 0
	mut brace_depth := 0
	mut position := expression_start
	for position < source.len && source[position] != `\n` {
		character := source[position]
		if character in [`'`, `\"`] {
			position = negate_include_quoted_end(source, position)
			continue
		}
		if character == `#` {
			return none
		}
		match character {
			`(` { round_opens << position }
			`)` {
				if round_opens.len == 0 {
					return none
				}
				round_opens.delete_last()
			}
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			`.` {
				if square_depth != 0 || brace_depth != 0 || !source[position..].starts_with('.include?') {
					position++
					continue
				}
				mut receiver_start := expression_start
				for open in round_opens {
					receiver_start = negate_include_skip_horizontal_space(source, receiver_start)
					if open != receiver_start {
						return none
					}
					receiver_start = open + 1
				}
				receiver_start = negate_include_skip_horizontal_space(source, receiver_start)
				_, receiver_end := negate_include_trim_range(source, receiver_start, position)
				if receiver_start >= receiver_end {
					return none
				}
				after_method := position + '.include?'.len
				open := negate_include_skip_horizontal_space(source, after_method)
				if open >= source.len || source[open] != `(` {
					return none
				}
				close := negate_include_closing_parenthesis(source, open) or { return none }
				object_begin, object_end := negate_include_trim_range(source, open + 1, close)
				if object_begin >= object_end || negate_include_has_top_level_comma(source, object_begin, object_end) {
					return none
				}
				mut end_pos := close + 1
				for _ in 0 .. round_opens.len {
					end_pos = negate_include_skip_horizontal_space(source, end_pos)
					if end_pos >= source.len || source[end_pos] != `)` {
						return none
					}
					end_pos++
				}
				after_call := negate_include_skip_horizontal_space(source, end_pos)
				if after_call < source.len && source[after_call] in [`.`, `[`] {
					return none
				}
				return NegateIncludeCall{
					receiver: source[receiver_start..receiver_end]
					object: source[object_begin..object_end]
					source: source[bang..end_pos]
					begin_pos: bang
					end_pos: end_pos
					receiver_begin: receiver_start
					receiver_end: receiver_end
					object_begin: object_begin
					object_end: object_end
				}
			}
			else {}
		}
		position++
	}
	return none
}

pub fn negate_include_call(source string) ?NegateIncludeCall {
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = negate_include_quoted_end(source, position)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if character == `!` {
			if call := negate_include_match_at(source, position) {
				return call
			}
		}
		position++
	}
	return none
}

pub fn analyze_negate_includes(source string) NegateIncludeAnalysis {
	mut offenses := []NegateIncludeOffense{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `\"`] {
			position = negate_include_quoted_end(source, position)
			continue
		}
		if character == `#` {
			for position < source.len && source[position] != `\n` {
				position++
			}
			continue
		}
		if character == `!` {
			if call := negate_include_match_at(source, position) {
				replacement := '${call.receiver}.exclude?(${call.object})'
				offenses << NegateIncludeOffense{
					call: call
					message: negate_include_message
					begin_pos: call.begin_pos
					end_pos: call.end_pos
					replacement: replacement
				}
				position = call.end_pos
				continue
			}
		}
		position++
	}
	mut corrected := source
	for index in 0 .. offenses.len {
		offense := offenses[offenses.len - 1 - index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return NegateIncludeAnalysis{
		offenses: offenses
		corrected: corrected
	}
}

fn negate_include_call_value(call NegateIncludeCall) ruby.Value {
	return ruby.structured_value('RuboCop::AST::NodeMatch', call.source, {
		'receiver':       call.receiver
		'object':         call.object
		'begin_pos':      call.begin_pos.str()
		'end_pos':        call.end_pos.str()
		'receiver_begin': call.receiver_begin.str()
		'receiver_end':   call.receiver_end.str()
		'object_begin':   call.object_begin.str()
		'object_end':     call.object_end.str()
	})
}

fn negate_include_offense_value(offense NegateIncludeOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'receiver':    offense.call.receiver
		'object':      offense.call.object
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby def_node_matcher `def_node_matcher :negate_include_call?, <<~PATTERN` at line 31.
pub fn ruby_negate_include_l31_d1_negate_include_call(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	call := negate_include_call(source) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return negate_include_call_value(call)
}

// Ruby method `on_send(node)` at line 36.
pub fn ruby_negate_include_l36_d2_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	analysis := analyze_negate_includes(source)
	if analysis.offenses.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return negate_include_offense_value(analysis.offenses[0])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `collection.exclude?(obj)`
// 8:       # over `!collection.include?(obj)`.
// 9:       #
// 10:       # NOTE: This cop is unsafe because false positives will occur for
// 11:       #       receiver objects that do not have an `#exclude?` method (e.g. `IPAddr`).
// 12:       #
// 13:       # ### Example
// 14:       #
// 15:       # ```ruby
// 16:       # # bad
// 17:       # !array.include?(2)
// 18:       # !hash.include?(:key)
// 19:       #
// 20:       # # good
// 21:       # array.exclude?(2)
// 22:       # hash.exclude?(:key)
// 23:       # ```
// 24:       class NegateInclude < Base
// 25:         extend AutoCorrector
// 26:
// 27:         MSG = "Use `.exclude?` and remove the negation part."
// 28:
// 29:         RESTRICT_ON_SEND = [:!].freeze
// 30:
// 31:         def_node_matcher :negate_include_call?, <<~PATTERN
// 32:           (send (send $!nil? :include? $_) :!)
// 33:         PATTERN
// 34:
// 35:         sig { params(node: RuboCop::AST::SendNode).void }
// 36:         def on_send(node)
// 37:           return unless (receiver, obj = negate_include_call?(node))
// 38:
// 39:           add_offense(node) do |corrector|
// 40:             corrector.replace(node, "#{receiver.source}.exclude?(#{obj.source})")
// 41:           end
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
