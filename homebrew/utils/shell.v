module utils

import ruby
import os

// Translated from Homebrew/brew `utils/shell.rb`.

const shell_names = ['bash', 'csh', 'fish', 'ksh', 'mksh', 'pwsh', 'rc', 'sh', 'tcsh', 'zsh']

const shell_profile_map = {
	'bash': '~/.profile'
	'csh':  '~/.cshrc'
	'fish': '~/.config/fish/config.fish'
	'ksh':  '~/.kshrc'
	'mksh': '~/.kshrc'
	'pwsh': '~/.config/powershell/Microsoft.PowerShell_profile.ps1'
	'rc':   '~/.rcrc'
	'sh':   '~/.profile'
	'tcsh': '~/.tcshrc'
	'zsh':  '~/.zshrc'
}

pub struct ShellPromptOptions {
pub:
	preferred_path string
	notice         string
	home           string
	path           string
	temporary      string
	library_path   string
}

pub struct ShellPromptPlan {
pub:
	command string
	notice  string
}

pub fn shell_from_path(path string) ?string {
	mut shell_name := os.base(path)
	if shell_name.contains('-') {
		shell_name = shell_name.all_before('-')
	}
	return if shell_name in shell_names { shell_name } else { none }
}

pub fn shell_preferred_path(default_value string) string {
	return os.getenv_opt('SHELL') or { default_value }
}

pub fn shell_preferred() ?string {
	return shell_from_path(shell_preferred_path(''))
}

pub fn shell_parent() ?string {
	result := ruby.run_captured_command(['ps', '-p', os.getppid().str(), '-o', 'ucomm='], ruby.CapturedCommandOptions{ environment: ruby.environment() }) or { return none }
	if result.exit_code != 0 {
		return none
	}
	return shell_from_path(result.stdout.trim_space())
}

pub fn shell_export_value(key string, value string, shell string) ?string {
	return match shell {
		'bash', 'ksh', 'mksh', 'sh', 'zsh' { 'export ${key}="${shell_sh_quote(value)}"' }
		'fish' { 'set -gx ${key} "${shell_sh_quote(value)}"' }
		'rc' { '${key}=(${shell_sh_quote(value)})' }
		'csh', 'tcsh' { 'setenv ${key} ${shell_csh_quote(value)};' }
		else { none }
	}
}

pub fn shell_profile() string {
	return shell_profile_for(shell_preferred() or { '' }, os.home_dir(), os.getenv('HOMEBREW_ZDOTDIR'))
}

pub fn shell_profile_for(shell string, home string, zdotdir string) string {
	match shell {
		'bash' {
			bash_profile := os.join_path(home, '.bash_profile')
			if os.exists(bash_profile) {
				return bash_profile
			}
		}
		'pwsh' {
			pwsh_profile := os.join_path(home, '.config', 'powershell', 'Microsoft.PowerShell_profile.ps1')
			if os.exists(pwsh_profile) {
				return pwsh_profile
			}
		}
		'rc' {
			rc_profile := os.join_path(home, '.rcrc')
			if os.exists(rc_profile) {
				return rc_profile
			}
		}
		'zsh' {
			if zdotdir != '' {
				return os.join_path(zdotdir, '.zshrc')
			}
		}
		else {}
	}
	if shell == '' {
		return '~/.profile'
	}
	return shell_profile_map[shell] or { '~/.profile' }
}

pub fn shell_set_variable_in_profile(variable string, value string, shell string, profile string) ?string {
	return match shell {
		'', 'bash', 'ksh', 'mksh', 'sh', 'zsh' {
			"echo 'export ${variable}=${shell_sh_quote(value)}' >> ${profile}"
		}
		'pwsh' { "\$env:${variable}='${value}' >> ${profile}" }
		'rc' { "echo '${variable}=(${shell_sh_quote(value)})' >> ${profile}" }
		'csh', 'tcsh' { "echo 'setenv ${variable} ${shell_csh_quote(value)}' >> ${profile}" }
		'fish' { "echo 'set -gx ${variable} ${shell_sh_quote(value)}' >> ${profile}" }
		else { none }
	}
}

