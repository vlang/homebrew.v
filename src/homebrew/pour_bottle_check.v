module homebrew

import brew_runtime

// Translated from Homebrew/brew `pour_bottle_check.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 8.
pub fn ruby_pour_bottle_check_l8_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `reason(reason)` at line 13.
pub fn ruby_pour_bottle_check_l13_d2_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
}

// Ruby method `satisfy(&block)` at line 18.
pub fn ruby_pour_bottle_check_l18_d3_satisfy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('satisfy', ...args)
}

// Ruby define_method `@formula.send(:define_method, :pour_bottle?, &block)` at line 19.
pub fn ruby_pour_bottle_check_l19_d4_pour_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pour_bottle?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class PourBottleCheck
// 5:   include OnSystem::MacOSAndLinux
// 6:
// 7:   sig { params(formula: T.class_of(Formula)).void }
// 8:   def initialize(formula)
// 9:     @formula = formula
// 10:   end
// 11:
// 12:   sig { params(reason: String).void }
// 13:   def reason(reason)
// 14:     @formula.pour_bottle_check_unsatisfied_reason = reason
// 15:   end
// 16:
// 17:   sig { params(block: T.proc.bind(::Formula).returns(T::Boolean)).void }
// 18:   def satisfy(&block)
// 19:     @formula.send(:define_method, :pour_bottle?, &block)
// 20:   end
// 21: end
