module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/zshcompletion_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask_token) { "with-shellcompletion" }` at line 5.
pub fn ruby_zshcompletion_spec_l5_d1_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_token) }` at line 6.
pub fn ruby_zshcompletion_spec_l6_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 9.
pub fn ruby_zshcompletion_spec_l9_d3_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("_test") }` at line 17.
pub fn ruby_zshcompletion_spec_l17_d4_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby let `let(:target_path) { cask.config.zsh_completion.join("_test") }` at line 18.
pub fn ruby_zshcompletion_spec_l18_d5_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby let `let(:full_source_path) { cask.staged_path.join("test.zsh-completion") }` at line 19.
pub fn ruby_zshcompletion_spec_l19_d6_full_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_source_path', ...args)
}

// Ruby let `let(:full_target_path) { cask.config.zsh_completion.join("_test") }` at line 20.
pub fn ruby_zshcompletion_spec_l20_d7_full_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_target_path', ...args)
}

// Ruby it `it "links the completion to the proper directory" do` at line 23.
pub fn ruby_zshcompletion_spec_l23_d8_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby let `let(:cask_token) { "with-shellcompletion-long" }` at line 34.
pub fn ruby_zshcompletion_spec_l34_d9_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby it `it "links the completion to the proper directory" do` at line 36.
pub fn ruby_zshcompletion_spec_l36_d10_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::ZshCompletion, :cask do
// 5:   let(:cask_token) { "with-shellcompletion" }
// 6:   let(:cask) { Cask::CaskLoader.load(cask_token) }
// 7:
// 8:   context "with install" do
// 9:     let(:install_phase) do
// 10:       lambda do
// 11:         cask.artifacts.grep(described_class).each do |artifact|
// 12:           artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 13:         end
// 14:       end
// 15:     end
// 16:
// 17:     let(:source_path) { cask.staged_path.join("_test") }
// 18:     let(:target_path) { cask.config.zsh_completion.join("_test") }
// 19:     let(:full_source_path) { cask.staged_path.join("test.zsh-completion") }
// 20:     let(:full_target_path) { cask.config.zsh_completion.join("_test") }
// 21:
// 22:     context "with completion" do
// 23:       it "links the completion to the proper directory" do
// 24:         source_path.dirname.mkpath
// 25:         source_path.write ""
// 26:
// 27:         install_phase.call
// 28:
// 29:         expect(File).to be_identical target_path, source_path
// 30:       end
// 31:     end
// 32:
// 33:     context "with long completion" do
// 34:       let(:cask_token) { "with-shellcompletion-long" }
// 35:
// 36:       it "links the completion to the proper directory" do
// 37:         full_source_path.dirname.mkpath
// 38:         full_source_path.write ""
// 39:
// 40:         install_phase.call
// 41:
// 42:         expect(File).to be_identical full_target_path, full_source_path
// 43:       end
// 44:     end
// 45:   end
// 46: end
