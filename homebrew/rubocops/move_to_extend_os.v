module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/move_to_extend_os.rb`.
pub const move_to_extend_os_non_extend_message = 'Move `OS.linux?` and `OS.mac?` calls to `extend/os`.'

pub struct MoveToExtendOsCall {
pub:
	method    string
	begin_pos int
	end_pos   int
}

pub struct MoveToExtendOsOffense {
pub:
	method    string
	file_path string
	begin_pos int
	end_pos   int
	message   string
}

fn move_to_extend_os_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn move_to_extend_os_skip_quoted(source string, start int) int {
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

fn move_to_extend_os_paired_delimiter(delimiter u8) u8 {
	return match delimiter {
		`(` { `)` }
		`[` { `]` }
		`{` { `}` }
		`<` { `>` }
		else { delimiter }
	}
}

fn move_to_extend_os_skip_percent_literal(source string, start int) ?int {
	if start + 1 >= source.len || source[start] != `%` {
		return none
	}
	mut delimiter_pos := start + 1
	if source[delimiter_pos] in [`q`, `Q`, `r`, `w`, `W`, `x`, `i`, `I`, `s`] {
		delimiter_pos++
	}
	if delimiter_pos >= source.len || source[delimiter_pos].is_alnum() || source[delimiter_pos] == `_` || source[delimiter_pos].is_space() {
		return none
	}
	open := source[delimiter_pos]
	close := move_to_extend_os_paired_delimiter(open)
	paired := close != open
	mut depth := 1
	mut escaped := false
	mut position := delimiter_pos + 1
	for position < source.len {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if paired && character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return position + 1
			}
		}
		position++
	}
	return source.len
}

fn move_to_extend_os_previous_code_byte(source string, start int) ?u8 {
	if start == 0 {
		return none
	}
	mut position := start - 1
	for position >= 0 {
		if !source[position].is_space() {
			return source[position]
		}
		position--
	}
	return none
}

fn move_to_extend_os_regex_start(source string, start int) bool {
	mut line_position := start - 1
	for line_position >= 0 && source[line_position] != `\n` {
		if !source[line_position].is_space() {
			break
		}
		line_position--
	}
	if line_position < 0 || source[line_position] == `\n` {
		return true
	}
	previous := move_to_extend_os_previous_code_byte(source, start) or { return true }
	return previous in [`=`, `(`, `[`, `{`, `,`, `!`, `?`, `:`, `;`]
}

fn move_to_extend_os_skip_regex(source string, start int) int {
	mut escaped := false
	mut in_class := false
	mut position := start + 1
	for position < source.len {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == `[` {
			in_class = true
		} else if character == `]` {
			in_class = false
		} else if character == `/` && !in_class {
			position++
			for position < source.len && source[position].is_letter() {
				position++
			}
			return position
		} else if character == `\n` {
			return position
		}
		position++
	}
	return source.len
}

fn move_to_extend_os_skip_space_and_comments(source string, start int, end int) int {
	mut position := start
	for position < end {
		if source[position].is_space() {
			position++
			continue
		}
		if source[position] == `#` {
			newline := source.index_after('\n', position) or { return end }
			position = newline + 1
			continue
		}
		break
	}
	return position
}

fn move_to_extend_os_empty_parentheses_end(source string, open int) ?int {
	mut depth := 1
	mut position := open + 1
	for position < source.len {
		position = move_to_extend_os_skip_space_and_comments(source, position, source.len)
		if position >= source.len {
			return none
		}
		if source[position] == `)` {
			depth--
			if depth == 0 {
				return position + 1
			}
			position++
			continue
		}
		if source[position] == `(` {
			depth++
		}
		// Any non-comment token inside the outer parentheses is an argument.
		return none
	}
	return none
}

fn move_to_extend_os_command_has_argument(source string, method_end int) bool {
	mut position := method_end
	mut saw_horizontal_space := false
	for position < source.len && source[position] in [` `, `\t`, `\r`] {
		saw_horizontal_space = true
		position++
	}
	if !saw_horizontal_space || position >= source.len || source[position] in [`\n`, `#`] {
		return false
	}
	// Operators delimit the zero-argument send; another expression is a command argument.
	return source[position] !in [`&`, `|`, `=`, `)`, `]`, `}`, `.`, `?`, `:`, `;`, `,`, `<`, `>`]
}

