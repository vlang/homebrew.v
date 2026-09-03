module cmd

import homebrew.analytics
import homebrew.utils

// Translated from Homebrew/brew `test/cmd/analytics_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses state as the default subcommand" do` at line 10.
pub fn ruby_analytics_spec_l10_d1_uses() bool {
	mut state := utils.AnalyticsState{}
	output := analytics.ruby_subcommand_l16_dispatch([], mut state) or { return false }
	return output.starts_with('InfluxDB analytics are enabled.')
}

// Ruby it `it "rejects extra arguments for state" do` at line 14.
pub fn ruby_analytics_spec_l14_d2_rejects() bool {
	mut state := utils.AnalyticsState{}
	analytics.ruby_subcommand_l16_dispatch(['state', 'foo'], mut state) or {
		return err.msg().contains('at most one named argument')
	}
	return false
}

// Ruby it `it "when HOMEBREW_NO_ANALYTICS is unset is disabled after running `brew analytics off`", :integration_test do` at line 19.
pub fn ruby_analytics_spec_l19_d3_when() bool {
	mut state := utils.AnalyticsState{}
	analytics.ruby_subcommand_l16_dispatch(['off'], mut state) or { return false }
	output := analytics.ruby_subcommand_l16_dispatch([], mut state) or { return false }
	return state.disabled() && output.to_lower().contains('analytics are disabled')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/analytics"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Analytics do
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
// 19:   it "when HOMEBREW_NO_ANALYTICS is unset is disabled after running `brew analytics off`", :integration_test do
// 20:     HOMEBREW_REPOSITORY.cd do
// 21:       system "git", "init"
// 22:     end
// 23:
// 24:     brew "analytics", "off"
// 25:     expect { brew "analytics", "HOMEBREW_NO_ANALYTICS" => nil }
// 26:       .to output(/analytics are disabled/i).to_stdout
// 27:       .and not_to_output.to_stderr
// 28:       .and be_a_success
// 29:   end
// 30: end
