module services

import ruby
import homebrew.services as services_core

// Translated from Homebrew/brew `test/services/formulae_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "empty list without available formulae" do` at line 8.
pub fn ruby_formulae_spec_l8_d1_empty(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(services_core.services_list([]services_core.ServiceFormula{}).len == 0)
}

// Ruby it `it "list with available formulae" do` at line 13.
pub fn ruby_formulae_spec_l13_d2_list(args ...ruby.Value) ruby.Value {
	formula := services_core.ServiceFormula{
		name: 'formula'
		has_service: true
		owner: 'root'
		file: '/Library/LaunchDaemons/file.plist'
		status: 'known'
		user: 'root'
	}
	result := services_core.services_list([formula])
	return ruby.bool_value(result == [services_core.ServiceFormulaStatus{
		file: '/Library/LaunchDaemons/file.plist'
		name: 'formula'
		status: 'known'
		user: 'root'
	}])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/formulae"
// 5:
// 6: RSpec.describe Homebrew::Services::Formulae do
// 7:   describe "#services_list" do
// 8:     it "empty list without available formulae" do
// 9:       allow(described_class).to receive(:available_services).and_return({})
// 10:       expect(described_class.services_list).to eq([])
// 11:     end
// 12:
// 13:     it "list with available formulae" do
// 14:       formula = instance_double(Homebrew::Services::FormulaWrapper)
// 15:       expected = [
// 16:         {
// 17:           file:   Pathname.new("/Library/LaunchDaemons/file.plist"),
// 18:           name:   "formula",
// 19:           status: :known,
// 20:           user:   "root",
// 21:         },
// 22:       ]
// 23:
// 24:       expect(formula).to receive(:to_hash).and_return(expected[0])
// 25:       allow(described_class).to receive(:available_services).and_return([formula])
// 26:       expect(described_class.services_list).to eq(expected)
// 27:     end
// 28:   end
// 29: end
