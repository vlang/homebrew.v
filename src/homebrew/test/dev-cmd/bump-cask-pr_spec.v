module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/bump-cask-pr_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:bump_cask_pr) { described_class.new(["test"]) }` at line 9.
pub fn ruby_bump_cask_pr_spec_l9_d1_bump_cask_pr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bump_cask_pr', ...args)
}

// Ruby let `let(:newest_macos) { MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym }` at line 11.
pub fn ruby_bump_cask_pr_spec_l11_d2_newest_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('newest_macos', ...args)
}

// Ruby let `let(:c) do` at line 12.
pub fn ruby_bump_cask_pr_spec_l12_d3_c(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c', ...args)
}

// Ruby let `let(:c_depends_on_intel) do` at line 22.
pub fn ruby_bump_cask_pr_spec_l22_d4_c_depends_on_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_depends_on_intel', ...args)
}

// Ruby let `let(:c_on_system) do` at line 34.
pub fn ruby_bump_cask_pr_spec_l34_d5_c_on_system(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_on_system', ...args)
}

// Ruby let `let(:c_on_system_depends_on_intel) do` at line 46.
pub fn ruby_bump_cask_pr_spec_l46_d6_c_on_system_depends_on_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_on_system_depends_on_intel', ...args)
}

// Ruby let `let(:c_arm_intel) do` at line 60.
pub fn ruby_bump_cask_pr_spec_l60_d7_c_arm_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_arm_intel', ...args)
}

// Ruby let `let(:older_macos) { :big_sur }` at line 81.
pub fn ruby_bump_cask_pr_spec_l81_d8_older_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('older_macos', ...args)
}

// Ruby let `let(:new_version) { Homebrew::BumpVersionParser.new(general: "1.2.3") }` at line 83.
pub fn ruby_bump_cask_pr_spec_l83_d9_new_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version', ...args)
}

// Ruby it `it "returns an array only including macOS/ARM" do` at line 86.
pub fn ruby_bump_cask_pr_spec_l86_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array only including macOS/`depends_on arch` value" do` at line 100.
pub fn ruby_bump_cask_pr_spec_l100_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array with combinations of `OnSystem::BASE_OS_OPTIONS` and `OnSystem::ARCH_OPTIONS`" do` at line 114.
pub fn ruby_bump_cask_pr_spec_l114_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array with combinations of `OnSystem::BASE_OS_OPTIONS` and `OnSystem::ARCH_OPTIONS`" do` at line 138.
pub fn ruby_bump_cask_pr_spec_l138_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns all arch combinations for `OnSystem::BASE_OS_OPTIONS`" do` at line 162.
pub fn ruby_bump_cask_pr_spec_l162_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:new_version_arm) { Homebrew::BumpVersionParser.new(arm: "1.2.3") }` at line 192.
pub fn ruby_bump_cask_pr_spec_l192_d15_new_version_arm(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_arm', ...args)
}

// Ruby let `let(:new_version_intel) { Homebrew::BumpVersionParser.new(intel: "1.2.3") }` at line 193.
pub fn ruby_bump_cask_pr_spec_l193_d16_new_version_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_intel', ...args)
}

// Ruby let `let(:new_version_arm_intel) { Homebrew::BumpVersionParser.new(arm: "1.2.3", intel: "1.2.2") }` at line 194.
pub fn ruby_bump_cask_pr_spec_l194_d17_new_version_arm_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_arm_intel', ...args)
}

// Ruby let `let(:new_version_intel_arm) { Homebrew::BumpVersionParser.new(arm: "1.2.2", intel: "1.2.3") }` at line 195.
pub fn ruby_bump_cask_pr_spec_l195_d18_new_version_intel_arm(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_intel_arm', ...args)
}

// Ruby it `it "returns an array only using archs of arch-specific versions" do` at line 197.
pub fn ruby_bump_cask_pr_spec_l197_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:contents) do` at line 256.
pub fn ruby_bump_cask_pr_spec_l256_d20_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contents', ...args)
}

// Ruby it `it "is idempotent when the replacement has already been applied" do` at line 276.
pub fn ruby_bump_cask_pr_spec_l276_d21_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "raises when the stanza is missing entirely" do` at line 283.
pub fn ruby_bump_cask_pr_spec_l283_d22_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby let `let(:old_hash) { "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }` at line 290.
pub fn ruby_bump_cask_pr_spec_l290_d23_old_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_hash', ...args)
}

// Ruby let `let(:new_hash) { "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" }` at line 291.
pub fn ruby_bump_cask_pr_spec_l291_d24_new_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_hash', ...args)
}

// Ruby let `let(:intel_hash) { "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" }` at line 292.
pub fn ruby_bump_cask_pr_spec_l292_d25_intel_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('intel_hash', ...args)
}

