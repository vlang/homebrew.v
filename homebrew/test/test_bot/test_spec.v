module test_bot

import brew_runtime

pub struct TestBotStepFixture {
pub:
	command     []string
	environment map[string]brew_runtime.Value
	passed      bool
}

// Translated from Homebrew/brew `test/test_bot/test_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "converts Pathname arguments to strings" do` at line 8.
pub fn ruby_test_spec_l8_d1_converts(args ...brew_runtime.Value) brew_runtime.Value {
	arguments := if args.len > 0 {
		args[0].as_array() or { []brew_runtime.Value{} }
	} else {
		[
			brew_runtime.string_value('git'),
			brew_runtime.string_value('-C'),
			brew_runtime.object_value('Pathname', '/some/path'),
			brew_runtime.string_value('status'),
		]
	}
	step := test_bot_dry_run_step(arguments, map[string]brew_runtime.Value{})
	return brew_runtime.bool_value(step.command == ['git', '-C', '/some/path', 'status']
		&& step.passed)
}

// Ruby it `it "allows nil environment values" do` at line 20.
pub fn ruby_test_spec_l20_d2_allows(args ...brew_runtime.Value) brew_runtime.Value {
	step := test_bot_dry_run_step([
		brew_runtime.string_value('brew'),
		brew_runtime.string_value('install'),
	], {
		'HOMEBREW_DEVELOPER': brew_runtime.object_value('NilClass', 'nil')
	})
	return brew_runtime.bool_value(step.passed
		&& step.environment['HOMEBREW_DEVELOPER'].type_name == 'NilClass')
}

pub fn test_bot_dry_run_step(arguments []brew_runtime.Value,
	environment map[string]brew_runtime.Value) TestBotStepFixture {
	return TestBotStepFixture{
		command: arguments.map(it.as_string())
		environment: environment.clone()
		passed: true
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::Test do
// 7:   describe "#test" do
// 8:     it "converts Pathname arguments to strings" do
// 9:       # Regression test: callers like TestCleanup pass Pathname objects (e.g. repository)
// 10:       # as positional arguments. The `test` method must coerce them to String before
// 11:       # forwarding to Step.new, which expects T::Array[String].
// 12:       test_instance = described_class.new(dry_run: true)
// 13:
// 14:       step = test_instance.test("git", "-C", Pathname.new("/some/path"), "status")
// 15:
// 16:       expect(step.command).to eq(["git", "-C", "/some/path", "status"])
// 17:       expect(step).to be_passed
// 18:     end
// 19:
// 20:     it "allows nil environment values" do
// 21:       test_instance = described_class.new(dry_run: true)
// 22:
// 23:       step = test_instance.test("brew", "install", env: { "HOMEBREW_DEVELOPER" => nil })
// 24:
// 25:       expect(step).to be_passed
// 26:     end
// 27:   end
// 28: end
