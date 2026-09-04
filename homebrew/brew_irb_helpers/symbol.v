module brew_irb_helpers

import ruby
import homebrew

// Translated from Homebrew/brew `brew_irb_helpers/symbol.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `f(*args)` at line 7.
pub fn ruby_symbol_l7_d1_f(args ...ruby.Value) ruby.Value {
	return homebrew.ruby_brew_irb_helpers_l13_d1_f(...args)
}

// Ruby method `c(config: nil)` at line 13.
pub fn ruby_symbol_l13_d2_c(args ...ruby.Value) ruby.Value {
	return homebrew.ruby_brew_irb_helpers_l19_d2_c(...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Symbol
// 5:   # @!visibility private
// 6:   sig { params(args: Integer).returns(Formula) }
// 7:   def f(*args)
// 8:     to_s.f(*args)
// 9:   end
// 10:
// 11:   # @!visibility private
// 12:   sig { params(config: T.nilable(T::Hash[Symbol, T.untyped])).returns(Cask::Cask) }
// 13:   def c(config: nil)
// 14:     to_s.c(config:)
// 15:   end
// 16: end
