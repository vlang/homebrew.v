module utils

import brew_runtime
import os

// Translated from Homebrew/brew `utils/shell.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `from_path(path)` at line 15.
pub fn ruby_shell_l15_d1_from_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Utils::Shell.from_path requires a path') }
	if shell := shell_from_path(args[0].as_string()) {
		return brew_runtime.object_value('Symbol', shell)
	}
	return shell_nil_value()
}

// Ruby method `preferred_path(default: "")` at line 24.
pub fn ruby_shell_l24_d2_preferred_path(args ...brew_runtime.Value) brew_runtime.Value {
	default_value := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_value(shell_preferred_path(default_value))
}

// Ruby method `preferred` at line 29.
pub fn ruby_shell_l29_d3_preferred(args ...brew_runtime.Value) brew_runtime.Value {
	if shell := shell_preferred() {
		return brew_runtime.object_value('Symbol', shell)
	}
	return shell_nil_value()
}

// Ruby method `parent` at line 34.
pub fn ruby_shell_l34_d4_parent(args ...brew_runtime.Value) brew_runtime.Value {
	if shell := shell_parent() {
		return brew_runtime.object_value('Symbol', shell)
	}
	return shell_nil_value()
}

// Ruby method `export_value(key, value, shell = preferred)` at line 40.
pub fn ruby_shell_l40_d5_export_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Utils::Shell.export_value requires key and value') }
	shell := if args.len > 2 {
		args[2].as_string().trim_left(':')
	} else {
		shell_preferred() or { '' }
	}
	if exported := shell_export_value(args[0].as_string(), args[1].as_string(), shell) {
		return brew_runtime.string_value(exported)
	}
	return shell_nil_value()
}

// Ruby method `profile` at line 58.
pub fn ruby_shell_l58_d6_profile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_profile())
}

// Ruby method `set_variable_in_profile(variable, value)` at line 80.
pub fn ruby_shell_l80_d7_set_variable_in_profile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Utils::Shell.set_variable_in_profile requires variable and value') }
	if command := shell_set_variable_in_profile(args[0].as_string(), args[1].as_string(), shell_preferred() or { '' }, shell_profile()) {
		return brew_runtime.string_value(command)
	}
	return shell_nil_value()
}

// Ruby method `prepend_path_in_profile(path)` at line 96.
pub fn ruby_shell_l96_d8_prepend_path_in_profile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Utils::Shell.prepend_path_in_profile requires a path') }
	if command := shell_prepend_path_in_profile(args[0].as_string(), shell_preferred() or { '' }, shell_profile()) {
		return brew_runtime.string_value(command)
	}
	return shell_nil_value()
}

// Ruby method `csh_quote(str)` at line 130.
pub fn ruby_shell_l130_d9_csh_quote(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Utils::Shell.csh_quote requires a value') }
	return brew_runtime.string_value(shell_csh_quote(args[0].as_string()))
}

// Ruby method `sh_quote(str)` at line 144.
pub fn ruby_shell_l144_d10_sh_quote(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Utils::Shell.sh_quote requires a value') }
	return brew_runtime.string_value(shell_sh_quote(args[0].as_string()))
}

// Ruby method `shell_with_prompt(type, preferred_path:, notice:, home: Dir.home)` at line 157.
pub fn ruby_shell_l157_d11_shell_with_prompt(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Utils::Shell.shell_with_prompt requires type and preferred_path') }
	notice := if args.len > 2 { args[2].as_string() } else { '' }
	home := if args.len > 3 { args[3].as_string() } else { os.home_dir() }
	command := shell_with_prompt(args[0].as_string(), ShellPromptOptions{
		preferred_path: args[1].as_string()
		notice: notice
		home: home
	}) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.string_value(command)
}

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
	result := brew_runtime.run_captured_command(['ps', '-p', os.getppid().str(), '-o', 'ucomm='], brew_runtime.CapturedCommandOptions{ environment: brew_runtime.environment() }) or { return none }
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

