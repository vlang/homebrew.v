module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/shell_commands.rb`.
const shell_command_builtins = ['!', '.', ':', 'break', 'case', 'continue', 'do', 'done', 'elif',
	'else', 'esac', 'eval', 'exec', 'exit', 'export', 'fi', 'for', 'if', 'in', 'readonly', 'return',
	'set', 'shift', 'then', 'times', 'trap', 'unset', 'until', 'while']
const shell_command_metacharacters = ['*', '?', '{', '}', '[', ']', '<', '>', '(', ')', '~', '&',
	'|', '\\', '\$', ';', "'", '`', '"', '\n', '#']

pub enum ShellCommandArgumentKind {
	string
	dynamic_string
	hash
	constant
	other
}

pub struct ShellCommandArgument {
pub:
	kind             ShellCommandArgumentKind
	source           string
	content          string
	stripped_content string
	begin_pos        int
	end_pos          int
}

pub struct ShellCommandSend {
pub:
	receiver    string
	method_name string
	arguments   []ShellCommandArgument
	begin_pos   int
	end_pos     int
}

pub struct ShellCommandOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct ShellCommandAnalysis {
pub:
	offenses  []ShellCommandOffense
	corrected string
}

pub struct ShellCommandDecision {
pub:
	offense ?ShellCommandOffense
}

fn shell_command_identifier_byte(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_` || character == `!` || character == `?`
}

fn shell_command_skip_space(source string, start int) int {
	mut index := start
	for index < source.len && source[index] in [` `, `\t`] {
		index++
	}
	return index
}

fn shell_command_matching_delimiter(source string, start int, open u8, close u8) int {
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for index := start; index < source.len; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		if character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return index
			}
		}
	}
	return -1
}

fn shell_command_string_end(source string, start int) int {
	quote := source[start]
	mut escaped := false
	for index := start + 1; index < source.len; index++ {
		if escaped {
			escaped = false
			continue
		}
		if source[index] == `\\` {
			escaped = true
			continue
		}
		if source[index] == quote {
			return index
		}
	}
	return source.len - 1
}

fn shell_command_comment_start(source string, start int, end int) int {
	mut quote := u8(0)
	mut escaped := false
	for index := start; index < end; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		if character == `#` && (index + 1 >= end || source[index + 1] != `{`) {
			return index
		}
	}
	return end
}

fn shell_command_split_arguments(source string, start int, end int) []ShellCommandArgument {
	mut ranges := [start]
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for index := start; index < end; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
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
					ranges << index
					ranges << index + 1
				}
			}
			else {}
		}
	}
	ranges << end
	mut arguments := []ShellCommandArgument{}
	for index := 0; index + 1 < ranges.len; index += 2 {
		mut begin_pos := ranges[index]
		mut end_pos := ranges[index + 1]
		for begin_pos < end_pos && source[begin_pos] in [` `, `\t`] {
			begin_pos++
		}
		for end_pos > begin_pos && source[end_pos - 1] in [` `, `\t`] {
			end_pos--
		}
		if begin_pos < end_pos {
			arguments << shell_command_argument(source[begin_pos..end_pos], begin_pos, end_pos)
		}
	}
	return arguments
}

fn shell_command_strip_dynamic(content string) string {
	mut stripped := ''
	mut index := 0
	for index < content.len {
		if index + 1 < content.len && content[index] == `#` && content[index + 1] == `{` {
			closing := shell_command_matching_delimiter(content, index + 1, `{`, `}`)
			if closing >= 0 {
				index = closing + 1
				continue
			}
		}
		stripped += content[index].ascii_str()
		index++
	}
	return stripped
}

fn shell_command_string_parts(raw string) ?([]string, []string, bool) {
	mut content_parts := []string{}
	mut stripped_parts := []string{}
	mut dynamic := false
	mut index := 0
	for index < raw.len {
		index = shell_command_skip_space(raw, index)
		if index >= raw.len || raw[index] !in [`'`, `"`] {
			return none
		}
		quote := raw[index]
		start := index + 1
		index++
		mut escaped := false
		for index < raw.len {
			if escaped {
				escaped = false
				index++
				continue
			}
			if raw[index] == `\\` {
				escaped = true
				index++
				continue
			}
			if raw[index] == quote {
				break
			}
			index++
		}
		if index >= raw.len {
			return none
		}
		part := raw[start..index]
		content_parts << part
		if quote == `"` && part.contains('#{') {
			dynamic = true
			stripped_parts << shell_command_strip_dynamic(part)
		} else {
			stripped_parts << part
		}
		index++
		index = shell_command_skip_space(raw, index)
		if index >= raw.len {
			break
		}
		if raw[index] != `+` {
			return none
		}
		index++
	}
	return content_parts, stripped_parts, dynamic
}

