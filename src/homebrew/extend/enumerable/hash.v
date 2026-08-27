module enumerable

import brew_runtime

// Translated from Homebrew/brew `extend/enumerable/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `compact_blank = reject { |_k, v| T.unsafe(v).blank? }` at line 6.
pub fn ruby_hash_l6_d1_compact_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compact_blank', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Hash
// 5:   # {Hash#reject} has its own definition, so this needs one too.
// 6:   def compact_blank = reject { |_k, v| T.unsafe(v).blank? }
// 7: end
