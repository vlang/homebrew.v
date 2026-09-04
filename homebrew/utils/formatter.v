module utils

import math

// Translated from Homebrew/brew `utils/formatter.rb`.
pub struct ReadableSizeUnit {
pub:
	size f64
	unit string
}

fn tty_code_for_state(state TtyState, name string) string {
	mut current := state
	current.escape_sequence = state.escape_sequence.clone()
	current.add_code(name) or { return '' }
	return current.str()
}

pub fn formatter_prefix(prefix ?string, input string, color ?string, state TtyState) string {
	if prefix_value := prefix {
		if color_value := color {
			return '${tty_code_for_state(state, color_value)}${prefix_value}${tty_code_for_state(state, 'reset')} ${input}'
		}
		return '${prefix_value} ${input}'
	}
	if color_value := color {
		return '${tty_code_for_state(state, color_value)}${input}${tty_code_for_state(state, 'reset')}'
	}
	return input
}

pub fn formatter_arrow(input string, color ?string, state TtyState) string {
	return formatter_prefix('==>', input, color, state)
}

pub fn formatter_headline(input string, color ?string, state TtyState) string {
	styled := '${tty_code_for_state(state, 'bold')}${input}${tty_code_for_state(state, 'reset')}'
	return formatter_arrow(styled, color, state)
}

pub fn formatter_identifier(input string, state TtyState) string {
	return '${tty_code_for_state(state, 'green')}${input}${tty_code_for_state(state, 'default')}'
}

pub fn formatter_bold(input string, state TtyState) string {
	return '${tty_code_for_state(state, 'bold')}${input}${tty_code_for_state(state, 'reset')}'
}

pub fn formatter_label(label ?string, input string, color string, state TtyState) string {
	prefix := if label_value := label { ?string('${label_value}:') } else { ?string(none) }
	return formatter_prefix(prefix, input, color, state)
}

pub fn formatter_success(input string, label ?string, state TtyState) string {
	return formatter_label(label, input, 'green', state)
}

pub fn formatter_warning(input string, label ?string, state TtyState) string {
	return formatter_label(label, input, 'yellow', state)
}

pub fn formatter_error(input string, label ?string, state TtyState) string {
	return formatter_label(label, input, 'red', state)
}

pub fn formatter_truncate(input string, maximum int, omission string) string {
	runes := input.runes()
	if runes.len <= maximum {
		return input
	}
	room := maximum - omission.runes().len
	if room <= 0 {
		return omission
	}
	return runes[..room].string() + omission
}

fn wrap_help_words(line string, width int) []string {
	if line.len <= width || width <= 0 {
		return [line]
	}
	indent_length := line.len - line.trim_left(' ').len
	indent := ' '.repeat(indent_length)
	words := line.trim_space().split_any(' \t')
	mut lines := []string{}
	mut current_words := []string{}
	for word in words {
		mut candidate_words := current_words.clone()
		candidate_words << word
		candidate := indent + candidate_words.join(' ')
		if candidate.len > width && current_words.len > 0 {
			if word.starts_with('-') && current_words.len > 1 {
				option_leader := current_words.pop()
				lines << indent + current_words.join(' ')
				current_words = [option_leader, word]
			} else {
				lines << indent + current_words.join(' ')
				current_words = [word]
			}
			continue
		}
		current_words << word
	}
	lines << indent + current_words.join(' ')
	return lines
}

fn formatter_collapse_help_linebreaks(input string) string {
	mut collapsed := ''
	for index, character in input {
		if character == `\n` && index > 0 && index + 1 < input.len && !input[index - 1].is_space() && !input[index + 1].is_space() {
			collapsed += ' '
		} else {
			collapsed += character.ascii_str()
		}
	}
	return collapsed
}

fn formatter_split_subcommand_description(line string) []string {
	separator := line.index(': ') or { return [line] }
	if separator == 0 {
		return [line]
	}
	preceding := line[separator - 1]
	if preceding !in [`\``, `>`, `)`, `]`] {
		return [line]
	}
	return [line[..separator + 1], '    ' + line[separator + 2..]]
}

