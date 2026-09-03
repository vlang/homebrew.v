module cmd

import brew_runtime
import homebrew.cmd as production_cmd

// Translated from Homebrew/brew `test/cmd/--prefix_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints Homebrew's prefix", :integration_test do` at line 10.
pub fn ruby_prefix_spec_l10_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '/homebrew' }
	result := production_cmd.run_prefix(production_cmd.PrefixOptions{
		prefix: prefix
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '${prefix}\n')
}

// Ruby it `it "prints the prefix for a Formula" do` at line 17.
pub fn ruby_prefix_spec_l17_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '/homebrew' }
	result := production_cmd.run_prefix(production_cmd.PrefixOptions{
		prefix: prefix
		named: ['testball']
		formulae: [production_cmd.PrefixFormula{
			name: 'testball'
			opt_prefix: '${prefix}/opt/testball'
		}]
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '${prefix}/opt/testball\n')
}

// Ruby it `it "errors if the given Formula doesn't exist" do` at line 27.
pub fn ruby_prefix_spec_l27_d3_errors(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'nonexistent' }
	production_cmd.run_prefix(production_cmd.PrefixOptions{
		named: [name]
		resolution_error: name
	}) or {
		return brew_runtime.bool_value(err.msg().contains('FormulaUnavailableError') && err.msg().contains(name))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "prints a warning when `--installed` is used and the given Formula is not installed" do` at line 35.
pub fn ruby_prefix_spec_l35_d4_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	production_cmd.run_prefix(production_cmd.PrefixOptions{
		installed: true
		named: ['testball']
		formulae: [production_cmd.PrefixFormula{
			name: 'testball'
			opt_prefix: '/homebrew/opt/testball'
		}]
	}) or {
		return brew_runtime.bool_value(err.msg().contains('NotAKegError') && err.msg().contains('testball'))
	}
	return brew_runtime.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/--prefix"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Prefix do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints Homebrew's prefix", :integration_test do
// 11:     expect { brew_sh "--prefix" }
// 12:       .to output("#{ENV.fetch("HOMEBREW_PREFIX")}\n").to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16:
// 17:   it "prints the prefix for a Formula" do
// 18:     cmd = described_class.new(["testball"])
// 19:     allow(cmd.args.named).to receive(:to_resolved_formulae)
// 20:       .and_return([instance_double(Formula, opt_prefix: HOMEBREW_PREFIX/"opt/testball")])
// 21:
// 22:     expect { cmd.run }
// 23:       .to output("#{HOMEBREW_PREFIX}/opt/testball\n").to_stdout
// 24:       .and not_to_output.to_stderr
// 25:   end
// 26:
// 27:   it "errors if the given Formula doesn't exist" do
// 28:     cmd = described_class.new(["nonexistent"])
// 29:     allow(cmd.args.named).to receive(:to_resolved_formulae)
// 30:       .and_raise(FormulaUnavailableError.new("nonexistent"))
// 31:
// 32:     expect { cmd.run }.to raise_error(FormulaUnavailableError, /nonexistent/)
// 33:   end
// 34:
// 35:   it "prints a warning when `--installed` is used and the given Formula is not installed" do
// 36:     cmd = described_class.new(["--installed", "testball"])
// 37:     allow(cmd.args.named).to receive(:to_resolved_formulae).and_return([
// 38:       instance_double(Formula, name: "testball", opt_prefix: HOMEBREW_PREFIX/"opt/testball", optlinked?: false),
// 39:     ])
// 40:
// 41:     expect { cmd.run }
// 42:       .to raise_error(NotAKegError, /testball/)
// 43:   end
// 44: end
