module test

import brew_runtime
import homebrew
import homebrew.cli as brew_cli

// Translated from Homebrew/brew `test/abstract_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn abstract_subcommand_spec_parser(mut parser brew_cli.Parser) ! {
	parser.set_usage_banner('`brew test`:\nRun the test subcommand.')!
	parser.add_switch(['--foo'], brew_cli.OptionConfig{})
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	})!
}

fn abstract_subcommand_spec_named_none(mut parser brew_cli.Parser) ! {
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	})!
}

fn abstract_subcommand_spec_class() homebrew.AbstractSubcommandClass {
	mut subcommand := homebrew.new_abstract_subcommand_class('TestSubcommand')
	homebrew.ruby_abstract_subcommand_l74_d5_subcommand_args(mut subcommand, homebrew.AbstractSubcommandArgsConfig{
		aliases: ['ts']
		default: true
	}, abstract_subcommand_spec_parser)
	return subcommand
}

// Ruby method `run; end` at line 20.
pub fn ruby_abstract_subcommand_spec_l20_d1_run() {}

// Ruby it `it "defines parser metadata from subcommand_args" do` at line 26.
pub fn ruby_abstract_subcommand_spec_l26_d2_defines() !bool {
	mut parser := brew_cli.new_parser('SubcommandTestCmd')
	homebrew.ruby_abstract_subcommand_l47_d4_define(abstract_subcommand_spec_class(), mut parser)!
	subcommands := parser.subcommand_list()
	if subcommands.len != 1 {
		return false
	}
	return subcommands[0].name == 'test' && subcommands[0].aliases == ['ts'] && subcommands[0].default && parser.processed_options_for_subcommand('test').map(it.long).contains('--foo')
}

// Ruby it `it "allows access to args" do` at line 37.
pub fn ruby_abstract_subcommand_spec_l37_d3_allows() bool {
	argument := brew_runtime.object_value('Symbol', 'args')
	subcommand := homebrew.ruby_abstract_subcommand_l86_d7_initialize(argument, homebrew.AbstractSubcommandInitOptions{})
	actual := homebrew.ruby_abstract_subcommand_l83_d6_args(subcommand)
	return actual.type_name == 'Symbol' && actual.repr == 'args'
}

// Ruby it `it "finds subcommands nested under a command class" do` at line 41.
pub fn ruby_abstract_subcommand_spec_l41_d4_finds() bool {
	mut nested := homebrew.new_abstract_subcommand_class('SubcommandTestCmd::NestedSubcommand')
	homebrew.ruby_abstract_subcommand_l74_d5_subcommand_args(mut nested, homebrew.AbstractSubcommandArgsConfig{}, abstract_subcommand_spec_named_none)
	mut other := homebrew.new_abstract_subcommand_class('OtherSubcommandTestCmd::NestedSubcommand')
	homebrew.ruby_abstract_subcommand_l74_d5_subcommand_args(mut other, homebrew.AbstractSubcommandArgsConfig{}, abstract_subcommand_spec_named_none)
	found := homebrew.ruby_abstract_subcommand_l32_d2_subcommands_for('SubcommandTestCmd', [
		nested,
		other,
	])
	return found.len == 1 && found[0].name == nested.name
}

// Ruby method `run; end` at line 44.
pub fn ruby_abstract_subcommand_spec_l44_d5_run() {}

// Ruby method `run; end` at line 50.
pub fn ruby_abstract_subcommand_spec_l50_d6_run() {}

// Ruby it `it "defines all subcommands nested under a command class" do` at line 58.
pub fn ruby_abstract_subcommand_spec_l58_d7_defines() !bool {
	mut first := homebrew.new_abstract_subcommand_class('SubcommandTestCmd::FirstSubcommand')
	homebrew.ruby_abstract_subcommand_l74_d5_subcommand_args(mut first, homebrew.AbstractSubcommandArgsConfig{}, abstract_subcommand_spec_named_none)
	mut second := homebrew.new_abstract_subcommand_class('SubcommandTestCmd::SecondSubcommand')
	homebrew.ruby_abstract_subcommand_l74_d5_subcommand_args(mut second, homebrew.AbstractSubcommandArgsConfig{}, abstract_subcommand_spec_named_none)
	mut parser := brew_cli.new_parser('SubcommandTestCmd')
	homebrew.ruby_abstract_subcommand_l40_d3_define_all(mut parser, 'SubcommandTestCmd', [
		first,
		second,
	])!
	names := parser.subcommand_names()
	return 'first' in names && 'second' in names
}

