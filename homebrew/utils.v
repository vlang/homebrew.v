module homebrew

import ruby
import time

// Translated from Homebrew/brew `utils.rb`.
pub struct AuthorIdentity {
pub:
	name  string
	email string
}

pub type ParallelValueOperation = fn (ruby.Value) !ruby.Value

struct ParallelValueResult {
	index         int
	value         ruby.Value
	error_message string
}

pub fn deconstantize(path string) string {
	index := path.last_index('::') or { return '' }
	return path[..index]
}

pub fn demodulize(path ?string) !string {
	value := path or { return error('No constant path provided') }
	index := value.last_index('::') or { return value }
	return value[index + 2..]
}

pub fn name_from_full_name(full_name string) string {
	parts := full_name.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { full_name }
}

pub fn name_or_token(object ruby.Value) string {
	if object.type_name == 'Cask::Cask' {
		return object.attributes['token'] or { object.repr }
	}
	return object.attributes['name'] or { object.repr }
}

pub fn tap_from_full_name(full_name string) ?string {
	parts := full_name.split_nth('/', 3)
	if parts.len != 3 {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

pub fn is_full_name(full_name string) bool {
	return full_name.count('/') == 2
}

pub fn pluralize(stem string, count i64, plural_suffix string, singular_suffix string,
	include_count bool) string {
	mut root := stem
	mut plural := plural_suffix
	mut singular := singular_suffix
	if root == 'formula' {
		plural = 'e'
	} else if root in ['dependency', 'try'] {
		root = root.trim_string_right('y')
		plural = 'ies'
		singular = 'y'
	}
	prefix := if include_count { '${count} ' } else { '' }
	suffix := if count == 1 { singular } else { plural }
	return '${prefix}${root}${suffix}'
}

pub fn exponential_backoff_wait(attempt int, base int) !i64 {
	if attempt < 0 || base < 0 {
		return error('negative exponential backoff values are unsupported')
	}
	mut wait := i64(1)
	for _ in 0 .. attempt {
		if base > 0 && wait > i64(9223372036854775807) / i64(base) {
			return error('exponential backoff overflow')
		}
		wait *= i64(base)
	}
	return wait
}

pub fn exponential_backoff_sleep(attempt int, base int, before_sleep fn (i64)) ! {
	wait := exponential_backoff_wait(attempt, base)!
	before_sleep(wait)
	time.sleep(time.Duration(wait) * time.second)
}

pub fn parse_author(author string) !AuthorIdentity {
	open := author.last_index('<') or { return error('Unable to parse name and email.') }
	if !author.ends_with('>') {
		return error('Unable to parse name and email.')
	}
	name := author[..open].trim_right(' \t')
	email := author[open + 1..author.len - 1]
	if name.len == 0 || email.len == 0 || email.contains('>') {
		return error('Unable to parse name and email.')
	}
	return AuthorIdentity{
		name: name
		email: email
	}
}

pub fn underscore(camel_cased_word string) string {
	if !camel_cased_word.contains('::') && !camel_cased_word.contains('-') && !camel_cased_word.bytes().any(it >= `A` && it <= `Z`) {
		return camel_cased_word
	}
	word := camel_cased_word.replace('::', '/')
	mut output := []u8{cap: word.len + 8}
	bytes := word.bytes()
	for index, character in bytes {
		if character == `-` {
			output << `_`
			continue
		}
		is_upper := character >= `A` && character <= `Z`
		if is_upper && index > 0 {
			previous := bytes[index - 1]
			next_is_lower := index + 1 < bytes.len && bytes[index + 1] >= `a` && bytes[index + 1] <= `z`
			previous_is_lower_or_digit := (previous >= `a` && previous <= `z`) || (previous >= `0` && previous <= `9`)
			previous_is_upper := previous >= `A` && previous <= `Z`
			if previous != `/` && (previous_is_lower_or_digit || (previous_is_upper && next_is_lower)) {
				output << `_`
			}
		}
		output << if is_upper { character + 32 } else { character }
	}
	return output.bytestr()
}

pub fn safe_filename_part(basename string) string {
	return basename.bytes().filter(it >= 32 && it != 127 && it != `/`).bytestr()
}

pub fn is_safe_filename(basename string) bool {
	return safe_filename_part(basename) == basename
}

fn value_is_blank(value ruby.Value, compact_zero bool, compact_false bool) bool {
	if value.type_name == 'NilClass' {
		return true
	}
	if value.type_name == 'Bool' && !value.bool_data {
		return compact_false
	}
	if value.type_name == 'Integer' && value.int_data == 0 {
		return compact_zero
	}
	if value.type_name == 'Float' && value.float_data == 0.0 {
		return compact_zero
	}
	if value.type_name == 'String' {
		return value.repr.trim_space().len == 0
	}
	return (value.type_name == 'Array' && value.array_data.len == 0) || (value.type_name == 'Hash' && value.map_data.len == 0)
}
