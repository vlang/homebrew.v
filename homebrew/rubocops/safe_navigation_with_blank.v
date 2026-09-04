module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/safe_navigation_with_blank.rb`.
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

fn safe_navigation_blank_value(matched SafeNavigationBlankMatch, type_name string) ruby.Value {
	return ruby.structured_value(type_name, matched.condition, {
		'begin_pos': matched.begin_pos.str()
		'end_pos':   matched.end_pos.str()
		'dot_pos':   matched.dot_pos.str()
		'condition': matched.condition
		'message':   matched.message
	})
}
