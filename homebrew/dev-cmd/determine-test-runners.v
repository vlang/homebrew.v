module dev_cmd

import ruby
import homebrew
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/determine-test-runners.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct DetermineTestRunnersOptions {
pub:
	named                 []string
	all_supported         bool
	eval_all              bool
	tap_trust_configured  bool
	dependents            bool
	dependent_shards      string
	github_actions        bool
	github_output         string
	github_run_id         string
	linux_self_hosted     bool
	macos_long_timeout    bool
	macos_build_on_github bool
	linux_arm_runner      string = 'ubuntu-24.04-arm'
	formulae              map[string]homebrew.TestRunnerFormulaDefinition
	dependent_formulae    []homebrew.TestRunnerFormulaDefinition
	intel_bottle_tags     map[string][]string
	oldest_macos_runner   string = 'sonoma'
	newest_macos_runner   string = 'tahoe'
	newest_intel_runner   string = 'sonoma'
}

pub struct DetermineTestRunnersResult {
pub:
	runners             []map[string]ruby.Value
	runners_json        string
	stdout              string
	github_output       string
	github_output_wrote bool
}

@[heap]
pub struct DetermineTestRunnersInput {
pub:
	options DetermineTestRunnersOptions
}

fn determine_test_runners_positive_integer(value string) bool {
	if value.len == 0 || value[0] == `0` {
		return false
	}
	return value.bytes().all(it >= `0` && it <= `9`)
}

fn determine_test_runners_json_value(runners []map[string]ruby.Value) ruby.Value {
	mut values := []ruby.Value{cap: runners.len}
	for runner in runners {
		mut normalized := runner.clone()
		if container := normalized['container'] {
			if container.type_name == 'Container' {
				normalized['container'] = ruby.map_value({
					'image':   ruby.string_value(container.attributes['image'] or { '' })
					'options': ruby.string_value(container.attributes['options'] or { '' })
				})
			}
		}
		values << ruby.map_value(normalized)
	}
	return ruby.array_value(values)
}

pub fn run_determine_test_runners(options DetermineTestRunnersOptions) !DetermineTestRunnersResult {
	if options.named.len == 0 && !options.all_supported {
		return error('at least 1 named argument is required')
	} else if options.all_supported && options.named.len > 0 {
		return error('`--all-supported` is mutually exclusive to other arguments.')
	}

	eval_all := options.eval_all || options.tap_trust_configured
	mut testing_formulae := []homebrew.TestRunnerFormula{}
	if options.named.len > 0 {
		for name in options.named[0].split(',') {
			formula := options.formulae[name] or { return error('No available formula with the name "${name}".') }
			testing_formulae << homebrew.new_test_runner_formula(formula, eval_all)
		}
	}
	deleted_formulae := if options.named.len > 1 { options.named[1].split(',') } else { []string{} }
	dependent_shards_text := if options.dependent_shards == '' {
		'1'
	} else {
		options.dependent_shards
	}
	if !determine_test_runners_positive_integer(dependent_shards_text) {
		return error('`--dependent-shards` must be a positive integer.')
	}
	if options.github_actions && options.github_run_id == '' {
		return error('key not found: "GITHUB_RUN_ID"')
	}

	matrix := homebrew.new_github_runner_matrix(testing_formulae, deleted_formulae, homebrew.GitHubRunnerMatrixOptions{
		all_supported: options.all_supported
		dependent_matrix: options.dependents
		dependent_shards: dependent_shards_text.int()
		github_run_id: options.github_run_id
		linux_self_hosted: options.linux_self_hosted
		macos_long_timeout: options.macos_long_timeout
		macos_build_on_github: options.macos_build_on_github
		linux_arm_runner: options.linux_arm_runner
		dependent_formulae: options.dependent_formulae
		intel_bottle_tags: options.intel_bottle_tags
		oldest_macos_runner: options.oldest_macos_runner
		newest_macos_runner: options.newest_macos_runner
		newest_intel_runner: options.newest_intel_runner
	})!
	runners := homebrew.github_runner_matrix_active_specs(matrix)
	runners_value := determine_test_runners_json_value(runners)
	runners_json := ruby.json_value_to_string(runners_value)
	pretty_runners := json2.encode(ruby.json_any_from_value(runners_value), prettify: true)
	stdout := '==> Runners\n${pretty_runners}\n'

	if options.github_actions && options.github_output == '' {
		return error('key not found: "GITHUB_OUTPUT"')
	}
	mut github_output_wrote := false
	if options.github_output != '' {
		mut output := os.open_append(options.github_output)!
		defer {
			output.close()
		}
		output.writeln('runners=${runners_json}')!
		output.writeln('runners_present=${runners.len > 0}')!
		github_output_wrote = true
	}

	return DetermineTestRunnersResult{
		runners: runners
		runners_json: runners_json
		stdout: stdout
		github_output: options.github_output
		github_output_wrote: github_output_wrote
	}
}

