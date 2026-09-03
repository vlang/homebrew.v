module linux

import brew_runtime
import homebrew.os.linux as linux_ld
import os
import time

// Translated from Homebrew/brew `test/os/linux/ld_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub const ld_spec_diagnostics = 'path.prefix="/usr"\npath.sysconfdir="/usr/local/etc"\npath.system_dirs[0x0]="/lib64"\npath.system_dirs[0x1]="/var/lib"\n'
pub const ld_spec_linker = '/lib/ld-linux.so.3'

fn ld_spec_known_linker_executable(path string) bool {
	return path == ld_spec_linker
}

fn ld_spec_never_executable(_ string) bool {
	return false
}

pub fn ld_spec_write_configuration(root string) !string {
	first := os.join_path(root, 'subdir1')
	second := os.join_path(root, 'subdir2')
	os.mkdir_all(first)!
	os.mkdir_all(second)!
	configuration := os.join_path(root, 'ld.so.conf')
	os.write_file(configuration, '# This line is a comment\n\ninclude ${first}/*.conf # This is an end-of-line comment, should be ignored\n\n# subdir2 is an empty directory\ninclude ${second}/*.conf\n\n/a/b/c\n  /d/e/f # Indentation on this line should be ignored\n/a/b/c # Duplicate entry should be ignored\n')!
	os.write_file(os.join_path(first, '1-1.conf'), '/foo/bar\n/baz/qux\n')!
	os.write_file(os.join_path(first, '1-2.conf'), '/g/h/i\n')!
	os.write_file(os.join_path(first, '1-3.conf'), '\n\t\n\t\n')!
	os.write_file(os.join_path(first, '1-4.conf'), '')!
	return configuration
}

pub fn ld_spec_parsed_library_paths(root string) ![]string {
	configuration := ld_spec_write_configuration(root)!
	return linux_ld.library_paths_from_file(configuration)
}

// Ruby let `let(:diagnostics) do` at line 8.
pub fn ruby_ld_spec_l8_d1_diagnostics(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(ld_spec_diagnostics)
}

// Ruby let `let(:ld_so) { "/lib/ld-linux.so.3" }` at line 18.
pub fn ruby_ld_spec_l18_d2_ld_so(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(ld_spec_linker)
}

// Ruby it `it "returns the path to a known dynamic linker" do` at line 25.
pub fn ruby_ld_spec_l25_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	linker := linux_ld.find_system_ld_so_in(linux_ld.dynamic_linkers, ld_spec_known_linker_executable) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(linker == ld_spec_linker)
}

// Ruby it `it "returns nil when there is no known dynamic linker" do` at line 30.
pub fn ruby_ld_spec_l30_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	linker := linux_ld.find_system_ld_so_in(linux_ld.dynamic_linkers, ld_spec_never_executable)
	return brew_runtime.bool_value(linker == none)
}

// Ruby it `it "returns path.sysconfdir" do` at line 36.
pub fn ruby_ld_spec_l36_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	diagnostics := if args.len > 0 { args[0].as_string() } else { ld_spec_diagnostics }
	return brew_runtime.bool_value(linux_ld.sysconfdir_from_diagnostics(diagnostics) == '/usr/local/etc')
}

// Ruby it `it "returns fallback on blank diagnostics" do` at line 42.
pub fn ruby_ld_spec_l42_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	diagnostics := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(linux_ld.sysconfdir_from_diagnostics(diagnostics) == '/etc')
}

// Ruby it `it "returns all path.system_dirs" do` at line 50.
pub fn ruby_ld_spec_l50_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	diagnostics := if args.len > 0 { args[0].as_string() } else { ld_spec_diagnostics }
	return brew_runtime.bool_value(linux_ld.system_dirs_from_diagnostics(diagnostics) == [
		'/lib64',
		'/var/lib',
	])
}

// Ruby it `it "returns an empty array on blank diagnostics" do` at line 56.
pub fn ruby_ld_spec_l56_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	diagnostics := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(linux_ld.system_dirs_from_diagnostics(diagnostics).len == 0)
}