fn shell_nil_value() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   module Shell
// 6:     extend T::Helpers
// 7:
// 8:     requires_ancestor { Kernel }
// 9:
// 10:     module_function
// 11:
// 12:     # Take a path and heuristically convert it to a shell name,
// 13:     # return `nil` if there's no match.
// 14:     sig { params(path: String).returns(T.nilable(Symbol)) }
// 15:     def from_path(path)
// 16:       # we only care about the basename
// 17:       shell_name = File.basename(path)
// 18:       # handle possible version suffix like `zsh-5.2`
// 19:       shell_name.sub!(/-.*\z/m, "")
// 20:       shell_name.to_sym if %w[bash csh fish ksh mksh pwsh rc sh tcsh zsh].include?(shell_name)
// 21:     end
// 22:
// 23:     sig { params(default: String).returns(String) }
// 24:     def preferred_path(default: "")
// 25:       ENV.fetch("SHELL", default)
// 26:     end
// 27:
// 28:     sig { returns(T.nilable(Symbol)) }
// 29:     def preferred
// 30:       from_path(preferred_path)
// 31:     end
// 32:
// 33:     sig { returns(T.nilable(Symbol)) }
// 34:     def parent
// 35:       from_path(`ps -p #{Process.ppid} -o ucomm=`.strip)
// 36:     end
// 37:
// 38:     # Quote values. Quoting keys is overkill.
// 39:     sig { params(key: String, value: String, shell: T.nilable(Symbol)).returns(T.nilable(String)) }
// 40:     def export_value(key, value, shell = preferred)
// 41:       case shell
// 42:       when :bash, :ksh, :mksh, :sh, :zsh
// 43:         "export #{key}=\"#{sh_quote(value)}\""
// 44:       when :fish
// 45:         # fish quoting is mostly Bourne compatible except that
// 46:         # a single quote can be included in a single-quoted string via \'
// 47:         # and a literal \ can be included via \\
// 48:         "set -gx #{key} \"#{sh_quote(value)}\""
// 49:       when :rc
// 50:         "#{key}=(#{sh_quote(value)})"
// 51:       when :csh, :tcsh
// 52:         "setenv #{key} #{csh_quote(value)};"
// 53:       end
// 54:     end
// 55:
// 56:     # Return the shell profile file based on user's preferred shell.
// 57:     sig { returns(String) }
// 58:     def profile
// 59:       case preferred
// 60:       when :bash
// 61:         bash_profile = "#{Dir.home}/.bash_profile"
// 62:         return bash_profile if File.exist? bash_profile
// 63:       when :pwsh
// 64:         pwsh_profile = "#{Dir.home}/.config/powershell/Microsoft.PowerShell_profile.ps1"
// 65:         return pwsh_profile if File.exist? pwsh_profile
// 66:       when :rc
// 67:         rc_profile = "#{Dir.home}/.rcrc"
// 68:         return rc_profile if File.exist? rc_profile
// 69:       when :zsh
// 70:         return "#{ENV["HOMEBREW_ZDOTDIR"]}/.zshrc" if ENV["HOMEBREW_ZDOTDIR"].present?
// 71:       end
// 72:
// 73:       shell = preferred
// 74:       return "~/.profile" if shell.nil?
// 75:
// 76:       SHELL_PROFILE_MAP.fetch(shell, "~/.profile")
// 77:     end
// 78:
// 79:     sig { params(variable: String, value: String).returns(T.nilable(String)) }
// 80:     def set_variable_in_profile(variable, value)
// 81:       case preferred
// 82:       when :bash, :ksh, :mksh, :sh, :zsh, nil
// 83:         "echo 'export #{variable}=#{sh_quote(value)}' >> #{profile}"
// 84:       when :pwsh
// 85:         "$env:#{variable}='#{value}' >> #{profile}"
// 86:       when :rc
// 87:         "echo '#{variable}=(#{sh_quote(value)})' >> #{profile}"
// 88:       when :csh, :tcsh
// 89:         "echo 'setenv #{variable} #{csh_quote(value)}' >> #{profile}"
// 90:       when :fish
// 91:         "echo 'set -gx #{variable} #{sh_quote(value)}' >> #{profile}"
// 92:       end
// 93:     end
// 94:
// 95:     sig { params(path: String).returns(T.nilable(String)) }
// 96:     def prepend_path_in_profile(path)
// 97:       case preferred
// 98:       when :bash, :ksh, :mksh, :sh, :zsh, nil
// 99:         "echo 'export PATH=\"#{sh_quote(path)}:$PATH\"' >> #{profile}"
// 100:       when :pwsh
// 101:         "$env:PATH = '#{path}' + \":${env:PATH}\" >> #{profile}"
// 102:       when :rc
// 103:         "echo 'path=(#{sh_quote(path)} $path)' >> #{profile}"
// 104:       when :csh, :tcsh
// 105:         "echo 'setenv PATH #{csh_quote(path)}:$PATH' >> #{profile}"
// 106:       when :fish
// 107:         "fish_add_path #{sh_quote(path)}"
// 108:       end
// 109:     end
// 110:
// 111:     SHELL_PROFILE_MAP = T.let(
// 112:       {
// 113:         bash: "~/.profile",
// 114:         csh:  "~/.cshrc",
// 115:         fish: "~/.config/fish/config.fish",
// 116:         ksh:  "~/.kshrc",
// 117:         mksh: "~/.kshrc",
// 118:         pwsh: "~/.config/powershell/Microsoft.PowerShell_profile.ps1",
// 119:         rc:   "~/.rcrc",
// 120:         sh:   "~/.profile",
// 121:         tcsh: "~/.tcshrc",
// 122:         zsh:  "~/.zshrc",
// 123:       }.freeze,
// 124:       T::Hash[Symbol, String],
// 125:     )
// 126:
// 127:     UNSAFE_SHELL_CHAR = %r{([^A-Za-z0-9_\-.,:/@~+\n])}
// 128:
// 129:     sig { params(str: String).returns(String) }
// 130:     def csh_quote(str)
// 131:       # Ruby's implementation of `shell_escape`.
// 132:       str = str.to_s
// 133:       return "''" if str.empty?
// 134:
// 135:       str = str.dup
// 136:       # Anything that isn't a known safe character is padded.
// 137:       str.gsub!(UNSAFE_SHELL_CHAR, '\\\\\\1')
// 138:       # Newlines have to be specially quoted in `csh`.
// 139:       str.gsub!("\n", "'\\\n'")
// 140:       str
// 141:     end
// 142:
// 143:     sig { params(str: String).returns(String) }
// 144:     def sh_quote(str)
// 145:       # Ruby's implementation of `shell_escape`.
// 146:       str = str.to_s
// 147:       return "''" if str.empty?
// 148:
// 149:       str = str.dup
// 150:       # Anything that isn't a known safe character is padded.
// 151:       str.gsub!(UNSAFE_SHELL_CHAR, '\\\\\\1')
// 152:       str.gsub!("\n", "'\n'")
// 153:       str
// 154:     end
// 155:
// 156:     sig { params(type: String, preferred_path: String, notice: T.nilable(String), home: String).returns(String) }
// 157:     def shell_with_prompt(type, preferred_path:, notice:, home: Dir.home)
// 158:       preferred = from_path(preferred_path)
// 159:       path = ENV.fetch("PATH")
// 160:       subshell = case preferred
// 161:       when :zsh
// 162:         zdotdir = Pathname.new(HOMEBREW_TEMP/"brew-zsh-prompt-#{Process.euid}")
// 163:         zdotdir.mkpath
// 164:         FileUtils.chmod_R(0700, zdotdir)
// 165:         FileUtils.cp(HOMEBREW_LIBRARY_PATH/"utils/zsh/brew-sh-prompt-zshrc.zsh", zdotdir/".zshrc")
// 166:         %w[.zshenv .zcompdump .zsh_history .zsh_sessions].each do |file|
// 167:           FileUtils.ln_sf("#{home}/#{file}", zdotdir/file)
// 168:         end
// 169:         <<~ZSH.strip
// 170:           BREW_PROMPT_PATH="#{path}" BREW_PROMPT_TYPE="#{type}" ZDOTDIR="#{zdotdir}" #{preferred_path}
// 171:         ZSH
// 172:       when :bash
// 173:         <<~BASH.strip
// 174:           BREW_PROMPT_PATH="#{path}" BREW_PROMPT_TYPE="#{type}" #{preferred_path} --rcfile "#{HOMEBREW_LIBRARY_PATH}/utils/bash/brew-sh-prompt-bashrc.bash"
// 175:         BASH
// 176:       else
// 177:         "PS1=\"\\[\\033[1;32m\\]#{type} \\[\\033[1;31m\\]\\w \\[\\033[1;34m\\]$\\[\\033[0m\\] \" #{preferred_path}"
// 178:       end
// 179:
// 180:       puts notice if notice.present?
// 181:       $stdout.flush
// 182:
// 183:       subshell
// 184:     end
// 185:   end
// 186: end
