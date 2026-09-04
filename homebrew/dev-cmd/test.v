module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/test.rb`.

pub struct FormulaTestTarget {
pub:
	full_name                 string
	path                      string
	logs                      string
	head                      bool
	latest_version_installed  bool
	test_defined              bool
	keg_only                  bool
	linked                    bool
	missing_test_dependencies []string
	network_access_allowed    bool = true
	test_failures             int
	failure_message           string
}

pub struct FormulaTestOptions {
pub:
	formulae          []FormulaTestTarget
	force             bool
	retry             bool
	ruby_exec_args    []string
	library_path      string
	options_only      []string
	prefix            string
	existing_var_dirs []string
}

pub struct RetryTestResult {
pub:
	retry          bool
	heading        string
	clear_cache    bool
	rust_backtrace string
	failed         bool
}

pub struct FormulaTestAttempt {
pub:
	formula              string
	heading              string
	exec_args            []string
	step                 string
	warn_without_sandbox bool
	sandbox_log          string
	allow_temp_and_cache bool
	allow_formula_log    bool
	allow_xcode          bool
	allow_locks          string
	optional_write_paths []string
	deny_read_home       bool
	deny_network         bool
	attempts             int
	cache_cleared        bool
	rust_backtrace       string
	environment_restored bool
	success              bool
	error                string
}

pub struct FormulaTestResult {
pub:
	bundler_groups []string
	setup_path     bool
	required_files []string
	attempts       []FormulaTestAttempt
	errors         []string
	failed         bool
}

pub fn retry_formula_test(formula string, retry_enabled bool, already_failed bool) RetryTestResult {
	if retry_enabled && !already_failed {
		return RetryTestResult{
			retry: true
			heading: 'Testing ${formula} (again)'
			clear_cache: true
			rust_backtrace: 'full'
		}
	}
	return RetryTestResult{
		failed: true
	}
}

pub fn run_formula_tests(options FormulaTestOptions) FormulaTestResult {
	mut attempts := []FormulaTestAttempt{}
	mut errors := []string{}
	mut failed := false
	for formula in options.formulae {
		if !formula.latest_version_installed {
			errors << 'Testing requires the latest version of ${formula.full_name}'
			failed = true
			continue
		}
		if !formula.test_defined {
			errors << '${formula.full_name} defines no test'
			failed = true
			continue
		}
		if !options.force && !formula.keg_only && !formula.linked {
			errors << '${formula.full_name} is not linked'
			failed = true
			continue
		}
		if formula.missing_test_dependencies.len > 0 {
			errors << '${formula.full_name} is missing test dependencies: ${formula.missing_test_dependencies.join(' ')}'
			failed = true
			continue
		}
		mut exec_args := options.ruby_exec_args.clone()
		exec_args << ['--', '${options.library_path}/test.rb', formula.path]
		exec_args << options.options_only
		if formula.head {
			exec_args << '--HEAD'
		}
		mut optional_write_paths := []string{}
		for directory in ['var/cache', 'var/log', 'var/run'] {
			path := '${options.prefix}/${directory}'
			if path in options.existing_var_dirs {
				optional_write_paths << path
			}
		}
		mut attempt_count := 1
		mut cache_cleared := false
		mut rust_backtrace := ''
		mut success := formula.test_failures == 0
		mut error_message := ''
		if !success {
			retry_result := retry_formula_test(formula.full_name, options.retry, false)
			if retry_result.retry {
				attempt_count++
				cache_cleared = retry_result.clear_cache
				rust_backtrace = retry_result.rust_backtrace
				success = formula.test_failures < 2
			}
			if !success {
				failed = true
				error_message = if formula.failure_message.len > 0 {
					formula.failure_message
				} else {
					'${formula.full_name}: failed'
				}
				errors << '${formula.full_name}: failed'
				if formula.failure_message.len > 0 {
					errors << formula.failure_message
				}
			}
		}
		attempts << FormulaTestAttempt{
			formula: formula.full_name
			heading: 'Testing ${formula.full_name}'
			exec_args: exec_args
			step: 'testing ${formula.full_name}'
			warn_without_sandbox: false
			sandbox_log: '${formula.logs}/test.sandbox.log'
			allow_temp_and_cache: true
			allow_formula_log: true
			allow_xcode: true
			allow_locks: '${options.prefix}/var/homebrew/locks'
			optional_write_paths: optional_write_paths
			deny_read_home: true
			deny_network: !formula.network_access_allowed
			attempts: attempt_count
			cache_cleared: cache_cleared
			rust_backtrace: rust_backtrace
			environment_restored: true
			success: success
			error: error_message
		}
	}
	return FormulaTestResult{
		bundler_groups: ['formula_test']
		setup_path: false
		required_files: ['formula_assertions', 'formula_free_port', 'utils/fork']
		attempts: attempts
		errors: errors
		failed: failed
	}
}

@[heap]
pub struct FormulaTestInput {
pub:
	options FormulaTestOptions
}

pub fn formula_test_input_boundary(input &FormulaTestInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Test::Input', '', {
		'formula_test_input_address': u64(voidptr(input)).str()
	})
}

fn formula_test_input_from_value(value ruby.Value) &FormulaTestInput {
	address := value.attributes['formula_test_input_address'] or { panic('invalid Test input') }
	return unsafe { &FormulaTestInput(voidptr(address.u64())) }
}

fn formula_test_attempt_value(attempt FormulaTestAttempt) ruby.Value {
	return ruby.map_value({
		'formula':              ruby.string_value(attempt.formula)
		'heading':              ruby.string_value(attempt.heading)
		'exec_args':            ruby.string_array_value(attempt.exec_args)
		'step':                 ruby.string_value(attempt.step)
		'sandbox_log':          ruby.string_value(attempt.sandbox_log)
		'optional_write_paths': ruby.string_array_value(attempt.optional_write_paths)
		'deny_read_home':       ruby.bool_value(attempt.deny_read_home)
		'deny_network':         ruby.bool_value(attempt.deny_network)
		'attempts':             ruby.int_value(attempt.attempts)
		'cache_cleared':        ruby.bool_value(attempt.cache_cleared)
		'rust_backtrace':       ruby.string_value(attempt.rust_backtrace)
		'environment_restored': ruby.bool_value(attempt.environment_restored)
		'success':              ruby.bool_value(attempt.success)
		'error':                ruby.string_value(attempt.error)
	})
}

fn formula_test_result_value(result FormulaTestResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups': ruby.string_array_value(result.bundler_groups)
		'setup_path':     ruby.bool_value(result.setup_path)
		'required_files': ruby.string_array_value(result.required_files)
		'attempts':       ruby.array_value(result.attempts.map(formula_test_attempt_value(it)))
		'errors':         ruby.string_array_value(result.errors)
		'failed':         ruby.bool_value(result.failed)
	})
}
