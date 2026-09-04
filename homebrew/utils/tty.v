module utils

import ruby

// Translated from Homebrew/brew `utils/tty.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct TerminalSize {
pub:
	height int
	width  int
}

pub struct TtyState {
pub:
	stream_is_tty bool
	no_color      bool
	force_color   bool
pub mut:
	escape_sequence []int
}

pub fn current_tty_state() TtyState {
	return TtyState{
		stream_is_tty: ruby.stdout_is_terminal()
		no_color:      ruby.environment_value('HOMEBREW_NO_COLOR') != ''
		force_color:   ruby.environment_value('HOMEBREW_COLOR') != ''
	}
}

pub fn (state TtyState) with_stream(stream_is_tty bool) TtyState {
	return TtyState{
		stream_is_tty:   stream_is_tty
		no_color:        state.no_color
		force_color:     state.force_color
		escape_sequence: state.escape_sequence.clone()
	}
}

pub fn tty_strip_ansi(input string) string {
	mut output := []u8{cap: input.len}
	mut index := 0
	for index < input.len {
		if input[index] == 0x1b && index + 2 < input.len && input[index + 1] == `[` {
			mut cursor := index + 2
			mut has_digit := false
			for cursor < input.len && ((input[cursor] >= `0` && input[cursor] <= `9`)
				|| input[cursor] == `;`) {
				if input[cursor] != `;` {
					has_digit = true
				}
				cursor++
			}
			if has_digit && cursor < input.len && input[cursor] == `m` {
				index = cursor + 1
				continue
			}
		}
		output << input[index]
		index++
	}
	return output.bytestr()
}

pub fn tty_collapse_carriage_returns(input string) string {
	mut lines := []string{}
	for line in input.split('\n') {
		mut last := ''
		for segment in line.split('\r') {
			if segment != '' {
				last = segment
			}
		}
		lines << last
	}
	return lines.join('\n')
}

pub fn tty_move_cursor_up_beginning(line_count int) string {
	return '\x1b[${line_count}F'
}

pub fn tty_move_cursor_beginning() string {
	return '\x1b[0G'
}

pub fn tty_move_cursor_down(line_count int) string {
	return '\x1b[${line_count}B'
}

pub fn tty_clear_to_end() string {
	return '\x1b[K'
}

pub fn tty_hide_cursor() string {
	return '\x1b[?25l'
}

pub fn tty_show_cursor() string {
	return '\x1b[?25h'
}

pub fn tty_begin_synchronized_update() string {
	return '\x1b[?2026h'
}

pub fn tty_end_synchronized_update() string {
	return '\x1b[?2026l'
}

pub fn tty_size() ?TerminalSize {
	result := ruby.run_command('/bin/stty', ['size'])
	if result.exit_code != 0 {
		return none
	}
	parts := result.output.trim_space().split_any(' \t')
	if parts.len < 2 || parts[0].int() <= 0 || parts[1].int() <= 0 {
		return none
	}
	return TerminalSize{
		height: parts[0].int()
		width:  parts[1].int()
	}
}

pub fn tty_height() int {
	if size := tty_size() {
		return size.height
	}
	result := ruby.run_command('/usr/bin/tput', ['lines'])
	return if result.exit_code == 0 && result.output.trim_space().int() > 0 {
		result.output.trim_space().int()
	} else {
		40
	}
}

pub fn tty_width() int {
	if size := tty_size() {
		return size.width
	}
	result := ruby.run_command('/usr/bin/tput', ['cols'])
	return if result.exit_code == 0 && result.output.trim_space().int() > 0 {
		result.output.trim_space().int()
	} else {
		80
	}
}

pub fn tty_truncate(input string, width int) string {
	if width == 0 {
		return input
	}
	runes := input.runes()
	end := width - 4
	if end <= 0 {
		return ''
	}
	if runes.len <= end {
		return input
	}
	return runes[..end].string()
}

fn tty_code(name string) !int {
	return match name.trim_left(':') {
		'red' { 31 }
		'green' { 32 }
		'yellow' { 33 }
		'blue' { 34 }
		'magenta' { 35 }
		'cyan' { 36 }
		'default' { 39 }
		'reset' { 0 }
		'bold' { 1 }
		'italic' { 3 }
		'underline' { 4 }
		'strikethrough' { 9 }
		'no_underline' { 24 }
		else { return error('unknown TTY code: ${name}') }
	}
}

pub fn (state TtyState) color() bool {
	if state.no_color {
		return false
	}
	if state.force_color {
		return true
	}
	return state.stream_is_tty
}

