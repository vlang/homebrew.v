module utils

import brew_runtime
import homebrew.utils as production_utils

// Translated from Homebrew/brew `test/utils/fork_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "preserves build error details" do` at line 8.
pub fn ruby_fork_spec_l8_d1_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	child_error := &production_utils.ForkChildError{
		kind: .build_error
		message: 'Failed executing: make install'
		backtrace: ['build.rb:1']
		command: 'make'
		arguments: ['install']
		environment: {
			'PATH': '/bin'
		}
	}
	error_hash := production_utils.child_error_hash(child_error)
	return brew_runtime.bool_value(error_hash['cmd'].as_string() == 'make'
		&& error_hash['args'].as_string_array() or { []string{} } == ['install']
		&& error_hash['env'].map_data['PATH'].as_string() == '/bin')
}

// Ruby it `it "raises a RuntimeError on an error that isn't ErrorDuringExecution" do` at line 18.
pub fn ruby_fork_spec_l18_d2_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	request := &production_utils.ForkSafeRequest{
		directory: '/tmp/fork-spec-runtime'
		has_child_error: true
		child_error: production_utils.ForkChildError{
			kind: .runtime_error
			class_name: 'RuntimeError'
			message: 'this is an exception in the child'
			backtrace: ['fork_spec.rb:21']
		}
		has_exitstatus: true
		exitstatus: 1
	}
	outcome := production_utils.safe_fork_outcome(request)
	return brew_runtime.bool_value(outcome.has_error && outcome.raised.kind == .runtime_error
		&& outcome.raised.message.contains('this is an exception in the child'))
}

// Ruby it `it "raises an ErrorDuringExecution on one in the child" do` at line 26.
pub fn ruby_fork_spec_l26_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	request := &production_utils.ForkSafeRequest{
		directory: '/tmp/fork-spec-execution'
		has_child_error: true
		child_error: production_utils.ForkChildError{
			kind: .error_during_execution
			message: 'Failure while executing; `/usr/bin/false` exited with 1.'
			backtrace: ['fork_spec.rb:29']
			command_arguments: ['/usr/bin/false']
			status_is_process: true
			status: production_utils.ForkProcessStatus{
				has_exitstatus: true
				exitstatus: 1
			}
		}
		has_exitstatus: true
		exitstatus: 1
	}
	outcome := production_utils.safe_fork_outcome(request)
	return brew_runtime.bool_value(outcome.has_error
		&& outcome.raised.kind == .error_during_execution
		&& outcome.raised.command_arguments == ['/usr/bin/false'])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/fork"
// 5:
// 6: RSpec.describe Utils do
// 7:   describe "::child_error_hash" do
// 8:     it "preserves build error details" do
// 9:       error = BuildError.new(nil, "make", ["install"], { "PATH" => "/bin" })
// 10:
// 11:       expect(described_class.child_error_hash(error)).to include(
// 12:         "cmd" => "make", "args" => ["install"], "env" => { "PATH" => "/bin" },
// 13:       )
// 14:     end
// 15:   end
// 16:
// 17:   describe "#safe_fork" do
// 18:     it "raises a RuntimeError on an error that isn't ErrorDuringExecution" do
// 19:       expect do
// 20:         described_class.safe_fork do
// 21:           raise "this is an exception in the child"
// 22:         end
// 23:       end.to raise_error(RuntimeError)
// 24:     end
// 25:
// 26:     it "raises an ErrorDuringExecution on one in the child" do
// 27:       expect do
// 28:         described_class.safe_fork do
// 29:           safe_system "/usr/bin/false"
// 30:         end
// 31:       end.to raise_error(ErrorDuringExecution)
// 32:     end
// 33:   end
// 34: end
