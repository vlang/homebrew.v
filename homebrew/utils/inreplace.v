module utils

import os

// Translated from Homebrew/brew `utils/inreplace.rb`.
pub struct InreplaceOptions {
pub:
	audit_result bool = true
	global       bool = true
}

pub struct InreplaceResult {
pub:
	paths []string
}

struct InreplaceMakeAssignment {
	start int
	end   int
	value string
}

pub struct InreplaceBuffer {
pub mut:
	inreplace_string string
	errors           []string
}

pub type InreplaceBlock = fn (mut InreplaceBuffer)

fn inreplace_inspect(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')}"'
}

fn inreplace_replacement_error(before string, after string) string {
	return 'expected replacement of ${inreplace_inspect(before)} with ${inreplace_inspect(after)}'
}

pub fn new_inreplace_buffer(contents string) InreplaceBuffer {
	return InreplaceBuffer{
		inreplace_string: contents
	}
}

pub fn (mut buffer InreplaceBuffer) sub(before string, after string, audit_result bool) bool {
	index := buffer.inreplace_string.index(before) or {
		if audit_result {
			buffer.errors << inreplace_replacement_error(before, after)
		}
		return false
	}
	buffer.inreplace_string = buffer.inreplace_string[..index] + after + buffer.inreplace_string[index + before.len..]
	return true
}

pub fn (mut buffer InreplaceBuffer) gsub(before string, after string,
	audit_result bool) bool {
	if !buffer.inreplace_string.contains(before) {
		if audit_result {
			buffer.errors << inreplace_replacement_error(before, after)
		}
		return false
	}
	buffer.inreplace_string = buffer.inreplace_string.replace(before, after)
	return true
}

fn inreplace_operator_tail(line string, flag string) ?int {
	if !line.starts_with(flag) {
		return none
	}
	mut index := flag.len
	for index < line.len && line[index] in [` `, `\t`] {
		index++
	}
	if index < line.len && line[index] in [`\\`, `?`, `+`, `:`, `!`] {
		index++
	}
	if index >= line.len || line[index] != `=` {
		return none
	}
	index++
	for index < line.len && line[index] in [` `, `\t`] {
		index++
	}
	return index
}

fn (buffer InreplaceBuffer) make_assignment(flag string) ?InreplaceMakeAssignment {
	mut start := 0
	for start <= buffer.inreplace_string.len {
		newline := buffer.inreplace_string.index_after('\n', start) or {
			buffer.inreplace_string.len
		}
		line := buffer.inreplace_string[start..newline]
		value_start_in_line := inreplace_operator_tail(line, flag) or {
			if newline >= buffer.inreplace_string.len {
				break
			}
			start = newline + 1
			continue
		}
		mut end := if newline < buffer.inreplace_string.len { newline + 1 } else { newline }
		mut current_line := line
		for current_line.ends_with('\\') && end < buffer.inreplace_string.len {
			next_newline := buffer.inreplace_string.index_after('\n', end) or {
				buffer.inreplace_string.len
			}
			current_line = buffer.inreplace_string[end..next_newline]
			end = if next_newline < buffer.inreplace_string.len {
				next_newline + 1
			} else {
				next_newline
			}
		}
		value_end := if end > start && buffer.inreplace_string[end - 1] == `\n` {
			end - 1
		} else {
			end
		}
		return InreplaceMakeAssignment{
			start: start
			end: end
			value: buffer.inreplace_string[start + value_start_in_line..value_end]
		}
	}
	return none
}

pub fn (mut buffer InreplaceBuffer) change_make_var(flag string, new_value string) bool {
	assignment := buffer.make_assignment(flag) or {
		buffer.errors << 'expected to change ${inreplace_inspect(flag)} to ${inreplace_inspect(new_value)}'
		return false
	}
	value := new_value.replace('\\1', assignment.value)
	newline := if assignment.end > assignment.start && buffer.inreplace_string[assignment.end - 1] == `\n` {
		'\n'
	} else {
		''
	}
	buffer.inreplace_string = buffer.inreplace_string[..assignment.start] + '${flag}=${value}${newline}' + buffer.inreplace_string[assignment.end..]
	return true
}

pub fn (mut buffer InreplaceBuffer) remove_make_var(flags []string) bool {
	mut success := true
	for flag in flags {
		assignment := buffer.make_assignment(flag) or {
			buffer.errors << 'expected to remove ${inreplace_inspect(flag)}'
			success = false
			continue
		}
		buffer.inreplace_string = buffer.inreplace_string[..assignment.start] + buffer.inreplace_string[assignment.end..]
	}
	return success
}

pub fn (buffer InreplaceBuffer) get_make_var(flag string) !string {
	assignment := buffer.make_assignment(flag) or {
		return error('expected to find make variable ${inreplace_inspect(flag)}')
	}
	return assignment.value
}

pub fn format_inreplace_error(errors map[string][]string) string {
	mut message := 'inreplace failed\n'
	for path, path_errors in errors {
		message += '${path}:\n'
		for path_error in path_errors {
			message += '  ${path_error}\n'
		}
	}
	return message
}

fn inreplace_atomic_write(path string, contents string) ! {
	directory := os.dir(path)
	base := os.file_name(path)
	temporary := os.join_path(directory, '.${base}.inreplace-${os.getpid()}')
	os.write_file(temporary, contents)!
	os.mv(temporary, path)!
}

pub fn inreplace(paths []string, before ?string, after ?string, options InreplaceOptions,
	block ?InreplaceBlock) !InreplaceResult {
	mut errors := map[string][]string{}
	if paths.len == 0 || paths.all(it.trim_space() == '') {
		errors['`paths` (first) parameter'] = ['`paths` was empty']
		return error(format_inreplace_error(errors))
	}
	for path in paths {
		contents := os.read_file(path)!
		mut buffer := new_inreplace_buffer(contents)
		if before == none && after == none {
			callback := block or {
				return error('Must supply a block or before/after params')
			}
			callback(mut buffer)
		} else {
			before_value := before or {
				return error('Must supply both before and after params')
			}
			after_value := after or {
				return error('Must supply both before and after params')
			}
			if options.global {
				buffer.gsub(before_value, after_value, options.audit_result)
			} else {
				buffer.sub(before_value, after_value, options.audit_result)
			}
		}
		if buffer.errors.len > 0 {
			errors[path] = buffer.errors.clone()
		}
		inreplace_atomic_write(path, buffer.inreplace_string)!
	}
	if errors.len > 0 {
		return error(format_inreplace_error(errors))
	}
	return InreplaceResult{
		paths: paths.clone()
	}
}
