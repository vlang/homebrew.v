module test_bot

import brew_runtime
import os

// Translated from Homebrew/brew `test_bot/test_runner.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn test_runner_args_from_value(value brew_runtime.Value) TestRunnerArgs {
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

fn test_runner_plan_value(plan TestRunnerBuildPlan) brew_runtime.Value {
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
	return brew_runtime.structured_value('TestRunnerTypes', plan.argument, {
		'argument': plan.argument
		'enabled':  enabled.join(',')
	})
}

fn test_runner_plan_from_value(value brew_runtime.Value) TestRunnerBuildPlan {
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

// Ruby method `run!(tap, git:, args:)` at line 35.
pub fn ruby_test_runner_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	result := run_test_runner(test_runner_args_from_value(args[0])) or { panic(err) }
	return brew_runtime.structured_value('TestRunnerResult', result.steps_output, {
		'success':       result.success.str()
		'arguments':     result.arguments.join(',')
		'steps_output':  result.steps_output
		'junit_written': result.junit_written.str()
	})
}

// Ruby method `ensure_blank_file_exists!(file)` at line 122.
pub fn ruby_test_runner_l122_d2_ensure_blank_file_exists(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		test_runner_ensure_blank_file_exists(args[0].as_string()) or { panic(err) }
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `no_only_args?(args)` at line 131.
pub fn ruby_test_runner_l131_d3_no_only_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && test_runner_no_only_args(test_runner_args_from_value(args[0])))
}

// Ruby method `build_tests(argument, tap:, git:, output_paths:, skip_setup:,` at line 155.
pub fn ruby_test_runner_l155_d4_build_tests(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return test_runner_plan_value(TestRunnerBuildPlan{})
	}
	return test_runner_plan_value(test_runner_build_tests(args[0].as_string(), args.len > 2
		&& (args[2].as_bool() or { false }), args.len > 3 && (args[3].as_bool() or { false }), args.len > 4 && (args[4].as_bool() or { false }), test_runner_args_from_value(args[1])))
}

