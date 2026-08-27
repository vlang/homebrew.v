module test

import brew_runtime

// Translated from Homebrew/brew `test/compiler_failure_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :fail_with, :be_fails_with` at line 7.
pub fn ruby_compiler_failure_spec_l7_d1_fail_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fail_with', ...args)
}

// Ruby it `it "creates a failure when given a symbol" do` at line 10.
pub fn ruby_compiler_failure_spec_l10_d2_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "can be given a build number in a block" do` at line 17.
pub fn ruby_compiler_failure_spec_l17_d3_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can be given an empty block" do` at line 24.
pub fn ruby_compiler_failure_spec_l24_d4_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "creates a failure when given a hash" do` at line 33.
pub fn ruby_compiler_failure_spec_l33_d5_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates a failure when given a hash and a block with aversion" do` at line 50.
pub fn ruby_compiler_failure_spec_l50_d6_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5:
// 6: RSpec.describe CompilerFailure do
// 7:   alias_matcher :fail_with, :be_fails_with
// 8:
// 9:   describe "::create" do
// 10:     it "creates a failure when given a symbol" do
// 11:       failure = described_class.create(:clang)
// 12:       expect(failure).to fail_with(
// 13:         instance_double(CompilerSelector::Compiler, "Compiler", type: :clang, name: :clang, version: 600),
// 14:       )
// 15:     end
// 16:
// 17:     it "can be given a build number in a block" do
// 18:       failure = described_class.create(:clang) { build 700 }
// 19:       expect(failure).to fail_with(
// 20:         instance_double(CompilerSelector::Compiler, "Compiler", type: :clang, name: :clang, version: 700),
// 21:       )
// 22:     end
// 23:
// 24:     it "can be given an empty block" do
// 25:       failure = described_class.create(:clang) do
// 26:         # do nothing
// 27:       end
// 28:       expect(failure).to fail_with(
// 29:         instance_double(CompilerSelector::Compiler, "Compiler", type: :clang, name: :clang, version: 600),
// 30:       )
// 31:     end
// 32:
// 33:     it "creates a failure when given a hash" do
// 34:       failure = described_class.create(gcc: "7")
// 35:       expect(failure).to fail_with(
// 36:         instance_double(CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-7", version: Version.new("7")),
// 37:       )
// 38:       expect(failure).to fail_with(
// 39:         instance_double(
// 40:           CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-7", version: Version.new("7.1")
// 41:         ),
// 42:       )
// 43:       expect(failure).not_to fail_with(
// 44:         instance_double(
// 45:           CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-6", version: Version.new("6.0")
// 46:         ),
// 47:       )
// 48:     end
// 49:
// 50:     it "creates a failure when given a hash and a block with aversion" do
// 51:       failure = described_class.create(gcc: "7") { version "7.1" }
// 52:       expect(failure).to fail_with(
// 53:         instance_double(CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-7", version: Version.new("7")),
// 54:       )
// 55:       expect(failure).to fail_with(
// 56:         instance_double(
// 57:           CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-7", version: Version.new("7.1")
// 58:         ),
// 59:       )
// 60:       expect(failure).not_to fail_with(
// 61:         instance_double(
// 62:           CompilerSelector::Compiler, "Compiler", type: :gcc, name: "gcc-7", version: Version.new("7.2")
// 63:         ),
// 64:       )
// 65:     end
// 66:   end
// 67: end
