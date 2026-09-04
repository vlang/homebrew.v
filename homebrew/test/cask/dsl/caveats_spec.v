module dsl

import ruby
import homebrew.cask.dsl as cask_dsl

// Translated from Homebrew/brew `test/cask/dsl/caveats_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:caveats) { described_class.new(cask) }` at line 7.
pub fn ruby_caveats_spec_l7_d1_caveats() cask_dsl.CaskCaveats {
	value := cask_dsl.ruby_caveats_l23_d1_initialize(ruby_caveats_spec_l9_d2_cask())
	return cask_dsl.cask_caveats_from_value(value) or { panic(err) }
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-caveats-everything")) }` at line 9.
pub fn ruby_caveats_spec_l9_d2_cask() ruby.Value {
	return caveats_spec_cask('sonoma', '/opt/homebrew', 'intel', false)
}

// Ruby let `let(:dsl) { caveats }` at line 10.
pub fn ruby_caveats_spec_l10_d3_dsl() cask_dsl.CaskCaveats {
	return ruby_caveats_spec_l7_d1_caveats()
}

// Ruby it `it "includes caveat text for methods and strings" do` at line 15.
pub fn ruby_caveats_spec_l15_d4_includes() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('logout', [])
	caveats = caveats_spec_eval(caveats, ruby.string_value('Custom caveat text.'))
	return caveats_spec_text(caveats) == 'Custom caveat text.\n\n${caveats_spec_logout_text()}'
}

// Ruby it `it "excludes requires_rosetta caveat text" do` at line 32.
pub fn ruby_caveats_spec_l32_d5_excludes() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'arm', false)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_text(caveats) == caveats_spec_rosetta_text() && caveats_spec_text_without_conditional(caveats) == ''
}

// Ruby it `it "keeps non-conditional built-in caveats" do` at line 50.
pub fn ruby_caveats_spec_l50_d6_keeps() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('reboot', [])
	return caveats_spec_text_without_conditional(caveats) == caveats_spec_reboot_text()
}

// Ruby it `it "keeps custom caveats" do` at line 62.
pub fn ruby_caveats_spec_l62_d7_keeps() bool {
	caveats := caveats_spec_eval(ruby_caveats_spec_l7_d1_caveats(), ruby.string_value('Custom caveat text\n'))
	return caveats_spec_text_without_conditional(caveats) == 'Custom caveat text\n'
}

// Ruby it `it "returns true for invoked caveats" do` at line 70.
pub fn ruby_caveats_spec_l70_d8_returns() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'arm', false)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_invoked(caveats, 'requires_rosetta')
}

// Ruby it `it "returns true even when caveat condition is false" do` at line 79.
pub fn ruby_caveats_spec_l79_d9_returns() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'intel', false)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_invoked(caveats, 'requires_rosetta') && caveats_spec_text(caveats) == ''
}

// Ruby it `it "returns false for non-invoked caveats" do` at line 89.
pub fn ruby_caveats_spec_l89_d10_returns() bool {
	return !caveats_spec_invoked(ruby_caveats_spec_l7_d1_caveats(), 'requires_rosetta')
}

// Ruby it `it "returns nil if the block does not return anything" do` at line 95.
pub fn ruby_caveats_spec_l95_d11_returns() bool {
	caveats := caveats_spec_eval(ruby_caveats_spec_l7_d1_caveats(), caveats_spec_nil())
	return caveats_spec_text(caveats) == ''
}

// Ruby it `it "returns System Settings on macOS Sonoma or later" do` at line 105.
pub fn ruby_caveats_spec_l105_d12_returns() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'intel', false)
	caveats.invoke('kext', [])
	return caveats_spec_text(caveats) == caveats_spec_kext_text()
}

// Ruby it `it "does not return kext caveat text on macOS Ventura and earlier" do` at line 123.
pub fn ruby_caveats_spec_l123_d13_does() bool {
	mut caveats := caveats_spec_new('ventura', '/opt/homebrew', 'intel', false)
	caveats.invoke('kext', [])
	return caveats_spec_text(caveats) == ''
}

// Ruby it `it "returns System Settings text on macOS Ventura or later" do` at line 134.
pub fn ruby_caveats_spec_l134_d14_returns() bool {
	mut caveats := caveats_spec_new('ventura', '/opt/homebrew', 'intel', false)
	caveats.invoke('unsigned_accessibility', [])
	return caveats_spec_text(caveats) == caveats_spec_accessibility_text('System Settings → Privacy & Security')
}

