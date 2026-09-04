module blank

import ruby

fn rune_is_blank(character rune) bool {
	return (character >= 0x09 && character <= 0x0d) || character == 0x20
		|| character == 0x85 || character == 0xa0 || character == 0x1680
		|| (character >= 0x2000 && character <= 0x200a) || character == 0x2028
		|| character == 0x2029 || character == 0x202f || character == 0x205f
		|| character == 0x3000
}

// value_is_blank translates the type-specific Object#blank? overrides.
pub fn value_is_blank(value ruby.Value) bool {
	return match value.type_name {
		'NilClass', 'FalseClass' {
			true
		}
		'TrueClass', 'Integer', 'Float', 'Time' {
			false
		}
		'Bool' {
			!(value.as_bool() or { false })
		}
		'String' {
			input := value.as_string()
			input == '' || input.runes().all(rune_is_blank(it))
		}
		'Symbol', 'Pathname' {
			value.as_string() == ''
		}
		'Array' {
			value.array_data.len == 0 && value.string_array_data.len == 0
		}
		'Hash' {
			value.map_data.len == 0 && value.attributes.len == 0
		}
		else {
			empty_result := value.attributes['empty_result'] or { return false }
			empty_result !in ['', 'false', 'nil']
		}
	}
}

pub fn value_is_present(value ruby.Value) bool {
	return !value_is_blank(value)
}

pub fn value_presence(value ruby.Value) ruby.Value {
	return if value_is_present(value) { value } else { ruby.object_value('NilClass', '') }
}