// Ruby method `cask_from_contents(contents)` at line 299.
pub fn ruby_bump_cask_pr_spec_l299_d26_cask_from_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_from_contents', ...args)
}

// Ruby it `it "splits a root version and single checksum before replacing the ARM values" do` at line 307.
pub fn ruby_bump_cask_pr_spec_l307_d27_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "splits a root version and keeps top-level architecture checksums" do` at line 342.
pub fn ruby_bump_cask_pr_spec_l342_d28_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "splits a root version and leaves top-level no_check checksums" do` at line 380.
pub fn ruby_bump_cask_pr_spec_l380_d29_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "splits root version and checksum stanzas when new versions differ by architecture" do` at line 410.
pub fn ruby_bump_cask_pr_spec_l410_d30_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "only updates matching version and checksum stanzas inside the target architecture block" do` at line 446.
pub fn ruby_bump_cask_pr_spec_l446_d31_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "updates arch-specific version and no_check checksum stanzas when new version is general" do` at line 486.
pub fn ruby_bump_cask_pr_spec_l486_d32_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('updates', ...args)
}

// Ruby it `it "requires depends_on arch when a checksum is missing" do` at line 526.
pub fn ruby_bump_cask_pr_spec_l526_d33_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "leaves nested architecture stanzas unchanged when matching values could be replaced globally" do` at line 557.
pub fn ruby_bump_cask_pr_spec_l557_d34_leaves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('leaves', ...args)
}

// Ruby let `let(:c_throttle) do` at line 586.
pub fn ruby_bump_cask_pr_spec_l586_d35_c_throttle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_throttle', ...args)
}

// Ruby let `let(:c_throttle_days) do` at line 600.
pub fn ruby_bump_cask_pr_spec_l600_d36_c_throttle_days(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_throttle_days', ...args)
}

// Ruby let `let(:c_throttle_rate_and_days) do` at line 614.
pub fn ruby_bump_cask_pr_spec_l614_d37_c_throttle_rate_and_days(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_throttle_rate_and_days', ...args)
}

// Ruby let `let(:new_version) { Homebrew::BumpVersionParser.new(general: "1.2.5") }` at line 628.
pub fn ruby_bump_cask_pr_spec_l628_d38_new_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version', ...args)
}

// Ruby let `let(:throttle_error) { "Error: throttle-test should only be updated every 5 releases on multiples of 5\n" }` at line 629.
pub fn ruby_bump_cask_pr_spec_l629_d39_throttle_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttle_error', ...args)
}

// Ruby let `let(:throttle_days_error) { "Error: throttle-days-test should only be updated every 1 day\n" }` at line 630.
pub fn ruby_bump_cask_pr_spec_l630_d40_throttle_days_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttle_days_error', ...args)
}

// Ruby let `let(:throttle_rate_days_error) do` at line 631.
pub fn ruby_bump_cask_pr_spec_l631_d41_throttle_rate_days_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttle_rate_days_error', ...args)
}

// Ruby let `let(:tap) { Tap.fetch("test", "tap") }` at line 634.
pub fn ruby_bump_cask_pr_spec_l634_d42_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it "outputs nothing" do` at line 637.
pub fn ruby_bump_cask_pr_spec_l637_d43_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Ruby it `it "does not throttle" do` at line 643.
pub fn ruby_bump_cask_pr_spec_l643_d44_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:empty_version) do` at line 650.
pub fn ruby_bump_cask_pr_spec_l650_d45_empty_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty_version', ...args)
}

// Ruby it `it "does not throttle" do` at line 656.
pub fn ruby_bump_cask_pr_spec_l656_d46_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not throttle" do` at line 665.
pub fn ruby_bump_cask_pr_spec_l665_d47_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:new_version_indivisible) { Homebrew::BumpVersionParser.new(general: "1.2.4") }` at line 674.
pub fn ruby_bump_cask_pr_spec_l674_d48_new_version_indivisible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_indivisible', ...args)
}

// Ruby it `it "throttles version" do` at line 676.
pub fn ruby_bump_cask_pr_spec_l676_d49_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttles', ...args)
}

// Ruby let `let(:new_version_indivisible) { Homebrew::BumpVersionParser.new(general: "1.2.4") }` at line 687.
pub fn ruby_bump_cask_pr_spec_l687_d50_new_version_indivisible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_version_indivisible', ...args)
}

// Ruby it `it "throttles version when throttle interval has not elapsed" do` at line 693.
pub fn ruby_bump_cask_pr_spec_l693_d51_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttles', ...args)
}

// Ruby it `it "does not throttle when throttle interval has elapsed" do` at line 703.
pub fn ruby_bump_cask_pr_spec_l703_d52_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "throttles version when throttle interval has not elapsed" do` at line 717.
pub fn ruby_bump_cask_pr_spec_l717_d53_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttles', ...args)
}

