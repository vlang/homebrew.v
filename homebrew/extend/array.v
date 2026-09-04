module extend

import ruby

// Translated from Homebrew/brew `extend/array.rb`.

pub fn array_second[T](values []T) ?T {
	return if values.len > 1 { values[1] } else { none }
}

pub fn array_third[T](values []T) ?T {
	return if values.len > 2 { values[2] } else { none }
}

pub fn array_fourth[T](values []T) ?T {
	return if values.len > 3 { values[3] } else { none }
}

pub fn array_fifth[T](values []T) ?T {
	return if values.len > 4 { values[4] } else { none }
}

pub fn array_to_sentence(values []string, words_connector string, two_words_connector string, last_word_connector string) string {
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]}${two_words_connector}${values[1]}' }
		else {
			'${values[..values.len - 1].join(words_connector)}${last_word_connector}${values.last()}'
		}
	}
}

fn boundary_array_element(args []ruby.Value, index int, method string) ruby.Value {
	if args.len == 0 {
		panic('Array#${method} requires a receiver')
	}
	values := args[0].as_string_array() or { panic(err) }
	return if index < values.len {
		ruby.string_value(values[index])
	} else {
		ruby.object_value('NilClass', '')
	}
}
