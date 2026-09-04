module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/array.rb`.

// deep_dup_values translates Array#deep_dup using the shared recursive value
// copier used by Object#deep_dup.
pub fn deep_dup_array_values(values []ruby.Value) []ruby.Value {
	return values.map(deep_dup_value(it))
}
