module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/determine-test-runners_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `get_runners(file)` at line 8.
pub fn ruby_determine_test_runners_spec_l8_d1_get_runners(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_runners', ...args)
}

// Ruby let `let(:arm_linux_runner) { OS::LINUX_CI_ARM_RUNNER }` at line 20.
pub fn ruby_determine_test_runners_spec_l20_d2_arm_linux_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm_linux_runner', ...args)
}

// Ruby let `let(:linux_runner) { "ubuntu-latest" }` at line 21.
pub fn ruby_determine_test_runners_spec_l21_d3_linux_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_runner', ...args)
}

// Ruby let `let(:github_output) { "#{TEST_TMPDIR}/github_output#{DetermineRunnerTestHelper.new.number}" }` at line 23.
pub fn ruby_determine_test_runners_spec_l23_d4_github_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_output', ...args)
}

// Ruby let `let(:ephemeral_suffix) { "-12345" }` at line 24.
pub fn ruby_determine_test_runners_spec_l24_d5_ephemeral_suffix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ephemeral_suffix', ...args)
}

// Ruby let `let(:runner_env) do` at line 25.
pub fn ruby_determine_test_runners_spec_l25_d6_runner_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runner_env', ...args)
}

// Ruby let `let(:all_runners) do` at line 32.
pub fn ruby_determine_test_runners_spec_l32_d7_all_runners(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_runners', ...args)
}

// Ruby it `it "assigns all runners for formulae without any requirements", :integration_test do` at line 53.
pub fn ruby_determine_test_runners_spec_l53_d8_assigns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assigns', ...args)
}

// Ruby attr_accessor `attr_accessor :instances` at line 69.
pub fn ruby_determine_test_runners_spec_l69_d9_instances(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('instances', ...args)
}

// Ruby attr_accessor `attr_accessor :instances` at line 69.
pub fn ruby_determine_test_runners_spec_l69_d10_instances(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('instances=', ...args)
}

// Ruby attr_reader `attr_reader :number` at line 72.
pub fn ruby_determine_test_runners_spec_l72_d11_number(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('number', ...args)
}

// Ruby method `initialize` at line 74.
pub fn ruby_determine_test_runners_spec_l74_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "dev-cmd/determine-test-runners"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::DetermineTestRunners do
// 8:   def get_runners(file)
// 9:     runner_line = File.open(file, &:first)
// 10:     json_text = runner_line[/runners=(.*)/, 1]
// 11:     runner_hash = JSON.parse(json_text)
// 12:     runner_hash.map { |item| item["runner"].delete_suffix(ephemeral_suffix) }
// 13:                .sort
// 14:   end
// 15:
// 16:   after do
// 17:     FileUtils.rm_f github_output
// 18:   end
// 19:
// 20:   let(:arm_linux_runner) { OS::LINUX_CI_ARM_RUNNER }
// 21:   let(:linux_runner) { "ubuntu-latest" }
// 22:   # We need to make sure we write to a different path for each example.
// 23:   let(:github_output) { "#{TEST_TMPDIR}/github_output#{DetermineRunnerTestHelper.new.number}" }
// 24:   let(:ephemeral_suffix) { "-12345" }
// 25:   let(:runner_env) do
// 26:     {
// 27:       "HOMEBREW_LINUX_RUNNER"       => linux_runner,
// 28:       "HOMEBREW_MACOS_LONG_TIMEOUT" => "false",
// 29:       "GITHUB_RUN_ID"               => ephemeral_suffix.split("-").second,
// 30:     }.freeze
// 31:   end
// 32:   let(:all_runners) do
// 33:     out = []
// 34:     MacOSVersion::SYMBOLS.each_value do |v|
// 35:       macos_version = MacOSVersion.new(v)
// 36:       next if macos_version < GitHubRunnerMatrix::OLDEST_HOMEBREW_CORE_MACOS_RUNNER
// 37:       next if macos_version > GitHubRunnerMatrix::NEWEST_HOMEBREW_CORE_MACOS_RUNNER
// 38:
// 39:       out << "#{v}-arm64"
// 40:       next if macos_version > GitHubRunnerMatrix::NEWEST_HOMEBREW_CORE_INTEL_MACOS_RUNNER
// 41:
// 42:       out << "#{v}-x86_64"
// 43:     end
// 44:
// 45:     out << linux_runner
// 46:     out << arm_linux_runner
// 47:
// 48:     out
// 49:   end
// 50:
// 51:   it_behaves_like "parseable arguments"
// 52:
// 53:   it "assigns all runners for formulae without any requirements", :integration_test do
// 54:     setup_test_formula "testball"
// 55:
// 56:     expect { brew "determine-test-runners", "testball", runner_env.merge({ "GITHUB_OUTPUT" => github_output }) }
// 57:       .to not_to_output.to_stderr
// 58:       .and be_a_success
// 59:
// 60:     expect(File.read(github_output)).not_to be_empty
// 61:     expect(get_runners(github_output).sort).to eq(all_runners.sort)
// 62:   end
// 63: end
// 64:
// 65: class DetermineRunnerTestHelper
// 66:   @instances = 0
// 67:
// 68:   class << self
// 69:     attr_accessor :instances
// 70:   end
// 71:
// 72:   attr_reader :number
// 73:
// 74:   def initialize
// 75:     self.class.instances += 1
// 76:     @number = self.class.instances
// 77:   end
// 78: end