fn shell_command_argument(raw string, begin_pos int, end_pos int) ShellCommandArgument {
	if raw.starts_with('{') {
		return ShellCommandArgument{ kind: .hash, source: raw, begin_pos: begin_pos, end_pos: end_pos }
	}
	if raw.starts_with('"') || raw.starts_with("'") {
		content_parts, stripped_parts, dynamic := shell_command_string_parts(raw) or {
			return ShellCommandArgument{ kind: .other, source: raw, begin_pos: begin_pos, end_pos: end_pos }
		}
		return ShellCommandArgument{
			kind: if dynamic { .dynamic_string } else { .string }
			source: raw
			content: content_parts.join('')
			stripped_content: stripped_parts.join('')
			begin_pos: begin_pos
			end_pos: end_pos
		}
	}
	if raw != '' && raw.bytes().all(shell_command_identifier_byte(it)) {
		return ShellCommandArgument{
			kind: .constant
			source: raw
			content: raw
			stripped_content: raw
			begin_pos: begin_pos
			end_pos: end_pos
		}
	}
	return ShellCommandArgument{ kind: .other, source: raw, begin_pos: begin_pos, end_pos: end_pos }
}

pub fn parse_shell_command_sends(source string) []ShellCommandSend {
	mut sends := []ShellCommandSend{}
	mut index := 0
	for index < source.len {
		if source[index] in [`'`, `"`] {
			index = shell_command_string_end(source, index) + 1
			continue
		}
		if source[index] == `#` {
			line_end := source[index..].index('\n') or { -1 }
			index = if line_end < 0 { source.len } else { index + line_end + 1 }
			continue
		}
		if !((source[index] >= `a` && source[index] <= `z`) || (source[index] >= `A` && source[index] <= `Z`) || source[index] == `_`) {
			index++
			continue
		}
		start := index
		for index < source.len && shell_command_identifier_byte(source[index]) {
			index++
		}
		mut receiver := ''
		mut method_name := source[start..index]
		line_start := source[..start].last_index('\n') or { -1 }
		prefix := source[line_start + 1..start].trim_space()
		if prefix.ends_with('def') || prefix.ends_with('class') || prefix.ends_with('module') {
			continue
		}
		if index < source.len && source[index] == `.` {
			receiver = method_name
			index++
			method_start := index
			for index < source.len && shell_command_identifier_byte(source[index]) {
				index++
			}
			method_name = source[method_start..index]
		}
		if method_name !in ['system', 'safe_system', 'quiet_system', 'popen', 'popen_read',
			'safe_popen_read', 'popen_write', 'safe_popen_write', 'exec'] {
			continue
		}
		before_space := index
		mut arguments_start := shell_command_skip_space(source, index)
		mut arguments_end := arguments_start
		mut call_end := arguments_start
		if arguments_start < source.len && source[arguments_start] == `(` {
			closing := shell_command_matching_delimiter(source, arguments_start, `(`, `)`)
			if closing < 0 {
				continue
			}
			arguments_start++
			arguments_end = closing
			call_end = closing + 1
		} else {
			if arguments_start == before_space {
				continue
			}
			line_end_option := source[arguments_start..].index('\n') or { -1 }
			arguments_end = if line_end_option >= 0 {
				arguments_start + line_end_option
			} else {
				source.len
			}
			arguments_end = shell_command_comment_start(source, arguments_start, arguments_end)
			call_end = arguments_end
		}
		sends << ShellCommandSend{
			receiver: receiver
			method_name: method_name
			arguments: shell_command_split_arguments(source, arguments_start, arguments_end)
			begin_pos: start
			end_pos: call_end
		}
		index = call_end
	}
	return sends
}

pub fn shellwords_split(value string) ![]string {
	mut words := []string{}
	mut word := ''
	mut word_started := false
	mut quote := u8(0)
	mut escaped := false
	for character in value.bytes() {
		if escaped {
			word += character.ascii_str()
			word_started = true
			escaped = false
			continue
		}
		if character == `\\` && quote != `'` {
			escaped = true
			word_started = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			} else {
				word += character.ascii_str()
			}
			word_started = true
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			word_started = true
		} else if character in [` `, `\t`, `\n`, `\r`] {
			if word_started {
				words << word
				word = ''
				word_started = false
			}
		} else {
			word += character.ascii_str()
			word_started = true
		}
	}
	if escaped || quote != 0 {
		return error('Unmatched quote')
	}
	if word_started {
		words << word
	}
	return words
}

