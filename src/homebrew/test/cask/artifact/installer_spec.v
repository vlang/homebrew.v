module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/installer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:installer) { described_class.new(cask, **args) }` at line 5.
pub fn ruby_installer_spec_l5_d1_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installer', ...args)
}

// Ruby let `let(:staged_path) { mktmpdir }` at line 7.
pub fn ruby_installer_spec_l7_d2_staged_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staged_path', ...args)
}

// Ruby let `let(:cask) { instance_double(Cask::Cask, staged_path:) }` at line 8.
pub fn ruby_installer_spec_l8_d3_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:command) { SystemCommand }` at line 9.
pub fn ruby_installer_spec_l9_d4_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:args) { {} }` at line 10.
pub fn ruby_installer_spec_l10_d5_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby let `let(:args) { { manual: "installer" } }` at line 14.
pub fn ruby_installer_spec_l14_d6_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby it `it "shows a message prompting to run the installer manually" do` at line 16.
pub fn ruby_installer_spec_l16_d7_shows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shows', ...args)
}

// Ruby let `let(:executable) { staged_path/"executable" }` at line 24.
pub fn ruby_installer_spec_l24_d8_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable', ...args)
}

// Ruby let `let(:args) { { script: { executable: "executable" } } }` at line 25.
pub fn ruby_installer_spec_l25_d9_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby it `it "looks for the executable in HOMEBREW_PREFIX" do` at line 31.
pub fn ruby_installer_spec_l31_d10_looks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('looks', ...args)
}

// Ruby it `it "does not sandbox the executable" do` at line 42.
pub fn ruby_installer_spec_l42_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Installer, :cask do
// 5:   subject(:installer) { described_class.new(cask, **args) }
// 6:
// 7:   let(:staged_path) { mktmpdir }
// 8:   let(:cask) { instance_double(Cask::Cask, staged_path:) }
// 9:   let(:command) { SystemCommand }
// 10:   let(:args) { {} }
// 11:
// 12:   describe "#install_phase" do
// 13:     context "when given a manual installer" do
// 14:       let(:args) { { manual: "installer" } }
// 15:
// 16:       it "shows a message prompting to run the installer manually" do
// 17:         expect do
// 18:           installer.install_phase(command:)
// 19:         end.to output(%r{open #{staged_path}/installer}).to_stdout
// 20:       end
// 21:     end
// 22:
// 23:     context "when given a script installer" do
// 24:       let(:executable) { staged_path/"executable" }
// 25:       let(:args) { { script: { executable: "executable" } } }
// 26:
// 27:       before do
// 28:         FileUtils.touch executable
// 29:       end
// 30:
// 31:       it "looks for the executable in HOMEBREW_PREFIX" do
// 32:         expect(command).to receive(:run!).with(
// 33:           executable,
// 34:           a_hash_including(
// 35:             env: { "PATH" => PATH.new("#{HOMEBREW_PREFIX}/bin", "#{HOMEBREW_PREFIX}/sbin", ENV.fetch("PATH")) },
// 36:           ),
// 37:         )
// 38:
// 39:         installer.install_phase(command:)
// 40:       end
// 41:
// 42:       it "does not sandbox the executable" do
// 43:         allow(Sandbox).to receive(:available?).and_return(true)
// 44:         expect(Sandbox).not_to receive(:new)
// 45:         expect(command).to receive(:run!)
// 46:
// 47:         installer.install_phase(command:)
// 48:       end
// 49:     end
// 50:   end
// 51: end
