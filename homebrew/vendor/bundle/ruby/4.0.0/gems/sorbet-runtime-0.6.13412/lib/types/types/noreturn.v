module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/noreturn.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize; end` at line 7.
pub fn ruby_noreturn_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 9.
pub fn ruby_noreturn_l9_d2_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 14.
pub fn ruby_noreturn_l14_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 19.
pub fn ruby_noreturn_l19_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 24.
pub fn ruby_noreturn_l24_d5_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # The bottom type
// 6:   class NoReturn < Base
// 7:     def initialize; end
// 8:
// 9:     def build_type
// 10:       nil
// 11:     end
// 12:
// 13:     # overrides Base
// 14:     def name
// 15:       "T.noreturn"
// 16:     end
// 17:
// 18:     # overrides Base
// 19:     def valid?(obj)
// 20:       false
// 21:     end
// 22:
// 23:     # overrides Base
// 24:     private def subtype_of_single?(other)
// 25:       true
// 26:     end
// 27:
// 28:     module Private
// 29:       INSTANCE = NoReturn.new.freeze
// 30:     end
// 31:   end
// 32: end
