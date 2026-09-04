module homebrew

import ruby
import homebrew.cli as brew_cli

// Translated from Homebrew/brew `abstract_subcommand.rb`.

// AbstractSubcommandParserBlock is the V equivalent of the parser-bound block
// retained by `subcommand_args` in Ruby.
pub type AbstractSubcommandParserBlock = fn (mut brew_cli.Parser) !

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
	context ruby.Value
	targets ruby.Value
	quiet   bool
	cleanup bool = true
}

// AbstractSubcommand stores the five instance variables initialized by Ruby.
// The untyped Ruby readers remain Values while their boolean state is concrete.
pub struct AbstractSubcommand {
	args_value    ruby.Value
	context_value ruby.Value
	targets_value ruby.Value
	quiet_value   bool
	cleanup_value bool
}

fn abstract_subcommand_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn new_abstract_subcommand(args ruby.Value, options AbstractSubcommandInitOptions) AbstractSubcommand {
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

pub fn (subcommand AbstractSubcommand) args() ruby.Value {
	return subcommand.args_value
}

pub fn (subcommand AbstractSubcommand) context() ruby.Value {
	return subcommand.context_value
}

pub fn (subcommand AbstractSubcommand) targets() ruby.Value {
	return subcommand.targets_value
}

pub fn (subcommand AbstractSubcommand) quiet() bool {
	return subcommand.quiet_value
}

pub fn (subcommand AbstractSubcommand) cleanup() bool {
	return subcommand.cleanup_value
}
