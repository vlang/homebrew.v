module homebrew

import brew_runtime
import homebrew.cli as brew_cli

// Translated from Homebrew/brew `abstract_subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

// AbstractSubcommandParserBlock is the V equivalent of the parser-bound block
// retained by `subcommand_args` in Ruby.
pub type AbstractSubcommandParserBlock = fn(mut brew_cli.Parser) !

// AbstractSubcommandArgsConfig retains the class-level metadata supplied to
// `subcommand_args`.
pub struct AbstractSubcommandArgsConfig {
pub:
	aliases       []string
	alias_options map[string]string
	default       bool
}

// AbstractSubcommandClass models the Ruby subclass object. Ruby discovers these
// objects through T::Helpers.subclasses; translated callers pass the same ordered
// subclass list explicitly.
pub struct AbstractSubcommandClass {
pub:
	name     string
	has_name bool
pub mut:
	aliases          []string
	alias_options    map[string]string
	default          bool
	has_parser_block bool
	parser_block     AbstractSubcommandParserBlock @[required]
}

fn abstract_subcommand_empty_parser_block(mut _ brew_cli.Parser) ! {}

pub fn new_abstract_subcommand_class(name string) AbstractSubcommandClass {
	return AbstractSubcommandClass{
		name: name
		has_name: true
		alias_options: map[string]string{}
		parser_block: abstract_subcommand_empty_parser_block
	}
}

pub fn new_anonymous_abstract_subcommand_class() AbstractSubcommandClass {
	return AbstractSubcommandClass{
		alias_options: map[string]string{}
		parser_block: abstract_subcommand_empty_parser_block
	}
}

pub fn (subcommand AbstractSubcommandClass) subcommand_name() !string {
	if !subcommand.has_name {
		return error('anonymous subcommands do not have names')
	}
	parts := subcommand.name.split('::')
	class_name := parts[parts.len - 1]
	mut name := underscore(class_name).replace('_', '-')
	if name.ends_with('-subcommand') {
		name = name[..name.len - '-subcommand'.len]
	}
	return name
}

pub fn abstract_subcommands_for(command_name string, subclasses []AbstractSubcommandClass) []AbstractSubcommandClass {
	namespace := '${command_name}::'
	return subclasses.filter(it.has_name && it.name.starts_with(namespace))
}

pub fn abstract_subcommand_define_all(mut parser brew_cli.Parser, command_name string,
	subclasses []AbstractSubcommandClass) ! {
	for subcommand in abstract_subcommands_for(command_name, subclasses) {
		subcommand.define(mut parser)!
	}
}

pub fn (subcommand AbstractSubcommandClass) define(mut parser brew_cli.Parser) ! {
	if !subcommand.has_parser_block {
		return error('subcommand arguments have not been defined')
	}
	name := subcommand.subcommand_name()!
	parser.add_subcommand(name, brew_cli.SubcommandConfig{
		aliases: subcommand.aliases.clone()
		alias_options: subcommand.alias_options.clone()
		default: subcommand.default
	}, subcommand.parser_block)!
}

pub fn (mut subcommand AbstractSubcommandClass) subcommand_args(config AbstractSubcommandArgsConfig,
	block AbstractSubcommandParserBlock) {
	subcommand.aliases = config.aliases.clone()
	subcommand.alias_options = config.alias_options.clone()
	subcommand.default = config.default
	subcommand.parser_block = block
	subcommand.has_parser_block = true
}

pub struct AbstractSubcommandInitOptions {
pub:
	context brew_runtime.Value
	targets brew_runtime.Value
	quiet   bool
	cleanup bool = true
}

// AbstractSubcommand stores the five instance variables initialized by Ruby.
// The untyped Ruby readers remain Values while their boolean state is concrete.
pub struct AbstractSubcommand {
	args_value    brew_runtime.Value
	context_value brew_runtime.Value
	targets_value brew_runtime.Value
	quiet_value   bool
	cleanup_value bool
}

