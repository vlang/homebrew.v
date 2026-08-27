module test

import brew_runtime

// Translated from Homebrew/brew `test/global_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "does not require slow dependencies unnecessarily" do` at line 5.
pub fn ruby_global_spec_l5_d1_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
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