pub fn shell_prepend_path_in_profile(path string, shell string, profile string) ?string {
	return match shell {
		'', 'bash', 'ksh', 'mksh', 'sh', 'zsh' {
			'echo \'export PATH="${shell_sh_quote(path)}:\$PATH"\' >> ${profile}'
		}
		'pwsh' { '\$env:PATH = \'${path}\' + "\${env:PATH}" >> ${profile}' }
		'rc' { "echo 'path=(${shell_sh_quote(path)} \$path)' >> ${profile}" }
		'csh', 'tcsh' { "echo 'setenv PATH ${shell_csh_quote(path)}:\$PATH' >> ${profile}" }
		'fish' { 'fish_add_path ${shell_sh_quote(path)}' }
		else { none }
	}
}

pub fn shell_csh_quote(value string) string {
	if value == '' {
		return "''"
	}
	return shell_escape_unsafe(value).replace('\n', "'\\\n'")
}

pub fn shell_sh_quote(value string) string {
	if value == '' {
		return "''"
	}
	return shell_escape_unsafe(value).replace('\n', "'\n'")
}

pub fn shell_with_prompt(prompt_type string, options ShellPromptOptions) !string {
	plan := shell_prompt_plan(prompt_type, options)!
	if plan.notice != '' {
		println(plan.notice)
	}
	return plan.command
}

pub fn shell_prompt_plan(prompt_type string, options ShellPromptOptions) !ShellPromptPlan {
	preferred := shell_from_path(options.preferred_path) or { '' }
	path := if options.path != '' { options.path } else { os.getenv('PATH') }
	temporary := if options.temporary != '' { options.temporary } else { shell_homebrew_temp() }
	library_path := if options.library_path != '' {
		options.library_path
	} else {
		shell_homebrew_library_path()
	}
	home := if options.home != '' { options.home } else { os.home_dir() }
	command := match preferred {
		'zsh' {
			zdotdir := os.join_path(temporary, 'brew-zsh-prompt-${os.geteuid()}')
			os.mkdir_all(zdotdir)!
			os.chmod(zdotdir, 0o700)!
			source := os.join_path(library_path, 'utils', 'zsh', 'brew-sh-prompt-zshrc.zsh')
			os.cp(source, os.join_path(zdotdir, '.zshrc'))!
			for file in ['.zshenv', '.zcompdump', '.zsh_history', '.zsh_sessions'] {
				destination := os.join_path(zdotdir, file)
				if os.exists(destination) || os.is_link(destination) { os.rm(destination)! }
				os.symlink(os.join_path(home, file), destination)!
			}
			'BREW_PROMPT_PATH="${path}" BREW_PROMPT_TYPE="${prompt_type}" ZDOTDIR="${zdotdir}" ${options.preferred_path}'
		}
		'bash' {
			'BREW_PROMPT_PATH="${path}" BREW_PROMPT_TYPE="${prompt_type}" ${options.preferred_path} --rcfile "${os.join_path(library_path, 'utils', 'bash', 'brew-sh-prompt-bashrc.bash')}"'
		}
		else {
			'PS1="\\[\\033[1;32m\\]${prompt_type} \\[\\033[1;31m\\]\\w \\[\\033[1;34m\\]\$\\[\\033[0m\\] " ${options.preferred_path}'
		}
	}
	return ShellPromptPlan{
		command: command
		notice: options.notice
	}
}

fn shell_escape_unsafe(value string) string {
	mut output := []rune{}
	for character in value.runes() {
		if !shell_safe_character(character) && character != `\n` { output << `\\` }
		output << character
	}
	return output.string()
}

fn shell_safe_character(character rune) bool {
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

fn shell_homebrew_temp() string {
	value := os.getenv('HOMEBREW_TEMP')
	return if value != '' { value } else { os.temp_dir() }
}

fn shell_homebrew_library_path() string {
	value := os.getenv('HOMEBREW_LIBRARY_PATH')
	return if value != '' { value } else { os.join_path(os.getwd(), 'homebrew') }
}

fn shell_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
