module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/formula_info_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn formula_info_spec_case() bool {
	info := homebrew.formula_info_from_json('{"name":"testball","versions":{"stable":"0.1"},"revision":0,"bottle":{}}', 'arm64_sequoia') or { return false }
	version := info.version('stable') or { return false }
	pkg_version := info.pkg_version('stable') or { return false }
	return info.revision() == 0 && info.bottle_tags().len == 0 && info.bottle_info('arm64_sequoia') == none && info.bottle_info_any() == none && info.any_bottle_tag() == none && version.to_s() == '0.1' && pkg_version == homebrew.new_pkg_version(version, 0)
}

// Ruby it `it "tests the FormulaInfo class" do` at line 7.
pub fn ruby_formula_info_spec_l7_d1_tests(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(formula_info_spec_case())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_info"
// 5:
// 6: RSpec.describe FormulaInfo, :integration_test do
// 7:   it "tests the FormulaInfo class" do
// 8:     formula_path = setup_test_formula "testball"
// 9:     info = T.must(described_class.lookup(formula_path))
// 10:     expect(info).not_to be_nil
// 11:     expect(info.revision).to eq(0)
// 12:     expect(info.bottle_tags).to eq([])
// 13:     expect(info.bottle_info).to be_nil
// 14:     expect(info.bottle_info_any).to be_nil
// 15:     expect(info.any_bottle_tag).to be_nil
// 16:     expect(info.version(:stable).to_s).to eq("0.1")
// 17:
// 18:     version = info.version(:stable)
// 19:     expect(info.pkg_version).to eq(PkgVersion.new(version, 0))
// 20:   end
// 21: end
