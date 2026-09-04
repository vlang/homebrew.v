module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/module.rb`.

// deep_dup_module preserves named modules and copies anonymous modules.
pub fn deep_dup_module(value ruby.Value, name string) ruby.Value {
	if name.len > 0 {
		return value
	}
	return ruby.Value{
		...value
		string_array_data: value.string_array_data.clone()
		array_data: value.array_data.clone()
		attributes: value.attributes.clone()
	}
}
