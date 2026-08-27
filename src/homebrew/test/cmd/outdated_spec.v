module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/outdated_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_formula_version(name, version, linked: false)` at line 10.
pub fn ruby_outdated_spec_l10_d1_install_formula_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_formula_version', ...args)
}

// Ruby method `write_formula(name, content)` at line 22.
pub fn ruby_outdated_spec_l22_d2_write_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_formula', ...args)
}

// Ruby it `it "requires one named argument with --minimum-version" do` at line 34.
pub fn ruby_outdated_spec_l34_d3_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "rejects multiple named arguments with --minimum-version" do` at line 39.
pub fn ruby_outdated_spec_l39_d4_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "excludes non-outdated auto-updating casks without --greedy-auto-updates", :cask do` at line 44.
pub fn ruby_outdated_spec_l44_d5_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "checks auto-updating casks with --greedy-auto-updates", :cask do` at line 54.
pub fn ruby_outdated_spec_l54_d6_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby it `it "excludes auto-updating casks when auto-update upgrades are disabled", :cask do` at line 64.
pub fn ruby_outdated_spec_l64_d7_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "outputs JSON for outdated formulae and casks", :cask, :integration_test do` at line 89.
pub fn ruby_outdated_spec_l89_d8_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Ruby it `it "reports a formula installed below the minimum version" do` at line 116.
pub fn ruby_outdated_spec_l116_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report a formula installed at --minimum-version" do` at line 127.
pub fn ruby_outdated_spec_l127_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reports a cask installed below --minimum-version", :cask do` at line 137.
pub fn ruby_outdated_spec_l137_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report a cask installed at --minimum-version", :cask do` at line 145.
pub fn ruby_outdated_spec_l145_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises UsageError for an invalid cask --minimum-version", :cask do` at line 152.
pub fn ruby_outdated_spec_l152_d13_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not report an uninstalled formula with --minimum-version" do` at line 159.
pub fn ruby_outdated_spec_l159_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "outputs JSON for a formula installed below --minimum-version" do` at line 168.
pub fn ruby_outdated_spec_l168_d15_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Ruby it `it "outputs JSON for a cask installed below --minimum-version", :cask do` at line 190.
pub fn ruby_outdated_spec_l190_d16_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/outdated"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Outdated do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   def install_formula_version(name, version, linked: false)
// 11:     keg_path = HOMEBREW_CELLAR/name/version
// 12:     keg_path.mkpath
// 13:     tab = Tab.empty
// 14:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 15:     tab.write
// 16:     return unless linked
// 17:
// 18:     (HOMEBREW_LINKED_KEGS/name).parent.mkpath
// 19:     FileUtils.ln_s(keg_path, HOMEBREW_LINKED_KEGS/name)
// 20:   end
// 21:
// 22:   def write_formula(name, content)
// 23:     Formulary.find_formula_in_tap(name, CoreTap.instance).tap do |path|
// 24:       path.dirname.mkpath
// 25:       path.write <<~RUBY
// 26:         class #{Formulary.class_s(name)} < Formula
// 27:         #{content.gsub(/^(?!$)/, "  ")}
// 28:         end
// 29:       RUBY
// 30:       CoreTap.instance.clear_cache
// 31:     end
// 32:   end
// 33:
// 34:   it "requires one named argument with --minimum-version" do
// 35:     expect { described_class.new(["--minimum-version=1.2.3"]).run }
// 36:       .to raise_error(UsageError, /`--minimum-version` requires exactly one formula or cask argument/)
// 37:   end
// 38:
// 39:   it "rejects multiple named arguments with --minimum-version" do
// 40:     expect { described_class.new(["foo", "bar", "--minimum-version=1.2.3"]).run }
// 41:       .to raise_error(UsageError, /`--minimum-version` requires exactly one formula or cask argument/)
// 42:   end
// 43:
// 44:   it "excludes non-outdated auto-updating casks without --greedy-auto-updates", :cask do
// 45:     cask = Cask::CaskLoader.load(cask_path("auto-updates"))
// 46:     cmd = described_class.new([])
// 47:
// 48:     expect(cask).to receive(:outdated?)
// 49:       .with(greedy: false, greedy_latest: false, greedy_auto_updates: false)
// 50:       .and_return(false)
// 51:     expect(cmd.select_outdated([cask])).to be_empty
// 52:   end
// 53:
// 54:   it "checks auto-updating casks with --greedy-auto-updates", :cask do
// 55:     cask = Cask::CaskLoader.load(cask_path("auto-updates"))
// 56:     cmd = described_class.new(["--greedy-auto-updates"])
// 57:
// 58:     expect(cask).to receive(:outdated?)
// 59:       .with(greedy: false, greedy_latest: false, greedy_auto_updates: true)
// 60:       .and_return(true)
// 61:     expect(cmd.select_outdated([cask])).to eq([cask])
// 62:   end
// 63:
// 64:   it "excludes auto-updating casks when auto-update upgrades are disabled", :cask do
// 65:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/auto-updates")))
// 66:
// 67:     info_plist = Pathname(Cask::CaskLoader.load(cask_path("auto-updates")).config.appdir)
// 68:                  .join("MyFancyApp.app/Contents/Info.plist")
// 69:     info_plist.dirname.mkpath
// 70:     info_plist.write <<~PLIST
// 71:       <?xml version="1.0" encoding="UTF-8"?>
// 72:       <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 73:       <plist version="1.0">
// 74:       <dict>
// 75:         <key>CFBundleShortVersionString</key>
// 76:         <string>2.57</string>
// 77:         <key>CFBundleVersion</key>
// 78:         <string>2057</string>
// 79:       </dict>
// 80:       </plist>
// 81:     PLIST
// 82:
// 83:     with_env(HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS: "1") do
// 84:       expect { described_class.new(["--cask"]).run }
// 85:         .not_to output.to_stdout
// 86:     end
// 87:   end
// 88:
// 89:   it "outputs JSON for outdated formulae and casks", :cask, :integration_test do
// 90:     setup_test_formula "testball"
// 91:     (HOMEBREW_CELLAR/"testball/0.0.1/foo").mkpath
// 92:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/local-caffeine")))
// 93:
// 94:     expected_json = JSON.pretty_generate({
// 95:       formulae: [{
// 96:         name:               "testball",
// 97:         installed_versions: ["0.0.1"],
// 98:         current_version:    "0.1",
// 99:         pinned:             false,
// 100:         pinned_version:     nil,
// 101:       }],
// 102:       casks:    [{
// 103:         name:               "local-caffeine",
// 104:         installed_versions: ["1.2.2"],
// 105:         current_version:    "1.2.3",
// 106:         pinned:             false,
// 107:         pinned_version:     nil,
// 108:       }],
// 109:     })
// 110:
// 111:     expect { brew "outdated", "--json=v2" }
// 112:       .to output("#{expected_json}\n").to_stdout
// 113:       .and be_a_success
// 114:   end
// 115:
// 116:   it "reports a formula installed below the minimum version" do
// 117:     write_formula "minimum-version-formula", <<~RUBY
// 118:       url "https://brew.sh/minimum-version-formula-1.2.3"
// 119:     RUBY
// 120:     install_formula_version "minimum-version-formula", "1.2.2"
// 121:
// 122:     expect { described_class.new(["minimum-version-formula", "--min-version=1.2.3"]).run }
// 123:       .to output("minimum-version-formula\n").to_stdout
// 124:     expect(Homebrew).to have_failed
// 125:   end
// 126:
// 127:   it "does not report a formula installed at --minimum-version" do
// 128:     write_formula "minimum-version-formula", <<~RUBY
// 129:       url "https://brew.sh/minimum-version-formula-1.2.3"
// 130:     RUBY
// 131:     install_formula_version "minimum-version-formula", "1.2.3", linked: true
// 132:
// 133:     expect { described_class.new(["minimum-version-formula", "--minimum-version=1.2.3"]).run }
// 134:       .not_to output.to_stdout
// 135:   end
// 136:
// 137:   it "reports a cask installed below --minimum-version", :cask do
// 138:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/local-caffeine")))
// 139:
// 140:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1.2.3"]).run }
// 141:       .to output("local-caffeine\n").to_stdout
// 142:     expect(Homebrew).to have_failed
// 143:   end
// 144:
// 145:   it "does not report a cask installed at --minimum-version", :cask do
// 146:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("local-caffeine")))
// 147:
// 148:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1.2.3"]).run }
// 149:       .not_to output.to_stdout
// 150:   end
// 151:
// 152:   it "raises UsageError for an invalid cask --minimum-version", :cask do
// 153:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("local-caffeine")))
// 154:
// 155:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1/2"]).run }
// 156:       .to raise_error(UsageError, %r{invalid `--minimum-version`: 1/2})
// 157:   end
// 158:
// 159:   it "does not report an uninstalled formula with --minimum-version" do
// 160:     write_formula "minimum-version-formula", <<~RUBY
// 161:       url "https://brew.sh/minimum-version-formula-1.2.3"
// 162:     RUBY
// 163:
// 164:     expect { described_class.new(["minimum-version-formula", "--minimum-version=1.2.3"]).run }
// 165:       .not_to output.to_stdout
// 166:   end
// 167:
// 168:   it "outputs JSON for a formula installed below --minimum-version" do
// 169:     write_formula "minimum-version-formula", <<~RUBY
// 170:       url "https://brew.sh/minimum-version-formula-1.2.3"
// 171:     RUBY
// 172:     install_formula_version "minimum-version-formula", "1.2.2"
// 173:
// 174:     expected_json = JSON.pretty_generate({
// 175:       formulae: [{
// 176:         name:               "minimum-version-formula",
// 177:         installed_versions: ["1.2.2"],
// 178:         current_version:    "1.2.3",
// 179:         pinned:             false,
// 180:         pinned_version:     nil,
// 181:       }],
// 182:       casks:    [],
// 183:     })
// 184:
// 185:     expect { described_class.new(["minimum-version-formula", "--minimum-version=1.2.3", "--json=v2"]).run }
// 186:       .to output("#{expected_json}\n").to_stdout
// 187:     expect(Homebrew).to have_failed
// 188:   end
// 189:
// 190:   it "outputs JSON for a cask installed below --minimum-version", :cask do
// 191:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/local-caffeine")))
// 192:
// 193:     expected_json = JSON.pretty_generate({
// 194:       formulae: [],
// 195:       casks:    [{
// 196:         name:               "local-caffeine",
// 197:         installed_versions: ["1.2.2"],
// 198:         current_version:    "1.2.3",
// 199:         pinned:             false,
// 200:         pinned_version:     nil,
// 201:       }],
// 202:     })
// 203:
// 204:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1.2.3", "--json=v2"]).run }
// 205:       .to output("#{expected_json}\n").to_stdout
// 206:     expect(Homebrew).to have_failed
// 207:   end
// 208: end
