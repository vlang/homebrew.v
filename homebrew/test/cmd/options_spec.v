module cmd

import brew_runtime
import homebrew.cmd as cmd_core
import homebrew.options as option_types

// Translated from Homebrew/brew `test/cmd/options_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints a given Formula's options", :integration_test do` at line 10.
pub fn ruby_options_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := cmd_core.OptionsFormula{
		full_name: 'testball'
		install_options: [
			option_types.new_option('with-foo', 'Build with foo'),
			option_types.new_option('without-bar', 'Build without bar support'),
		]
	}
	expected := '--with-foo\n\tBuild with foo\n--without-bar\n\tBuild without bar support\n\n'
	return brew_runtime.bool_value(cmd_core.render_formula_options([formula], false) == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/options"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::OptionsCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints a given Formula's options", :integration_test do
// 11:     setup_test_formula "testball", <<~RUBY
// 12:       depends_on "bar" => :recommended
// 13:     RUBY
// 14:
// 15:     expect { brew "options", "testball", "HOMEBREW_REQUIRE_TAP_TRUST" => "1" }
// 16:       .to output("--with-foo\n\tBuild with foo\n--without-bar\n\tBuild without bar support\n\n").to_stdout
// 17:       .and not_to_output.to_stderr
// 18:       .and be_a_success
// 19:   end
// 20: end
