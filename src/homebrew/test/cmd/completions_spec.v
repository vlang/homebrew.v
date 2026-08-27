module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/completions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses state as the default subcommand" do` at line 10.
pub fn ruby_completions_spec_l10_d1_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "rejects extra arguments for state" do` at line 14.
pub fn ruby_completions_spec_l14_d2_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "runs the status subcommand correctly", :integration_test do` at line 19.
pub fn ruby_completions_spec_l19_d3_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/completions"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::CompletionsCmd do
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
// 19:   it "runs the status subcommand correctly", :integration_test do
// 20:     HOMEBREW_REPOSITORY.cd do
// 21:       system "git", "init"
// 22:     end
// 23:
// 24:     brew "completions", "link"
// 25:     expect { brew "completions" }
// 26:       .to output(/Completions are linked/).to_stdout
// 27:       .and not_to_output.to_stderr
// 28:       .and be_a_success
// 29:   end
// 30: end
