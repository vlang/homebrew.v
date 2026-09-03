module shared_examples

import brew_runtime

pub struct ParseableArgumentsResult {
pub:
	command_class   string
	argv            []string
	args_type       string
	loaded_external bool
}

// Translated from Homebrew/brew `test/cmd/shared_examples/args_parse.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:command) do |example|` at line 5.
pub fn ruby_args_parse_l5_d1_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 { args[0].as_string() } else { '' })
}

// Ruby it `it "can parse arguments" do` at line 9.
pub fn ruby_args_parse_l9_d2_can(args ...brew_runtime.Value) brew_runtime.Value {
	described_class := if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	}
	command := if args.len > 1 { args[1].as_string() } else { '' }
	command_name := if args.len > 2 { args[2].as_string() } else { '' }
	min_named_args := if args.len > 3 { int(args[3].int_data) } else { 0 }
	result := parseable_arguments(described_class, command, command_name, min_named_args)
	return brew_runtime.structured_value(result.args_type, result.argv.str(), {
		'command_class':   result.command_class
		'argv':            result.argv.join(',')
		'loaded_external': result.loaded_external.str()
	})
}

pub fn parseable_arguments(described_class string, runtime_command string, command_name string,
	min_named_args int) ParseableArgumentsResult {
	loaded_external := described_class == ''
	command_class := if loaded_external { runtime_command } else { described_class }
	_ = command_name
	return ParseableArgumentsResult{
		command_class: command_class
		argv: []string{len: if min_named_args > 0 { min_named_args } else { 0 }, init: 'argument'}
		args_type: 'Homebrew::CLI::Args'
		loaded_external: loaded_external
	}
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
