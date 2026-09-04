module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/sh.rb`.

const sh_ruby_notice = "Your shell has been configured to use Homebrew's Ruby environment.\nThis includes the correct Ruby version, GEM_HOME, and bundle configuration.\nTools like RuboCop, Sorbet, and RSpec are available via `bundle exec`.\nHide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\nWhen done, type `exit`.\n"

const sh_build_notice = "Your shell has been configured to use Homebrew's build environment;\nthis should help you build stuff. Notably though, the system versions of\ngem and pip will ignore our configuration and insist on using the\nenvironment they were built under (mostly). Sadly, scons will also\nignore our configuration.\nHide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\nWhen done, type `exit`.\n"

pub struct ShInstalledFormula {
pub:
	name                    string
	keg_only                bool
	opt_prefix              string
	opt_prefix_is_directory bool
}

pub struct ShOptions {
pub:
	ruby                  bool
	env                   ?string
	cmd                   ?string
	named                 []string
	verbose               bool
	no_env_hints          bool
	preferred_shell       string
	superenv_bin          string
	installed_formulae    []ShInstalledFormula
	environment           map[string]string
	homebrew_prefix       string
	homebrew_library_path string
	homebrew_temp         string
	home                  string
}

pub struct ShEnvironmentPlan {
pub:
	prompt                  string
	notice                  ?string
	install_bundler_gems    bool
	setup_path              bool
	activated_extension     string
	dependencies            []string
	setup_build_environment bool
	environment             map[string]string
}

pub struct ShPromptLink {
pub:
	source      string
	destination string
}

pub struct ShPromptPlan {
pub:
	command            string
	notice             ?string
	shell              string
	zdotdir            string
	mode               int
	zshrc_source       string
	zshrc_destination  string
	home_configuration []ShPromptLink
}

pub struct ShCommandPlan {
pub:
	environment    ShEnvironmentPlan
	preferred_path string
	mode           string
	program        string
	arguments      []string
	safe           bool
	prompt         ShPromptPlan
}

@[heap]
pub struct ShInput {
pub:
	options ShOptions
}

pub fn sh_input_boundary(input &ShInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Sh::Input', '', {
		'sh_input_address': u64(voidptr(input)).str()
	})
}

fn sh_input_from_value(value ruby.Value) &ShInput {
	address := value.attributes['sh_input_address'] or { panic('invalid Sh input') }
	return unsafe { &ShInput(voidptr(address.u64())) }
}

fn sh_optional_string(value ?string) string {
	return value or { '' }
}

fn sh_is_superenv(environment ?string, superenv_bin string) bool {
	if selected := environment {
		if selected == 'std' {
			return false
		}
	}
	return superenv_bin != ''
}

fn sh_unique_path_with_insert(path string, index int, addition string) string {
	mut values := if path == '' { []string{} } else { path.split(os.path_delimiter) }
	insert_at := if index < values.len { index } else { values.len }
	values.insert(insert_at, addition)
	mut unique := []string{}
	for value in values {
		if value !in unique {
			unique << value
		}
	}
	return unique.join(os.path_delimiter)
}

fn sh_shell_name(path string) string {
	mut name := os.base(path)
	if name.contains('-') {
		name = name.all_before('-')
	}
	return if name in ['bash', 'csh', 'fish', 'ksh', 'mksh', 'pwsh', 'rc', 'sh', 'tcsh', 'zsh'] {
		name
	} else {
		''
	}
}

fn sh_preferred_path(options ShOptions) string {
	if options.preferred_shell != '' {
		return options.preferred_shell
	}
	if shell := options.environment['SHELL'] {
		return shell
	}
	return '/bin/bash'
}

fn sh_option_path(explicit string, environment map[string]string, name string, fallback string) string {
	if explicit != '' {
		return explicit
	}
	if value := environment[name] {
		return value
	}
	return fallback
}

pub fn setup_sh_ruby_environment(options ShOptions) ShEnvironmentPlan {
	return ShEnvironmentPlan{
		prompt: 'brew ruby'
		notice: if options.no_env_hints { none } else { sh_ruby_notice }
		install_bundler_gems: true
		setup_path: true
		environment: options.environment.clone()
	}
}

pub fn setup_sh_build_environment(options ShOptions) ShEnvironmentPlan {
	mut environment := options.environment.clone()
	superenv := sh_is_superenv(options.env, options.superenv_bin)
	mut dependencies := []string{}
	if superenv {
		dependencies = options.installed_formulae.filter(it.keg_only
			&& it.opt_prefix_is_directory).map(it.name)
		prefix := sh_option_path(options.homebrew_prefix, environment, 'HOMEBREW_PREFIX', '')
		environment['PATH'] = sh_unique_path_with_insert(environment['PATH'], 1, os.join_path(prefix, 'bin'))
	}
	if options.verbose {
		environment['VERBOSE'] = '1'
	}
	return ShEnvironmentPlan{
		prompt: 'brew'
		notice: if options.no_env_hints { none } else { sh_build_notice }
		activated_extension: if superenv { 'superenv' } else { 'stdenv' }
		dependencies: dependencies
		setup_build_environment: true
		environment: environment
	}
}

pub fn sh_prompt_plan(prompt_type string, preferred_path string, notice ?string,
	options ShOptions) ShPromptPlan {
	shell := sh_shell_name(preferred_path)
	path := options.environment['PATH']
	library_path := sh_option_path(options.homebrew_library_path, options.environment, 'HOMEBREW_LIBRARY_PATH', '')
	home := sh_option_path(options.home, options.environment, 'HOME', os.home_dir())
	temporary := sh_option_path(options.homebrew_temp, options.environment, 'HOMEBREW_TEMP', os.temp_dir())
	return match shell {
		'zsh' {
			zdotdir := os.join_path(temporary, 'brew-zsh-prompt-${os.geteuid()}')
			mut links := []ShPromptLink{}
			for file in ['.zshenv', '.zcompdump', '.zsh_history', '.zsh_sessions'] {
				links << ShPromptLink{
					source: os.join_path(home, file)
					destination: os.join_path(zdotdir, file)
				}
			}
			ShPromptPlan{
				command: 'BREW_PROMPT_PATH="${path}" BREW_PROMPT_TYPE="${prompt_type}" ZDOTDIR="${zdotdir}" ${preferred_path}'
				notice: notice
				shell: shell
				zdotdir: zdotdir
				mode: 0o700
				zshrc_source: os.join_path(library_path, 'utils', 'zsh', 'brew-sh-prompt-zshrc.zsh')
				zshrc_destination: os.join_path(zdotdir, '.zshrc')
				home_configuration: links
			}
		}
		'bash' {
			ShPromptPlan{
				command: 'BREW_PROMPT_PATH="${path}" BREW_PROMPT_TYPE="${prompt_type}" ${preferred_path} --rcfile "${os.join_path(library_path, 'utils', 'bash', 'brew-sh-prompt-bashrc.bash')}"'
				notice: notice
				shell: shell
			}
		}
		else {
			ShPromptPlan{
				command: 'PS1="\\[\\033[1;32m\\]${prompt_type} \\[\\033[1;31m\\]\\w \\[\\033[1;34m\\]\$\\[\\033[0m\\] " ${preferred_path}'
				notice: notice
				shell: shell
			}
		}
	}
}

pub fn run_sh_command(options ShOptions) ShCommandPlan {
	environment := if options.ruby {
		setup_sh_ruby_environment(options)
	} else {
		setup_sh_build_environment(options)
	}
	preferred_path := sh_preferred_path(options)
	if command := options.cmd {
		return ShCommandPlan{
			environment: environment
			preferred_path: preferred_path
			mode: 'command'
			program: preferred_path
			arguments: ['-c', command]
			safe: true
		}
	}
	if options.named.len > 0 {
		return ShCommandPlan{
			environment: environment
			preferred_path: preferred_path
			mode: 'file'
			program: preferred_path
			arguments: [options.named[0]]
			safe: true
		}
	}
	prompt := sh_prompt_plan(environment.prompt, preferred_path, environment.notice, ShOptions{
		...options
		environment: environment.environment
	})
	return ShCommandPlan{
		environment: environment
		preferred_path: preferred_path
		mode: 'interactive'
		program: prompt.command
		safe: false
		prompt: prompt
	}
}

fn sh_environment_plan_value(plan ShEnvironmentPlan) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in plan.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'prompt':                  ruby.string_value(plan.prompt)
		'notice':                  ruby.string_value(sh_optional_string(plan.notice))
		'install_bundler_gems':    ruby.bool_value(plan.install_bundler_gems)
		'setup_path':              ruby.bool_value(plan.setup_path)
		'activated_extension':     ruby.string_value(plan.activated_extension)
		'dependencies':            ruby.string_array_value(plan.dependencies)
		'setup_build_environment': ruby.bool_value(plan.setup_build_environment)
		'environment':             ruby.map_value(environment)
	})
}

fn sh_command_plan_value(plan ShCommandPlan) ruby.Value {
	return ruby.map_value({
		'environment':    sh_environment_plan_value(plan.environment)
		'preferred_path': ruby.string_value(plan.preferred_path)
		'mode':           ruby.object_value('Symbol', plan.mode)
		'program':        ruby.string_value(plan.program)
		'arguments':      ruby.string_array_value(plan.arguments)
		'safe':           ruby.bool_value(plan.safe)
		'prompt_command': ruby.string_value(plan.prompt.command)
		'prompt_notice':  ruby.string_value(sh_optional_string(plan.prompt.notice))
		'prompt_shell':   ruby.string_value(plan.prompt.shell)
		'prompt_zdotdir': ruby.string_value(plan.prompt.zdotdir)
	})
}