// Ruby it `it "returns System Preferences text on macOS Monterey and earlier" do` at line 152.
pub fn ruby_caveats_spec_l152_d15_returns() bool {
	mut caveats := caveats_spec_new('monterey', '/opt/homebrew', 'intel', false)
	caveats.invoke('unsigned_accessibility', [])
	return caveats_spec_text(caveats) == caveats_spec_accessibility_text('System Preferences → Security & Privacy → Privacy')
}

// Ruby it `it "returns PATH environment variable caveat text" do` at line 172.
pub fn ruby_caveats_spec_l172_d16_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('path_environment_variable', ['/example/path'])
	return caveats_spec_text(caveats) == 'To use ${caveats_spec_token}, you may need to add the /example/path directory\nto your PATH environment variable, e.g. (for Bash shell):\n  export PATH=/example/path:"\$PATH"\n'
}

// Ruby it `it "returns Zsh PATH helper caveat text" do` at line 188.
pub fn ruby_caveats_spec_l188_d17_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('zsh_path_helper', ['/example/path'])
	return caveats_spec_text(caveats) == 'To use ${caveats_spec_token}, zsh users may need to add the following line to their\n~/.zprofile. (Among other effects, /example/path will be added to the\nPATH environment variable):\n  eval `/usr/libexec/path_helper -s`\n'
}

// Ruby it `it "returns files in /usr/local caveat text when HOMEBREW_PREFIX starts with /usr/local" do` at line 205.
pub fn ruby_caveats_spec_l205_d18_returns() bool {
	mut caveats := caveats_spec_new('sonoma', '/usr/local', 'intel', false)
	caveats.invoke('files_in_usr_local', [])
	return caveats_spec_text(caveats) == "Cask ${caveats_spec_token} installs files under /usr/local. The presence of such\nfiles can cause warnings when running `brew doctor`, which is considered\nto be a bug in Homebrew's cask handling.\n"
}

// Ruby it `it "does not return caveat text when HOMEBREW_PREFIX does not start /usr/local" do` at line 220.
pub fn ruby_caveats_spec_l220_d19_does() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'intel', false)
	caveats.invoke('files_in_usr_local', [])
	return caveats_spec_text(caveats) == ''
}

// Ruby it `it "returns generic required Java caveat text without an argument" do` at line 231.
pub fn ruby_caveats_spec_l231_d20_returns() bool {
	return caveats_spec_java_text([]) == '${caveats_spec_token} requires Java. You can install the latest version with:\n  brew install --cask temurin\n'
}

// Ruby it `it "returns generic required Java caveat text for `:any` value" do` at line 244.
pub fn ruby_caveats_spec_l244_d21_returns() bool {
	return caveats_spec_java_text([':any']) == '${caveats_spec_token} requires Java. You can install the latest version with:\n  brew install --cask temurin\n'
}

// Ruby it `it "returns required Java caveat text with latest temurin for a version string including a plus sign" do` at line 257.
pub fn ruby_caveats_spec_l257_d22_returns() bool {
	return caveats_spec_java_text(['11+']) == '${caveats_spec_token} requires Java 11+. You can install the latest version with:\n  brew install --cask temurin\n'
}

// Ruby it `it "returns required Java caveat text with versioned temurin for a version string not including a plus sign" do` at line 270.
pub fn ruby_caveats_spec_l270_d23_returns() bool {
	return caveats_spec_java_text(['11']) == '${caveats_spec_token} requires Java 11. You can install it with:\n  brew install --cask temurin@11\n'
}

// Ruby it `it "returns Rosetta caveat text if the current arch is :arm and Rosetta 2 is not installed" do` at line 285.
pub fn ruby_caveats_spec_l285_d24_returns() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'arm', false)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_text(caveats) == caveats_spec_rosetta_text()
}

// Ruby it `it "does not return a caveat string if the current arch is :arm but Rosetta 2 is already installed" do` at line 302.
pub fn ruby_caveats_spec_l302_d25_does() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'arm', true)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_text(caveats) == ''
}

// Ruby it `it "does not return a caveat string if the current arch is not :arm" do` at line 312.
pub fn ruby_caveats_spec_l312_d26_does() bool {
	mut caveats := caveats_spec_new('sonoma', '/opt/homebrew', 'intel', false)
	caveats.invoke('requires_rosetta', [])
	return caveats_spec_text(caveats) == ''
}

