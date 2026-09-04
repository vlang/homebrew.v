module test_bot

import ruby
import homebrew.test_bot as setup_core

// Translated from Homebrew/brew `test/test_bot/setup_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:setup) { described_class.new }` at line 7.
pub fn ruby_setup_spec_l7_d1_setup(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Homebrew::TestBot::Setup', 'Setup')
}

// Ruby it `it "is successful" do` at line 10.
pub fn ruby_setup_spec_l10_d2_is(args ...ruby.Value) ruby.Value {
	run := setup_core.setup_run(false)
	return ruby.bool_value(run.steps.len == 3 && run.steps.all(it.passed)
		&& run.steps.last().passed)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dev-cmd/test-bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::Setup do
// 7:   subject(:setup) { described_class.new }
// 8:
// 9:   describe "#run!" do
// 10:     it "is successful" do
// 11:       expect(setup).to receive(:test)
// 12:         .exactly(3).times
// 13:         .and_return(instance_double(Homebrew::TestBot::Step, passed?: true))
// 14:
// 15:       expect(setup.run!(args: instance_double(Homebrew::Cmd::TestBotCmd::Args)).passed?).to be(true)
// 16:     end
// 17:   end
// 18: end
