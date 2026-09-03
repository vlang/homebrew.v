module cmd

import homebrew.readall as readall_core

// Translated from Homebrew/brew `cmd/readall.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 37.
pub fn ruby_readall_l37_d1_run(arguments []string,
	config ReadallCommandConfig) !ReadallCommandResult {
	mut state := readall_core.new_state()
	return run_readall_command(arguments, config, mut state)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "readall"
// 6: require "env_config"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class ReadallCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Import all items from the specified <tap>, or from all installed taps if none is provided.
// 14:           This can be useful for debugging issues across all items when making
// 15:           significant changes to `formula.rb`, testing the performance of loading
// 16:           all items or checking if any current formulae/casks have Ruby issues.
// 17:         EOS
// 18:         flag   "--os=",
// 19:                description: "Read using the given operating system. (Pass `all` to simulate all operating systems.)"
// 20:         flag   "--arch=",
// 21:                description: "Read using the given CPU architecture. (Pass `all` to simulate all architectures.)"
// 22:         switch "--aliases",
// 23:                description: "Verify any alias symlinks in each tap."
// 24:         switch "--syntax",
// 25:                description: "Syntax-check all of Homebrew's Ruby files (if no <tap> is passed)."
// 26:         switch "--eval-all",
// 27:                description: "Evaluate all available formulae and casks, whether installed or not.",
// 28:                env:         :eval_all,
// 29:                odeprecated: true
// 30:         switch "--no-simulate",
// 31:                description: "Don't simulate other system configurations when checking formulae and casks."
// 32:
// 33:         named_args :tap
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         Homebrew.with_no_api_env do
// 39:           if args.syntax? && args.no_named?
// 40:             scan_files = "#{HOMEBREW_LIBRARY_PATH}/**/*.rb"
// 41:             ruby_files = Dir.glob(scan_files).grep_v(%r{/(vendor)/}).map { Pathname(it) }
// 42:
// 43:             Homebrew.failed = true unless Readall.valid_ruby_syntax?(ruby_files)
// 44:           end
// 45:
// 46:           options = {
// 47:             aliases:     args.aliases?,
// 48:             no_simulate: args.no_simulate?,
// 49:           }
// 50:           options[:os_arch_combinations] = args.os_arch_combinations if args.os || args.arch
// 51:
// 52:           eval_all = args.eval_all?
// 53:           eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 54:           taps = if args.no_named?
// 55:             unless eval_all
// 56:               raise UsageError,
// 57:                     "`brew readall` needs a tap, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 58:                     "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 59:             end
// 60:
// 61:             Tap.installed
// 62:           else
// 63:             args.named.to_installed_taps
// 64:           end
// 65:
// 66:           taps.each do |tap|
// 67:             Homebrew.failed = true unless Readall.valid_tap?(tap, **options)
// 68:           end
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
