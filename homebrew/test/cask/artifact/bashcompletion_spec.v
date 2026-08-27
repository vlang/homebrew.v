module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/bashcompletion_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask_token) { "basic-cask" }` at line 5.
pub fn ruby_bashcompletion_spec_l5_d1_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_token) }` at line 6.
pub fn ruby_bashcompletion_spec_l6_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 9.
pub fn ruby_bashcompletion_spec_l9_d3_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("test.bash") }` at line 17.
pub fn ruby_bashcompletion_spec_l17_d4_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby let `let(:target_path) { cask.config.bash_completion.join("test") }` at line 18.
pub fn ruby_bashcompletion_spec_l18_d5_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby let `let(:full_source_path) { cask.staged_path.join("test.bash-completion") }` at line 19.
pub fn ruby_bashcompletion_spec_l19_d6_full_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_source_path', ...args)
}

// Ruby let `let(:full_target_path) { cask.config.bash_completion.join("test") }` at line 20.
pub fn ruby_bashcompletion_spec_l20_d7_full_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_target_path', ...args)
}

// Ruby let `let(:cask_token) { "with-shellcompletion" }` at line 23.
pub fn ruby_bashcompletion_spec_l23_d8_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby it `it "links the completion to the proper directory" do` at line 25.
pub fn ruby_bashcompletion_spec_l25_d9_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby let `let(:cask_token) { "with-shellcompletion-long" }` at line 36.
pub fn ruby_bashcompletion_spec_l36_d10_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby it `it "links the completion to the proper directory" do` at line 38.
pub fn ruby_bashcompletion_spec_l38_d11_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::BashCompletion, :cask do
// 5:   let(:cask_token) { "basic-cask" }
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
// 17:     let(:source_path) { cask.staged_path.join("test.bash") }
// 18:     let(:target_path) { cask.config.bash_completion.join("test") }
// 19:     let(:full_source_path) { cask.staged_path.join("test.bash-completion") }
// 20:     let(:full_target_path) { cask.config.bash_completion.join("test") }
// 21:
// 22:     context "with completion" do
// 23:       let(:cask_token) { "with-shellcompletion" }
// 24:
// 25:       it "links the completion to the proper directory" do
// 26:         source_path.dirname.mkpath
// 27:         source_path.write ""
// 28:
// 29:         install_phase.call
// 30:
// 31:         expect(File).to be_identical target_path, source_path
// 32:       end
// 33:     end
// 34:
// 35:     context "with long completion" do
// 36:       let(:cask_token) { "with-shellcompletion-long" }
// 37:
// 38:       it "links the completion to the proper directory" do
// 39:         full_source_path.dirname.mkpath
// 40:         full_source_path.write ""
// 41:
// 42:         install_phase.call
// 43:
// 44:         expect(File).to be_identical full_target_path, full_source_path
// 45:       end
// 46:     end
// 47:   end
// 48: end
