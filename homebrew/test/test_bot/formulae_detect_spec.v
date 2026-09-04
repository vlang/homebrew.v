module test_bot

import ruby
import homebrew.test_bot as formulae_detect

// Translated from Homebrew/brew `test/test_bot/formulae_detect_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses GitHub-hosted, dependency-free formulae for default formula testing" do` at line 8.
pub fn ruby_formulae_detect_spec_l8_d1_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formulae_detect.default_test_formulae == [
		'libdeflate',
		'bats-core',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::FormulaeDetect do
// 7:   describe "::DEFAULT_TEST_FORMULAE" do
// 8:     it "uses GitHub-hosted, dependency-free formulae for default formula testing" do
// 9:       expect(Homebrew::TestBot::FormulaeDetect::DEFAULT_TEST_FORMULAE).to eq(%w[libdeflate bats-core])
// 10:     end
// 11:   end
// 12: end