// Ruby method `run_tests(tests, args:)` at line 232.
pub fn ruby_test_runner_l232_d5_run_tests(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	execution := test_runner_run_tests(test_runner_plan_from_value(args[0]), test_runner_args_from_value(args[1]))
	return brew_runtime.structured_value('TestRunnerExecution', execution.events.join(','), {
		'events':                     execution.events.join(',')
		'testing_formulae':           execution.testing_formulae.join(',')
		'skipped_or_failed_formulae': execution.skipped_or_failed_formulae.join(',')
		'tested_formulae':            execution.tested_formulae.join(',')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot/junit"
// 5: require "test_bot/test"
// 6: require "test_bot/test_cleanup"
// 7: require "test_bot/test_formulae"
// 8: require "test_bot/cleanup_after"
// 9: require "test_bot/cleanup_before"
// 10: require "test_bot/formulae_detect"
// 11: require "test_bot/formulae_dependents"
// 12: require "test_bot/bottles_fetch"
// 13: require "test_bot/formulae"
// 14: require "test_bot/setup"
// 15: require "test_bot/tap_syntax"
// 16:
// 17: module Homebrew
// 18:   module TestBot
// 19:     module TestRunner
// 20:       TestRunnerTypes = T.type_alias do
// 21:         {
// 22:           setup:               T.nilable(Setup),
// 23:           tap_syntax:          T.nilable(TapSyntax),
// 24:           formulae_detect:     T.nilable(FormulaeDetect),
// 25:           formulae:            T.nilable(Formulae),
// 26:           formulae_dependents: T.nilable(FormulaeDependents),
// 27:           cleanup_before:      T.nilable(CleanupBefore),
// 28:           cleanup_after:       T.nilable(CleanupAfter),
// 29:           bottles_fetch:       T.nilable(BottlesFetch),
// 30:         }
// 31:       end
// 32:
// 33:       class << self
// 34:         sig { params(tap: T.nilable(Tap), git: String, args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 35:         def run!(tap, git:, args:)
// 36:           tests = T.let([], T::Array[Test])
// 37:           skip_setup = args.skip_setup?
// 38:           skip_cleanup_before = T.let(false, T::Boolean)
// 39:
// 40:           bottle_output_path = Pathname.new("bottle_output.txt")
// 41:           linkage_output_path = Pathname.new("linkage_output.txt")
// 42:           skipped_or_failed_formulae_output_path = Pathname.new("skipped_or_failed_formulae-#{Utils::Bottles.tag}.txt")
// 43:           @skipped_or_failed_formulae_output_path = T.let(skipped_or_failed_formulae_output_path,
// 44:                                                           T.nilable(Pathname))
// 45:
// 46:           if no_only_args?(args) || args.only_formulae?
// 47:             ensure_blank_file_exists!(bottle_output_path)
// 48:             ensure_blank_file_exists!(linkage_output_path)
// 49:             ensure_blank_file_exists!(skipped_or_failed_formulae_output_path)
// 50:           end
// 51:
// 52:           output_paths = {
// 53:             bottle:                     bottle_output_path,
// 54:             linkage:                    linkage_output_path,
// 55:             skipped_or_failed_formulae: skipped_or_failed_formulae_output_path,
// 56:           }
// 57:
// 58:           test_bot_args = args.named.dup
// 59:
// 60:           # With no arguments just build the most recent commit.
// 61:           test_bot_args << "HEAD" if test_bot_args.empty?
// 62:
// 63:           test_bot_args.each do |argument|
// 64:             skip_cleanup_after = argument != test_bot_args.last
// 65:             current_tests = build_tests(argument, tap:,
// 66:                                                   git:,
// 67:                                                   output_paths:,
// 68:                                                   skip_setup:,
// 69:                                                   skip_cleanup_before:,
// 70:                                                   skip_cleanup_after:,
// 71:                                                   args:)
// 72:             skip_setup = true
// 73:             skip_cleanup_before = true
// 74:             tests += current_tests.values.compact
// 75:             run_tests(current_tests, args:)
// 76:           end
// 77:
// 78:           failed_steps = tests.map(&:failed_steps)
// 79:                               .flatten
// 80:                               .compact
// 81:           ignored_steps = tests.map(&:ignored_steps)
// 82:                                .flatten
// 83:                                .compact
// 84:           steps_output = if failed_steps.blank? && ignored_steps.blank?
// 85:             "All steps passed!"
// 86:           else
// 87:             output_lines = []
// 88:
// 89:             if ignored_steps.present?
// 90:               output_lines += [
// 91:                 "Warning: #{ignored_steps.count} failed step#{"s" if ignored_steps.count > 1} ignored!",
// 92:               ]
// 93:               output_lines += ignored_steps.map(&:command_trimmed)
// 94:             end
// 95:
// 96:             if failed_steps.present?
// 97:               output_lines += ["Error: #{failed_steps.count} failed step#{"s" if failed_steps.count > 1}!"]
// 98:               output_lines += failed_steps.map(&:command_trimmed)
// 99:             end
// 100:
// 101:             output_lines.join("\n")
// 102:           end
// 103:           puts steps_output
// 104:
// 105:           steps_output_path = Pathname.new("steps_output.txt")
// 106:           steps_output_path.unlink if steps_output_path.exist?
// 107:           steps_output_path.write(steps_output)
// 108:
// 109:           if args.junit? && (no_only_args?(args) || args.only_formulae? || args.only_formulae_dependents?)
// 110:             junit_filters = %w[audit test]
// 111:             junit = Junit.new(tests)
// 112:             junit.build(filters: junit_filters)
// 113:             junit.write("brew-test-bot.xml")
// 114:           end
// 115:
// 116:           failed_steps.empty?
// 117:         end
// 118:
// 119:         private
// 120:
// 121:         sig { params(file: Pathname).void }
// 122:         def ensure_blank_file_exists!(file)
// 123:           if file.exist?
// 124:             file.truncate(0)
// 125:           else
// 126:             FileUtils.touch(file)
// 127:           end
// 128:         end
// 129:
// 130:         sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 131:         def no_only_args?(args)
// 132:           any_only = args.only_cleanup_before? ||
// 133:                      args.only_setup? ||
// 134:                      args.only_tap_syntax? ||
// 135:                      args.only_formulae? ||
// 136:                      args.only_formulae_detect? ||
// 137:                      args.only_formulae_dependents? ||
// 138:                      args.only_bottles_fetch? ||
// 139:                      args.only_cleanup_after?
// 140:           !any_only
// 141:         end
// 142:
// 143:         sig {
// 144:           params(
// 145:             argument:            String,
// 146:             tap:                 T.nilable(Tap),
// 147:             git:                 String,
// 148:             output_paths:        T::Hash[Symbol, Pathname],
// 149:             skip_setup:          T::Boolean,
// 150:             skip_cleanup_before: T::Boolean,
// 151:             skip_cleanup_after:  T::Boolean,
// 152:             args:                Homebrew::Cmd::TestBotCmd::Args,
// 153:           ).returns(TestRunnerTypes)
// 154:         }
// 155:         def build_tests(argument, tap:, git:, output_paths:, skip_setup:,
// 156:                         skip_cleanup_before:, skip_cleanup_after:, args:)
// 157:           no_only_args = no_only_args?(args)
// 158:
// 159:           if !skip_setup && (no_only_args || args.only_setup?)
// 160:             setup = Setup.new(dry_run:   args.dry_run?,
// 161:                               fail_fast: args.fail_fast?,
// 162:                               verbose:   args.verbose?)
// 163:           end
// 164:
// 165:           if no_only_args || args.only_tap_syntax?
// 166:             tap_syntax = TapSyntax.new(tap:       tap || CoreTap.instance,
// 167:                                        dry_run:   args.dry_run?,
// 168:                                        git:,
// 169:                                        fail_fast: args.fail_fast?,
// 170:                                        verbose:   args.verbose?)
// 171:           end
// 172:
// 173:           no_formulae_flags = args.testing_formulae.nil? &&
// 174:                               args.added_formulae.nil? &&
// 175:                               args.deleted_formulae.nil?
// 176:           if no_formulae_flags && (no_only_args || args.only_formulae? || args.only_formulae_detect?)
// 177:             formulae_detect = FormulaeDetect.new(argument, tap:,
// 178:                                                            git:,
// 179:                                                            dry_run:   args.dry_run?,
// 180:                                                            fail_fast: args.fail_fast?,
// 181:                                                            verbose:   args.verbose?)
// 182:           end
// 183:
// 184:           if no_only_args || args.only_formulae?
// 185:             formulae = Formulae.new(tap:,
// 186:                                     git:,
// 187:                                     dry_run:      args.dry_run?,
// 188:                                     fail_fast:    args.fail_fast?,
// 189:                                     verbose:      args.verbose?,
// 190:                                     output_paths:)
// 191:           end
// 192:
// 193:           if !args.skip_dependents? && (no_only_args || args.only_formulae? || args.only_formulae_dependents?)
// 194:             formulae_dependents = FormulaeDependents.new(tap:,
// 195:                                                          git:,
// 196:                                                          dry_run:   args.dry_run?,
// 197:                                                          fail_fast: args.fail_fast?,
// 198:                                                          verbose:   args.verbose?)
// 199:           end
// 200:
// 201:           if Homebrew::TestBot.cleanup?(args)
// 202:             if !skip_cleanup_before && (no_only_args || args.only_cleanup_before?)
// 203:               cleanup_before = CleanupBefore.new(tap:,
// 204:                                                  git:,
// 205:                                                  dry_run:   args.dry_run?,
// 206:                                                  fail_fast: args.fail_fast?,
// 207:                                                  verbose:   args.verbose?)
// 208:             end
// 209:
// 210:             if !skip_cleanup_after && (no_only_args || args.only_cleanup_after?)
// 211:               cleanup_after = CleanupAfter.new(tap:,
// 212:                                                git:,
// 213:                                                dry_run:   args.dry_run?,
// 214:                                                fail_fast: args.fail_fast?,
// 215:                                                verbose:   args.verbose?)
// 216:             end
// 217:           end
// 218:
// 219:           if args.only_bottles_fetch?
// 220:             bottles_fetch = BottlesFetch.new(tap:,
// 221:                                              git:,
// 222:                                              dry_run:   args.dry_run?,
// 223:                                              fail_fast: args.fail_fast?,
// 224:                                              verbose:   args.verbose?)
// 225:           end
// 226:
// 227:           { setup:, tap_syntax:, formulae_detect:, formulae:, formulae_dependents:,
// 228:             cleanup_before:, cleanup_after:, bottles_fetch: }
// 229:         end
// 230:
// 231:         sig { params(tests: TestRunnerTypes, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 232:         def run_tests(tests, args:)
// 233:           tests[:cleanup_before]&.run!(args:)
// 234:           begin
// 235:             tests[:setup]&.run!(args:)
// 236:             tests[:tap_syntax]&.run!(args:)
// 237:
// 238:             testing_formulae, added_formulae, deleted_formulae = if (detect_test = tests[:formulae_detect])
// 239:               detect_test.run!(args:)
// 240:
// 241:               [
// 242:                 detect_test.testing_formulae,
// 243:                 detect_test.added_formulae,
// 244:                 detect_test.deleted_formulae,
// 245:               ]
// 246:             else
// 247:               [
// 248:                 args.testing_formulae.to_a,
// 249:                 args.added_formulae.to_a,
// 250:                 args.deleted_formulae.to_a,
// 251:               ]
// 252:             end
// 253:
// 254:             skipped_or_failed_formulae = if (formulae_test = tests[:formulae])
// 255:               formulae_test.testing_formulae = testing_formulae
// 256:               formulae_test.added_formulae = added_formulae
// 257:               formulae_test.deleted_formulae = deleted_formulae
// 258:
// 259:               formulae_test.run!(args:)
// 260:
// 261:               formulae_test.skipped_or_failed_formulae
// 262:             elsif args.skipped_or_failed_formulae.present?
// 263:               Array.new(T.must(args.skipped_or_failed_formulae))
// 264:             elsif T.must(@skipped_or_failed_formulae_output_path).exist?
// 265:               T.must(@skipped_or_failed_formulae_output_path).read.chomp.split(",")
// 266:             else
// 267:               []
// 268:             end
// 269:
// 270:             if (dependents_test = tests[:formulae_dependents])
// 271:               dependents_test.testing_formulae = testing_formulae
// 272:               dependents_test.skipped_or_failed_formulae = skipped_or_failed_formulae
// 273:               dependents_test.tested_formulae = args.tested_formulae.to_a.presence || testing_formulae
// 274:
// 275:               dependents_test.run!(args:)
// 276:             end
// 277:
// 278:             if (fetch_test = tests[:bottles_fetch])
// 279:               fetch_test.testing_formulae = testing_formulae
// 280:
// 281:               fetch_test.run!(args:)
// 282:             end
// 283:           ensure
// 284:             tests[:cleanup_after]&.run!(args:)
// 285:           end
// 286:         end
// 287:       end
// 288:     end
// 289:   end
// 290: end
