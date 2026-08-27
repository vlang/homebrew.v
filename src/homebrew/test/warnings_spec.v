module test

import brew_runtime

// Translated from Homebrew/brew `test/warnings_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "restores ignored warnings after an exception" do` at line 7.
pub fn ruby_warnings_spec_l7_d1_restores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restores', ...args)
}

// Ruby it `it "supports nested ignored warnings" do` at line 15.
pub fn ruby_warnings_spec_l15_d2_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "warnings"
// 5:
// 6: RSpec.describe Warnings do
// 7:   it "restores ignored warnings after an exception" do
// 8:     expect do
// 9:       described_class.ignore(/ignored warning/) { raise "failure" }
// 10:     rescue RuntimeError
// 11:       Warning.warn("ignored warning\n")
// 12:     end.to output("ignored warning\n").to_stderr
// 13:   end
// 14:
// 15:   it "supports nested ignored warnings" do
// 16:     expect do
// 17:       described_class.ignore(/outer warning/) do
// 18:         Warning.warn("outer warning\n")
// 19:         described_class.ignore(/inner warning/) do
// 20:           Warning.warn("outer warning\n")
// 21:           Warning.warn("inner warning\n")
// 22:         end
// 23:         Warning.warn("outer warning\n")
// 24:         Warning.warn("inner warning\n")
// 25:       end
// 26:       Warning.warn("outer warning\n")
// 27:     end.to output("inner warning\nouter warning\n").to_stderr
// 28:   end
// 29: end
