module utils

import brew_runtime

// Translated from Homebrew/brew `test/cask/utils/trash_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { Pathname("/tmp/example") }` at line 8.
pub fn ruby_trash_spec_l8_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby let `let(:trashed_path) { "/Users/example/.Trash/example" }` at line 9.
pub fn ruby_trash_spec_l9_d2_trashed_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trashed_path', ...args)
}

// Ruby it `it "uses the Foundation trash implementation by default" do` at line 11.
pub fn ruby_trash_spec_l11_d3_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "retries untrashable paths after gaining permissions" do` at line 21.
pub fn ruby_trash_spec_l21_d4_retries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retries', ...args)
}

// Ruby let `let(:deletion_time) { Time.local(2026, 4, 25, 13, 14, 15) }` at line 39.
pub fn ruby_trash_spec_l39_d5_deletion_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deletion_time', ...args)
}

// Ruby let `let(:xdg_data_home) { mktmpdir/"xdg-data" }` at line 40.
pub fn ruby_trash_spec_l40_d6_xdg_data_home(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xdg_data_home', ...args)
}

// Ruby let `let(:trash_path) { xdg_data_home/"Trash" }` at line 41.
pub fn ruby_trash_spec_l41_d7_trash_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trash_path', ...args)
}

// Ruby let `let(:files_path) { trash_path/"files" }` at line 42.
pub fn ruby_trash_spec_l42_d8_files_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('files_path', ...args)
}

// Ruby let `let(:info_path) { trash_path/"info" }` at line 43.
pub fn ruby_trash_spec_l43_d9_info_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('info_path', ...args)
}

// Ruby let `let(:path) { mktmpdir/"folder with spaces"/"example file.txt" }` at line 44.
pub fn ruby_trash_spec_l44_d10_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby it `it "moves files into the XDG trash and writes a trashinfo file" do` at line 54.
pub fn ruby_trash_spec_l54_d11_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/utils/trash"
// 5:
// 6: RSpec.describe Cask::Utils::Trash do
// 7:   describe "::trash", :needs_macos do
// 8:     let(:path) { Pathname("/tmp/example") }
// 9:     let(:trashed_path) { "/Users/example/.Trash/example" }
// 10:
// 11:     it "uses the Foundation trash implementation by default" do
// 12:       expect(MacOS::FFI::Foundation).to receive(:trash_paths)
// 13:         .with([path.to_s])
// 14:         .and_return([[trashed_path], []])
// 15:
// 16:       with_env(HOMEBREW_DEVELOPER: nil) do
// 17:         expect(described_class.trash(path)).to eq([[trashed_path], []])
// 18:       end
// 19:     end
// 20:
// 21:     it "retries untrashable paths after gaining permissions" do
// 22:       expect(MacOS::FFI::Foundation).to receive(:trash_paths)
// 23:         .with([path.to_s])
// 24:         .and_return([[], [path.to_s]])
// 25:       expect(Cask::Utils).to receive(:gain_permissions)
// 26:         .with(path, ["-R"], SystemCommand)
// 27:         .and_yield
// 28:       expect(MacOS::FFI::Foundation).to receive(:trash_item)
// 29:         .with(path.to_s)
// 30:         .and_return(trashed_path)
// 31:
// 32:       with_env(HOMEBREW_DEVELOPER: nil) do
// 33:         expect(described_class.trash(path)).to eq([[trashed_path], []])
// 34:       end
// 35:     end
// 36:   end
// 37:
// 38:   describe "::freedesktop_trash" do
// 39:     let(:deletion_time) { Time.local(2026, 4, 25, 13, 14, 15) }
// 40:     let(:xdg_data_home) { mktmpdir/"xdg-data" }
// 41:     let(:trash_path) { xdg_data_home/"Trash" }
// 42:     let(:files_path) { trash_path/"files" }
// 43:     let(:info_path) { trash_path/"info" }
// 44:     let(:path) { mktmpdir/"folder with spaces"/"example file.txt" }
// 45:
// 46:     around do |example|
// 47:       old_xdg_data_home = ENV.fetch("XDG_DATA_HOME", nil)
// 48:       ENV["XDG_DATA_HOME"] = xdg_data_home.to_s
// 49:       example.run
// 50:     ensure
// 51:       ENV["XDG_DATA_HOME"] = old_xdg_data_home
// 52:     end
// 53:
// 54:     it "moves files into the XDG trash and writes a trashinfo file" do
// 55:       path.dirname.mkpath
// 56:       path.write("example")
// 57:       allow(Time).to receive(:now).and_return(deletion_time)
// 58:
// 59:       trashed, untrashable = described_class.freedesktop_trash(path)
// 60:
// 61:       expect(path).not_to exist
// 62:       expect(trashed).to eq([path.to_s])
// 63:       expect(untrashable).to be_empty
// 64:       expect((files_path/"example file.txt").read).to eq("example")
// 65:       expect((info_path/"example file.txt.trashinfo").read).to eq(<<~EOS)
// 66:         [Trash Info]
// 67:         Path=#{URI::DEFAULT_PARSER.escape(path.to_s)}
// 68:         DeletionDate=2026-04-25T13:14:15
// 69:       EOS
// 70:     end
// 71:   end
// 72: end
