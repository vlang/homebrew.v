module cmd

// Translated from Homebrew/brew `cmd/version-install.rb`.
// The original source is retained below until every stub has a typed V body.
pub const version_install_default_tap_repository = 'versions'

pub enum VersionInstallOutcome {
	already_installed
	installed
}

pub struct VersionInstallFormula {
pub:
	full_name string
	name      string
	version   string
}

pub struct VersionInstallTap {
pub:
	name          string
	installed     bool
	formula_names []string
}

pub struct VersionInstallRuntime {
pub mut:
	commands    [][]string
	messages    []string
	warnings    []string
	dev_cmd_run bool
}

pub type VersionInstallFormulaResolver = fn(reference string, formulae map[string]VersionInstallFormula) !VersionInstallFormula

pub type VersionInstallTapFetcher = fn(name string, taps map[string]VersionInstallTap) !VersionInstallTap

pub type VersionInstallCommandRunner = fn(mut runtime VersionInstallRuntime, command []string) !

pub fn resolve_version_install_formula(reference string,
	formulae map[string]VersionInstallFormula) !VersionInstallFormula {
	return formulae[reference] or { return error('Formula unavailable: ${reference}') }
}

pub fn fetch_version_install_tap(name string,
	taps map[string]VersionInstallTap) !VersionInstallTap {
	return taps[name] or {
		VersionInstallTap{
			name: name
		}
	}
}

pub fn record_version_install_command(mut runtime VersionInstallRuntime, command []string) ! {
	runtime.commands << command.clone()
}

pub struct VersionInstallConfig {
pub:
	installed_formula_names []string
	installed_taps          []VersionInstallTap
	formulae                map[string]VersionInstallFormula
	fetched_taps            map[string]VersionInstallTap
	github_api_enabled      bool
	github_credentials      bool
	github_username         string
	local_username          string
	environment_user        string
	brew_file               string = 'brew'
	formula_resolver        VersionInstallFormulaResolver = resolve_version_install_formula
	tap_fetcher             VersionInstallTapFetcher = fetch_version_install_tap
	command_runner          VersionInstallCommandRunner = record_version_install_command
}

pub struct VersionInstallResult {
pub:
	outcome            VersionInstallOutcome
	formula_input      string
	version_input      string
	normalized_version string
	versioned_name     string
	versioned_ref      string
	install_target     string
	commands           [][]string
	messages           []string
	warnings           []string
	dev_cmd_run        bool
}

pub fn normalize_version_install_version(version string) string {
	if version == '' {
		return ''
	}
	mut start := 0
	for start < version.len && !version[start].is_digit() {
		start++
	}
	mut end := version.len
	for end > start && !version[end - 1].is_digit() {
		end--
	}
	if start == end {
		return '.'
	}
	mut normalized := ''
	mut in_separator := false
	for character in version[start..end] {
		if character.is_digit() {
			normalized += character.ascii_str()
			in_separator = false
		} else if !in_separator {
			normalized += '.'
			in_separator = true
		}
	}
	return normalized
}

fn version_install_tap_and_formula(reference string) (?string, string) {
	parts := reference.split('/')
	if parts.len < 3 {
		return none, reference
	}
	return '${parts[0]}/${parts[1]}', parts[2..].join('/')
}

fn version_install_result(outcome VersionInstallOutcome, formula_input string,
	version_input string, normalized_version string, versioned_name string, versioned_ref string,
	install_target string, runtime VersionInstallRuntime) VersionInstallResult {
	return VersionInstallResult{
		outcome: outcome
		formula_input: formula_input
		version_input: version_input
		normalized_version: normalized_version
		versioned_name: versioned_name
		versioned_ref: versioned_ref
		install_target: install_target
		commands: runtime.commands.clone()
		messages: runtime.messages.clone()
		warnings: runtime.warnings.clone()
		dev_cmd_run: runtime.dev_cmd_run
	}
}

