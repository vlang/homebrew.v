module test

import brew_runtime

// Translated from Homebrew/brew `test/sandbox_linux_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:sandbox) { described_class.new }` at line 8.
pub fn ruby_sandbox_linux_spec_l8_d1_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandbox', ...args)
}

// Ruby it `it "allows writing to an allowed path" do` at line 15.
pub fn ruby_sandbox_linux_spec_l15_d2_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "fails when writing to a path that has not been allowed" do` at line 23.
pub fn ruby_sandbox_linux_spec_l23_d3_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "returns the command exit status" do` at line 33.
pub fn ruby_sandbox_linux_spec_l33_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "allows spawning a pseudo-terminal" do` at line 37.
pub fn ruby_sandbox_linux_spec_l37_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "prevents listing a denied read hierarchy" do` at line 45.
pub fn ruby_sandbox_linux_spec_l45_d6_prevents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prevents', ...args)
}

// Ruby it `it "prevents executing from a denied read hierarchy" do` at line 54.
pub fn ruby_sandbox_linux_spec_l54_d7_prevents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prevents', ...args)
}

// Ruby it `it "allows standard devices and shared memory" do` at line 65.
pub fn ruby_sandbox_linux_spec_l65_d8_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sandbox"
// 5: require "extend/os/linux/sandbox" if OS.linux?
// 6:
// 7: RSpec.describe Sandbox, :needs_linux do
// 8:   subject(:sandbox) { described_class.new }
// 9:
// 10:   describe "#run" do
// 11:     before do
// 12:       skip "Sandbox not available." unless described_class.available?
// 13:     end
// 14:
// 15:     it "allows writing to an allowed path" do
// 16:       file = mktmpdir/"foo"
// 17:       sandbox.allow_write path: file
// 18:       sandbox.run "touch", file
// 19:
// 20:       expect(file).to exist
// 21:     end
// 22:
// 23:     it "fails when writing to a path that has not been allowed" do
// 24:       file = mktmpdir/"foo"
// 25:
// 26:       expect do
// 27:         sandbox.run "touch", file
// 28:       end.to raise_error(ErrorDuringExecution)
// 29:
// 30:       expect(file).not_to exist
// 31:     end
// 32:
// 33:     it "returns the command exit status" do
// 34:       expect { sandbox.run "false" }.to raise_error(ErrorDuringExecution)
// 35:     end
// 36:
// 37:     it "allows spawning a pseudo-terminal" do
// 38:       sandbox.deny_read_path mktmpdir
// 39:
// 40:       expect do
// 41:         sandbox.run RUBY_PATH, "-rpty", "-e", 'PTY.spawn("true") { |_, _, pid| Process.wait(pid) }'
// 42:       end.not_to raise_error
// 43:     end
// 44:
// 45:     it "prevents listing a denied read hierarchy" do
// 46:       denied_dir = mktmpdir
// 47:       FileUtils.touch denied_dir/"secret"
// 48:       sandbox.deny_read_path denied_dir
// 49:
// 50:       expect { sandbox.run "/bin/sh", "-c", 'ls "$1" | grep -q secret', "brew-test", denied_dir }
// 51:         .to raise_error(ErrorDuringExecution)
// 52:     end
// 53:
// 54:     it "prevents executing from a denied read hierarchy" do
// 55:       denied_dir = mktmpdir
// 56:       executable = denied_dir/"secret"
// 57:       executable.write "#!/bin/sh\nexit 0\n"
// 58:       executable.chmod 0755
// 59:       sandbox.deny_read_path denied_dir
// 60:
// 61:       expect { sandbox.run "/bin/sh", "-c", 'exec "$1"', "brew-test", executable }
// 62:         .to raise_error(ErrorDuringExecution)
// 63:     end
// 64:
// 65:     it "allows standard devices and shared memory" do
// 66:       expect do
// 67:         sandbox.run RUBY_PATH, "-rio/console", "-e", <<~'RUBY'
// 68:           begin
// 69:             File.open("/dev/tty", "r+") { |tty| tty.winsize }
// 70:           rescue Errno::ENXIO, Errno::ENOENT, Errno::EACCES, Errno::EPERM
// 71:             nil
// 72:           end
// 73:
// 74:           if File.exist?("/dev/full")
// 75:             begin
// 76:               File.write("/dev/full", "test")
// 77:               raise "/dev/full accepted a write"
// 78:             rescue Errno::ENOSPC
// 79:               nil
// 80:             end
// 81:           end
// 82:
// 83:           if Dir.exist?("/dev/shm")
// 84:             path = "/dev/shm/homebrew-landlock-#{Process.pid}"
// 85:             File.write(path, "test")
// 86:             File.unlink(path)
// 87:           end
// 88:         RUBY
// 89:       end.not_to raise_error
// 90:     end
// 91:   end
// 92: end
