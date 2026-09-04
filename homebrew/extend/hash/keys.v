module hash

import ruby

// Translated from Homebrew/brew `extend/hash/keys.rb`.
pub enum DeepKeyKind {
	string_key
	symbol_key
	integer_key
}

pub struct DeepKey {
pub:
	kind    DeepKeyKind
	text    string
	integer i64
}

pub fn string_deep_key(value string) DeepKey {
	return DeepKey{
		kind: .string_key
		text: value
	}
}

pub fn symbol_deep_key(value string) DeepKey {
	return DeepKey{
		kind: .symbol_key
		text: value.trim_left(':')
	}
}

pub fn integer_deep_key(value i64) DeepKey {
	return DeepKey{
		kind: .integer_key
		integer: value
	}
}

pub fn (key DeepKey) inspect() string {
	return match key.kind {
		.string_key { "'${key.text}'" }
		.symbol_key { ':${key.text}' }
		.integer_key { key.integer.str() }
	}
}

pub enum DeepValueKind {
	null_value
	string_value
	integer_value
	hash_value
	array_value
}

pub struct DeepEntry {
pub:
	key   DeepKey
	value DeepValue
}

pub struct DeepValue {
pub:
	kind    DeepValueKind
	text    string
	integer i64
	entries []DeepEntry
	items   []DeepValue
}

pub fn deep_string(value string) DeepValue {
	return DeepValue{
		kind: .string_value
		text: value
	}
}

pub fn deep_integer(value i64) DeepValue {
	return DeepValue{
		kind: .integer_value
		integer: value
	}
}

pub fn deep_hash(entries []DeepEntry) DeepValue {
	return DeepValue{
		kind: .hash_value
		entries: entries.clone()
	}
}

pub fn deep_array(items []DeepValue) DeepValue {
	return DeepValue{
		kind: .array_value
		items: items.clone()
	}
}

pub fn assert_valid_deep_keys(entries []DeepEntry, valid_keys []DeepKey) ! {
	for entry in entries {
		if entry.key !in valid_keys {
			valid := valid_keys.map(it.inspect()).join(', ')
			return error('Unknown key: ${entry.key.inspect()}. Valid keys are: ${valid}')
		}
	}
}

pub fn deep_transform_keys_in_object(object DeepValue, transform fn (DeepKey) DeepKey) DeepValue {
	return match object.kind {
		.hash_value {
			deep_hash(object.entries.map(DeepEntry{
				key: transform(it.key)
				value: deep_transform_keys_in_object(it.value, transform)
			}))
		}
		.array_value {
			deep_array(object.items.map(deep_transform_keys_in_object(it, transform)))
		}
		else {
			object
		}
	}
}

pub fn deep_transform_keys_in_object_in_place(mut object DeepValue,
	transform fn (DeepKey) DeepKey) {
	match object.kind {
		.hash_value {
			mut entries := []DeepEntry{cap: object.entries.len}
			for entry in object.entries {
				mut value := entry.value
				deep_transform_keys_in_object_in_place(mut value, transform)
				entries << DeepEntry{
					key: transform(entry.key)
					value: value
				}
			}
			object = DeepValue{
				...object
				entries: entries
			}
		}
		.array_value {
			mut items := []DeepValue{cap: object.items.len}
			for item in object.items {
				mut transformed := item
				deep_transform_keys_in_object_in_place(mut transformed, transform)
				items << transformed
			}
			object = DeepValue{
				...object
				items: items
			}
		}
		else {}
	}
}

pub fn deep_transform_keys(object DeepValue, transform fn (DeepKey) DeepKey) DeepValue {
	return deep_transform_keys_in_object(object, transform)
}

pub fn deep_transform_keys_in_place(mut object DeepValue, transform fn (DeepKey) DeepKey) {
	deep_transform_keys_in_object_in_place(mut object, transform)
}

fn stringify_deep_key(key DeepKey) DeepKey {
	return string_deep_key(match key.kind {
		.integer_key { key.integer.str() }
		else { key.text }
	})
}

fn symbolize_deep_key(key DeepKey) DeepKey {
	if key.kind == .string_key {
		return symbol_deep_key(key.text)
	}
	return key
}

fn uppercase_deep_key(key DeepKey) DeepKey {
	return match key.kind {
		.string_key { string_deep_key(key.text.to_upper()) }
		.symbol_key { symbol_deep_key(key.text.to_upper()) }
		.integer_key { key }
	}
}

pub fn deep_stringify_keys(object DeepValue) DeepValue {
	return deep_transform_keys(object, stringify_deep_key)
}

pub fn deep_symbolize_keys(object DeepValue) DeepValue {
	return deep_transform_keys(object, symbolize_deep_key)
}

fn deep_key_from_runtime(value ruby.Value) DeepKey {
	return match value.type_name {
		'Symbol' { symbol_deep_key(value.as_string()) }
		'Integer' { integer_deep_key(value.int_data) }
		else { string_deep_key(value.as_string()) }
	}
}

fn deep_value_from_runtime(value ruby.Value) DeepValue {
	return match value.type_name {
		'Hash' {
			mut entries := []DeepEntry{}
			for key, child in value.map_data {
				entries << DeepEntry{
					key: string_deep_key(key)
					value: deep_value_from_runtime(child)
				}
			}
			deep_hash(entries)
		}
		'Array' {
			deep_array((value.as_array() or { []ruby.Value{} }).map(deep_value_from_runtime(it)))
		}
		'Integer' { deep_integer(value.int_data) }
		'NilClass' { DeepValue{} }
		else { deep_string(value.as_string()) }
	}
}

fn deep_key_runtime_name(key DeepKey) string {
	return match key.kind {
		.symbol_key { ':${key.text}' }
		.string_key { key.text }
		.integer_key { key.integer.str() }
	}
}

fn deep_value_repr(value DeepValue) string {
	return match value.kind {
		.null_value { 'nil' }
		.string_value { '"${value.text}"' }
		.integer_value { value.integer.str() }
		.array_value { '[${value.items.map(deep_value_repr(it)).join(', ')}]' }
		.hash_value {
			'{${value.entries.map('\${it.key.inspect()}=>\${deep_value_repr(it.value)}').join(', ')}}'
		}
	}
}

fn deep_value_to_runtime(value DeepValue) ruby.Value {
	return match value.kind {
		.null_value { ruby.object_value('NilClass', 'nil') }
		.string_value { ruby.string_value(value.text) }
		.integer_value { ruby.int_value(value.integer) }
		.array_value { ruby.array_value(value.items.map(deep_value_to_runtime(it))) }
		.hash_value {
			mut values := map[string]ruby.Value{}
			for entry in value.entries {
				values[deep_key_runtime_name(entry.key)] = deep_value_to_runtime(entry.value)
			}
			ruby.Value{
				type_name: 'Hash'
				repr: deep_value_repr(value)
				map_data: values
			}
		}
	}
}

fn deep_transform_from_args(args []ruby.Value) fn (DeepKey) DeepKey {
	mode := if args.len > 1 { args[1].as_string() } else { 'identity' }
	return match mode {
		'string', 'stringify' { stringify_deep_key }
		'symbol', 'symbolize' { symbolize_deep_key }
		'upper', 'uppercase' { uppercase_deep_key }
		else {
			fn (key DeepKey) DeepKey {
				return key
			}
		}
	}
}
