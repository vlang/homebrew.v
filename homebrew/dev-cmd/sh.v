module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/sh.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 40.
pub fn ruby_sh_l40_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return sh_command_plan_value(run_sh_command(sh_input_from_value(args[0]).options))
}

// Ruby method `setup_ruby_environment!` at line 61.
pub fn ruby_sh_l61_d2_setup_ruby_environment(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return sh_environment_plan_value(setup_sh_ruby_environment(sh_input_from_value(args[0]).options))
}

// Ruby method `setup_build_environment!` at line 78.
pub fn ruby_sh_l78_d3_setup_build_environment(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return sh_environment_plan_value(setup_sh_build_environment(sh_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "extend/ENV"
// 6: require "formula"
// 7: require "utils/gem_setup"
// 8: require "utils/shell"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Sh < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Enter an interactive shell for Homebrew's build environment. Use years-battle-hardened
// 16:           build logic to help your `./configure && make && make install`
// 17:           and even your `gem install` succeed. Especially handy if you run Homebrew
// 18:           in an Xcode-only configuration since it adds tools like `make` to your `$PATH`
// 19:           which build systems would not find otherwise.
// 20:
// 21:           With `--ruby`, enter an interactive shell for Homebrew's Ruby environment.
// 22:           This sets up the correct Ruby paths, `$GEM_HOME` and bundle
// 23:           configuration used by Homebrew's development tools.
// 24:           The environment includes gems from the installed groups,
// 25:           making tools like RuboCop, Sorbet and RSpec available via `bundle exec`.
// 26:         EOS
// 27:         switch "-r", "--ruby",
// 28:                description: "Set up Homebrew's Ruby environment."
// 29:         flag   "--env=",
// 30:                description: "Use the standard `$PATH` instead of superenv's when `std` is passed."
// 31:         flag   "-c=", "--cmd=",
// 32:                description: "Execute commands in a non-interactive shell."
// 33:
// 34:         conflicts "--ruby", "--env="
// 35:
// 36:         named_args :file, max: 1
// 37:       end
// 38:
// 39:       sig { override.void }
// 40:       def run
// 41:         prompt, notice = if args.ruby?
// 42:           setup_ruby_environment!
// 43:         else
// 44:           setup_build_environment!
// 45:         end
// 46:
// 47:         preferred_path = Utils::Shell.preferred_path(default: "/bin/bash")
// 48:
// 49:         if args.cmd.present?
// 50:           safe_system(preferred_path, "-c", args.cmd)
// 51:         elsif args.named.present?
// 52:           safe_system(preferred_path, args.named.first)
// 53:         else
// 54:           system Utils::Shell.shell_with_prompt(prompt, preferred_path:, notice:)
// 55:         end
// 56:       end
// 57:
// 58:       private
// 59:
// 60:       sig { returns([String, T.nilable(String)]) }
// 61:       def setup_ruby_environment!
// 62:         Homebrew.install_bundler_gems!(setup_path: true)
// 63:
// 64:         notice = unless Homebrew::EnvConfig.no_env_hints?
// 65:           <<~EOS
// 66:             Your shell has been configured to use Homebrew's Ruby environment.
// 67:             This includes the correct Ruby version, GEM_HOME, and bundle configuration.
// 68:             Tools like RuboCop, Sorbet, and RSpec are available via `bundle exec`.
// 69:             Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 70:             When done, type `exit`.
// 71:           EOS
// 72:         end
// 73:
// 74:         ["brew ruby", notice]
// 75:       end
// 76:
// 77:       sig { returns([String, T.nilable(String)]) }
// 78:       def setup_build_environment!
// 79:         ENV.activate_extensions!(env: args.env)
// 80:
// 81:         if superenv?(args.env)
// 82:           ENV.deps = Formula.installed.select do |f|
// 83:             f.keg_only? && f.opt_prefix.directory?
// 84:           end
// 85:         end
// 86:         ENV.setup_build_environment
// 87:         if superenv?(args.env)
// 88:           # superenv stopped adding brew's bin but generally users will want it
// 89:           ENV["PATH"] = PATH.new(ENV.fetch("PATH")).insert(1, HOMEBREW_PREFIX/"bin").to_s
// 90:         end
// 91:
// 92:         ENV["VERBOSE"] = "1" if args.verbose?
// 93:
// 94:         notice = unless Homebrew::EnvConfig.no_env_hints?
// 95:           <<~EOS
// 96:             Your shell has been configured to use Homebrew's build environment;
// 97:             this should help you build stuff. Notably though, the system versions of
// 98:             gem and pip will ignore our configuration and insist on using the
// 99:             environment they were built under (mostly). Sadly, scons will also
// 100:             ignore our configuration.
// 101:             Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 102:             When done, type `exit`.
// 103:           EOS
// 104:         end
// 105:
// 106:         ["brew", notice]
// 107:       end
// 108:     end
// 109:   end
// 110: end
