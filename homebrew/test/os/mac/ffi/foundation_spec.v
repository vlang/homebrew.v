module ffi

import homebrew.os.mac.ffi as mac_ffi
import os

// Translated from Homebrew/brew `test/os/mac/ffi/foundation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "moves a file to the user's Trash" do` at line 8.
pub fn ruby_foundation_spec_l8_d1_moves() !bool {
	tmpdir := os.join_path(os.temp_dir(), 'brew-v-foundation-${os.getpid()}')
	trash := os.join_path(tmpdir, '.Trash')
	path := os.join_path(tmpdir, 'homebrew-trash-ffi-test')
	os.mkdir_all(tmpdir)!
	defer { os.rmdir_all(tmpdir) or {} }
	os.write_file(path, 'trash')!
	trashed_path := mac_ffi.foundation_trash_item(path, trash)!
	return !os.exists(path) && trashed_path != '' && os.exists(trashed_path)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/foundation"
// 5:
// 6: RSpec.describe MacOS::FFI::Foundation, :needs_macos do
// 7:   describe ".trash_item" do
// 8:     it "moves a file to the user's Trash" do
// 9:       trashed_path = T.let(nil, T.nilable(String))
// 10:
// 11:       mktmpdir do |tmpdir|
// 12:         path = tmpdir/"homebrew-trash-ffi-test"
// 13:         path.write("trash")
// 14:
// 15:         trashed_path = described_class.trash_item(path.to_s)
// 16:
// 17:         expect(path).not_to exist
// 18:         raise "Failed to trash #{path}" unless trashed_path
// 19:
// 20:         expect(Pathname(trashed_path)).to exist
// 21:       ensure
// 22:         FileUtils.rm_rf(trashed_path) if trashed_path
// 23:       end
// 24:     end
// 25:   end
// 26: end
