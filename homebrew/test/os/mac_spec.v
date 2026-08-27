module os

import brew_runtime

// Translated from Homebrew/brew `test/os/mac_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a list of all languages" do` at line 9.
pub fn ruby_mac_spec_l9_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the first item from` at line 15.
pub fn ruby_mac_spec_l15_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:clt_sdk_path) { Pathname("/tmp/clt/MacOS.sdk") }` at line 21.
pub fn ruby_mac_spec_l21_d3_clt_sdk_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clt_sdk_path', ...args)
}

// Ruby let `let(:clt_sdk) { OS::Mac::SDK.new(MacOSVersion.new("26"), clt_sdk_path, :clt) }` at line 22.
pub fn ruby_mac_spec_l22_d4_clt_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clt_sdk', ...args)
}

// Ruby let `let(:xcode_sdk_path) { Pathname("/tmp/xcode/MacOS.sdk") }` at line 23.
pub fn ruby_mac_spec_l23_d5_xcode_sdk_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xcode_sdk_path', ...args)
}

// Ruby let `let(:xcode_sdk) { OS::Mac::SDK.new(MacOSVersion.new("26"), xcode_sdk_path, :xcode) }` at line 24.
pub fn ruby_mac_spec_l24_d6_xcode_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xcode_sdk', ...args)
}

// Ruby it `it "returns the Xcode SDK path on Xcode-only systems" do` at line 31.
pub fn ruby_mac_spec_l31_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the CLT SDK path on CLT-only systems" do` at line 37.
pub fn ruby_mac_spec_l37_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "locale"
// 5: require "os/mac"
// 6:
// 7: RSpec.describe OS::Mac do
// 8:   describe "::languages" do
// 9:     it "returns a list of all languages" do
// 10:       expect(described_class.languages).not_to be_empty
// 11:     end
// 12:   end
// 13:
// 14:   describe "::language" do
// 15:     it "returns the first item from #languages" do
// 16:       expect(described_class.language).to eq(described_class.languages.first)
// 17:     end
// 18:   end
// 19:
// 20:   describe "::sdk_path" do
// 21:     let(:clt_sdk_path) { Pathname("/tmp/clt/MacOS.sdk") }
// 22:     let(:clt_sdk) { OS::Mac::SDK.new(MacOSVersion.new("26"), clt_sdk_path, :clt) }
// 23:     let(:xcode_sdk_path) { Pathname("/tmp/xcode/MacOS.sdk") }
// 24:     let(:xcode_sdk) { OS::Mac::SDK.new(MacOSVersion.new("26"), xcode_sdk_path, :xcode) }
// 25:
// 26:     before do
// 27:       allow_any_instance_of(OS::Mac::CLTSDKLocator).to receive(:sdk_if_applicable).and_return(clt_sdk)
// 28:       allow_any_instance_of(OS::Mac::XcodeSDKLocator).to receive(:sdk_if_applicable).and_return(xcode_sdk)
// 29:     end
// 30:
// 31:     it "returns the Xcode SDK path on Xcode-only systems" do
// 32:       allow(OS::Mac::Xcode).to receive(:installed?).and_return(true)
// 33:       allow(OS::Mac::CLT).to receive(:installed?).and_return(false)
// 34:       expect(described_class.sdk_path).to eq(xcode_sdk_path)
// 35:     end
// 36:
// 37:     it "returns the CLT SDK path on CLT-only systems" do
// 38:       allow(OS::Mac::Xcode).to receive(:installed?).and_return(false)
// 39:       allow(OS::Mac::CLT).to receive(:installed?).and_return(true)
// 40:       expect(described_class.sdk_path).to eq(clt_sdk_path)
// 41:     end
// 42:   end
// 43: end
