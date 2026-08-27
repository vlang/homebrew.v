module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/ld_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:diagnostics) do` at line 8.
pub fn ruby_ld_spec_l8_d1_diagnostics(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('diagnostics', ...args)
}

// Ruby let `let(:ld_so) { "/lib/ld-linux.so.3" }` at line 18.
pub fn ruby_ld_spec_l18_d2_ld_so(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ld_so', ...args)
}

// Ruby it `it "returns the path to a known dynamic linker" do` at line 25.
pub fn ruby_ld_spec_l25_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when there is no known dynamic linker" do` at line 30.
pub fn ruby_ld_spec_l30_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns path.sysconfdir" do` at line 36.
pub fn ruby_ld_spec_l36_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns fallback on blank diagnostics" do` at line 42.
pub fn ruby_ld_spec_l42_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns all path.system_dirs" do` at line 50.
pub fn ruby_ld_spec_l50_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array on blank diagnostics" do` at line 56.
pub fn ruby_ld_spec_l56_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "parses library paths successfully" do` at line 99.
pub fn ruby_ld_spec_l99_d9_parses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parses', ...args)
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
