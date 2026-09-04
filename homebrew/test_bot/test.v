module test_bot

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `test_bot/test.rb`.

pub struct TestTap {
pub:
	name      string
	full_name string
	path      string
}

pub struct TestConfig {
pub:
	tap                 TestTap
	has_tap             bool
	git                 string
	has_git             bool
	dry_run             bool
	fail_fast           bool
	verbose             bool
	core_tap_path       string
	homebrew_library    string
	homebrew_prefix     string
	homebrew_repository string
	runner_os_title     string
	github_actions      bool
	emit_output         bool = true
	formula_locations   map[string]StepFormulaLocation
	analytics_enabled   bool
	analytics_state     utils.AnalyticsState
}

pub struct TestRequest {
pub:
	arguments         []string
	named_args        []string
	environment       map[string]string
	unset_environment []string
	verbose           bool
	has_verbose       bool
	ignore_failures   bool
	report_analytics  bool
}

pub struct TestCommandArgs {
pub:
	cleanup    bool
	local_mode bool
}

pub struct Test {
pub:
	tap                 TestTap
	has_tap             bool
	git                 string
	has_git             bool
	dry_run             bool
	fail_fast           bool
	verbose             bool
	repository          string
	homebrew_library    string
	homebrew_prefix     string
	homebrew_repository string
	runner_title        string
	github_actions      bool
	emit_output         bool
	formula_locations   map[string]StepFormulaLocation
	analytics_enabled   bool
	analytics_state     utils.AnalyticsState
pub mut:
	steps        []Step
	last_run     StepRunResult
	has_last_run bool
	analytics    []utils.AnalyticsCurlPlan
	emitted      []string
}

fn test_core_tap_path(config TestConfig) string {
	if config.core_tap_path != '' {
		return config.core_tap_path
	}
	if configured := os.getenv_opt('HOMEBREW_CORE_TAP_PATH') {
		if configured != '' {
			return configured
		}
	}
	library := if config.homebrew_library != '' {
		config.homebrew_library
	} else {
		ruby.environment_value('HOMEBREW_LIBRARY')
	}
	return if library == '' {
		os.join_path(os.getwd(), 'Library', 'Taps', 'homebrew', 'homebrew-core')
	} else {
		os.join_path(library, 'Taps', 'homebrew', 'homebrew-core')
	}
}

fn test_analytics_state_copy(state utils.AnalyticsState) utils.AnalyticsState {
	return utils.AnalyticsState{
		...state
		settings: state.settings.clone()
	}
}

pub fn new_test(config TestConfig) &Test {
	repository := if config.has_tap { config.tap.path } else { test_core_tap_path(config) }
	return &Test{
		tap: config.tap
		has_tap: config.has_tap
		git: config.git
		has_git: config.has_git
		dry_run: config.dry_run
		fail_fast: config.fail_fast
		verbose: config.verbose
		repository: repository
		homebrew_library: config.homebrew_library
		homebrew_prefix: config.homebrew_prefix
		homebrew_repository: config.homebrew_repository
		runner_title: config.runner_os_title
		github_actions: config.github_actions
		emit_output: config.emit_output
		formula_locations: config.formula_locations.clone()
		analytics_enabled: config.analytics_enabled
		analytics_state: test_analytics_state_copy(config.analytics_state)
	}
}

pub fn (test &Test) failed_steps() []Step {
	return test.steps.filter(it.failed())
}

pub fn (test &Test) ignored_steps() []Step {
	return test.steps.filter(it.ignored())
}

fn (test &Test) actions_enabled() bool {
	return test.github_actions || os.getenv('GITHUB_ACTIONS') != ''
}

pub fn test_cleanup_enabled(args TestCommandArgs, github_actions bool) bool {
	return args.cleanup || github_actions || os.getenv('GITHUB_ACTIONS') != ''
}

pub fn test_local_enabled(args TestCommandArgs, github_actions bool) bool {
	return args.local_mode || github_actions || os.getenv('GITHUB_ACTIONS') != ''
}

fn (mut test Test) analytics_for_step(step Step, requested bool) {
	if !requested
		|| (!test.analytics_enabled && os.getenv('HOMEBREW_TEST_BOT_ANALYTICS') == '') {
		return
	}
	mut state := test_analytics_state_copy(test.analytics_state)
	state.test_bot_analytics = true
	if plan := utils.analytics_report_test_bot_test(state, step.command_short(), step.passed()) {
		test.analytics << plan
	}
}

