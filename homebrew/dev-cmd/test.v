module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/test.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 33.
pub fn ruby_test_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `retry_test?(formula)` at line 118.
pub fn ruby_test_l118_d2_retry_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retry_test?', ...args)
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
