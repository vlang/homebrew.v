module utils

import brew_runtime
import homebrew.utils as popen_utils
import os
import time

// Translated from Homebrew/brew `test/utils/popen_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn popen_spec_temp_path(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-popen-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn popen_spec_foo_path(args []brew_runtime.Value) string {
	return if args.len > 0 { args[0].as_string() } else { popen_spec_temp_path('foo') }
}

fn popen_spec_cat_order(arguments []string, input string, expected string) bool {
	root := popen_spec_temp_path('cat')
	os.mkdir_all(root) or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	foo := os.join_path(root, 'foo')
	os.write_file(foo, 'Foo\n') or { return false }
	mut argv := ['cat']
	for argument in arguments {
		argv << if argument == 'foo' { foo } else { argument }
	}
	result := popen_utils.popen_write(argv, input, popen_utils.PopenOptions{}) or {
		return false
	}
	return result.success() && result.stdout == expected
}

// Ruby it `it "reads the standard output of a given command" do` at line 8.
pub fn ruby_popen_spec_l8_d1_reads(args ...brew_runtime.Value) brew_runtime.Value {
	result := popen_utils.popen_read(['sh', '-c', 'echo success'], popen_utils.PopenOptions{}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.success() && result.stdout.trim_space() == 'success')
}

// Ruby it `it "can be given a block to manually read from the pipe" do` at line 13.
pub fn ruby_popen_spec_l13_d2_can(args ...brew_runtime.Value) brew_runtime.Value {
	result := popen_utils.popen_read(['sh', '-c', 'echo success'], popen_utils.PopenOptions{}) or { return brew_runtime.bool_value(false) }
	manually_read := result.stdout.trim_space()
	return brew_runtime.bool_value(result.success() && manually_read == 'success')
}

// Ruby it `it "fails when the command does not exist" do` at line 22.
pub fn ruby_popen_spec_l22_d3_fails(args ...brew_runtime.Value) brew_runtime.Value {
	result := popen_utils.popen_read(['./nonexistent'], popen_utils.PopenOptions{
		stderr: .stdout
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.exit_code == 127 && result.stdout == 'brew: command not found: ./nonexistent\n')
}

// Ruby let `let(:foo) { mktmpdir/"foo" }` at line 30.
pub fn ruby_popen_spec_l30_d4_foo(args ...brew_runtime.Value) brew_runtime.Value {
	path := popen_spec_foo_path(args)
	os.mkdir_all(os.dir(path)) or { return brew_runtime.object_value('IOError', err.msg()) }
	os.write_file(path, 'Foo\n') or { return brew_runtime.object_value('IOError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby it `it "supports writing to a command's standard input" do` at line 34.
pub fn ruby_popen_spec_l34_d5_supports(args ...brew_runtime.Value) brew_runtime.Value {
	result := popen_utils.popen_write(['grep', '-q', 'success'], 'success\n', popen_utils.PopenOptions{}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.success())
}

// Ruby it `it "returns the command's standard output before writing" do` at line 41.
pub fn ruby_popen_spec_l41_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(popen_spec_cat_order(['foo', '-'], 'Bar\n', 'Foo\nBar\n'))
}

// Ruby it `it "returns the command's standard output after writing" do` at line 52.
pub fn ruby_popen_spec_l52_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(popen_spec_cat_order(['-', 'foo'], 'Bar\n', 'Bar\nFoo\n'))
}

// Ruby it `it "supports interleaved writing between two reads" do` at line 63.
pub fn ruby_popen_spec_l63_d8_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(popen_spec_cat_order(['foo', '-', 'foo'], 'Bar\n', 'Foo\nBar\nFoo\n'))
}

// Ruby it `it "does not raise an error if the command succeeds" do` at line 77.
pub fn ruby_popen_spec_l77_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	output := popen_utils.safe_popen_read(['sh', '-c', 'true'], popen_utils.PopenOptions{}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(output == '')
}

// Ruby it `it "raises an error if the command fails" do` at line 82.
pub fn ruby_popen_spec_l82_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	if _ := popen_utils.safe_popen_read(['sh', '-c', 'false'], popen_utils.PopenOptions{}) {
		return brew_runtime.bool_value(false)
	} else {
		return brew_runtime.bool_value(err.code() != 0 && err.msg().contains('Failure while executing'))
	}
}

// Ruby it `it "does not raise an error if the command succeeds" do` at line 89.
pub fn ruby_popen_spec_l89_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	if _ := popen_utils.safe_popen_write(['grep', 'success'], 'success\n', popen_utils.PopenOptions{}) {
		return brew_runtime.bool_value(true)
	} else {
		return brew_runtime.bool_value(false)
	}
}

