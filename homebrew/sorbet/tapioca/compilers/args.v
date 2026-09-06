module compilers

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
