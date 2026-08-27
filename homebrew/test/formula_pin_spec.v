module test

import brew_runtime

// Translated from Homebrew/brew `test/formula_pin_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:formula_pin) { described_class.new(formula) }` at line 7.
pub fn ruby_formula_pin_spec_l7_d1_formula_pin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_pin', ...args)
}

// Ruby let `let(:name) { "double" }` at line 9.
pub fn ruby_formula_pin_spec_l9_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, name:, rack: HOMEBREW_CELLAR/name) }` at line 10.
pub fn ruby_formula_pin_spec_l10_d3_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it "is not pinnable by default" do` at line 24.
pub fn ruby_formula_pin_spec_l24_d4_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is pinnable if the Keg exists" do` at line 28.
pub fn ruby_formula_pin_spec_l28_d5_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby specify `specify "#pin and` at line 33.
pub fn ruby_formula_pin_spec_l33_d6_pin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#pin', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_pin"
// 5:
// 6: RSpec.describe FormulaPin do
// 7:   subject(:formula_pin) { described_class.new(formula) }
// 8:
// 9:   let(:name) { "double" }
// 10:   let(:formula) { instance_double(Formula, name:, rack: HOMEBREW_CELLAR/name) }
// 11:
// 12:   before do
// 13:     formula.rack.mkpath
// 14:
// 15:     allow(formula).to receive(:installed_prefixes) do
// 16:       formula.rack.directory? ? formula.rack.subdirs.sort : []
// 17:     end
// 18:
// 19:     allow(formula).to receive(:installed_kegs) do
// 20:       formula.installed_prefixes.map { |prefix| Keg.new(prefix) }
// 21:     end
// 22:   end
// 23:
// 24:   it "is not pinnable by default" do
// 25:     expect(formula_pin).not_to be_pinnable
// 26:   end
// 27:
// 28:   it "is pinnable if the Keg exists" do
// 29:     (formula.rack/"0.1").mkpath
// 30:     expect(formula_pin).to be_pinnable
// 31:   end
// 32:
// 33:   specify "#pin and #unpin" do
// 34:     (formula.rack/"0.1").mkpath
// 35:
// 36:     formula_pin.pin
// 37:     expect(formula_pin).to be_pinned
// 38:     expect(HOMEBREW_PINNED_KEGS/name).to be_a_directory
// 39:     expect(HOMEBREW_PINNED_KEGS.children.count).to eq(1)
// 40:
// 41:     formula_pin.unpin
// 42:     expect(formula_pin).not_to be_pinned
// 43:     expect(HOMEBREW_PINNED_KEGS).not_to be_a_directory
// 44:   end
// 45: end
