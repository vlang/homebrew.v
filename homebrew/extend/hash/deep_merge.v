module hash

import ruby

// Translated from Homebrew/brew `extend/hash/deep_merge.rb`.

fn resolve_deep_merge_collision(key string, left ruby.Value,
	right ruby.Value, strategy string) ruby.Value {
	if left.type_name == 'Hash' && right.type_name == 'Hash' {
		return ruby.map_value(deep_merge_value_maps(left.as_map() or { map[string]ruby.Value{} }, right.as_map() or { map[string]ruby.Value{} }, strategy))
	}
	if strategy == 'sum' && left.type_name == 'Integer' && right.type_name == 'Integer' {
		return ruby.int_value((left.as_int() or { 0 }) + (right.as_int() or { 0 }))
	}
	if strategy == 'keyed_sum' && left.type_name == 'Integer' && right.type_name == 'Integer' {
		// The named strategy makes the key visible in deterministic boundary tests,
		// while retaining Ruby's ability to resolve a collision from all 3 values.
		return ruby.int_value((left.as_int() or { 0 }) + (right.as_int() or { 0 }) + key.len)
	}
	return right
}

pub fn deep_merge_value_maps(left map[string]ruby.Value,
	right map[string]ruby.Value, strategy string) map[string]ruby.Value {
	mut merged := left.clone()
	for key, other_value in right {
		if key in merged {
			merged[key] = resolve_deep_merge_collision(key, merged[key], other_value, strategy)
		} else {
			merged[key] = other_value
		}
	}
	return merged
}
