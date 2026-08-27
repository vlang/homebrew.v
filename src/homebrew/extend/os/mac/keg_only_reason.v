module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/keg_only_reason.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `applicable?` at line 6.
pub fn ruby_keg_only_reason_l6_d1_applicable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('applicable?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class KegOnlyReason
// 5:   sig { returns(T::Boolean) }
// 6:   def applicable?
// 7:     true
// 8:   end
// 9: end
