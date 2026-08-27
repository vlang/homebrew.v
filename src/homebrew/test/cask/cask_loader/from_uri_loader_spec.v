module cask_loader

import brew_runtime

// Translated from Homebrew/brew `test/cask/cask_loader/from_uri_loader_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a loader when given an URI" do` at line 6.
pub fn ruby_from_uri_loader_spec_l6_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a loader when given a string which can be parsed to a URI" do` at line 10.
pub fn ruby_from_uri_loader_spec_l10_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when path loading is disabled" do` at line 14.
pub fn ruby_from_uri_loader_spec_l14_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when given a string with Cask contents containing a URL" do` at line 19.
pub fn ruby_from_uri_loader_spec_l19_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises an error when given an https URL" do` at line 29.
pub fn ruby_from_uri_loader_spec_l29_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises an error when given an ftp URL" do` at line 36.
pub fn ruby_from_uri_loader_spec_l36_d6_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises an error when given an sftp URL" do` at line 43.
pub fn ruby_from_uri_loader_spec_l43_d7_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not raise an error when given a file URL", :needs_utils_curl do` at line 50.
pub fn ruby_from_uri_loader_spec_l50_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromURILoader do
// 5:   describe "::try_new" do
// 6:     it "returns a loader when given an URI" do
// 7:       expect(described_class.try_new(URI("https://brew.sh/"))).not_to be_nil
// 8:     end
// 9:
// 10:     it "returns a loader when given a string which can be parsed to a URI" do
// 11:       expect(described_class.try_new("https://brew.sh/")).not_to be_nil
// 12:     end
// 13:
// 14:     it "returns nil when path loading is disabled" do
// 15:       ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 16:       expect(described_class.try_new(URI("file://#{TEST_FIXTURE_DIR}/cask/Casks/local-caffeine.rb"))).to be_nil
// 17:     end
// 18:
// 19:     it "returns nil when given a string with Cask contents containing a URL" do
// 20:       expect(described_class.try_new(<<~RUBY)).to be_nil
// 21:         cask 'token' do
// 22:           url 'https://brew.sh/'
// 23:         end
// 24:       RUBY
// 25:     end
// 26:   end
// 27:
// 28:   describe "::load" do
// 29:     it "raises an error when given an https URL" do
// 30:       loader = described_class.new("https://brew.sh/foo.rb")
// 31:       expect do
// 32:         loader.load(config: nil)
// 33:       end.to raise_error(UnsupportedInstallationMethod)
// 34:     end
// 35:
// 36:     it "raises an error when given an ftp URL" do
// 37:       loader = described_class.new("ftp://brew.sh/foo.rb")
// 38:       expect do
// 39:         loader.load(config: nil)
// 40:       end.to raise_error(UnsupportedInstallationMethod)
// 41:     end
// 42:
// 43:     it "raises an error when given an sftp URL" do
// 44:       loader = described_class.new("sftp://brew.sh/foo.rb")
// 45:       expect do
// 46:         loader.load(config: nil)
// 47:       end.to raise_error(UnsupportedInstallationMethod)
// 48:     end
// 49:
// 50:     it "does not raise an error when given a file URL", :needs_utils_curl do
// 51:       loader = described_class.new("file://#{TEST_FIXTURE_DIR}/cask/Casks/local-caffeine.rb")
// 52:       expect do
// 53:         loader.load(config: nil)
// 54:       end.not_to raise_error
// 55:     end
// 56:   end
// 57: end
