module deep_dup

import ruby

// Translated from Homebrew/brew `extend/object/deep_dup/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `deep_dup` at line 14.
pub fn ruby_hash_l14_d1_deep_dup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('Hash', '{}', {})
	}
	attributes := args[0].attributes.clone()
	return ruby.structured_value('Hash', attributes.str(), attributes)
}

// deep_dup_values translates Hash#deep_dup for typed string-keyed maps. V map
// keys are values, so only the recursively copied values need replacement.
pub fn deep_dup_hash_values(values map[string]ruby.Value) map[string]ruby.Value {
	mut duplicated := map[string]ruby.Value{}
	for key, value in values {
		duplicated[key] = deep_dup_value(value)
	}
	return duplicated
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # Returns a deep copy of hash.
// 6:   #
// 7:   #   hash = { a: { b: 'b' } }
// 8:   #   dup  = hash.deep_dup
// 9:   #   dup[:a][:c] = 'c'
// 10:   #
// 11:   #   hash[:a][:c] # => nil
// 12:   #   dup[:a][:c]  # => "c"
// 13:   sig { returns(T.self_type) }
// 14:   def deep_dup
// 15:     hash = dup
// 16:     each_pair do |key, value|
// 17:       case key
// 18:       when ::String, ::Symbol
// 19:         hash[key] = T.unsafe(value).deep_dup
// 20:       else
// 21:         hash.delete(key)
// 22:         hash[T.unsafe(key).deep_dup] = T.unsafe(value).deep_dup
// 23:       end
// 24:     end
// 25:     hash
// 26:   end
// 27: end
