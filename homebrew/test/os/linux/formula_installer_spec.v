module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/formula_installer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(keg_path) }` at line 8.
pub fn ruby_formula_installer_spec_l8_d1_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby subject `subject(:formula_installer) { described_class.new(Testball.new) }` at line 13.
pub fn ruby_formula_installer_spec_l13_d2_formula_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_installer', ...args)
}

// Ruby it `it "is true by default" do` at line 15.
pub fn ruby_formula_installer_spec_l15_d3_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is false in developer mode" do` at line 20.
pub fn ruby_formula_installer_spec_l20_d4_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_installer"
// 5: require "test/support/fixtures/testball"
// 6:
// 7: RSpec.describe FormulaInstaller do
// 8:   subject(:keg) { described_class.new(keg_path) }
// 9:
// 10:   include FileUtils
// 11:
// 12:   describe "#fresh_install" do
// 13:     subject(:formula_installer) { described_class.new(Testball.new) }
// 14:
// 15:     it "is true by default" do
// 16:       formula = Testball.new
// 17:       expect(formula_installer.fresh_install?(formula)).to be true
// 18:     end
// 19:
// 20:     it "is false in developer mode" do
// 21:       formula = Testball.new
// 22:       allow(Homebrew::EnvConfig).to receive_messages(developer?: true)
// 23:       expect(formula_installer.fresh_install?(formula)).to be false
// 24:     end
// 25:   end
// 26: end
