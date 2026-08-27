module shared_examples

import brew_runtime

// Translated from Homebrew/brew `test/cmd/shared_examples/args_parse.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:command) do |example|` at line 5.
pub fn ruby_args_parse_l5_d1_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby it `it "can parse arguments" do` at line 9.
pub fn ruby_args_parse_l9_d2_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.shared_examples "parseable arguments" do |command_name: nil|
// 5:   let(:command) do |example|
// 6:     example.metadata.dig(:example_group, :parent_example_group, :description)
// 7:   end
// 8:
// 9:   it "can parse arguments" do
// 10:     if described_class
// 11:       klass = described_class
// 12:     else
// 13:       # for tests of remote taps, we need to load the command class
// 14:       require(Commands.external_ruby_v2_cmd_path(command_name))
// 15:       # The command class name is only known at runtime.
// 16:       # rubocop:disable Sorbet/ConstantsFromStrings
// 17:       klass = Object.const_get(command)
// 18:       # rubocop:enable Sorbet/ConstantsFromStrings
// 19:     end
// 20:     argv = klass.parser.min_named_args&.times&.map { "argument" } || []
// 21:     cmd = klass.new(argv)
// 22:     expect(cmd.args).to be_a Homebrew::CLI::Args
// 23:   end
// 24: end
