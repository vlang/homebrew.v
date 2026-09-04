module utils

import ruby

// Translated from Homebrew/brew `utils/tty.rb`.

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
		no_color: ruby.environment_value('HOMEBREW_NO_COLOR') != ''
		force_color: ruby.environment_value('HOMEBREW_COLOR') != ''
	}
}

pub fn (state TtyState) with_stream(stream_is_tty bool) TtyState {
	return TtyState{
		stream_is_tty: stream_is_tty
		no_color: state.no_color
		force_color: state.force_color
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
		width: parts[1].int()
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
		else {
			return error('unknown TTY code: ${name}')
		}
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
		else {
			return ''
		}
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
		stream_is_tty: (value.attribute('stream_is_tty') or { 'false' }) == 'true'
		no_color: (value.attribute('no_color') or { 'false' }) == 'true'
		force_color: (value.attribute('force_color') or { 'false' }) == 'true'
		escape_sequence: codes
	}
}
