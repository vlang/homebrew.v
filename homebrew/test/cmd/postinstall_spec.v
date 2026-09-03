module cmd

import homebrew.cmd as postinstall_core

// Translated from Homebrew/brew `test/cmd/postinstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "runs post-install steps through `FormulaInstaller`" do` at line 10.
pub fn ruby_postinstall_spec_l10_d1_runs() bool {
	result := postinstall_core.run_postinstall_command([
		postinstall_core.PostinstallFormula{
			name: 'foo'
			post_install_steps_defined: true
		},
	], postinstall_core.PostinstallOptions{})
	return result.actions == [
		'Postinstalling foo',
		'install_etc_var:foo',
		'FormulaInstaller.new:foo:debug=false:quiet=false:verbose=false',
		'FormulaInstaller.post_install:foo',
	] && result.warnings.len == 0 && !result.actions.any(it.contains('run_post_install_steps'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/postinstall"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Postinstall do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "runs post-install steps through `FormulaInstaller`" do
// 11:     cmd = described_class.new(["foo"])
// 12:     formula = instance_double(Formula, install_etc_var: nil, post_install_steps_defined?: true,
// 13:                                        post_install_defined?: false, to_s: "foo")
// 14:     installer = instance_double(FormulaInstaller)
// 15:
// 16:     allow(cmd.args.named).to receive(:to_resolved_formulae).and_return([formula])
// 17:     expect(formula).not_to receive(:run_post_install_steps)
// 18:     expect(FormulaInstaller).to receive(:new)
// 19:       .with(formula, debug: false, quiet: false, verbose: false)
// 20:       .ordered
// 21:       .and_return(installer)
// 22:     expect(installer).to receive(:post_install).ordered
// 23:
// 24:     cmd.run
// 25:   end
// 26: end
