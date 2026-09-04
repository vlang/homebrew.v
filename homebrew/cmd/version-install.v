module cmd

// Translated from Homebrew/brew `cmd/version-install.rb`.
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

pub type VersionInstallFormulaResolver = fn (reference string, formulae map[string]VersionInstallFormula) !VersionInstallFormula

pub type VersionInstallTapFetcher = fn (name string, taps map[string]VersionInstallTap) !VersionInstallTap

pub type VersionInstallCommandRunner = fn (mut runtime VersionInstallRuntime, command []string) !

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
