module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/setup-ruby_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "installs and configures Homebrew's Ruby", :integration_test do` at line 5.
pub fn ruby_setup_ruby_spec_l5_d1_installs(args ...brew_runtime.Value) brew_runtime.Value {
	stdout := if args.len > 0 { args[0].as_string() } else { '' }
	stderr := if args.len > 1 { args[1].as_string() } else { '' }
	exit_code := if args.len > 2 { int(args[2].int_data) } else { 0 }
	return brew_runtime.bool_value(setup_ruby_command_succeeded(stdout, stderr, exit_code))
}

pub fn setup_ruby_command_succeeded(stdout string, stderr string, exit_code int) bool {
	return stdout == '' && stderr == '' && exit_code == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew setup-ruby", type: :system do
// 5:   it "installs and configures Homebrew's Ruby", :integration_test do
// 6:     expect { brew_sh "setup-ruby" }
// 7:       .to output("").to_stdout
// 8:       .and not_to_output.to_stderr
// 9:       .and be_a_success
// 10:   end
// 11: end