fn move_to_extend_os_call_at(source string, start int) ?MoveToExtendOsCall {
	if start + 2 > source.len || source[start..start + 2] != 'OS' {
		return none
	}
	if start > 0 && move_to_extend_os_identifier_byte(source[start - 1]) {
		return none
	}
	if previous := move_to_extend_os_previous_code_byte(source, start) {
		if previous in [`.`, `:`] {
			return none
		}
	}
	if start + 2 < source.len && move_to_extend_os_identifier_byte(source[start + 2]) {
		return none
	}
	mut position := start + 2
	for position < source.len && source[position].is_space() {
		position++
	}
	if position >= source.len || source[position] != `.` {
		return none
	}
	position++
	for position < source.len && source[position].is_space() {
		position++
	}
	method_begin := position
	method := if source[method_begin..].starts_with('mac?') {
		'mac'
	} else if source[method_begin..].starts_with('linux?') {
		'linux'
	} else {
		return none
	}
	method_end := method_begin + method.len + 1
	if method_end < source.len && move_to_extend_os_identifier_byte(source[method_end]) {
		return none
	}
	mut end_pos := method_end
	mut after := method_end
	for after < source.len && source[after] in [` `, `\t`, `\r`] {
		after++
	}
	if after < source.len && source[after] == `(` {
		end_pos = move_to_extend_os_empty_parentheses_end(source, after) or { return none }
	} else if move_to_extend_os_command_has_argument(source, method_end) {
		return none
	}
	return MoveToExtendOsCall{
		method: method
		begin_pos: start
		end_pos: end_pos
	}
}

pub fn find_move_to_extend_os_calls(source string) []MoveToExtendOsCall {
	mut calls := []MoveToExtendOsCall{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character == `#` {
			newline := source.index_after('\n', position) or { break }
			position = newline + 1
			continue
		}
		if character in [`'`, `"`] {
			position = move_to_extend_os_skip_quoted(source, position)
			continue
		}
		if character == `%` {
			if after := move_to_extend_os_skip_percent_literal(source, position) {
				position = after
				continue
			}
		}
		if character == `/` && move_to_extend_os_regex_start(source, position) {
			position = move_to_extend_os_skip_regex(source, position)
			continue
		}
		if character == `O` {
			if call := move_to_extend_os_call_at(source, position) {
				calls << call
				position = call.end_pos
				continue
			}
		}
		position++
	}
	return calls
}

fn move_to_extend_os_homebrew_path(file_path string, relative string) bool {
	needle := 'Library/Homebrew/${relative}'
	mut offset := 0
	for offset <= file_path.len - needle.len {
		relative_position := file_path[offset..].index(needle) or { return false }
		position := offset + relative_position
		if position == 0 || file_path[position - 1] == `/` {
			return true
		}
		offset = position + needle.len
	}
	return false
}

pub fn move_to_extend_os_ignored_path(file_path string) bool {
	return move_to_extend_os_homebrew_path(file_path, 'requirements/') || move_to_extend_os_homebrew_path(file_path, 'test/') || (move_to_extend_os_homebrew_path(file_path, 'os.rb') && file_path.ends_with('Library/Homebrew/os.rb'))
}

pub fn move_to_extend_os_offense_message(extend_os string, os_method string) string {
	truth := if extend_os == os_method { 'true' } else { 'false' }
	return "Don't use `OS.${os_method}?` in `extend/os/${extend_os}`, it is always `${truth}`."
}

pub fn audit_move_to_extend_os(source string, file_path string) []MoveToExtendOsOffense {
	if move_to_extend_os_ignored_path(file_path) {
		return []MoveToExtendOsOffense{}
	}
	mut offenses := []MoveToExtendOsOffense{}
	for call in find_move_to_extend_os_calls(source) {
		message := if file_path.contains('extend/os/mac/') {
			move_to_extend_os_offense_message('mac', call.method)
		} else if file_path.contains('extend/os/linux/') {
			move_to_extend_os_offense_message('linux', call.method)
		} else if !file_path.contains('extend/os/') {
			move_to_extend_os_non_extend_message
		} else {
			continue
		}
		offenses << MoveToExtendOsOffense{
			method: call.method
			file_path: file_path
			begin_pos: call.begin_pos
			end_pos: call.end_pos
			message: message
		}
	}
	return offenses
}

fn move_to_extend_os_call_value(call MoveToExtendOsCall) ruby.Value {
	return ruby.structured_value('RuboCop::AST::NodeMatch', 'OS.${call.method}?', {
		'method':    call.method
		'begin_pos': call.begin_pos.str()
		'end_pos':   call.end_pos.str()
	})
}

fn move_to_extend_os_offense_value(offense MoveToExtendOsOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'method':    offense.method
		'file_path': offense.file_path
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
	})
}
