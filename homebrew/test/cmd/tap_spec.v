module cmd

import homebrew.cmd as tap_core

// Translated from Homebrew/brew `test/cmd/tap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "taps a given Tap", :integration_test do` at line 10.
pub fn ruby_tap_spec_l10_d1_taps() bool {
	result := tap_core.run_tap_command(tap_core.TapCommandRequest{
		named: ['homebrew/bar', '/tmp/homebrew-bar/.git']
	}) or { return false }
	return (result.installed or { '' }) == 'homebrew/bar' && (result.clone_target or { '' }) == '/tmp/homebrew-bar/.git' && result.output.contains('Tapped')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/tap"
// 6:
// 7: RSpec.describe Homebrew::Cmd::TapCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "taps a given Tap", :integration_test do
// 11:     path = setup_test_tap
// 12:
// 13:     expect { brew "tap", "homebrew/bar", path/".git" }
// 14:       .to output(/Tapped/).to_stderr
// 15:       .and be_a_success
// 16:   end
// 17: end
