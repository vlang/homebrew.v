module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/utils_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:command) { NeverSudoSystemCommand }` at line 5.
pub fn ruby_utils_spec_l5_d1_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:dir) { mktmpdir }` at line 6.
pub fn ruby_utils_spec_l6_d2_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby let `let(:path) { dir/"a/b/c" }` at line 7.
pub fn ruby_utils_spec_l7_d3_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby let `let(:link) { dir/"link" }` at line 8.
pub fn ruby_utils_spec_l8_d4_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link', ...args)
}

// Ruby it `it "creates a directory" do` at line 11.
pub fn ruby_utils_spec_l11_d5_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates a directory with `sudo`" do` at line 20.
pub fn ruby_utils_spec_l20_d6_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "removes the symlink, not the file it points to" do` at line 43.
pub fn ruby_utils_spec_l43_d7_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "removes the symlink, not the directory it points to" do` at line 62.
pub fn ruby_utils_spec_l62_d8_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Utils do
// 5:   let(:command) { NeverSudoSystemCommand }
// 6:   let(:dir) { mktmpdir }
// 7:   let(:path) { dir/"a/b/c" }
// 8:   let(:link) { dir/"link" }
// 9:
// 10:   describe "::gain_permissions_mkpath" do
// 11:     it "creates a directory" do
// 12:       expect(path).not_to exist
// 13:       described_class.gain_permissions_mkpath(path, command:)
// 14:       expect(path).to be_a_directory
// 15:       described_class.gain_permissions_mkpath(path, command:)
// 16:       expect(path).to be_a_directory
// 17:     end
// 18:
// 19:     context "when parent directory is not writable" do
// 20:       it "creates a directory with `sudo`" do
// 21:         FileUtils.chmod "-w", dir
// 22:         expect(dir).not_to be_writable
// 23:
// 24:         expect(command).to receive(:run!).exactly(:once).and_wrap_original do |original, *args, **options|
// 25:           FileUtils.chmod "+w", dir
// 26:           original.call(*args, **options)
// 27:           FileUtils.chmod "-w", dir
// 28:         end
// 29:
// 30:         expect(path).not_to exist
// 31:         described_class.gain_permissions_mkpath(path, command:)
// 32:         expect(path).to be_a_directory
// 33:         described_class.gain_permissions_mkpath(path, command:)
// 34:         expect(path).to be_a_directory
// 35:
// 36:         expect(dir).not_to be_writable
// 37:         FileUtils.chmod "+w", dir
// 38:       end
// 39:     end
// 40:   end
// 41:
// 42:   describe "::gain_permissions_remove" do
// 43:     it "removes the symlink, not the file it points to" do
// 44:       path.dirname.mkpath
// 45:       FileUtils.touch path
// 46:       FileUtils.ln_s path, link
// 47:
// 48:       expect(path).to be_a_file
// 49:       expect(link).to be_a_symlink
// 50:       expect(link.readlink).to eq path
// 51:
// 52:       described_class.gain_permissions_remove(link, command:)
// 53:
// 54:       expect(path).to be_a_file
// 55:       expect(link).not_to exist
// 56:
// 57:       described_class.gain_permissions_remove(path, command:)
// 58:
// 59:       expect(path).not_to exist
// 60:     end
// 61:
// 62:     it "removes the symlink, not the directory it points to" do
// 63:       path.mkpath
// 64:       FileUtils.ln_s path, link
// 65:
// 66:       expect(path).to be_a_directory
// 67:       expect(link).to be_a_symlink
// 68:       expect(link.readlink).to eq path
// 69:
// 70:       described_class.gain_permissions_remove(link, command:)
// 71:
// 72:       expect(path).to be_a_directory
// 73:       expect(link).not_to exist
// 74:
// 75:       described_class.gain_permissions_remove(path, command:)
// 76:
// 77:       expect(path).not_to exist
// 78:     end
// 79:   end
// 80: end
