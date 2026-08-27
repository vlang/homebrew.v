module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/directory_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) do` at line 7.
pub fn ruby_directory_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby let `let(:unpack_dir) { mktmpdir }` at line 17.
pub fn ruby_directory_spec_l17_d2_unpack_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpack_dir', ...args)
}

// Ruby subject `subject(:strategy) { described_class.new(path, move:) }` at line 20.
pub fn ruby_directory_spec_l20_d3_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby it `it "does not follow symlinks" do` at line 22.
pub fn ruby_directory_spec_l22_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not follow top level symlinks to directories" do` at line 27.
pub fn ruby_directory_spec_l27_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "preserves permissions of contained files" do` at line 32.
pub fn ruby_directory_spec_l32_d6_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "preserves permissions of contained subdirectories" do` at line 39.
pub fn ruby_directory_spec_l39_d7_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "preserves permissions of the destination directory" do` at line 48.
pub fn ruby_directory_spec_l48_d8_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "preserves mtime of contained files and directories" do` at line 56.
pub fn ruby_directory_spec_l56_d9_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "preserves unrelated destination files and subdirectories" do` at line 65.
pub fn ruby_directory_spec_l65_d10_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "overwrites destination files/symlinks with source files/symlinks" do` at line 74.
pub fn ruby_directory_spec_l74_d11_overwrites(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('overwrites', ...args)
}

// Ruby it `it "fails when overwriting a directory with a file" do` at line 84.
pub fn ruby_directory_spec_l84_d12_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails when overwriting a nested directory with a file" do` at line 89.
pub fn ruby_directory_spec_l89_d13_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "preserves hardlinks" do` at line 103.
pub fn ruby_directory_spec_l103_d14_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "fails when overwriting a file with a directory" do` at line 110.
pub fn ruby_directory_spec_l110_d15_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Directory do
// 7:   let(:path) do
// 8:     mktmpdir.tap do |path|
// 9:       FileUtils.touch path/"file"
// 10:       FileUtils.ln_s "file", path/"symlink"
// 11:       FileUtils.ln path/"file", path/"hardlink"
// 12:       FileUtils.mkdir path/"folder"
// 13:       FileUtils.ln_s "folder", path/"folderSymlink"
// 14:     end
// 15:   end
// 16:
// 17:   let(:unpack_dir) { mktmpdir }
// 18:
// 19:   shared_examples "extract directory" do |move:|
// 20:     subject(:strategy) { described_class.new(path, move:) }
// 21:
// 22:     it "does not follow symlinks" do
// 23:       strategy.extract(to: unpack_dir)
// 24:       expect(unpack_dir/"symlink").to be_a_symlink
// 25:     end
// 26:
// 27:     it "does not follow top level symlinks to directories" do
// 28:       strategy.extract(to: unpack_dir)
// 29:       expect(unpack_dir/"folderSymlink").to be_a_symlink
// 30:     end
// 31:
// 32:     it "preserves permissions of contained files" do
// 33:       FileUtils.chmod 0644, path/"file"
// 34:
// 35:       strategy.extract(to: unpack_dir)
// 36:       expect((unpack_dir/"file").stat.mode & 0777).to eq 0644
// 37:     end
// 38:
// 39:     it "preserves permissions of contained subdirectories" do
// 40:       FileUtils.mkdir unpack_dir/"folder"
// 41:       FileUtils.chmod 0755, unpack_dir/"folder"
// 42:       FileUtils.chmod 0700, path/"folder"
// 43:
// 44:       strategy.extract(to: unpack_dir)
// 45:       expect((unpack_dir/"folder").stat.mode & 0777).to eq 0700
// 46:     end
// 47:
// 48:     it "preserves permissions of the destination directory" do
// 49:       FileUtils.chmod 0700, path
// 50:       FileUtils.chmod 0755, unpack_dir
// 51:
// 52:       strategy.extract(to: unpack_dir)
// 53:       expect(unpack_dir.stat.mode & 0777).to eq 0755
// 54:     end
// 55:
// 56:     it "preserves mtime of contained files and directories" do
// 57:       FileUtils.mkdir unpack_dir/"folder"
// 58:       FileUtils.touch path/"folder", mtime: Time.utc(2000, 1, 2, 3, 4, 5, 678999), nocreate: true
// 59:       mtimes = path.children.to_h { |child| [child.basename, child.lstat.mtime] }
// 60:
// 61:       strategy.extract(to: unpack_dir)
// 62:       expect(unpack_dir.children.to_h { |child| [child.basename, child.lstat.mtime] }).to eq mtimes
// 63:     end
// 64:
// 65:     it "preserves unrelated destination files and subdirectories" do
// 66:       FileUtils.touch unpack_dir/"existing_file"
// 67:       FileUtils.mkdir unpack_dir/"existing_folder"
// 68:
// 69:       strategy.extract(to: unpack_dir)
// 70:       expect(unpack_dir/"existing_file").to be_a_file
// 71:       expect(unpack_dir/"existing_folder").to be_a_directory
// 72:     end
// 73:
// 74:     it "overwrites destination files/symlinks with source files/symlinks" do
// 75:       FileUtils.mkdir unpack_dir/"existing_folder"
// 76:       FileUtils.ln_s unpack_dir/"existing_folder", unpack_dir/"symlink"
// 77:       (unpack_dir/"file").write "existing contents"
// 78:
// 79:       strategy.extract(to: unpack_dir)
// 80:       expect((unpack_dir/"file").read).to be_empty
// 81:       expect((unpack_dir/"symlink").readlink).to eq Pathname("file")
// 82:     end
// 83:
// 84:     it "fails when overwriting a directory with a file" do
// 85:       FileUtils.mkdir unpack_dir/"file"
// 86:       expect { strategy.extract(to: unpack_dir) }.to raise_error(/Is a directory|cannot overwrite directory/i)
// 87:     end
// 88:
// 89:     it "fails when overwriting a nested directory with a file" do
// 90:       FileUtils.touch path/"folder/nested"
// 91:       FileUtils.mkdir_p unpack_dir/"folder/nested"
// 92:       expect { strategy.extract(to: unpack_dir) }.to raise_error(/Is a directory|cannot overwrite directory/i)
// 93:     end
// 94:   end
// 95:
// 96:   context "with `move: false`" do
// 97:     include_examples "extract directory", move: false
// 98:   end
// 99:
// 100:   context "with `move: true`" do
// 101:     include_examples "extract directory", move: true
// 102:
// 103:     it "preserves hardlinks" do
// 104:       strategy.extract(to: unpack_dir)
// 105:       expect((unpack_dir/"file").stat.ino).to eq (unpack_dir/"hardlink").stat.ino
// 106:     end
// 107:
// 108:     # NOTE: We don't test `move: false` because system cp behaviour is inconsistent,
// 109:     # e.g. Ventura cp does not error but Sequoia and Linux cp will error
// 110:     it "fails when overwriting a file with a directory" do
// 111:       FileUtils.touch unpack_dir/"folder"
// 112:       expect { strategy.extract(to: unpack_dir) }.to raise_error(/cannot overwrite non-directory/i)
// 113:     end
// 114:   end
// 115: end
