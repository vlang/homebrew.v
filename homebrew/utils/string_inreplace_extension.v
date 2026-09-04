module utils

import ruby
import regex

// Translated from Homebrew/brew `utils/string_inreplace_extension.rb`.

// StringInreplaceExtension is the concrete mutable counterpart of the Ruby
// String wrapper. The generic ruby_* functions only serialise this state when a
// translated caller still crosses a Value boundary.
pub struct StringInreplaceExtension {
pub mut:
	inreplace_string string
	errors           []string
}

pub struct StringInreplaceRegexResult {
pub:
	replaced bool
	value    string
}

pub fn new_string_inreplace_extension(contents string) StringInreplaceExtension {
	return StringInreplaceExtension{
		inreplace_string: contents
	}
}

pub fn (mut extension StringInreplaceExtension) sub(before string, after string,
	audit_result bool) ?string {
	index := extension.inreplace_string.index(before) or {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(before, after, false)
		}
		return none
	}
	extension.inreplace_string = extension.inreplace_string[..index] + after + extension.inreplace_string[index + before.len..]
	return extension.inreplace_string
}

pub fn (mut extension StringInreplaceExtension) gsub(before string, after string,
	audit_result bool) ?string {
	if !extension.inreplace_string.contains(before) {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(before, after, false)
		}
		return none
	}
	extension.inreplace_string = extension.inreplace_string.replace(before, after)
	return extension.inreplace_string
}

pub fn (mut extension StringInreplaceExtension) sub_regex(pattern string, after string,
	audit_result bool) !StringInreplaceRegexResult {
	mut expression := regex.regex_opt(pattern)!
	start, end := expression.find(extension.inreplace_string)
	if start < 0 || end < start {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(pattern, after, true)
		}
		return StringInreplaceRegexResult{}
	}
	replacement := string_inreplace_regex_replacement(expression, extension.inreplace_string, after)
	extension.inreplace_string = extension.inreplace_string[..start] + replacement + extension.inreplace_string[end..]
	return StringInreplaceRegexResult{
		replaced: true
		value: extension.inreplace_string
	}
}

pub fn (mut extension StringInreplaceExtension) gsub_regex(pattern string, after string,
	audit_result bool) !StringInreplaceRegexResult {
	mut expression := regex.regex_opt(pattern)!
	start, _ := expression.find(extension.inreplace_string)
	if start < 0 {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(pattern, after, true)
		}
		return StringInreplaceRegexResult{}
	}
	mut v_replacement := after
	for capture in 1 .. 10 {
		v_replacement = v_replacement.replace('\\${capture}', '\\${capture - 1}')
	}
	extension.inreplace_string = expression.replace(extension.inreplace_string, v_replacement)
	return StringInreplaceRegexResult{
		replaced: true
		value: extension.inreplace_string
	}
}

pub fn (mut extension StringInreplaceExtension) change_make_var(flag string,
	new_value string) bool {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	buffer.errors = extension.errors.clone()
	result := buffer.change_make_var(flag, new_value)
	extension.inreplace_string = buffer.inreplace_string
	extension.errors = buffer.errors.clone()
	return result
}

pub fn (mut extension StringInreplaceExtension) remove_make_var(flags []string) bool {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	buffer.errors = extension.errors.clone()
	result := buffer.remove_make_var(flags)
	extension.inreplace_string = buffer.inreplace_string
	extension.errors = buffer.errors.clone()
	return result
}

pub fn (extension StringInreplaceExtension) get_make_var(flag string) !string {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	return buffer.get_make_var(flag)
}

fn string_inreplace_inspect(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')}"'
}

fn string_inreplace_replacement_error(before string, after string, regexp bool) string {
	before_inspect := if regexp { '/${before}/' } else { string_inreplace_inspect(before) }
	return 'expected replacement of ${before_inspect} with ${string_inreplace_inspect(after)}'
}

fn string_inreplace_regex_replacement(expression regex.RE, contents string,
	replacement string) string {
	mut result := replacement
	for capture in 1 .. 10 {
		result = result.replace('\\${capture}', expression.get_group_by_id(contents, capture - 1))
	}
	return result
}

fn string_inreplace_extension_value(extension StringInreplaceExtension) ruby.Value {
	return ruby.Value{
		type_name: 'StringInreplaceExtension'
		repr: extension.inreplace_string
		map_data: {
			'inreplace_string': ruby.string_value(extension.inreplace_string)
			'errors':           ruby.string_array_value(extension.errors)
		}
	}
}

fn string_inreplace_mutation_value(extension StringInreplaceExtension,
	result ?string) ruby.Value {
	mut value := string_inreplace_extension_value(extension)
	mut values := value.map_data.clone()
	values['result'] = if replacement := result {
		ruby.string_value(replacement)
	} else {
		ruby.object_value('NilClass', '')
	}
	return ruby.Value{
		...value
		map_data: values
	}
}

fn string_inreplace_extension_from_value(value ruby.Value) StringInreplaceExtension {
	contents := if nested := value.map_data['inreplace_string'] {
		nested.as_string()
	} else {
		value.as_string()
	}
	errors := if nested := value.map_data['errors'] {
		string_inreplace_value_strings(nested)
	} else {
		[]string{}
	}
	return StringInreplaceExtension{
		inreplace_string: contents
		errors: errors
	}
}

fn string_inreplace_value_strings(value ruby.Value) []string {
	if value.type_name == 'String' {
		return [value.as_string()]
	}
	if strings := value.as_string_array() {
		if strings.len > 0 {
			return strings
		}
	}
	if values := value.as_array() {
		return values.map(it.as_string())
	}
	return []string{}
}
