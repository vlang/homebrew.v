module cmd

import homebrew.developer
import homebrew.developer.subcommand

// Translated from Homebrew/brew `test/cmd/developer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses state as the default subcommand" do` at line 10.
pub fn ruby_developer_spec_l10_d1_uses() bool {
	mut state := subcommand.DeveloperState{}
	output := developer.ruby_subcommand_l16_d1_dispatch([], mut state) or { return false }
	return output.starts_with('Developer mode is disabled.')
}

// Ruby it `it "rejects extra arguments for state" do` at line 14.
pub fn ruby_developer_spec_l14_d2_rejects() bool {
	mut state := subcommand.DeveloperState{}
	developer.ruby_subcommand_l16_d1_dispatch(['state', 'foo'], mut state) or {
		return err.msg().contains('at most one named argument')
	}
	return false
}

// Ruby it `it "prints that Developer mode is disabled by default", :integration_test do` at line 19.
pub fn ruby_developer_spec_l19_d3_prints() bool {
	mut state := subcommand.DeveloperState{}
	output := developer.ruby_subcommand_l16_d1_dispatch([], mut state) or { return false }
	return output.contains('Developer mode is disabled')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/developer"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Developer do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "uses state as the default subcommand" do
// 11:     expect(described_class.new([]).args.subcommand).to eq("state")
// 12:   end
// 13:
// 14:   it "rejects extra arguments for state" do
// 15:     expect { described_class.new(%w[state foo]) }
// 16:       .to raise_error(Homebrew::CLI::MaxNamedArgumentsError)
// 17:   end
// 18:
// 19:   it "prints that Developer mode is disabled by default", :integration_test do
// 20:     expect { brew "developer" }
// 21:       .to output(/Developer mode is disabled/).to_stdout
// 22:       .and not_to_output.to_stderr
// 23:       .and be_a_success
// 24:   end
// 25: end
