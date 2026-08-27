module test

import brew_runtime

// Translated from Homebrew/brew `test/dependable_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :be_a_build_dependency, :be_build` at line 7.
pub fn ruby_dependable_spec_l7_d1_be_a_build_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_a_build_dependency', ...args)
}

// Ruby subject `subject(:dependable) do` at line 9.
pub fn ruby_dependable_spec_l9_d2_dependable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependable', ...args)
}

// Ruby method `initialize` at line 13.
pub fn ruby_dependable_spec_l13_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby specify `specify do` at line 19.
pub fn ruby_dependable_spec_l19_d4_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby subject `subject(:dependable_no_linkage) do` at line 28.
pub fn ruby_dependable_spec_l28_d5_dependable_no_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependable_no_linkage', ...args)
}

// Ruby method `initialize` at line 32.
pub fn ruby_dependable_spec_l32_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby specify `specify do` at line 38.
pub fn ruby_dependable_spec_l38_d7_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependable"
// 5:
// 6: RSpec.describe Dependable do
// 7:   alias_matcher :be_a_build_dependency, :be_build
// 8:
// 9:   subject(:dependable) do
// 10:     Class.new do
// 11:       include Dependable
// 12:
// 13:       def initialize
// 14:         @tags = ["foo", "bar", :build]
// 15:       end
// 16:     end.new
// 17:   end
// 18:
// 19:   specify do
// 20:     expect(dependable.options.as_flags.sort).to eq(%w[--foo --bar].sort)
// 21:     expect(dependable).to be_a_build_dependency
// 22:     expect(dependable).not_to be_optional
// 23:     expect(dependable).not_to be_recommended
// 24:     expect(dependable).not_to be_no_linkage
// 25:   end
// 26:
// 27:   describe "with no_linkage tag" do
// 28:     subject(:dependable_no_linkage) do
// 29:       Class.new do
// 30:         include Dependable
// 31:
// 32:         def initialize
// 33:           @tags = [:no_linkage]
// 34:         end
// 35:       end.new
// 36:     end
// 37:
// 38:     specify do
// 39:       expect(dependable_no_linkage).to be_no_linkage
// 40:       expect(dependable_no_linkage).to be_required
// 41:     end
// 42:   end
// 43: end
