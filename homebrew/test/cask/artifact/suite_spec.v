module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/suite_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-suite")) }` at line 5.
pub fn ruby_suite_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 7.
pub fn ruby_suite_spec_l7_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("Caffeine") }` at line 15.
pub fn ruby_suite_spec_l15_d3_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine") }` at line 16.
pub fn ruby_suite_spec_l16_d4_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby it `it "creates a suite containing the expected app" do` at line 22.
pub fn ruby_suite_spec_l22_d5_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "avoids clobbering an existing suite by moving over it" do` at line 28.
pub fn ruby_suite_spec_l28_d6_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avoids', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Suite, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-suite")) }
// 6:
// 7:   let(:install_phase) do
// 8:     lambda do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:   end
// 14:
// 15:   let(:target_path) { Pathname(cask.config.appdir).join("Caffeine") }
// 16:   let(:source_path) { cask.staged_path.join("Caffeine") }
// 17:
// 18:   before do
// 19:     InstallHelper.install_without_artifacts(cask)
// 20:   end
// 21:
// 22:   it "creates a suite containing the expected app" do
// 23:     install_phase.call
// 24:
// 25:     expect(target_path.join("Caffeine.app")).to exist
// 26:   end
// 27:
// 28:   it "avoids clobbering an existing suite by moving over it" do
// 29:     target_path.mkpath
// 30:
// 31:     expect do
// 32:       install_phase.call
// 33:     end.to raise_error(Cask::CaskError)
// 34:
// 35:     expect(source_path).to be_a_directory
// 36:     expect(target_path).to be_a_directory
// 37:     expect(File.identical?(source_path, target_path)).to be false
// 38:   end
// 39: end
