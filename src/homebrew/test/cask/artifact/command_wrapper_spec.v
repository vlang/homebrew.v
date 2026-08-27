module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/command_wrapper_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) do` at line 5.
pub fn ruby_command_wrapper_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(described_class) } }` at line 17.
pub fn ruby_command_wrapper_spec_l17_d2_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifact', ...args)
}

// Ruby let `let(:target) { cask.config.binarydir/"example" }` at line 18.
pub fn ruby_command_wrapper_spec_l18_d3_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target', ...args)
}

// Ruby let `let(:custom_target) { cask.config.binarydir/"custom" }` at line 19.
pub fn ruby_command_wrapper_spec_l19_d4_custom_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('custom_target', ...args)
}

// Ruby it `it "writes and links an executable command wrapper" do` at line 31.
pub fn ruby_command_wrapper_spec_l31_d5_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "serialises the wrapper definition" do` at line 44.
pub fn ruby_command_wrapper_spec_l44_d6_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialises', ...args)
}

// Ruby it `it "shell-escapes a single non-array argument" do` at line 55.
pub fn ruby_command_wrapper_spec_l55_d7_shell_escapes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shell-escapes', ...args)
}

// Ruby it `it "serialises Pathname arguments and symbol environment keys as plain strings" do` at line 67.
pub fn ruby_command_wrapper_spec_l67_d8_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialises', ...args)
}

// Ruby it `it "accepts custom wrapper content" do` at line 83.
pub fn ruby_command_wrapper_spec_l83_d9_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "serialises custom wrapper content" do` at line 91.
pub fn ruby_command_wrapper_spec_l91_d10_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialises', ...args)
}

// Ruby it `it "rejects missing content and executable" do` at line 100.
pub fn ruby_command_wrapper_spec_l100_d11_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects command names containing path components" do` at line 106.
pub fn ruby_command_wrapper_spec_l106_d12_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects content with an executable" do` at line 112.
pub fn ruby_command_wrapper_spec_l112_d13_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::CommandWrapper, :cask do
// 5:   let(:cask) do
// 6:     Cask::Cask.new("with-command-wrapper") do
// 7:       version "1.2.3"
// 8:       sha256 :no_check
// 9:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 10:
// 11:       command_wrapper "example",
// 12:                       executable: "/Applications/Example.app/Contents/MacOS/example",
// 13:                       args:       ["--cli", "batch mode"],
// 14:                       env:        { "EXAMPLE_MODE" => "batch" }
// 15:     end
// 16:   end
// 17:   let(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(described_class) } }
// 18:   let(:target) { cask.config.binarydir/"example" }
// 19:   let(:custom_target) { cask.config.binarydir/"custom" }
// 20:
// 21:   around do |example|
// 22:     cask.staged_path.mkpath
// 23:     target.dirname.mkpath
// 24:     example.run
// 25:   ensure
// 26:     FileUtils.rm_f target
// 27:     FileUtils.rm_f custom_target
// 28:     FileUtils.rm_rf cask.staged_path
// 29:   end
// 30:
// 31:   it "writes and links an executable command wrapper" do
// 32:     artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 33:
// 34:     expect(target).to be_a_symlink.and have_attributes(
// 35:       read:        <<~BASH,
// 36:         #!/bin/bash
// 37:         EXAMPLE_MODE="batch" exec "/Applications/Example.app/Contents/MacOS/example" --cli batch\\ mode "$@"
// 38:       BASH
// 39:       executable?: true,
// 40:       readlink:    cask.staged_path/".homebrew-command-wrappers/example",
// 41:     )
// 42:   end
// 43:
// 44:   it "serialises the wrapper definition" do
// 45:     expect(artifact.to_args).to eq([
// 46:       "example",
// 47:       {
// 48:         executable: "/Applications/Example.app/Contents/MacOS/example",
// 49:         args:       ["--cli", "batch mode"],
// 50:         env:        { "EXAMPLE_MODE" => "batch" },
// 51:       },
// 52:     ])
// 53:   end
// 54:
// 55:   it "shell-escapes a single non-array argument" do
// 56:     wrapper = described_class.from_args(cask, "custom",
// 57:                                         executable: "/usr/bin/example",
// 58:                                         args:       "two words; true")
// 59:     wrapper.install_phase(command: NeverSudoSystemCommand, force: false)
// 60:
// 61:     expect(custom_target.read).to eq(<<~BASH)
// 62:       #!/bin/bash
// 63:       exec "/usr/bin/example" two\\ words\\;\\ true "$@"
// 64:     BASH
// 65:   end
// 66:
// 67:   it "serialises Pathname arguments and symbol environment keys as plain strings" do
// 68:     wrapper = described_class.from_args(cask, "custom",
// 69:                                         executable: Pathname("/usr/bin/example"),
// 70:                                         args:       Pathname("/etc/example.conf"),
// 71:                                         env:        { EXAMPLE_MODE: Pathname("/var/example") })
// 72:
// 73:     expect(wrapper.to_args).to eq([
// 74:       "custom",
// 75:       {
// 76:         executable: "/usr/bin/example",
// 77:         args:       ["/etc/example.conf"],
// 78:         env:        { "EXAMPLE_MODE" => "/var/example" },
// 79:       },
// 80:     ])
// 81:   end
// 82:
// 83:   it "accepts custom wrapper content" do
// 84:     content = "#!/bin/sh\nexit 1\n"
// 85:     custom_artifact = described_class.from_args(cask, "custom", content:)
// 86:     custom_artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 87:
// 88:     expect(custom_target).to be_a_symlink.and have_attributes(read: content, executable?: true)
// 89:   end
// 90:
// 91:   it "serialises custom wrapper content" do
// 92:     custom_artifact = described_class.from_args(cask, "custom", content: "#!/bin/sh\nexit 1\n")
// 93:
// 94:     expect(custom_artifact.to_args).to eq([
// 95:       "custom",
// 96:       { content: "#!/bin/sh\nexit 1\n" },
// 97:     ])
// 98:   end
// 99:
// 100:   it "rejects missing content and executable" do
// 101:     expect do
// 102:       described_class.from_args(cask, "other")
// 103:     end.to raise_error(Cask::CaskInvalidError, /requires content or executable/)
// 104:   end
// 105:
// 106:   it "rejects command names containing path components" do
// 107:     expect do
// 108:       described_class.from_args(cask, "../other", executable: "example")
// 109:     end.to raise_error(Cask::CaskInvalidError, /requires a command name without path components/)
// 110:   end
// 111:
// 112:   it "rejects content with an executable" do
// 113:     expect do
// 114:       described_class.from_args(cask, "other", content: "#!/bin/sh\n", executable: "example")
// 115:     end.to raise_error(Cask::CaskInvalidError, /content or executable, not both/)
// 116:   end
// 117: end
