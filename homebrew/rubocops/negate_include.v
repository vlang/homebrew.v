module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/negate_include.rb`.
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