pub fn (state TtyState) current_escape_sequence() string {
	if state.escape_sequence.len == 0 {
		return ''
	}
	return '\x1b[${state.escape_sequence.map(it.str()).join(';')}m'
}

pub fn (mut state TtyState) add_code(name string) ! {
	state.escape_sequence << tty_code(name)!
}

pub fn (mut state TtyState) reset_escape_sequence() {
	state.escape_sequence.clear()
}

pub fn (mut state TtyState) str() string {
	output := if state.color() { state.current_escape_sequence() } else { '' }
	state.reset_escape_sequence()
	return output
}

pub fn tty_escape(name string) string {
	mut state := current_tty_state()
	state.add_code(name) or { return '' }
	return state.str()
}

pub fn tty_special_code(name string, stream_is_tty bool) string {
	if !stream_is_tty {
		return ''
	}
	code := match name.trim_left(':') {
		'up' { '1A' }
		'down' { '1B' }
		'right' { '1C' }
		'left' { '1D' }
		'erase_line' { 'K' }
		'erase_char' { 'P' }
		else { return '' }
	}
	return '\x1b[${code}'
}

fn tty_state_value(state TtyState) ruby.Value {
	return ruby.structured_value('Tty', state.current_escape_sequence(), {
		'stream_is_tty':   state.stream_is_tty.str()
		'no_color':        state.no_color.str()
		'force_color':     state.force_color.str()
		'escape_sequence': state.escape_sequence.map(it.str()).join(',')
	})
}

fn tty_state_from_value(value ruby.Value) TtyState {
	if value.type_name != 'Tty' {
		return current_tty_state()
	}
	codes_text := value.attribute('escape_sequence') or { '' }
	mut codes := []int{}
	if codes_text != '' {
		codes = codes_text.split(',').map(it.int())
	}
	return TtyState{
		stream_is_tty:   (value.attribute('stream_is_tty') or { 'false' }) == 'true'
		no_color:        (value.attribute('no_color') or { 'false' }) == 'true'
		force_color:     (value.attribute('force_color') or { 'false' }) == 'true'
		escape_sequence: codes
	}
}

// Ruby method `with(stream, &_block)` at line 49.
pub fn ruby_tty_l49_d1_with(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.with requires a stream')
	}
	stream_is_tty := if args[0].type_name == 'Bool' { args[0].as_bool() or { false } } else { false }
	return tty_state_value(current_tty_state().with_stream(stream_is_tty))
}

// Ruby method `strip_ansi(string)` at line 59.
pub fn ruby_tty_l59_d2_strip_ansi(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.strip_ansi requires a string')
	}
	return ruby.string_value(tty_strip_ansi(args[0].as_string()))
}

// Ruby method `collapse_carriage_returns(string)` at line 65.
pub fn ruby_tty_l65_d3_collapse_carriage_returns(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.collapse_carriage_returns requires a string')
	}
	return ruby.string_value(tty_collapse_carriage_returns(args[0].as_string()))
}

// Ruby method `move_cursor_up_beginning(line_count)` at line 73.
pub fn ruby_tty_l73_d4_move_cursor_up_beginning(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.move_cursor_up_beginning requires a line count')
	}
	return ruby.string_value(tty_move_cursor_up_beginning(int(args[0].as_int() or {
		panic(err)
	})))
}

// Ruby method `move_cursor_beginning` at line 78.
pub fn ruby_tty_l78_d5_move_cursor_beginning(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_move_cursor_beginning())
}

// Ruby method `move_cursor_down(line_count)` at line 83.
pub fn ruby_tty_l83_d6_move_cursor_down(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.move_cursor_down requires a line count')
	}
	return ruby.string_value(tty_move_cursor_down(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `clear_to_end` at line 88.
pub fn ruby_tty_l88_d7_clear_to_end(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_clear_to_end())
}

// Ruby method `hide_cursor` at line 93.
pub fn ruby_tty_l93_d8_hide_cursor(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_hide_cursor())
}

// Ruby method `show_cursor` at line 98.
pub fn ruby_tty_l98_d9_show_cursor(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_show_cursor())
}

// Ruby method `begin_synchronized_update` at line 103.
pub fn ruby_tty_l103_d10_begin_synchronized_update(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_begin_synchronized_update())
}

// Ruby method `end_synchronized_update` at line 108.
pub fn ruby_tty_l108_d11_end_synchronized_update(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tty_end_synchronized_update())
}

// Ruby method `size` at line 113.
pub fn ruby_tty_l113_d12_size(args ...ruby.Value) ruby.Value {
	if size := tty_size() {
		return ruby.structured_value('Array', '[${size.height}, ${size.width}]', {
			'height': size.height.str()
			'width':  size.width.str()
		})
	}
	return ruby.object_value('NilClass', '')
}