// Ruby it `it "parses library paths successfully" do` at line 99.
pub fn ruby_ld_spec_l99_d9_parses(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-ld-spec-${os.getpid()}-${time.now().unix_micro()}')
	}
	cleanup := args.len == 0
	defer {
		if cleanup {
			os.rmdir_all(root) or {}
		}
	}
	paths := ld_spec_parsed_library_paths(root) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(paths == ['/foo/bar', '/baz/qux', '/g/h/i', '/a/b/c', '/d/e/f'])
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/ld"
// 5: require "tmpdir"
// 6:
// 7: RSpec.describe OS::Linux::Ld do
// 8:   let(:diagnostics) do
// 9:     <<~EOS
// 10:       path.prefix="/usr"
// 11:       path.sysconfdir="/usr/local/etc"
// 12:       path.system_dirs[0x0]="/lib64"
// 13:       path.system_dirs[0x1]="/var/lib"
// 14:     EOS
// 15:   end
// 16:
// 17:   describe "::system_ld_so" do
// 18:     let(:ld_so) { "/lib/ld-linux.so.3" }
// 19:
// 20:     before do
// 21:       allow(File).to receive(:executable?).and_return(false)
// 22:       described_class.system_ld_so = nil
// 23:     end
// 24:
// 25:     it "returns the path to a known dynamic linker" do
// 26:       allow(File).to receive(:executable?).with(ld_so).and_return(true)
// 27:       expect(described_class.system_ld_so).to eq(Pathname(ld_so))
// 28:     end
// 29:
// 30:     it "returns nil when there is no known dynamic linker" do
// 31:       expect(described_class.system_ld_so).to be_nil
// 32:     end
// 33:   end
// 34:
// 35:   describe "::sysconfdir" do
// 36:     it "returns path.sysconfdir" do
// 37:       allow(described_class).to receive(:ld_so_diagnostics).and_return(diagnostics)
// 38:       expect(described_class.sysconfdir).to eq("/usr/local/etc")
// 39:       expect(described_class.sysconfdir(brewed: false)).to eq("/usr/local/etc")
// 40:     end
// 41:
// 42:     it "returns fallback on blank diagnostics" do
// 43:       allow(described_class).to receive(:ld_so_diagnostics).and_return("")
// 44:       expect(described_class.sysconfdir).to eq("/etc")
// 45:       expect(described_class.sysconfdir(brewed: false)).to eq("/etc")
// 46:     end
// 47:   end
// 48:
// 49:   describe "::system_dirs" do
// 50:     it "returns all path.system_dirs" do
// 51:       allow(described_class).to receive(:ld_so_diagnostics).and_return(diagnostics)
// 52:       expect(described_class.system_dirs).to eq(["/lib64", "/var/lib"])
// 53:       expect(described_class.system_dirs(brewed: false)).to eq(["/lib64", "/var/lib"])
// 54:     end
// 55:
// 56:     it "returns an empty array on blank diagnostics" do
// 57:       allow(described_class).to receive(:ld_so_diagnostics).and_return("")
// 58:       expect(described_class.system_dirs).to eq([])
// 59:       expect(described_class.system_dirs(brewed: false)).to eq([])
// 60:     end
// 61:   end
// 62:
// 63:   describe "::library_paths" do
// 64:     ld_etc = Pathname("")
// 65:     before do
// 66:       ld_etc = Pathname(Dir.mktmpdir("homebrew-tests-ld-etc-", Dir.tmpdir))
// 67:       FileUtils.mkdir [ld_etc/"subdir1", ld_etc/"subdir2"]
// 68:       (ld_etc/"ld.so.conf").write <<~EOS
// 69:         # This line is a comment
// 70:
// 71:         include #{ld_etc}/subdir1/*.conf # This is an end-of-line comment, should be ignored
// 72:
// 73:         # subdir2 is an empty directory
// 74:         include #{ld_etc}/subdir2/*.conf
// 75:
// 76:         /a/b/c
// 77:           /d/e/f # Indentation on this line should be ignored
// 78:         /a/b/c # Duplicate entry should be ignored
// 79:       EOS
// 80:
// 81:       (ld_etc/"subdir1/1-1.conf").write <<~EOS
// 82:         /foo/bar
// 83:         /baz/qux
// 84:       EOS
// 85:
// 86:       (ld_etc/"subdir1/1-2.conf").write <<~EOS
// 87:         /g/h/i
// 88:       EOS
// 89:
// 90:       # Empty files (or files containing only whitespace) should be ignored
// 91:       (ld_etc/"subdir1/1-3.conf").write "\n\t\n\t\n"
// 92:       (ld_etc/"subdir1/1-4.conf").write ""
// 93:     end
// 94:
// 95:     after do
// 96:       FileUtils.rm_rf ld_etc
// 97:     end
// 98:
// 99:     it "parses library paths successfully" do
// 100:       expect(described_class.library_paths(ld_etc/"ld.so.conf")).to eq(%w[/foo/bar /baz/qux /g/h/i /a/b/c /d/e/f])
// 101:     end
// 102:   end
// 103: end
