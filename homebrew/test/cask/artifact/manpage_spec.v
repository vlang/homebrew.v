module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/manpage_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask_token) { "basic-cask" }` at line 5.
pub fn ruby_manpage_spec_l5_d1_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_token) }` at line 6.
pub fn ruby_manpage_spec_l6_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:cask_token) { "invalid-manpage-no-section" }` at line 9.
pub fn ruby_manpage_spec_l9_d3_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby it `it "fails to load a cask without section", :no_api do` at line 11.
pub fn ruby_manpage_spec_l11_d4_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby let `let(:install_phase) do` at line 17.
pub fn ruby_manpage_spec_l17_d5_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("manpage.1") }` at line 25.
pub fn ruby_manpage_spec_l25_d6_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby let `let(:target_path) { cask.config.manpagedir.join("man1/manpage.1") }` at line 26.
pub fn ruby_manpage_spec_l26_d7_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby let `let(:gz_source_path) { cask.staged_path.join("gzpage.1.gz") }` at line 27.
pub fn ruby_manpage_spec_l27_d8_gz_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gz_source_path', ...args)
}

// Ruby let `let(:gz_target_path) { cask.config.manpagedir.join("man1/gzpage.1.gz") }` at line 28.
pub fn ruby_manpage_spec_l28_d9_gz_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gz_target_path', ...args)
}

// Ruby let `let(:cask_token) { "with-autodetected-manpage-section" }` at line 35.
pub fn ruby_manpage_spec_l35_d10_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby it `it "links the manpage to the proper directory" do` at line 37.
pub fn ruby_manpage_spec_l37_d11_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Manpage, :cask do
// 5:   let(:cask_token) { "basic-cask" }
// 6:   let(:cask) { Cask::CaskLoader.load(cask_token) }
// 7:
// 8:   context "without section" do
// 9:     let(:cask_token) { "invalid-manpage-no-section" }
// 10:
// 11:     it "fails to load a cask without section", :no_api do
// 12:       expect { cask }.to raise_error(Cask::CaskInvalidError, /is not a valid man page name/)
// 13:     end
// 14:   end
// 15:
// 16:   context "with install" do
// 17:     let(:install_phase) do
// 18:       lambda do
// 19:         cask.artifacts.grep(described_class).each do |artifact|
// 20:           artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 21:         end
// 22:       end
// 23:     end
// 24:
// 25:     let(:source_path) { cask.staged_path.join("manpage.1") }
// 26:     let(:target_path) { cask.config.manpagedir.join("man1/manpage.1") }
// 27:     let(:gz_source_path) { cask.staged_path.join("gzpage.1.gz") }
// 28:     let(:gz_target_path) { cask.config.manpagedir.join("man1/gzpage.1.gz") }
// 29:
// 30:     before do
// 31:       InstallHelper.install_without_artifacts(cask)
// 32:     end
// 33:
// 34:     context "with autodetected section" do
// 35:       let(:cask_token) { "with-autodetected-manpage-section" }
// 36:
// 37:       it "links the manpage to the proper directory" do
// 38:         install_phase.call
// 39:
// 40:         expect(File).to be_identical target_path, source_path
// 41:         expect(File).to be_identical gz_target_path, gz_source_path
// 42:       end
// 43:     end
// 44:   end
// 45: end
