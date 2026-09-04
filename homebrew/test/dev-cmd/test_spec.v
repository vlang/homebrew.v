module dev_cmd

import ruby

// Translated from Homebrew/brew `test/dev-cmd/test_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "tests a given Formula", :integration_test do` at line 11.
pub fn ruby_test_spec_l11_d1_tests(args ...ruby.Value) ruby.Value {
	_ = args
	result := run_formula_tests(FormulaTestOptions{
		formulae: [FormulaTestTarget{
			full_name: 'testball'
			path: '/formula/testball.rb'
			logs: '/logs/testball'
			latest_version_installed: true
			test_defined: true
			linked: true
		}]
	})
	return ruby.bool_value(!result.failed && result.attempts.len == 1
		&& result.attempts[0].heading == 'Testing testball')
}

// Ruby it `it "blocks network access when test phase is offline", :integration_test do` at line 35.
pub fn ruby_test_spec_l35_d2_blocks(args ...ruby.Value) ruby.Value {
	_ = args
	result := run_formula_tests(FormulaTestOptions{
		formulae: [FormulaTestTarget{
			full_name: 'testball_offline_test'
			path: '/formula/testball_offline_test.rb'
			logs: '/logs/testball_offline_test'
			latest_version_installed: true
			test_defined: true
			linked: true
			network_access_allowed: false
			test_failures: 1
			failure_message: 'curl: (6) Could not resolve host: example.org'
		}]
	})
	return ruby.bool_value(result.failed && result.attempts[0].deny_network
		&& result.errors.any(it.contains('Could not resolve host')))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/test"
// 6: require "sandbox"
// 7:
// 8: RSpec.describe Homebrew::DevCmd::Test do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   it "tests a given Formula", :integration_test do
// 12:     skip "Nested sandboxing is not supported." if Sandbox.nested_sandbox?
// 13:
// 14:     setup_test_formula "testball", <<~'RUBY', tab_attributes: { installed_on_request: true }
// 15:       test do
// 16:         assert_equal "test", shell_output("#{bin}/test")
// 17:       end
// 18:     RUBY
// 19:     formula_prefix = Formula["testball"].prefix
// 20:     (formula_prefix/"bin").mkpath
// 21:     (formula_prefix/"bin/test").write <<~SH
// 22:       #!/bin/sh
// 23:       printf test
// 24:     SH
// 25:     (formula_prefix/"bin/test").chmod 0755
// 26:     HOMEBREW_LINKED_KEGS.mkpath
// 27:     (HOMEBREW_LINKED_KEGS/"testball").make_relative_symlink(formula_prefix)
// 28:
// 29:     expect { brew "test", "--verbose", "testball", "HOMEBREW_NO_INSTALL_FROM_API" => "1" }
// 30:       .to output(/Testing testball/).to_stdout
// 31:       .and not_to_output.to_stderr
// 32:       .and be_a_success
// 33:   end
// 34:
// 35:   it "blocks network access when test phase is offline", :integration_test do
// 36:     skip "Sandbox not available." unless Sandbox.available?
// 37:     skip "Nested sandboxing is not supported." if Sandbox.nested_sandbox?
// 38:
// 39:     formula_name = "testball_offline_test"
// 40:     setup_test_formula formula_name, <<~RUBY, tab_attributes: { installed_on_request: true }
// 41:       deny_network_access! :test
// 42:       test do
// 43:         system "curl", "example.org"
// 44:       end
// 45:     RUBY
// 46:     HOMEBREW_LINKED_KEGS.mkpath
// 47:     (HOMEBREW_LINKED_KEGS/formula_name).make_relative_symlink(Formula[formula_name].prefix)
// 48:
// 49:     expect { brew "test", "--verbose", formula_name, "HOMEBREW_NO_INSTALL_FROM_API" => "1" }
// 50:       .to output(/curl: \((?:6\) Could not resolve host:|7\) Failed to connect to) example\.org/).to_stdout
// 51:       .and be_a_failure
// 52:   end
// 53: end
