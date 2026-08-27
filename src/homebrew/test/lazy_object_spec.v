module test

import brew_runtime

// Translated from Homebrew/brew `test/lazy_object_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "does not evaluate the block" do` at line 8.
pub fn ruby_lazy_object_spec_l8_d1_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "evaluates the block" do` at line 16.
pub fn ruby_lazy_object_spec_l16_d2_evaluates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('evaluates', ...args)
}

// Ruby it `it "delegates to the underlying object" do` at line 22.
pub fn ruby_lazy_object_spec_l22_d3_delegates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delegates', ...args)
}

// Ruby it `it "delegates to the underlying object" do` at line 28.
pub fn ruby_lazy_object_spec_l28_d4_delegates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delegates', ...args)
}

// Ruby it `it "delegates to the underlying object" do` at line 34.
pub fn ruby_lazy_object_spec_l34_d5_delegates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delegates', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "lazy_object"
// 5:
// 6: RSpec.describe LazyObject do
// 7:   describe "#initialize" do
// 8:     it "does not evaluate the block" do
// 9:       expect do |block|
// 10:         described_class.new(&block)
// 11:       end.not_to yield_control
// 12:     end
// 13:   end
// 14:
// 15:   describe "when receiving a message" do
// 16:     it "evaluates the block" do
// 17:       expect(described_class.new { 42 }.to_s).to eq "42"
// 18:     end
// 19:   end
// 20:
// 21:   describe "#!" do
// 22:     it "delegates to the underlying object" do
// 23:       expect(!described_class.new { false }).to be true
// 24:     end
// 25:   end
// 26:
// 27:   describe "#!=" do
// 28:     it "delegates to the underlying object" do
// 29:       expect(described_class.new { 42 }).not_to eq 13
// 30:     end
// 31:   end
// 32:
// 33:   describe "#==" do
// 34:     it "delegates to the underlying object" do
// 35:       expect(described_class.new { 42 }).to eq 42
// 36:     end
// 37:   end
// 38: end
