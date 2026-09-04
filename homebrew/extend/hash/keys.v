module hash

import ruby

// Translated from Homebrew/brew `extend/hash/keys.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn deep_transform_keys_in_object(object DeepValue, transform fn(DeepKey) DeepKey) DeepValue {
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
	transform fn(DeepKey) DeepKey) {
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

pub fn deep_transform_keys(object DeepValue, transform fn(DeepKey) DeepKey) DeepValue {
	return deep_transform_keys_in_object(object, transform)
}

pub fn deep_transform_keys_in_place(mut object DeepValue, transform fn(DeepKey) DeepKey) {
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

fn deep_transform_from_args(args []ruby.Value) fn(DeepKey) DeepKey {
	mode := if args.len > 1 { args[1].as_string() } else { 'identity' }
	return match mode {
		'string', 'stringify' { stringify_deep_key }
		'symbol', 'symbolize' { symbolize_deep_key }
		'upper', 'uppercase' { uppercase_deep_key }
		else { fn (key DeepKey) DeepKey {
			return key
		} }
	}
}

// Ruby method `assert_valid_keys(*valid_keys)` at line 21.
pub fn ruby_keys_l21_d1_assert_valid_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return ruby.object_value('ArgumentError', 'hash is required')
	}
	object := deep_value_from_runtime(args[0])
	mut valid := []DeepKey{}
	for value in args[1..] {
		if value.type_name == 'Array' {
			for nested in value.as_array() or { []ruby.Value{} } {
				valid << deep_key_from_runtime(nested)
			}
		} else {
			valid << deep_key_from_runtime(value)
		}
	}
	assert_valid_deep_keys(object.entries, valid) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `deep_transform_keys(&block) = _deep_transform_keys_in_object(self, &block)` at line 43.
pub fn ruby_keys_l43_d2_deep_transform_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'hash is required')
	}
	return deep_value_to_runtime(deep_transform_keys(deep_value_from_runtime(args[0]), deep_transform_from_args(args)))
}

// Ruby method `deep_transform_keys!(&block) = _deep_transform_keys_in_object!(self, &block)` at line 48.
pub fn ruby_keys_l48_d3_deep_transform_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'hash is required')
	}
	mut object := deep_value_from_runtime(args[0])
	deep_transform_keys_in_place(mut object, deep_transform_from_args(args))
	return deep_value_to_runtime(object)
}

// Ruby method `deep_stringify_keys = T.unsafe(self).deep_transform_keys(&:to_s)` at line 62.
pub fn ruby_keys_l62_d4_deep_stringify_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'hash is required')
	}
	return deep_value_to_runtime(deep_stringify_keys(deep_value_from_runtime(args[0])))
}

// Ruby method `deep_symbolize_keys` at line 76.
pub fn ruby_keys_l76_d5_deep_symbolize_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'hash is required')
	}
	return deep_value_to_runtime(deep_symbolize_keys(deep_value_from_runtime(args[0])))
}

// Ruby method `_deep_transform_keys_in_object(object, &block)` at line 88.
pub fn ruby_keys_l88_d6_deep_transform_keys_in_object(args ...ruby.Value) ruby.Value {
	return ruby_keys_l43_d2_deep_transform_keys(...args)
}

