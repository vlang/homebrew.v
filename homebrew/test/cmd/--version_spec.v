module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/--version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints the Homebrew's version", :integration_test do` at line 5.
pub fn ruby_version_spec_l5_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew --version", type: :system do
// 5:   it "prints the Homebrew's version", :integration_test do
// 6:     expect { brew_sh "--version" }
// 7:       .to output(/^Homebrew #{Regexp.escape(HOMEBREW_VERSION)}\n/o).to_stdout
// 8:       .and not_to_output.to_stderr
// 9:       .and be_a_success
// 10:   end
// 11: end
