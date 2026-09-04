module class

import ruby
import homebrew.rubocops as class_core

// Translated from Homebrew/brew `test/rubocops/class/class_name_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_class_name_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::ClassName', 'FormulaAudit/ClassName')
}

// Ruby let `let(:corrected_source) do` at line 9.
pub fn ruby_class_name_spec_l9_d2_corrected_source() string {
	return "class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\nend\n"
}

fn class_name_deprecated_case(parent string) bool {
	source := "class Foo < ${parent}\n  url 'https://brew.sh/foo-1.0.tgz'\nend\n"
	return class_core.audit_formula_class_name(source).map(it.kind) == [
		'deprecated_class',
	] && class_core.correct_formula_class_name(source) == ruby_class_name_spec_l9_d2_corrected_source()
}

// Ruby it `it "reports and corrects an offense when using ScriptFileFormula" do` at line 17.
pub fn ruby_class_name_spec_l17_d3_reports() bool {
	return class_name_deprecated_case('ScriptFileFormula')
}

// Ruby it `it "reports and corrects an offense when using GithubGistFormula" do` at line 27.
pub fn ruby_class_name_spec_l27_d4_reports() bool {
	return class_name_deprecated_case('GithubGistFormula')
}

// Ruby it `it "reports and corrects an offense when using AmazonWebServicesFormula" do` at line 37.
pub fn ruby_class_name_spec_l37_d5_reports() bool {
	return class_name_deprecated_case('AmazonWebServicesFormula')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/class"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ClassName do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   let(:corrected_source) do
// 10:     <<~RUBY
// 11:       class Foo < Formula
// 12:         url 'https://brew.sh/foo-1.0.tgz'
// 13:       end
// 14:     RUBY
// 15:   end
// 16:
// 17:   it "reports and corrects an offense when using ScriptFileFormula" do
// 18:     expect_offense(<<~RUBY)
// 19:       class Foo < ScriptFileFormula
// 20:                   ^^^^^^^^^^^^^^^^^ FormulaAudit/ClassName: `ScriptFileFormula` is deprecated, use `Formula` instead
// 21:         url 'https://brew.sh/foo-1.0.tgz'
// 22:       end
// 23:     RUBY
// 24:     expect_correction(corrected_source)
// 25:   end
// 26:
// 27:   it "reports and corrects an offense when using GithubGistFormula" do
// 28:     expect_offense(<<~RUBY)
// 29:       class Foo < GithubGistFormula
// 30:                   ^^^^^^^^^^^^^^^^^ FormulaAudit/ClassName: `GithubGistFormula` is deprecated, use `Formula` instead
// 31:         url 'https://brew.sh/foo-1.0.tgz'
// 32:       end
// 33:     RUBY
// 34:     expect_correction(corrected_source)
// 35:   end
// 36:
// 37:   it "reports and corrects an offense when using AmazonWebServicesFormula" do
// 38:     expect_offense(<<~RUBY)
// 39:       class Foo < AmazonWebServicesFormula
// 40:                   ^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/ClassName: `AmazonWebServicesFormula` is deprecated, use `Formula` instead
// 41:         url 'https://brew.sh/foo-1.0.tgz'
// 42:       end
// 43:     RUBY
// 44:     expect_correction(corrected_source)
// 45:   end
// 46: end
