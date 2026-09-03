module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/test.rb`.
// The original source is retained below until every stub has a typed V body.

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
	formulae              []FormulaTestTarget
	force                 bool
	retry                 bool
	ruby_exec_args        []string
	library_path          string
	options_only          []string
	prefix                string
	existing_var_dirs     []string
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
	formula                  string
	heading                  string
	exec_args                []string
	step                     string
	warn_without_sandbox     bool
	sandbox_log              string
	allow_temp_and_cache     bool
	allow_formula_log        bool
	allow_xcode              bool
	allow_locks              string
	optional_write_paths     []string
	deny_read_home           bool
	deny_network             bool
	attempts                  int
	cache_cleared            bool
	rust_backtrace           string
	environment_restored     bool
	success                   bool
	error                     string
}

pub struct FormulaTestResult {
pub:
	bundler_groups  []string
	setup_path      bool
	required_files  []string
	attempts        []FormulaTestAttempt
	errors          []string
	failed          bool
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
				error_message = if formula.failure_message.len > 0 { formula.failure_message } else { '${formula.full_name}: failed' }
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

pub fn formula_test_input_boundary(input &FormulaTestInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Test::Input', '', {
		'formula_test_input_address': u64(voidptr(input)).str()
	})
}

fn formula_test_input_from_value(value brew_runtime.Value) &FormulaTestInput {
	address := value.attributes['formula_test_input_address'] or { panic('invalid Test input') }
	return unsafe { &FormulaTestInput(voidptr(address.u64())) }
}

fn formula_test_attempt_value(attempt FormulaTestAttempt) brew_runtime.Value {
	return brew_runtime.map_value({
		'formula': brew_runtime.string_value(attempt.formula)
		'heading': brew_runtime.string_value(attempt.heading)
		'exec_args': brew_runtime.string_array_value(attempt.exec_args)
		'step': brew_runtime.string_value(attempt.step)
		'sandbox_log': brew_runtime.string_value(attempt.sandbox_log)
		'optional_write_paths': brew_runtime.string_array_value(attempt.optional_write_paths)
		'deny_read_home': brew_runtime.bool_value(attempt.deny_read_home)
		'deny_network': brew_runtime.bool_value(attempt.deny_network)
		'attempts': brew_runtime.int_value(attempt.attempts)
		'cache_cleared': brew_runtime.bool_value(attempt.cache_cleared)
		'rust_backtrace': brew_runtime.string_value(attempt.rust_backtrace)
		'environment_restored': brew_runtime.bool_value(attempt.environment_restored)
		'success': brew_runtime.bool_value(attempt.success)
		'error': brew_runtime.string_value(attempt.error)
	})
}

fn formula_test_result_value(result FormulaTestResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bundler_groups': brew_runtime.string_array_value(result.bundler_groups)
		'setup_path': brew_runtime.bool_value(result.setup_path)
		'required_files': brew_runtime.string_array_value(result.required_files)
		'attempts': brew_runtime.array_value(result.attempts.map(formula_test_attempt_value(it)))
		'errors': brew_runtime.string_array_value(result.errors)
		'failed': brew_runtime.bool_value(result.failed)
	})
}

// Ruby method `run` at line 33.
pub fn ruby_test_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return formula_test_result_value(run_formula_tests(formula_test_input_from_value(args[0]).options))
}

// Ruby method `retry_test?(formula)` at line 118.
pub fn ruby_test_l118_d2_retry_test(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula is required')
	}
	formula := args[0].as_string()
	retry_enabled := args.len > 1 && (args[1].as_bool() or { false })
	already_failed := args.len > 2 && (args[2].as_bool() or { false })
	result := retry_formula_test(formula, retry_enabled, already_failed)
	return brew_runtime.map_value({
		'retry': brew_runtime.bool_value(result.retry)
		'heading': brew_runtime.string_value(result.heading)
		'clear_cache': brew_runtime.bool_value(result.clear_cache)
		'rust_backtrace': brew_runtime.string_value(result.rust_backtrace)
		'failed': brew_runtime.bool_value(result.failed)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "extend/ENV"
// 6: require "sandbox"
// 7: require "timeout"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class Test < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Run the test method provided by an installed formula.
// 15:           There is no standard output or return code, but generally it should notify the
// 16:           user if something is wrong with the installed formula.
// 17:
// 18:           *Example:* `brew install jruby && brew test jruby`
// 19:         EOS
// 20:         switch "-f", "--force",
// 21:                description: "Test formulae even if they are unlinked."
// 22:         switch "--HEAD",
// 23:                description: "Test the HEAD version of a formula."
// 24:         switch "--keep-tmp",
// 25:                description: "Retain the temporary files created for the test."
// 26:         switch "--retry",
// 27:                description: "Retry if a testing fails."
// 28:
// 29:         named_args :installed_formula, min: 1, without_api: true
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         Homebrew.install_bundler_gems!(groups: ["formula_test"], setup_path: false)
// 35:
// 36:         require "formula_assertions"
// 37:         require "formula_free_port"
// 38:         require "utils/fork"
// 39:
// 40:         optional_prefix_var_dirs = %w[var/cache var/log var/run]
// 41:         args.named.to_resolved_formulae.each do |f|
// 42:           # Cannot test uninstalled formulae
// 43:           unless f.latest_version_installed?
// 44:             ofail "Testing requires the latest version of #{f.full_name}"
// 45:             next
// 46:           end
// 47:
// 48:           # Cannot test formulae without a test method
// 49:           unless f.test_defined?
// 50:             ofail "#{f.full_name} defines no test"
// 51:             next
// 52:           end
// 53:
// 54:           # Don't test unlinked formulae
// 55:           if !args.force? && !f.keg_only? && !f.linked?
// 56:             ofail "#{f.full_name} is not linked"
// 57:             next
// 58:           end
// 59:
// 60:           # Don't test formulae missing test dependencies
// 61:           missing_test_deps = f.recursive_dependencies do |dependent, dependency|
// 62:             next Dependable::PRUNE if dependency.installed?
// 63:             next if dependency.test? && dependent == f
// 64:
// 65:             next Dependable::PRUNE unless dependency.required?
// 66:           end.map(&:to_s)
// 67:           unless missing_test_deps.empty?
// 68:             ofail "#{f.full_name} is missing test dependencies: #{missing_test_deps.join(" ")}"
// 69:             next
// 70:           end
// 71:
// 72:           oh1 "Testing #{f.full_name}"
// 73:
// 74:           env = ENV.to_hash
// 75:
// 76:           begin
// 77:             exec_args = HOMEBREW_RUBY_EXEC_ARGS + %W[
// 78:               --
// 79:               #{HOMEBREW_LIBRARY_PATH}/test.rb
// 80:               #{f.path}
// 81:             ].concat(args.options_only)
// 82:
// 83:             exec_args << "--HEAD" if f.head?
// 84:
// 85:             Sandbox.run_or_fork(
// 86:               *exec_args,
// 87:               step:                 "testing #{f.full_name}",
// 88:               warn_without_sandbox: false,
// 89:             ) do |sandbox|
// 90:               f.logs.mkpath
// 91:               sandbox.record_log(f.logs/"test.sandbox.log")
// 92:               sandbox.allow_write_temp_and_cache
// 93:               sandbox.allow_write_log(f)
// 94:               sandbox.allow_write_xcode
// 95:               sandbox.allow_write_path(HOMEBREW_PREFIX/"var/homebrew/locks")
// 96:               sandbox.deny_read_home
// 97:               optional_prefix_var_dirs.each do |dir|
// 98:                 sandbox.allow_write_path_if_exists HOMEBREW_PREFIX/dir
// 99:               end
// 100:               sandbox.deny_all_network unless f.class.network_access_allowed?(:test)
// 101:             end
// 102:           # Rescue any possible exception types.
// 103:           rescue Exception => e # rubocop:disable Lint/RescueException
// 104:             retry if retry_test?(f)
// 105:
// 106:             require "utils/backtrace"
// 107:             ofail "#{f.full_name}: failed"
// 108:             $stderr.puts e, Utils::Backtrace.clean(e)
// 109:           ensure
// 110:             ENV.replace(env)
// 111:           end
// 112:         end
// 113:       end
// 114:
// 115:       private
// 116:
// 117:       sig { params(formula: Formula).returns(T::Boolean) }
// 118:       def retry_test?(formula)
// 119:         @test_failed ||= T.let(Set.new, T.nilable(T::Set[T.untyped]))
// 120:         if args.retry? && @test_failed.add?(formula)
// 121:           oh1 "Testing #{formula.full_name} (again)"
// 122:           formula.clear_cache
// 123:           ENV["RUST_BACKTRACE"] = "full"
// 124:           true
// 125:         else
// 126:           Homebrew.failed = true
// 127:           false
// 128:         end
// 129:       end
// 130:     end
// 131:   end
// 132: end