// Ruby it `it "returns log out caveat text" do` at line 323.
pub fn ruby_caveats_spec_l323_d27_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('logout', [])
	return caveats_spec_text(caveats) == caveats_spec_logout_text()
}

// Ruby it `it "returns reboot caveat text" do` at line 337.
pub fn ruby_caveats_spec_l337_d28_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('reboot', [])
	return caveats_spec_text(caveats) == caveats_spec_reboot_text()
}

// Ruby it `it "returns license caveat text" do` at line 351.
pub fn ruby_caveats_spec_l351_d29_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('license', ['https://brew.sh/test-license/'])
	return caveats_spec_text(caveats) == 'Installing ${caveats_spec_token} means you have AGREED to the license at:\n  https://brew.sh/test-license/\n'
}

// Ruby it `it "returns license caveat text" do` at line 366.
pub fn ruby_caveats_spec_l366_d30_returns() bool {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('free_license', ['https://brew.sh/test-free-license/'])
	return caveats_spec_text(caveats) == 'The vendor offers a free license for ${caveats_spec_token} at:\n  https://brew.sh/test-free-license/\n'
}

const caveats_spec_token = 'with-caveats-everything'

fn caveats_spec_cask(macos_version string, homebrew_prefix string, system_arch string,
	rosetta_installed bool) ruby.Value {
	return ruby.Value{
		type_name: 'Cask'
		repr: caveats_spec_token
		map_data: {
			'token':             ruby.string_value(caveats_spec_token)
			'macos_version':     ruby.string_value(macos_version)
			'homebrew_prefix':   ruby.string_value(homebrew_prefix)
			'system_arch':       ruby.string_value(system_arch)
			'rosetta_installed': ruby.bool_value(rosetta_installed)
		}
	}
}

fn caveats_spec_new(macos_version string, homebrew_prefix string, system_arch string,
	rosetta_installed bool) cask_dsl.CaskCaveats {
	return cask_dsl.new_cask_caveats(caveats_spec_cask(macos_version, homebrew_prefix, system_arch, rosetta_installed))
}

fn caveats_spec_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn caveats_spec_eval(caveats cask_dsl.CaskCaveats,
	result ruby.Value) cask_dsl.CaskCaveats {
	value := cask_dsl.ruby_caveats_l80_d9_eval_caveats(cask_dsl.cask_caveats_value(caveats), result)
	return cask_dsl.cask_caveats_from_value(value) or { panic(err) }
}

fn caveats_spec_text(caveats cask_dsl.CaskCaveats) string {
	return cask_dsl.ruby_caveats_l51_d5_to_s(cask_dsl.cask_caveats_value(caveats)).as_string()
}

fn caveats_spec_text_without_conditional(caveats cask_dsl.CaskCaveats) string {
	return cask_dsl.ruby_caveats_l59_d6_to_s_without_conditional(cask_dsl.cask_caveats_value(caveats)).as_string()
}

fn caveats_spec_invoked(caveats cask_dsl.CaskCaveats, name string) bool {
	return cask_dsl.ruby_caveats_l68_d7_invoked(cask_dsl.cask_caveats_value(caveats), ruby.Value{
		type_name: 'Symbol'
		repr: ':${name}'
	}).as_bool() or { false }
}

fn caveats_spec_java_text(arguments []string) string {
	mut caveats := ruby_caveats_spec_l7_d1_caveats()
	caveats.invoke('depends_on_java', arguments)
	return caveats_spec_text(caveats)
}

fn caveats_spec_logout_text() string {
	return 'You must log out and log back in for the installation of ${caveats_spec_token} to take effect.\n'
}

fn caveats_spec_reboot_text() string {
	return 'You must reboot for the installation of ${caveats_spec_token} to take effect.\n'
}

fn caveats_spec_rosetta_text() string {
	return '${caveats_spec_token} is built for Intel macOS and so requires Rosetta 2 to be installed.\nYou can install Rosetta 2 with:\n  softwareupdate --install-rosetta --agree-to-license\nNote that it is very difficult to remove Rosetta 2 once it is installed.\n'
}

fn caveats_spec_kext_text() string {
	return '${caveats_spec_token} requires a kernel extension to work.\nIf the installation fails, retry after you enable it in:\n  System Settings → Privacy & Security\n\nFor more information, refer to vendor documentation or this Apple Technical Note:\n  https://developer.apple.com/library/content/technotes/tn2459/_index.html\n'
}

