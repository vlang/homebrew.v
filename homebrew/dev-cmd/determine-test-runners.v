module dev_cmd

import ruby
import homebrew
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/determine-test-runners.rb`.

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
