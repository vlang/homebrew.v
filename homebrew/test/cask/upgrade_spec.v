module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/upgrade_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:version_latest_paths) do` at line 7.
pub fn ruby_upgrade_spec_l7_d1_version_latest_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_latest_paths', ...args)
}

// Ruby let `let(:version_latest) { Cask::CaskLoader.load("version-latest") }` at line 13.
pub fn ruby_upgrade_spec_l13_d2_version_latest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_latest', ...args)
}

// Ruby let `let(:auto_updates_path) { Pathname(auto_updates.config.appdir).join("MyFancyApp.app") }` at line 14.
pub fn ruby_upgrade_spec_l14_d3_auto_updates_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('auto_updates_path', ...args)
}

// Ruby let `let(:auto_updates) { Cask::CaskLoader.load("auto-updates") }` at line 15.
pub fn ruby_upgrade_spec_l15_d4_auto_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('auto_updates', ...args)
}

// Ruby let `let(:local_transmission_path) { Pathname(local_transmission.config.appdir).join("Transmission.app") }` at line 16.
pub fn ruby_upgrade_spec_l16_d5_local_transmission_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_transmission_path', ...args)
}

// Ruby let `let(:local_transmission) { Cask::CaskLoader.load("local-transmission-zip") }` at line 17.
pub fn ruby_upgrade_spec_l17_d6_local_transmission(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_transmission', ...args)
}

// Ruby let `let(:local_caffeine_path) { Pathname(local_caffeine.config.appdir).join("Caffeine.app") }` at line 18.
pub fn ruby_upgrade_spec_l18_d7_local_caffeine_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_caffeine_path', ...args)
}

// Ruby let `let(:local_caffeine) { Cask::CaskLoader.load("local-caffeine") }` at line 19.
pub fn ruby_upgrade_spec_l19_d8_local_caffeine(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_caffeine', ...args)
}

// Ruby let `let(:renamed_app) { Cask::CaskLoader.load("renamed-app") }` at line 20.
pub fn ruby_upgrade_spec_l20_d9_renamed_app(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('renamed_app', ...args)
}

// Ruby let `let(:renamed_app_old_path) { Pathname(renamed_app.config.appdir).join("OldApp.app") }` at line 21.
pub fn ruby_upgrade_spec_l21_d10_renamed_app_old_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('renamed_app_old_path', ...args)
}

// Ruby let `let(:renamed_app_new_path) { Pathname(renamed_app.config.appdir).join("NewApp.app") }` at line 22.
pub fn ruby_upgrade_spec_l22_d11_renamed_app_new_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('renamed_app_new_path', ...args)
}

// Ruby let `let(:args) do` at line 23.
pub fn ruby_upgrade_spec_l23_d12_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby method `write_info_plist(path, short_version:, bundle_version:)` at line 29.
pub fn ruby_upgrade_spec_l29_d13_write_info_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_info_plist', ...args)
}

// Ruby it `it "warns and excludes casks with no version for the current platform" do` at line 50.
pub fn ruby_upgrade_spec_l50_d14_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it 'includes "auto_updates true" casks when the installed bundle version is older than the tap version' do` at line 83.
pub fn ruby_upgrade_spec_l83_d15_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it 'excludes "auto_updates true" casks when HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS is set' do` at line 125.
pub fn ruby_upgrade_spec_l125_d16_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "lets HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS override HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS" do` at line 144.
pub fn ruby_upgrade_spec_l144_d17_lets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lets', ...args)
}

// Ruby it `it "lets HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS override the developer default" do` at line 156.
pub fn ruby_upgrade_spec_l156_d18_lets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lets', ...args)
}

// Ruby it `it 'excludes "auto_updates true" casks when the installed bundle matches the tap version' do` at line 169.
pub fn ruby_upgrade_spec_l169_d19_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "records final cask upgrade summary details" do` at line 186.
pub fn ruby_upgrade_spec_l186_d20_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "passes the quit option to cask upgrades" do` at line 204.
pub fn ruby_upgrade_spec_l204_d21_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Ruby it `it "excludes pinned Casks" do` at line 218.
pub fn ruby_upgrade_spec_l218_d22_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "fails and skips explicitly named pinned Casks" do` at line 241.
pub fn ruby_upgrade_spec_l241_d23_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "would update only the Casks specified in the command line" do` at line 258.
pub fn ruby_upgrade_spec_l258_d24_would(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('would', ...args)
}

// Ruby it `it 'would update "auto_updates" and "latest" Casks when their tokens are provided in the command line' do` at line 282.
pub fn ruby_upgrade_spec_l282_d25_would(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('would', ...args)
}

// Ruby it `it 'would include the Casks with "auto_updates true" or "version latest"' do` at line 318.
pub fn ruby_upgrade_spec_l318_d26_would(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('would', ...args)
}

// Ruby it `it 'would update outdated Casks with "auto_updates true"' do` at line 366.
pub fn ruby_upgrade_spec_l366_d27_would(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('would', ...args)
}

// Ruby it `it 'would update outdated Casks with "version latest"' do` at line 382.
pub fn ruby_upgrade_spec_l382_d28_would(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('would', ...args)
}

// Ruby it `it "recovers when the installed caskfile raises CaskInvalidError" do` at line 417.
pub fn ruby_upgrade_spec_l417_d29_recovers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recovers', ...args)
}

// Ruby it `it "warns and skips when the installed caskfile raises CaskUnreadableError" do` at line 433.
pub fn ruby_upgrade_spec_l433_d30_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "warns and skips when the installed caskfile raises MethodDeprecatedError" do` at line 445.
pub fn ruby_upgrade_spec_l445_d31_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "warns and skips when the cask is not fully installed" do` at line 457.
pub fn ruby_upgrade_spec_l457_d32_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby let `let(:outdated_auto_updates) { Cask::CaskLoader.load(cask_path("outdated/auto-updates")) }` at line 473.
pub fn ruby_upgrade_spec_l473_d33_outdated_auto_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_auto_updates', ...args)
}

// Ruby let `let(:outdated_local_caffeine) { Cask::CaskLoader.load(cask_path("outdated/local-caffeine")) }` at line 474.
pub fn ruby_upgrade_spec_l474_d34_outdated_local_caffeine(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_local_caffeine', ...args)
}

// Ruby let `let(:auto_updates_identity) do` at line 475.
pub fn ruby_upgrade_spec_l475_d35_auto_updates_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('auto_updates_identity', ...args)
}

// Ruby let `let(:local_caffeine_identity) do` at line 480.
pub fn ruby_upgrade_spec_l480_d36_local_caffeine_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_caffeine_identity', ...args)
}

// Ruby it `it 'prefetches "auto_updates true" casks with quarantine until signed identity is checked' do` at line 495.
pub fn ruby_upgrade_spec_l495_d37_prefetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefetches', ...args)
}

// Ruby it `it "releases quarantine when Gatekeeper was already approved and identity matches" do` at line 508.
pub fn ruby_upgrade_spec_l508_d38_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('releases', ...args)
}

