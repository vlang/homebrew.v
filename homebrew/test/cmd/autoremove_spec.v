module cmd

import homebrew.cmd as autoremove_core

// Translated from Homebrew/brew `test/cmd/autoremove_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:requested_formula) { Formula["testball1"] }` at line 11.
pub fn ruby_autoremove_spec_l11_d1_requested_formula() autoremove_core.AutoremoveFormula {
	return autoremove_core.AutoremoveFormula{
		name: 'testball1'
		installed: true
		installed_on_request: true
	}
}

// Ruby let `let(:unused_formula) { Formula["testball2"] }` at line 12.
pub fn ruby_autoremove_spec_l12_d2_unused_formula() autoremove_core.AutoremoveFormula {
	return autoremove_core.AutoremoveFormula{
		name: 'testball2'
		installed: true
		installed_on_request: false
	}
}

// Ruby it `it "only removes unused dependencies", :integration_test do` at line 24.
pub fn ruby_autoremove_spec_l24_d3_only() bool {
	result := autoremove_core.autoremove_formulae([
		ruby_autoremove_spec_l11_d1_requested_formula(),
		ruby_autoremove_spec_l12_d2_unused_formula(),
	], false)
	return result.removed == ['testball2'] && result.retained == ['testball1'] && result.output == 'Autoremoving testball2\n'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/autoremove"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Autoremove do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "integration test" do
// 11:     let(:requested_formula) { Formula["testball1"] }
// 12:     let(:unused_formula) { Formula["testball2"] }
// 13:
// 14:     before do
// 15:       # Make testball1 poured from a bottle
// 16:       tab_attributes = { poured_from_bottle: true, installed_on_request: true }
// 17:       setup_test_formula("testball1", tab_attributes:)
// 18:
// 19:       # Make testball2 poured from a bottle and an unused dependency
// 20:       tab_attributes = { poured_from_bottle: true, installed_on_request: false }
// 21:       setup_test_formula("testball2", tab_attributes:)
// 22:     end
// 23:
// 24:     it "only removes unused dependencies", :integration_test do
// 25:       expect(requested_formula.any_version_installed?).to be true
// 26:       expect(unused_formula.any_version_installed?).to be true
// 27:
// 28:       # When there are unused dependencies
// 29:       expect { brew "autoremove" }
// 30:         .to be_a_success
// 31:         .and output(/Autoremoving/).to_stdout
// 32:         .and not_to_output.to_stderr
// 33:
// 34:       expect(requested_formula.any_version_installed?).to be true
// 35:       expect(unused_formula.any_version_installed?).to be false
// 36:     end
// 37:   end
// 38: end
