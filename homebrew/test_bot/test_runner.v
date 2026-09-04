module test_bot

import ruby
import os

// Translated from Homebrew/brew `test_bot/test_runner.rb`.

pub struct TestRunnerStepFailure {
pub:
	command string
	ignored bool
}

pub struct TestRunnerArgs {
pub:
	named                      []string
	working_directory          string = '.'
	bottle_tag                 string = 'all'
	skip_setup                 bool
	only_cleanup_before        bool
	only_setup                 bool
	only_tap_syntax            bool
	only_formulae              bool
	only_formulae_detect       bool
	only_formulae_dependents   bool
	only_bottles_fetch         bool
	only_cleanup_after         bool
	skip_dependents            bool
	cleanup                    bool = true
	junit                      bool
	testing_formulae_set       bool
	added_formulae_set         bool
	deleted_formulae_set       bool
	testing_formulae           []string
	added_formulae             []string
	deleted_formulae           []string
	detected_testing_formulae  []string
	detected_added_formulae    []string
	detected_deleted_formulae  []string
	skipped_or_failed_formulae []string
	formulae_skipped_or_failed []string
	tested_formulae            []string
	step_failures              []TestRunnerStepFailure
}

pub struct TestRunnerBuildPlan {
pub:
	argument            string
	setup               bool
	tap_syntax          bool
	formulae_detect     bool
	formulae            bool
	formulae_dependents bool
	cleanup_before      bool
	cleanup_after       bool
	bottles_fetch       bool
}

pub struct TestRunnerExecution {
pub:
	events                     []string
	testing_formulae           []string
	added_formulae             []string
	deleted_formulae           []string
	skipped_or_failed_formulae []string
	tested_formulae            []string
}

pub struct TestRunnerResult {
pub:
	success       bool
	arguments     []string
	plans         []TestRunnerBuildPlan
	executions    []TestRunnerExecution
	steps_output  string
	output_paths  map[string]string
	junit_written bool
	junit_filters []string
}

pub fn test_runner_ensure_blank_file_exists(file string) ! {
	parent := os.dir(file)
	if parent != '.' && parent != '' {
		os.mkdir_all(parent)!
	}
	os.write_file(file, '')!
}

pub fn test_runner_no_only_args(args TestRunnerArgs) bool {
	return !(args.only_cleanup_before || args.only_setup || args.only_tap_syntax
		|| args.only_formulae || args.only_formulae_detect || args.only_formulae_dependents
		|| args.only_bottles_fetch || args.only_cleanup_after)
}

pub fn test_runner_build_tests(argument string, skip_setup bool, skip_cleanup_before bool,
	skip_cleanup_after bool, args TestRunnerArgs) TestRunnerBuildPlan {
	no_only_args := test_runner_no_only_args(args)
	no_formulae_flags := !args.testing_formulae_set && !args.added_formulae_set
		&& !args.deleted_formulae_set
	return TestRunnerBuildPlan{
		argument: argument
		setup: !skip_setup && (no_only_args || args.only_setup)
		tap_syntax: no_only_args || args.only_tap_syntax
		formulae_detect: no_formulae_flags
			&& (no_only_args || args.only_formulae || args.only_formulae_detect)
		formulae: no_only_args || args.only_formulae
		formulae_dependents: !args.skip_dependents
			&& (no_only_args || args.only_formulae || args.only_formulae_dependents)
		cleanup_before: args.cleanup && !skip_cleanup_before
			&& (no_only_args || args.only_cleanup_before)
		cleanup_after: args.cleanup && !skip_cleanup_after
			&& (no_only_args || args.only_cleanup_after)
		bottles_fetch: args.only_bottles_fetch
	}
}

