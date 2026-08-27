module test

import brew_runtime

// Translated from Homebrew/brew `test/macos_runner_spec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:spec) { described_class.new(name: "macOS 11-arm64", runner: "11-arm64", timeout: 90, cleanup: true) }` at line 7.
pub fn ruby_macos_runner_spec_spec_l7_d1_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('spec', ...args)
}

// Ruby it `it "has immutable attributes" do` at line 9.
pub fn ruby_macos_runner_spec_spec_l9_d2_has(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has', ...args)
}

// Ruby it `it "returns an object that responds to `#to_json`" do` at line 16.
pub fn ruby_macos_runner_spec_spec_l16_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_runner_spec"
// 5:
// 6: RSpec.describe MacOSRunnerSpec do
// 7:   let(:spec) { described_class.new(name: "macOS 11-arm64", runner: "11-arm64", timeout: 90, cleanup: true) }
// 8:
// 9:   it "has immutable attributes" do
// 10:     [:name, :runner, :timeout, :cleanup].each do |attribute|
// 11:       expect(spec.respond_to?(:"#{attribute}=")).to be(false)
// 12:     end
// 13:   end
// 14:
// 15:   describe "#to_h" do
// 16:     it "returns an object that responds to `#to_json`" do
// 17:       expect(spec.to_h.respond_to?(:to_json)).to be(true)
// 18:     end
// 19:   end
// 20: end
