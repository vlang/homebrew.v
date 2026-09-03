module dev_cmd

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `test/dev-cmd/determine-test-runners_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct DetermineRunnerTestState {
pub mut:
	instances int
}

pub struct DetermineRunnerTestHelper {
pub:
	number int
}

pub fn determine_test_runners_spec_get_runners(file string, ephemeral_suffix string) ![]string {
	contents := os.read_file(file)!
	lines := contents.split_into_lines()
	if lines.len == 0 || !lines[0].starts_with('runners=') {
		return error('missing runners output')
	}
	runner_hash := brew_runtime.parse_json_value(lines[0].all_after('runners='))!.as_array()!
	mut runners := []string{cap: runner_hash.len}
	for item in runner_hash {
		runner := item.as_map()!['runner'] or { return error('runner output has no runner') }
		name := runner.as_string()
		runners << if name.ends_with(ephemeral_suffix) {
			name[..name.len - ephemeral_suffix.len]
		} else {
			name
		}
	}
	runners.sort()
	return runners
}

pub fn determine_test_runners_spec_arm_linux_runner() string {
	return 'ubuntu-24.04-arm'
}

pub fn determine_test_runners_spec_linux_runner() string {
	return 'ubuntu-latest'
}

pub fn determine_test_runners_spec_github_output(test_tmpdir string,
	mut state DetermineRunnerTestState) string {
	helper := determine_runner_test_helper_initialize(mut state)
	return os.join_path(test_tmpdir, 'github_output${helper.number}')
}

pub fn determine_test_runners_spec_ephemeral_suffix() string {
	return '-12345'
}

pub fn determine_test_runners_spec_runner_env(linux_runner string,
	ephemeral_suffix string) map[string]string {
	return {
		'HOMEBREW_LINUX_RUNNER':       linux_runner
		'HOMEBREW_MACOS_LONG_TIMEOUT': 'false'
		'GITHUB_RUN_ID':               ephemeral_suffix.split('-')[1]
	}
}

pub fn determine_test_runners_spec_all_runners(linux_runner string,
	arm_linux_runner string) ![]string {
	oldest := homebrew.macos_version_from_symbol('sonoma')!
	newest := homebrew.macos_version_from_symbol('tahoe')!
	newest_intel := homebrew.macos_version_from_symbol('sonoma')!
	mut runners := []string{}
	for _, value in homebrew.macos_symbol_versions() {
		macos_version := homebrew.new_macos_version(value)!
		if macos_version.compare(oldest) < 0 || macos_version.compare(newest) > 0 {
			continue
		}
		runners << '${value}-arm64'
		if macos_version.compare(newest_intel) <= 0 {
			runners << '${value}-x86_64'
		}
	}
	runners << linux_runner
	runners << arm_linux_runner
	return runners
}

pub fn determine_test_runners_spec_assigns(test_tmpdir string) !bool {
	mut state := DetermineRunnerTestState{}
	github_output := determine_test_runners_spec_github_output(test_tmpdir, mut state)
	defer {
		os.rm(github_output) or {}
	}
	ephemeral_suffix := determine_test_runners_spec_ephemeral_suffix()
	linux_runner := determine_test_runners_spec_linux_runner()
	arm_linux_runner := determine_test_runners_spec_arm_linux_runner()
	runner_env := determine_test_runners_spec_runner_env(linux_runner, ephemeral_suffix)
	result := run_determine_test_runners(DetermineTestRunnersOptions{
		named: ['testball']
		github_output: github_output
		github_run_id: runner_env['GITHUB_RUN_ID']
		linux_arm_runner: arm_linux_runner
		macos_long_timeout: runner_env['HOMEBREW_MACOS_LONG_TIMEOUT'] == 'true'
		formulae: {
			'testball': homebrew.TestRunnerFormulaDefinition{
				name: 'testball'
			}
		}
	})!
	if !result.github_output_wrote || !os.exists(github_output)
		|| os.read_file(github_output)!.len == 0 {
		return false
	}
	mut actual := determine_test_runners_spec_get_runners(github_output, ephemeral_suffix)!
	mut expected := determine_test_runners_spec_all_runners(linux_runner, arm_linux_runner)!
	actual.sort()
	expected.sort()
	return actual == expected
}

pub fn determine_runner_test_helper_instances(state DetermineRunnerTestState) int {
	return state.instances
}

pub fn determine_runner_test_helper_set_instances(mut state DetermineRunnerTestState,
	instances int) {
	state.instances = instances
}

pub fn determine_runner_test_helper_number(helper DetermineRunnerTestHelper) int {
	return helper.number
}

pub fn determine_runner_test_helper_initialize(mut state DetermineRunnerTestState) DetermineRunnerTestHelper {
	state.instances += 1
	return DetermineRunnerTestHelper{
		number: state.instances
	}
}

// Ruby method `get_runners(file)` at line 8.
pub fn ruby_determine_test_runners_spec_l8_d1_get_runners(file string,
	ephemeral_suffix string) ![]string {
	return determine_test_runners_spec_get_runners(file, ephemeral_suffix)
}

// Ruby let `let(:arm_linux_runner) { OS::LINUX_CI_ARM_RUNNER }` at line 20.
pub fn ruby_determine_test_runners_spec_l20_d2_arm_linux_runner() string {
	return determine_test_runners_spec_arm_linux_runner()
}

// Ruby let `let(:linux_runner) { "ubuntu-latest" }` at line 21.
pub fn ruby_determine_test_runners_spec_l21_d3_linux_runner() string {
	return determine_test_runners_spec_linux_runner()
}

// Ruby let `let(:github_output) { "#{TEST_TMPDIR}/github_output#{DetermineRunnerTestHelper.new.number}" }` at line 23.
pub fn ruby_determine_test_runners_spec_l23_d4_github_output(test_tmpdir string,
	mut state DetermineRunnerTestState) string {
	return determine_test_runners_spec_github_output(test_tmpdir, mut state)
}

// Ruby let `let(:ephemeral_suffix) { "-12345" }` at line 24.
pub fn ruby_determine_test_runners_spec_l24_d5_ephemeral_suffix() string {
	return determine_test_runners_spec_ephemeral_suffix()
}

// Ruby let `let(:runner_env) do` at line 25.
pub fn ruby_determine_test_runners_spec_l25_d6_runner_env(linux_runner string,
	ephemeral_suffix string) map[string]string {
	return determine_test_runners_spec_runner_env(linux_runner, ephemeral_suffix)
}

// Ruby let `let(:all_runners) do` at line 32.
pub fn ruby_determine_test_runners_spec_l32_d7_all_runners(linux_runner string,
	arm_linux_runner string) ![]string {
	return determine_test_runners_spec_all_runners(linux_runner, arm_linux_runner)
}

// Ruby it `it "assigns all runners for formulae without any requirements", :integration_test do` at line 53.
pub fn ruby_determine_test_runners_spec_l53_d8_assigns(test_tmpdir string) !bool {
	return determine_test_runners_spec_assigns(test_tmpdir)
}

// Ruby attr_accessor `attr_accessor :instances` at line 69.
pub fn ruby_determine_test_runners_spec_l69_d9_instances(state DetermineRunnerTestState) int {
	return determine_runner_test_helper_instances(state)
}

// Ruby attr_accessor `attr_accessor :instances` at line 69.
pub fn ruby_determine_test_runners_spec_l69_d10_instances(mut state DetermineRunnerTestState,
	instances int) {
	determine_runner_test_helper_set_instances(mut state, instances)
}

// Ruby attr_reader `attr_reader :number` at line 72.
pub fn ruby_determine_test_runners_spec_l72_d11_number(helper DetermineRunnerTestHelper) int {
	return determine_runner_test_helper_number(helper)
}

// Ruby method `initialize` at line 74.
pub fn ruby_determine_test_runners_spec_l74_d12_initialize(mut state DetermineRunnerTestState) DetermineRunnerTestHelper {
	return determine_runner_test_helper_initialize(mut state)
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