fn shell_command_target(node ShellCommandSend) bool {
	if node.method_name in ['system', 'safe_system', 'quiet_system'] {
		return node.receiver in ['', 'Kernel', 'Homebrew']
	}
	if node.method_name in ['popen_read', 'safe_popen_read', 'popen_write', 'safe_popen_write'] {
		return node.receiver == 'Utils'
	}
	return false
}

fn shell_command_has_metacharacter(value string) bool {
	return shell_command_metacharacters.any(value.contains(it))
}

pub fn shell_commands_on_send(node ShellCommandSend) !ShellCommandDecision {
	if !shell_command_target(node) {
		return ShellCommandDecision{}
	}
	mut argument_index := 0
	mut argument_count := node.arguments.len
	if argument_count > 0 && node.arguments[0].kind == .hash {
		argument_index = 1
		argument_count--
	}
	if argument_index >= node.arguments.len || argument_count >= 2 {
		return ShellCommandDecision{}
	}
	first_arg := node.arguments[argument_index]
	split_args := shellwords_split(first_arg.content)!
	if split_args.len <= 1 {
		return ShellCommandDecision{}
	}
	command := split_args[0]
	if command in shell_command_builtins || command.contains('=') || shell_command_has_metacharacter(first_arg.stripped_content) {
		return ShellCommandDecision{}
	}
	good_args := split_args.map('"${it}"').join(', ')
	method_string := if node.receiver == 'Utils' {
		'Utils.${node.method_name}'
	} else {
		node.method_name
	}
	return ShellCommandDecision{
		offense: ShellCommandOffense{
			begin_pos: first_arg.begin_pos
			end_pos: first_arg.end_pos
			message: 'Separate `${method_string}` commands into `${good_args}`'
			replacement: good_args
		}
	}
}

pub fn exec_shell_metacharacters_on_send(node ShellCommandSend) !ShellCommandDecision {
	if node.method_name != 'exec' || node.receiver !in ['', 'Kernel'] || node.arguments.len != 1 {
		return ShellCommandDecision{}
	}
	argument := node.arguments[0]
	split := shellwords_split(argument.content)!
	command := if split.len > 0 { split[0] } else { '' }
	if command !in shell_command_builtins && !command.contains('=') && !shell_command_has_metacharacter(argument.stripped_content) {
		return ShellCommandDecision{}
	}
	return ShellCommandDecision{
		offense: ShellCommandOffense{
			begin_pos: argument.begin_pos
			end_pos: argument.end_pos
			message: "Don't use shell metacharacters in `exec`. Implement the logic in Ruby instead, using methods like `\$stdout.reopen`."
		}
	}
}

fn shell_command_apply_corrections(source string, offenses []ShellCommandOffense) string {
	mut corrected := source
	mut sorted := offenses.clone()
	sorted.sort(a.begin_pos > b.begin_pos)
	for offense in sorted {
		if offense.replacement != '' {
			corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
		}
	}
	return corrected
}

pub fn analyze_shell_commands(source string) !ShellCommandAnalysis {
	mut offenses := []ShellCommandOffense{}
	for node in parse_shell_command_sends(source) {
		decision := shell_commands_on_send(node)!
		if offense := decision.offense {
			offenses << offense
		}
	}
	return ShellCommandAnalysis{
		offenses: offenses
		corrected: shell_command_apply_corrections(source, offenses)
	}
}

pub fn analyze_exec_shell_metacharacters(source string) !ShellCommandAnalysis {
	mut offenses := []ShellCommandOffense{}
	for node in parse_shell_command_sends(source) {
		decision := exec_shell_metacharacters_on_send(node)!
		if offense := decision.offense {
			offenses << offense
		}
	}
	return ShellCommandAnalysis{ offenses: offenses, corrected: source }
}

pub fn shell_command_analysis_value(analysis ShellCommandAnalysis) ruby.Value {
	offenses := analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
	}))
	return ruby.map_value({
		'offenses':  ruby.array_value(offenses)
		'corrected': ruby.string_value(analysis.corrected)
	})
}