// Ruby it `it "raises an error if the command fails" do` at line 96.
pub fn ruby_popen_spec_l96_d12_raises(args ...brew_runtime.Value) brew_runtime.Value {
	if _ := popen_utils.safe_popen_write(['grep', 'success'], 'failure\n', popen_utils.PopenOptions{}) {
		return brew_runtime.bool_value(false)
	} else {
		return brew_runtime.bool_value(err.code() != 0 && err.msg().contains('Failure while executing'))
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/popen"
// 5:
// 6: RSpec.describe Utils do
// 7:   describe "::popen_read" do
// 8:     it "reads the standard output of a given command" do
// 9:       expect(described_class.popen_read("sh", "-c", "echo success").chomp).to eq("success")
// 10:       expect($CHILD_STATUS).to be_a_success
// 11:     end
// 12:
// 13:     it "can be given a block to manually read from the pipe" do
// 14:       expect(
// 15:         described_class.popen_read("sh", "-c", "echo success") do |pipe|
// 16:           pipe.read.chomp
// 17:         end,
// 18:       ).to eq("success")
// 19:       expect($CHILD_STATUS).to be_a_success
// 20:     end
// 21:
// 22:     it "fails when the command does not exist" do
// 23:       expect(described_class.popen_read("./nonexistent", err: :out))
// 24:         .to eq("brew: command not found: ./nonexistent\n")
// 25:       expect($CHILD_STATUS).to be_a_failure
// 26:     end
// 27:   end
// 28:
// 29:   describe "::popen_write" do
// 30:     let(:foo) { mktmpdir/"foo" }
// 31:
// 32:     before { foo.write "Foo\n" }
// 33:
// 34:     it "supports writing to a command's standard input" do
// 35:       described_class.popen_write("grep", "-q", "success") do |pipe|
// 36:         pipe.write "success\n"
// 37:       end
// 38:       expect($CHILD_STATUS).to be_a_success
// 39:     end
// 40:
// 41:     it "returns the command's standard output before writing" do
// 42:       child_stdout = described_class.popen_write("cat", foo, "-") do |pipe|
// 43:         pipe.write "Bar\n"
// 44:       end
// 45:       expect($CHILD_STATUS).to be_a_success
// 46:       expect(child_stdout).to eq <<~EOS
// 47:         Foo
// 48:         Bar
// 49:       EOS
// 50:     end
// 51:
// 52:     it "returns the command's standard output after writing" do
// 53:       child_stdout = described_class.popen_write("cat", "-", foo) do |pipe|
// 54:         pipe.write "Bar\n"
// 55:       end
// 56:       expect($CHILD_STATUS).to be_a_success
// 57:       expect(child_stdout).to eq <<~EOS
// 58:         Bar
// 59:         Foo
// 60:       EOS
// 61:     end
// 62:
// 63:     it "supports interleaved writing between two reads" do
// 64:       child_stdout = described_class.popen_write("cat", foo, "-", foo) do |pipe|
// 65:         pipe.write "Bar\n"
// 66:       end
// 67:       expect($CHILD_STATUS).to be_a_success
// 68:       expect(child_stdout).to eq <<~EOS
// 69:         Foo
// 70:         Bar
// 71:         Foo
// 72:       EOS
// 73:     end
// 74:   end
// 75:
// 76:   describe "::safe_popen_read" do
// 77:     it "does not raise an error if the command succeeds" do
// 78:       expect(described_class.safe_popen_read("sh", "-c", "true")).to eq("")
// 79:       expect($CHILD_STATUS).to be_a_success
// 80:     end
// 81:
// 82:     it "raises an error if the command fails" do
// 83:       expect { described_class.safe_popen_read("sh", "-c", "false") }.to raise_error(ErrorDuringExecution)
// 84:       expect($CHILD_STATUS).to be_a_failure
// 85:     end
// 86:   end
// 87:
// 88:   describe "::safe_popen_write" do
// 89:     it "does not raise an error if the command succeeds" do
// 90:       expect do
// 91:         described_class.safe_popen_write("grep", "success") { |pipe| pipe.write "success\n" }
// 92:       end.not_to raise_error
// 93:       expect($CHILD_STATUS).to be_a_success
// 94:     end
// 95:
// 96:     it "raises an error if the command fails" do
// 97:       expect do
// 98:         described_class.safe_popen_write("grep", "success") { |pipe| pipe.write "failure\n" }
// 99:       end.to raise_error(ErrorDuringExecution)
// 100:       expect($CHILD_STATUS).to be_a_failure
// 101:     end
// 102:   end
// 103: end
