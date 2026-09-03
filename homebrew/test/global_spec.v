module test

import brew_runtime

// Translated from Homebrew/brew `test/global_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "does not require slow dependencies unnecessarily" do` at line 5.
pub fn ruby_global_spec_l5_d1_does(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	exit_code := args[0].as_int() or { return brew_runtime.bool_value(false) }
	output := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.bool_value(exit_code == 0 && output == '')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Homebrew, :integration_test do
// 5:   it "does not require slow dependencies unnecessarily" do
// 6:     expect do
// 7:       brew "verify-undefined",
// 8:            "HOMEBREW_SORBET_RECURSIVE" => nil,
// 9:            "HOMEBREW_SORBET_RUNTIME"   => nil
// 10:     end
// 11:       .to not_to_output.to_stdout
// 12:       .and not_to_output.to_stderr
// 13:       .and be_a_success
// 14:   end
// 15: end