pub fn test_runner_run_tests(plan TestRunnerBuildPlan, args TestRunnerArgs) TestRunnerExecution {
	mut events := []string{}
	if plan.cleanup_before {
		events << 'cleanup_before'
	}
	if plan.setup {
		events << 'setup'
	}
	if plan.tap_syntax {
		events << 'tap_syntax'
	}
	mut testing_formulae := args.testing_formulae.clone()
	mut added_formulae := args.added_formulae.clone()
	mut deleted_formulae := args.deleted_formulae.clone()
	if plan.formulae_detect {
		events << 'formulae_detect'
		testing_formulae = args.detected_testing_formulae.clone()
		added_formulae = args.detected_added_formulae.clone()
		deleted_formulae = args.detected_deleted_formulae.clone()
	}
	mut skipped_or_failed := args.skipped_or_failed_formulae.clone()
	if plan.formulae {
		events << 'formulae'
		skipped_or_failed = args.formulae_skipped_or_failed.clone()
	}
	mut tested_formulae := args.tested_formulae.clone()
	if tested_formulae.len == 0 {
		tested_formulae = testing_formulae.clone()
	}
	if plan.formulae_dependents {
		events << 'formulae_dependents'
	}
	if plan.bottles_fetch {
		events << 'bottles_fetch'
	}
	// Ruby's ensure block always runs this last when present.
	if plan.cleanup_after {
		events << 'cleanup_after'
	}
	return TestRunnerExecution{
		events: events
		testing_formulae: testing_formulae
		added_formulae: added_formulae
		deleted_formulae: deleted_formulae
		skipped_or_failed_formulae: skipped_or_failed
		tested_formulae: tested_formulae
	}
}

fn test_runner_steps_output(failures []TestRunnerStepFailure) string {
	ignored := failures.filter(it.ignored)
	failed := failures.filter(!it.ignored)
	if ignored.len == 0 && failed.len == 0 {
		return 'All steps passed!'
	}
	mut lines := []string{}
	if ignored.len > 0 {
		lines << 'Warning: ${ignored.len} failed step${if ignored.len > 1 { 's' } else { '' }} ignored!'
		lines << ignored.map(it.command)
	}
	if failed.len > 0 {
		lines << 'Error: ${failed.len} failed step${if failed.len > 1 { 's' } else { '' }}!'
		lines << failed.map(it.command)
	}
	return lines.join('\n')
}

pub fn run_test_runner(args TestRunnerArgs) !TestRunnerResult {
	root := if args.working_directory == '' { '.' } else { args.working_directory }
	output_paths := {
		'bottle':                     os.join_path(root, 'bottle_output.txt')
		'linkage':                    os.join_path(root, 'linkage_output.txt')
		'skipped_or_failed_formulae': os.join_path(root, 'skipped_or_failed_formulae-${args.bottle_tag}.txt')
	}
	if test_runner_no_only_args(args) || args.only_formulae {
		for path in output_paths.values() {
			test_runner_ensure_blank_file_exists(path)!
		}
	}
	mut arguments := args.named.clone()
	if arguments.len == 0 {
		arguments << 'HEAD'
	}
	mut plans := []TestRunnerBuildPlan{}
	mut executions := []TestRunnerExecution{}
	mut skip_setup := args.skip_setup
	mut skip_cleanup_before := false
	for index, argument in arguments {
		plan := test_runner_build_tests(argument, skip_setup, skip_cleanup_before, index != arguments.len - 1, args)
		plans << plan
		executions << test_runner_run_tests(plan, args)
		skip_setup = true
		skip_cleanup_before = true
	}
	steps_output := test_runner_steps_output(args.step_failures)
	steps_output_path := os.join_path(root, 'steps_output.txt')
	test_runner_ensure_blank_file_exists(steps_output_path)!
	os.write_file(steps_output_path, steps_output)!
	junit_written := args.junit
		&& (test_runner_no_only_args(args) || args.only_formulae || args.only_formulae_dependents)
	if junit_written {
		os.write_file(os.join_path(root, 'brew-test-bot.xml'), '<testsuite filters="audit,test"></testsuite>\n')!
	}
	return TestRunnerResult{
		success: args.step_failures.all(it.ignored)
		arguments: arguments
		plans: plans
		executions: executions
		steps_output: steps_output
		output_paths: output_paths
		junit_written: junit_written
		junit_filters: if junit_written { ['audit', 'test'] } else { [] }
	}
}

