module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/provided_by_macos_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_provided_by_macos_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "fails for formulae not in PROVIDED_BY_MACOS_FORMULAE list" do` at line 9.
pub fn ruby_provided_by_macos_spec_l9_d2_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "succeeds for formulae in PROVIDED_BY_MACOS_FORMULAE list" do` at line 21.
pub fn ruby_provided_by_macos_spec_l21_d3_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('succeeds', ...args)
}

// Ruby it `it "succeeds for formulae that are keg_only for a different reason" do` at line 32.
pub fn ruby_provided_by_macos_spec_l32_d4_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('succeeds', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/uses_from_macos"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ProvidedByMacos do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "fails for formulae not in PROVIDED_BY_MACOS_FORMULAE list" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Baz < Formula
// 12:         url "https://brew.sh/baz-1.0.tgz"
// 13:         homepage "https://brew.sh"
// 14:
// 15:         keg_only :provided_by_macos
// 16:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/ProvidedByMacos: Formulae that are `keg_only :provided_by_macos` should be added to the `PROVIDED_BY_MACOS_FORMULAE` list (in the Homebrew/brew repository)
// 17:       end
// 18:     RUBY
// 19:   end
// 20:
// 21:   it "succeeds for formulae in PROVIDED_BY_MACOS_FORMULAE list" do
// 22:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/apr.rb")
// 23:       class Apr < Formula
// 24:         url "https://brew.sh/apr-1.0.tgz"
// 25:         homepage "https://brew.sh"
// 26:
// 27:         keg_only :provided_by_macos
// 28:       end
// 29:     RUBY
// 30:   end
// 31:
// 32:   it "succeeds for formulae that are keg_only for a different reason" do
// 33:     expect_no_offenses(<<~RUBY)
// 34:       class Foo < Formula
// 35:         url "https://brew.sh/foo-1.0.tgz"
// 36:         homepage "https://brew.sh"
// 37:
// 38:         keg_only :versioned_formula
// 39:       end
// 40:     RUBY
// 41:   end
// 42:
// 43:   include_examples "formulae exist", RuboCop::Cop::FormulaAudit::ProvidedByMacos::PROVIDED_BY_MACOS_FORMULAE
// 44: end
