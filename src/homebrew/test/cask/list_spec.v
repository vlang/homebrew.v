module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/list_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "lists the installed Casks in a pretty fashion" do` at line 7.
pub fn ruby_list_spec_l7_d1_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "lists oneline" do` at line 22.
pub fn ruby_list_spec_l22_d2_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "lists full names" do` at line 45.
pub fn ruby_list_spec_l45_d3_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby let `let(:casks) do` at line 69.
pub fn ruby_list_spec_l69_d4_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks', ...args)
}

// Ruby let `let(:expected_output) do` at line 75.
pub fn ruby_list_spec_l75_d5_expected_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_output', ...args)
}

// Ruby it `it "of all installed Casks" do` at line 88.
pub fn ruby_list_spec_l88_d6_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('of', ...args)
}

// Ruby it `it "of given Casks" do` at line 94.
pub fn ruby_list_spec_l94_d7_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('of', ...args)
}

// Ruby let `let(:caffeine) { Cask::CaskLoader.load(cask_path("local-caffeine")) }` at line 102.
pub fn ruby_list_spec_l102_d8_caffeine(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caffeine', ...args)
}

// Ruby let `let(:transmission) { Cask::CaskLoader.load(cask_path("local-transmission-zip")) }` at line 103.
pub fn ruby_list_spec_l103_d9_transmission(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('transmission', ...args)
}

// Ruby let `let(:casks) { [caffeine, transmission] }` at line 104.
pub fn ruby_list_spec_l104_d10_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks', ...args)
}

// Ruby it `it "lists the installed files for those Casks" do` at line 106.
pub fn ruby_list_spec_l106_d11_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "alphabetizes the strings" do` at line 126.
pub fn ruby_list_spec_l126_d12_alphabetizes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alphabetizes', ...args)
}

// Ruby it `it "alphabetizes the strings" do` at line 133.
pub fn ruby_list_spec_l133_d13_alphabetizes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alphabetizes', ...args)
}

