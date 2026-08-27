module os

import brew_runtime

// Translated from Homebrew/brew `test/os/os_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "is not NULL" do` at line 6.
pub fn ruby_os_spec_l6_d1_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "returns Linux on Linux", :needs_linux do` at line 12.
pub fn ruby_os_spec_l12_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns Darwin on macOS", :needs_macos do` at line 16.
pub fn ruby_os_spec_l16_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe OS do
// 5:   describe "::kernel_version" do
// 6:     it "is not NULL" do
// 7:       expect(described_class.kernel_version).not_to be_null
// 8:     end
// 9:   end
// 10:
// 11:   describe "::kernel_name" do
// 12:     it "returns Linux on Linux", :needs_linux do
// 13:       expect(described_class.kernel_name).to eq "Linux"
// 14:     end
// 15:
// 16:     it "returns Darwin on macOS", :needs_macos do
// 17:       expect(described_class.kernel_name).to eq "Darwin"
// 18:     end
// 19:   end
// 20: end
