module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/keg_only_reason.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `applicable?` at line 6.
pub fn ruby_keg_only_reason_l6_d1_applicable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_only_reason_is_applicable())
}

pub fn keg_only_reason_is_applicable() bool {
	return true
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
