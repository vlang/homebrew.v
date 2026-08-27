module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/relocated_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) do` at line 7.
pub fn ruby_relocated_spec_l7_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:command) { NeverSudoSystemCommand }` at line 16.
pub fn ruby_relocated_spec_l16_d2_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:artifact) { described_class.new(cask, "test_file.txt") }` at line 17.
pub fn ruby_relocated_spec_l17_d3_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifact', ...args)
}

// Ruby let `let(:file) { Pathname("/tmp/test_file.txt") }` at line 20.
pub fn ruby_relocated_spec_l20_d4_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby let `let(:altname) { Pathname("alternate_name.txt") }` at line 21.
pub fn ruby_relocated_spec_l21_d5_altname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('altname', ...args)
}

// Ruby it `it "is a no-op and does not call xattr commands" do` at line 28.
pub fn ruby_relocated_spec_l28_d6_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "calls xattr commands to set metadata" do` at line 43.
pub fn ruby_relocated_spec_l43_d7_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('calls', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5:
// 6: RSpec.describe Cask::Artifact::Relocated, :cask do
// 7:   let(:cask) do
// 8:     Cask::Cask.new("test-cask") do
// 9:       url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 10:       homepage "https://brew.sh/"
// 11:       version "1.0"
// 12:       sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 13:     end
// 14:   end
// 15:
// 16:   let(:command) { NeverSudoSystemCommand }
// 17:   let(:artifact) { described_class.new(cask, "test_file.txt") }
// 18:
// 19:   describe "#add_altname_metadata" do
// 20:     let(:file) { Pathname("/tmp/test_file.txt") }
// 21:     let(:altname) { Pathname("alternate_name.txt") }
// 22:
// 23:     before do
// 24:       allow(file).to receive_messages(basename: Pathname("test_file.txt"), writable?: true, realpath: file)
// 25:     end
// 26:
// 27:     context "when running on Linux", :needs_linux do
// 28:       it "is a no-op and does not call xattr commands" do
// 29:         expect(command).not_to receive(:run)
// 30:         expect(command).not_to receive(:run!)
// 31:
// 32:         artifact.add_altname_metadata(file, altname, command: command)
// 33:       end
// 34:     end
// 35:
// 36:     context "when running on macOS", :needs_macos do
// 37:       before do
// 38:         stdout_double = instance_double(SystemCommand::Result, stdout: "")
// 39:         allow(command).to receive(:run).and_return(stdout_double)
// 40:         allow(command).to receive(:run!)
// 41:       end
// 42:
// 43:       it "calls xattr commands to set metadata" do
// 44:         expect(command).to receive(:run).with("/usr/bin/xattr",
// 45:                                               args:         ["-p", "com.apple.metadata:kMDItemAlternateNames", file],
// 46:                                               print_stderr: false)
// 47:         expect(command).to receive(:run!).twice
// 48:
// 49:         artifact.add_altname_metadata(file, altname, command: command)
// 50:       end
// 51:     end
// 52:   end
// 53: end
