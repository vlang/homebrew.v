module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/diagnostic_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:checks) { described_class.new }` at line 7.
pub fn ruby_diagnostic_spec_l7_d1_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby specify `specify "#check_for_unsupported_macos" do` at line 9.
pub fn ruby_diagnostic_spec_l9_d2_check_for_unsupported_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_for_unsupported_macos', ...args)
}

// Ruby let `let(:macos_version) { MacOSVersion.new("13") }` at line 21.
pub fn ruby_diagnostic_spec_l21_d3_macos_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_version', ...args)
}

// Ruby it `it "reports Tier 2 on a modern CPU running a supported macOS" do` at line 34.
pub fn ruby_diagnostic_spec_l34_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports Tier 3 on an old CPU" do` at line 41.
pub fn ruby_diagnostic_spec_l41_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports Tier 3 on a modern CPU running an outdated macOS" do` at line 48.
pub fn ruby_diagnostic_spec_l48_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby specify `specify "#check_if_xcode_needs_clt_installed" do` at line 56.
pub fn ruby_diagnostic_spec_l56_d7_check_if_xcode_needs_clt_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_if_xcode_needs_clt_installed', ...args)
}

// Ruby it `it "doesn't require developer tools on Apple Silicon" do` at line 66.
pub fn ruby_diagnostic_spec_l66_d8_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "requires developer tools on Intel" do` at line 72.
pub fn ruby_diagnostic_spec_l72_d9_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "requires developer tools" do` at line 80.
pub fn ruby_diagnostic_spec_l80_d10_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "warns about missing developer tools" do` at line 86.
pub fn ruby_diagnostic_spec_l86_d11_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby let `let(:macos_version) { MacOSVersion.new("11") }` at line 92.
pub fn ruby_diagnostic_spec_l92_d12_macos_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_version', ...args)
}

// Ruby it `it "doesn't trigger when a valid SDK is present" do` at line 101.
pub fn ruby_diagnostic_spec_l101_d13_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "triggers when a valid SDK is not present on CLT systems" do` at line 109.
pub fn ruby_diagnostic_spec_l109_d14_triggers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('triggers', ...args)
}

// Ruby it `it "triggers when a valid SDK is not present on Xcode systems" do` at line 116.
pub fn ruby_diagnostic_spec_l116_d15_triggers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('triggers', ...args)
}

// Ruby it `it "doesn't trigger when SDK versions are as expected" do` at line 125.
pub fn ruby_diagnostic_spec_l125_d16_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "triggers when the CLT SDK version doesn't match the folder name" do` at line 135.
pub fn ruby_diagnostic_spec_l135_d17_triggers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('triggers', ...args)
}

// Ruby it `it "triggers when the Xcode SDK version doesn't match the folder name" do` at line 144.
pub fn ruby_diagnostic_spec_l144_d18_triggers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('triggers', ...args)
}

// Ruby let `let(:pkg_config_formula) { instance_double(Formula, any_version_installed?: true) }` at line 156.
pub fn ruby_diagnostic_spec_l156_d19_pkg_config_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkg_config_formula', ...args)
}

// Ruby let `let(:tab) { instance_double(Tab, built_on: { "os_version" => "13" }) }` at line 157.
pub fn ruby_diagnostic_spec_l157_d20_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby it `it "doesn't trigger when pkgconf is not installed" do` at line 164.
pub fn ruby_diagnostic_spec_l164_d21_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "doesn't trigger when no versions are installed" do` at line 170.
pub fn ruby_diagnostic_spec_l170_d22_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "doesn't trigger when built_on information is missing" do` at line 176.
pub fn ruby_diagnostic_spec_l176_d23_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "doesn't trigger when os_version information is missing" do` at line 182.
pub fn ruby_diagnostic_spec_l182_d24_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "doesn't trigger when versions match" do` at line 188.
pub fn ruby_diagnostic_spec_l188_d25_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "triggers when built_on version differs from current macOS version" do` at line 195.
pub fn ruby_diagnostic_spec_l195_d26_triggers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('triggers', ...args)
}

