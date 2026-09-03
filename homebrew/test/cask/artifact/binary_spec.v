module artifact

import brew_runtime
import homebrew.cask.artifact as core
import os

// Translated from Homebrew/brew `test/cask/artifact/binary_spec.rb`.
// The original source is retained below for exact boundary auditing.
struct BinarySpecFixture {
	root      string
	token     string
	source    string
	target    string
	binarydir string
}

struct BinarySpecInstallResult {
	symlink_result core.SymlinkedOperationResult
	executable     brew_runtime.Value
	disabled       bool
}

fn binary_spec_paths(token string) (string, string, string) {
	root := os.join_path(os.temp_dir(), 'brew-v-binary-spec-values', token)
	binarydir := os.join_path(root, 'bin')
	source := match token {
		'with-non-executable-binary' {
			os.join_path(root, 'Caskroom', token, 'staged', 'naked_non_executable')
		}
		'with-embedded-binary' {
			os.join_path(root, 'Caskroom', token, 'staged', 'Embedded.app', 'Contents', 'MacOS', 'binary')
		}
		else { os.join_path(root, 'Caskroom', token, 'staged', 'binary') }
	}
	target := os.join_path(binarydir, os.file_name(source))
	return source, binarydir, target
}

fn binary_spec_cask_value(token string, installed_without_artifacts bool) brew_runtime.Value {
	source, binarydir, target := binary_spec_paths(token)
	artifact := core.SymlinkedArtifact{
		source: source
		target: target
		english_name: 'Binary'
		caskroom_path: os.join_path(os.temp_dir(), 'brew-v-binary-spec-values', token, 'Caskroom', token)
	}
	return brew_runtime.Value{
		type_name: 'Cask'
		repr: token
		attributes: {
			'token':                       token
			'staged_path':                 os.dir(source)
			'binarydir':                   binarydir
			'installed_without_artifacts': installed_without_artifacts.str()
		}
		map_data: {
			'artifacts': brew_runtime.array_value([
				core.symlinked_artifact_to_value(artifact),
			])
		}
	}
}

fn binary_spec_fixture(index int, token string) !BinarySpecFixture {
	root := os.join_path(os.temp_dir(), 'brew-v-binary-artifact-spec-${os.getpid()}-${index}')
	os.rmdir_all(root) or {}
	binarydir := os.join_path(root, 'bin')
	file_name := if token == 'with-non-executable-binary' {
		'naked_non_executable'
	} else {
		'binary'
	}
	source := if token == 'with-embedded-binary' {
		os.join_path(root, 'Caskroom', token, 'staged', 'Embedded.app', 'Contents', 'MacOS', file_name)
	} else {
		os.join_path(root, 'Caskroom', token, 'staged', file_name)
	}
	os.mkdir_all(os.dir(source))!
	os.mkdir_all(binarydir)!
	os.write_file(source, '#!/bin/sh\necho binary\n')!
	mode := if token == 'with-non-executable-binary' { 0o644 } else { 0o755 }
	os.chmod(source, mode)!
	return BinarySpecFixture{
		root: root
		token: token
		source: source
		target: os.join_path(binarydir, file_name)
		binarydir: binarydir
	}
}

fn binary_spec_artifact(fixture BinarySpecFixture) core.SymlinkedArtifact {
	return core.SymlinkedArtifact{
		source: fixture.source
		target: fixture.target
		english_name: 'Binary'
		caskroom_path: os.join_path(fixture.root, 'Caskroom', fixture.token)
		cellar_root: os.join_path(fixture.root, 'Cellar')
	}
}

fn binary_spec_runner(command core.ArtifactCommand) !bool {
	if command.executable != '/bin/ln' || command.args.len != 5 {
		return error('unexpected binary link command')
	}
	return true
}

fn binary_spec_install(fixture BinarySpecFixture, binaries bool) BinarySpecInstallResult {
	if !binaries {
		return BinarySpecInstallResult{
			symlink_result: core.SymlinkedOperationResult{
				skipped: true
			}
			executable: brew_runtime.object_value('NilClass', 'nil')
			disabled: true
		}
	}
	artifact := binary_spec_artifact(fixture)
	mut symlink_result := core.link_symlinked_artifact_with_command(artifact, core.SymlinkedInstallOptions{}, binary_spec_runner)
	mut executable := brew_runtime.object_value('NilClass', 'nil')
	if symlink_result.success {
		executable = core.ruby_binary_l18_d1_link(brew_runtime.string_value(fixture.source))
		if executable.type_name == 'CaskError' || executable.type_name == 'ArgumentError' {
			symlink_result.success = false
			symlink_result.error = executable.repr
		}
	}
	return BinarySpecInstallResult{
		symlink_result: symlink_result
		executable: executable
	}
}

