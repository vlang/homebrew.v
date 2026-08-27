module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/binary_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) do` at line 5.
pub fn ruby_binary_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:artifacts) { cask.artifacts.grep(described_class) }` at line 10.
pub fn ruby_binary_spec_l10_d2_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifacts', ...args)
}

// Ruby let `let(:binarydir) { cask.config.binarydir }` at line 11.
pub fn ruby_binary_spec_l11_d3_binarydir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('binarydir', ...args)
}

// Ruby let `let(:expected_path) { binarydir.join("binary") }` at line 12.
pub fn ruby_binary_spec_l12_d4_expected_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_path', ...args)
}

// Ruby let `let(:cask) do` at line 24.
pub fn ruby_binary_spec_l24_d5_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "doesn't link the binary when --no-binaries is specified" do` at line 28.
pub fn ruby_binary_spec_l28_d6_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "links the binary to the proper directory" do` at line 34.
pub fn ruby_binary_spec_l34_d7_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby let `let(:cask) do` at line 44.
pub fn ruby_binary_spec_l44_d8_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:expected_path) { cask.config.binarydir.join("naked_non_executable") }` at line 50.
pub fn ruby_binary_spec_l50_d9_expected_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_path', ...args)
}

// Ruby it `it "makes the binary executable" do` at line 52.
pub fn ruby_binary_spec_l52_d10_makes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('makes', ...args)
}

// Ruby it `it "avoids clobbering an existing binary by linking over it" do` at line 65.
pub fn ruby_binary_spec_l65_d11_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avoids', ...args)
}

// Ruby it `it "avoids clobbering an existing symlink" do` at line 77.
pub fn ruby_binary_spec_l77_d12_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avoids', ...args)
}

// Ruby it `it "skips linking when the target is already a symlink to the source" do` at line 89.
pub fn ruby_binary_spec_l89_d13_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "raises a clean error when the target symlink cannot be resolved" do` at line 100.
pub fn ruby_binary_spec_l100_d14_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "creates parent directory if it doesn't exist" do` at line 110.
pub fn ruby_binary_spec_l110_d15_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby let `let(:cask) do` at line 121.
pub fn ruby_binary_spec_l121_d16_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "links the binary to the proper directory" do` at line 127.
pub fn ruby_binary_spec_l127_d17_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Binary, :cask do
// 5:   let(:cask) do
// 6:     Cask::CaskLoader.load(cask_path("with-binary")).tap do |cask|
// 7:       InstallHelper.install_without_artifacts(cask)
// 8:     end
// 9:   end
// 10:   let(:artifacts) { cask.artifacts.grep(described_class) }
// 11:   let(:binarydir) { cask.config.binarydir }
// 12:   let(:expected_path) { binarydir.join("binary") }
// 13:
// 14:   around do |example|
// 15:     binarydir.mkpath
// 16:
// 17:     example.run
// 18:   ensure
// 19:     FileUtils.rm_f expected_path
// 20:     FileUtils.rmdir binarydir
// 21:   end
// 22:
// 23:   context "when --no-binaries is specified" do
// 24:     let(:cask) do
// 25:       Cask::CaskLoader.load(cask_path("with-binary"))
// 26:     end
// 27:
// 28:     it "doesn't link the binary when --no-binaries is specified" do
// 29:       Cask::Installer.new(cask, binaries: false).install
// 30:       expect(expected_path).not_to exist
// 31:     end
// 32:   end
// 33:
// 34:   it "links the binary to the proper directory" do
// 35:     artifacts.each do |artifact|
// 36:       artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 37:     end
// 38:
// 39:     expect(expected_path).to be_a_symlink
// 40:     expect(expected_path.readlink).to exist
// 41:   end
// 42:
// 43:   context "when the binary is not executable" do
// 44:     let(:cask) do
// 45:       Cask::CaskLoader.load(cask_path("with-non-executable-binary")).tap do |cask|
// 46:         InstallHelper.install_without_artifacts(cask)
// 47:       end
// 48:     end
// 49:
// 50:     let(:expected_path) { cask.config.binarydir.join("naked_non_executable") }
// 51:
// 52:     it "makes the binary executable" do
// 53:       expect(FileUtils).to receive(:chmod)
// 54:         .with("+x", cask.staged_path.join("naked_non_executable")).and_call_original
// 55:
// 56:       artifacts.each do |artifact|
// 57:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 58:       end
// 59:
// 60:       expect(expected_path).to be_a_symlink
// 61:       expect(expected_path.readlink).to be_executable
// 62:     end
// 63:   end
// 64:
// 65:   it "avoids clobbering an existing binary by linking over it" do
// 66:     FileUtils.touch expected_path
// 67:
// 68:     expect do
// 69:       artifacts.each do |artifact|
// 70:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 71:       end
// 72:     end.to raise_error(Cask::CaskError)
// 73:
// 74:     expect(expected_path).not_to be :symlink?
// 75:   end
// 76:
// 77:   it "avoids clobbering an existing symlink" do
// 78:     expected_path.make_symlink("/tmp")
// 79:
// 80:     expect do
// 81:       artifacts.each do |artifact|
// 82:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 83:       end
// 84:     end.to raise_error(Cask::CaskError)
// 85:
// 86:     expect(File.readlink(expected_path)).to eq("/tmp")
// 87:   end
// 88:
// 89:   it "skips linking when the target is already a symlink to the source" do
// 90:     artifact = artifacts.first
// 91:     expected_path.make_symlink(artifact.source)
// 92:
// 93:     expect do
// 94:       artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 95:     end.to output(/is already linked/).to_stdout
// 96:
// 97:     expect(expected_path.readlink).to eq(artifact.source)
// 98:   end
// 99:
// 100:   it "raises a clean error when the target symlink cannot be resolved" do
// 101:     artifact = artifacts.first
// 102:     expected_path.make_symlink(artifact.source)
// 103:     allow(artifact.target).to receive(:realpath).and_raise(Errno::EACCES)
// 104:
// 105:     expect do
// 106:       artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 107:     end.to raise_error(Cask::CaskError, /already a Binary/)
// 108:   end
// 109:
// 110:   it "creates parent directory if it doesn't exist" do
// 111:     FileUtils.rmdir binarydir
// 112:
// 113:     artifacts.each do |artifact|
// 114:       artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 115:     end
// 116:
// 117:     expect(expected_path.exist?).to be true
// 118:   end
// 119:
// 120:   context "when the binary is inside an app package" do
// 121:     let(:cask) do
// 122:       Cask::CaskLoader.load(cask_path("with-embedded-binary")).tap do |cask|
// 123:         InstallHelper.install_without_artifacts(cask)
// 124:       end
// 125:     end
// 126:
// 127:     it "links the binary to the proper directory" do
// 128:       cask.artifacts.grep(Cask::Artifact::App).each do |artifact|
// 129:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 130:       end
// 131:       artifacts.each do |artifact|
// 132:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 133:       end
// 134:
// 135:       expect(expected_path).to be_a_symlink
// 136:       expect(expected_path.readlink).to exist
// 137:     end
// 138:   end
// 139: end