fn caveats_spec_accessibility_text(navigation string) string {
	return '${caveats_spec_token} is not signed and requires Accessibility access,\nso you will need to re-grant Accessibility access every time the app is updated.\n\nEnable or re-enable it in:\n  ${navigation} → Accessibility\nTo re-enable, untick and retick ${caveats_spec_token}.app.\n'
}

pub fn caveats_spec_all_boundaries() []ruby.Value {
	return [
		cask_dsl.cask_caveats_value(ruby_caveats_spec_l7_d1_caveats()),
		ruby_caveats_spec_l9_d2_cask(),
		cask_dsl.cask_caveats_value(ruby_caveats_spec_l10_d3_dsl()),
		ruby.bool_value(ruby_caveats_spec_l15_d4_includes()),
		ruby.bool_value(ruby_caveats_spec_l32_d5_excludes()),
		ruby.bool_value(ruby_caveats_spec_l50_d6_keeps()),
		ruby.bool_value(ruby_caveats_spec_l62_d7_keeps()),
		ruby.bool_value(ruby_caveats_spec_l70_d8_returns()),
		ruby.bool_value(ruby_caveats_spec_l79_d9_returns()),
		ruby.bool_value(ruby_caveats_spec_l89_d10_returns()),
		ruby.bool_value(ruby_caveats_spec_l95_d11_returns()),
		ruby.bool_value(ruby_caveats_spec_l105_d12_returns()),
		ruby.bool_value(ruby_caveats_spec_l123_d13_does()),
		ruby.bool_value(ruby_caveats_spec_l134_d14_returns()),
		ruby.bool_value(ruby_caveats_spec_l152_d15_returns()),
		ruby.bool_value(ruby_caveats_spec_l172_d16_returns()),
		ruby.bool_value(ruby_caveats_spec_l188_d17_returns()),
		ruby.bool_value(ruby_caveats_spec_l205_d18_returns()),
		ruby.bool_value(ruby_caveats_spec_l220_d19_does()),
		ruby.bool_value(ruby_caveats_spec_l231_d20_returns()),
		ruby.bool_value(ruby_caveats_spec_l244_d21_returns()),
		ruby.bool_value(ruby_caveats_spec_l257_d22_returns()),
		ruby.bool_value(ruby_caveats_spec_l270_d23_returns()),
		ruby.bool_value(ruby_caveats_spec_l285_d24_returns()),
		ruby.bool_value(ruby_caveats_spec_l302_d25_does()),
		ruby.bool_value(ruby_caveats_spec_l312_d26_does()),
		ruby.bool_value(ruby_caveats_spec_l323_d27_returns()),
		ruby.bool_value(ruby_caveats_spec_l337_d28_returns()),
		ruby.bool_value(ruby_caveats_spec_l351_d29_returns()),
		ruby.bool_value(ruby_caveats_spec_l366_d30_returns()),
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/cask/dsl/shared_examples/base"
// 5:
// 6: RSpec.describe Cask::DSL::Caveats, :cask do
// 7:   subject(:caveats) { described_class.new(cask) }
// 8:
// 9:   let(:cask) { Cask::CaskLoader.load(cask_path("with-caveats-everything")) }
// 10:   let(:dsl) { caveats }
// 11:
// 12:   it_behaves_like Cask::DSL::Base
// 13:
// 14:   describe "#to_s" do
// 15:     it "includes caveat text for methods and strings" do
// 16:       expected_caveats_str = <<~EOS
// 17:         Custom caveat text.
// 18:
// 19:         You must log out and log back in for the installation of #{cask} to take effect.
// 20:       EOS
// 21:
// 22:       caveats.eval_caveats do
// 23:         logout
// 24:         "Custom caveat text."
// 25:       end
// 26:
// 27:       expect(caveats.to_s).to eq(expected_caveats_str)
// 28:     end
// 29:   end
// 30:
// 31:   describe "#to_s_without_conditional" do
// 32:     it "excludes requires_rosetta caveat text" do
// 33:       expected_caveats_str = <<~EOS
// 34:         #{cask} is built for Intel macOS and so requires Rosetta 2 to be installed.
// 35:         You can install Rosetta 2 with:
// 36:           softwareupdate --install-rosetta --agree-to-license
// 37:         Note that it is very difficult to remove Rosetta 2 once it is installed.
// 38:       EOS
// 39:
// 40:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:arm)
// 41:       allow(Hardware::CPU).to receive(:rosetta_installed?).and_return(false)
// 42:       caveats.eval_caveats do
// 43:         requires_rosetta
// 44:       end
// 45:
// 46:       expect(caveats.to_s).to eq(expected_caveats_str)
// 47:       expect(caveats.to_s_without_conditional).to be_empty
// 48:     end
// 49:
// 50:     it "keeps non-conditional built-in caveats" do
// 51:       expected_caveats_str = <<~EOS
// 52:         You must reboot for the installation of #{cask} to take effect.
// 53:       EOS
// 54:
// 55:       caveats.eval_caveats do
// 56:         reboot
// 57:       end
// 58:
// 59:       expect(caveats.to_s_without_conditional).to eq(expected_caveats_str)
// 60:     end
// 61:
// 62:     it "keeps custom caveats" do
// 63:       caveats.eval_caveats { "Custom caveat text\n" }
// 64:
// 65:       expect(caveats.to_s_without_conditional).to eq("Custom caveat text\n")
// 66:     end
// 67:   end
// 68:
// 69:   describe "#invoked?" do
// 70:     it "returns true for invoked caveats" do
// 71:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:arm)
// 72:       caveats.eval_caveats do
// 73:         requires_rosetta
// 74:       end
// 75:
// 76:       expect(caveats.invoked?(:requires_rosetta)).to be true
// 77:     end
// 78:
// 79:     it "returns true even when caveat condition is false" do
// 80:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:intel)
// 81:       caveats.eval_caveats do
// 82:         requires_rosetta
// 83:       end
// 84:
// 85:       expect(caveats.invoked?(:requires_rosetta)).to be true
// 86:       expect(caveats.to_s).to be_empty
// 87:     end
// 88:
// 89:     it "returns false for non-invoked caveats" do
// 90:       expect(caveats.invoked?(:requires_rosetta)).to be false
// 91:     end
// 92:   end
// 93:
// 94:   describe "#eval_caveats" do
// 95:     it "returns nil if the block does not return anything" do
// 96:       caveats.eval_caveats do
// 97:         # Intentionally empty to exercise the `return unless result` guard
// 98:       end
// 99:
// 100:       expect(caveats.to_s).to be_empty
// 101:     end
// 102:   end
// 103:
// 104:   describe "#kext" do
// 105:     it "returns System Settings on macOS Sonoma or later" do
// 106:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:sonoma))
// 107:       expected_caveats_str = <<~EOS
// 108:         #{cask} requires a kernel extension to work.
// 109:         If the installation fails, retry after you enable it in:
// 110:           System Settings → Privacy & Security
// 111:
// 112:         For more information, refer to vendor documentation or this Apple Technical Note:
// 113:           https://developer.apple.com/library/content/technotes/tn2459/_index.html
// 114:       EOS
// 115:
// 116:       caveats.eval_caveats do
// 117:         kext
// 118:       end
// 119:
// 120:       expect(caveats.to_s).to eq(expected_caveats_str)
// 121:     end
// 122:
// 123:     it "does not return kext caveat text on macOS Ventura and earlier" do
// 124:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:ventura))
// 125:       caveats.eval_caveats do
// 126:         kext
// 127:       end
// 128:
// 129:       expect(caveats.to_s).to be_empty
// 130:     end
// 131:   end
// 132:
// 133:   describe "#unsigned_accessibility" do
// 134:     it "returns System Settings text on macOS Ventura or later" do
// 135:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:ventura))
// 136:       expected_caveats_str = <<~EOS
// 137:         #{cask} is not signed and requires Accessibility access,
// 138:         so you will need to re-grant Accessibility access every time the app is updated.
// 139:
// 140:         Enable or re-enable it in:
// 141:           System Settings → Privacy & Security → Accessibility
// 142:         To re-enable, untick and retick #{cask}.app.
// 143:       EOS
// 144:
// 145:       caveats.eval_caveats do
// 146:         unsigned_accessibility
// 147:       end
// 148:
// 149:       expect(caveats.to_s).to eq(expected_caveats_str)
// 150:     end
// 151:
// 152:     it "returns System Preferences text on macOS Monterey and earlier" do
// 153:       allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:monterey))
// 154:       expected_caveats_str = <<~EOS
// 155:         #{cask} is not signed and requires Accessibility access,
// 156:         so you will need to re-grant Accessibility access every time the app is updated.
// 157:
// 158:         Enable or re-enable it in:
// 159:           System Preferences → Security & Privacy → Privacy → Accessibility
// 160:         To re-enable, untick and retick #{cask}.app.
// 161:       EOS
// 162:
// 163:       caveats.eval_caveats do
// 164:         unsigned_accessibility
// 165:       end
// 166:
// 167:       expect(caveats.to_s).to eq(expected_caveats_str)
// 168:     end
// 169:   end
// 170:
// 171:   describe "#path_environment_variable" do
// 172:     it "returns PATH environment variable caveat text" do
// 173:       expected_caveats_str = <<~EOS
// 174:         To use #{cask}, you may need to add the /example/path directory
// 175:         to your PATH environment variable, e.g. (for Bash shell):
// 176:           export PATH=/example/path:"$PATH"
// 177:       EOS
// 178:
// 179:       caveats.eval_caveats do
// 180:         path_environment_variable "/example/path"
// 181:       end
// 182:
// 183:       expect(caveats.to_s).to eq(expected_caveats_str)
// 184:     end
// 185:   end
// 186:
// 187:   describe "#zsh_path_helper" do
// 188:     it "returns Zsh PATH helper caveat text" do
// 189:       expected_caveats_str = <<~EOS
// 190:         To use #{cask}, zsh users may need to add the following line to their
// 191:         ~/.zprofile. (Among other effects, /example/path will be added to the
// 192:         PATH environment variable):
// 193:           eval `/usr/libexec/path_helper -s`
// 194:       EOS
// 195:
// 196:       caveats.eval_caveats do
// 197:         zsh_path_helper "/example/path"
// 198:       end
// 199:
// 200:       expect(caveats.to_s).to eq(expected_caveats_str)
// 201:     end
// 202:   end
// 203:
// 204:   describe "#files_in_usr_local" do
// 205:     it "returns files in /usr/local caveat text when HOMEBREW_PREFIX starts with /usr/local" do
// 206:       stub_const("HOMEBREW_PREFIX", "/usr/local")
// 207:       expected_caveats_str = <<~EOS
// 208:         Cask #{cask} installs files under /usr/local. The presence of such
// 209:         files can cause warnings when running `brew doctor`, which is considered
// 210:         to be a bug in Homebrew's cask handling.
// 211:       EOS
// 212:
// 213:       caveats.eval_caveats do
// 214:         files_in_usr_local
// 215:       end
// 216:
// 217:       expect(caveats.to_s).to eq(expected_caveats_str)
// 218:     end
// 219:
// 220:     it "does not return caveat text when HOMEBREW_PREFIX does not start /usr/local" do
// 221:       stub_const("HOMEBREW_PREFIX", "/opt/homebrew")
// 222:       caveats.eval_caveats do
// 223:         files_in_usr_local
// 224:       end
// 225:
// 226:       expect(caveats.to_s).to be_empty
// 227:     end
// 228:   end
// 229:
// 230:   describe "#depends_on_java" do
// 231:     it "returns generic required Java caveat text without an argument" do
// 232:       expected_caveats_str = <<~EOS
// 233:         #{cask} requires Java. You can install the latest version with:
// 234:           brew install --cask temurin
// 235:       EOS
// 236:
// 237:       caveats.eval_caveats do
// 238:         depends_on_java
// 239:       end
// 240:
// 241:       expect(caveats.to_s).to eq(expected_caveats_str)
// 242:     end
// 243:
// 244:     it "returns generic required Java caveat text for `:any` value" do
// 245:       expected_caveats_str = <<~EOS
// 246:         #{cask} requires Java. You can install the latest version with:
// 247:           brew install --cask temurin
// 248:       EOS
// 249:
// 250:       caveats.eval_caveats do
// 251:         depends_on_java :any
// 252:       end
// 253:
// 254:       expect(caveats.to_s).to eq(expected_caveats_str)
// 255:     end
// 256:
// 257:     it "returns required Java caveat text with latest temurin for a version string including a plus sign" do
// 258:       expected_caveats_str = <<~EOS
// 259:         #{cask} requires Java 11+. You can install the latest version with:
// 260:           brew install --cask temurin
// 261:       EOS
// 262:
// 263:       caveats.eval_caveats do
// 264:         depends_on_java "11+"
// 265:       end
// 266:
// 267:       expect(caveats.to_s).to eq(expected_caveats_str)
// 268:     end
// 269:
// 270:     it "returns required Java caveat text with versioned temurin for a version string not including a plus sign" do
// 271:       expected_caveats_str = <<~EOS
// 272:         #{cask} requires Java 11. You can install it with:
// 273:           brew install --cask temurin@11
// 274:       EOS
// 275:
// 276:       caveats.eval_caveats do
// 277:         depends_on_java "11"
// 278:       end
// 279:
// 280:       expect(caveats.to_s).to eq(expected_caveats_str)
// 281:     end
// 282:   end
// 283:
// 284:   describe "#requires_rosetta" do
// 285:     it "returns Rosetta caveat text if the current arch is :arm and Rosetta 2 is not installed" do
// 286:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:arm)
// 287:       allow(Hardware::CPU).to receive(:rosetta_installed?).and_return(false)
// 288:       expected_caveats_str = <<~EOS
// 289:         #{cask} is built for Intel macOS and so requires Rosetta 2 to be installed.
// 290:         You can install Rosetta 2 with:
// 291:           softwareupdate --install-rosetta --agree-to-license
// 292:         Note that it is very difficult to remove Rosetta 2 once it is installed.
// 293:       EOS
// 294:
// 295:       caveats.eval_caveats do
// 296:         requires_rosetta
// 297:       end
// 298:
// 299:       expect(caveats.to_s).to eq(expected_caveats_str)
// 300:     end
// 301:
// 302:     it "does not return a caveat string if the current arch is :arm but Rosetta 2 is already installed" do
// 303:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:arm)
// 304:       allow(Hardware::CPU).to receive(:rosetta_installed?).and_return(true)
// 305:       caveats.eval_caveats do
// 306:         requires_rosetta
// 307:       end
// 308:
// 309:       expect(caveats.to_s).to be_empty
// 310:     end
// 311:
// 312:     it "does not return a caveat string if the current arch is not :arm" do
// 313:       allow(Homebrew::SimulateSystem).to receive(:current_arch).and_return(:intel)
// 314:       caveats.eval_caveats do
// 315:         requires_rosetta
// 316:       end
// 317:
// 318:       expect(caveats.to_s).to be_empty
// 319:     end
// 320:   end
// 321:
// 322:   describe "#logout" do
// 323:     it "returns log out caveat text" do
// 324:       expected_caveats_str = <<~EOS
// 325:         You must log out and log back in for the installation of #{cask} to take effect.
// 326:       EOS
// 327:
// 328:       caveats.eval_caveats do
// 329:         logout
// 330:       end
// 331:
// 332:       expect(caveats.to_s).to eq(expected_caveats_str)
// 333:     end
// 334:   end
// 335:
// 336:   describe "#reboot" do
// 337:     it "returns reboot caveat text" do
// 338:       expected_caveats_str = <<~EOS
// 339:         You must reboot for the installation of #{cask} to take effect.
// 340:       EOS
// 341:
// 342:       caveats.eval_caveats do
// 343:         reboot
// 344:       end
// 345:
// 346:       expect(caveats.to_s).to eq(expected_caveats_str)
// 347:     end
// 348:   end
// 349:
// 350:   describe "#license" do
// 351:     it "returns license caveat text" do
// 352:       expected_caveats_str = <<~EOS
// 353:         Installing #{cask} means you have AGREED to the license at:
// 354:           https://brew.sh/test-license/
// 355:       EOS
// 356:
// 357:       caveats.eval_caveats do
// 358:         license "https://brew.sh/test-license/"
// 359:       end
// 360:
// 361:       expect(caveats.to_s).to eq(expected_caveats_str)
// 362:     end
// 363:   end
// 364:
// 365:   describe "#free_license" do
// 366:     it "returns license caveat text" do
// 367:       expected_caveats_str = <<~EOS
// 368:         The vendor offers a free license for #{cask} at:
// 369:           https://brew.sh/test-free-license/
// 370:       EOS
// 371:
// 372:       caveats.eval_caveats do
// 373:         free_license "https://brew.sh/test-free-license/"
// 374:       end
// 375:
// 376:       expect(caveats.to_s).to eq(expected_caveats_str)
// 377:     end
// 378:   end
// 379: end
