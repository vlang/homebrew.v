module hash

import ruby

// Translated from Homebrew/brew `extend/hash/deep_transform_values.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `deep_transform_values(&block) = _deep_transform_values_in_object(self, &block)` at line 17.
pub fn ruby_deep_transform_values_l17_d1_deep_transform_values(object ruby.Value,
	transform fn (ruby.Value) ruby.Value) ruby.Value {
	return deep_transform_values(object, transform)
}

// Ruby method `_deep_transform_values_in_object(object, &block)` at line 23.
pub fn ruby_deep_transform_values_l23_d2_deep_transform_values_in_object(object ruby.Value,
	transform fn (ruby.Value) ruby.Value) ruby.Value {
	return deep_transform_values(object, transform)
}

// Ruby method `_deep_transform_values_in_object!(object, &block)` at line 35.
pub fn ruby_deep_transform_values_l35_d3_deep_transform_values_in_object(object ruby.Value,
	transform fn (ruby.Value) ruby.Value) ruby.Value {
	return deep_transform_values(object, transform)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # Returns a new hash with all values converted by the block operation.
// 6:   # This includes the values from the root hash and from all
// 7:   # nested hashes and arrays.
// 8:   #
// 9:   # ### Example
// 10:   #
// 11:   # ```ruby
// 12:   # hash = { person: { name: 'Rob', age: '28' } }
// 13:   #
// 14:   # hash.deep_transform_values{ |value| value.to_s.upcase }
// 15:   # # => {person: {name: "ROB", age: "28"}}
// 16:   # ```
// 17:   def deep_transform_values(&block) = _deep_transform_values_in_object(self, &block)
// 18:
// 19:   private
// 20:
// 21:   # Support methods for deep transforming nested hashes and arrays.
// 22:   sig { params(object: T.anything, block: T.proc.params(v: T.untyped).returns(T.untyped)).returns(T.untyped) }
// 23:   def _deep_transform_values_in_object(object, &block)
// 24:     case object
// 25:     when Hash
// 26:       object.transform_values { |value| _deep_transform_values_in_object(value, &block) }
// 27:     when Array
// 28:       object.map { |e| _deep_transform_values_in_object(e, &block) }
// 29:     else
// 30:       yield(object)
// 31:     end
// 32:   end
// 33:
// 34:   sig { params(object: T.anything, block: T.proc.params(v: T.untyped).returns(T.untyped)).returns(T.untyped) }
// 35:   def _deep_transform_values_in_object!(object, &block)
// 36:     case object
// 37:     when Hash
// 38:       object.transform_values! { |value| _deep_transform_values_in_object!(value, &block) }
// 39:     when Array
// 40:       object.map! { |e| _deep_transform_values_in_object!(e, &block) }
// 41:     else
// 42:       yield(object)
// 43:     end
// 44:   end
// 45: end