// Ruby it `it "prefers the string without tap" do` at line 146.
pub fn ruby_list_spec_l146_d14_prefers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefers', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/list"
// 5:
// 6: RSpec.describe Cask::List, :cask do
// 7:   it "lists the installed Casks in a pretty fashion" do
// 8:     casks = %w[local-caffeine local-transmission].map { |c| Cask::CaskLoader.load(c) }
// 9:
// 10:     casks.each do |c|
// 11:       InstallHelper.install_with_caskfile(c)
// 12:     end
// 13:
// 14:     expect do
// 15:       described_class.list_casks
// 16:     end.to output(<<~EOS).to_stdout
// 17:       local-caffeine
// 18:       local-transmission
// 19:     EOS
// 20:   end
// 21:
// 22:   it "lists oneline" do
// 23:     with_env(HOMEBREW_USER_CONFIG_HOME: mktmpdir) do
// 24:       Homebrew::Trust.trust!(:tap, "third-party/tap")
// 25:       casks = %w[
// 26:         local-caffeine
// 27:         third-party/tap/third-party-cask
// 28:         local-transmission
// 29:       ].map { |c| Cask::CaskLoader.load(c) }
// 30:
// 31:       casks.each do |c|
// 32:         InstallHelper.install_with_caskfile(c)
// 33:       end
// 34:
// 35:       expect do
// 36:         described_class.list_casks(one: true)
// 37:       end.to output(<<~EOS).to_stdout
// 38:         local-caffeine
// 39:         local-transmission
// 40:         third-party-cask
// 41:       EOS
// 42:     end
// 43:   end
// 44:
// 45:   it "lists full names" do
// 46:     with_env(HOMEBREW_USER_CONFIG_HOME: mktmpdir) do
// 47:       Homebrew::Trust.trust!(:tap, "third-party/tap")
// 48:       casks = %w[
// 49:         local-caffeine
// 50:         third-party/tap/third-party-cask
// 51:         local-transmission
// 52:       ].map { |c| Cask::CaskLoader.load(c) }
// 53:
// 54:       casks.each do |c|
// 55:         InstallHelper.install_with_caskfile(c)
// 56:       end
// 57:
// 58:       expect do
// 59:         described_class.list_casks(full_name: true)
// 60:       end.to output(<<~EOS).to_stdout
// 61:         local-caffeine
// 62:         local-transmission
// 63:         third-party/tap/third-party-cask
// 64:       EOS
// 65:     end
// 66:   end
// 67:
// 68:   describe "lists versions" do
// 69:     let(:casks) do
// 70:       [
// 71:         "local-caffeine",
// 72:         "local-transmission",
// 73:       ].map { |token| Cask::CaskLoader.load(token) }
// 74:     end
// 75:     let(:expected_output) do
// 76:       <<~EOS
// 77:         local-caffeine 1.2.3
// 78:         local-transmission 2.61
// 79:       EOS
// 80:     end
// 81:
// 82:     before do
// 83:       casks.each do |cask|
// 84:         InstallHelper.install_with_caskfile(cask)
// 85:       end
// 86:     end
// 87:
// 88:     it "of all installed Casks" do
// 89:       expect do
// 90:         described_class.list_casks(versions: true)
// 91:       end.to output(expected_output).to_stdout
// 92:     end
// 93:
// 94:     it "of given Casks" do
// 95:       expect do
// 96:         described_class.list_casks(*casks, versions: true)
// 97:       end.to output(expected_output).to_stdout
// 98:     end
// 99:   end
// 100:
// 101:   describe "given a set of installed Casks" do
// 102:     let(:caffeine) { Cask::CaskLoader.load(cask_path("local-caffeine")) }
// 103:     let(:transmission) { Cask::CaskLoader.load(cask_path("local-transmission-zip")) }
// 104:     let(:casks) { [caffeine, transmission] }
// 105:
// 106:     it "lists the installed files for those Casks" do
// 107:       casks.each { InstallHelper.install_without_artifacts_with_caskfile(it) }
// 108:
// 109:       transmission.artifacts.grep(Cask::Artifact::App).each do |artifact|
// 110:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 111:       end
// 112:
// 113:       expect do
// 114:         described_class.list_casks(transmission, caffeine)
// 115:       end.to output(<<~EOS).to_stdout
// 116:         ==> App
// 117:         #{Pathname(transmission.config.appdir).join("Transmission.app")} (#{Pathname(transmission.config.appdir).join("Transmission.app").abv})
// 118:         ==> App
// 119:         Missing App: #{Pathname(caffeine.config.appdir).join("Caffeine.app")}
// 120:       EOS
// 121:     end
// 122:   end
// 123:
// 124:   describe "TAP_AND_NAME_COMPARISON" do
// 125:     describe "both strings are only names" do
// 126:       it "alphabetizes the strings" do
// 127:         expect(%w[a b].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[a b])
// 128:         expect(%w[b a].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[a b])
// 129:       end
// 130:     end
// 131:
// 132:     describe "both strings include tap" do
// 133:       it "alphabetizes the strings" do
// 134:         expect(%w[a/z/z b/z/z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[a/z/z b/z/z])
// 135:         expect(%w[b/z/z a/z/z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[a/z/z b/z/z])
// 136:
// 137:         expect(%w[z/a/z z/b/z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z/a/z z/b/z])
// 138:         expect(%w[z/b/z z/a/z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z/a/z z/b/z])
// 139:
// 140:         expect(%w[z/z/a z/z/b].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z/z/a z/z/b])
// 141:         expect(%w[z/z/b z/z/a].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z/z/a z/z/b])
// 142:       end
// 143:     end
// 144:
// 145:     describe "only one string includes tap" do
// 146:       it "prefers the string without tap" do
// 147:         expect(%w[a/z/z z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z a/z/z])
// 148:         expect(%w[z a/z/z].sort(&Cask::List::TAP_AND_NAME_COMPARISON)).to eq(%w[z a/z/z])
// 149:       end
// 150:     end
// 151:   end
// 152: end
