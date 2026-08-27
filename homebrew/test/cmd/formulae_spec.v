module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/formulae_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints all installed Formulae", :integration_test do` at line 5.
pub fn ruby_formulae_spec_l5_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew formulae", type: :system do
// 5:   it "prints all installed Formulae", :integration_test do
// 6:     expect { brew_sh "formulae", "HOMEBREW_NO_REQUIRE_TAP_TRUST" => "1" }
// 7:       .to be_a_success
// 8:       .and not_to_output.to_stderr
// 9:   end
// 10: end
