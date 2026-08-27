module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/generic_artifact_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-generic-artifact")) }` at line 5.
pub fn ruby_generic_artifact_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 7.
pub fn ruby_generic_artifact_spec_l7_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine.app") }` at line 15.
pub fn ruby_generic_artifact_spec_l15_d3_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }` at line 16.
pub fn ruby_generic_artifact_spec_l16_d4_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby it `it "fails to load", :no_api do` at line 23.
pub fn ruby_generic_artifact_spec_l23_d5_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "does not fail to load" do` at line 31.
pub fn ruby_generic_artifact_spec_l31_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not fail to load" do` at line 39.
pub fn ruby_generic_artifact_spec_l39_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "moves the artifact to the proper directory" do` at line 46.
pub fn ruby_generic_artifact_spec_l46_d8_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Ruby it `it "avoids clobbering an existing artifact" do` at line 53.
pub fn ruby_generic_artifact_spec_l53_d9_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avoids', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Artifact, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-generic-artifact")) }
// 6:
// 7:   let(:install_phase) do
// 8:     lambda do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:   end
// 14:
// 15:   let(:source_path) { cask.staged_path.join("Caffeine.app") }
// 16:   let(:target_path) { Pathname(cask.config.appdir).join("Caffeine.app") }
// 17:
// 18:   before do
// 19:     InstallHelper.install_without_artifacts(cask)
// 20:   end
// 21:
// 22:   context "without target" do
// 23:     it "fails to load", :no_api do
// 24:       expect do
// 25:         Cask::CaskLoader.load("invalid-generic-artifact-no-target")
// 26:       end.to raise_error(Cask::CaskInvalidError, /Generic Artifact.*requires.*target/)
// 27:     end
// 28:   end
// 29:
// 30:   context "with relative target" do
// 31:     it "does not fail to load" do
// 32:       expect do
// 33:         Cask::CaskLoader.load("generic-artifact-relative-target")
// 34:       end.not_to raise_error
// 35:     end
// 36:   end
// 37:
// 38:   context "with user-relative target" do
// 39:     it "does not fail to load" do
// 40:       expect do
// 41:         Cask::CaskLoader.load("generic-artifact-user-relative-target")
// 42:       end.not_to raise_error
// 43:     end
// 44:   end
// 45:
// 46:   it "moves the artifact to the proper directory" do
// 47:     install_phase.call
// 48:
// 49:     expect(target_path).to be_a_directory
// 50:     expect(source_path).to be_a_symlink
// 51:   end
// 52:
// 53:   it "avoids clobbering an existing artifact" do
// 54:     target_path.mkpath
// 55:
// 56:     expect do
// 57:       install_phase.call
// 58:     end.to raise_error(Cask::CaskError)
// 59:
// 60:     expect(source_path).to be_a_directory
// 61:     expect(target_path).to be_a_directory
// 62:     expect(File.identical?(source_path, target_path)).to be false
// 63:   end
// 64: end
