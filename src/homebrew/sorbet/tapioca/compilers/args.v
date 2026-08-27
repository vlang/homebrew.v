module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/args.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants` at line 19.
pub fn ruby_args_l19_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 28.
pub fn ruby_args_l28_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Ruby method `args_table(parser) = parser.args.methods(false)` at line 43.
pub fn ruby_args_l43_d3_args_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args_table', ...args)
}

// Ruby method `comma_arrays(parser)` at line 46.
pub fn ruby_args_l46_d4_comma_arrays(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comma_arrays', ...args)
}

// Ruby method `get_return_type(method_name, comma_array_methods)` at line 52.
pub fn ruby_args_l52_d5_get_return_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_return_type', ...args)
}

// Ruby method `create_args_methods(klass, parser)` at line 65.
pub fn ruby_args_l65_d6_create_args_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_args_methods', ...args)
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