// Ruby it `it "reports a changed signer when the new app does not satisfy the old designated requirement" do` at line 520.
pub fn ruby_upgrade_spec_l520_d39_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an unverified signer when the old signing identity is missing" do` at line 532.
pub fn ruby_upgrade_spec_l532_d40_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an unverified signer when the new signing identity is missing" do` at line 541.
pub fn ruby_upgrade_spec_l541_d41_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports missing approval when Gatekeeper was not approved" do` at line 553.
pub fn ruby_upgrade_spec_l553_d42_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "releases quarantine for casks without auto_updates when Gatekeeper was already approved " \` at line 562.
pub fn ruby_upgrade_spec_l562_d43_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('releases', ...args)
}

// Ruby it `it "reports missing approval for casks without auto_updates when Gatekeeper was not approved" do` at line 575.
pub fn ruby_upgrade_spec_l575_d44_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "inherits quarantine approval when the previous version was already approved" do` at line 591.
pub fn ruby_upgrade_spec_l591_d45_inherits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherits', ...args)
}

// Ruby it `it "continues the upgrade when quarantine approval cannot be inherited" do` at line 604.
pub fn ruby_upgrade_spec_l604_d46_continues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('continues', ...args)
}

// Ruby it `it "reports the skipped quarantine release under --verbose when approval is missing" do` at line 619.
pub fn ruby_upgrade_spec_l619_d47_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports a changed signer by default so the returning Gatekeeper prompt is explained" do` at line 627.
pub fn ruby_upgrade_spec_l627_d48_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an unverified signer by default so the returning Gatekeeper prompt is explained" do` at line 641.
pub fn ruby_upgrade_spec_l641_d49_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "warns and skips disabled casks" do` at line 656.
pub fn ruby_upgrade_spec_l656_d50_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "uses the installed metadata version for the second upgrade" do` at line 675.
pub fn ruby_upgrade_spec_l675_d51_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "uses the forced upgrade metadata for the next upgrade" do` at line 700.
pub fn ruby_upgrade_spec_l700_d52_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "keeps the old cask receipt" do` at line 742.
pub fn ruby_upgrade_spec_l742_d53_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby let `let(:output_reverted) do` at line 770.
pub fn ruby_upgrade_spec_l770_d54_output_reverted(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_reverted', ...args)
}

// Ruby it `it "restores the old Cask if the upgrade failed" do` at line 776.
pub fn ruby_upgrade_spec_l776_d55_restores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restores', ...args)
}

