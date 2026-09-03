module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/shell_commands.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `on_send(node)` at line 73.
pub fn ruby_shell_commands_l73_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'source is required')
	}
	analysis := analyze_shell_commands(args[0].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return shell_command_analysis_value(analysis)
}

// Ruby method `on_send(node)` at line 127.
pub fn ruby_shell_commands_l127_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'source is required')
	}
	analysis := analyze_exec_shell_metacharacters(args[0].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return shell_command_analysis_value(analysis)
}

pub fn shell_command_analysis_value(analysis ShellCommandAnalysis) brew_runtime.Value {
	offenses := analysis.offenses.map(brew_runtime.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
	}))
	return brew_runtime.map_value({
		'offenses':  brew_runtime.array_value(offenses)
		'corrected': brew_runtime.string_value(analysis.corrected)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/array"
// 5: require "rubocops/shared/helper_functions"
// 6: require "shellwords"
// 7:
// 8: module RuboCop
// 9:   module Cop
// 10:     module Homebrew
// 11:       # https://github.com/ruby/ruby/blob/v2_6_3/process.c#L2430-L2460
// 12:       SHELL_BUILTINS = %w[
// 13:         !
// 14:         .
// 15:         :
// 16:         break
// 17:         case
// 18:         continue
// 19:         do
// 20:         done
// 21:         elif
// 22:         else
// 23:         esac
// 24:         eval
// 25:         exec
// 26:         exit
// 27:         export
// 28:         fi
// 29:         for
// 30:         if
// 31:         in
// 32:         readonly
// 33:         return
// 34:         set
// 35:         shift
// 36:         then
// 37:         times
// 38:         trap
// 39:         unset
// 40:         until
// 41:         while
// 42:       ].freeze
// 43:       private_constant :SHELL_BUILTINS
// 44:
// 45:       # https://github.com/ruby/ruby/blob/v2_6_3/process.c#L2495
// 46:       SHELL_METACHARACTERS = %W[* ? { } [ ] < > ( ) ~ & | \\ $ ; ' ` " \n #].freeze
// 47:       private_constant :SHELL_METACHARACTERS
// 48:
// 49:       # This cop makes sure that shell command arguments are separated.
// 50:       class ShellCommands < Base
// 51:         include HelperFunctions
// 52:         extend AutoCorrector
// 53:
// 54:         MSG = "Separate `%<method>s` commands into `%<good_args>s`"
// 55:
// 56:         TARGET_METHODS = [
// 57:           [nil, :system],
// 58:           [nil, :safe_system],
// 59:           [nil, :quiet_system],
// 60:           [:Utils, :popen_read],
// 61:           [:Utils, :safe_popen_read],
// 62:           [:Utils, :popen_write],
// 63:           [:Utils, :safe_popen_write],
// 64:         ].freeze
// 65:         private_constant :TARGET_METHODS
// 66:
// 67:         RESTRICT_ON_SEND = T.let(
// 68:           TARGET_METHODS.map(&:second).uniq.freeze,
// 69:           T::Array[T.nilable(Symbol)],
// 70:         )
// 71:
// 72:         sig { params(node: RuboCop::AST::SendNode).void }
// 73:         def on_send(node)
// 74:           TARGET_METHODS.each do |target_class, target_method|
// 75:             next if node.method_name != target_method
// 76:
// 77:             target_receivers = if target_class.nil?
// 78:               [nil, s(:const, nil, :Kernel), s(:const, nil, :Homebrew)]
// 79:             else
// 80:               [s(:const, nil, target_class)]
// 81:             end
// 82:             next unless target_receivers.include?(node.receiver)
// 83:
// 84:             first_arg = node.arguments.first
// 85:             arg_count = node.arguments.count
// 86:             if first_arg&.hash_type? # popen methods allow env hash
// 87:               first_arg = node.arguments.second
// 88:               arg_count -= 1
// 89:             end
// 90:             next if first_arg.nil? || arg_count >= 2
// 91:
// 92:             first_arg_str = string_content(first_arg)
// 93:             stripped_first_arg_str = string_content(first_arg, strip_dynamic: true)
// 94:
// 95:             split_args = first_arg_str.shellsplit
// 96:             next if split_args.count <= 1
// 97:
// 98:             # Only separate when no shell metacharacters are present
// 99:             command = split_args.first
// 100:             next if SHELL_BUILTINS.any?(command)
// 101:             next if command&.include?("=")
// 102:             next if SHELL_METACHARACTERS.any? { |meta| stripped_first_arg_str.include?(meta) }
// 103:
// 104:             good_args = split_args.map { |arg| "\"#{arg}\"" }.join(", ")
// 105:             method_string = if target_class
// 106:               "#{target_class}.#{target_method}"
// 107:             else
// 108:               target_method.to_s
// 109:             end
// 110:             add_offense(first_arg, message: format(MSG, method: method_string, good_args:)) do |corrector|
// 111:               corrector.replace(first_arg.source_range, good_args)
// 112:             end
// 113:           end
// 114:         end
// 115:       end
// 116:
// 117:       # This cop disallows shell metacharacters in `exec` calls.
// 118:       class ExecShellMetacharacters < Base
// 119:         include HelperFunctions
// 120:
// 121:         MSG = "Don't use shell metacharacters in `exec`. " \
// 122:               "Implement the logic in Ruby instead, using methods like `$stdout.reopen`."
// 123:
// 124:         RESTRICT_ON_SEND = [:exec].freeze
// 125:
// 126:         sig { params(node: RuboCop::AST::SendNode).void }
// 127:         def on_send(node)
// 128:           return if node.receiver.present? && node.receiver != s(:const, nil, :Kernel)
// 129:           return if node.arguments.count != 1
// 130:
// 131:           stripped_arg_str = string_content(node.arguments.first, strip_dynamic: true)
// 132:           command = string_content(node.arguments.first).shellsplit.first
// 133:
// 134:           return if SHELL_BUILTINS.none?(command) &&
// 135:                     !command&.include?("=") &&
// 136:                     SHELL_METACHARACTERS.none? { |meta| stripped_arg_str.include?(meta) }
// 137:
// 138:           add_offense(node.arguments.first, message: MSG)
// 139:         end
// 140:       end
// 141:     end
// 142:   end
// 143: end
