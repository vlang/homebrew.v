module options

import brew_runtime

// Translated from Homebrew/brew `options/deprecated_option.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :old, :current` at line 7.
pub fn ruby_deprecated_option_l7_d1_old(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old', ...args)
}

// Ruby attr_reader `attr_reader :old, :current` at line 7.
pub fn ruby_deprecated_option_l7_d2_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current', ...args)
}

// Ruby method `initialize(old, current)` at line 10.
pub fn ruby_deprecated_option_l10_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `old_flag` at line 16.
pub fn ruby_deprecated_option_l16_d4_old_flag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_flag', ...args)
}

// Ruby method `current_flag` at line 21.
pub fn ruby_deprecated_option_l21_d5_current_flag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_flag', ...args)
}

// Ruby method `==(other)` at line 26.
pub fn ruby_deprecated_option_l26_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 34.
pub fn ruby_deprecated_option_l34_d7_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A deprecated formula option.
// 5: class DeprecatedOption
// 6:   sig { returns(String) }
// 7:   attr_reader :old, :current
// 8:
// 9:   sig { params(old: String, current: String).void }
// 10:   def initialize(old, current)
// 11:     @old = old
// 12:     @current = current
// 13:   end
// 14:
// 15:   sig { returns(String) }
// 16:   def old_flag
// 17:     "--#{old}"
// 18:   end
// 19:
// 20:   sig { returns(String) }
// 21:   def current_flag
// 22:     "--#{current}"
// 23:   end
// 24:
// 25:   sig { params(other: T.anything).returns(T::Boolean) }
// 26:   def ==(other)
// 27:     case other
// 28:     when DeprecatedOption
// 29:       instance_of?(other.class) && old == other.old && current == other.current
// 30:     else
// 31:       false
// 32:     end
// 33:   end
// 34:   alias eql? ==
// 35: end
