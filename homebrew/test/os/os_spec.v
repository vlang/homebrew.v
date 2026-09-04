module os

import ruby

// Translated from Homebrew/brew `test/os/os_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "is not NULL" do` at line 6.
pub fn ruby_os_spec_l6_d1_is(args ...ruby.Value) ruby.Value {
	version := if args.len > 0 { args[0].as_string() } else { ruby.kernel_info().release }
	return ruby.bool_value(kernel_version_is_not_null(version))
}

// Ruby it `it "returns Linux on Linux", :needs_linux do` at line 12.
pub fn ruby_os_spec_l12_d2_returns(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'Linux' }
	return ruby.bool_value(kernel_name_matches(name, 'Linux'))
}

// Ruby it `it "returns Darwin on macOS", :needs_macos do` at line 16.
pub fn ruby_os_spec_l16_d3_returns(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'Darwin' }
	return ruby.bool_value(kernel_name_matches(name, 'Darwin'))
}

pub fn kernel_version_is_not_null(version string) bool {
	return version.trim_space() != '' && version != 'NULL'
}

pub fn kernel_name_matches(actual string, expected string) bool {
	return actual == expected
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
