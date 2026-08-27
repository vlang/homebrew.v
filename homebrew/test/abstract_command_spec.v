module test

import brew_runtime

// Translated from Homebrew/brew `test/abstract_command_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run; end` at line 15.
pub fn ruby_abstract_command_spec_l15_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby it `it "parses valid args" do` at line 21.
pub fn ruby_abstract_command_spec_l21_d2_parses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parses', ...args)
}

// Ruby it `it "allows access to args" do` at line 25.
pub fn ruby_abstract_command_spec_l25_d3_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "raises on invalid args" do` at line 29.
pub fn ruby_abstract_command_spec_l29_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "has a default command name" do` at line 35.
pub fn ruby_abstract_command_spec_l35_d5_has(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has', ...args)
}

// Ruby it `it "can lookup command" do` at line 39.
pub fn ruby_abstract_command_spec_l39_d6_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "removes -cmd suffix from command name" do` at line 43.
pub fn ruby_abstract_command_spec_l43_d7_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby method `self.command_name = "t-a-c"` at line 51.
pub fn ruby_abstract_command_spec_l51_d8_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_name', ...args)
}

// Ruby method `run; end` at line 52.
pub fn ruby_abstract_command_spec_l52_d9_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby it `it "can be looked up by command name" do` at line 57.
pub fn ruby_abstract_command_spec_l57_d10_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "match command name" do` at line 65.
pub fn ruby_abstract_command_spec_l65_d11_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: RSpec.describe Homebrew::AbstractCommand do
// 7:   describe "subclasses" do
// 8:     before do
// 9:       test_cat = Class.new(Homebrew::AbstractCommand) do
// 10:         cmd_args do
// 11:           description "test"
// 12:           switch "--foo"
// 13:           flag "--bar="
// 14:         end
// 15:         def run; end
// 16:       end
// 17:       stub_const("TestCat", test_cat)
// 18:     end
// 19:
// 20:     describe "parsing args" do
// 21:       it "parses valid args" do
// 22:         expect { TestCat.new(["--foo"]).run }.not_to raise_error
// 23:       end
// 24:
// 25:       it "allows access to args" do
// 26:         expect(TestCat.new(["--bar", "baz"]).args.bar).to eq("baz")
// 27:       end
// 28:
// 29:       it "raises on invalid args" do
// 30:         expect { TestCat.new(["--bat"]) }.to raise_error(OptionParser::InvalidOption)
// 31:       end
// 32:     end
// 33:
// 34:     describe "command names" do
// 35:       it "has a default command name" do
// 36:         expect(TestCat.command_name).to eq("test-cat")
// 37:       end
// 38:
// 39:       it "can lookup command" do
// 40:         expect(described_class.command("test-cat")).to be(TestCat)
// 41:       end
// 42:
// 43:       it "removes -cmd suffix from command name" do
// 44:         require "dev-cmd/formula"
// 45:         expect(Homebrew::DevCmd::FormulaCmd.command_name).to eq("formula")
// 46:       end
// 47:
// 48:       describe "when command name is overridden" do
// 49:         before do
// 50:           tac = Class.new(Homebrew::AbstractCommand) do
// 51:             def self.command_name = "t-a-c"
// 52:             def run; end
// 53:           end
// 54:           stub_const("Tac", tac)
// 55:         end
// 56:
// 57:         it "can be looked up by command name" do
// 58:           expect(described_class.command("t-a-c")).to be(Tac)
// 59:         end
// 60:       end
// 61:     end
// 62:   end
// 63:
// 64:   describe "command paths" do
// 65:     it "match command name" do
// 66:       ["cmd", "dev-cmd"].each do |dir|
// 67:         Dir[File.join(__dir__, "../#{dir}", "*.rb")].each do |file|
// 68:           filename = File.basename(file, ".rb")
// 69:           require(file)
// 70:           command = described_class.command(filename)
// 71:           expect(Pathname(File.join(__dir__, "../#{dir}/#{command.command_name}.rb"))).to exist
// 72:         end
// 73:       end
// 74:     end
// 75:   end
// 76: end