pub fn determine_test_runners_input_boundary(input &DetermineTestRunnersInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::DetermineTestRunners::Input', '', {
		'determine_test_runners_input_address': u64(voidptr(input)).str()
	})
}

fn determine_test_runners_input_from_value(value ruby.Value) &DetermineTestRunnersInput {
	address := value.attributes['determine_test_runners_input_address'] or {
		panic('invalid DetermineTestRunners input')
	}
	return unsafe { &DetermineTestRunnersInput(voidptr(address.u64())) }
}

fn determine_test_runners_result_value(result DetermineTestRunnersResult) ruby.Value {
	return ruby.map_value({
		'runners':             determine_test_runners_json_value(result.runners)
		'runners_json':        ruby.string_value(result.runners_json)
		'stdout':              ruby.string_value(result.stdout)
		'github_output':       ruby.string_value(result.github_output)
		'github_output_wrote': ruby.bool_value(result.github_output_wrote)
	})
}

// Ruby method `run` at line 39.
pub fn ruby_determine_test_runners_l39_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	options := determine_test_runners_input_from_value(args[0]).options
	result := run_determine_test_runners(options) or {
		error_type := if options.named.len == 0 && !options.all_supported {
			'Homebrew::CLI::MinNamedArgumentsError'
		} else if err.msg().starts_with('`--') {
			'UsageError'
		} else if err.msg().starts_with('key not found:') {
			'KeyError'
		} else {
			'Error'
		}
		return ruby.object_value(error_type, err.msg())
	}
	return determine_test_runners_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "test_runner_formula"
// 6: require "github_runner_matrix"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class DetermineTestRunners < AbstractCommand
// 11:       cmd_args do
// 12:         usage_banner <<~EOS
// 13:           `determine-test-runners` {<testing-formulae> [<deleted-formulae>]|--all-supported}
// 14:
// 15:           Determines the runners used to test formulae or their dependents. For internal use in Homebrew taps.
// 16:         EOS
// 17:         switch "--all-supported",
// 18:                description: "Instead of selecting runners based on the chosen formula, return all supported runners."
// 19:         switch "--eval-all",
// 20:                description: "Evaluate all available formulae, whether installed or not, to determine testing " \
// 21:                             "dependents.",
// 22:                env:         :eval_all,
// 23:                odeprecated: true
// 24:         switch "--dependents",
// 25:                description: "Determine runners for testing dependents."
// 26:         flag   "--dependent-shards=",
// 27:                description: "Split each dependent runner into the given number of shards.",
// 28:                depends_on:  "--dependents",
// 29:                hidden:      true
// 30:
// 31:         named_args max: 2
// 32:
// 33:         conflicts "--all-supported", "--dependents"
// 34:
// 35:         hide_from_man_page!
// 36:       end
// 37:
// 38:       sig { override.void }
// 39:       def run
// 40:         if args.no_named? && !args.all_supported?
// 41:           raise Homebrew::CLI::MinNamedArgumentsError, 1
// 42:         elsif args.all_supported? && !args.no_named?
// 43:           raise UsageError, "`--all-supported` is mutually exclusive to other arguments."
// 44:         end
// 45:
// 46:         eval_all = args.eval_all?
// 47:         eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 48:
// 49:         testing_formulae = args.named.first&.split(",").to_a.map do |name|
// 50:           TestRunnerFormula.new(Formulary.factory(name), eval_all:)
// 51:         end.freeze
// 52:         deleted_formulae = args.named.second&.split(",").to_a.freeze
// 53:         dependent_shards = args.dependent_shards || "1"
// 54:         unless dependent_shards.match?(/\A[1-9]\d*\z/)
// 55:           raise UsageError,
// 56:                 "`--dependent-shards` must be a positive integer."
// 57:         end
// 58:
// 59:         runner_matrix = GitHubRunnerMatrix.new(testing_formulae, deleted_formulae,
// 60:                                                all_supported:    args.all_supported?,
// 61:                                                dependent_matrix: args.dependents?,
// 62:                                                dependent_shards: dependent_shards.to_i)
// 63:         runners = runner_matrix.active_runner_specs_hash
// 64:
// 65:         ohai "Runners", JSON.pretty_generate(runners)
// 66:
// 67:         # gracefully handle non-GitHub Actions environments
// 68:         github_output = if ENV.key?("GITHUB_ACTIONS")
// 69:           ENV.fetch("GITHUB_OUTPUT")
// 70:         else
// 71:           ENV.fetch("GITHUB_OUTPUT", nil)
// 72:         end
// 73:         return unless github_output
// 74:
// 75:         File.open(github_output, "a") do |f|
// 76:           f.puts("runners=#{runners.to_json}")
// 77:           f.puts("runners_present=#{runners.present?}")
// 78:         end
// 79:       end
// 80:     end
// 81:   end
// 82: end
