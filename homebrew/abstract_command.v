module homebrew

import homebrew.cli
import os

// Translated from Homebrew/brew `abstract_command.rb`.
// The original source is retained below until every stub has a typed V body.

// AbstractCommandParserBlock is the typed equivalent of the block passed to
// AbstractCommand.cmd_args. The block is evaluated against a fresh parser each
// time AbstractCommandClass.parser is called, just as in Ruby.
pub type AbstractCommandParserBlock = fn (mut cli.Parser)

pub struct AbstractCommandClassConfig {
pub:
	command_name  string
	shell_command bool
}

// AbstractCommandClass carries the class-level state Ruby stores on each
// AbstractCommand subclass.
pub struct AbstractCommandClass {
pub:
	class_name    string
	shell_command bool
mut:
	command_name_override string
	parser_block          ?AbstractCommandParserBlock
	args_class_name       ?string
}

pub struct AbstractCommandRegistry {
mut:
	subclasses []AbstractCommandClass
}

// AbstractCommand is a parsed command instance. parsed_args deliberately has a
// different field name so args() remains the exact attr_reader-shaped API.
pub struct AbstractCommand {
pub:
	command AbstractCommandClass
mut:
	parsed_args cli.Args
}

pub fn new_abstract_command_class(class_name string, config AbstractCommandClassConfig) AbstractCommandClass {
	return AbstractCommandClass{
		class_name: class_name
		shell_command: config.shell_command
		command_name_override: config.command_name
	}
}

fn delete_command_suffix(name string) string {
	if name.ends_with('-cmd') {
		return name[..name.len - 4]
	}
	return name
}

// command_name_from_class_name mirrors Utils.underscore(name.split("::").last)
// followed by the two Ruby suffix transformations.
pub fn command_name_from_class_name(class_name string) !string {
	if class_name.len == 0 {
		return error('anonymous commands do not have names')
	}
	class_component := class_name.split('::').last()
	return delete_command_suffix(underscore(class_component).replace('_', '-'))
}

// Ruby method `command_name` at line 32.
pub fn (command AbstractCommandClass) command_name() !string {
	if command.command_name_override.len > 0 {
		return command.command_name_override
	}
	return command_name_from_class_name(command.class_name)
}

// Ruby attr_reader `attr_reader :args_class` at line 29.
pub fn (command AbstractCommandClass) args_class() ?string {
	return command.args_class_name
}

// Ruby method `dev_cmd? = T.must(name).start_with?("Homebrew::DevCmd")` at line 45.
pub fn (command AbstractCommandClass) dev_cmd() bool {
	return command.class_name.starts_with('Homebrew::DevCmd')
}

// Ruby method `ruby_cmd? = !include?(Homebrew::ShellCommand)` at line 48.
pub fn (command AbstractCommandClass) ruby_cmd() bool {
	return !command.shell_command
}

// Ruby method `cmd_args(&block)` at line 59.
pub fn (mut command AbstractCommandClass) define_args(block AbstractCommandParserBlock) {
	command.parser_block = block
	command.args_class_name = if command.class_name.len > 0 {
		'${command.class_name}::Args'
	} else {
		'Args'
	}
}

// Ruby method `parser = CLI::Parser.new(self, &@parser_block)` at line 51.
pub fn (command AbstractCommandClass) parser() !cli.Parser {
	mut parser := cli.new_parser(command.command_name()!)
	parser.set_developer_command(command.dev_cmd())
	if block := command.parser_block {
		block(mut parser)
	}
	return parser
}

pub fn (mut registry AbstractCommandRegistry) register(command AbstractCommandClass) {
	registry.subclasses << command
}

pub fn (registry AbstractCommandRegistry) all() []AbstractCommandClass {
	return registry.subclasses.clone()
}

// Ruby method `command(name) = subclasses.find { it.command_name == name }` at line 42.
pub fn (registry AbstractCommandRegistry) command(name string) ?AbstractCommandClass {
	for candidate in registry.subclasses {
		candidate_name := candidate.command_name() or { continue }
		if candidate_name == name {
			return candidate
		}
	}
	return none
}

