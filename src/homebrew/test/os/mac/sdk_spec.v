module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/sdk_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:locator) { described_class.new }` at line 5.
pub fn ruby_sdk_spec_l5_d1_locator(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locator', ...args)
}

// Ruby let `let(:big_sur_sdk) { OS::Mac::SDK.new(MacOSVersion.new("11"), "/some/path/MacOSX.sdk", :clt) }` at line 7.
pub fn ruby_sdk_spec_l7_d2_big_sur_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('big_sur_sdk', ...args)
}

// Ruby let `let(:catalina_sdk) { OS::Mac::SDK.new(MacOSVersion.new("10.15"), "/some/path/MacOSX10.15.sdk", :clt) }` at line 8.
pub fn ruby_sdk_spec_l8_d3_catalina_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('catalina_sdk', ...args)
}

// Ruby specify `specify "#sdk_for" do` at line 10.
pub fn ruby_sdk_spec_l10_d4_sdk_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#sdk_for', ...args)
}

// Ruby it `it "returns the requested SDK" do` at line 24.
pub fn ruby_sdk_spec_l24_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the latest SDK if the requested version is not found" do` at line 29.
pub fn ruby_sdk_spec_l29_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the SDK matching the OS version if no version is specified" do` at line 34.
pub fn ruby_sdk_spec_l34_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the latest SDK on older OS versions when there's no matching SDK" do` at line 39.
pub fn ruby_sdk_spec_l39_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil if the OS is newer than all SDKs" do` at line 44.
pub fn ruby_sdk_spec_l44_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:big_sur_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/big_sur" }` at line 51.
pub fn ruby_sdk_spec_l51_d10_big_sur_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('big_sur_sdk_prefix', ...args)
}

// Ruby let `let(:malformed_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/malformed" }` at line 52.
pub fn ruby_sdk_spec_l52_d11_malformed_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('malformed_sdk_prefix', ...args)
}

// Ruby it `it "reads the SDKSettings.json version of unversioned SDKs folders" do` at line 54.
pub fn ruby_sdk_spec_l54_d12_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "rejects malformed sdks" do` at line 66.
pub fn ruby_sdk_spec_l66_d13_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe OS::Mac::CLTSDKLocator do
// 5:   subject(:locator) { described_class.new }
// 6:
// 7:   let(:big_sur_sdk) { OS::Mac::SDK.new(MacOSVersion.new("11"), "/some/path/MacOSX.sdk", :clt) }
// 8:   let(:catalina_sdk) { OS::Mac::SDK.new(MacOSVersion.new("10.15"), "/some/path/MacOSX10.15.sdk", :clt) }
// 9:
// 10:   specify "#sdk_for" do
// 11:     allow(locator).to receive(:all_sdks).and_return([big_sur_sdk, catalina_sdk])
// 12:
// 13:     expect(locator.sdk_for(MacOSVersion.new("11"))).to eq(big_sur_sdk)
// 14:     expect(locator.sdk_for(MacOSVersion.new("10.15"))).to eq(catalina_sdk)
// 15:     expect { locator.sdk_for(MacOSVersion.new("10.14")) }
// 16:       .to raise_error { |e| expect(e.class.name).to eq("OS::Mac::BaseSDKLocator::NoSDKError") }
// 17:   end
// 18:
// 19:   describe "#sdk_if_applicable" do
// 20:     before do
// 21:       allow(locator).to receive(:all_sdks).and_return([big_sur_sdk, catalina_sdk])
// 22:     end
// 23:
// 24:     it "returns the requested SDK" do
// 25:       expect(locator.sdk_if_applicable(MacOSVersion.new("11"))).to eq(big_sur_sdk)
// 26:       expect(locator.sdk_if_applicable(MacOSVersion.new("10.15"))).to eq(catalina_sdk)
// 27:     end
// 28:
// 29:     it "returns the latest SDK if the requested version is not found" do
// 30:       expect(locator.sdk_if_applicable(MacOSVersion.new("10.14"))).to eq(big_sur_sdk)
// 31:       expect(locator.sdk_if_applicable(MacOSVersion.new("12"))).to eq(big_sur_sdk)
// 32:     end
// 33:
// 34:     it "returns the SDK matching the OS version if no version is specified" do
// 35:       allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new("10.15"))
// 36:       expect(locator.sdk_if_applicable).to eq(catalina_sdk)
// 37:     end
// 38:
// 39:     it "returns the latest SDK on older OS versions when there's no matching SDK" do
// 40:       allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new("10.14"))
// 41:       expect(locator.sdk_if_applicable).to eq(big_sur_sdk)
// 42:     end
// 43:
// 44:     it "returns nil if the OS is newer than all SDKs" do
// 45:       allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new("12"))
// 46:       expect(locator.sdk_if_applicable).to be_nil
// 47:     end
// 48:   end
// 49:
// 50:   describe "#all_sdks" do
// 51:     let(:big_sur_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/big_sur" }
// 52:     let(:malformed_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/malformed" }
// 53:
// 54:     it "reads the SDKSettings.json version of unversioned SDKs folders" do
// 55:       allow(locator).to receive(:sdk_prefix).and_return(big_sur_sdk_prefix.to_s)
// 56:
// 57:       sdks = locator.all_sdks
// 58:       expect(sdks.count).to eq(1)
// 59:
// 60:       sdk = sdks.first
// 61:       expect(sdk.path).to eq(big_sur_sdk_prefix/"MacOSX.sdk")
// 62:       expect(sdk.version).to eq(MacOSVersion.new("11"))
// 63:       expect(sdk.source).to eq(:clt)
// 64:     end
// 65:
// 66:     it "rejects malformed sdks" do
// 67:       allow(locator).to receive(:sdk_prefix).and_return(malformed_sdk_prefix.to_s)
// 68:
// 69:       expect(locator.all_sdks).to be_empty
// 70:     end
// 71:   end
// 72: end