pub fn run_version_install_command(arguments []string, config VersionInstallConfig,
	mut runtime VersionInstallRuntime) !VersionInstallResult {
	if arguments.len == 0 || arguments.len > 2 {
		return error('`version-install` requires one or two arguments.')
	}
	mut formula_input := arguments[0]
	has_version_input := arguments.len > 1
	mut version_input := if arguments.len > 1 { arguments[1] } else { '' }
	mut versioned_ref := ''
	if !has_version_input || formula_input.contains('@') {
		if !formula_input.contains('@') {
			return error('Specify a version with <formula> <version> or <formula>@<version>.')
		}
		separator := formula_input.last_index('@') or { -1 }
		formula_base := if separator > 0 { formula_input[..separator] } else { '' }
		version_from_input := if separator >= 0 && separator + 1 < formula_input.len {
			formula_input[separator + 1..]
		} else {
			''
		}
		if formula_base == '' || version_from_input == '' {
			return error('Invalid formula reference: ${formula_input}')
		}
		if !has_version_input {
			version_input = version_from_input
		} else if version_from_input != version_input {
			return error('Version mismatch: ${formula_input} != ${version_input}')
		}
		versioned_ref = formula_input
		formula_input = formula_base
	}
	tap, raw_base_name := version_install_tap_and_formula(formula_input)
	mut base_name := raw_base_name.to_lower()
	if at := base_name.index('@') {
		base_name = base_name[..at]
	}
	normalized_version := normalize_version_install_version(version_input)
	versioned_name := '${base_name}@${normalized_version}'
	if versioned_ref == '' {
		versioned_ref = if tap_name := tap {
			'${tap_name}/${versioned_name}'
		} else {
			versioned_name
		}
	}
	if versioned_name in config.installed_formula_names {
		runtime.messages << '${versioned_name} is already installed'
		return version_install_result(.already_installed, formula_input, version_input, normalized_version, versioned_name, versioned_ref, '', runtime)
	}
	mut installed_taps := config.installed_taps.clone()
	installed_taps.sort_with_compare(fn (left &VersionInstallTap, right &VersionInstallTap) int {
		return left.name.compare(right.name)
	})
	mut install_target := ''
	for installed_tap in installed_taps {
		if versioned_name in installed_tap.formula_names {
			install_target = '${installed_tap.name}/${versioned_name}'
			break
		}
	}
	versioned_formula := config.formula_resolver(versioned_ref, config.formulae) or {
		VersionInstallFormula{}
	}
	if install_target == '' {
		if versioned_formula.full_name != '' {
			install_target = versioned_formula.full_name
		} else {
			current_formula := config.formula_resolver(formula_input, config.formulae) or {
				VersionInstallFormula{}
			}
			if current_formula.full_name != '' && current_formula.version == version_input {
				if current_formula.name in config.installed_formula_names {
					runtime.messages << '${current_formula.full_name} is already installed'
					return version_install_result(.already_installed, formula_input, version_input, normalized_version, versioned_name, versioned_ref, '', runtime)
				}
				install_target = current_formula.full_name
			}
		}
	}
	runtime.dev_cmd_run = true
	brew_file := if config.brew_file == '' { 'brew' } else { config.brew_file }
	if install_target == '' {
		mut username := ''
		if config.github_api_enabled && config.github_credentials {
			username = config.github_username
		}
		if username == '' {
			username = config.local_username
		}
		if username == '' {
			username = config.environment_user
		}
		if username == '' {
			return error('Unable to determine a username for tap creation.')
		}
		requested_tap_name := '${username}/homebrew-${version_install_default_tap_repository}'
		tap_to_use := config.tap_fetcher(requested_tap_name, config.fetched_taps)!
		tap_name := if tap_to_use.name == '' { requested_tap_name } else { tap_to_use.name }
		if !tap_to_use.installed {
			runtime.messages << 'Creating ${tap_name} tap for storing versioned formulae...'
			config.command_runner(mut runtime, [brew_file, 'tap-new', '--no-git', tap_name])!
		}
		runtime.messages << 'Extracting ${formula_input}@${version_input} into ${tap_name}...'
		config.command_runner(mut runtime, [brew_file, 'extract', formula_input, tap_name,
			'--version=${version_input}'])!
		install_target = '${tap_name}/${versioned_name}'
		runtime.warnings << 'You are responsible for maintaining this ${install_target}!'
		runtime.warnings << 'It will not receive any bugfix/security updates.'
	}
	runtime.messages << 'Installing ${install_target}...'
	config.command_runner(mut runtime, [brew_file, 'install', install_target])!
	return version_install_result(.installed, formula_input, version_input, normalized_version, versioned_name, versioned_ref, install_target, runtime)
}