fn abstract_subcommand_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_abstract_subcommand(args brew_runtime.Value, options AbstractSubcommandInitOptions) AbstractSubcommand {
	return AbstractSubcommand{
		args_value: args
		context_value: if options.context.type_name == '' {
			abstract_subcommand_nil()
		} else {
			options.context
		}
		targets_value: if options.targets.type_name == '' {
			abstract_subcommand_nil()
		} else {
			options.targets
		}
		quiet_value: options.quiet
		cleanup_value: options.cleanup
	}
}

pub fn (subcommand AbstractSubcommand) args() brew_runtime.Value {
	return subcommand.args_value
}

pub fn (subcommand AbstractSubcommand) context() brew_runtime.Value {
	return subcommand.context_value
}

pub fn (subcommand AbstractSubcommand) targets() brew_runtime.Value {
	return subcommand.targets_value
}

pub fn (subcommand AbstractSubcommand) quiet() bool {
	return subcommand.quiet_value
}

pub fn (subcommand AbstractSubcommand) cleanup() bool {
	return subcommand.cleanup_value
}

// Ruby method `subcommand_name` at line 20.
pub fn ruby_abstract_subcommand_l20_d1_subcommand_name(subcommand AbstractSubcommandClass) !string {
	return subcommand.subcommand_name()
}

// Ruby method `subcommands_for(command)` at line 32.
pub fn ruby_abstract_subcommand_l32_d2_subcommands_for(command_name string,
	subclasses []AbstractSubcommandClass) []AbstractSubcommandClass {
	return abstract_subcommands_for(command_name, subclasses)
}

// Ruby method `define_all(parser, command:)` at line 40.
pub fn ruby_abstract_subcommand_l40_d3_define_all(mut parser brew_cli.Parser, command_name string,
	subclasses []AbstractSubcommandClass) ! {
	abstract_subcommand_define_all(mut parser, command_name, subclasses)!
}

// Ruby method `define(parser)` at line 47.
pub fn ruby_abstract_subcommand_l47_d4_define(subcommand AbstractSubcommandClass,
	mut parser brew_cli.Parser) ! {
	subcommand.define(mut parser)!
}

// Ruby method `subcommand_args(aliases: [], alias_options: {}, default: false, &block)` at line 74.
pub fn ruby_abstract_subcommand_l74_d5_subcommand_args(mut subcommand AbstractSubcommandClass,
	config AbstractSubcommandArgsConfig, block AbstractSubcommandParserBlock) {
	subcommand.subcommand_args(config, block)
}

// Ruby attr_reader `attr_reader :args` at line 83.
pub fn ruby_abstract_subcommand_l83_d6_args(subcommand AbstractSubcommand) brew_runtime.Value {
	return subcommand.args()
}

// Ruby method `initialize(args, context: nil, targets: nil, quiet: false, cleanup: true)` at line 86.
pub fn ruby_abstract_subcommand_l86_d7_initialize(args brew_runtime.Value,
	options AbstractSubcommandInitOptions) AbstractSubcommand {
	return new_abstract_subcommand(args, options)
}

// Ruby attr_reader `attr_reader :context` at line 95.
pub fn ruby_abstract_subcommand_l95_d8_context(subcommand AbstractSubcommand) brew_runtime.Value {
	return subcommand.context()
}

// Ruby attr_reader `attr_reader :targets` at line 98.
pub fn ruby_abstract_subcommand_l98_d9_targets(subcommand AbstractSubcommand) brew_runtime.Value {
	return subcommand.targets()
}

// Ruby attr_reader `attr_reader :quiet` at line 101.
pub fn ruby_abstract_subcommand_l101_d10_quiet(subcommand AbstractSubcommand) bool {
	return subcommand.quiet()
}

// Ruby attr_reader `attr_reader :cleanup` at line 104.
pub fn ruby_abstract_subcommand_l104_d11_cleanup(subcommand AbstractSubcommand) bool {
	return subcommand.cleanup()
}

// Ruby method `run; end` at line 110.
pub fn ruby_abstract_subcommand_l110_d12_run(_ AbstractSubcommand) {}

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
