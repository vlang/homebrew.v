module test

import brew_runtime

// Translated from Homebrew/brew `test/error_during_execution_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:error) { described_class.new(command, status:, output:) }` at line 5.
pub fn ruby_error_during_execution_spec_l5_d1_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:command) { ["false"] }` at line 7.
pub fn ruby_error_during_execution_spec_l7_d2_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:status) { instance_double(Process::Status, exitstatus:, termsig: nil) }` at line 8.
pub fn ruby_error_during_execution_spec_l8_d3_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('status', ...args)
}

// Ruby let `let(:exitstatus) { 1 }` at line 9.
pub fn ruby_error_during_execution_spec_l9_d4_exitstatus(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exitstatus', ...args)
}

// Ruby let `let(:output) { nil }` at line 10.
pub fn ruby_error_during_execution_spec_l10_d5_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output', ...args)
}

// Ruby it `it "fails when only given a command" do` at line 13.
pub fn ruby_error_during_execution_spec_l13_d6_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails when only given a status" do` at line 20.
pub fn ruby_error_during_execution_spec_l20_d7_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "does not raise an error when given both a command and a status" do` at line 25.
pub fn ruby_error_during_execution_spec_l25_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq "Failure while executing; `false` exited with 1." }` at line 34.
pub fn ruby_error_during_execution_spec_l34_d9_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby let `let(:output) do` at line 38.
pub fn ruby_error_during_execution_spec_l38_d10_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output', ...args)
}

// Ruby it `it(:to_s) do` at line 49.
pub fn ruby_error_during_execution_spec_l49_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby let `let(:command) { ["env", "PATH=/bin", "cat", "with spaces"] }` at line 59.
pub fn ruby_error_during_execution_spec_l59_d12_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby it `it(:to_s) do` at line 61.
pub fn ruby_error_during_execution_spec_l61_d13_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe ErrorDuringExecution do
// 5:   subject(:error) { described_class.new(command, status:, output:) }
// 6:
// 7:   let(:command) { ["false"] }
// 8:   let(:status) { instance_double(Process::Status, exitstatus:, termsig: nil) }
// 9:   let(:exitstatus) { 1 }
// 10:   let(:output) { nil }
// 11:
// 12:   describe "#initialize" do
// 13:     it "fails when only given a command" do
// 14:       expect do
// 15:         # Intentionally using T.unsafe to check runtime behaviour rather than static analysis
// 16:         T.unsafe(described_class).new(command)
// 17:       end.to raise_error(ArgumentError)
// 18:     end
// 19:
// 20:     it "fails when only given a status" do
// 21:       # Intentionally using T.unsafe to check runtime behaviour rather than static analysis
// 22:       expect { T.unsafe(described_class).new(status:) }.to raise_error(ArgumentError)
// 23:     end
// 24:
// 25:     it "does not raise an error when given both a command and a status" do
// 26:       expect do
// 27:         described_class.new(command, status:)
// 28:       end.not_to raise_error
// 29:     end
// 30:   end
// 31:
// 32:   describe "#to_s" do
// 33:     context "when only given a command and a status" do
// 34:       it(:to_s) { expect(error.to_s).to eq "Failure while executing; `false` exited with 1." }
// 35:     end
// 36:
// 37:     context "when additionally given the output" do
// 38:       let(:output) do
// 39:         [
// 40:           [:stdout, "This still worked.\n"],
// 41:           [:stderr, "Here something went wrong.\n"],
// 42:         ]
// 43:       end
// 44:
// 45:       before do
// 46:         allow($stdout).to receive(:tty?).and_return(true)
// 47:       end
// 48:
// 49:       it(:to_s) do
// 50:         expect(error.to_s).to eq <<~EOS
// 51:           Failure while executing; `false` exited with 1. Here's the output:
// 52:           This still worked.
// 53:           #{Formatter.error("Here something went wrong.\n")}
// 54:         EOS
// 55:       end
// 56:     end
// 57:
// 58:     context "when command arguments contain special characters" do
// 59:       let(:command) { ["env", "PATH=/bin", "cat", "with spaces"] }
// 60:
// 61:       it(:to_s) do
// 62:         expect(error.to_s)
// 63:           .to eq 'Failure while executing; `env PATH=/bin cat with\ spaces` exited with 1.'
// 64:       end
// 65:     end
// 66:   end
// 67: end
