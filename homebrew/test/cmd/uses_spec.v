module cmd

import ruby
import homebrew.cmd as uses_cmd

fn uses_spec_dependency(name string, optional bool) uses_cmd.DepsItem {
	return uses_cmd.DepsItem{
		kind: .dependency
		name: name
		full_name: name
		optional: optional
	}
}

fn uses_spec_formula(name string, dependencies []uses_cmd.DepsItem,
	installed bool) uses_cmd.DepsDependent {
	return uses_cmd.DepsDependent{
		kind: .formula
		name: name
		full_name: name
		deps: dependencies
		any_version_installed: installed
	}
}

// Translated from Homebrew/brew `test/cmd/uses_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses tap trust configuration to evaluate all formulae" do` at line 14.
pub fn ruby_uses_spec_l14_d1_uses(args ...ruby.Value) ruby.Value {
	used_formula := uses_cmd.UsesFormula{
		name: 'foo'
		full_name: 'foo'
	}
	result := uses_cmd.run_uses_command(uses_cmd.UsesCommandInput{
		options: uses_cmd.UsesCommandOptions{
			formula: true
			tap_trust_configured: true
		}
		named: ['foo']
		used_formulae: [used_formula]
	})
	return ruby.bool_value(!result.failed && result.stdout == '' && result.stderr == ''
		&& result.formula_all_called && result.formula_all_eval_all)
}

// Ruby it `it "handles unavailable formula" do` at line 25.
pub fn ruby_uses_spec_l25_d2_handles(args ...ruby.Value) ruby.Value {
	bar := uses_spec_formula('bar', [uses_spec_dependency('foo', false)], false)
	optional := uses_spec_formula('optional', [uses_spec_dependency('foo', true)], false)
	result := uses_cmd.run_uses_command(uses_cmd.UsesCommandInput{
		options: uses_cmd.UsesCommandOptions{
			recursive: true
			include_optional: true
			tap_trust_configured: true
		}
		named: ['foo']
		formula_unavailable_error: 'foo'
		all_formulae: [bar, optional]
	})
	return ruby.bool_value(result.failed && result.stdout == 'bar\noptional\n'
		&& result.stderr.contains('Error: Missing formulae should not have dependents!\n')
		&& result.error == 'Missing formulae should not have dependents!')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/named_args"
// 5: require "cmd/shared_examples/args_parse"
// 6: require "cmd/uses"
// 7: require "fileutils"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Uses do
// 10:   include FileUtils
// 11:
// 12:   it_behaves_like "parseable arguments"
// 13:
// 14:   it "uses tap trust configuration to evaluate all formulae" do
// 15:     used_formula = instance_double(Formula, full_name: "foo")
// 16:     cmd = described_class.new(["--formula", "foo"])
// 17:
// 18:     allow(cmd.args.named).to receive(:to_formulae).and_return([used_formula])
// 19:     expect(Formula).to receive(:all).with(eval_all: true).and_return([])
// 20:
// 21:     expect { with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") { cmd.run } }
// 22:       .to not_to_output.to_stderr
// 23:   end
// 24:
// 25:   it "handles unavailable formula" do
// 26:     cmd = described_class.new(%w[foo --include-optional --recursive])
// 27:     allow(cmd.args.named)
// 28:       .to receive(:to_formulae)
// 29:       .and_raise(FormulaUnavailableError, "foo")
// 30:     allow(cmd).to receive(:intersection_of_dependents)
// 31:       .and_return([
// 32:         instance_double(Formula, full_name: "bar"),
// 33:         instance_double(Formula, full_name: "optional"),
// 34:       ])
// 35:
// 36:     allow(Homebrew::Trust).to receive(:trusted?).and_return(true)
// 37:
// 38:     expect { cmd.run }
// 39:       .to output(/^(bar\noptional|optional\nbar)$/).to_stdout
// 40:       .and output(/Error: Missing formulae should not have dependents!\n/).to_stderr
// 41:       .and raise_error SystemExit
// 42:   end
// 43: end
