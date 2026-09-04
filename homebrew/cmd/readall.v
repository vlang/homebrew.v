module cmd

import homebrew.readall as readall_core

// Translated from Homebrew/brew `cmd/readall.rb`.
pub struct ReadallCommandArgs {
pub:
	os          string
	arch        string
	aliases     bool
	syntax      bool
	eval_all    bool
	no_simulate bool
	named_taps  []string
}

pub struct ReadallCommandConfig {
pub:
	library_ruby_files   []readall_core.RubyFile
	installed_taps       []readall_core.Tap
	named_taps           map[string]readall_core.Tap
	tap_trust_configured bool
	cores                int = 1
	current_os           readall_core.SystemOs = .macos
	current_arch         readall_core.SystemArch = .arm
	syntax_compiler      readall_core.SyntaxCompiler = readall_core.compile_ruby_file
	formula_evaluator    readall_core.FormulaEvaluator = readall_core.evaluate_formula_file
	cask_evaluator       readall_core.CaskEvaluator = readall_core.evaluate_cask_file
}

pub struct ReadallCommandResult {
pub:
	args                 ReadallCommandArgs
	failed               bool
	no_api_environment   bool
	eval_all             bool
	used_tap_trust       bool
	selected_taps        []string
	os_arch_combinations []readall_core.SystemCombination
	syntax_validation    readall_core.ValidationResult
	tap_validations      []readall_core.ValidationResult
	stdout               string
	stderr               string
}

pub fn parse_readall_command_args(arguments []string) !ReadallCommandArgs {
	mut os_name := ''
	mut arch := ''
	mut aliases := false
	mut syntax := false
	mut eval_all := false
	mut no_simulate := false
	mut named_taps := []string{}
	for argument in arguments {
		if argument.starts_with('--os=') {
			os_name = argument.all_after('=')
		} else if argument.starts_with('--arch=') {
			arch = argument.all_after('=')
		} else {
			match argument {
				'--aliases' {
					aliases = true
				}
				'--syntax' {
					syntax = true
				}
				'--eval-all' {
					eval_all = true
				}
				'--no-simulate' {
					no_simulate = true
				}
				else {
					if argument.starts_with('-') {
						return error('Unknown option: ${argument}')
					}
					named_taps << argument
				}
			}
		}
	}
	if os_name !in ['', 'all', 'macos', 'linux'] {
		return error('Unknown operating system: ${os_name}')
	}
	if arch !in ['', 'all', 'arm', 'arm64', 'intel', 'x86_64'] {
		return error('Unknown CPU architecture: ${arch}')
	}
	return ReadallCommandArgs{
		os: os_name
		arch: arch
		aliases: aliases
		syntax: syntax
		eval_all: eval_all
		no_simulate: no_simulate
		named_taps: named_taps
	}
}

fn readall_command_combinations(args ReadallCommandArgs,
	config ReadallCommandConfig) []readall_core.SystemCombination {
	if args.os == '' && args.arch == '' {
		return readall_core.all_system_combinations()
	}
	oses := match args.os {
		'all' { [readall_core.SystemOs.macos, .linux] }
		'macos' { [readall_core.SystemOs.macos] }
		'linux' { [readall_core.SystemOs.linux] }
		else { [config.current_os] }
	}
	arches := match args.arch {
		'all' { [readall_core.SystemArch.arm, .intel] }
		'arm', 'arm64' { [readall_core.SystemArch.arm] }
		'intel', 'x86_64' { [readall_core.SystemArch.intel] }
		else { [config.current_arch] }
	}
	mut combinations := []readall_core.SystemCombination{}
	for os_name in oses {
		for arch in arches {
			combinations << readall_core.SystemCombination{
				os: os_name
				arch: arch
			}
		}
	}
	return combinations
}

pub fn run_readall_command(arguments []string, config ReadallCommandConfig,
	mut state readall_core.State) !ReadallCommandResult {
	args := parse_readall_command_args(arguments)!
	mut failed := false
	mut stdout := ''
	mut stderr := ''
	mut syntax_validation := readall_core.ValidationResult{}
	if args.syntax && args.named_taps.len == 0 {
		ruby_files := config.library_ruby_files.filter(!it.path.contains('/vendor/'))
		syntax_validation = readall_core.valid_ruby_syntax(ruby_files, config.cores, config.syntax_compiler)
		failed = failed || !syntax_validation.valid
		stdout += syntax_validation.stdout
		stderr += syntax_validation.stderr
	}
	eval_all := args.eval_all || (args.named_taps.len == 0 && config.tap_trust_configured)
	used_tap_trust := !args.eval_all && args.named_taps.len == 0 && config.tap_trust_configured
	mut taps := []readall_core.Tap{}
	if args.named_taps.len == 0 {
		if !eval_all {
			return error('`brew readall` needs a tap, `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
		}
		taps = config.installed_taps.clone()
	} else {
		for name in args.named_taps {
			tap := config.named_taps[name] or { return error('Tap ${name} is not installed.') }
			taps << tap
		}
	}
	combinations := readall_command_combinations(args, config)
	mut validations := []readall_core.ValidationResult{}
	for tap in taps {
		validation := readall_core.valid_tap(mut state, tap, readall_core.TapValidationOptions{
			aliases: args.aliases
			no_simulate: args.no_simulate
			os_arch_combinations: combinations
			cores: config.cores
			current_os: config.current_os
			current_arch: config.current_arch
			formula_evaluator: config.formula_evaluator
			cask_evaluator: config.cask_evaluator
		})
		validations << validation
		failed = failed || !validation.valid
		stdout += validation.stdout
		stderr += validation.stderr
	}
	return ReadallCommandResult{
		args: args
		failed: failed
		no_api_environment: true
		eval_all: eval_all
		used_tap_trust: used_tap_trust
		selected_taps: taps.map(it.name)
		os_arch_combinations: combinations
		syntax_validation: syntax_validation
		tap_validations: validations
		stdout: stdout
		stderr: stderr
	}
}
