module helper

import ruby

pub struct IntegrationFinding {
pub:
	message string
}

pub struct IntegrationExecPlan {
pub:
	arguments      []string
	flush_coverage bool
}

// Translated from Homebrew/brew `test/support/helper/integration_mocks.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `check_integration_test` at line 7.
pub fn ruby_integration_mocks_l7_d1_check_integration_test(args ...ruby.Value) ruby.Value {
	enabled := if args.len > 0 {
		args[0].bool_data
	} else {
		ruby.environment_value('HOMEBREW_INTEGRATION_TEST') != ''
	}
	if finding := check_integration_test(enabled) {
		return ruby.structured_value('Homebrew::Diagnostic::Finding', finding.message, {
			'message': finding.message
		})
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `exec(*args)` at line 13.
pub fn ruby_integration_mocks_l13_d2_exec(args ...ruby.Value) ruby.Value {
	arguments := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	coverage := if args.len > 1 {
		args[1].bool_data
	} else {
		ruby.environment_value('HOMEBREW_TESTS_COVERAGE') != ''
	}
	integration := if args.len > 2 {
		args[2].bool_data
	} else {
		ruby.environment_value('HOMEBREW_INTEGRATION_TEST') != ''
	}
	plan := integration_exec_plan(arguments, coverage, integration)
	return ruby.map_value({
		'arguments':      ruby.string_array_value(plan.arguments)
		'flush_coverage': ruby.bool_value(plan.flush_coverage)
		'action':         ruby.string_value('Kernel.exec')
	})
}

pub fn check_integration_test(enabled bool) ?IntegrationFinding {
	if !enabled {
		return none
	}
	return IntegrationFinding{ message: 'This is an integration test' }
}

pub fn integration_exec_plan(arguments []string, coverage bool, integration bool) IntegrationExecPlan {
	return IntegrationExecPlan{
		arguments: arguments.clone()
		flush_coverage: coverage && integration
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Diagnostic
// 6:     class Checks
// 7:       def check_integration_test
// 8:         Finding.new("This is an integration test") if ENV["HOMEBREW_INTEGRATION_TEST"]
// 9:       end
// 10:     end
// 11:   end
// 12:
// 13:   def exec(*args)
// 14:     if ENV["HOMEBREW_TESTS_COVERAGE"] && ENV["HOMEBREW_INTEGRATION_TEST"]
// 15:       # Ensure we get coverage results before replacing the current process.
// 16:       SimpleCov.result
// 17:     end
// 18:     Kernel.exec(*args)
// 19:   end
// 20: end
