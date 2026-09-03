module test

import homebrew
import homebrew.cli
import os

// Translated from Homebrew/brew `test/abstract_command_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn define_test_cat_args(mut parser cli.Parser) {
	parser.set_description('test')
	parser.add_switch(['--foo'], cli.OptionConfig{})
	parser.add_flag(['--bar='], cli.OptionConfig{})
}

pub fn abstract_command_spec_test_cat() homebrew.AbstractCommandClass {
	mut test_cat := homebrew.new_abstract_command_class('TestCat', homebrew.AbstractCommandClassConfig{})
	test_cat.define_args(define_test_cat_args)
	return test_cat
}

fn abstract_command_spec_registry(commands []homebrew.AbstractCommandClass) homebrew.AbstractCommandRegistry {
	mut registry := homebrew.AbstractCommandRegistry{}
	for command in commands {
		registry.register(command)
	}
	return registry
}

fn class_name_from_command_source(source string) ?string {
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('class ') && trimmed.contains(' < ') && trimmed.contains('AbstractCommand') {
			return trimmed.all_after('class ').all_before(' <').trim_space()
		}
	}
	return none
}

fn command_name_override_from_source(source string) string {
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		prefix := 'def self.command_name = '
		if !trimmed.starts_with(prefix) {
			continue
		}
		literal := trimmed[prefix.len..].trim_space()
		if literal.len >= 2 && ((literal[0] == `"` && literal[literal.len - 1] == `"`) || (literal[0] == `'` && literal[literal.len - 1] == `'`)) {
			return literal[1..literal.len - 1]
		}
	}
	return ''
}

fn command_class_from_source(directory string, source string) !homebrew.AbstractCommandClass {
	short_name := class_name_from_command_source(source) or {
		return error('command source has no AbstractCommand subclass')
	}
	namespace := if directory == 'dev-cmd' { 'DevCmd' } else { 'Cmd' }
	return homebrew.new_abstract_command_class('Homebrew::${namespace}::${short_name}', homebrew.AbstractCommandClassConfig{
		command_name: command_name_override_from_source(source)
		shell_command: source.split_into_lines().any(it.trim_space() in [
			'include ShellCommand',
			'include Homebrew::ShellCommand',
		])
	})
}

// Ruby method `run; end` at line 15.
pub fn ruby_abstract_command_spec_l15_d1_run() {}

// Ruby it `it "parses valid args" do` at line 21.
pub fn ruby_abstract_command_spec_l21_d2_parses() bool {
	command := homebrew.new_abstract_command(abstract_command_spec_test_cat(), ['--foo']) or {
		return false
	}
	command.run()
	return command.args().switch_value('foo') or { false }
}

// Ruby it `it "allows access to args" do` at line 25.
pub fn ruby_abstract_command_spec_l25_d3_allows() bool {
	command := homebrew.new_abstract_command(abstract_command_spec_test_cat(), ['--bar', 'baz']) or {
		return false
	}
	return command.args().flag_value('bar') or { '' } == 'baz'
}

// Ruby it `it "raises on invalid args" do` at line 29.
pub fn ruby_abstract_command_spec_l29_d4_raises() bool {
	homebrew.new_abstract_command(abstract_command_spec_test_cat(), ['--bat']) or {
		return err.msg() == 'invalid option: --bat'
	}
	return false
}

// Ruby it `it "has a default command name" do` at line 35.
pub fn ruby_abstract_command_spec_l35_d5_has() bool {
	return abstract_command_spec_test_cat().command_name() or { '' } == 'test-cat'
}

// Ruby it `it "can lookup command" do` at line 39.
pub fn ruby_abstract_command_spec_l39_d6_can() bool {
	test_cat := abstract_command_spec_test_cat()
	registry := abstract_command_spec_registry([test_cat])
	found := registry.command('test-cat') or { return false }
	return found.class_name == test_cat.class_name
}

// Ruby it `it "removes -cmd suffix from command name" do` at line 43.
pub fn ruby_abstract_command_spec_l43_d7_removes() bool {
	formula := homebrew.new_abstract_command_class('Homebrew::DevCmd::FormulaCmd', homebrew.AbstractCommandClassConfig{})
	return formula.command_name() or { '' } == 'formula'
}

// Ruby method `self.command_name = "t-a-c"` at line 51.
pub fn ruby_abstract_command_spec_l51_d8_self_command_name() string {
	return 't-a-c'
}

// Ruby method `run; end` at line 52.
pub fn ruby_abstract_command_spec_l52_d9_run() {}

// Ruby it `it "can be looked up by command name" do` at line 57.
pub fn ruby_abstract_command_spec_l57_d10_can() bool {
	tac := homebrew.new_abstract_command_class('Tac', homebrew.AbstractCommandClassConfig{
		command_name: ruby_abstract_command_spec_l51_d8_self_command_name()
	})
	registry := abstract_command_spec_registry([tac])
	found := registry.command('t-a-c') or { return false }
	return found.class_name == tac.class_name
}

// Ruby it `it "match command name" do` at line 65.
pub fn ruby_abstract_command_spec_l65_d11_match(homebrew_root string) !bool {
	mut registry := homebrew.AbstractCommandRegistry{}
	mut paths := []string{}
	for directory in ['cmd', 'dev-cmd'] {
		mut directory_paths := os.glob(os.join_path(homebrew_root, directory, '*.rb')) or {
			return error('cannot enumerate ${directory} commands: ${err}')
		}
		directory_paths.sort()
		for path in directory_paths {
			source := os.read_file(path)!
			registry.register(command_class_from_source(directory, source)!)
			paths << path
		}
	}
	for path in paths {
		filename := os.file_name(path).all_before_last('.')
		command := registry.command(filename) or {
			return error('no AbstractCommand subclass registered for ${filename}')
		}
		resolved_name := command.command_name()!
		if !os.exists(os.join_path(os.dir(path), '${resolved_name}.rb')) {
			return false
		}
	}
	return true
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