fn formatter_option_line(line string, width int) ?[]string {
	trimmed := line.trim_left(' ')
	if !trimmed.starts_with('-') {
		return none
	}
	leading := line.len - trimmed.len
	mut separator := -1
	mut index := leading + 1
	for index + 1 < line.len {
		if line[index] == ` ` && line[index + 1] == ` ` {
			separator = index
			break
		}
		index++
	}
	if separator < 0 {
		return none
	}
	description_start := 35
	if line.len <= description_start {
		return [line]
	}
	prefix := line[..description_start]
	description := line[description_start..].trim_space()
	description_width := width - description_start
	if description_width <= 0 {
		return [line]
	}
	wrapped := wrap_help_words(description, description_width)
	mut output := []string{cap: wrapped.len}
	for wrapped_index, part in wrapped {
		output << if wrapped_index == 0 {
			prefix + part
		} else {
			' '.repeat(description_start) + part
		}
	}
	return output
}

// formatter_format_help_text translates the source's five ordered regular
// expression substitutions: paragraph joining, subcommand indentation,
// hanging option descriptions, hanging continuations and final word wrapping.
pub fn formatter_format_help_text(input string, width int) string {
	collapsed := formatter_collapse_help_linebreaks(input)
	mut output := []string{}
	for line in collapsed.split('\n') {
		for split_line in formatter_split_subcommand_description(line) {
			if option_lines := formatter_option_line(split_line, width) {
				output << option_lines
			} else {
				output << wrap_help_words(split_line, width)
			}
		}
	}
	return output.join('\n').trim_right('\n') + '\n'
}

pub fn formatter_url(input string, state TtyState) string {
	return '${tty_code_for_state(state, 'underline')}${input}${tty_code_for_state(state, 'no_underline')}'
}

pub fn formatter_columns(objects []string, console_width int, stream_is_tty bool, gap_size int, min_width int) string {
	fallback := objects.join('\n') + '\n'
	if objects.len == 0 || !stream_is_tty {
		return fallback
	}
	lengths := objects.map(tty_strip_ansi(it).runes().len)
	mut max_length := min_width
	for length in lengths {
		if length > max_length {
			max_length = length
		}
	}
	mut columns := (console_width + gap_size) / (max_length + gap_size)
	if columns < 2 {
		return fallback
	}
	rows := (objects.len + columns - 1) / columns
	if min_width == 0 {
		columns = (objects.len + rows - 1) / rows
	}
	column_width := ((console_width + gap_size) / columns) - gap_size
	gap := ' '.repeat(gap_size)
	mut output := ''
	for row in 0 .. rows {
		mut row_items := []string{}
		mut object_index := row
		for object_index < objects.len {
			mut item := objects[object_index]
			if object_index + rows < objects.len {
				padding := column_width - lengths[object_index]
				if padding > 0 {
					item += ' '.repeat(padding)
				}
			}
			row_items << item
			object_index += rows
		}
		output += row_items.join(gap) + '\n'
	}
	return output
}

pub fn formatter_disk_usage_readable_size_unit(size_in_bytes f64, precision ?int) ReadableSizeUnit {
	mut size := size_in_bytes
	mut unit := 'B'
	for next_unit in ['KB', 'MB', 'GB'] {
		comparison := if precision_value := precision {
			factor := math.pow(10.0, precision_value)
			math.round(math.abs(size) * factor) / factor
		} else {
			math.abs(size)
		}
		if comparison < 1000 {
			break
		}
		size /= 1000.0
		unit = next_unit
	}
	return ReadableSizeUnit{
		size: size
		unit: unit
	}
}

pub fn formatter_disk_usage_readable(size_in_bytes f64) string {
	readable := formatter_disk_usage_readable_size_unit(size_in_bytes, none)
	if int(readable.size * 10) % 10 == 0 {
		return '${int(readable.size)}${readable.unit}'
	}
	return '${readable.size:.1f}${readable.unit}'
}

pub fn formatter_number_readable(number i64) string {
	negative := number < 0
	digits := if negative { (-number).str() } else { number.str() }
	mut groups := []string{}
	mut end := digits.len
	for end > 3 {
		groups.prepend(digits[end - 3..end])
		end -= 3
	}
	groups.prepend(digits[..end])
	return if negative { '-' + groups.join(',') } else { groups.join(',') }
}

pub fn formatter_redact_secrets(input string, secrets []string) string {
	mut output := input
	for secret in secrets {
		output = output.replace(secret, '******')
	}
	return output
}
