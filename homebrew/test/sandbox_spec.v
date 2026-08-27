module test

import brew_runtime

// Translated from Homebrew/brew `test/sandbox_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:sandbox) { described_class.new }` at line 7.
pub fn ruby_sandbox_spec_l7_d1_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandbox', ...args)
}

// Ruby let `let(:dir) { mktmpdir }` at line 9.
pub fn ruby_sandbox_spec_l9_d2_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby let `let(:file) { dir/"foo" }` at line 10.
pub fn ruby_sandbox_spec_l10_d3_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby it `it "skips the sandbox for an unprivileged user in a custom prefix" do` at line 26.
pub fn ruby_sandbox_spec_l26_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "is false when not opted in via the environment" do` at line 30.
pub fn ruby_sandbox_spec_l30_d5_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is false when not running inside another sandbox" do` at line 35.
pub fn ruby_sandbox_spec_l35_d6_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "errors out in the default prefix" do` at line 40.
pub fn ruby_sandbox_spec_l40_d7_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors out for a user in a privileged group" do` at line 45.
pub fn ruby_sandbox_spec_l45_d8_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby specify `specify "#allow_write" do` at line 51.
pub fn ruby_sandbox_spec_l51_d9_allow_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#allow_write', ...args)
}

// Ruby it `it "writes to a path containing the seatbelt string delimiters \\ and \"" do` at line 58.
pub fn ruby_sandbox_spec_l58_d10_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "fails when writing to file not specified with` at line 69.
pub fn ruby_sandbox_spec_l69_d11_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "complains on failure" do` at line 77.
pub fn ruby_sandbox_spec_l77_d12_complains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('complains', ...args)
}

// Ruby it `it "does not raise getcwd EPERM when the parent CWD is sandbox-denied" do` at line 88.
pub fn ruby_sandbox_spec_l88_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "ignores bogus Python error" do` at line 97.
pub fn ruby_sandbox_spec_l97_d14_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "formula does a chmod to opt" do` at line 115.
pub fn ruby_sandbox_spec_l115_d15_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it "allows chmod on a path allowed to write" do` at line 119.
pub fn ruby_sandbox_spec_l119_d16_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "formula does a chmod 4000 to opt" do` at line 129.
pub fn ruby_sandbox_spec_l129_d17_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it "allows chmod 4000 on a path allowed to write" do` at line 133.
pub fn ruby_sandbox_spec_l133_d18_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sandbox"
// 5:
// 6: RSpec.describe Sandbox, :needs_macos do
// 7:   subject(:sandbox) { described_class.new }
// 8:
// 9:   let(:dir) { mktmpdir }
// 10:   let(:file) { dir/"foo" }
// 11:
// 12:   define_negated_matcher :not_matching, :matching
// 13:
// 14:   before do
// 15:     skip "Sandbox not implemented." unless described_class.available?
// 16:   end
// 17:
// 18:   describe ".avoid_nested_sandboxing?" do
// 19:     before do
// 20:       allow(Homebrew::EnvConfig).to receive(:avoid_nested_sandboxing?).and_return(true)
// 21:       allow(described_class).to receive(:nested_sandbox?).and_return(true)
// 22:       allow(Homebrew).to receive(:default_prefix?).and_return(false)
// 23:       allow(Process).to receive(:groups).and_return([])
// 24:     end
// 25:
// 26:     it "skips the sandbox for an unprivileged user in a custom prefix" do
// 27:       expect(described_class.avoid_nested_sandboxing?).to be(true)
// 28:     end
// 29:
// 30:     it "is false when not opted in via the environment" do
// 31:       allow(Homebrew::EnvConfig).to receive(:avoid_nested_sandboxing?).and_return(false)
// 32:       expect(described_class.avoid_nested_sandboxing?).to be(false)
// 33:     end
// 34:
// 35:     it "is false when not running inside another sandbox" do
// 36:       allow(described_class).to receive(:nested_sandbox?).and_return(false)
// 37:       expect(described_class.avoid_nested_sandboxing?).to be(false)
// 38:     end
// 39:
// 40:     it "errors out in the default prefix" do
// 41:       allow(Homebrew).to receive(:default_prefix?).and_return(true)
// 42:       expect { described_class.avoid_nested_sandboxing? }.to raise_error(SystemExit)
// 43:     end
// 44:
// 45:     it "errors out for a user in a privileged group" do
// 46:       allow(Process).to receive(:groups).and_return([Etc.getgrnam("staff")&.gid].compact)
// 47:       expect { described_class.avoid_nested_sandboxing? }.to raise_error(SystemExit)
// 48:     end
// 49:   end
// 50:
// 51:   specify "#allow_write" do
// 52:     sandbox.allow_write path: file
// 53:     sandbox.run "touch", file
// 54:
// 55:     expect(file).to exist
// 56:   end
// 57:
// 58:   it "writes to a path containing the seatbelt string delimiters \\ and \"" do
// 59:     delimiter_dir = dir/"I:\\ and \"quote\""
// 60:     delimiter_dir.mkpath
// 61:     target = delimiter_dir/"foo"
// 62:     sandbox.allow_write path: target
// 63:     sandbox.run "touch", target
// 64:
// 65:     expect(target).to exist
// 66:   end
// 67:
// 68:   describe "#run" do
// 69:     it "fails when writing to file not specified with ##allow_write" do
// 70:       expect do
// 71:         sandbox.run "touch", file
// 72:       end.to raise_error(ErrorDuringExecution)
// 73:
// 74:       expect(file).not_to exist
// 75:     end
// 76:
// 77:     it "complains on failure" do
// 78:       ENV["HOMEBREW_VERBOSE"] = "1"
// 79:
// 80:       allow(Utils).to receive(:popen_read).and_call_original
// 81:       allow(Utils).to receive(:popen_read).with("syslog", any_args).and_return("foo")
// 82:
// 83:       expect { sandbox.run "false" }
// 84:         .to raise_error(ErrorDuringExecution)
// 85:         .and output(/foo/).to_stdout
// 86:     end
// 87:
// 88:     it "does not raise getcwd EPERM when the parent CWD is sandbox-denied" do
// 89:       mktmpdir do |denied|
// 90:         sandbox.deny_read_path(denied)
// 91:         Dir.chdir(denied) do
// 92:           expect { sandbox.run "/bin/pwd" }.not_to raise_error
// 93:         end
// 94:       end
// 95:     end
// 96:
// 97:     it "ignores bogus Python error" do
// 98:       ENV["HOMEBREW_VERBOSE"] = "1"
// 99:
// 100:       with_bogus_error = <<~EOS
// 101:         foo
// 102:         Mar 17 02:55:06 sandboxd[342]: Python(49765) deny file-write-unlink /System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/distutils/errors.pyc
// 103:         bar
// 104:       EOS
// 105:       allow(Utils).to receive(:popen_read).and_call_original
// 106:       allow(Utils).to receive(:popen_read).with("syslog", any_args).and_return(with_bogus_error)
// 107:
// 108:       expect { sandbox.run "false" }
// 109:         .to raise_error(ErrorDuringExecution)
// 110:         .and output(a_string_matching(/foo/).and(matching(/bar/).and(not_matching(/Python/)))).to_stdout
// 111:     end
// 112:   end
// 113:
// 114:   describe "#disallow chmod on some directory" do
// 115:     it "formula does a chmod to opt" do
// 116:       expect { sandbox.run "chmod", "ug-w", HOMEBREW_PREFIX }.to raise_error(ErrorDuringExecution)
// 117:     end
// 118:
// 119:     it "allows chmod on a path allowed to write" do
// 120:       mktmpdir do |path|
// 121:         FileUtils.touch path/"foo"
// 122:         sandbox.allow_write_path(path)
// 123:         expect { sandbox.run "chmod", "ug-w", path/"foo" }.not_to raise_error
// 124:       end
// 125:     end
// 126:   end
// 127:
// 128:   describe "#disallow chmod SUID or SGID on some directory" do
// 129:     it "formula does a chmod 4000 to opt" do
// 130:       expect { sandbox.run "chmod", "4000", HOMEBREW_PREFIX }.to raise_error(ErrorDuringExecution)
// 131:     end
// 132:
// 133:     it "allows chmod 4000 on a path allowed to write" do
// 134:       mktmpdir do |path|
// 135:         FileUtils.touch path/"foo"
// 136:         sandbox.allow_write_path(path)
// 137:         expect { sandbox.run "chmod", "4000", path/"foo" }.not_to raise_error
// 138:       end
// 139:     end
// 140:   end
// 141: end
