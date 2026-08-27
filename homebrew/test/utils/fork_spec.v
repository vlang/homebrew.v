module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/fork_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "preserves build error details" do` at line 8.
pub fn ruby_fork_spec_l8_d1_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "raises a RuntimeError on an error that isn't ErrorDuringExecution" do` at line 18.
pub fn ruby_fork_spec_l18_d2_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises an ErrorDuringExecution on one in the child" do` at line 26.
pub fn ruby_fork_spec_l26_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/fork"
// 5:
// 6: RSpec.describe Utils do
// 7:   describe "::child_error_hash" do
// 8:     it "preserves build error details" do
// 9:       error = BuildError.new(nil, "make", ["install"], { "PATH" => "/bin" })
// 10:
// 11:       expect(described_class.child_error_hash(error)).to include(
// 12:         "cmd" => "make", "args" => ["install"], "env" => { "PATH" => "/bin" },
// 13:       )
// 14:     end
// 15:   end
// 16:
// 17:   describe "#safe_fork" do
// 18:     it "raises a RuntimeError on an error that isn't ErrorDuringExecution" do
// 19:       expect do
// 20:         described_class.safe_fork do
// 21:           raise "this is an exception in the child"
// 22:         end
// 23:       end.to raise_error(RuntimeError)
// 24:     end
// 25:
// 26:     it "raises an ErrorDuringExecution on one in the child" do
// 27:       expect do
// 28:         described_class.safe_fork do
// 29:           safe_system "/usr/bin/false"
// 30:         end
// 31:       end.to raise_error(ErrorDuringExecution)
// 32:     end
// 33:   end
// 34: end