// Ruby it `it "does not throttle when throttle interval has elapsed" do` at line 727.
pub fn ruby_bump_cask_pr_spec_l727_d54_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/bump-cask-pr"
// 6: require "bump_version_parser"
// 7:
// 8: RSpec.describe Homebrew::DevCmd::BumpCaskPr do
// 9:   subject(:bump_cask_pr) { described_class.new(["test"]) }
// 10:
// 11:   let(:newest_macos) { MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym }
// 12:   let(:c) do
// 13:     Cask::Cask.new("test") do
// 14:       version "0.0.1,2"
// 15:
// 16:       url "https://brew.sh/test-0.0.1.dmg"
// 17:       name "Test"
// 18:       desc "Test cask"
// 19:       homepage "https://brew.sh"
// 20:     end
// 21:   end
// 22:   let(:c_depends_on_intel) do
// 23:     Cask::Cask.new("test-depends-on-intel") do
// 24:       version "0.0.1,2"
// 25:
// 26:       url "https://brew.sh/test-0.0.1.dmg"
// 27:       name "Test"
// 28:       desc "Test cask"
// 29:       homepage "https://brew.sh"
// 30:
// 31:       depends_on arch: :x86_64
// 32:     end
// 33:   end
// 34:   let(:c_on_system) do
// 35:     Cask::Cask.new("test-on-system") do
// 36:       os macos: "darwin", linux: "linux"
// 37:
// 38:       version "0.0.1,2"
// 39:
// 40:       url "https://brew.sh/test-0.0.1.dmg"
// 41:       name "Test"
// 42:       desc "Test cask"
// 43:       homepage "https://brew.sh"
// 44:     end
// 45:   end
// 46:   let(:c_on_system_depends_on_intel) do
// 47:     Cask::Cask.new("test-on-system-depends-on-intel") do
// 48:       os macos: "darwin", linux: "linux"
// 49:
// 50:       version "0.0.1,2"
// 51:
// 52:       url "https://brew.sh/test-0.0.1.dmg"
// 53:       name "Test"
// 54:       desc "Test cask"
// 55:       homepage "https://brew.sh"
// 56:
// 57:       depends_on arch: :x86_64
// 58:     end
// 59:   end
// 60:   let(:c_arm_intel) do
// 61:     Cask::Cask.new("test") do
// 62:       on_arm do
// 63:         version "0.0.2,3"
// 64:       end
// 65:       on_intel do
// 66:         version "0.0.1,2"
// 67:       end
// 68:
// 69:       url "https://brew.sh/test-#{version}.dmg"
// 70:       name "Test"
// 71:       desc "Test cask"
// 72:       homepage "https://brew.sh"
// 73:     end
// 74:   end
// 75:
// 76:   it_behaves_like "parseable arguments"
// 77:
// 78:   describe "::generate_system_options" do
// 79:     # We simulate a macOS version older than the newest, as the method will use
// 80:     # the host macOS version instead of the default (the newest macOS version).
// 81:     let(:older_macos) { :big_sur }
// 82:
// 83:     let(:new_version) { Homebrew::BumpVersionParser.new(general: "1.2.3") }
// 84:
// 85:     context "when cask does not have on_system blocks/calls or `depends_on arch`" do
// 86:       it "returns an array only including macOS/ARM" do
// 87:         Homebrew::SimulateSystem.with(os: :linux) do
// 88:           expect(bump_cask_pr.generate_system_options(c, new_version))
// 89:             .to eq([[newest_macos, :arm]])
// 90:         end
// 91:
// 92:         Homebrew::SimulateSystem.with(os: older_macos) do
// 93:           expect(bump_cask_pr.generate_system_options(c, new_version))
// 94:             .to eq([[older_macos, :arm]])
// 95:         end
// 96:       end
// 97:     end
// 98:
// 99:     context "when cask does not have on_system blocks/calls but has `depends_on arch`" do
// 100:       it "returns an array only including macOS/`depends_on arch` value" do
// 101:         Homebrew::SimulateSystem.with(os: :linux, arch: :arm) do
// 102:           expect(bump_cask_pr.generate_system_options(c_depends_on_intel, new_version))
// 103:             .to eq([[newest_macos, :intel]])
// 104:         end
// 105:
// 106:         Homebrew::SimulateSystem.with(os: older_macos, arch: :arm) do
// 107:           expect(bump_cask_pr.generate_system_options(c_depends_on_intel, new_version))
// 108:             .to eq([[older_macos, :intel]])
// 109:         end
// 110:       end
// 111:     end
// 112:
// 113:     context "when cask has on_system blocks/calls but does not have `depends_on arch`" do
// 114:       it "returns an array with combinations of `OnSystem::BASE_OS_OPTIONS` and `OnSystem::ARCH_OPTIONS`" do
// 115:         Homebrew::SimulateSystem.with(os: :linux) do
// 116:           expect(bump_cask_pr.generate_system_options(c_on_system, new_version))
// 117:             .to eq([
// 118:               [newest_macos, :intel],
// 119:               [newest_macos, :arm],
// 120:               [:linux, :intel],
// 121:               [:linux, :arm],
// 122:             ])
// 123:         end
// 124:
// 125:         Homebrew::SimulateSystem.with(os: older_macos) do
// 126:           expect(bump_cask_pr.generate_system_options(c_on_system, new_version))
// 127:             .to eq([
// 128:               [older_macos, :intel],
// 129:               [older_macos, :arm],
// 130:               [:linux, :intel],
// 131:               [:linux, :arm],
// 132:             ])
// 133:         end
// 134:       end
// 135:     end
// 136:
// 137:     context "when cask has on_system blocks/calls and `depends_on arch`" do
// 138:       it "returns an array with combinations of `OnSystem::BASE_OS_OPTIONS` and `OnSystem::ARCH_OPTIONS`" do
// 139:         Homebrew::SimulateSystem.with(os: :linux, arch: :arm) do
// 140:           expect(bump_cask_pr.generate_system_options(c_on_system_depends_on_intel, new_version))
// 141:             .to eq([
// 142:               [newest_macos, :intel],
// 143:               [newest_macos, :arm],
// 144:               [:linux, :intel],
// 145:               [:linux, :arm],
// 146:             ])
// 147:         end
// 148:
// 149:         Homebrew::SimulateSystem.with(os: older_macos, arch: :arm) do
// 150:           expect(bump_cask_pr.generate_system_options(c_on_system_depends_on_intel, new_version))
// 151:             .to eq([
// 152:               [older_macos, :intel],
// 153:               [older_macos, :arm],
// 154:               [:linux, :intel],
// 155:               [:linux, :arm],
// 156:             ])
// 157:         end
// 158:       end
// 159:     end
// 160:
// 161:     context "when cask has `depends_on arch` scoped to an `on_os` block" do
// 162:       it "returns all arch combinations for `OnSystem::BASE_OS_OPTIONS`" do
// 163:         Homebrew::SimulateSystem.with(os: older_macos, arch: :arm) do
// 164:           cask = Cask::Cask.new("test-on-macos-scoped-depends-on-arm") do
// 165:             os macos: "darwin", linux: "linux"
// 166:
// 167:             version "0.0.1,2"
// 168:
// 169:             url "https://brew.sh/test-0.0.1.dmg"
// 170:             name "Test"
// 171:             desc "Test cask"
// 172:             homepage "https://brew.sh"
// 173:
// 174:             on_macos do
// 175:               depends_on arch: :arm64
// 176:             end
// 177:           end
// 178:
// 179:           expect(cask.depends_on.arch).to eq([{ type: :arm, bits: 64 }])
// 180:           expect(bump_cask_pr.generate_system_options(cask, new_version))
// 181:             .to eq([
// 182:               [older_macos, :intel],
// 183:               [older_macos, :arm],
// 184:               [:linux, :intel],
// 185:               [:linux, :arm],
// 186:             ])
// 187:         end
// 188:       end
// 189:     end
// 190:
// 191:     context "when cask has arch-specific versions" do
// 192:       let(:new_version_arm) { Homebrew::BumpVersionParser.new(arm: "1.2.3") }
// 193:       let(:new_version_intel) { Homebrew::BumpVersionParser.new(intel: "1.2.3") }
// 194:       let(:new_version_arm_intel) { Homebrew::BumpVersionParser.new(arm: "1.2.3", intel: "1.2.2") }
// 195:       let(:new_version_intel_arm) { Homebrew::BumpVersionParser.new(arm: "1.2.2", intel: "1.2.3") }
// 196:
// 197:       it "returns an array only using archs of arch-specific versions" do
// 198:         Homebrew::SimulateSystem.with(os: :linux) do
// 199:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_arm))
// 200:             .to eq([
// 201:               [newest_macos, :arm],
// 202:               [:linux, :arm],
// 203:             ])
// 204:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_intel))
// 205:             .to eq([
// 206:               [newest_macos, :intel],
// 207:               [:linux, :intel],
// 208:             ])
// 209:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_arm_intel))
// 210:             .to eq([
// 211:               [newest_macos, :arm],
// 212:               [newest_macos, :intel],
// 213:               [:linux, :arm],
// 214:               [:linux, :intel],
// 215:             ])
// 216:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_intel_arm))
// 217:             .to eq([
// 218:               [newest_macos, :intel],
// 219:               [newest_macos, :arm],
// 220:               [:linux, :intel],
// 221:               [:linux, :arm],
// 222:             ])
// 223:         end
// 224:
// 225:         Homebrew::SimulateSystem.with(os: older_macos) do
// 226:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_arm))
// 227:             .to eq([
// 228:               [older_macos, :arm],
// 229:               [:linux, :arm],
// 230:             ])
// 231:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_intel))
// 232:             .to eq([
// 233:               [older_macos, :intel],
// 234:               [:linux, :intel],
// 235:             ])
// 236:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_arm_intel))
// 237:             .to eq([
// 238:               [older_macos, :arm],
// 239:               [older_macos, :intel],
// 240:               [:linux, :arm],
// 241:               [:linux, :intel],
// 242:             ])
// 243:           expect(bump_cask_pr.generate_system_options(c_arm_intel, new_version_intel_arm))
// 244:             .to eq([
// 245:               [older_macos, :intel],
// 246:               [older_macos, :arm],
// 247:               [:linux, :intel],
// 248:               [:linux, :arm],
// 249:             ])
// 250:         end
// 251:       end
// 252:     end
// 253:   end
// 254:
// 255:   describe "#replace_cask_stanza_value" do
// 256:     let(:contents) do
// 257:       <<~RUBY
// 258:         cask "foo" do
// 259:           arch arm: "Apple", intel: "Intel"
// 260:
// 261:           version "1.0"
// 262:           sha256 arm:   "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 263:                  intel: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 264:
// 265:           url "https://brew.sh/foo-\#{version}.dmg"
// 266:           name "Foo"
// 267:         end
// 268:       RUBY
// 269:     end
// 270:
// 271:     before do
// 272:       Homebrew.install_bundler_gems!(groups: ["ast"])
// 273:       require "utils/ast"
// 274:     end
// 275:
// 276:     it "is idempotent when the replacement has already been applied" do
// 277:       bumped = bump_cask_pr.replace_cask_stanza_value(contents, :version, "1.0", "2.0")
// 278:       expect(bumped).to include('version "2.0"')
// 279:       expect { bump_cask_pr.replace_cask_stanza_value(bumped, :version, "1.0", "2.0") }
// 280:         .not_to raise_error
// 281:     end
// 282:
// 283:     it "raises when the stanza is missing entirely" do
// 284:       expect { bump_cask_pr.replace_cask_stanza_value(contents, :version, "9.9", "2.0") }
// 285:         .to raise_error(/Could not find 'version' stanza/)
// 286:     end
// 287:   end
// 288:
// 289:   describe "#replace_version_and_checksum" do
// 290:     let(:old_hash) { "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
// 291:     let(:new_hash) { "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" }
// 292:     let(:intel_hash) { "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" }
// 293:
// 294:     before do
// 295:       Homebrew.install_bundler_gems!(groups: ["ast"])
// 296:       require "utils/ast"
// 297:     end
// 298:
// 299:     def cask_from_contents(contents)
// 300:       path = mktmpdir/"foo.rb"
// 301:       path.write(contents)
// 302:       Homebrew::SimulateSystem.with(os: newest_macos, arch: :arm) do
// 303:         Cask::CaskLoader.load(path)
// 304:       end
// 305:     end
// 306:
// 307:     it "splits a root version and single checksum before replacing the ARM values" do
// 308:       contents = <<~RUBY
// 309:         cask "foo" do
// 310:           version "1.0"
// 311:           sha256 "#{old_hash}"
// 312:
// 313:           url "https://brew.sh/foo-\#{version}.dmg"
// 314:           name "Foo"
// 315:         end
// 316:       RUBY
// 317:       cask = Homebrew::SimulateSystem.with(os: newest_macos, arch: :arm) { cask_from_contents(contents) }
// 318:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0")
// 319:
// 320:       expect(bump_cask_pr.replace_version_and_checksum(cask, new_hash, new_version, contents))
// 321:         .to eq <<~RUBY
// 322:           cask "foo" do
// 323:             on_arm do
// 324:               version "2.0"
// 325:             end
// 326:             on_intel do
// 327:               version "1.0"
// 328:             end
// 329:             on_arm do
// 330:               sha256 "#{new_hash}"
// 331:             end
// 332:             on_intel do
// 333:               sha256 "#{old_hash}"
// 334:             end
// 335:
// 336:             url "https://brew.sh/foo-\#{version}.dmg"
// 337:             name "Foo"
// 338:           end
// 339:         RUBY
// 340:     end
// 341:
// 342:     it "splits a root version and keeps top-level architecture checksums" do
// 343:       contents = <<~RUBY
// 344:         cask "foo" do
// 345:           arch arm: "arm", intel: "intel"
// 346:
// 347:           version "1.0"
// 348:           sha256 arm:   "#{old_hash}",
// 349:                  intel: "#{intel_hash}"
// 350:
// 351:           url "https://brew.sh/foo-\#{arch}-\#{version}.dmg"
// 352:           name "Foo"
// 353:           depends_on :macos
// 354:         end
// 355:       RUBY
// 356:       cask = Homebrew::SimulateSystem.with(os: newest_macos, arch: :arm) { cask_from_contents(contents) }
// 357:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0")
// 358:
// 359:       expect(bump_cask_pr.replace_version_and_checksum(cask, new_hash, new_version, contents))
// 360:         .to eq <<~RUBY
// 361:           cask "foo" do
// 362:             arch arm: "arm", intel: "intel"
// 363:
// 364:             on_arm do
// 365:               version "2.0"
// 366:             end
// 367:             on_intel do
// 368:               version "1.0"
// 369:             end
// 370:             sha256 arm:   "#{new_hash}",
// 371:                    intel: "#{intel_hash}"
// 372:
// 373:             url "https://brew.sh/foo-\#{arch}-\#{version}.dmg"
// 374:             name "Foo"
// 375:             depends_on :macos
// 376:           end
// 377:         RUBY
// 378:     end
// 379:
// 380:     it "splits a root version and leaves top-level no_check checksums" do
// 381:       contents = <<~RUBY
// 382:         cask "foo" do
// 383:           version "1.0"
// 384:           sha256 :no_check
// 385:
// 386:           url "https://brew.sh/foo-\#{version}.dmg"
// 387:           name "Foo"
// 388:         end
// 389:       RUBY
// 390:       cask = cask_from_contents(contents)
// 391:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0")
// 392:
// 393:       expect(bump_cask_pr.replace_version_and_checksum(cask, new_hash, new_version, contents))
// 394:         .to eq <<~RUBY
// 395:           cask "foo" do
// 396:             on_arm do
// 397:               version "2.0"
// 398:             end
// 399:             on_intel do
// 400:               version "1.0"
// 401:             end
// 402:             sha256 :no_check
// 403:
// 404:             url "https://brew.sh/foo-\#{version}.dmg"
// 405:             name "Foo"
// 406:           end
// 407:         RUBY
// 408:     end
// 409:
// 410:     it "splits root version and checksum stanzas when new versions differ by architecture" do
// 411:       contents = <<~RUBY
// 412:         cask "foo" do
// 413:           version "1.0"
// 414:           sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 415:
// 416:           url "https://brew.sh/foo-\#{version}.dmg"
// 417:           name "Foo"
// 418:         end
// 419:       RUBY
// 420:       cask = cask_from_contents(contents)
// 421:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0", intel: "1.5")
// 422:
// 423:       expect(
// 424:         bump_cask_pr.replace_version_and_checksum(cask, :no_check, new_version, contents),
// 425:       ).to eq <<~RUBY
// 426:         cask "foo" do
// 427:           on_arm do
// 428:             version "2.0"
// 429:           end
// 430:           on_intel do
// 431:             version "1.5"
// 432:           end
// 433:           on_arm do
// 434:             sha256 :no_check
// 435:           end
// 436:           on_intel do
// 437:             sha256 :no_check
// 438:           end
// 439:
// 440:           url "https://brew.sh/foo-\#{version}.dmg"
// 441:           name "Foo"
// 442:         end
// 443:       RUBY
// 444:     end
// 445:
// 446:     it "only updates matching version and checksum stanzas inside the target architecture block" do
// 447:       contents = <<~RUBY
// 448:         cask "foo" do
// 449:           on_arm do
// 450:             version "1.0"
// 451:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 452:           end
// 453:
// 454:           on_intel do
// 455:             version "1.0"
// 456:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 457:           end
// 458:
// 459:           url "https://brew.sh/foo-\#{version}.dmg"
// 460:           name "Foo"
// 461:         end
// 462:       RUBY
// 463:       cask = cask_from_contents(contents)
// 464:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0")
// 465:
// 466:       expect(
// 467:         bump_cask_pr.replace_version_and_checksum(cask, :no_check, new_version, contents),
// 468:       ).to eq <<~RUBY
// 469:         cask "foo" do
// 470:           on_arm do
// 471:             version "2.0"
// 472:             sha256 :no_check
// 473:           end
// 474:
// 475:           on_intel do
// 476:             version "1.0"
// 477:             sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 478:           end
// 479:
// 480:           url "https://brew.sh/foo-\#{version}.dmg"
// 481:           name "Foo"
// 482:         end
// 483:       RUBY
// 484:     end
// 485:
// 486:     it "updates arch-specific version and no_check checksum stanzas when new version is general" do
// 487:       contents = <<~RUBY
// 488:         cask "foo" do
// 489:           on_arm do
// 490:             version "1.0"
// 491:             sha256 :no_check
// 492:           end
// 493:
// 494:           on_intel do
// 495:             version "1.5"
// 496:             sha256 :no_check
// 497:           end
// 498:
// 499:           url "https://brew.sh/foo-\#{version}.dmg"
// 500:           name "Foo"
// 501:         end
// 502:       RUBY
// 503:       cask = cask_from_contents(contents)
// 504:       new_version = Homebrew::BumpVersionParser.new(general: "2.0")
// 505:
// 506:       expect(
// 507:         bump_cask_pr.replace_version_and_checksum(cask, new_hash, new_version, contents),
// 508:       ).to eq <<~RUBY
// 509:         cask "foo" do
// 510:           on_arm do
// 511:             version "2.0"
// 512:             sha256 "#{new_hash}"
// 513:           end
// 514:
// 515:           on_intel do
// 516:             version "2.0"
// 517:             sha256 "#{new_hash}"
// 518:           end
// 519:
// 520:           url "https://brew.sh/foo-\#{version}.dmg"
// 521:           name "Foo"
// 522:         end
// 523:       RUBY
// 524:     end
// 525:
// 526:     it "requires depends_on arch when a checksum is missing" do
// 527:       contents = <<~RUBY
// 528:         cask "foo" do
// 529:           arch arm: "arm64", intel: "x64"
// 530:           os macos: "macos", linux: "linux"
// 531:
// 532:           version "1.0"
// 533:           sha256 arm:          "#{old_hash}",
// 534:                  arm64_linux:  "#{new_hash}",
// 535:                  x86_64_linux: "#{intel_hash}"
// 536:
// 537:           url "https://brew.sh/foo-\#{os}-\#{arch}-\#{version}.zip"
// 538:           name "Foo"
// 539:
// 540:           on_macos do
// 541:             app "Foo.app"
// 542:           end
// 543:           on_linux do
// 544:             binary "foo"
// 545:           end
// 546:         end
// 547:       RUBY
// 548:       cask = cask_from_contents(contents)
// 549:       new_version = Homebrew::BumpVersionParser.new(general: "2.0")
// 550:       allow(Cask::Download).to receive(:new) { raise "download attempted" }
// 551:
// 552:       expect do
// 553:         bump_cask_pr.replace_version_and_checksum(cask, nil, new_version, contents)
// 554:       end.to raise_error(Cask::CaskError, /No checksum.*`depends_on arch:`/)
// 555:     end
// 556:
// 557:     it "leaves nested architecture stanzas unchanged when matching values could be replaced globally" do
// 558:       contents = <<~RUBY
// 559:         cask "foo" do
// 560:           on_macos do
// 561:             on_arm do
// 562:               version "1.0"
// 563:               sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 564:             end
// 565:
// 566:             on_intel do
// 567:               version "1.0"
// 568:               sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 569:             end
// 570:           end
// 571:
// 572:           url "https://brew.sh/foo-\#{version}.dmg"
// 573:           name "Foo"
// 574:         end
// 575:       RUBY
// 576:       cask = cask_from_contents(contents)
// 577:       new_version = Homebrew::BumpVersionParser.new(arm: "2.0")
// 578:
// 579:       expect(
// 580:         bump_cask_pr.replace_version_and_checksum(cask, :no_check, new_version, contents),
// 581:       ).to eq(contents)
// 582:     end
// 583:   end
// 584:
// 585:   describe "::check_throttle" do
// 586:     let(:c_throttle) do
// 587:       Cask::Cask.new("throttle-test") do
// 588:         version "1.2.3"
// 589:
// 590:         url "https://brew.sh/test-#{version}.dmg"
// 591:         name "Test"
// 592:         desc "Test cask"
// 593:         homepage "https://brew.sh"
// 594:
// 595:         livecheck do
// 596:           throttle 5
// 597:         end
// 598:       end
// 599:     end
// 600:     let(:c_throttle_days) do
// 601:       Cask::Cask.new("throttle-days-test") do
// 602:         version "1.2.3"
// 603:
// 604:         url "https://brew.sh/test-#{version}.dmg"
// 605:         name "Test"
// 606:         desc "Test cask"
// 607:         homepage "https://brew.sh"
// 608:
// 609:         livecheck do
// 610:           throttle days: 1
// 611:         end
// 612:       end
// 613:     end
// 614:     let(:c_throttle_rate_and_days) do
// 615:       Cask::Cask.new("throttle-rate-and-days-test") do
// 616:         version "1.2.3"
// 617:
// 618:         url "https://brew.sh/test-#{version}.dmg"
// 619:         name "Test"
// 620:         desc "Test cask"
// 621:         homepage "https://brew.sh"
// 622:
// 623:         livecheck do
// 624:           throttle 5, days: 1
// 625:         end
// 626:       end
// 627:     end
// 628:     let(:new_version) { Homebrew::BumpVersionParser.new(general: "1.2.5") }
// 629:     let(:throttle_error) { "Error: throttle-test should only be updated every 5 releases on multiples of 5\n" }
// 630:     let(:throttle_days_error) { "Error: throttle-days-test should only be updated every 1 day\n" }
// 631:     let(:throttle_rate_days_error) do
// 632:       "Error: throttle-rate-and-days-test should only be updated every 5 releases on multiples of 5 or 1 day\n"
// 633:     end
// 634:     let(:tap) { Tap.fetch("test", "tap") }
// 635:
// 636:     context "when cask is not in a tap" do
// 637:       it "outputs nothing" do
// 638:         expect { bump_cask_pr.check_throttle(c, new_version:) }.not_to output.to_stderr
// 639:       end
// 640:     end
// 641:
// 642:     context "when a livecheck throttle value isn't present" do
// 643:       it "does not throttle" do
// 644:         allow(c).to receive(:tap).and_return(tap)
// 645:         expect { bump_cask_pr.check_throttle(c, new_version:) }.not_to output.to_stderr
// 646:       end
// 647:     end
// 648:
// 649:     context "when new_version has no version values" do
// 650:       let(:empty_version) do
// 651:         version = new_version.clone
// 652:         version.remove_instance_variable(:@general)
// 653:         version
// 654:       end
// 655:
// 656:       it "does not throttle" do
// 657:         allow(c_throttle).to receive(:tap).and_return(tap)
// 658:         expect do
// 659:           bump_cask_pr.check_throttle(c_throttle, new_version: empty_version)
// 660:         end.not_to output.to_stderr
// 661:       end
// 662:     end
// 663:
// 664:     context "when patch version is a multiple of throttle_rate" do
// 665:       it "does not throttle" do
// 666:         allow(c_throttle).to receive(:tap).and_return(tap)
// 667:         expect do
// 668:           bump_cask_pr.check_throttle(c_throttle, new_version:)
// 669:         end.not_to output.to_stderr
// 670:       end
// 671:     end
// 672:
// 673:     context "when patch version is not a multiple of throttle_rate" do
// 674:       let(:new_version_indivisible) { Homebrew::BumpVersionParser.new(general: "1.2.4") }
// 675:
// 676:       it "throttles version" do
// 677:         allow(c_throttle).to receive(:tap).and_return(tap)
// 678:         expect do
// 679:           bump_cask_pr.check_throttle(c_throttle, new_version: new_version_indivisible)
// 680:         rescue SystemExit
// 681:           next
// 682:         end.to output(throttle_error).to_stderr
// 683:       end
// 684:     end
// 685:
// 686:     context "when patch version is not a multiple and throttle days are set" do
// 687:       let(:new_version_indivisible) { Homebrew::BumpVersionParser.new(general: "1.2.4") }
// 688:
// 689:       before do
// 690:         allow(c_throttle_rate_and_days).to receive(:tap).and_return(tap)
// 691:       end
// 692:
// 693:       it "throttles version when throttle interval has not elapsed" do
// 694:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 695:
// 696:         expect do
// 697:           bump_cask_pr.check_throttle(c_throttle_rate_and_days, new_version: new_version_indivisible)
// 698:         rescue SystemExit
// 699:           next
// 700:         end.to output(throttle_rate_days_error).to_stderr
// 701:       end
// 702:
// 703:       it "does not throttle when throttle interval has elapsed" do
// 704:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 705:
// 706:         expect do
// 707:           bump_cask_pr.check_throttle(c_throttle_rate_and_days, new_version: new_version_indivisible)
// 708:         end.not_to output.to_stderr
// 709:       end
// 710:     end
// 711:
// 712:     context "when only throttle days is set" do
// 713:       before do
// 714:         allow(c_throttle_days).to receive(:tap).and_return(tap)
// 715:       end
// 716:
// 717:       it "throttles version when throttle interval has not elapsed" do
// 718:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 719:
// 720:         expect do
// 721:           bump_cask_pr.check_throttle(c_throttle_days, new_version:)
// 722:         rescue SystemExit
// 723:           next
// 724:         end.to output(throttle_days_error).to_stderr
// 725:       end
// 726:
// 727:       it "does not throttle when throttle interval has elapsed" do
// 728:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 729:
// 730:         expect do
// 731:           bump_cask_pr.check_throttle(c_throttle_days, new_version:)
// 732:         end.not_to output.to_stderr
// 733:       end
// 734:     end
// 735:   end
// 736: end
