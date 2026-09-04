module utils

import ruby

// Translated from Homebrew/brew `utils/shell_completion.rb`.

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
		arguments: arguments
		environment: result_environment
	}
}

pub fn generate_completion_output(commands []string, parameter CompletionParameter) !string {
	if commands.len == 0 {
		return error('completion command must not be empty')
	}
	mut arguments := commands[1..].clone()
	arguments << parameter.arguments
	result := ruby.run_command_with_environment(commands[0], arguments, parameter.environment)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result.output
}
