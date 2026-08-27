module homebrew

import brew_runtime

// Translated from Homebrew/brew `brew_irb_helpers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `f(*args)` at line 13.
pub fn ruby_brew_irb_helpers_l13_d1_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby method `c(config: nil)` at line 19.
pub fn ruby_brew_irb_helpers_l19_d2_c(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper methods for the Homebrew IRB/PRY shell run by `brew irb`
// 5:
// 6: require "formula"
// 7: require "formulary"
// 8: require "cask/cask_loader"
// 9:
// 10: class String
// 11:   # @!visibility private
// 12:   sig { params(args: Integer).returns(Formula) }
// 13:   def f(*args)
// 14:     Formulary.factory(self, *args)
// 15:   end
// 16:
// 17:   # @!visibility private
// 18:   sig { params(config: T.nilable(T::Hash[Symbol, T.untyped])).returns(Cask::Cask) }
// 19:   def c(config: nil)
// 20:     Cask::CaskLoader.load(self, config: Cask::Config.new(**config))
// 21:   end
// 22: end
// 23: require "brew_irb_helpers/symbol"
