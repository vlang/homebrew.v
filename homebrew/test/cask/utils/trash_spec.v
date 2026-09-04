module utils

import ruby
import homebrew.cask.utils as trash_utils
import homebrew.extend.os.mac.cask.utils as mac_trash
import os

fn trash_spec_root() string {
	return os.join_path(os.temp_dir(), 'brew-v-trash-spec-${os.getpid()}')
}

fn trash_spec_retry(path string) !string {
	return '/Users/example/.Trash/${os.file_name(path)}'
}

// Translated from Homebrew/brew `test/cask/utils/trash_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { Pathname("/tmp/example") }` at line 8.
pub fn ruby_trash_spec_l8_d1_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/tmp/example')
}

// Ruby let `let(:trashed_path) { "/Users/example/.Trash/example" }` at line 9.
pub fn ruby_trash_spec_l9_d2_trashed_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/Users/example/.Trash/example')
}

// Ruby it `it "uses the Foundation trash implementation by default" do` at line 11.
pub fn ruby_trash_spec_l11_d3_uses(args ...ruby.Value) ruby.Value {
	root := trash_spec_root()
	os.rmdir_all(root) or {}
	os.mkdir_all(root) or { return ruby.bool_value(false) }
	defer { os.rmdir_all(root) or {} }
	path := os.join_path(root, 'example')
	os.write_file(path, 'example') or { return ruby.bool_value(false) }
	result := mac_trash.mac_trash_paths([path], os.join_path(root, '.Trash'), trash_spec_retry)
	return ruby.bool_value(result.trashed.len == 1 && result.untrashable.len == 0)
}

// Ruby it `it "retries untrashable paths after gaining permissions" do` at line 21.
pub fn ruby_trash_spec_l21_d4_retries(args ...ruby.Value) ruby.Value {
	result := mac_trash.mac_trash_paths(['/tmp/missing-example'], os.join_path(trash_spec_root(), '.Trash'), trash_spec_retry)
	return ruby.bool_value(result.trashed == [
		'/Users/example/.Trash/missing-example',
	] && result.untrashable.len == 0)
}

// Ruby let `let(:deletion_time) { Time.local(2026, 4, 25, 13, 14, 15) }` at line 39.
pub fn ruby_trash_spec_l39_d5_deletion_time(args ...ruby.Value) ruby.Value {
	return ruby.string_value('2026-04-25T13:14:15')
}

// Ruby let `let(:xdg_data_home) { mktmpdir/"xdg-data" }` at line 40.
pub fn ruby_trash_spec_l40_d6_xdg_data_home(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(trash_spec_root(), 'xdg-data'))
}

// Ruby let `let(:trash_path) { xdg_data_home/"Trash" }` at line 41.
pub fn ruby_trash_spec_l41_d7_trash_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(trash_utils.home_trash_path(os.join_path(trash_spec_root(), 'xdg-data'), os.home_dir()))
}

// Ruby let `let(:files_path) { trash_path/"files" }` at line 42.
pub fn ruby_trash_spec_l42_d8_files_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(trash_utils.home_trash_path(os.join_path(trash_spec_root(), 'xdg-data'), os.home_dir()), 'files'))
}

// Ruby let `let(:info_path) { trash_path/"info" }` at line 43.
pub fn ruby_trash_spec_l43_d9_info_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(trash_utils.home_trash_path(os.join_path(trash_spec_root(), 'xdg-data'), os.home_dir()), 'info'))
}

// Ruby let `let(:path) { mktmpdir/"folder with spaces"/"example file.txt" }` at line 44.
pub fn ruby_trash_spec_l44_d10_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(trash_spec_root(), 'folder with spaces', 'example file.txt'))
}

// Ruby it `it "moves files into the XDG trash and writes a trashinfo file" do` at line 54.
pub fn ruby_trash_spec_l54_d11_moves(args ...ruby.Value) ruby.Value {
	root := trash_spec_root()
	os.rmdir_all(root) or {}
	defer { os.rmdir_all(root) or {} }
	xdg := os.join_path(root, 'xdg-data')
	path := os.join_path(root, 'folder with spaces', 'example file.txt')
	os.mkdir_all(os.dir(path)) or { return ruby.bool_value(false) }
	os.write_file(path, 'example') or { return ruby.bool_value(false) }
	result := trash_utils.freedesktop_trash([path], xdg, os.home_dir(), '2026-04-25T13:14:15')
	files_path := os.join_path(xdg, 'Trash', 'files', 'example file.txt')
	info_path := os.join_path(xdg, 'Trash', 'info', 'example file.txt.trashinfo')
	contents := os.read_file(files_path) or { '' }
	info := os.read_file(info_path) or { '' }
	return ruby.bool_value(!os.exists(path) && result.trashed == [path] && result.untrashable.len == 0 && contents == 'example' && info == '[Trash Info]\nPath=${path.replace(' ', '%20')}\nDeletionDate=2026-04-25T13:14:15\n')
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