fn test_runner_args_from_value(value ruby.Value) TestRunnerArgs {
	attributes := value.attributes.clone()
	return TestRunnerArgs{
		named: attributes['named'].split(',').filter(it != '')
		working_directory: if attributes['working_directory'] != '' {
			attributes['working_directory']
		} else {
			'.'
		}
		bottle_tag: if attributes['bottle_tag'] != '' {
			attributes['bottle_tag']
		} else {
			'all'
		}
		skip_setup: attributes['skip_setup'] == 'true'
		only_cleanup_before: attributes['only_cleanup_before'] == 'true'
		only_setup: attributes['only_setup'] == 'true'
		only_tap_syntax: attributes['only_tap_syntax'] == 'true'
		only_formulae: attributes['only_formulae'] == 'true'
		only_formulae_detect: attributes['only_formulae_detect'] == 'true'
		only_formulae_dependents: attributes['only_formulae_dependents'] == 'true'
		only_bottles_fetch: attributes['only_bottles_fetch'] == 'true'
		only_cleanup_after: attributes['only_cleanup_after'] == 'true'
		skip_dependents: attributes['skip_dependents'] == 'true'
		cleanup: attributes['cleanup'] != 'false'
		junit: attributes['junit'] == 'true'
		testing_formulae_set: attributes['testing_formulae_set'] == 'true'
		added_formulae_set: attributes['added_formulae_set'] == 'true'
		deleted_formulae_set: attributes['deleted_formulae_set'] == 'true'
		testing_formulae: attributes['testing_formulae'].split(',').filter(it != '')
		added_formulae: attributes['added_formulae'].split(',').filter(it != '')
		deleted_formulae: attributes['deleted_formulae'].split(',').filter(it != '')
		detected_testing_formulae: attributes['detected_testing_formulae'].split(',').filter(it != '')
		detected_added_formulae: attributes['detected_added_formulae'].split(',').filter(it != '')
		detected_deleted_formulae: attributes['detected_deleted_formulae'].split(',').filter(it != '')
		skipped_or_failed_formulae: attributes['skipped_or_failed_formulae'].split(',').filter(it != '')
		formulae_skipped_or_failed: attributes['formulae_skipped_or_failed'].split(',').filter(it != '')
		tested_formulae: attributes['tested_formulae'].split(',').filter(it != '')
	}
}

fn test_runner_plan_value(plan TestRunnerBuildPlan) ruby.Value {
	mut enabled := []string{}
	for name, selected in {
		'setup':               plan.setup
		'tap_syntax':          plan.tap_syntax
		'formulae_detect':     plan.formulae_detect
		'formulae':            plan.formulae
		'formulae_dependents': plan.formulae_dependents
		'cleanup_before':      plan.cleanup_before
		'cleanup_after':       plan.cleanup_after
		'bottles_fetch':       plan.bottles_fetch
	} {
		if selected {
			enabled << name
		}
	}
	return ruby.structured_value('TestRunnerTypes', plan.argument, {
		'argument': plan.argument
		'enabled':  enabled.join(',')
	})
}

fn test_runner_plan_from_value(value ruby.Value) TestRunnerBuildPlan {
	enabled := value.attributes['enabled'].split(',')
	return TestRunnerBuildPlan{
		argument: value.attributes['argument']
		setup: 'setup' in enabled
		tap_syntax: 'tap_syntax' in enabled
		formulae_detect: 'formulae_detect' in enabled
		formulae: 'formulae' in enabled
		formulae_dependents: 'formulae_dependents' in enabled
		cleanup_before: 'cleanup_before' in enabled
		cleanup_after: 'cleanup_after' in enabled
		bottles_fetch: 'bottles_fetch' in enabled
	}
}
