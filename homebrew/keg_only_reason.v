module homebrew

import brew_runtime

// Translated from Homebrew/brew `keg_only_reason.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :reason` at line 8.
pub fn ruby_keg_only_reason_l8_d1_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
}

// Ruby method `initialize(reason, explanation)` at line 11.
pub fn ruby_keg_only_reason_l11_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `versioned_formula?` at line 17.
pub fn ruby_keg_only_reason_l17_d3_versioned_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_formula?', ...args)
}

// Ruby method `provided_by_macos?` at line 22.
pub fn ruby_keg_only_reason_l22_d4_provided_by_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('provided_by_macos?', ...args)
}

// Ruby method `shadowed_by_macos?` at line 27.
pub fn ruby_keg_only_reason_l27_d5_shadowed_by_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shadowed_by_macos?', ...args)
}

// Ruby method `by_macos?` at line 32.
pub fn ruby_keg_only_reason_l32_d6_by_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('by_macos?', ...args)
}

// Ruby method `applicable?` at line 37.
pub fn ruby_keg_only_reason_l37_d7_applicable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('applicable?', ...args)
}

// Ruby method `to_s` at line 44.
pub fn ruby_keg_only_reason_l44_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `to_hash` at line 67.
pub fn ruby_keg_only_reason_l67_d9_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_hash', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Used to annotate formulae that duplicate macOS-provided software
// 5: # or cause conflicts when linked in.
// 6: class KegOnlyReason
// 7:   sig { returns(T.any(Symbol, String)) }
// 8:   attr_reader :reason
// 9:
// 10:   sig { params(reason: T.any(Symbol, String), explanation: String).void }
// 11:   def initialize(reason, explanation)
// 12:     @reason = reason
// 13:     @explanation = explanation
// 14:   end
// 15:
// 16:   sig { returns(T::Boolean) }
// 17:   def versioned_formula?
// 18:     @reason == :versioned_formula
// 19:   end
// 20:
// 21:   sig { returns(T::Boolean) }
// 22:   def provided_by_macos?
// 23:     @reason == :provided_by_macos
// 24:   end
// 25:
// 26:   sig { returns(T::Boolean) }
// 27:   def shadowed_by_macos?
// 28:     @reason == :shadowed_by_macos
// 29:   end
// 30:
// 31:   sig { returns(T::Boolean) }
// 32:   def by_macos?
// 33:     provided_by_macos? || shadowed_by_macos?
// 34:   end
// 35:
// 36:   sig { returns(T::Boolean) }
// 37:   def applicable?
// 38:     # macOS reasons aren't applicable on other OSs
// 39:     # (see extend/os/mac/keg_only_reason for override on macOS)
// 40:     !by_macos?
// 41:   end
// 42:
// 43:   sig { returns(String) }
// 44:   def to_s
// 45:     return @explanation unless @explanation.empty?
// 46:
// 47:     if versioned_formula?
// 48:       <<~EOS
// 49:         this is an alternate version of another formula
// 50:       EOS
// 51:     elsif provided_by_macos?
// 52:       <<~EOS
// 53:         macOS already provides this software and installing another version in
// 54:         parallel can cause all kinds of trouble
// 55:       EOS
// 56:     elsif shadowed_by_macos?
// 57:       <<~EOS
// 58:         macOS provides similar software and installing this software in
// 59:         parallel can cause all kinds of trouble
// 60:       EOS
// 61:     else
// 62:       @reason.to_s
// 63:     end.strip
// 64:   end
// 65:
// 66:   sig { returns(T::Hash[String, String]) }
// 67:   def to_hash
// 68:     reason_string = if @reason.is_a?(Symbol)
// 69:       @reason.inspect
// 70:     else
// 71:       @reason.to_s
// 72:     end
// 73:
// 74:     {
// 75:       "reason"      => reason_string,
// 76:       "explanation" => @explanation,
// 77:     }
// 78:   end
// 79: end
// 80:
// 81: require "extend/os/keg_only_reason"
