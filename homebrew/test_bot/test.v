module test_bot

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `test_bot/test.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `failed_steps` at line 13.
pub fn ruby_test_l13_d1_failed_steps(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(test.failed_steps().map(step_boundary_value(it)))
}

// Ruby method `ignored_steps` at line 18.
pub fn ruby_test_l18_d2_ignored_steps(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(test.ignored_steps().map(step_boundary_value(it)))
}

// Ruby attr_reader `attr_reader :steps` at line 23.
pub fn ruby_test_l23_d3_steps(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(test.steps.map(step_boundary_value(it)))
}

// Ruby method `test(*arguments, named_args: nil, env: {}, verbose: @verbose, ignore_failures: false,` at line 35.
pub fn ruby_test_l35_d4_test(args ...ruby.Value) ruby.Value {
	mut test := test_boundary_receiver(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'Test request is required')
	}
	request := if args[1].type_name == 'Homebrew::TestBot::TestRequest' {
		test_request_from_boundary(args[1])
	} else if args[1].type_name == 'Array' {
		TestRequest{ arguments: args[1].as_string_array() or { []string{} } }
	} else {
		TestRequest{ arguments: args[1..].map(it.as_string()) }
	}
	step := test.run_step(request)
	return step_boundary_value(step)
}

// Ruby method `cleanup?(args)` at line 58.
pub fn ruby_test_l58_d5_cleanup(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.bool_value(false) }
	options := if args.len > 1 {
		TestCommandArgs{ cleanup: (args[1].attributes['cleanup'] or { 'false' }).bool() }
	} else {
		TestCommandArgs{}
	}
	return ruby.bool_value(test_cleanup_enabled(options, test.actions_enabled()))
}

// Ruby method `local?(args)` at line 63.
pub fn ruby_test_l63_d6_local(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.bool_value(false) }
	options := if args.len > 1 {
		TestCommandArgs{ local_mode: (args[1].attributes['local'] or { 'false' }).bool() }
	} else {
		TestCommandArgs{}
	}
	return ruby.bool_value(test_local_enabled(options, test.actions_enabled()))
}

// Ruby attr_reader `attr_reader :tap` at line 70.
pub fn ruby_test_l70_d7_tap(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.object_value('NilClass', 'nil') }
	return test_tap_boundary(test.tap, test.has_tap)
}

// Ruby attr_reader `attr_reader :git` at line 73.
pub fn ruby_test_l73_d8_git(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or { return ruby.object_value('NilClass', 'nil') }
	return test_optional_string(test.git, test.has_git, 'String')
}

// Ruby attr_reader `attr_reader :repository` at line 76.
pub fn ruby_test_l76_d9_repository(args ...ruby.Value) ruby.Value {
	test := test_boundary_receiver(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', test.repository)
}

// Ruby method `initialize(tap: nil, git: nil, dry_run: false, fail_fast: false, verbose: false)` at line 87.
pub fn ruby_test_l87_d10_initialize(args ...ruby.Value) ruby.Value {
	tap := if args.len > 0 && args[0].type_name !in ['NilClass', 'Nil'] {
		TestTap{
			name: args[0].attributes['name'] or { args[0].as_string() }
			full_name: args[0].attributes['full_name'] or { args[0].as_string() }
			path: args[0].attributes['path'] or { args[0].as_string() }
		}
	} else {
		TestTap{}
	}
	config := TestConfig{
		tap: tap
		has_tap: args.len > 0 && args[0].type_name !in ['NilClass', 'Nil']
		git: if args.len > 1 { args[1].as_string() } else { '' }
		has_git: args.len > 1 && args[1].type_name !in ['NilClass', 'Nil']
		dry_run: args.len > 2 && (args[2].as_bool() or { false })
		fail_fast: args.len > 3 && (args[3].as_bool() or { false })
		verbose: args.len > 4 && (args[4].as_bool() or { false })
		core_tap_path: if args.len > 5 { args[5].as_string() } else { '' }
		emit_output: false
	}
	return test_boundary_value(new_test(config))
}

// Ruby method `test_header(klass, method: "run!")` at line 101.
pub fn ruby_test_l101_d11_test_header(args ...ruby.Value) ruby.Value {
	mut test := test_boundary_receiver(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	class_name := if args.len > 1 { args[1].as_string().trim_left(':') } else { '' }
	method := if args.len > 2 && args[2].type_name !in ['NilClass', 'Nil'] {
		args[2].as_string().trim_left(':')
	} else {
		'run!'
	}
	test.test_header(class_name, method)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `info_header(text)` at line 107.
pub fn ruby_test_l107_d12_info_header(args ...ruby.Value) ruby.Value {
	mut test := test_boundary_receiver(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	test.info_header(if args.len > 1 { args[1].as_string() } else { '' })
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/analytics"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   module TestBot
// 9:     class Test
// 10:       include Utils::Output::Mixin
// 11:
// 12:       sig { returns(T::Array[Step]) }
// 13:       def failed_steps
// 14:         @steps.select(&:failed?)
// 15:       end
// 16:
// 17:       sig { returns(T::Array[Step]) }
// 18:       def ignored_steps
// 19:         @steps.select(&:ignored?)
// 20:       end
// 21:
// 22:       sig { returns(T::Array[Step]) }
// 23:       attr_reader :steps
// 24:
// 25:       sig {
// 26:         params(
// 27:           arguments:        T.any(String, Pathname),
// 28:           named_args:       T.nilable(T.any(String, T::Array[String])),
// 29:           env:              T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 30:           verbose:          T::Boolean,
// 31:           ignore_failures:  T::Boolean,
// 32:           report_analytics: T::Boolean,
// 33:         ).returns(Step)
// 34:       }
// 35:       def test(*arguments, named_args: nil, env: {}, verbose: @verbose, ignore_failures: false,
// 36:                report_analytics: false)
// 37:         step = Step.new(
// 38:           arguments.map(&:to_s),
// 39:           named_args:,
// 40:           env:,
// 41:           verbose:,
// 42:           ignore_failures:,
// 43:           repository:      @repository,
// 44:         )
// 45:         step.run(dry_run: @dry_run, fail_fast: @fail_fast)
// 46:         @steps << step
// 47:
// 48:         if ENV["HOMEBREW_TEST_BOT_ANALYTICS"].present? && report_analytics
// 49:           ::Utils::Analytics.report_test_bot_test(step.command_short, step.passed?)
// 50:         end
// 51:
// 52:         step
// 53:       end
// 54:
// 55:       protected
// 56:
// 57:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 58:       def cleanup?(args)
// 59:         Homebrew::TestBot.cleanup?(args)
// 60:       end
// 61:
// 62:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 63:       def local?(args)
// 64:         Homebrew::TestBot.local?(args)
// 65:       end
// 66:
// 67:       private
// 68:
// 69:       sig { returns(T.nilable(Tap)) }
// 70:       attr_reader :tap
// 71:
// 72:       sig { returns(T.nilable(String)) }
// 73:       attr_reader :git
// 74:
// 75:       sig { returns(Pathname) }
// 76:       attr_reader :repository
// 77:
// 78:       sig {
// 79:         params(
// 80:           tap:       T.nilable(Tap),
// 81:           git:       T.nilable(String),
// 82:           dry_run:   T::Boolean,
// 83:           fail_fast: T::Boolean,
// 84:           verbose:   T::Boolean,
// 85:         ).void
// 86:       }
// 87:       def initialize(tap: nil, git: nil, dry_run: false, fail_fast: false, verbose: false)
// 88:         @tap = tap
// 89:         @git = git
// 90:         @dry_run = dry_run
// 91:         @fail_fast = fail_fast
// 92:         @verbose = verbose
// 93:
// 94:         @steps = T.let([], T::Array[Step])
// 95:
// 96:         tap_path = @tap ? @tap.path : CoreTap.instance.path
// 97:         @repository = T.let(tap_path, Pathname)
// 98:       end
// 99:
// 100:       sig { params(klass: Symbol, method: T.nilable(T.any(String, Symbol))).void }
// 101:       def test_header(klass, method: "run!")
// 102:         puts
// 103:         puts Formatter.headline("Running #{klass}##{method}", color: :magenta)
// 104:       end
// 105:
// 106:       sig { params(text: String).void }
// 107:       def info_header(text)
// 108:         puts Formatter.headline(text, color: :cyan)
// 109:       end
// 110:     end
// 111:   end
// 112: end
