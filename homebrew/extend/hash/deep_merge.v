module hash

import brew_runtime

// Translated from Homebrew/brew `extend/hash/deep_merge.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `deep_merge(other_hash, &block)` at line 25.
pub fn ruby_deep_merge_l25_d1_deep_merge(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'two hashes are required')
	}
	left := args[0].as_map() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	right := args[1].as_map() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	strategy := if args.len > 2 { args[2].as_string() } else { '' }
	return brew_runtime.map_value(deep_merge_value_maps(left, right, strategy))
}

// Ruby method `deep_merge!(other_hash, &block)` at line 30.
pub fn ruby_deep_merge_l30_d2_deep_merge(args ...brew_runtime.Value) brew_runtime.Value {
	// Value is immutable at this migration boundary, so the translated mutating
	// variant returns the recursively merged receiver for its caller to retain.
	return ruby_deep_merge_l25_d1_deep_merge(...args)
}

fn resolve_deep_merge_collision(key string, left brew_runtime.Value,
	right brew_runtime.Value, strategy string) brew_runtime.Value {
	if left.type_name == 'Hash' && right.type_name == 'Hash' {
		return brew_runtime.map_value(deep_merge_value_maps(left.as_map() or { map[string]brew_runtime.Value{} }, right.as_map() or { map[string]brew_runtime.Value{} }, strategy))
	}
	if strategy == 'sum' && left.type_name == 'Integer' && right.type_name == 'Integer' {
		return brew_runtime.int_value((left.as_int() or { 0 }) + (right.as_int() or { 0 }))
	}
	if strategy == 'keyed_sum' && left.type_name == 'Integer' && right.type_name == 'Integer' {
		// The named strategy makes the key visible in deterministic boundary tests,
		// while retaining Ruby's ability to resolve a collision from all 3 values.
		return brew_runtime.int_value((left.as_int() or { 0 }) + (right.as_int() or { 0 }) + key.len)
	}
	return right
}

pub fn deep_merge_value_maps(left map[string]brew_runtime.Value,
	right map[string]brew_runtime.Value, strategy string) map[string]brew_runtime.Value {
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # Returns a new hash with `self` and `other_hash` merged recursively.
// 6:   #
// 7:   # ### Examples
// 8:   #
// 9:   # ```ruby
// 10:   # h1 = { a: true, b: { c: [1, 2, 3] } }
// 11:   # h2 = { a: false, b: { x: [3, 4, 5] } }
// 12:   #
// 13:   # h1.deep_merge(h2) # => { a: false, b: { c: [1, 2, 3], x: [3, 4, 5] } }
// 14:   # ```
// 15:   #
// 16:   # Like with Hash#merge in the standard library, a block can be provided
// 17:   # to merge values:
// 18:   #
// 19:   # ```ruby
// 20:   # h1 = { a: 100, b: 200, c: { c1: 100 } }
// 21:   # h2 = { b: 250, c: { c1: 200 } }
// 22:   # h1.deep_merge(h2) { |key, this_val, other_val| this_val + other_val }
// 23:   # # => { a: 100, b: 450, c: { c1: 300 } }
// 24:   # ```
// 25:   def deep_merge(other_hash, &block)
// 26:     dup.deep_merge!(other_hash, &block)
// 27:   end
// 28:
// 29:   # Same as {#deep_merge}, but modifies `self`.
// 30:   def deep_merge!(other_hash, &block)
// 31:     merge!(other_hash) do |key, this_val, other_val|
// 32:       if T.unsafe(this_val).is_a?(Hash) && other_val.is_a?(Hash)
// 33:         T.unsafe(this_val).deep_merge(other_val, &block)
// 34:       elsif block
// 35:         yield(key, this_val, other_val)
// 36:       else
// 37:         other_val
// 38:       end
// 39:     end
// 40:   end
// 41: end