// Ruby method `height` at line 123.
pub fn ruby_tty_l123_d13_height(args ...ruby.Value) ruby.Value {
	return ruby.int_value(tty_height())
}

// Ruby method `width` at line 129.
pub fn ruby_tty_l129_d14_width(args ...ruby.Value) ruby.Value {
	return ruby.int_value(tty_width())
}

// Ruby method `truncate(string)` at line 134.
pub fn ruby_tty_l134_d15_truncate(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty.truncate requires a string')
	}
	return ruby.string_value(tty_truncate(args[0].as_string(), tty_width()))
}

// Ruby method `current_escape_sequence` at line 139.
pub fn ruby_tty_l139_d16_current_escape_sequence(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { tty_state_from_value(args[0]) } else { current_tty_state() }
	return ruby.string_value(state.current_escape_sequence())
}

// Ruby method `reset_escape_sequence!` at line 146.
pub fn ruby_tty_l146_d17_reset_escape_sequence(args ...ruby.Value) ruby.Value {
	mut state := if args.len > 0 { tty_state_from_value(args[0]) } else { current_tty_state() }
	state.reset_escape_sequence()
	return tty_state_value(state)
}

// Ruby define_method `define_method(name) do` at line 151.
pub fn ruby_tty_l151_d18_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty color method requires a name')
	}
	mut state := if args.len > 1 { tty_state_from_value(args[1]) } else { current_tty_state() }
	state.add_code(args[0].as_string()) or { panic(err) }
	return tty_state_value(state)
}

// Ruby define_method `define_method(name) do` at line 159.
pub fn ruby_tty_l159_d19_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tty special method requires a name')
	}
	stream_is_tty := if args.len > 1 && args[1].type_name == 'Bool' {
		args[1].as_bool() or { false }
	} else {
		ruby.stdout_is_terminal()
	}
	return ruby.string_value(tty_special_code(args[0].as_string(), stream_is_tty))
}

// Ruby method `to_s` at line 170.
pub fn ruby_tty_l170_d20_to_s(args ...ruby.Value) ruby.Value {
	mut state := if args.len > 0 { tty_state_from_value(args[0]) } else { current_tty_state() }
	return ruby.string_value(state.str())
}

