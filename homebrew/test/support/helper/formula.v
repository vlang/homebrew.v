module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `formula(name = "formula_name", path: nil, spec: :stable, alias_path: nil, tap: nil, &block)` at line 19.
pub fn ruby_formula_l19_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby method `stub_formula_loader(formula, ref = formula.full_name, call_original: false)` at line 27.
pub fn ruby_formula_l27_d2_stub_formula_loader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_formula_loader', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formulary"
// 5:
// 6: module Test
// 7:   module Helper
// 8:     module Formula
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { RSpec::Mocks::ExampleMethods }
// 12:
// 13:       sig {
// 14:         params(
// 15:           name: String, path: T.nilable(Pathname), spec: Symbol, alias_path: T.nilable(Pathname),
// 16:           tap: T.nilable(Tap), block: T.nilable(T.proc.void)
// 17:         ).returns(::Formula)
// 18:       }
// 19:       def formula(name = "formula_name", path: nil, spec: :stable, alias_path: nil, tap: nil, &block)
// 20:         path ||= Formulary.find_formula_in_tap(name, tap || CoreTap.instance)
// 21:         Class.new(::Formula, &block).new(name, path, spec, alias_path:, tap:)
// 22:       end
// 23:
// 24:       # Use a stubbed {Formulary::FormulaLoader} to make a given formula be found
// 25:       # when loading from {Formulary} with `ref`.
// 26:       sig { params(formula: ::Formula, ref: T.nilable(T.any(String, Pathname)), call_original: T::Boolean).void }
// 27:       def stub_formula_loader(formula, ref = formula.full_name, call_original: false)
// 28:         allow(Formulary).to receive(:loader_for).and_call_original if call_original
// 29:
// 30:         loader = instance_double(Formulary::FormulaLoader, get_formula: formula, name: formula.name)
// 31:         allow(Formulary).to receive(:loader_for).with(ref, any_args).and_return(loader)
// 32:       end
// 33:     end
// 34:   end
// 35: end
