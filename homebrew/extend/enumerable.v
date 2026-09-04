module extend

import ruby
import homebrew.extend.blank

// Translated from Homebrew/brew `extend/enumerable.rb`.

pub fn enumerable_excludes[T](values []T, object T) bool {
	return object !in values
}

pub fn compact_blank_values(values []ruby.Value) []ruby.Value {
	return values.filter(blank.value_is_present(it))
}
