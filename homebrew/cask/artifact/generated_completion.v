module artifact

import ruby
import homebrew.utils
import os
import time

// Translated from Homebrew/brew `cask/artifact/generated_completion.rb`.
pub const generated_completion_supported_shells = ['bash', 'zsh', 'fish', 'pwsh']

pub struct GeneratedCompletionOptions {
pub:
	base_name              string
	base_name_set          bool
	shell_parameter_format string
	shells                 []string
	shells_set             bool
	prefix                 string
}

pub struct GeneratedCompletionInvocation {
pub:
	shell       string
	commands    []string
	parameter   utils.CompletionParameter
	output_path string
}

pub struct GeneratedCompletionArtifact {
pub:
	cask_token             string
	staged_path            string
	prefix                 string
	commands               []string
	base_name              string
	base_name_set          bool
	shell_parameter_format string
	shells                 []string
pub mut:
	warnings               []string
	last_completions       []GeneratedCompletionInvocation
	sandbox_used           bool
	sandbox_runs           int
	sandbox_calls          []string
	sandbox_home           string
	network_access_allowed bool
	allowed_write_paths    []string
	resolved_base_name     string
	base_name_resolved     bool
}

fn generated_completion_prefix(configured string) string {
	if configured != '' {
		return configured
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { '/opt/homebrew' } else { prefix }
}

fn normalize_generated_completion_shell(shell string) string {
	return shell.trim_left(':')
}

pub fn initialize_generated_completion(cask_token string, staged_path string, commands []string,
	options GeneratedCompletionOptions) GeneratedCompletionArtifact {
	return GeneratedCompletionArtifact{
		cask_token: cask_token
		staged_path: staged_path
		prefix: generated_completion_prefix(options.prefix)
		commands: commands.clone()
		base_name: options.base_name
		base_name_set: options.base_name_set
		shell_parameter_format: options.shell_parameter_format.trim_left(':')
		shells: options.shells.map(normalize_generated_completion_shell(it))
	}
}

pub fn new_generated_completion(cask_token string, staged_path string, commands []string,
	options GeneratedCompletionOptions) !GeneratedCompletionArtifact {
	if commands.len == 0 {
		return error("'generate_completions_from_executable' requires at least one command")
	}
	resolved_shells := if options.shells_set {
		options.shells.map(normalize_generated_completion_shell(it))
	} else {
		utils.default_completion_shells(options.shell_parameter_format)
	}
	unsupported := resolved_shells.filter(it !in generated_completion_supported_shells)
	if unsupported.len > 0 {
		return error("'generate_completions_from_executable' does not support shell(s): ${unsupported.join(', ')}")
	}
	return initialize_generated_completion(cask_token, staged_path, commands, GeneratedCompletionOptions{
		...options
		shells: resolved_shells
		shells_set: true
	})
}

fn (artifact GeneratedCompletionArtifact) staged_path_join_executable(command string) string {
	mut path := command
	if path.starts_with('~') {
		path = os.expand_tilde_to_home(path)
	}
	absolute_path := if os.is_abs_path(path) {
		path
	} else {
		os.join_path(artifact.staged_path, path)
	}
	if os.exists(absolute_path) {
		if !os.is_executable(absolute_path) {
			os.chmod(absolute_path, 0o755) or {}
		}
		return absolute_path
	}
	return path
}

pub fn (mut artifact GeneratedCompletionArtifact) resolve_base_name() string {
	if artifact.base_name_resolved {
		return artifact.resolved_base_name
	}
	executable := artifact.staged_path_join_executable(artifact.commands[0])
	mut name := if artifact.base_name_set { artifact.base_name } else { os.base(executable) }
	if name == '' || name == '.' {
		name = artifact.cask_token
	}
	artifact.resolved_base_name = name
	artifact.base_name_resolved = true
	return name
}

pub fn (mut artifact GeneratedCompletionArtifact) summarize() string {
	return '${artifact.commands.join(' ')} (base_name: ${artifact.resolve_base_name()}, shells: ${artifact.shells.join(', ')})'
}

pub fn (mut artifact GeneratedCompletionArtifact) completion_path(shell string) !string {
	name := artifact.resolve_base_name()
	return match normalize_generated_completion_shell(shell) {
		'bash' {
			resolve_bash_completion_target(name, os.join_path(artifact.prefix, 'etc/bash_completion.d'))
		}
		'zsh' {
			resolve_zsh_completion_target(name, os.join_path(artifact.prefix, 'share/zsh/site-functions'))
		}
		'fish' {
			resolve_fish_completion_target(name, os.join_path(artifact.prefix, 'share/fish/vendor_completions.d'))
		}
		'pwsh' { os.join_path(artifact.prefix, 'share/pwsh/completions', '_${name}.ps1') }
		else {
			return error('unsupported shell: ${shell}')
		}
	}
}

fn generated_completion_unique_strings(values []string) []string {
	mut unique := []string{cap: values.len}
	for value in values {
		if value !in unique {
			unique << value
		}
	}
	return unique
}

fn (mut artifact GeneratedCompletionArtifact) completion_invocations(home string) ![]GeneratedCompletionInvocation {
	executable := artifact.staged_path_join_executable(artifact.commands[0])
	mut commands := [executable]
	if artifact.commands.len > 1 {
		commands << artifact.commands[1..]
	}
	mut completions := []GeneratedCompletionInvocation{cap: artifact.shells.len}
	for shell in artifact.shells {
		mut environment := {
			'SHELL': shell
		}
		if home != '' {
			environment['HOME'] = home
		}
		completions << GeneratedCompletionInvocation{
			shell: shell
			commands: commands.clone()
			parameter: utils.completion_shell_parameter(artifact.shell_parameter_format, shell, executable, environment)
			output_path: artifact.completion_path(shell)!
		}
	}
	return completions
}

fn write_generated_completion(completion GeneratedCompletionInvocation) ! {
	os.mkdir_all(os.dir(completion.output_path))!
	output := utils.generate_completion_output(completion.commands, completion.parameter)!
	os.write_file(completion.output_path, output)!
}

pub fn (mut artifact GeneratedCompletionArtifact) write_completion(completion GeneratedCompletionInvocation,
	executable string) {
	write_generated_completion(completion) or {
		message := 'Failed to generate ${completion.shell} completions from ${executable}: ${err.msg()}'
		artifact.warnings << message
		eprintln('Warning: ${message}')
	}
}

fn (mut artifact GeneratedCompletionArtifact) run_completions(completions []GeneratedCompletionInvocation,
	executable string) {
	for completion in completions {
		artifact.write_completion(completion, executable)
	}
}

pub fn (mut artifact GeneratedCompletionArtifact) install_phase(sandboxed bool) {
	artifact.warnings = []
	artifact.sandbox_used = sandboxed
	artifact.sandbox_calls = []
	artifact.allowed_write_paths = []
	artifact.sandbox_home = ''
	artifact.network_access_allowed = false
	executable := artifact.staged_path_join_executable(artifact.commands[0])
	if !sandboxed {
		completions := artifact.completion_invocations('') or {
			artifact.warnings << err.msg()
			eprintln('Warning: ${err.msg()}')
			return
		}
		artifact.last_completions = completions.clone()
		artifact.run_completions(completions, executable)
		return
	}

	temporary_path := os.join_path(os.temp_dir(), 'homebrew-cask-sandbox-${os.getpid()}-${time.now().unix_micro()}')
	home := os.join_path(temporary_path, 'home')
	os.mkdir_all(home) or {
		artifact.warnings << err.msg()
		eprintln('Warning: ${err.msg()}')
		return
	}
	artifact.sandbox_home = home
	artifact.sandbox_runs++
	artifact.sandbox_calls << 'add_install_hook_rules'
	defer {
		os.rmdir_all(temporary_path) or {}
	}
	completions := artifact.completion_invocations(home) or {
		artifact.warnings << err.msg()
		eprintln('Warning: ${err.msg()}')
		return
	}
	artifact.last_completions = completions.clone()
	artifact.allowed_write_paths = generated_completion_unique_strings(completions.map(os.dir(it.output_path)))
	artifact.sandbox_calls << 'run'
	artifact.run_completions(completions, executable)
}

pub fn (mut artifact GeneratedCompletionArtifact) uninstall_phase() {
	for shell in artifact.shells {
		path := artifact.completion_path(shell) or {
			message := 'Failed to remove ${shell} generated completions: ${err.msg()}'
			artifact.warnings << message
			eprintln('Warning: ${message}')
			continue
		}
		if !os.exists(path) && !os.is_link(path) {
			continue
		}
		os.rm(path) or {
			message := 'Failed to remove ${shell} generated completions: ${err.msg()}'
			artifact.warnings << message
			eprintln('Warning: ${message}')
		}
	}
}
