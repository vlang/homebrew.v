module enumerable

import ruby
import homebrew.extend.blank

// Translated from Homebrew/brew `extend/enumerable/hash.rb`.

// compact_blank_values is the typed V form of Hash#compact_blank.
pub fn compact_blank_values(values map[string]ruby.Value) map[string]ruby.Value {
	mut compacted := map[string]ruby.Value{}
	for key, value in values {
		if !blank.value_is_blank(value) {
			compacted[key] = value
		}
	}
	return compacted
}
