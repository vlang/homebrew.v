module cmd

import ruby

// Translated from Homebrew/brew `cmd/--env.rb`.
const env_build_keys = ['CC', 'CXX', 'LD', 'OBJC', 'OBJCXX', 'HOMEBREW_CC', 'CFLAGS', 'CXXFLAGS',
	'CPPFLAGS', 'LDFLAGS', 'SDKROOT', 'MAKEFLAGS', 'CMAKE_PREFIX_PATH', 'CMAKE_INCLUDE_PATH',
	'CMAKE_LIBRARY_PATH', 'CMAKE_FRAMEWORK_PATH', 'MACOSX_DEPLOYMENT_TARGET', 'PKG_CONFIG_PATH',
	'PKG_CONFIG_LIBDIR', 'HOMEBREW_DEBUG', 'HOMEBREW_MAKE_JOBS', 'HOMEBREW_VERBOSE', 'all_proxy',
	'ftp_proxy', 'http_proxy', 'https_proxy', 'no_proxy', 'HOMEBREW_SVN', 'HOMEBREW_GIT',
	'HOMEBREW_SDKROOT', 'MAKE', 'GIT', 'CPP', 'ACLOCAL_PATH', 'PATH', 'CPATH', 'LD_LIBRARY_PATH',
	'LD_RUN_PATH', 'LD_PRELOAD', 'LIBRARY_PATH']

pub enum EnvShell {
	bash
	csh
	fish
	ksh
	mksh
	pwsh
	rc
	sh
	tcsh
	zsh
}

pub struct EnvCommandRequest {
pub:
	environment     map[string]string
	plain           bool
	requested_shell ?string
	stdout_tty      bool
	parent_shell    ?EnvShell
	preferred_shell ?EnvShell
	superenv        bool
	formulae        []string
}

pub struct EnvCommandResult {
pub:
	shell                   ?EnvShell
	lines                   []string
	dependencies            []string
	activated_extensions    bool
	setup_build_environment bool
}

pub fn env_shell_from_path(path string) ?EnvShell {
	mut name := path.all_after_last('/')
	if dash := name.index('-') {
		name = name[..dash]
	}
	return match name {
		'bash' { .bash }
		'csh' { .csh }
		'fish' { .fish }
		'ksh' { .ksh }
		'mksh' { .mksh }
		'pwsh' { .pwsh }
		'rc' { .rc }
		'sh' { .sh }
		'tcsh' { .tcsh }
		'zsh' { .zsh }
		else { none }
	}
}

fn env_safe_shell_character(character u8) bool {
	return (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character in [
		`_`,
		`-`,
		`.`,
		`,`,
		`:`,
		`/`,
		`@`,
		`~`,
		`+`,
		`\n`,
	]
}

fn env_shell_quote(value string, csh bool) string {
	if value == '' {
		return "''"
	}
	mut quoted := ''
	for character in value.bytes() {
		if character == `\n` {
			quoted += if csh { "'\\\n'" } else { "'\n'" }
		} else if env_safe_shell_character(character) {
			quoted += character.ascii_str()
		} else {
			quoted += '\\${character.ascii_str()}'
		}
	}
	return quoted
}

pub fn env_export_value(key string, value string, shell EnvShell) string {
	return match shell {
		.bash, .ksh, .mksh, .sh, .zsh { 'export ${key}="${env_shell_quote(value, false)}"' }
		.fish { 'set -gx ${key} "${env_shell_quote(value, false)}"' }
		.rc { '${key}=(${env_shell_quote(value, false)})' }
		.csh, .tcsh { 'setenv ${key} ${env_shell_quote(value, true)};' }
		.pwsh { '' }
	}
}

fn env_selected_keys(environment map[string]string) []string {
	mut keys := env_build_keys.filter(it in environment)
	if environment['CC'] == environment['HOMEBREW_CC'] {
		for compiler in ['CC', 'CXX', 'OBJC', 'OBJCXX'] {
			index := keys.index(compiler)
			if index >= 0 {
				keys.delete(index)
			}
		}
	}
	return keys
}

fn env_plain_lines(environment map[string]string) []string {
	mut lines := []string{}
	for key in env_selected_keys(environment) {
		value := environment[key]
		mut line := '${key}: ${value}'
		if key in ['CC', 'CXX', 'LD'] && value != '' && ruby.is_link(value) {
			line += ' => ${ruby.real_path(value)}'
		}
		lines << line
	}
	return lines
}

pub fn run_env_command(request EnvCommandRequest) EnvCommandResult {
	selected_shell := if request.plain {
		?EnvShell(none)
	} else if requested := request.requested_shell {
		if requested == 'auto' {
			if parent := request.parent_shell { ?EnvShell(parent) } else { request.preferred_shell }
		} else {
			env_shell_from_path(requested)
		}
	} else if !request.stdout_tty {
		?EnvShell(EnvShell.bash)
	} else {
		none
	}
	mut lines := []string{}
	if shell := selected_shell {
		for key in env_selected_keys(request.environment) {
			lines << env_export_value(key, request.environment[key], shell)
		}
	} else {
		lines = env_plain_lines(request.environment)
	}
	return EnvCommandResult{
		shell: selected_shell
		lines: lines
		dependencies: if request.superenv { request.formulae.clone() } else { [] }
		activated_extensions: true
		setup_build_environment: true
	}
}

pub fn env_command_output(result EnvCommandResult) string {
	return if result.lines.len == 0 { '' } else { '${result.lines.join('\n')}\n' }
}

fn env_map_from_value(value ruby.Value) map[string]string {
	mut environment := map[string]string{}
	for key, item in value.map_data {
		environment[key] = item.as_string()
	}
	return environment
}

fn env_shell_from_value(value ruby.Value) ?EnvShell {
	if value.type_name == 'NilClass' || value.as_string() == '' {
		return none
	}
	return env_shell_from_path(value.as_string())
}

fn env_command_result_value(result EnvCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'EnvCommandResult'
		repr: env_command_output(result)
		attributes: {
			'shell':                   if shell := result.shell { shell.str() } else { '' }
			'activated_extensions':    result.activated_extensions.str()
			'setup_build_environment': result.setup_build_environment.str()
		}
		map_data: {
			'lines':        ruby.string_array_value(result.lines)
			'dependencies': ruby.string_array_value(result.dependencies)
		}
	}
}
