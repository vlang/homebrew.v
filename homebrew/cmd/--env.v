module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--env.rb`.
// The original source is retained below until every stub has a typed V body.
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
		if key in ['CC', 'CXX', 'LD'] && value != '' && brew_runtime.is_link(value) {
			line += ' => ${brew_runtime.real_path(value)}'
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

fn env_map_from_value(value brew_runtime.Value) map[string]string {
	mut environment := map[string]string{}
	for key, item in value.map_data {
		environment[key] = item.as_string()
	}
	return environment
}

fn env_shell_from_value(value brew_runtime.Value) ?EnvShell {
	if value.type_name == 'NilClass' || value.as_string() == '' {
		return none
	}
	return env_shell_from_path(value.as_string())
}

fn env_command_result_value(result EnvCommandResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'EnvCommandResult'
		repr: env_command_output(result)
		attributes: {
			'shell':                   if shell := result.shell { shell.str() } else { '' }
			'activated_extensions':    result.activated_extensions.str()
			'setup_build_environment': result.setup_build_environment.str()
		}
		map_data: {
			'lines':        brew_runtime.string_array_value(result.lines)
			'dependencies': brew_runtime.string_array_value(result.dependencies)
		}
	}
}

// Ruby method `self.command_name = "--env"` at line 13.
pub fn ruby_env_l13_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('--env')
}

// Ruby method `run` at line 32.
pub fn ruby_env_l32_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	environment := if args.len > 0 { env_map_from_value(args[0]) } else { map[string]string{} }
	request := EnvCommandRequest{
		environment: environment
		plain: args.len > 1 && (args[1].as_bool() or { false })
		requested_shell: if args.len > 2 && args[2].type_name != 'NilClass' {
			?string(args[2].as_string())} else {
			none}
		stdout_tty: args.len > 3 && (args[3].as_bool() or { false })
		parent_shell: if args.len > 4 { env_shell_from_value(args[4]) } else { none }
		preferred_shell: if args.len > 5 { env_shell_from_value(args[5]) } else { none }
		superenv: args.len > 6 && (args[6].as_bool() or { false })
		formulae: if args.len > 7 { args[7].as_string_array() or { [] } } else { [] }
	}
	return env_command_result_value(run_env_command(request))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "extend/ENV"
// 6: require "build_environment"
// 7: require "utils/shell"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Env < AbstractCommand
// 12:       sig { override.returns(String) }
// 13:       def self.command_name = "--env"
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Summarise Homebrew's build environment as a plain list.
// 18:
// 19:           If the command's output is sent through a pipe and no shell is specified,
// 20:           the list is formatted for export to `bash`(1) unless `--plain` is passed.
// 21:         EOS
// 22:         flag   "--shell=",
// 23:                description: "Generate a list of environment variables for the specified shell, " \
// 24:                             "or `--shell=auto` to detect the current shell."
// 25:         switch "--plain",
// 26:                description: "Generate plain output even when piped."
// 27:
// 28:         named_args :formula
// 29:       end
// 30:
// 31:       sig { override.void }
// 32:       def run
// 33:         ENV.activate_extensions!
// 34:         ENV.deps = args.named.to_formulae if superenv?(nil)
// 35:         ENV.setup_build_environment
// 36:
// 37:         shell = if args.plain?
// 38:           nil
// 39:         elsif args.shell.nil?
// 40:           :bash unless $stdout.tty?
// 41:         elsif args.shell == "auto"
// 42:           Utils::Shell.parent || Utils::Shell.preferred
// 43:         elsif args.shell
// 44:           Utils::Shell.from_path(T.must(args.shell))
// 45:         end
// 46:
// 47:         if shell.nil?
// 48:           BuildEnvironment.dump ENV.to_h
// 49:         else
// 50:           BuildEnvironment.keys(ENV.to_h).each do |key|
// 51:             puts Utils::Shell.export_value(key, ENV.fetch(key), shell)
// 52:           end
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57: end
