module os

import brew_runtime

// Translated from Homebrew/brew `test/os/linux_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a list of all languages" do` at line 9.
pub fn ruby_linux_spec_l9_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the first item from` at line 15.
pub fn ruby_linux_spec_l15_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the OS version" do` at line 21.
pub fn ruby_linux_spec_l21_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the WSL state" do` at line 27.
pub fn ruby_linux_spec_l27_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the WSL version" do` at line 33.
pub fn ruby_linux_spec_l33_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "locale"
// 5: require "os/linux"
// 6:
// 7: RSpec.describe OS::Linux do
// 8:   describe "::languages", :needs_linux do
// 9:     it "returns a list of all languages" do
// 10:       expect(described_class.languages).not_to be_empty
// 11:     end
// 12:   end
// 13:
// 14:   describe "::language", :needs_linux do
// 15:     it "returns the first item from #languages" do
// 16:       expect(described_class.language).to eq(described_class.languages.first)
// 17:     end
// 18:   end
// 19:
// 20:   describe "::'os_version'", :needs_linux do
// 21:     it "returns the OS version" do
// 22:       expect(described_class.os_version).not_to be_empty
// 23:     end
// 24:   end
// 25:
// 26:   describe "::'wsl?'" do
// 27:     it "returns the WSL state" do
// 28:       expect(described_class.wsl?).to be(false)
// 29:     end
// 30:   end
// 31:
// 32:   describe "::'wsl_version'", :needs_linux do
// 33:     it "returns the WSL version" do
// 34:       expect(described_class.wsl_version).to match(Version::NULL)
// 35:     end
// 36:   end
// 37: end