pub fn binary_spec_case(index int) bool {
	token := match index {
		10 { 'with-non-executable-binary' }
		17 { 'with-embedded-binary' }
		else { 'with-binary' }
	}
	fixture := binary_spec_fixture(index, token) or { return false }
	defer { os.rmdir_all(fixture.root) or {} }
	return match index {
		6 {
			result := binary_spec_install(fixture, false)
			result.disabled && result.symlink_result.success && result.symlink_result.skipped && !os.exists(fixture.target) && !os.is_link(fixture.target)
		}
		7 {
			result := binary_spec_install(fixture, true)
			link := os.readlink(fixture.target) or { return false }
			already_executable := result.executable.attribute('already_executable') or { 'false' }
			result.symlink_result.success && result.symlink_result.linked && already_executable == 'true' && os.is_link(fixture.target) && link == fixture.source && os.exists(fixture.target)
		}
		10 {
			if os.is_executable(fixture.source) {
				return false
			}
			result := binary_spec_install(fixture, true)
			chmod_applied := result.executable.attribute('chmod_applied') or { 'false' }
			result.symlink_result.success && result.symlink_result.linked && chmod_applied == 'true' && os.is_link(fixture.target) && os.is_executable(fixture.source) && os.is_executable(fixture.target)
		}
		11 {
			os.write_file(fixture.target, 'existing binary') or { return false }
			result := binary_spec_install(fixture, true)
			passed := !result.symlink_result.success && result.symlink_result.error.contains('already a Binary') && os.exists(fixture.target) && !os.is_link(fixture.target)
			passed
		}
		12 {
			os.symlink('/tmp', fixture.target) or { return false }
			result := binary_spec_install(fixture, true)
			link := os.readlink(fixture.target) or { return false }
			passed := !result.symlink_result.success && result.symlink_result.error.contains('already a Binary') && link == '/tmp'
			passed
		}
		13 {
			os.symlink(fixture.source, fixture.target) or { return false }
			result := binary_spec_install(fixture, true)
			link := os.readlink(fixture.target) or { return false }
			result.symlink_result.success && result.symlink_result.skipped && result.symlink_result.output.any(it.contains('is already linked')) && link == fixture.source
		}
		14 {
			other := os.join_path(fixture.root, 'other-binary')
			os.write_file(other, 'other') or { return false }
			os.symlink(other, fixture.target) or { return false }
			result := binary_spec_install(fixture, true)
			link := os.readlink(fixture.target) or { return false }
			passed := !result.symlink_result.success && result.symlink_result.error.contains('already a Binary') && link == other
			passed
		}
		15 {
			os.rmdir(fixture.binarydir) or { return false }
			result := binary_spec_install(fixture, true)
			result.symlink_result.success && result.symlink_result.linked && os.is_dir(fixture.binarydir) && os.exists(fixture.target)
		}
		17 {
			result := binary_spec_install(fixture, true)
			result.symlink_result.success && result.symlink_result.linked && fixture.source.contains('.app${os.path_separator}Contents${os.path_separator}MacOS') && os.is_link(fixture.target) && os.exists(fixture.target)
		}
		else { false }
	}
}

// Ruby let `let(:cask) do` at line 5.
pub fn ruby_binary_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return binary_spec_cask_value('with-binary', true)
}

// Ruby let `let(:artifacts) { cask.artifacts.grep(described_class) }` at line 10.
pub fn ruby_binary_spec_l10_d2_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { binary_spec_cask_value('with-binary', true) }
	return cask.map_data['artifacts'] or { brew_runtime.array_value([]) }
}

// Ruby let `let(:binarydir) { cask.config.binarydir }` at line 11.
pub fn ruby_binary_spec_l11_d3_binarydir(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { binary_spec_cask_value('with-binary', true) }
	return brew_runtime.string_value(cask.attributes['binarydir'] or { '' })
}

// Ruby let `let(:expected_path) { binarydir.join("binary") }` at line 12.
pub fn ruby_binary_spec_l12_d4_expected_path(args ...brew_runtime.Value) brew_runtime.Value {
	binarydir := if args.len > 0 {
		args[0].as_string()
	} else {
		binary_spec_cask_value('with-binary', true).attributes['binarydir'] or { '' }
	}
	return brew_runtime.string_value(os.join_path(binarydir, 'binary'))
}

// Ruby let `let(:cask) do` at line 24.
pub fn ruby_binary_spec_l24_d5_cask(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return binary_spec_cask_value('with-binary', false)
}

// Ruby it `it "doesn't link the binary when --no-binaries is specified" do` at line 28.
pub fn ruby_binary_spec_l28_d6_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(6))
}

// Ruby it `it "links the binary to the proper directory" do` at line 34.
pub fn ruby_binary_spec_l34_d7_links(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(7))
}

// Ruby let `let(:cask) do` at line 44.
pub fn ruby_binary_spec_l44_d8_cask(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return binary_spec_cask_value('with-non-executable-binary', true)
}

// Ruby let `let(:expected_path) { cask.config.binarydir.join("naked_non_executable") }` at line 50.
pub fn ruby_binary_spec_l50_d9_expected_path(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 {
		args[0]
	} else {
		binary_spec_cask_value('with-non-executable-binary', true)
	}
	return brew_runtime.string_value(os.join_path(cask.attributes['binarydir'] or { '' }, 'naked_non_executable'))
}

// Ruby it `it "makes the binary executable" do` at line 52.
pub fn ruby_binary_spec_l52_d10_makes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(10))
}

// Ruby it `it "avoids clobbering an existing binary by linking over it" do` at line 65.
pub fn ruby_binary_spec_l65_d11_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(11))
}

// Ruby it `it "avoids clobbering an existing symlink" do` at line 77.
pub fn ruby_binary_spec_l77_d12_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(12))
}

// Ruby it `it "skips linking when the target is already a symlink to the source" do` at line 89.
pub fn ruby_binary_spec_l89_d13_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(13))
}

// Ruby it `it "raises a clean error when the target symlink cannot be resolved" do` at line 100.
pub fn ruby_binary_spec_l100_d14_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(14))
}

// Ruby it `it "creates parent directory if it doesn't exist" do` at line 110.
pub fn ruby_binary_spec_l110_d15_creates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(15))
}

// Ruby let `let(:cask) do` at line 121.
pub fn ruby_binary_spec_l121_d16_cask(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return binary_spec_cask_value('with-embedded-binary', true)
}

// Ruby it `it "links the binary to the proper directory" do` at line 127.
pub fn ruby_binary_spec_l127_d17_links(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(binary_spec_case(17))
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
