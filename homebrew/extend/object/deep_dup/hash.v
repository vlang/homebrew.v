module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/hash.rb`.

// deep_dup_values translates Hash#deep_dup for typed string-keyed maps. V map
// keys are values, so only the recursively copied values need replacement.
pub fn deep_dup_hash_values(values map[string]ruby.Value) map[string]ruby.Value {
	mut duplicated := map[string]ruby.Value{}
	for key, value in values {
		duplicated[key] = deep_dup_value(value)
	}
	return duplicated
}
