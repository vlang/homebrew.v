module hash

import ruby

// Translated from Homebrew/brew `extend/hash/deep_transform_values.rb`.

pub fn deep_transform_values(object ruby.Value,
	transform fn (ruby.Value) ruby.Value) ruby.Value {
	if object.type_name == 'Hash' {
		values := object.as_map() or { return transform(object) }
		mut transformed := map[string]ruby.Value{}
		for key, value in values {
			transformed[key] = deep_transform_values(value, transform)
		}
		return ruby.map_value(transformed)
	}
	if object.type_name == 'Array' {
		values := object.as_array() or { return transform(object) }
		return ruby.array_value(values.map(deep_transform_values(it, transform)))
	}
	return transform(object)
}
