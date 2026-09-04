module utils

import ruby

// Translated from Homebrew/brew `utils/shell_completion.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct CompletionParameter {
pub:
	arguments   []string
	environment map[string]string
}

pub fn default_completion_shells(format string) []string {
	return if format.trim_left(':') in ['cobra', 'typer'] {
		['bash', 'zsh', 'fish', 'pwsh']
	} else {
		['bash', 'zsh', 'fish']
	}
}

fn completion_executable_name(path string) string {
	normalized := path.replace('\\', '/')
	return normalized.all_after_last('/')
}

pub fn completion_shell_parameter(format string, shell string, executable string,
	environment map[string]string) CompletionParameter {
	mut result_environment := environment.clone()
	format_name := format.trim_left(':')
	shell_name := shell.trim_left(':')
	shell_parameter := if shell_name == 'pwsh' { 'powershell' } else { shell_name }
	arguments := match format_name {
		'' {
			[shell_parameter]
		}
		'arg' {
			['--shell=${shell_parameter}']
		}
		'clap' {
			result_environment['COMPLETE'] = shell_parameter
			[]string{}
		}
		'click' {
			program_name := completion_executable_name(executable).to_upper().replace('-', '_')
			result_environment['_${program_name}_COMPLETE'] = '${shell_parameter}_source'
			[]string{}
		}
		'cobra' {
			['completion', shell_parameter]
		}
		'flag' {
			['--${shell_parameter}']
		}
		'none' {
			[]string{}
		}
		'typer' {
			result_environment['_TYPER_COMPLETE_TEST_DISABLE_SHELL_DETECTION'] = '1'
			['--show-completion', shell_parameter]
		}
		else {
			['${format}${shell_name}']
		}
	}
	return CompletionParameter{
		arguments:   arguments
		environment: result_environment
	}
}

pub fn generate_completion_output(commands []string, parameter CompletionParameter) !string {
	if commands.len == 0 {
		return error('completion command must not be empty')
	}
	mut arguments := commands[1..].clone()
	arguments << parameter.arguments
	result := ruby.run_command_with_environment(commands[0], arguments,
		parameter.environment)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result.output
}

// Ruby method `self.default_completion_shells(format)` at line 10.
pub fn ruby_shell_completion_l10_d1_self_default_completion_shells(args ...ruby.Value) ruby.Value {
	format := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_array_value(default_completion_shells(format))
}

// Ruby method `self.completion_shell_parameter(format, shell, executable, env)` at line 27.
pub fn ruby_shell_completion_l27_d2_self_completion_shell_parameter(args ...ruby.Value) ruby.Value {
	if args.len < 3 { return ruby.object_value('NilClass', '') }
	parameter := completion_shell_parameter(args[0].as_string(), args[1].as_string(),
		args[2].as_string(), map[string]string{})
	if parameter.arguments.len == 0 {
		return ruby.structured_value('NilClass', '', parameter.environment)
	}
	if parameter.arguments.len == 1 {
		return ruby.structured_value('String', parameter.arguments[0],
			parameter.environment)
	}
	return ruby.structured_value('Array', parameter.arguments.str(), parameter.environment)
}

// Ruby method `self.generate_completion_output(commands, shell_parameter, env)` at line 64.
pub fn ruby_shell_completion_l64_d3_self_generate_completion_output(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	commands := args[0].as_string_array() or { return ruby.string_value('') }
	parameter_arguments := if args.len > 1 { args[1].as_string_array() or {
			if args[1].type_name == 'NilClass' { []string{} } else { [
					args[1].as_string()] }
		}
	 } else { []string{}
	 }
	output := generate_completion_output(commands, CompletionParameter{
		arguments: parameter_arguments
	}) or { panic(err) }
	return ruby.string_value(output)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Shared logic for generating shell completion scripts.
// 6:   # Used by both {Formula#generate_completions_from_executable} and
// 7:   # {Cask::Artifact::GeneratedCompletion}.
// 8:   module ShellCompletion
// 9:     sig { params(format: T.nilable(T.any(Symbol, String))).returns(T::Array[Symbol]) }
// 10:     def self.default_completion_shells(format)
// 11:       case format
// 12:       when :cobra, :typer
// 13:         [:bash, :zsh, :fish, :pwsh]
// 14:       else
// 15:         [:bash, :zsh, :fish]
// 16:       end
// 17:     end
// 18:
// 19:     sig {
// 20:       params(
// 21:         format:     T.nilable(T.any(Symbol, String)),
// 22:         shell:      Symbol,
// 23:         executable: String,
// 24:         env:        T::Hash[String, String],
// 25:       ).returns(T.nilable(T.any(String, T::Array[String])))
// 26:     }
// 27:     def self.completion_shell_parameter(format, shell, executable, env)
// 28:       # Go's cobra and Rust's clap accept "powershell".
// 29:       shell_parameter = (shell == :pwsh) ? "powershell" : shell.to_s
// 30:
// 31:       case format
// 32:       when nil
// 33:         shell_parameter
// 34:       when :arg
// 35:         "--shell=#{shell_parameter}"
// 36:       when :clap
// 37:         env["COMPLETE"] = shell_parameter
// 38:         nil
// 39:       when :click
// 40:         prog_name = File.basename(executable).upcase.tr("-", "_")
// 41:         env["_#{prog_name}_COMPLETE"] = "#{shell_parameter}_source"
// 42:         nil
// 43:       when :cobra
// 44:         ["completion", shell_parameter]
// 45:       when :flag
// 46:         "--#{shell_parameter}"
// 47:       when :none
// 48:         nil
// 49:       when :typer
// 50:         env["_TYPER_COMPLETE_TEST_DISABLE_SHELL_DETECTION"] = "1"
// 51:         ["--show-completion", shell_parameter]
// 52:       else
// 53:         "#{format}#{shell}"
// 54:       end
// 55:     end
// 56:
// 57:     sig {
// 58:       params(
// 59:         commands:        T::Array[T.any(Pathname, String)],
// 60:         shell_parameter: T.nilable(T.any(String, T::Array[String])),
// 61:         env:             T::Hash[String, String],
// 62:       ).returns(String)
// 63:     }
// 64:     def self.generate_completion_output(commands, shell_parameter, env)
// 65:       args = T.let(commands + Array(shell_parameter), T::Array[T.any(Pathname, String)])
// 66:       options = T.let({}, T::Hash[Symbol, Symbol])
// 67:       options[:err] = :err unless ENV["HOMEBREW_STDERR"]
// 68:       Utils.safe_popen_read(env, *args, **options)
// 69:     end
// 70:   end
// 71: end