// Ruby method `run; end` at line 61.
pub fn ruby_abstract_subcommand_spec_l61_d8_run() {}

// Ruby method `run; end` at line 65.
pub fn ruby_abstract_subcommand_spec_l65_d9_run() {}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "abstract_subcommand"
// 6:
// 7: RSpec.describe Homebrew::AbstractSubcommand do
// 8:   describe "subclasses" do
// 9:     before do
// 10:       subcommand = Class.new(Homebrew::AbstractSubcommand) do
// 11:         subcommand_args aliases: ["ts"], default: true do
// 12:           usage_banner <<~EOS
// 13:             `brew test`:
// 14:             Run the test subcommand.
// 15:           EOS
// 16:           switch "--foo"
// 17:           named_args :none
// 18:         end
// 19:
// 20:         def run; end
// 21:       end
// 22:       stub_const("TestSubcommand", subcommand)
// 23:       stub_const("SubcommandTestCmd", Class.new(Homebrew::AbstractCommand))
// 24:     end
// 25:
// 26:     it "defines parser metadata from subcommand_args" do
// 27:       parser = Homebrew::CLI::Parser.new(SubcommandTestCmd) do
// 28:         TestSubcommand.define(self)
// 29:       end
// 30:
// 31:       expect(parser.subcommands.first.name).to eq("test")
// 32:       expect(parser.subcommands.first.aliases).to eq(["ts"])
// 33:       expect(parser.subcommands.first.default).to be(true)
// 34:       expect(parser.processed_options_for_subcommand("test").map(&:second)).to include("--foo")
// 35:     end
// 36:
// 37:     it "allows access to args" do
// 38:       expect(TestSubcommand.new(:args).args).to eq(:args)
// 39:     end
// 40:
// 41:     it "finds subcommands nested under a command class" do
// 42:       nested_subcommand = Class.new(Homebrew::AbstractSubcommand) do
// 43:         subcommand_args { named_args :none }
// 44:         def run; end
// 45:       end
// 46:       stub_const("SubcommandTestCmd::NestedSubcommand", nested_subcommand)
// 47:       stub_const("OtherSubcommandTestCmd", Class.new(Homebrew::AbstractCommand))
// 48:       other_subcommand = Class.new(Homebrew::AbstractSubcommand) do
// 49:         subcommand_args { named_args :none }
// 50:         def run; end
// 51:       end
// 52:       stub_const("OtherSubcommandTestCmd::NestedSubcommand", other_subcommand)
// 53:
// 54:       expect(described_class.subcommands_for(SubcommandTestCmd)).to include(nested_subcommand)
// 55:       expect(described_class.subcommands_for(SubcommandTestCmd)).not_to include(other_subcommand)
// 56:     end
// 57:
// 58:     it "defines all subcommands nested under a command class" do
// 59:       stub_const("SubcommandTestCmd::FirstSubcommand", Class.new(Homebrew::AbstractSubcommand) do
// 60:         subcommand_args { named_args :none }
// 61:         def run; end
// 62:       end)
// 63:       stub_const("SubcommandTestCmd::SecondSubcommand", Class.new(Homebrew::AbstractSubcommand) do
// 64:         subcommand_args { named_args :none }
// 65:         def run; end
// 66:       end)
// 67:
// 68:       abstract_subcommand = described_class
// 69:       parser = Homebrew::CLI::Parser.new(SubcommandTestCmd) do
// 70:         abstract_subcommand.define_all(self, command: SubcommandTestCmd)
// 71:       end
// 72:
// 73:       expect(parser.subcommand_names).to include("first", "second")
// 74:     end
// 75:   end
// 76: end