// Ruby it `it "does not restore the old Cask if the upgrade failed pre-install" do` at line 794.
pub fn ruby_upgrade_spec_l794_d56_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reports the original upgrade error, not a failure that occurs while rolling back" do` at line 812.
pub fn ruby_upgrade_spec_l812_d57_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not end the upgrade process" do` at line 838.
pub fn ruby_upgrade_spec_l838_d58_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "continues upgrading compatible casks" do` at line 899.
pub fn ruby_upgrade_spec_l899_d59_continues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('continues', ...args)
}

// Ruby it `it "reports prefetched requirement errors alongside compatible casks" do` at line 928.
pub fn ruby_upgrade_spec_l928_d60_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/upgrade"
// 5:
// 6: RSpec.describe Cask::Upgrade, :cask do
// 7:   let(:version_latest_paths) do
// 8:     [
// 9:       Pathname(version_latest.config.appdir).join("Caffeine Mini.app"),
// 10:       Pathname(version_latest.config.appdir).join("Caffeine Pro.app"),
// 11:     ]
// 12:   end
// 13:   let(:version_latest) { Cask::CaskLoader.load("version-latest") }
// 14:   let(:auto_updates_path) { Pathname(auto_updates.config.appdir).join("MyFancyApp.app") }
// 15:   let(:auto_updates) { Cask::CaskLoader.load("auto-updates") }
// 16:   let(:local_transmission_path) { Pathname(local_transmission.config.appdir).join("Transmission.app") }
// 17:   let(:local_transmission) { Cask::CaskLoader.load("local-transmission-zip") }
// 18:   let(:local_caffeine_path) { Pathname(local_caffeine.config.appdir).join("Caffeine.app") }
// 19:   let(:local_caffeine) { Cask::CaskLoader.load("local-caffeine") }
// 20:   let(:renamed_app) { Cask::CaskLoader.load("renamed-app") }
// 21:   let(:renamed_app_old_path) { Pathname(renamed_app.config.appdir).join("OldApp.app") }
// 22:   let(:renamed_app_new_path) { Pathname(renamed_app.config.appdir).join("NewApp.app") }
// 23:   let(:args) do
// 24:     parser = Homebrew::CLI::Parser.new(Homebrew::Cmd::Brew)
// 25:     parser.cask_options
// 26:     parser.args
// 27:   end
// 28:
// 29:   def write_info_plist(path, short_version:, bundle_version:)
// 30:     info_plist = path/"Contents/Info.plist"
// 31:     info_plist.dirname.mkpath
// 32:     info_plist.write <<~PLIST
// 33:       <?xml version="1.0" encoding="UTF-8"?>
// 34:       <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 35:       <plist version="1.0">
// 36:       <dict>
// 37:         <key>CFBundleShortVersionString</key>
// 38:         <string>#{short_version}</string>
// 39:         <key>CFBundleVersion</key>
// 40:         <string>#{bundle_version}</string>
// 41:       </dict>
// 42:       </plist>
// 43:     PLIST
// 44:   end
// 45:
// 46:   before do
// 47:     allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_return(true)
// 48:   end
// 49:
// 50:   it "warns and excludes casks with no version for the current platform" do
// 51:     cask = Homebrew::SimulateSystem.with(os: :linux) do
// 52:       Cask::Cask.new("macos-only") do
// 53:         on_macos do
// 54:           version "1.2.3"
// 55:         end
// 56:       end
// 57:     end
// 58:
// 59:     expect do
// 60:       expect(described_class.outdated_casks([cask], args:, force: true, quiet: false)).to be_empty
// 61:     end.to output(/Not upgrading macos-only, no version is available for the current platform/).to_stderr
// 62:   end
// 63:
// 64:   context "when the upgrade is a dry run" do
// 65:     # Use stub installation for dry-run tests since they mock upgrade_cask
// 66:     # and only need to verify installation state, not perform real upgrades.
// 67:     # This avoids downloading and extracting archives, significantly speeding up tests.
// 68:     before do
// 69:       [
// 70:         "outdated/local-caffeine",
// 71:         "outdated/local-transmission-zip",
// 72:         "outdated/auto-updates",
// 73:         "outdated/version-latest",
// 74:         "outdated/renamed-app",
// 75:       ].each do |cask_name|
// 76:         InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path(cask_name)))
// 77:       end
// 78:
// 79:       write_info_plist(auto_updates_path, short_version: "2.57", bundle_version: "2057")
// 80:     end
// 81:
// 82:     describe "without --greedy" do
// 83:       it 'includes "auto_updates true" casks when the installed bundle version is older than the tap version' do
// 84:         expect(described_class).not_to receive(:upgrade_cask)
// 85:         expect(described_class).to receive(:show_upgrade_summary) do |cask_upgrades, dry_run:|
// 86:           expect(dry_run).to be(true)
// 87:           expect(cask_upgrades).to include(
// 88:             "local-caffeine 1.2.2 -> 1.2.3",
// 89:             "local-transmission-zip 2.60 -> 2.61",
// 90:             "auto-updates 2.57 -> 2.61",
// 91:             "renamed-app 1.0.0 -> 2.0.0",
// 92:           )
// 93:           expect(cask_upgrades.grep(/version-latest/)).to be_empty
// 94:         end
// 95:
// 96:         expect(local_caffeine).to be_installed
// 97:         expect(local_caffeine_path).to be_a_directory
// 98:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 99:
// 100:         expect(local_transmission).to be_installed
// 101:         expect(local_transmission_path).to be_a_directory
// 102:         expect(local_transmission.installed_version).to eq "2.60"
// 103:
// 104:         expect(renamed_app).to be_installed
// 105:         expect(renamed_app_old_path).to be_a_directory
// 106:         expect(renamed_app_new_path).not_to be_a_directory
// 107:         expect(renamed_app.installed_version).to eq "1.0.0"
// 108:
// 109:         described_class.upgrade_casks!(dry_run: true, args:)
// 110:
// 111:         expect(local_caffeine).to be_installed
// 112:         expect(local_caffeine_path).to be_a_directory
// 113:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 114:
// 115:         expect(local_transmission).to be_installed
// 116:         expect(local_transmission_path).to be_a_directory
// 117:         expect(local_transmission.installed_version).to eq "2.60"
// 118:
// 119:         expect(renamed_app).to be_installed
// 120:         expect(renamed_app_old_path).to be_a_directory
// 121:         expect(renamed_app_new_path).not_to be_a_directory
// 122:         expect(renamed_app.installed_version).to eq "1.0.0"
// 123:       end
// 124:
// 125:       it 'excludes "auto_updates true" casks when HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS is set' do
// 126:         allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_call_original
// 127:
// 128:         expect(described_class).not_to receive(:upgrade_cask)
// 129:         expect(described_class).to receive(:show_upgrade_summary) do |cask_upgrades, dry_run:|
// 130:           expect(dry_run).to be(true)
// 131:           expect(cask_upgrades).to include(
// 132:             "local-caffeine 1.2.2 -> 1.2.3",
// 133:             "local-transmission-zip 2.60 -> 2.61",
// 134:             "renamed-app 1.0.0 -> 2.0.0",
// 135:           )
// 136:           expect(cask_upgrades.grep(/auto-updates/)).to be_empty
// 137:         end
// 138:
// 139:         with_env(HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS: "1") do
// 140:           described_class.upgrade_casks!(dry_run: true, args:)
// 141:         end
// 142:       end
// 143:
// 144:       it "lets HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS override HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS" do
// 145:         allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_call_original
// 146:
// 147:         with_env(
// 148:           "HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS"    => "1",
// 149:           "HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS" => "1",
// 150:         ) do
// 151:           expect { described_class.upgrade_casks!(dry_run: true, args:) }
// 152:             .not_to raise_error
// 153:         end
// 154:       end
// 155:
// 156:       it "lets HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS override the developer default" do
// 157:         allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_call_original
// 158:
// 159:         with_env(
// 160:           "HOMEBREW_DEVELOPER"                     => "1",
// 161:           "HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS"    => "1",
// 162:           "HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS" => "1",
// 163:         ) do
// 164:           expect { described_class.upgrade_casks!(dry_run: true, args:) }
// 165:             .not_to raise_error
// 166:         end
// 167:       end
// 168:
// 169:       it 'excludes "auto_updates true" casks when the installed bundle matches the tap version' do
// 170:         write_info_plist(auto_updates_path, short_version: "2.61", bundle_version: "2061")
// 171:
// 172:         expect(described_class).not_to receive(:upgrade_cask)
// 173:         expect(described_class).to receive(:show_upgrade_summary) do |cask_upgrades, dry_run:|
// 174:           expect(dry_run).to be(true)
// 175:           expect(cask_upgrades).to include(
// 176:             "local-caffeine 1.2.2 -> 1.2.3",
// 177:             "local-transmission-zip 2.60 -> 2.61",
// 178:             "renamed-app 1.0.0 -> 2.0.0",
// 179:           )
// 180:           expect(cask_upgrades.grep(/auto-updates/)).to be_empty
// 181:         end
// 182:
// 183:         described_class.upgrade_casks!(dry_run: true, args:)
// 184:       end
// 185:
// 186:       it "records final cask upgrade summary details" do
// 187:         summary_upgrades = []
// 188:         summary_deprecated = []
// 189:         allow(local_caffeine).to receive(:deprecated?).and_return(true)
// 190:
// 191:         described_class.upgrade_casks!(
// 192:           local_caffeine,
// 193:           dry_run:              true,
// 194:           show_upgrade_summary: false,
// 195:           summary_upgrades:,
// 196:           summary_deprecated:,
// 197:           args:,
// 198:         )
// 199:
// 200:         expect(summary_upgrades).to include("local-caffeine 1.2.2 -> 1.2.3")
// 201:         expect(summary_deprecated).to include("local-caffeine")
// 202:       end
// 203:
// 204:       it "passes the quit option to cask upgrades" do
// 205:         expect(described_class).to receive(:upgrade_cask) do |_, _, **options|
// 206:           expect(options[:quit]).to be(false)
// 207:         end
// 208:
// 209:         described_class.upgrade_casks!(
// 210:           local_caffeine,
// 211:           quit:                 false,
// 212:           skip_prefetch:        true,
// 213:           show_upgrade_summary: false,
// 214:           args:,
// 215:         )
// 216:       end
// 217:
// 218:       it "excludes pinned Casks" do
// 219:         local_caffeine.pin
// 220:         summary_pinned = []
// 221:
// 222:         begin
// 223:           expect(described_class).not_to receive(:upgrade_cask)
// 224:           expect(described_class).to receive(:show_upgrade_summary) do |cask_upgrades, dry_run:|
// 225:             expect(dry_run).to be(true)
// 226:             expect(cask_upgrades).to include(
// 227:               "local-transmission-zip 2.60 -> 2.61",
// 228:               "auto-updates 2.57 -> 2.61",
// 229:               "renamed-app 1.0.0 -> 2.0.0",
// 230:             )
// 231:             expect(cask_upgrades.grep(/local-caffeine/)).to be_empty
// 232:           end
// 233:
// 234:           described_class.upgrade_casks!(dry_run: true, quiet: true, summary_pinned:, args:)
// 235:           expect(summary_pinned).to include("local-caffeine 1.2.2")
// 236:         ensure
// 237:           local_caffeine.unpin
// 238:         end
// 239:       end
// 240:
// 241:       it "fails and skips explicitly named pinned Casks" do
// 242:         local_caffeine.pin
// 243:
// 244:         begin
// 245:           expect(described_class).not_to receive(:upgrade_cask)
// 246:
// 247:           expect do
// 248:             described_class.upgrade_casks!(local_caffeine, dry_run: true, args:)
// 249:           end.to not_to_output.to_stdout
// 250:              .and output(/Not upgrading 1 pinned package:.*local-caffeine 1\.2\.2/m).to_stderr
// 251:           expect(Homebrew).to be_failed
// 252:         ensure
// 253:           local_caffeine.unpin
// 254:           Homebrew.failed = false
// 255:         end
// 256:       end
// 257:
// 258:       it "would update only the Casks specified in the command line" do
// 259:         expect(described_class).not_to receive(:upgrade_cask)
// 260:         expect(described_class).to receive(:show_upgrade_summary)
// 261:           .with(["local-caffeine 1.2.2 -> 1.2.3"], dry_run: true)
// 262:
// 263:         expect(local_caffeine).to be_installed
// 264:         expect(local_caffeine_path).to be_a_directory
// 265:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 266:
// 267:         expect(local_transmission).to be_installed
// 268:         expect(local_transmission_path).to be_a_directory
// 269:         expect(local_transmission.installed_version).to eq "2.60"
// 270:
// 271:         described_class.upgrade_casks!(local_caffeine, dry_run: true, args:)
// 272:
// 273:         expect(local_caffeine).to be_installed
// 274:         expect(local_caffeine_path).to be_a_directory
// 275:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 276:
// 277:         expect(local_transmission).to be_installed
// 278:         expect(local_transmission_path).to be_a_directory
// 279:         expect(local_transmission.installed_version).to eq "2.60"
// 280:       end
// 281:
// 282:       it 'would update "auto_updates" and "latest" Casks when their tokens are provided in the command line' do
// 283:         expect(described_class).not_to receive(:upgrade_cask)
// 284:         expect(described_class).to receive(:show_upgrade_summary)
// 285:           .with(["local-caffeine 1.2.2 -> 1.2.3", "auto-updates 2.57 -> 2.61"], dry_run: true)
// 286:
// 287:         expect(local_caffeine).to be_installed
// 288:         expect(local_caffeine_path).to be_a_directory
// 289:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 290:
// 291:         expect(auto_updates).to be_installed
// 292:         expect(auto_updates_path).to be_a_directory
// 293:         expect(auto_updates.installed_version).to eq "2.57"
// 294:
// 295:         expect(renamed_app).to be_installed
// 296:         expect(renamed_app_old_path).to be_a_directory
// 297:         expect(renamed_app_new_path).not_to be_a_directory
// 298:         expect(renamed_app.installed_version).to eq "1.0.0"
// 299:
// 300:         described_class.upgrade_casks!(local_caffeine, auto_updates, dry_run: true, args:)
// 301:
// 302:         expect(local_caffeine).to be_installed
// 303:         expect(local_caffeine_path).to be_a_directory
// 304:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 305:
// 306:         expect(auto_updates).to be_installed
// 307:         expect(auto_updates_path).to be_a_directory
// 308:         expect(auto_updates.installed_version).to eq "2.57"
// 309:
// 310:         expect(renamed_app).to be_installed
// 311:         expect(renamed_app_old_path).to be_a_directory
// 312:         expect(renamed_app_new_path).not_to be_a_directory
// 313:         expect(renamed_app.installed_version).to eq "1.0.0"
// 314:       end
// 315:     end
// 316:
// 317:     describe "with --greedy it checks additional Casks" do
// 318:       it 'would include the Casks with "auto_updates true" or "version latest"' do
// 319:         expect(described_class).not_to receive(:upgrade_cask)
// 320:
// 321:         expect(local_caffeine).to be_installed
// 322:         expect(local_caffeine_path).to be_a_directory
// 323:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 324:
// 325:         expect(auto_updates).to be_installed
// 326:         expect(auto_updates_path).to be_a_directory
// 327:         expect(auto_updates.installed_version).to eq "2.57"
// 328:
// 329:         expect(local_transmission).to be_installed
// 330:         expect(local_transmission_path).to be_a_directory
// 331:         expect(local_transmission.installed_version).to eq "2.60"
// 332:
// 333:         expect(renamed_app).to be_installed
// 334:         expect(renamed_app_old_path).to be_a_directory
// 335:         expect(renamed_app_new_path).not_to be_a_directory
// 336:         expect(renamed_app.installed_version).to eq "1.0.0"
// 337:
// 338:         expect(version_latest).to be_installed
// 339:         # Change download sha so that :latest cask decides to update itself
// 340:         version_latest.download_sha_path.write("fake download sha")
// 341:         expect(version_latest.outdated_download_sha?).to be(true)
// 342:
// 343:         described_class.upgrade_casks!(greedy: true, dry_run: true, args:)
// 344:
// 345:         expect(local_caffeine).to be_installed
// 346:         expect(local_caffeine_path).to be_a_directory
// 347:         expect(local_caffeine.installed_version).to eq "1.2.2"
// 348:
// 349:         expect(auto_updates).to be_installed
// 350:         expect(auto_updates_path).to be_a_directory
// 351:         expect(auto_updates.installed_version).to eq "2.57"
// 352:
// 353:         expect(local_transmission).to be_installed
// 354:         expect(local_transmission_path).to be_a_directory
// 355:         expect(local_transmission.installed_version).to eq "2.60"
// 356:
// 357:         expect(renamed_app).to be_installed
// 358:         expect(renamed_app_old_path).to be_a_directory
// 359:         expect(renamed_app_new_path).not_to be_a_directory
// 360:         expect(renamed_app.installed_version).to eq "1.0.0"
// 361:
// 362:         expect(version_latest).to be_installed
// 363:         expect(version_latest.outdated_download_sha?).to be(true)
// 364:       end
// 365:
// 366:       it 'would update outdated Casks with "auto_updates true"' do
// 367:         expect(described_class).not_to receive(:upgrade_cask)
// 368:         expect(described_class).to receive(:show_upgrade_summary)
// 369:           .with(["auto-updates 2.57 -> 2.61"], dry_run: true)
// 370:
// 371:         expect(auto_updates).to be_installed
// 372:         expect(auto_updates_path).to be_a_directory
// 373:         expect(auto_updates.installed_version).to eq "2.57"
// 374:
// 375:         described_class.upgrade_casks!(auto_updates, dry_run: true, greedy: true, args:)
// 376:
// 377:         expect(auto_updates).to be_installed
// 378:         expect(auto_updates_path).to be_a_directory
// 379:         expect(auto_updates.installed_version).to eq "2.57"
// 380:       end
// 381:
// 382:       it 'would update outdated Casks with "version latest"' do
// 383:         expect(described_class).not_to receive(:upgrade_cask)
// 384:         expect(described_class).to receive(:show_upgrade_summary)
// 385:           .with(["version-latest latest -> latest"], dry_run: true)
// 386:
// 387:         expect(version_latest).to be_installed
// 388:         expect(version_latest_paths).to all be_a_directory
// 389:         expect(version_latest.installed_version).to eq "latest"
// 390:         # Change download sha so that :latest cask decides to update itself
// 391:         version_latest.download_sha_path.write("fake download sha")
// 392:         expect(version_latest.outdated_download_sha?).to be(true)
// 393:
// 394:         described_class.upgrade_casks!(version_latest, dry_run: true, greedy: true, args:)
// 395:
// 396:         expect(version_latest).to be_installed
// 397:         expect(version_latest_paths).to all be_a_directory
// 398:         expect(version_latest.installed_version).to eq "latest"
// 399:         expect(version_latest.outdated_download_sha?).to be(true)
// 400:       end
// 401:     end
// 402:   end
// 403:
// 404:   context "when a cask has broken metadata" do
// 405:     before do
// 406:       [
// 407:         "outdated/local-caffeine",
// 408:         "outdated/auto-updates",
// 409:       ].each do |cask_name|
// 410:         InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path(cask_name)))
// 411:       end
// 412:
// 413:       write_info_plist(auto_updates_path, short_version: "2.57", bundle_version: "2057")
// 414:       allow(Cask::CaskLoader).to receive(:recover_from_installed_caskfile).and_return(nil)
// 415:     end
// 416:
// 417:     it "recovers when the installed caskfile raises CaskInvalidError" do
// 418:       allow(Cask::CaskLoader).to receive(:load_from_installed_caskfile).and_call_original
// 419:       allow(Cask::CaskLoader)
// 420:         .to receive(:load_from_installed_caskfile)
// 421:         .with(auto_updates.installed_caskfile)
// 422:         .and_raise(Cask::CaskInvalidError.new(auto_updates.token, "broken DSL"))
// 423:       expect(Cask::CaskLoader)
// 424:         .to receive(:recover_from_installed_caskfile)
// 425:         .with(auto_updates.installed_caskfile, fallback_cask: auto_updates)
// 426:         .and_return(auto_updates)
// 427:
// 428:       expect do
// 429:         described_class.upgrade_casks!(auto_updates, dry_run: true, args:)
// 430:       end.not_to output(/The cask 'auto-updates' cannot be upgraded as-is/).to_stderr
// 431:     end
// 432:
// 433:     it "warns and skips when the installed caskfile raises CaskUnreadableError" do
// 434:       allow(Cask::CaskLoader).to receive(:load_from_installed_caskfile).and_call_original
// 435:       allow(Cask::CaskLoader)
// 436:         .to receive(:load_from_installed_caskfile)
// 437:         .with(auto_updates.installed_caskfile)
// 438:         .and_raise(Cask::CaskUnreadableError.new(auto_updates.token, "syntax error"))
// 439:
// 440:       expect do
// 441:         described_class.upgrade_casks!(dry_run: true, args:)
// 442:       end.to output(/The cask 'auto-updates' cannot be upgraded as-is/).to_stderr
// 443:     end
// 444:
// 445:     it "warns and skips when the installed caskfile raises MethodDeprecatedError" do
// 446:       allow(Cask::CaskLoader).to receive(:load_from_installed_caskfile).and_call_original
// 447:       allow(Cask::CaskLoader)
// 448:         .to receive(:load_from_installed_caskfile)
// 449:         .with(auto_updates.installed_caskfile)
// 450:         .and_raise(MethodDeprecatedError.new)
// 451:
// 452:       expect do
// 453:         described_class.upgrade_casks!(dry_run: true, args:)
// 454:       end.to output(/The cask 'auto-updates' cannot be upgraded as-is/).to_stderr
// 455:     end
// 456:
// 457:     it "warns and skips when the cask is not fully installed" do
// 458:       # Stub installed? to return false after outdated detection
// 459:       # to simulate a cask with a broken metadata directory
// 460:       installed_calls = 0
// 461:       allow(auto_updates).to receive(:installed?) do
// 462:         installed_calls += 1
// 463:         installed_calls <= 1
// 464:       end
// 465:
// 466:       expect do
// 467:         described_class.upgrade_casks!(auto_updates, dry_run: true, args:)
// 468:       end.to output(/The cask 'auto-updates' cannot be upgraded as-is/).to_stderr
// 469:     end
// 470:   end
// 471:
// 472:   context "when releasing quarantine during upgrade" do
// 473:     let(:outdated_auto_updates) { Cask::CaskLoader.load(cask_path("outdated/auto-updates")) }
// 474:     let(:outdated_local_caffeine) { Cask::CaskLoader.load(cask_path("outdated/local-caffeine")) }
// 475:     let(:auto_updates_identity) do
// 476:       Cask::Quarantine::SigningIdentity.new(
// 477:         requirement: 'identifier "sh.brew.auto-updates" and certificate leaf[subject.OU] = "ABCDE12345"',
// 478:       )
// 479:     end
// 480:     let(:local_caffeine_identity) do
// 481:       Cask::Quarantine::SigningIdentity.new(
// 482:         requirement: 'identifier "sh.brew.local-caffeine" and certificate leaf[subject.OU] = "ABCDE12345"',
// 483:       )
// 484:     end
// 485:
// 486:     before do
// 487:       [
// 488:         "outdated/local-caffeine",
// 489:         "outdated/auto-updates",
// 490:       ].each do |cask_name|
// 491:         InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path(cask_name)))
// 492:       end
// 493:     end
// 494:
// 495:     it 'prefetches "auto_updates true" casks with quarantine until signed identity is checked' do
// 496:       installer = instance_double(Cask::Installer, check_requirements: nil, enqueue_downloads: nil,
// 497:                                                    source_download_requires_pre_fetch?: false)
// 498:
// 499:       expect(Cask::Installer).to receive(:new) do |cask, **|
// 500:         expect(cask).to eq(auto_updates)
// 501:         installer
// 502:       end
// 503:       expect(described_class).to receive(:upgrade_cask)
// 504:
// 505:       described_class.upgrade_casks!(auto_updates, show_upgrade_summary: false, args:)
// 506:     end
// 507:
// 508:     it "releases quarantine when Gatekeeper was already approved and identity matches" do
// 509:       allow(Cask::Quarantine).to receive(:signing_identity_match)
// 510:         .with(auto_updates_path, auto_updates_identity).and_return(true)
// 511:
// 512:       expect(described_class.quarantine_release_decision(
// 513:                outdated_auto_updates,
// 514:                auto_updates,
// 515:                { auto_updates_path.to_s => auto_updates_identity },
// 516:                { auto_updates_path.to_s => true },
// 517:              )).to eq(:release)
// 518:     end
// 519:
// 520:     it "reports a changed signer when the new app does not satisfy the old designated requirement" do
// 521:       allow(Cask::Quarantine).to receive(:signing_identity_match)
// 522:         .with(auto_updates_path, auto_updates_identity).and_return(false)
// 523:
// 524:       expect(described_class.quarantine_release_decision(
// 525:                outdated_auto_updates,
// 526:                auto_updates,
// 527:                { auto_updates_path.to_s => auto_updates_identity },
// 528:                { auto_updates_path.to_s => true },
// 529:              )).to eq(:signer_changed)
// 530:     end
// 531:
// 532:     it "reports an unverified signer when the old signing identity is missing" do
// 533:       expect(described_class.quarantine_release_decision(
// 534:                outdated_auto_updates,
// 535:                auto_updates,
// 536:                { auto_updates_path.to_s => nil },
// 537:                { auto_updates_path.to_s => true },
// 538:              )).to eq(:signer_unverified)
// 539:     end
// 540:
// 541:     it "reports an unverified signer when the new signing identity is missing" do
// 542:       allow(Cask::Quarantine).to receive(:signing_identity_match)
// 543:         .with(auto_updates_path, auto_updates_identity).and_return(nil)
// 544:
// 545:       expect(described_class.quarantine_release_decision(
// 546:                outdated_auto_updates,
// 547:                auto_updates,
// 548:                { auto_updates_path.to_s => auto_updates_identity },
// 549:                { auto_updates_path.to_s => true },
// 550:              )).to eq(:signer_unverified)
// 551:     end
// 552:
// 553:     it "reports missing approval when Gatekeeper was not approved" do
// 554:       expect(described_class.quarantine_release_decision(
// 555:                outdated_auto_updates,
// 556:                auto_updates,
// 557:                { auto_updates_path.to_s => auto_updates_identity },
// 558:                { auto_updates_path.to_s => false },
// 559:              )).to eq(:unapproved)
// 560:     end
// 561:
// 562:     it "releases quarantine for casks without auto_updates when Gatekeeper was already approved " \
// 563:        "and identity matches" do
// 564:       allow(Cask::Quarantine).to receive(:signing_identity_match)
// 565:         .with(local_caffeine_path, local_caffeine_identity).and_return(true)
// 566:
// 567:       expect(described_class.quarantine_release_decision(
// 568:                outdated_local_caffeine,
// 569:                local_caffeine,
// 570:                { local_caffeine_path.to_s => local_caffeine_identity },
// 571:                { local_caffeine_path.to_s => true },
// 572:              )).to eq(:release)
// 573:     end
// 574:
// 575:     it "reports missing approval for casks without auto_updates when Gatekeeper was not approved" do
// 576:       expect(described_class.quarantine_release_decision(
// 577:                outdated_local_caffeine,
// 578:                local_caffeine,
// 579:                { local_caffeine_path.to_s => local_caffeine_identity },
// 580:                { local_caffeine_path.to_s => false },
// 581:              )).to eq(:unapproved)
// 582:     end
// 583:   end
// 584:
// 585:   context "when an upgrade decides on quarantine after install" do
// 586:     before do
// 587:       Cask::Installer.new(Cask::CaskLoader.load(cask_path("outdated/local-caffeine"))).install
// 588:       allow(Cask::Quarantine).to receive(:available?).and_return(true)
// 589:     end
// 590:
// 591:     it "inherits quarantine approval when the previous version was already approved" do
// 592:       identity = Cask::Quarantine::SigningIdentity.new(requirement: 'identifier "sh.brew.local-caffeine"')
// 593:       allow(Cask::Quarantine).to receive_messages(
// 594:         user_approved?:         true,
// 595:         signing_identity:       identity,
// 596:         signing_identity_match: true,
// 597:       )
// 598:
// 599:       expect(Cask::Quarantine).to receive(:inherit_user_approval!).with(download_path: local_caffeine_path)
// 600:
// 601:       described_class.upgrade_casks!(local_caffeine, args:)
// 602:     end
// 603:
// 604:     it "continues the upgrade when quarantine approval cannot be inherited" do
// 605:       identity = Cask::Quarantine::SigningIdentity.new(requirement: 'identifier "sh.brew.local-caffeine"')
// 606:       allow(Cask::Quarantine).to receive_messages(
// 607:         user_approved?:         true,
// 608:         signing_identity:       identity,
// 609:         signing_identity_match: true,
// 610:       )
// 611:       allow(Cask::Quarantine).to receive(:inherit_user_approval!)
// 612:         .and_raise(Cask::CaskQuarantineReleaseError.new(local_caffeine_path, "Operation not permitted"))
// 613:
// 614:       expect do
// 615:         described_class.upgrade_casks!(local_caffeine, args:)
// 616:       end.to output(/couldn't inherit local-caffeine's quarantine approval so macOS may prompt/).to_stderr
// 617:     end
// 618:
// 619:     it "reports the skipped quarantine release under --verbose when approval is missing" do
// 620:       allow(Cask::Quarantine).to receive_messages(user_approved?: false, inherit_user_approval!: nil)
// 621:
// 622:       expect do
// 623:         described_class.upgrade_casks!(local_caffeine, verbose: true, args:)
// 624:       end.to output(/local-caffeine wasn't quarantine approved/).to_stdout
// 625:     end
// 626:
// 627:     it "reports a changed signer by default so the returning Gatekeeper prompt is explained" do
// 628:       identity = Cask::Quarantine::SigningIdentity.new(requirement: 'identifier "sh.brew.local-caffeine"')
// 629:       allow(Cask::Quarantine).to receive_messages(
// 630:         user_approved?:         true,
// 631:         signing_identity:       identity,
// 632:         signing_identity_match: false,
// 633:         inherit_user_approval!: nil,
// 634:       )
// 635:
// 636:       expect do
// 637:         described_class.upgrade_casks!(local_caffeine, args:)
// 638:       end.to output(/local-caffeine's signer changed so macOS may prompt/).to_stderr
// 639:     end
// 640:
// 641:     it "reports an unverified signer by default so the returning Gatekeeper prompt is explained" do
// 642:       identity = Cask::Quarantine::SigningIdentity.new(requirement: 'identifier "sh.brew.local-caffeine"')
// 643:       allow(Cask::Quarantine).to receive_messages(
// 644:         user_approved?:         true,
// 645:         signing_identity:       identity,
// 646:         signing_identity_match: nil,
// 647:         inherit_user_approval!: nil,
// 648:       )
// 649:
// 650:       expect do
// 651:         described_class.upgrade_casks!(local_caffeine, args:)
// 652:       end.to output(/couldn't verify local-caffeine's signer/).to_stderr
// 653:     end
// 654:   end
// 655:
// 656:   it "warns and skips disabled casks" do
// 657:     cask = Cask::CaskLoader.load(cask_path("livecheck/livecheck-disabled"))
// 658:     InstallHelper.stub_cask_installation(cask)
// 659:     allow(cask).to receive(:outdated?).with(greedy: true).and_return(true)
// 660:     summary_disabled = []
// 661:
// 662:     expect(described_class).not_to receive(:upgrade_cask)
// 663:
// 664:     expect do
// 665:       described_class.upgrade_casks!(cask, dry_run: true, summary_disabled:, args:)
// 666:     end.to output(/Not upgrading livecheck-disabled, it is disabled/).to_stderr
// 667:     expect(summary_disabled).to eq(["livecheck-disabled"])
// 668:   end
// 669:
// 670:   context "when upgrading the same cask twice" do
// 671:     before do
// 672:       Cask::Installer.new(Cask::CaskLoader.load(cask_path("outdated/local-caffeine"))).install
// 673:     end
// 674:
// 675:     it "uses the installed metadata version for the second upgrade" do
// 676:       described_class.upgrade_casks!(local_caffeine, args:)
// 677:       newer_cask = Cask::CaskLoader::FromContentLoader.new(<<~RUBY).load(config: nil)
// 678:         cask "local-caffeine" do
// 679:           version "1.2.4"
// 680:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 681:
// 682:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 683:           homepage "https://brew.sh/"
// 684:
// 685:           app "Caffeine.app"
// 686:         end
// 687:       RUBY
// 688:
// 689:       expect do
// 690:         described_class.upgrade_casks!(newer_cask, args:)
// 691:       end.to change(newer_cask, :installed_version).from("1.2.3").to("1.2.4")
// 692:     end
// 693:   end
// 694:
// 695:   context "when upgrading after a forced upgrade without a cask receipt" do
// 696:     before do
// 697:       InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/local-caffeine")))
// 698:     end
// 699:
// 700:     it "uses the forced upgrade metadata for the next upgrade" do
// 701:       receipt_path = local_caffeine.metadata_main_container_path/AbstractTab::FILENAME
// 702:       receipt_path.unlink
// 703:       allow(Homebrew::API).to receive(:cask_token?).with("local-caffeine").and_return(true)
// 704:       allow(Homebrew::API::Cask).to receive(:cask_json).with("local-caffeine").and_return({
// 705:         "artifacts" => [{ "app" => ["Caffeine.app"] }],
// 706:       })
// 707:
// 708:       expect(receipt_path).not_to exist
// 709:       expect(Cask::CaskLoader.load_from_installed_caskfile(local_caffeine.installed_caskfile).artifacts)
// 710:         .to include(an_instance_of(Cask::Artifact::App))
// 711:
// 712:       described_class.upgrade_casks!(local_caffeine, force: true, args:)
// 713:
// 714:       expect(receipt_path).to exist
// 715:       expect(local_caffeine.tab.installed_on_request).to be(true)
// 716:       expect(Cask::CaskLoader.load_from_installed_caskfile(local_caffeine.installed_caskfile).artifacts)
// 717:         .to include(an_instance_of(Cask::Artifact::App))
// 718:
// 719:       newer_cask = Cask::CaskLoader::FromContentLoader.new(<<~RUBY).load(config: nil)
// 720:         cask "local-caffeine" do
// 721:           version "1.2.4"
// 722:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 723:
// 724:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 725:           homepage "https://brew.sh/"
// 726:
// 727:           app "Caffeine.app"
// 728:         end
// 729:       RUBY
// 730:
// 731:       expect do
// 732:         described_class.upgrade_casks!(newer_cask, args:)
// 733:       end.to change(newer_cask, :installed_version).from("1.2.3").to("1.2.4")
// 734:     end
// 735:   end
// 736:
// 737:   context "when an upgrade fails after installing artifacts" do
// 738:     before do
// 739:       Cask::Installer.new(Cask::CaskLoader.load(cask_path("outdated/local-caffeine"))).install
// 740:     end
// 741:
// 742:     it "keeps the old cask receipt" do
// 743:       receipt_path = local_caffeine.metadata_main_container_path/AbstractTab::FILENAME
// 744:
// 745:       expect(JSON.parse(receipt_path.read).dig("source", "version")).to eq("1.2.2")
// 746:
// 747:       allow_any_instance_of(Cask::Installer).to receive(:finalize_upgrade)
// 748:         .and_raise(Cask::CaskError, "finalize failed")
// 749:
// 750:       expect do
// 751:         described_class.upgrade_casks!(local_caffeine, args:)
// 752:       end.to output(/local-caffeine: finalize failed/).to_stderr
// 753:
// 754:       expect(JSON.parse(receipt_path.read).dig("source", "version")).to eq("1.2.2")
// 755:     end
// 756:   end
// 757:
// 758:   context "when an upgrade failed" do
// 759:     # These tests perform actual upgrades and test rollback behavior,
// 760:     # so they need full real installations.
// 761:     before do
// 762:       [
// 763:         "outdated/bad-checksum",
// 764:         "outdated/will-fail-if-upgraded",
// 765:       ].each do |cask|
// 766:         Cask::Installer.new(Cask::CaskLoader.load(cask_path(cask))).install
// 767:       end
// 768:     end
// 769:
// 770:     let(:output_reverted) do
// 771:       Regexp.new <<~EOS
// 772:         Warning: Reverting upgrade for Cask .*
// 773:       EOS
// 774:     end
// 775:
// 776:     it "restores the old Cask if the upgrade failed" do
// 777:       will_fail_if_upgraded = Cask::CaskLoader.load("will-fail-if-upgraded")
// 778:       will_fail_if_upgraded_path = Pathname(will_fail_if_upgraded.config.appdir).join("container")
// 779:
// 780:       expect(will_fail_if_upgraded).to be_installed
// 781:       expect(will_fail_if_upgraded_path).to be_a_file
// 782:       expect(will_fail_if_upgraded.installed_version).to eq "1.2.2"
// 783:
// 784:       expect do
// 785:         described_class.upgrade_casks!(will_fail_if_upgraded, args:)
// 786:       end.to output(output_reverted).to_stderr
// 787:
// 788:       expect(will_fail_if_upgraded).to be_installed
// 789:       expect(will_fail_if_upgraded_path).to be_a_file
// 790:       expect(will_fail_if_upgraded.installed_version).to eq "1.2.2"
// 791:       expect(will_fail_if_upgraded.staged_path).not_to exist
// 792:     end
// 793:
// 794:     it "does not restore the old Cask if the upgrade failed pre-install" do
// 795:       bad_checksum = Cask::CaskLoader.load("bad-checksum")
// 796:       bad_checksum_path = Pathname(bad_checksum.config.appdir).join("Caffeine.app")
// 797:
// 798:       expect(bad_checksum).to be_installed
// 799:       expect(bad_checksum_path).to be_a_directory
// 800:       expect(bad_checksum.installed_version).to eq "1.2.2"
// 801:
// 802:       expect do
// 803:         described_class.upgrade_casks!(bad_checksum, args:)
// 804:       end.to output(/bad-checksum: SHA-256 mismatch/).to_stderr.and(not_to_output(output_reverted).to_stderr)
// 805:
// 806:       expect(bad_checksum).to be_installed
// 807:       expect(bad_checksum_path).to be_a_directory
// 808:       expect(bad_checksum.installed_version).to eq "1.2.2"
// 809:       expect(bad_checksum.staged_path).not_to exist
// 810:     end
// 811:
// 812:     it "reports the original upgrade error, not a failure that occurs while rolling back" do
// 813:       will_fail_if_upgraded = Cask::CaskLoader.load("will-fail-if-upgraded")
// 814:       allow_any_instance_of(Cask::Installer).to receive(:revert_upgrade).and_raise("rollback failed")
// 815:
// 816:       expect do
// 817:         described_class.upgrade_casks!(will_fail_if_upgraded, args:)
// 818:       end.to output(/Error: will-fail-if-upgraded: /).to_stderr
// 819:     end
// 820:   end
// 821:
// 822:   context "when there were multiple failures" do
// 823:     # This test exercises upgrade error handling, so it needs installed Casks.
// 824:     before do
// 825:       [
// 826:         "outdated/bad-checksum",
// 827:         "outdated/local-transmission-zip",
// 828:         "outdated/bad-checksum2",
// 829:       ].each do |cask|
// 830:         InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path(cask)))
// 831:       end
// 832:
// 833:       bad_checksum_2_path = Pathname(Cask::CaskLoader.load("bad-checksum2").config.appdir).join("container")
// 834:       FileUtils.rm_rf(bad_checksum_2_path)
// 835:       FileUtils.touch(bad_checksum_2_path)
// 836:     end
// 837:
// 838:     it "does not end the upgrade process" do
// 839:       summary_upgrades = []
// 840:       upgraded_tokens = []
// 841:       bad_checksum = Cask::CaskLoader.load("bad-checksum")
// 842:       bad_checksum_path = Pathname(bad_checksum.config.appdir).join("Caffeine.app")
// 843:
// 844:       bad_checksum_2 = Cask::CaskLoader.load("bad-checksum2")
// 845:       bad_checksum_2_path = Pathname(bad_checksum_2.config.appdir).join("container")
// 846:
// 847:       expect(bad_checksum).to be_installed
// 848:       expect(bad_checksum_path).to be_a_directory
// 849:       expect(bad_checksum.installed_version).to eq "1.2.2"
// 850:
// 851:       expect(local_transmission).to be_installed
// 852:       expect(local_transmission_path).to be_a_directory
// 853:       expect(local_transmission.installed_version).to eq "2.60"
// 854:
// 855:       expect(bad_checksum_2).to be_installed
// 856:       expect(bad_checksum_2_path).to be_a_file
// 857:       expect(bad_checksum_2.installed_version).to eq "1.2.2"
// 858:
// 859:       allow(described_class).to receive(:upgrade_cask) do |_, new_cask, **|
// 860:         upgraded_tokens << new_cask.token
// 861:         raise Cask::CaskError, "failed" if new_cask.token.start_with?("bad-checksum")
// 862:
// 863:         InstallHelper.stub_cask_installation(new_cask)
// 864:       end
// 865:
// 866:       expect do
// 867:         described_class.upgrade_casks!(args:, skip_prefetch: true, summary_upgrades:)
// 868:       end.to output(/bad-checksum: failed.*bad-checksum2: failed/m).to_stderr
// 869:
// 870:       expect(upgraded_tokens).to contain_exactly("bad-checksum", "bad-checksum2", "local-transmission-zip")
// 871:       expect(summary_upgrades).to contain_exactly("local-transmission-zip 2.60 -> 2.61")
// 872:
// 873:       expect(bad_checksum).to be_installed
// 874:       expect(bad_checksum_path).to be_a_directory
// 875:       expect(bad_checksum.installed_version).to eq "1.2.2"
// 876:       expect(bad_checksum.staged_path).not_to exist
// 877:
// 878:       expect(local_transmission).to be_installed
// 879:       expect(local_transmission_path).to be_a_directory
// 880:       expect(local_transmission.installed_version).to eq "2.61"
// 881:
// 882:       expect(bad_checksum_2).to be_installed
// 883:       expect(bad_checksum_2_path).to be_a_file
// 884:       expect(bad_checksum_2.installed_version).to eq "1.2.2"
// 885:       expect(bad_checksum_2.staged_path).not_to exist
// 886:     end
// 887:   end
// 888:
// 889:   context "when an outdated cask is incompatible" do
// 890:     before do
// 891:       [
// 892:         "outdated/local-caffeine",
// 893:         "outdated/local-transmission-zip",
// 894:       ].each do |cask|
// 895:         InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path(cask)))
// 896:       end
// 897:     end
// 898:
// 899:     it "continues upgrading compatible casks" do
// 900:       summary_upgrades = []
// 901:       upgraded_tokens = []
// 902:       incompatible_installer = instance_double(Cask::Installer, source_download_requires_pre_fetch?: false)
// 903:       compatible_installer = instance_double(Cask::Installer, source_download_requires_pre_fetch?: false)
// 904:
// 905:       allow(incompatible_installer).to receive(:check_requirements)
// 906:         .and_raise(Cask::CaskError, "local-caffeine: This cask does not run on macOS versions older than Tahoe.")
// 907:       allow(compatible_installer).to receive_messages(check_requirements: nil, enqueue_downloads: nil)
// 908:       allow(Cask::Installer).to receive(:new) do |cask, **|
// 909:         (cask.token == "local-caffeine") ? incompatible_installer : compatible_installer
// 910:       end
// 911:       allow(described_class).to receive(:upgrade_cask) do |_, new_cask, **|
// 912:         upgraded_tokens << new_cask.token
// 913:       end
// 914:
// 915:       expect do
// 916:         described_class.upgrade_casks!(
// 917:           local_caffeine, local_transmission,
// 918:           show_upgrade_summary: false,
// 919:           summary_upgrades:,
// 920:           args:
// 921:         )
// 922:       end.to output(/local-caffeine: This cask does not run on macOS versions older than Tahoe\./).to_stderr
// 923:
// 924:       expect(upgraded_tokens).to eq(["local-transmission-zip"])
// 925:       expect(summary_upgrades).to eq(["local-transmission-zip 2.60 -> 2.61"])
// 926:     end
// 927:
// 928:     it "reports prefetched requirement errors alongside compatible casks" do
// 929:       summary_upgrades = []
// 930:       upgraded_tokens = []
// 931:       cask_error = Cask::CaskError.new(
// 932:         "local-caffeine: This cask does not run on macOS versions older than Tahoe.",
// 933:       )
// 934:
// 935:       allow(described_class).to receive(:upgrade_cask) do |_, new_cask, **|
// 936:         upgraded_tokens << new_cask.token
// 937:       end
// 938:
// 939:       expect do
// 940:         described_class.upgrade_casks!(
// 941:           local_transmission,
// 942:           skip_prefetch:        true,
// 943:           show_upgrade_summary: false,
// 944:           summary_upgrades:,
// 945:           prefetched_errors:    [cask_error],
// 946:           args:,
// 947:         )
// 948:       end.to output(/#{Regexp.escape(cask_error.message)}/).to_stderr
// 949:
// 950:       expect(upgraded_tokens).to eq(["local-transmission-zip"])
// 951:       expect(summary_upgrades).to eq(["local-transmission-zip 2.60 -> 2.61"])
// 952:     end
// 953:   end
// 954: end
