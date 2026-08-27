module utils

import brew_runtime

// Translated from Homebrew/brew `utils/tty.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `with(stream, &_block)` at line 49.
pub fn ruby_tty_l49_d1_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with', ...args)
}

// Ruby method `strip_ansi(string)` at line 59.
pub fn ruby_tty_l59_d2_strip_ansi(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip_ansi', ...args)
}

// Ruby method `collapse_carriage_returns(string)` at line 65.
pub fn ruby_tty_l65_d3_collapse_carriage_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collapse_carriage_returns', ...args)
}

// Ruby method `move_cursor_up_beginning(line_count)` at line 73.
pub fn ruby_tty_l73_d4_move_cursor_up_beginning(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_cursor_up_beginning', ...args)
}

// Ruby method `move_cursor_beginning` at line 78.
pub fn ruby_tty_l78_d5_move_cursor_beginning(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_cursor_beginning', ...args)
}

// Ruby method `move_cursor_down(line_count)` at line 83.
pub fn ruby_tty_l83_d6_move_cursor_down(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_cursor_down', ...args)
}

// Ruby method `clear_to_end` at line 88.
pub fn ruby_tty_l88_d7_clear_to_end(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_to_end', ...args)
}

// Ruby method `hide_cursor` at line 93.
pub fn ruby_tty_l93_d8_hide_cursor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hide_cursor', ...args)
}

// Ruby method `show_cursor` at line 98.
pub fn ruby_tty_l98_d9_show_cursor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('show_cursor', ...args)
}

// Ruby method `begin_synchronized_update` at line 103.
pub fn ruby_tty_l103_d10_begin_synchronized_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('begin_synchronized_update', ...args)
}

// Ruby method `end_synchronized_update` at line 108.
pub fn ruby_tty_l108_d11_end_synchronized_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('end_synchronized_update', ...args)
}

// Ruby method `size` at line 113.
pub fn ruby_tty_l113_d12_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('size', ...args)
}

// Ruby method `height` at line 123.
pub fn ruby_tty_l123_d13_height(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('height', ...args)
}

// Ruby method `width` at line 129.
pub fn ruby_tty_l129_d14_width(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('width', ...args)
}

// Ruby method `truncate(string)` at line 134.
pub fn ruby_tty_l134_d15_truncate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('truncate', ...args)
}

// Ruby method `current_escape_sequence` at line 139.
pub fn ruby_tty_l139_d16_current_escape_sequence(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_escape_sequence', ...args)
}

// Ruby method `reset_escape_sequence!` at line 146.
pub fn ruby_tty_l146_d17_reset_escape_sequence(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset_escape_sequence!', ...args)
}

// Ruby define_method `define_method(name) do` at line 151.
pub fn ruby_tty_l151_d18_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby define_method `define_method(name) do` at line 159.
pub fn ruby_tty_l159_d19_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `to_s` at line 170.
pub fn ruby_tty_l170_d20_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `color?` at line 179.
pub fn ruby_tty_l179_d21_color(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('color?', ...args)
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
