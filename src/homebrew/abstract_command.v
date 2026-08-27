module homebrew

import brew_runtime

// Translated from Homebrew/brew `abstract_command.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :args_class` at line 29.
pub fn ruby_abstract_command_l29_d1_args_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args_class', ...args)
}

// Ruby method `command_name` at line 32.
pub fn ruby_abstract_command_l32_d2_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command_name', ...args)
}

// Ruby method `command(name) = subclasses.find { it.command_name == name }` at line 42.
pub fn ruby_abstract_command_l42_d3_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby method `dev_cmd? = T.must(name).start_with?("Homebrew::DevCmd")` at line 45.
pub fn ruby_abstract_command_l45_d4_dev_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dev_cmd?', ...args)
}

// Ruby method `ruby_cmd? = !include?(Homebrew::ShellCommand)` at line 48.
pub fn ruby_abstract_command_l48_d5_ruby_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ruby_cmd?', ...args)
}

// Ruby method `parser = CLI::Parser.new(self, &@parser_block)` at line 51.
pub fn ruby_abstract_command_l51_d6_parser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parser', ...args)
}

// Ruby method `cmd_args(&block)` at line 59.
pub fn ruby_abstract_command_l59_d7_cmd_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd_args', ...args)
}

// Ruby attr_reader `attr_reader :args` at line 66.
pub fn ruby_abstract_command_l66_d8_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby method `initialize(argv = ARGV.freeze)` at line 69.
pub fn ruby_abstract_command_l69_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run; end` at line 77.
pub fn ruby_abstract_command_l77_d10_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `run; end` at line 84.
pub fn ruby_abstract_command_l84_d11_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

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
