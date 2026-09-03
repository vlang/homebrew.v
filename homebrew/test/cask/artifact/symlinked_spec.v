module artifact

import brew_runtime
import homebrew.cask.artifact as core
import os

// Translated from Homebrew/brew `test/cask/artifact/symlinked_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn symlinked_spec_runner(command core.ArtifactCommand) !bool {
	_ = command
	return true
}

fn symlinked_spec_artifact(root string) core.SymlinkedArtifact {
	return core.SymlinkedArtifact{
		source: os.join_path(root, 'Caskroom', 'with-binary', 'staged', 'binary')
		target: os.join_path(root, 'bin', 'binary')
		english_name: 'Binary'
		caskroom_path: os.join_path(root, 'Caskroom', 'with-binary')
		cellar_root: os.join_path(root, 'Cellar')
	}
}

fn symlinked_spec_prepare_source(artifact core.SymlinkedArtifact) bool {
	os.mkdir_all(os.dir(artifact.source)) or { return false }
	os.write_file(artifact.source, '#!/bin/sh\n') or { return false }
	return true
}

pub fn symlinked_spec_case(index int) bool {
	root := os.join_path(os.temp_dir(), 'brew-v-symlinked-spec-${os.getpid()}-${index}')
	if os.exists(root) {
		os.rmdir_all(root) or { return false }
	}
	artifact := symlinked_spec_artifact(root)
	if !symlinked_spec_prepare_source(artifact) {
		return false
	}
	mut success := false
	match index {
		5 {
			formula_binary := os.join_path(artifact.cellar_root, 'with-binary', '1.0.0', 'bin', 'binary')
			os.mkdir_all(os.dir(formula_binary)) or { return false }
			os.write_file(formula_binary, 'formula') or { return false }
			os.mkdir_all(os.dir(artifact.target)) or { return false }
			os.symlink(formula_binary, artifact.target) or { return false }
			result := core.link_symlinked_artifact_with_command(artifact, core.SymlinkedInstallOptions{}, symlinked_spec_runner)
			success = result.success && result.skipped && result.conflicting_formula == 'with-binary' && os.readlink(artifact.target) or { '' } == formula_binary
		}
		6 {
			result := core.link_symlinked_artifact_with_command(artifact, core.SymlinkedInstallOptions{}, symlinked_spec_runner)
			success = result.success && result.linked && os.is_link(artifact.target) && os.exists(artifact.target)
		}
		else {}
	}
	os.rmdir_all(root) or {}
	return success
}

// Ruby let `let(:cask) do` at line 7.
pub fn ruby_symlinked_spec_l7_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('with-binary')
}

// Ruby let `let(:binary_artifact) { cask.artifacts.find { |a| a.is_a?(Cask::Artifact::Binary) } }` at line 13.
pub fn ruby_symlinked_spec_l13_d2_binary_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return core.symlinked_artifact_to_value(symlinked_spec_artifact('/tmp/symlinked-spec'))
}

// Ruby let `let(:binarydir) { cask.config.binarydir }` at line 14.
pub fn ruby_symlinked_spec_l14_d3_binarydir(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('/tmp/symlinked-spec/bin')
}

// Ruby let `let(:target_path) { binarydir.join("binary") }` at line 15.
pub fn ruby_symlinked_spec_l15_d4_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('/tmp/symlinked-spec/bin/binary')
}

// Ruby it `it "detects the conflict and skips linking with warning" do` at line 29.
pub fn ruby_symlinked_spec_l29_d5_detects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(symlinked_spec_case(5))
}

// Ruby it `it "proceeds with normal installation" do` at line 53.
pub fn ruby_symlinked_spec_l53_d6_proceeds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(symlinked_spec_case(6))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Symlinked, :cask do
// 5:   # Test the formula conflict detection functionality that applies to all symlinked artifacts
// 6:   describe "#conflicting_formula" do
// 7:     let(:cask) do
// 8:       Cask::CaskLoader.load(cask_path("with-binary")).tap do |cask|
// 9:         InstallHelper.install_without_artifacts(cask)
// 10:       end
// 11:     end
// 12:
// 13:     let(:binary_artifact) { cask.artifacts.find { |a| a.is_a?(Cask::Artifact::Binary) } }
// 14:     let(:binarydir) { cask.config.binarydir }
// 15:     let(:target_path) { binarydir.join("binary") }
// 16:
// 17:     around do |example|
// 18:       binarydir.mkpath
// 19:
// 20:       example.run
// 21:     ensure
// 22:       FileUtils.rm_f target_path
// 23:       FileUtils.rmdir binarydir
// 24:       # Clean up the fake formula directory
// 25:       FileUtils.rm_rf(HOMEBREW_CELLAR/"with-binary") if (HOMEBREW_CELLAR/"with-binary").exist?
// 26:     end
// 27:
// 28:     context "when target is already linked from a formula" do
// 29:       it "detects the conflict and skips linking with warning" do
// 30:         # Create a fake formula directory structure
// 31:         formula_cellar_path = HOMEBREW_CELLAR/"with-binary/1.0.0/bin"
// 32:         formula_cellar_path.mkpath
// 33:         formula_binary_path = formula_cellar_path/"binary"
// 34:         FileUtils.touch formula_binary_path
// 35:
// 36:         # Create symlink from the expected location to the formula binary
// 37:         target_path.make_symlink(formula_binary_path)
// 38:
// 39:         stderr = <<~EOS
// 40:           Warning: It seems there is already a Binary at '#{target_path}' from formula with-binary; skipping link.
// 41:         EOS
// 42:
// 43:         expect do
// 44:           binary_artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 45:         end.to output(stderr).to_stderr
// 46:
// 47:         expect(target_path).to be_a_symlink
// 48:         expect(target_path.readlink).to eq(formula_binary_path)
// 49:       end
// 50:     end
// 51:
// 52:     context "when target doesn't exist" do
// 53:       it "proceeds with normal installation" do
// 54:         expect do
// 55:           binary_artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 56:         end.not_to raise_error
// 57:
// 58:         expect(target_path).to be_a_symlink
// 59:         expect(target_path.readlink).to exist
// 60:       end
// 61:     end
// 62:   end
// 63: end
