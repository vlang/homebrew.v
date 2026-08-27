module hash

import brew_runtime

// Translated from Homebrew/brew `extend/hash/keys.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `assert_valid_keys(*valid_keys)` at line 21.
pub fn ruby_keys_l21_d1_assert_valid_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assert_valid_keys', ...args)
}

// Ruby method `deep_transform_keys(&block) = _deep_transform_keys_in_object(self, &block)` at line 43.
pub fn ruby_keys_l43_d2_deep_transform_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deep_transform_keys', ...args)
}

// Ruby method `deep_transform_keys!(&block) = _deep_transform_keys_in_object!(self, &block)` at line 48.
pub fn ruby_keys_l48_d3_deep_transform_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deep_transform_keys!', ...args)
}

// Ruby method `deep_stringify_keys = T.unsafe(self).deep_transform_keys(&:to_s)` at line 62.
pub fn ruby_keys_l62_d4_deep_stringify_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deep_stringify_keys', ...args)
}

// Ruby method `deep_symbolize_keys` at line 76.
pub fn ruby_keys_l76_d5_deep_symbolize_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deep_symbolize_keys', ...args)
}

// Ruby method `_deep_transform_keys_in_object(object, &block)` at line 88.
pub fn ruby_keys_l88_d6_deep_transform_keys_in_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_deep_transform_keys_in_object', ...args)
}

// Ruby method `_deep_transform_keys_in_object!(object, &block)` at line 102.
pub fn ruby_keys_l102_d7_deep_transform_keys_in_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_deep_transform_keys_in_object!', ...args)
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
