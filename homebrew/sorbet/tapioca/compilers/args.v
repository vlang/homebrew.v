module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/args.rb`.
// The original source is retained below until every stub has a typed V body.
pub const args_compiler_global_options = ['d?', 'debug?', 'q?', 'quiet?', 'v?', 'verbose?', 'h?',
	'help?']

pub struct ArgsCompilerParser {
pub:
	args_methods      []string
	processed_options map[string]string
	subcommands       []string
}

pub struct ArgsCompilerCommand {
pub:
	name            string
	args_class_name string
	is_brew         bool
	parser          ArgsCompilerParser
}

@[heap]
pub struct ArgsCompilerInput {
pub:
	commands []ArgsCompilerCommand
}

pub struct ArgsCompilerDecoration {
pub:
	command_name         string
	args_class_name      string
	args_superclass_name string
	args_methods         []TapiocaGeneratedMethod
	command_methods      []TapiocaGeneratedMethod
}

pub fn args_compiler_args_table(parser ArgsCompilerParser) []string {
	return parser.args_methods.clone()
}

pub fn args_compiler_comma_arrays(parser ArgsCompilerParser) []string {
	mut names := []string{}
	for option, kind in parser.processed_options {
		if kind == 'comma_array' {
			mut name := option
			for name.starts_with('-') {
				name = name[1..]
			}
			if name.starts_with('[no-]') {
				name = name[5..]
			}
			names << name.replace('-', '_').replace('=', '')
		}
	}
	return names
}

pub fn args_compiler_return_type(method_name string, comma_array_methods []string) string {
	if method_name in comma_array_methods {
		return 'T.nilable(T::Array[String])'
	}
	if method_name.ends_with('?') {
		return 'T::Boolean'
	}
	return 'T.nilable(String)'
}

pub fn args_compiler_create_methods(parser ArgsCompilerParser) []TapiocaGeneratedMethod {
	comma_array_methods := args_compiler_comma_arrays(parser)
	mut args_methods := args_compiler_args_table(parser)
	if parser.subcommands.len > 0 && 'subcommand' !in args_methods {
		args_methods << 'subcommand'
	}
	mut methods := []TapiocaGeneratedMethod{}
	for method_name in args_methods {
		if method_name in args_compiler_global_options {
			continue
		}
		methods << TapiocaGeneratedMethod{
			name: method_name
			return_type: args_compiler_return_type(method_name, comma_array_methods)
		}
	}
	return methods
}

pub fn args_compiler_decoration(command ArgsCompilerCommand) ?ArgsCompilerDecoration {
	if command.is_brew {
		return none
	}
	return ArgsCompilerDecoration{
		command_name: command.name
		args_class_name: command.args_class_name
		args_superclass_name: 'Homebrew::CLI::Args'
		args_methods: args_compiler_create_methods(command.parser)
		command_methods: [TapiocaGeneratedMethod{
			name: 'args'
			return_type: command.args_class_name
		}]
	}
}

fn args_compiler_methods_value(methods []TapiocaGeneratedMethod) ruby.Value {
	return ruby.array_value(methods.map(ruby.map_value({
		'name':         ruby.string_value(it.name)
		'return_type':  ruby.string_value(it.return_type)
		'class_method': ruby.bool_value(it.class_method)
		'parameters':   ruby.string_array_value(it.parameters)
	})))
}

fn args_compiler_decoration_value(decoration ArgsCompilerDecoration) ruby.Value {
	return ruby.map_value({
		'command_name':         ruby.string_value(decoration.command_name)
		'args_class_name':      ruby.string_value(decoration.args_class_name)
		'args_superclass_name': ruby.string_value(decoration.args_superclass_name)
		'args_methods':         args_compiler_methods_value(decoration.args_methods)
		'command_methods':      args_compiler_methods_value(decoration.command_methods)
	})
}

fn args_compiler_input_value(input &ArgsCompilerInput) ruby.Value {
	return ruby.structured_value('Tapioca::Compilers::Args::Input', '', {
		'args_compiler_input_address': u64(voidptr(input)).str()
	})
}

fn args_compiler_input_from_value(value ruby.Value) &ArgsCompilerInput {
	address := value.attributes['args_compiler_input_address'] or {
		panic('invalid Args compiler input')
	}
	return unsafe { &ArgsCompilerInput(voidptr(address.u64())) }
}

fn args_compiler_parser_value(parser &ArgsCompilerParser) ruby.Value {
	return ruby.structured_value('Homebrew::CLI::Parser', '', {
		'args_compiler_parser_address': u64(voidptr(parser)).str()
	})
}

fn args_compiler_parser_from_value(value ruby.Value) &ArgsCompilerParser {
	address := value.attributes['args_compiler_parser_address'] or {
		panic('invalid Args compiler parser')
	}
	return unsafe { &ArgsCompilerParser(voidptr(address.u64())) }
}

pub fn args_compiler_input_boundary(input &ArgsCompilerInput) ruby.Value {
	return args_compiler_input_value(input)
}

pub fn args_compiler_parser_boundary(parser &ArgsCompilerParser) ruby.Value {
	return args_compiler_parser_value(parser)
}

// Ruby method `self.gather_constants` at line 19.
pub fn ruby_args_l19_d1_self_gather_constants(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	input := args_compiler_input_from_value(args[0])
	return ruby.array_value(input.commands.map(ruby.object_value('Class', it.name)))
}

// Ruby method `decorate` at line 28.
pub fn ruby_args_l28_d2_decorate(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'input and command are required')
	}
	input := args_compiler_input_from_value(args[0])
	name := args[1].as_string()
	matches := input.commands.filter(it.name == name)
	if matches.len == 0 {
		return ruby.object_value('NameError', 'unknown command ${name}')
	}
	decoration := args_compiler_decoration(matches[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return args_compiler_decoration_value(decoration)
}

// Ruby method `args_table(parser) = parser.args.methods(false)` at line 43.
pub fn ruby_args_l43_d3_args_table(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'parser is required')
	}
	return ruby.string_array_value(args_compiler_args_table(*args_compiler_parser_from_value(args[0])))
}

// Ruby method `comma_arrays(parser)` at line 46.
pub fn ruby_args_l46_d4_comma_arrays(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'parser is required')
	}
	return ruby.string_array_value(args_compiler_comma_arrays(*args_compiler_parser_from_value(args[0])))
}

// Ruby method `get_return_type(method_name, comma_array_methods)` at line 52.
pub fn ruby_args_l52_d5_get_return_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'method and comma-array methods are required')
	}
	comma_arrays := args[1].as_string_array() or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.string_value(args_compiler_return_type(args[0].as_string(), comma_arrays))
}

// Ruby method `create_args_methods(klass, parser)` at line 65.
pub fn ruby_args_l65_d6_create_args_methods(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'parser is required')
	}
	parser_value := args[args.len - 1]
	return args_compiler_methods_value(args_compiler_create_methods(*args_compiler_parser_from_value(parser_value)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "cli/parser"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class Args < Tapioca::Dsl::Compiler
// 10:       GLOBAL_OPTIONS = T.let(
// 11:         Homebrew::CLI::Parser.global_options.map do |short_option, long_option, _|
// 12:           [short_option, long_option].map { "#{Homebrew::CLI::Parser.option_to_name(it)}?" }
// 13:         end.flatten.freeze, T::Array[String]
// 14:       )
// 15:
// 16:       Parsable = T.type_alias { T.any(T.class_of(Homebrew::CLI::Args), T.class_of(Homebrew::AbstractCommand)) }
// 17:       ConstantType = type_member { { fixed: Parsable } }
// 18:       sig { override.returns(T::Enumerable[Parsable]) }
// 19:       def self.gather_constants
// 20:         # require all the commands to ensure the command subclasses are defined
// 21:         ["cmd", "dev-cmd"].each do |dir|
// 22:           Dir[File.join(__dir__, "../../../#{dir}", "*.rb")].each { require(it) }
// 23:         end
// 24:         Homebrew::AbstractCommand.subclasses
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def decorate
// 29:         cmd = T.cast(constant, T.class_of(Homebrew::AbstractCommand))
// 30:         # This is a dummy class to make the `brew` command parsable
// 31:         return if cmd == Homebrew::Cmd::Brew
// 32:
// 33:         args_class_name = T.must(T.must(cmd.args_class).name)
// 34:         root.create_class(args_class_name, superclass_name: "Homebrew::CLI::Args") do |klass|
// 35:           create_args_methods(klass, cmd.parser)
// 36:         end
// 37:         root.create_path(constant) do |klass|
// 38:           klass.create_method("args", return_type: args_class_name)
// 39:         end
// 40:       end
// 41:
// 42:       sig { params(parser: Homebrew::CLI::Parser).returns(T::Array[Symbol]) }
// 43:       def args_table(parser) = parser.args.methods(false)
// 44:
// 45:       sig { params(parser: Homebrew::CLI::Parser).returns(T::Array[Symbol]) }
// 46:       def comma_arrays(parser)
// 47:         parser.instance_variable_get(:@non_global_processed_options)
// 48:               .filter_map { |k, v| parser.option_to_name(k).to_sym if v == :comma_array }
// 49:       end
// 50:
// 51:       sig { params(method_name: Symbol, comma_array_methods: T::Array[Symbol]).returns(String) }
// 52:       def get_return_type(method_name, comma_array_methods)
// 53:         if comma_array_methods.include?(method_name)
// 54:           "T.nilable(T::Array[String])"
// 55:         elsif method_name.end_with?("?")
// 56:           "T::Boolean"
// 57:         else
// 58:           "T.nilable(String)"
// 59:         end
// 60:       end
// 61:
// 62:       private
// 63:
// 64:       sig { params(klass: RBI::Scope, parser: Homebrew::CLI::Parser).void }
// 65:       def create_args_methods(klass, parser)
// 66:         comma_array_methods = comma_arrays(parser)
// 67:         args_methods = args_table(parser)
// 68:
// 69:         # `CLI::Parser` adds `subcommand` dynamically during parsing for commands
// 70:         # that define subcommands.
// 71:         args_methods << :subcommand if parser.subcommands.present? && !args_methods.include?(:subcommand)
// 72:
// 73:         args_methods.each do |method_name|
// 74:           method_name_str = method_name.to_s
// 75:           next if GLOBAL_OPTIONS.include?(method_name_str)
// 76:
// 77:           return_type = get_return_type(method_name, comma_array_methods)
// 78:           klass.create_method(method_name_str, return_type:)
// 79:         end
// 80:       end
// 81:     end
// 82:   end
// 83: end