// Ruby method `color?` at line 179.
pub fn ruby_tty_l179_d21_color(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { tty_state_from_value(args[0]) } else { current_tty_state() }
	return ruby.bool_value(state.color())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Various helper functions for interacting with TTYs.
// 5: module Tty
// 6:   @stream = T.let($stdout, T.nilable(T.any(IO, StringIO)))
// 7:
// 8:   COLOR_CODES = T.let(
// 9:     {
// 10:       red:     31,
// 11:       green:   32,
// 12:       yellow:  33,
// 13:       blue:    34,
// 14:       magenta: 35,
// 15:       cyan:    36,
// 16:       default: 39,
// 17:     }.freeze,
// 18:     T::Hash[Symbol, Integer],
// 19:   )
// 20:
// 21:   STYLE_CODES = T.let(
// 22:     {
// 23:       reset:         0,
// 24:       bold:          1,
// 25:       italic:        3,
// 26:       underline:     4,
// 27:       strikethrough: 9,
// 28:       no_underline:  24,
// 29:     }.freeze,
// 30:     T::Hash[Symbol, Integer],
// 31:   )
// 32:
// 33:   SPECIAL_CODES = T.let(
// 34:     {
// 35:       up:         "1A",
// 36:       down:       "1B",
// 37:       right:      "1C",
// 38:       left:       "1D",
// 39:       erase_line: "K",
// 40:       erase_char: "P",
// 41:     }.freeze,
// 42:     T::Hash[Symbol, String],
// 43:   )
// 44:
// 45:   CODES = T.let(COLOR_CODES.merge(STYLE_CODES).freeze, T::Hash[Symbol, Integer])
// 46:
// 47:   class << self
// 48:     sig { params(stream: T.any(IO, StringIO), _block: T.proc.params(arg0: T.any(IO, StringIO)).void).void }
// 49:     def with(stream, &_block)
// 50:       previous_stream = @stream
// 51:       @stream = T.let(stream, T.nilable(T.any(IO, StringIO)))
// 52:
// 53:       yield stream
// 54:     ensure
// 55:       @stream = T.let(previous_stream, T.nilable(T.any(IO, StringIO)))
// 56:     end
// 57:
// 58:     sig { params(string: String).returns(String) }
// 59:     def strip_ansi(string)
// 60:       string.gsub(/\033\[\d+(;\d+)*m/, "")
// 61:     end
// 62:
// 63:     # Simulates a terminal rendering `\r` overwrites (e.g. curl's `--progress-bar`).
// 64:     sig { params(string: String).returns(String) }
// 65:     def collapse_carriage_returns(string)
// 66:       string.split("\n", -1).map do |line|
// 67:         # `\r` resets the cursor, it doesn't erase, so keep the last non-empty segment.
// 68:         line.split("\r", -1).reject(&:empty?).last || ""
// 69:       end.join("\n")
// 70:     end
// 71:
// 72:     sig { params(line_count: Integer).returns(String) }
// 73:     def move_cursor_up_beginning(line_count)
// 74:       "\033[#{line_count}F"
// 75:     end
// 76:
// 77:     sig { returns(String) }
// 78:     def move_cursor_beginning
// 79:       "\033[0G"
// 80:     end
// 81:
// 82:     sig { params(line_count: Integer).returns(String) }
// 83:     def move_cursor_down(line_count)
// 84:       "\033[#{line_count}B"
// 85:     end
// 86:
// 87:     sig { returns(String) }
// 88:     def clear_to_end
// 89:       "\033[K"
// 90:     end
// 91:
// 92:     sig { returns(String) }
// 93:     def hide_cursor
// 94:       "\033[?25l"
// 95:     end
// 96:
// 97:     sig { returns(String) }
// 98:     def show_cursor
// 99:       "\033[?25h"
// 100:     end
// 101:
// 102:     sig { returns(String) }
// 103:     def begin_synchronized_update
// 104:       "\033[?2026h"
// 105:     end
// 106:
// 107:     sig { returns(String) }
// 108:     def end_synchronized_update
// 109:       "\033[?2026l"
// 110:     end
// 111:
// 112:     sig { returns(T.nilable([Integer, Integer])) }
// 113:     def size
// 114:       return @size if defined?(@size)
// 115:
// 116:       height, width = `/bin/stty size 2>/dev/null`.presence&.split&.map(&:to_i)
// 117:       return if height.nil? || width.nil?
// 118:
// 119:       @size = T.let([height, width], T.nilable([Integer, Integer]))
// 120:     end
// 121:
// 122:     sig { returns(Integer) }
// 123:     def height
// 124:       @height ||= T.let(size&.first || `/usr/bin/tput lines 2>/dev/null`.presence&.to_i || 40, T.nilable(Integer))
// 125:     end
// 126:
// 127:     # Keep in sync with `columns` in Library/Homebrew/utils/tty.sh.
// 128:     sig { returns(Integer) }
// 129:     def width
// 130:       @width ||= T.let(size&.second || `/usr/bin/tput cols 2>/dev/null`.presence&.to_i || 80, T.nilable(Integer))
// 131:     end
// 132:
// 133:     sig { params(string: String).returns(String) }
// 134:     def truncate(string)
// 135:       (w = width).zero? ? string.to_s : (string.to_s[0, w - 4] || "")
// 136:     end
// 137:
// 138:     sig { returns(String) }
// 139:     def current_escape_sequence
// 140:       return "" if @escape_sequence.nil?
// 141:
// 142:       "\033[#{@escape_sequence.join(";")}m"
// 143:     end
// 144:
// 145:     sig { void }
// 146:     def reset_escape_sequence!
// 147:       @escape_sequence = T.let(nil, T.nilable(T::Array[Integer]))
// 148:     end
// 149:
// 150:     CODES.each do |name, code|
// 151:       define_method(name) do
// 152:         @escape_sequence ||= T.let([], T.nilable(T::Array[Integer]))
// 153:         @escape_sequence << code
// 154:         self
// 155:       end
// 156:     end
// 157:
// 158:     SPECIAL_CODES.each do |name, code|
// 159:       define_method(name) do
// 160:         @stream = T.let($stdout, T.nilable(T.any(IO, StringIO)))
// 161:         if @stream&.tty?
// 162:           "\033[#{code}"
// 163:         else
// 164:           ""
// 165:         end
// 166:       end
// 167:     end
// 168:
// 169:     sig { returns(String) }
// 170:     def to_s
// 171:       return "" unless color?
// 172:
// 173:       current_escape_sequence
// 174:     ensure
// 175:       reset_escape_sequence!
// 176:     end
// 177:
// 178:     sig { returns(T::Boolean) }
// 179:     def color?
// 180:       require "env_config"
// 181:
// 182:       return false if Homebrew::EnvConfig.no_color?
// 183:       return true if Homebrew::EnvConfig.color?
// 184:       return false if @stream.blank?
// 185:
// 186:       @stream.tty?
// 187:     end
// 188:   end
// 189: end