// Ruby it `it "returns nil when quarantine is available" do` at line 204.
pub fn ruby_diagnostic_spec_l204_d27_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns error when xattr is broken" do` at line 209.
pub fn ruby_diagnostic_spec_l209_d28_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns error for an unknown status" do` at line 215.
pub fn ruby_diagnostic_spec_l215_d29_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic"
// 5:
// 6: RSpec.describe Homebrew::Diagnostic::Checks do
// 7:   subject(:checks) { described_class.new }
// 8:
// 9:   specify "#check_for_unsupported_macos" do
// 10:     ENV.delete("HOMEBREW_DEVELOPER")
// 11:
// 12:     macos_version = MacOSVersion.new("30")
// 13:     allow(OS::Mac).to receive_messages(version: macos_version, full_version: macos_version)
// 14:     allow(OS::Mac.version).to receive_messages(outdated_release?: false, prerelease?: true)
// 15:
// 16:     expect(checks.check_for_unsupported_macos&.to_s)
// 17:       .to match("We do not provide support for this pre-release version.")
// 18:   end
// 19:
// 20:   describe "#check_for_opencore" do
// 21:     let(:macos_version) { MacOSVersion.new("13") }
// 22:
// 23:     before do
// 24:       allow(OS::Mac).to receive_messages(version: macos_version, full_version: macos_version)
// 25:       allow(Hardware::CPU).to receive(:physical_cpu_arm64?).and_return(false)
// 26:       allow(Utils).to receive(:safe_popen_read)
// 27:         .with("/usr/sbin/nvram", "4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version")
// 28:         .and_return("opencore-version\t1.0.0")
// 29:       allow(Utils).to receive(:safe_popen_read)
// 30:         .with("/usr/sbin/nvram", "4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:OCLP-Version")
// 31:         .and_return("OCLP-Version\t2.0.0")
// 32:     end
// 33:
// 34:     it "reports Tier 2 on a modern CPU running a supported macOS" do
// 35:       allow(Hardware::CPU).to receive(:features).and_return([:pclmulqdq])
// 36:       allow(macos_version).to receive(:outdated_release?).and_return(false)
// 37:
// 38:       expect(checks.check_for_opencore&.tier).to eq 2
// 39:     end
// 40:
// 41:     it "reports Tier 3 on an old CPU" do
// 42:       allow(Hardware::CPU).to receive(:features).and_return([])
// 43:       allow(macos_version).to receive(:outdated_release?).and_return(false)
// 44:
// 45:       expect(checks.check_for_opencore&.tier).to eq 3
// 46:     end
// 47:
// 48:     it "reports Tier 3 on a modern CPU running an outdated macOS" do
// 49:       allow(Hardware::CPU).to receive(:features).and_return([:pclmulqdq])
// 50:       allow(macos_version).to receive(:outdated_release?).and_return(true)
// 51:
// 52:       expect(checks.check_for_opencore&.tier).to eq 3
// 53:     end
// 54:   end
// 55:
// 56:   specify "#check_if_xcode_needs_clt_installed" do
// 57:     macos_version = MacOSVersion.new("11")
// 58:     allow(OS::Mac).to receive_messages(version: macos_version, full_version: macos_version)
// 59:     allow(OS::Mac::Xcode).to receive_messages(installed?: true, version: "8.0", without_clt?: true)
// 60:
// 61:     expect(checks.check_if_xcode_needs_clt_installed&.to_s)
// 62:       .to match("Xcode alone is not sufficient on Big Sur")
// 63:   end
// 64:
// 65:   describe "#fatal_preinstall_checks" do
// 66:     it "doesn't require developer tools on Apple Silicon" do
// 67:       allow(Hardware::CPU).to receive(:arm?).and_return(true)
// 68:
// 69:       expect(checks.fatal_preinstall_checks).not_to include("check_for_installed_developer_tools")
// 70:     end
// 71:
// 72:     it "requires developer tools on Intel" do
// 73:       allow(Hardware::CPU).to receive(:arm?).and_return(false)
// 74:
// 75:       expect(checks.fatal_preinstall_checks).to include("check_for_installed_developer_tools")
// 76:     end
// 77:   end
// 78:
// 79:   describe "#fatal_build_from_source_checks" do
// 80:     it "requires developer tools" do
// 81:       expect(checks.fatal_build_from_source_checks).to include("check_for_installed_developer_tools")
// 82:     end
// 83:   end
// 84:
// 85:   describe "#build_from_source_checks" do
// 86:     it "warns about missing developer tools" do
// 87:       expect(checks.build_from_source_checks).to include("check_for_installed_developer_tools")
// 88:     end
// 89:   end
// 90:
// 91:   describe "#check_if_supported_sdk_available" do
// 92:     let(:macos_version) { MacOSVersion.new("11") }
// 93:
// 94:     before do
// 95:       allow(DevelopmentTools).to receive(:installed?).and_return(true)
// 96:       allow(OS::Mac).to receive(:version).and_return(macos_version)
// 97:       allow(OS::Mac::CLT).to receive(:below_minimum_version?).and_return(false)
// 98:       allow(OS::Mac::Xcode).to receive(:below_minimum_version?).and_return(false)
// 99:     end
// 100:
// 101:     it "doesn't trigger when a valid SDK is present" do
// 102:       allow(OS::Mac).to receive_messages(sdk: OS::Mac::SDK.new(
// 103:         macos_version, "/some/path/MacOSX.sdk", :clt
// 104:       ))
// 105:
// 106:       expect(checks.check_if_supported_sdk_available&.to_s).to be_nil
// 107:     end
// 108:
// 109:     it "triggers when a valid SDK is not present on CLT systems" do
// 110:       allow(OS::Mac).to receive_messages(sdk: nil, sdk_locator: OS::Mac::CLT.sdk_locator)
// 111:
// 112:       expect(checks.check_if_supported_sdk_available&.to_s)
// 113:         .to include("Your Command Line Tools (CLT) does not support macOS #{macos_version}")
// 114:     end
// 115:
// 116:     it "triggers when a valid SDK is not present on Xcode systems" do
// 117:       allow(OS::Mac).to receive_messages(sdk: nil, sdk_locator: OS::Mac::Xcode.sdk_locator)
// 118:
// 119:       expect(checks.check_if_supported_sdk_available&.to_s)
// 120:         .to include("Your Xcode does not support macOS #{macos_version}")
// 121:     end
// 122:   end
// 123:
// 124:   describe "#check_broken_sdks" do
// 125:     it "doesn't trigger when SDK versions are as expected" do
// 126:       allow(OS::Mac).to receive(:sdk_locator).and_return(OS::Mac::CLT.sdk_locator)
// 127:       allow_any_instance_of(OS::Mac::CLTSDKLocator).to receive(:all_sdks).and_return([
// 128:         OS::Mac::SDK.new(MacOSVersion.new("11"), "/some/path/MacOSX.sdk", :clt),
// 129:         OS::Mac::SDK.new(MacOSVersion.new("10.15"), "/some/path/MacOSX10.15.sdk", :clt),
// 130:       ])
// 131:
// 132:       expect(checks.check_broken_sdks&.to_s).to be_nil
// 133:     end
// 134:
// 135:     it "triggers when the CLT SDK version doesn't match the folder name" do
// 136:       allow_any_instance_of(OS::Mac::CLTSDKLocator).to receive(:all_sdks).and_return([
// 137:         OS::Mac::SDK.new(MacOSVersion.new("10.14"), "/some/path/MacOSX10.15.sdk", :clt),
// 138:       ])
// 139:
// 140:       expect(checks.check_broken_sdks&.to_s)
// 141:         .to include("SDKs in your Command Line Tools (CLT) installation do not match the SDK folder names")
// 142:     end
// 143:
// 144:     it "triggers when the Xcode SDK version doesn't match the folder name" do
// 145:       allow(OS::Mac).to receive(:sdk_locator).and_return(OS::Mac::Xcode.sdk_locator)
// 146:       allow_any_instance_of(OS::Mac::XcodeSDKLocator).to receive(:all_sdks).and_return([
// 147:         OS::Mac::SDK.new(MacOSVersion.new("10.14"), "/some/path/MacOSX10.15.sdk", :xcode),
// 148:       ])
// 149:
// 150:       expect(checks.check_broken_sdks&.to_s)
// 151:         .to include("The contents of the SDKs in your Xcode installation do not match the SDK folder names")
// 152:     end
// 153:   end
// 154:
// 155:   describe "#check_pkgconf_macos_sdk_mismatch" do
// 156:     let(:pkg_config_formula) { instance_double(Formula, any_version_installed?: true) }
// 157:     let(:tab) { instance_double(Tab, built_on: { "os_version" => "13" }) }
// 158:
// 159:     before do
// 160:       allow(Formula).to receive(:[]).with("pkgconf").and_return(pkg_config_formula)
// 161:       allow(Tab).to receive(:for_formula).with(pkg_config_formula).and_return(tab)
// 162:     end
// 163:
// 164:     it "doesn't trigger when pkgconf is not installed" do
// 165:       allow(Formula).to receive(:[]).with("pkgconf").and_raise(FormulaUnavailableError.new("pkgconf"))
// 166:
// 167:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to be_nil
// 168:     end
// 169:
// 170:     it "doesn't trigger when no versions are installed" do
// 171:       allow(pkg_config_formula).to receive(:any_version_installed?).and_return(false)
// 172:
// 173:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to be_nil
// 174:     end
// 175:
// 176:     it "doesn't trigger when built_on information is missing" do
// 177:       allow(tab).to receive(:built_on).and_return(nil)
// 178:
// 179:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to be_nil
// 180:     end
// 181:
// 182:     it "doesn't trigger when os_version information is missing" do
// 183:       allow(tab).to receive(:built_on).and_return({ "cpu_family" => "x86_64" })
// 184:
// 185:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to be_nil
// 186:     end
// 187:
// 188:     it "doesn't trigger when versions match" do
// 189:       current_version = MacOS.version.to_s
// 190:       allow(tab).to receive(:built_on).and_return({ "os_version" => current_version })
// 191:
// 192:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to be_nil
// 193:     end
// 194:
// 195:     it "triggers when built_on version differs from current macOS version" do
// 196:       allow(MacOS).to receive(:version).and_return(MacOSVersion.new("14"))
// 197:       allow(tab).to receive(:built_on).and_return({ "os_version" => "13" })
// 198:
// 199:       expect(checks.check_pkgconf_macos_sdk_mismatch&.to_s).to include("brew reinstall pkgconf")
// 200:     end
// 201:   end
// 202:
// 203:   describe "#check_cask_quarantine_support" do
// 204:     it "returns nil when quarantine is available" do
// 205:       allow(Cask::Quarantine).to receive(:check_quarantine_support).and_return([:quarantine_available, nil])
// 206:       expect(checks.check_cask_quarantine_support&.to_s).to be_nil
// 207:     end
// 208:
// 209:     it "returns error when xattr is broken" do
// 210:       allow(Cask::Quarantine).to receive(:check_quarantine_support).and_return([:xattr_broken, nil])
// 211:       expect(checks.check_cask_quarantine_support&.to_s)
// 212:         .to match("there's no working version of `xattr` on this system")
// 213:     end
// 214:
// 215:     it "returns error for an unknown status" do
// 216:       allow(Cask::Quarantine).to receive(:check_quarantine_support).and_return([:unknown, "whoopsie"])
// 217:       expect(checks.check_cask_quarantine_support&.to_s)
// 218:         .to match("whoopsie")
// 219:     end
// 220:   end
// 221: end