// Ruby method `initialize(argv = ARGV.freeze)` at line 69.
pub fn new_abstract_command(command AbstractCommandClass, argv []string) !AbstractCommand {
	mut parser := command.parser()!
	parsed_args := parser.parse(argv, false)!
	return AbstractCommand{
		command: command
		parsed_args: parsed_args
	}
}

pub fn new_abstract_command_from_process(command AbstractCommandClass) !AbstractCommand {
	argv := if os.args.len > 1 { os.args[1..].clone() } else { []string{} }
	return new_abstract_command(command, argv)
}

// Ruby attr_reader `attr_reader :args` at line 66.
pub fn (command AbstractCommand) args() cli.Args {
	return command.parsed_args
}

pub fn brew_abstract_command_class() AbstractCommandClass {
	return new_abstract_command_class('Homebrew::Cmd::Brew', AbstractCommandClassConfig{})
}

// Ruby method `run; end` at line 77.
pub fn (_ AbstractCommand) run() {}

// Ruby method `run; end` at line 84.
pub fn (_ AbstractCommand) run_brew() {}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/parser"
// 5: require "shell_command"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Subclass this to implement a `brew` command. This is preferred to declaring a named function in the `Homebrew`
// 10:   # module, because:
// 11:   #
// 12:   # - Each Command lives in an isolated namespace.
// 13:   # - Each Command implements a defined interface.
// 14:   # - `args` is available as an instance method and thus does not need to be passed as an argument to helper methods.
// 15:   # - Subclasses no longer need to reference `CLI::Parser` or parse args explicitly.
// 16:   #
// 17:   # To subclass, implement a `run` method and provide a `cmd_args` block to document the command and its allowed args.
// 18:   # To generate method signatures for command args, run `brew typecheck --update`.
// 19:   #
// 20:   # @api public
// 21:   class AbstractCommand
// 22:     extend T::Helpers
// 23:     include Utils::Output::Mixin
// 24:
// 25:     abstract!
// 26:
// 27:     class << self
// 28:       sig { returns(T.nilable(T.class_of(CLI::Args))) }
// 29:       attr_reader :args_class
// 30:
// 31:       sig { returns(String) }
// 32:       def command_name
// 33:         require "utils"
// 34:
// 35:         Utils.underscore(T.must(name).split("::").fetch(-1))
// 36:              .tr("_", "-")
// 37:              .delete_suffix("-cmd")
// 38:       end
// 39:
// 40:       # @return the AbstractCommand subclass associated with the brew CLI command name.
// 41:       sig { params(name: String).returns(T.nilable(T.class_of(AbstractCommand))) }
// 42:       def command(name) = subclasses.find { it.command_name == name }
// 43:
// 44:       sig { returns(T::Boolean) }
// 45:       def dev_cmd? = T.must(name).start_with?("Homebrew::DevCmd")
// 46:
// 47:       sig { returns(T::Boolean) }
// 48:       def ruby_cmd? = !include?(Homebrew::ShellCommand)
// 49:
// 50:       sig { returns(CLI::Parser) }
// 51:       def parser = CLI::Parser.new(self, &@parser_block)
// 52:
// 53:       private
// 54:
// 55:       # The description and arguments of the command should be defined within this block.
// 56:       #
// 57:       # @api public
// 58:       sig { params(block: T.proc.bind(CLI::Parser).void).void }
// 59:       def cmd_args(&block)
// 60:         @parser_block = T.let(block, T.nilable(T.proc.void))
// 61:         @args_class = T.let(const_set(:Args, Class.new(CLI::Args)), T.nilable(T.class_of(CLI::Args)))
// 62:       end
// 63:     end
// 64:
// 65:     sig { returns(CLI::Args) }
// 66:     attr_reader :args
// 67:
// 68:     sig { params(argv: T::Array[String]).void }
// 69:     def initialize(argv = ARGV.freeze)
// 70:       @args = T.let(self.class.parser.parse(argv), CLI::Args)
// 71:     end
// 72:
// 73:     # This method will be invoked when the command is run.
// 74:     #
// 75:     # @api public
// 76:     sig { abstract.void }
// 77:     def run; end
// 78:   end
// 79:
// 80:   module Cmd
// 81:     # The command class for `brew` itself, allowing its args to be parsed.
// 82:     class Brew < AbstractCommand
// 83:       sig { override.void }
// 84:       def run; end
// 85:     end
// 86:   end
// 87: end
