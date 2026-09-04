module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/args.rb`.
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
