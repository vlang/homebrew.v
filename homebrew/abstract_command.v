module homebrew

import homebrew.cli
import os

// Translated from Homebrew/brew `abstract_command.rb`.

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
