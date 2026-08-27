module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/commands_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints a list of all available commands", :integration_test do` at line 10.
pub fn ruby_commands_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/commands"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::CommandsCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints a list of all available commands", :integration_test do
// 11:     expect { brew "commands" }
// 12:       .to output(/Built-in commands/).to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16: end