// Ruby method `_deep_transform_keys_in_object!(object, &block)` at line 102.
pub fn ruby_keys_l102_d7_deep_transform_keys_in_object(args ...ruby.Value) ruby.Value {
	return ruby_keys_l48_d3_deep_transform_keys(...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # Validates all keys in a hash match `*valid_keys`, raising
// 6:   # `ArgumentError` on a mismatch.
// 7:   #
// 8:   # Note that keys are treated differently than `HashWithIndifferentAccess`,
// 9:   # meaning that string and symbol keys will not match.
// 10:   #
// 11:   # ### Example#
// 12:   #
// 13:   # ```ruby
// 14:   # { name: 'Rob', years: '28' }.assert_valid_keys(:name, :age)
// 15:   # # => raises "ArgumentError: Unknown key: :years. Valid keys are: :name, :age"
// 16:   # { name: 'Rob', age: '28' }.assert_valid_keys('name', 'age')
// 17:   # # => raises "ArgumentError: Unknown key: :name. Valid keys are: 'name', 'age'"
// 18:   # { name: 'Rob', age: '28' }.assert_valid_keys(:name, :age)   # => passes, raises nothing
// 19:   # ```
// 20:   sig { params(valid_keys: T.untyped).void }
// 21:   def assert_valid_keys(*valid_keys)
// 22:     valid_keys.flatten!
// 23:     each_key do |k|
// 24:       next if valid_keys.include?(k)
// 25:
// 26:       raise ArgumentError,
// 27:             "Unknown key: #{T.unsafe(k).inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(", ")}"
// 28:     end
// 29:   end
// 30:
// 31:   # Returns a new hash with all keys converted by the block operation.
// 32:   # This includes the keys from the root hash and from all
// 33:   # nested hashes and arrays.
// 34:   #
// 35:   # ### Example
// 36:   #
// 37:   # ```ruby
// 38:   # hash = { person: { name: 'Rob', age: '28' } }
// 39:   #
// 40:   # hash.deep_transform_keys{ |key| key.to_s.upcase }
// 41:   # # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
// 42:   # ```
// 43:   def deep_transform_keys(&block) = _deep_transform_keys_in_object(self, &block)
// 44:
// 45:   # Destructively converts all keys by using the block operation.
// 46:   # This includes the keys from the root hash and from all
// 47:   # nested hashes and arrays.
// 48:   def deep_transform_keys!(&block) = _deep_transform_keys_in_object!(self, &block)
// 49:
// 50:   # Returns a new hash with all keys converted to strings.
// 51:   # This includes the keys from the root hash and from all
// 52:   # nested hashes and arrays.
// 53:   #
// 54:   # ### Example
// 55:   #
// 56:   # ```ruby
// 57:   # hash = { person: { name: 'Rob', age: '28' } }
// 58:   #
// 59:   # hash.deep_stringify_keys
// 60:   # # => {"person"=>{"name"=>"Rob", "age"=>"28"}}
// 61:   # ```
// 62:   def deep_stringify_keys = T.unsafe(self).deep_transform_keys(&:to_s)
// 63:
// 64:   # Returns a new hash with all keys converted to symbols, as long as
// 65:   # they respond to `to_sym`. This includes the keys from the root hash
// 66:   # and from all nested hashes and arrays.
// 67:   #
// 68:   # ### Example
// 69:   #
// 70:   # ```ruby
// 71:   # hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
// 72:   #
// 73:   # hash.deep_symbolize_keys
// 74:   # # => {:person=>{:name=>"Rob", :age=>"28"}}
// 75:   # ```
// 76:   def deep_symbolize_keys
// 77:     deep_transform_keys do |key|
// 78:       T.unsafe(key).to_sym
// 79:     rescue
// 80:       key
// 81:     end
// 82:   end
// 83:
// 84:   private
// 85:
// 86:   # Support methods for deep transforming nested hashes and arrays.
// 87:   sig { params(object: T.anything, block: T.proc.params(k: T.untyped).returns(T.untyped)).returns(T.untyped) }
// 88:   def _deep_transform_keys_in_object(object, &block)
// 89:     case object
// 90:     when Hash
// 91:       object.each_with_object({}) do |(key, value), result|
// 92:         result[yield(key)] = _deep_transform_keys_in_object(value, &block)
// 93:       end
// 94:     when Array
// 95:       object.map { |e| _deep_transform_keys_in_object(e, &block) }
// 96:     else
// 97:       object
// 98:     end
// 99:   end
// 100:
// 101:   sig { params(object: T.anything, block: T.proc.params(k: T.untyped).returns(T.untyped)).returns(T.untyped) }
// 102:   def _deep_transform_keys_in_object!(object, &block)
// 103:     case object
// 104:     when Hash
// 105:       # We can't use `each_key` here because we're updating the hash in-place.
// 106:       object.keys.each do |key|
// 107:         value = object.delete(key)
// 108:         object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
// 109:       end
// 110:       object
// 111:     when Array
// 112:       object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
// 113:     else
// 114:       object
// 115:     end
// 116:   end
// 117: end
