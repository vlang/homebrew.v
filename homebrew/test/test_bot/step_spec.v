module test_bot

import ruby

// Translated from Homebrew/brew `test/test_bot/step_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct StepSpecStep {
pub:
	command []string
	env     map[string]ruby.Value
	verbose bool
}

pub struct StepSpecSystemCommandResult {
pub:
	success       bool
	merged_output string
}

pub struct StepSpecSystemCommandInvocation {
pub:
	executable   string
	args         []string
	env          map[string]ruby.Value
	print_stderr bool
	print_stdout bool
}

pub struct StepSpecRun {
pub:
	invocation StepSpecSystemCommandInvocation
	result     StepSpecSystemCommandResult
}

pub fn run_step_spec_command(step StepSpecStep,
	result StepSpecSystemCommandResult) !StepSpecRun {
	if step.command.len == 0 {
		return error('step command must contain an executable')
	}
	return StepSpecRun{
		invocation: StepSpecSystemCommandInvocation{
			executable: step.command[0]
			args: step.command[1..].clone()
			env: step.env.clone()
			print_stderr: step.verbose
			print_stdout: step.verbose
		}
		result: result
	}
}

// Ruby subject `subject(:step) { described_class.new(command, env:, verbose:) }` at line 7.
pub fn ruby_step_spec_l7_d1_step() StepSpecStep {
	return StepSpecStep{
		command: ruby_step_spec_l9_d2_command()
		env: ruby_step_spec_l10_d3_env()
		verbose: ruby_step_spec_l11_d4_verbose()
	}
}

// Ruby let `let(:command) { ["brew", "config"] }` at line 9.
pub fn ruby_step_spec_l9_d2_command() []string {
	return ['brew', 'config']
}

// Ruby let `let(:env) { {} }` at line 10.
pub fn ruby_step_spec_l10_d3_env() map[string]ruby.Value {
	return map[string]ruby.Value{}
}

// Ruby let `let(:verbose) { false }` at line 11.
pub fn ruby_step_spec_l11_d4_verbose() bool {
	return false
}

// Ruby it `it "runs the command" do` at line 14.
pub fn ruby_step_spec_l14_d5_runs() !bool {
	run := run_step_spec_command(ruby_step_spec_l7_d1_step(), StepSpecSystemCommandResult{
		success: true
	})!
	return run.invocation.executable == 'brew' && run.invocation.args == ['config']
		&& run.invocation.env.len == 0 && !run.invocation.print_stderr
		&& !run.invocation.print_stdout && run.result.success && run.result.merged_output == ''
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::Step do
// 7:   subject(:step) { described_class.new(command, env:, verbose:) }
// 8:
// 9:   let(:command) { ["brew", "config"] }
// 10:   let(:env) { {} }
// 11:   let(:verbose) { false }
// 12:
// 13:   describe "#run" do
// 14:     it "runs the command" do
// 15:       expect(step).to receive(:system_command)
// 16:         .with("brew", args: ["config"], env:, print_stderr: verbose, print_stdout: verbose)
// 17:         .and_return(instance_double(SystemCommand::Result, success?: true, merged_output: ""))
// 18:       step.run
// 19:     end
// 20:   end
// 21: end