// Ruby method `run` at line 29.
pub fn ruby_version_install_l29_d1_run(arguments []string,
	config VersionInstallConfig) !VersionInstallResult {
	mut runtime := VersionInstallRuntime{}
	return run_version_install_command(arguments, config, mut runtime)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "formulary"
// 7: require "tap"
// 8: require "utils/github"
// 9: require "utils/user"
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class VersionInstall < AbstractCommand
// 14:       DEFAULT_TAP_REPOSITORY = "versions"
// 15:       private_constant :DEFAULT_TAP_REPOSITORY
// 16:
// 17:       cmd_args do
// 18:         usage_banner "`version-install` <formula>[@<version>] [<version>]"
// 19:         description <<~EOS
// 20:           Extract a specific <version> of <formula> into a personal tap and install it.
// 21:           The default tap is <user>/#{DEFAULT_TAP_REPOSITORY}.
// 22:           <user> uses the GitHub username if available and the local username otherwise.
// 23:         EOS
// 24:
// 25:         named_args [:formula, :version], min: 1, max: 2
// 26:       end
// 27:
// 28:       sig { override.void }
// 29:       def run
// 30:         formula_input = args.named.fetch(0)
// 31:         version_input = args.named[1]
// 32:
// 33:         if version_input.nil? || formula_input.include?("@")
// 34:           unless formula_input.include?("@")
// 35:             raise UsageError, "Specify a version with <formula> <version> or <formula>@<version>."
// 36:           end
// 37:
// 38:           formula_base, _, version_from_input = formula_input.rpartition("@")
// 39:           odie "Invalid formula reference: #{formula_input}" if formula_base.empty? || version_from_input.empty?
// 40:
// 41:           version_input ||= version_from_input
// 42:           odie "Version mismatch: #{formula_input} != #{version_input}" if version_from_input != version_input
// 43:
// 44:           versioned_ref = formula_input
// 45:           formula_input = formula_base
// 46:         end
// 47:
// 48:         tap_with_name = Tap.with_formula_name(formula_input)
// 49:         tap, base_name = tap_with_name || [nil, formula_input]
// 50:         base_name = base_name.downcase
// 51:                              .sub(/\b@(.*)\z\b/i, "")
// 52:         normalized_version = version_input.to_s
// 53:                                           .sub(/\D*(.+?)\D*$/, "\\1")
// 54:                                           .gsub(/\D+/, ".")
// 55:         versioned_name = "#{base_name}@#{normalized_version}"
// 56:         versioned_ref ||= if tap
// 57:           "#{tap}/#{versioned_name}"
// 58:         else
// 59:           versioned_name
// 60:         end
// 61:
// 62:         installed_formula_names = Formula.installed_formula_names
// 63:         if installed_formula_names.include?(versioned_name)
// 64:           ohai "#{versioned_name} is already installed"
// 65:           return
// 66:         end
// 67:
// 68:         existing_tap = Tap.installed
// 69:                           .sort_by(&:name)
// 70:                           .find { |tap| tap.formula_files_by_name.key?(versioned_name) }
// 71:         install_target = "#{existing_tap}/#{versioned_name}" if existing_tap
// 72:
// 73:         versioned_formula = begin
// 74:           Formulary.factory(versioned_ref, warn: false)
// 75:         rescue TapFormulaAmbiguityError, FormulaUnavailableError, TapFormulaUnavailableError,
// 76:                TapFormulaUnreadableError
// 77:           nil
// 78:         end
// 79:
// 80:         if install_target.nil?
// 81:           install_target = if versioned_formula
// 82:             versioned_formula.full_name
// 83:           else
// 84:             current_formula = begin
// 85:               Formulary.factory(formula_input, warn: false)
// 86:             rescue FormulaUnavailableError, TapFormulaUnavailableError, TapFormulaUnreadableError
// 87:               nil
// 88:             end
// 89:
// 90:             if current_formula && current_formula.version.to_s == version_input
// 91:               if installed_formula_names.include?(current_formula.name)
// 92:                 ohai "#{current_formula.full_name} is already installed"
// 93:                 return
// 94:               end
// 95:
// 96:               current_formula.full_name
// 97:             end
// 98:           end
// 99:         end
// 100:
// 101:         # Pretend we've run a dev command to avoid making it seem like the user
// 102:         # has done so manually.
// 103:         ENV["HOMEBREW_DEV_CMD_RUN"] = "1"
// 104:
// 105:         if install_target.nil?
// 106:           username = if !Homebrew::EnvConfig.no_github_api? && GitHub::API.credentials_type != :none
// 107:             begin
// 108:               GitHub.user["login"].presence
// 109:             rescue *GitHub::API::ERRORS
// 110:               nil
// 111:             end
// 112:           end
// 113:           username ||= User.current&.to_s
// 114:           username ||= ENV.fetch("USER")
// 115:           odie "Unable to determine a username for tap creation." if username.blank?
// 116:
// 117:           tap = Tap.fetch("#{username}/homebrew-#{DEFAULT_TAP_REPOSITORY}")
// 118:           unless tap.installed?
// 119:             ohai "Creating #{tap.name} tap for storing versioned formulae..."
// 120:             safe_system HOMEBREW_BREW_FILE, "tap-new", "--no-git", tap.name
// 121:           end
// 122:
// 123:           ohai "Extracting #{formula_input}@#{version_input} into #{tap.name}..."
// 124:           safe_system HOMEBREW_BREW_FILE, "extract", formula_input, tap.name, "--version=#{version_input}"
// 125:
// 126:           install_target = "#{tap}/#{versioned_name}"
// 127:
// 128:           opoo <<~EOS
// 129:             You are responsible for maintaining this #{install_target}!
// 130:             It will not receive any bugfix/security updates.
// 131:             Homebrew cannot support it for you because we cannot maintain every formula
// 132:             at every version or fix older versions in our Git history.
// 133:           EOS
// 134:         end
// 135:
// 136:         ohai "Installing #{install_target}..."
// 137:         safe_system HOMEBREW_BREW_FILE, "install", install_target
// 138:       end
// 139:     end
// 140:   end
// 141: end
