module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/safe_navigation_with_blank.rb`.
// The original source is retained below until every stub has a typed V body.
pub const safe_navigation_with_blank_message = 'Avoid calling `blank?` with the safe navigation operator in conditionals.'

pub struct SafeNavigationBlankMatch {
pub:
	begin_pos int
	end_pos   int
	dot_pos   int
	condition string
	message   string
}

fn safe_navigation_blank_dot(condition string) ?int {
	mut dot := -1
	mut cursor := 0
	for cursor < condition.len {
		relative := condition[cursor..].index('&.blank?') or { break }
		dot = cursor + relative
		cursor = dot + '&.blank?'.len
	}
	if dot < 0 {
		return none
	}
	tail := condition[dot + '&.blank?'.len..].trim_space()
	if tail != '' && tail != '()' {
		return none
	}
	return dot
}

fn safe_navigation_conditional_part(line string) ?[]int {
	mut content_start := 0
	for content_start < line.len && (line[content_start] == ` ` || line[content_start] == `\t`) {
		content_start++
	}
	for keyword in ['if ', 'unless '] {
		if line[content_start..].starts_with(keyword) {
			return [content_start + keyword.len, line.len]
		}
	}
	mut quote := u8(0)
	mut escaped := false
	for cursor := content_start; cursor < line.len; cursor++ {
		character := line[cursor]
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
		if character == `'` || character == `"` {
			quote = character
			continue
		}
		for keyword in [' if ', ' unless '] {
			if line[cursor..].starts_with(keyword) {
				return [cursor + keyword.len, line.len]
			}
		}
	}
	return none
}

pub fn audit_safe_navigation_with_blank(source string) []SafeNavigationBlankMatch {
	mut matches := []SafeNavigationBlankMatch{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		conditional := safe_navigation_conditional_part(line) or {
			if newline < 0 {
				break
			}
			line_start = line_end + 1
			continue
		}
		condition := line[conditional[0]..conditional[1]].trim_space()
		condition_offset := line[conditional[0]..conditional[1]].index(condition) or { 0 }
		dot := safe_navigation_blank_dot(condition) or {
			if newline < 0 {
				break
			}
			line_start = line_end + 1
			continue
		}
		matches << SafeNavigationBlankMatch{
			begin_pos: line_start
			end_pos: line_end
			dot_pos: line_start + conditional[0] + condition_offset + dot
			condition: condition
			message: safe_navigation_with_blank_message
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return matches
}

pub fn correct_safe_navigation_with_blank(source string) string {
	matches := audit_safe_navigation_with_blank(source)
	mut corrected := source
	if matches.len == 0 {
		return corrected
	}
	for index := matches.len - 1; index >= 0; index-- {
		dot := matches[index].dot_pos
		corrected = corrected[..dot] + '.' + corrected[dot + 2..]
	}
	return corrected
}

fn safe_navigation_blank_value(matched SafeNavigationBlankMatch, type_name string) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, matched.condition, {
		'begin_pos': matched.begin_pos.str()
		'end_pos':   matched.end_pos.str()
		'dot_pos':   matched.dot_pos.str()
		'condition': matched.condition
		'message':   matched.message
	})
}

// Ruby def_node_matcher `def_node_matcher :safe_navigation_blank_in_conditional?, <<~PATTERN` at line 35.
pub fn ruby_safe_navigation_with_blank_l35_d1_safe_navigation_blank_in_conditional(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	input := if source.contains(' if ') || source.contains(' unless ') || source.trim_space().starts_with('if ') || source.trim_space().starts_with('unless ') {
		source
	} else {
		'if ${source}'
	}
	matches := audit_safe_navigation_with_blank(input)
	return if matches.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		safe_navigation_blank_value(matches[0], 'RuboCop::AST::NodeMatch')
	}
}

// Ruby method `on_if(node)` at line 40.
pub fn ruby_safe_navigation_with_blank_l40_d2_on_if(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	matches := audit_safe_navigation_with_blank(source)
	return if matches.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		safe_navigation_blank_value(matches[0], 'RuboCop::Cop::Offense')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks to make sure safe navigation isn't used with `blank?` in
// 8:       # a conditional.
// 9:       #
// 10:       # NOTE: While the safe navigation operator is generally a good idea, when
// 11:       #       checking `foo&.blank?` in a conditional, `foo` being `nil` will actually
// 12:       #       do the opposite of what the author intends:
// 13:       #
// 14:       #       ```ruby
// 15:       #       foo&.blank? #=> nil
// 16:       #       foo.blank? #=> true
// 17:       #       ```
// 18:       #
// 19:       # ### Example
// 20:       #
// 21:       # ```ruby
// 22:       # # bad
// 23:       # do_something if foo&.blank?
// 24:       # do_something unless foo&.blank?
// 25:       #
// 26:       # # good
// 27:       # do_something if foo.blank?
// 28:       # do_something unless foo.blank?
// 29:       # ```
// 30:       class SafeNavigationWithBlank < Base
// 31:         extend AutoCorrector
// 32:
// 33:         MSG = "Avoid calling `blank?` with the safe navigation operator in conditionals."
// 34:
// 35:         def_node_matcher :safe_navigation_blank_in_conditional?, <<~PATTERN
// 36:           (if $(csend ... :blank?) ...)
// 37:         PATTERN
// 38:
// 39:         sig { params(node: RuboCop::AST::IfNode).void }
// 40:         def on_if(node)
// 41:           return unless safe_navigation_blank_in_conditional?(node)
// 42:
// 43:           add_offense(node) do |corrector|
// 44:             corrector.replace(safe_navigation_blank_in_conditional?(node).location.dot, ".")
// 45:           end
// 46:         end
// 47:       end
// 48:     end
// 49:   end
// 50: end
