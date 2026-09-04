module enumerable

import ruby
import homebrew.extend.blank

// Translated from Homebrew/brew `extend/enumerable/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `compact_blank = reject { |_k, v| T.unsafe(v).blank? }` at line 6.
pub fn ruby_hash_l6_d1_compact_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('Hash', '{}', {})
	}
	mut kept := map[string]string{}
	for key, value in args[0].attributes {
		if !blank.value_is_blank(ruby.string_value(value)) {
			kept[key] = value
		}
	}
	return ruby.structured_value('Hash', kept.str(), kept)
}

// compact_blank_values is the typed V form of Hash#compact_blank.
pub fn compact_blank_values(values map[string]ruby.Value) map[string]ruby.Value {
	mut compacted := map[string]ruby.Value{}
	for key, value in values {
		if !blank.value_is_blank(value) {
			compacted[key] = value
		}
	}
	return compacted
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # {Hash#reject} has its own definition, so this needs one too.
// 6:   def compact_blank = reject { |_k, v| T.unsafe(v).blank? }
// 7: end