pub fn (mut test Test) run_step(request TestRequest) Step {
	verbose := if request.has_verbose { request.verbose } else { test.verbose }
	mut step := new_step(request.arguments, request.named_args, StepConfig{
		environment: request.environment.clone()
		unset_environment: request.unset_environment.clone()
		verbose: verbose
		ignore_failures: request.ignore_failures
		repository: test.repository
		homebrew_library: test.homebrew_library
		homebrew_prefix: test.homebrew_prefix
		homebrew_repository: test.homebrew_repository
		runner_os_title: test.runner_title
		github_actions: test.github_actions
		emit_output: test.emit_output
		formula_locations: test.formula_locations.clone()
	})
	run := step.run(StepRunOptions{
		dry_run: test.dry_run
		fail_fast: test.fail_fast
	})
	test.last_run = run
	test.has_last_run = true
	test.steps << step
	test.analytics_for_step(step, request.report_analytics)
	return step
}

fn test_header_line(class_name string, method string) string {
	return utils.formatter_headline('Running ${class_name}#${method}', 'magenta', utils.current_tty_state())
}

fn test_info_header_line(text string) string {
	return utils.formatter_headline(text, 'cyan', utils.current_tty_state())
}

fn (mut test Test) emit(text string) {
	test.emitted << text
	if test.emit_output {
		if text.ends_with('\n') {
			print(text)
		} else {
			println(text)
		}
	}
}

pub fn (mut test Test) test_header(class_name string, method string) string {
	test.emit('')
	line := test_header_line(class_name, method)
	test.emit(line)
	return line
}

pub fn (mut test Test) info_header(text string) string {
	line := test_info_header_line(text)
	test.emit(line)
	return line
}

pub fn test_request_boundary(request TestRequest) ruby.Value {
	mut attributes := {
		'named_args':        request.named_args.join('\x1f')
		'unset_environment': request.unset_environment.join('\x1f')
		'verbose':           request.verbose.str()
		'has_verbose':       request.has_verbose.str()
		'ignore_failures':   request.ignore_failures.str()
		'report_analytics':  request.report_analytics.str()
	}
	for key, value in request.environment {
		attributes['environment:${key}'] = value
	}
	return ruby.Value{
		type_name: 'Homebrew::TestBot::TestRequest'
		repr: request.arguments.join(' ')
		string_array_data: request.arguments.clone()
		attributes: attributes
	}
}

fn test_request_from_boundary(value ruby.Value) TestRequest {
	mut environment := map[string]string{}
	for key, contents in value.attributes {
		if key.starts_with('environment:') {
			environment[key.all_after('environment:')] = contents
		}
	}
	return TestRequest{
		arguments: value.string_array_data.clone()
		named_args: if value.attributes['named_args'] == '' {
			[]
		} else {
			value.attributes['named_args'].split('\x1f')
		}
		environment: environment
		unset_environment: if value.attributes['unset_environment'] == '' {
			[]
		} else {
			value.attributes['unset_environment'].split('\x1f')
		}
		verbose: value.attributes['verbose'] == 'true'
		has_verbose: value.attributes['has_verbose'] == 'true'
		ignore_failures: value.attributes['ignore_failures'] == 'true'
		report_analytics: value.attributes['report_analytics'] == 'true'
	}
}

fn test_boundary_value(test &Test) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::TestBot::Test'
		repr: test.repository
		array_data: test.steps.map(step_boundary_value(it))
		attributes: {
			'address':             u64(voidptr(test)).str()
			'tap_name':            test.tap.name
			'tap_full_name':       test.tap.full_name
			'tap_path':            test.tap.path
			'has_tap':             test.has_tap.str()
			'git':                 test.git
			'has_git':             test.has_git.str()
			'dry_run':             test.dry_run.str()
			'fail_fast':           test.fail_fast.str()
			'verbose':             test.verbose.str()
			'repository':          test.repository
			'homebrew_library':    test.homebrew_library
			'homebrew_prefix':     test.homebrew_prefix
			'homebrew_repository': test.homebrew_repository
			'runner_title':        test.runner_title
			'github_actions':      test.github_actions.str()
			'emit_output':         test.emit_output.str()
			'analytics_enabled':   test.analytics_enabled.str()
		}
	}
}

fn test_boundary_receiver(args []ruby.Value) !&Test {
	if args.len == 0 || args[0].type_name != 'Homebrew::TestBot::Test' {
		return error('Test receiver is required')
	}
	address := args[0].attributes['address'] or { return error('Test receiver has no address') }
	if address.u64() == 0 {
		return error('Test receiver has an invalid address')
	}
	return unsafe { &Test(voidptr(address.u64())) }
}

fn test_tap_boundary(tap TestTap, present bool) ruby.Value {
	if !present {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.structured_value('Tap', tap.name, {
		'name':      tap.name
		'full_name': tap.full_name
		'path':      tap.path
	})
}

fn test_optional_string(value string, present bool, type_name string) ruby.Value {
	return if present {
		ruby.object_value(type_name, value)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}
