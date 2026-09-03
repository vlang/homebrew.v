module mac

import homebrew.os.mac as sdk
import os

fn sdk_spec_locator() &sdk.SdkLocator {
	mut locator := sdk.new_sdk_locator('', 'clt')
	locator.loaded = true
	locator.sdks = [
		sdk.MacSdk{ version: '11', path: '/some/path/MacOSX.sdk', source: 'clt' },
		sdk.MacSdk{ version: '10.15', path: '/some/path/MacOSX10.15.sdk', source: 'clt' },
	]
	return locator
}

// Translated from Homebrew/brew `test/os/mac/sdk_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:locator) { described_class.new }` at line 5.
pub fn ruby_sdk_spec_l5_d1_locator() &sdk.SdkLocator {
	return sdk_spec_locator()
}

// Ruby let `let(:big_sur_sdk) { OS::Mac::SDK.new(MacOSVersion.new("11"), "/some/path/MacOSX.sdk", :clt) }` at line 7.
pub fn ruby_sdk_spec_l7_d2_big_sur_sdk() sdk.MacSdk {
	return sdk.MacSdk{ version: '11', path: '/some/path/MacOSX.sdk', source: 'clt' }
}

// Ruby let `let(:catalina_sdk) { OS::Mac::SDK.new(MacOSVersion.new("10.15"), "/some/path/MacOSX10.15.sdk", :clt) }` at line 8.
pub fn ruby_sdk_spec_l8_d3_catalina_sdk() sdk.MacSdk {
	return sdk.MacSdk{ version: '10.15', path: '/some/path/MacOSX10.15.sdk', source: 'clt' }
}

// Ruby specify `specify "#sdk_for" do` at line 10.
pub fn ruby_sdk_spec_l10_d4_sdk_for() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_for('11') or { return false } == ruby_sdk_spec_l7_d2_big_sur_sdk() && locator.sdk_for('10.15') or { return false } == ruby_sdk_spec_l8_d3_catalina_sdk() && if _ := locator.sdk_for('10.14') {
		false
	} else {
		err.msg().contains('NoSDKError')
	}
}

// Ruby it `it "returns the requested SDK" do` at line 24.
pub fn ruby_sdk_spec_l24_d5_returns() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_if_applicable('11', '15') or { return false } == ruby_sdk_spec_l7_d2_big_sur_sdk() && locator.sdk_if_applicable('10.15', '15') or { return false } == ruby_sdk_spec_l8_d3_catalina_sdk()
}

// Ruby it `it "returns the latest SDK if the requested version is not found" do` at line 29.
pub fn ruby_sdk_spec_l29_d6_returns() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_if_applicable('10.14', '15') or { return false } == ruby_sdk_spec_l7_d2_big_sur_sdk() && locator.sdk_if_applicable('12', '15') or { return false } == ruby_sdk_spec_l7_d2_big_sur_sdk()
}

// Ruby it `it "returns the SDK matching the OS version if no version is specified" do` at line 34.
pub fn ruby_sdk_spec_l34_d7_returns() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_if_applicable('', '10.15') or { return false } == ruby_sdk_spec_l8_d3_catalina_sdk()
}

// Ruby it `it "returns the latest SDK on older OS versions when there's no matching SDK" do` at line 39.
pub fn ruby_sdk_spec_l39_d8_returns() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_if_applicable('', '10.14') or { return false } == ruby_sdk_spec_l7_d2_big_sur_sdk()
}

// Ruby it `it "returns nil if the OS is newer than all SDKs" do` at line 44.
pub fn ruby_sdk_spec_l44_d9_returns() bool {
	mut locator := sdk_spec_locator()
	return locator.sdk_if_applicable('', '12') == none
}

// Ruby let `let(:big_sur_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/big_sur" }` at line 51.
pub fn ruby_sdk_spec_l51_d10_big_sur_sdk_prefix() string {
	return os.join_path(os.temp_dir(), 'brew-v-sdk-big-sur-${os.getpid()}')
}

// Ruby let `let(:malformed_sdk_prefix) { TEST_FIXTURE_DIR/"sdks/malformed" }` at line 52.
pub fn ruby_sdk_spec_l52_d11_malformed_sdk_prefix() string {
	return os.join_path(os.temp_dir(), 'brew-v-sdk-malformed-${os.getpid()}')
}

// Ruby it `it "reads the SDKSettings.json version of unversioned SDKs folders" do` at line 54.
pub fn ruby_sdk_spec_l54_d12_reads() !bool {
	prefix := ruby_sdk_spec_l51_d10_big_sur_sdk_prefix()
	path := os.join_path(prefix, 'MacOSX.sdk')
	os.mkdir_all(path)!
	defer { os.rmdir_all(prefix) or {} }
	os.write_file(os.join_path(path, 'SDKSettings.json'), '{"Version":"11.0"}')!
	mut locator := sdk.new_sdk_locator(prefix, 'clt')
	sdks := locator.all_sdks()
	return sdks.len == 1 && sdks[0] == sdk.MacSdk{ version: '11', path: path, source: 'clt' }
}

// Ruby it `it "rejects malformed sdks" do` at line 66.
pub fn ruby_sdk_spec_l66_d13_rejects() !bool {
	prefix := ruby_sdk_spec_l52_d11_malformed_sdk_prefix()
	path := os.join_path(prefix, 'MacOSX.sdk')
	os.mkdir_all(path)!
	defer { os.rmdir_all(prefix) or {} }
	os.write_file(os.join_path(path, 'SDKSettings.json'), '{"Version":"malformed"}')!
	mut locator := sdk.new_sdk_locator(prefix, 'clt')
	return locator.all_sdks().len == 0
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
