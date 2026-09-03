module enumerable

import brew_runtime
import homebrew.extend.blank

// Translated from Homebrew/brew `extend/enumerable/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `compact_blank = reject { |_k, v| T.unsafe(v).blank? }` at line 6.
pub fn ruby_hash_l6_d1_compact_blank(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.structured_value('Hash', '{}', {})
	}
	mut kept := map[string]string{}
	for key, value in args[0].attributes {
		if !blank.value_is_blank(brew_runtime.string_value(value)) {
			kept[key] = value
		}
	}
	return brew_runtime.structured_value('Hash', kept.str(), kept)
}

// compact_blank_values is the typed V form of Hash#compact_blank.
pub fn compact_blank_values(values map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut compacted := map[string]brew_runtime.Value{}
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
