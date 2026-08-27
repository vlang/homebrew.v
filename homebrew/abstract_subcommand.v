module homebrew

import brew_runtime

// Translated from Homebrew/brew `abstract_subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `subcommand_name` at line 20.
pub fn ruby_abstract_subcommand_l20_d1_subcommand_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subcommand_name', ...args)
}

// Ruby method `subcommands_for(command)` at line 32.
pub fn ruby_abstract_subcommand_l32_d2_subcommands_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subcommands_for', ...args)
}

// Ruby method `define_all(parser, command:)` at line 40.
pub fn ruby_abstract_subcommand_l40_d3_define_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_all', ...args)
}

// Ruby method `define(parser)` at line 47.
pub fn ruby_abstract_subcommand_l47_d4_define(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define', ...args)
}

// Ruby method `subcommand_args(aliases: [], alias_options: {}, default: false, &block)` at line 74.
pub fn ruby_abstract_subcommand_l74_d5_subcommand_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subcommand_args', ...args)
}

// Ruby attr_reader `attr_reader :args` at line 83.
pub fn ruby_abstract_subcommand_l83_d6_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby method `initialize(args, context: nil, targets: nil, quiet: false, cleanup: true)` at line 86.
pub fn ruby_abstract_subcommand_l86_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :context` at line 95.
pub fn ruby_abstract_subcommand_l95_d8_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('context', ...args)
}

// Ruby attr_reader `attr_reader :targets` at line 98.
pub fn ruby_abstract_subcommand_l98_d9_targets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('targets', ...args)
}

// Ruby attr_reader `attr_reader :quiet` at line 101.
pub fn ruby_abstract_subcommand_l101_d10_quiet(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('quiet', ...args)
}

// Ruby attr_reader `attr_reader :cleanup` at line 104.
pub fn ruby_abstract_subcommand_l104_d11_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup', ...args)
}

// Ruby method `run; end` at line 110.
pub fn ruby_abstract_subcommand_l110_d12_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/parser"
// 5: require "abstract_command"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Subclass this to implement a subcommand for a `brew` command.
// 10:   #
// 11:   # @api public
// 12:   class AbstractSubcommand
// 13:     extend T::Helpers
// 14:     include Utils::Output::Mixin
// 15:
// 16:     abstract!
// 17:
// 18:     class << self
// 19:       sig { returns(String) }
// 20:       def subcommand_name
// 21:         require "utils"
// 22:
// 23:         class_name = name
// 24:         raise TypeError, "anonymous subcommands do not have names" if class_name.nil?
// 25:
// 26:         Utils.underscore(class_name.split("::").fetch(-1))
// 27:              .tr("_", "-")
// 28:              .delete_suffix("-subcommand")
// 29:       end
// 30:
// 31:       sig { params(command: T.class_of(Homebrew::AbstractCommand)).returns(T::Array[T.class_of(AbstractSubcommand)]) }
// 32:       def subcommands_for(command)
// 33:         namespace = "#{command.name}::"
// 34:         subclasses.select do |subcommand|
// 35:           subcommand.name&.start_with?(namespace)
// 36:         end
// 37:       end
// 38:
// 39:       sig { params(parser: CLI::Parser, command: T.class_of(Homebrew::AbstractCommand)).void }
// 40:       def define_all(parser, command:)
// 41:         subcommands_for(command).each do |subcommand|
// 42:           subcommand.define(parser)
// 43:         end
// 44:       end
// 45:
// 46:       sig { params(parser: CLI::Parser).void }
// 47:       def define(parser)
// 48:         parser_block = @parser_block
// 49:         raise TypeError, "subcommand arguments have not been defined" if parser_block.nil?
// 50:
// 51:         parser.subcommand(
// 52:           subcommand_name,
// 53:           aliases:       @aliases || [],
// 54:           alias_options: @alias_options || {},
// 55:           default:       @default || false,
// 56:         ) do
// 57:           instance_eval(&parser_block)
// 58:         end
// 59:       end
// 60:
// 61:       private
// 62:
// 63:       # The description and arguments of the subcommand should be defined within this block.
// 64:       #
// 65:       # @api public
// 66:       sig {
// 67:         params(
// 68:           aliases:       T::Array[String],
// 69:           alias_options: T::Hash[String, String],
// 70:           default:       T::Boolean,
// 71:           block:         T.proc.bind(CLI::Parser).void,
// 72:         ).void
// 73:       }
// 74:       def subcommand_args(aliases: [], alias_options: {}, default: false, &block)
// 75:         @aliases = T.let(aliases, T.nilable(T::Array[String]))
// 76:         @alias_options = T.let(alias_options, T.nilable(T::Hash[String, String]))
// 77:         @default = T.let(default, T.nilable(T::Boolean))
// 78:         @parser_block = T.let(block, T.nilable(T.proc.void))
// 79:       end
// 80:     end
// 81:
// 82:     sig { returns(T.untyped) }
// 83:     attr_reader :args
// 84:
// 85:     sig { params(args: T.untyped, context: T.untyped, targets: T.untyped, quiet: T::Boolean, cleanup: T::Boolean).void }
// 86:     def initialize(args, context: nil, targets: nil, quiet: false, cleanup: true)
// 87:       @args = args
// 88:       @context = context
// 89:       @targets = targets
// 90:       @quiet = quiet
// 91:       @cleanup = cleanup
// 92:     end
// 93:
// 94:     sig { returns(T.untyped) }
// 95:     attr_reader :context
// 96:
// 97:     sig { returns(T.untyped) }
// 98:     attr_reader :targets
// 99:
// 100:     sig { returns(T::Boolean) }
// 101:     attr_reader :quiet
// 102:
// 103:     sig { returns(T::Boolean) }
// 104:     attr_reader :cleanup
// 105:
// 106:     # This method will be invoked when the subcommand is run.
// 107:     #
// 108:     # @api public
// 109:     sig { abstract.void }
// 110:     def run; end
// 111:   end
// 112: end
