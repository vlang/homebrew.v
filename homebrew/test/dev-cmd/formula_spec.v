module dev_cmd

import ruby

// Translated from Homebrew/brew `test/dev-cmd/formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints a given Formula's path", :integration_test do` at line 10.
pub fn ruby_formula_spec_l10_d1_prints(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula path is required')
	}
	path := args[0].as_string()
	output := run_formula_command([path], []) or { return ruby.bool_value(false) }
	return ruby.bool_value(output == '${path}\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/formula"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::FormulaCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints a given Formula's path", :integration_test do
// 11:     formula_file = Formulary.find_formula_in_tap("testball", CoreTap.instance)
// 12:     formula_file.dirname.mkpath
// 13:     formula_file.write ""
// 14:
// 15:     expect { brew "formula", "testball" }
// 16:       .to output("#{formula_file}\n").to_stdout
// 17:       .and not_to_output.to_stderr
// 18:       .and be_a_success
// 19:   end
// 20: end
