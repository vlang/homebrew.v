module test

import brew_runtime

// Translated from Homebrew/brew `test/cask_dependent_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dependent) { described_class.new test_cask }` at line 8.
pub fn ruby_cask_dependent_spec_l8_d1_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependent', ...args)
}

// Ruby let `let :test_cask do` at line 10.
pub fn ruby_cask_dependent_spec_l10_d2_test_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_cask', ...args)
}

// Ruby it `it "is the formula dependencies of the cask" do` at line 21.
pub fn ruby_cask_dependent_spec_l21_d3_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is the requirements of the cask" do` at line 28.
pub fn ruby_cask_dependent_spec_l28_d4_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is all the dependencies of the cask" do` at line 35.
pub fn ruby_cask_dependent_spec_l35_d5_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is all the dependencies of the cask" do` at line 49.
pub fn ruby_cask_dependent_spec_l49_d6_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/cask_loader"
// 5: require "cask_dependent"
// 6:
// 7: RSpec.describe CaskDependent, :needs_macos do
// 8:   subject(:dependent) { described_class.new test_cask }
// 9:
// 10:   let :test_cask do
// 11:     Cask::CaskLoader.load(+<<-RUBY)
// 12:       cask "testing" do
// 13:         depends_on formula: "baz"
// 14:         depends_on cask: "foo-cask"
// 15:         depends_on macos: :sequoia
// 16:       end
// 17:     RUBY
// 18:   end
// 19:
// 20:   describe "#deps" do
// 21:     it "is the formula dependencies of the cask" do
// 22:       expect(dependent.deps.map(&:name))
// 23:         .to eq %w[baz]
// 24:     end
// 25:   end
// 26:
// 27:   describe "#requirements" do
// 28:     it "is the requirements of the cask" do
// 29:       expect(dependent.requirements.map(&:name))
// 30:         .to eq %w[foo-cask macos]
// 31:     end
// 32:   end
// 33:
// 34:   describe "#recursive_dependencies", :integration_test, :no_api do
// 35:     it "is all the dependencies of the cask" do
// 36:       setup_test_formula "foo"
// 37:       setup_test_formula "bar"
// 38:       setup_test_formula "baz", <<-RUBY
// 39:         url "https://brew.sh/baz-1.0"
// 40:         depends_on "bar"
// 41:       RUBY
// 42:
// 43:       expect(dependent.recursive_dependencies.map(&:name))
// 44:         .to eq(%w[foo bar baz])
// 45:     end
// 46:   end
// 47:
// 48:   describe "#recursive_requirements", :integration_test do
// 49:     it "is all the dependencies of the cask" do
// 50:       setup_test_formula "foo"
// 51:       setup_test_formula "bar"
// 52:       setup_test_formula "baz", <<-RUBY
// 53:         url "https://brew.sh/baz-1.0"
// 54:         depends_on "bar"
// 55:       RUBY
// 56:
// 57:       expect(dependent.recursive_requirements.map(&:name))
// 58:         .to eq(%w[foo-cask macos])
// 59:     end
// 60:   end
// 61: end
