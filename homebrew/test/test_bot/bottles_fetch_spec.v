module test_bot

import ruby
import homebrew.test_bot as bottles_fetch_core
import homebrew.utils

// Translated from Homebrew/brew `test/test_bot/bottles_fetch_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts Utils::Bottles::Tag objects from the bottle collector" do` at line 9.
pub fn ruby_bottles_fetch_spec_l9_d1_accepts(args ...ruby.Value) ruby.Value {
	tag := utils.new_bottles_tag('sequoia', 'arm64')
	formula_name := if args.len > 0 { args[0].as_string() } else { 'some-formula' }
	plan := bottles_fetch_core.bottles_fetch_for_tag(tag, [formula_name])
	return ruby.bool_value(plan.passed && plan.cleanup && plan.operations.len == 3
		&& plan.operations[0].kind == .test_header && plan.operations[1].kind == .cleanup
		&& plan.operations[2].kind == .fetch && plan.command.contains('--bottle-tag=${tag}')
		&& plan.command.last() == formula_name)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5: require "dev-cmd/test-bot"
// 6:
// 7: RSpec.describe Homebrew::TestBot::BottlesFetch do
// 8:   describe "#run!" do
// 9:     it "accepts Utils::Bottles::Tag objects from the bottle collector" do
// 10:       # Regression test: bottle_specification.collector.tags returns Utils::Bottles::Tag objects,
// 11:       # not Symbols. The fetch_bottles! signature must accept Tag, not Symbol.
// 12:       fetch = described_class.new(tap: nil, git: nil, dry_run: true, fail_fast: false, verbose: false)
// 13:       fetch.testing_formulae = ["some-formula"]
// 14:       tag = Utils::Bottles::Tag.new(system: :sequoia, arch: :arm64)
// 15:       allow(fetch).to receive(:formulae_by_tag).and_return({ tag => Set["some-formula"] })
// 16:       allow(fetch).to receive(:cleanup_during!)
// 17:
// 18:       fetch.run!(args: instance_double(Homebrew::Cmd::TestBotCmd::Args))
// 19:
// 20:       last_step = T.must(fetch.steps.last)
// 21:       expect(last_step).to be_passed
// 22:       expect(last_step.command).to include("--bottle-tag=#{tag}")
// 23:     end
// 24:   end
// 25: end
