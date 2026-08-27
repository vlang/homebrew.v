module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "unknown predicates raise" do` at line 5.
pub fn ruby_subcommand_spec_l5_d1_unknown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unknown', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Test::Helper::Subcommand::Args do
// 5:   specify "unknown predicates raise" do
// 6:     expect do
// 7:       described_class.new(named: []).formuale?
// 8:     end.to raise_error(NoMethodError)
// 9:   end
// 10: end
