module text

import ruby
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/license_arrays_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn license_arrays_spec_formula(declaration string) string {
	return 'class Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\n  ${declaration}\nend'
}

fn license_arrays_spec_analyze(declaration string) line_cops.LinesAnalysis {
	return line_cops.audit_lines_license_arrays(line_cops.LinesContext{
		source: license_arrays_spec_formula(declaration)
	})
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_license_arrays_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LicenseArrays', 'LicenseArrays')
}

// Ruby it `it "reports no offenses for license strings" do` at line 10.
pub fn ruby_license_arrays_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	analysis := license_arrays_spec_analyze('license "MIT"')
	return ruby.bool_value(analysis.offenses.len == 0 && analysis.corrected == license_arrays_spec_formula('license "MIT"'))
}

// Ruby it `it "reports no offenses for license symbols" do` at line 20.
pub fn ruby_license_arrays_spec_l20_d3_reports(args ...ruby.Value) ruby.Value {
	analysis := license_arrays_spec_analyze('license :public_domain')
	return ruby.bool_value(analysis.offenses.len == 0 && analysis.corrected == license_arrays_spec_formula('license :public_domain'))
}

// Ruby it `it "reports no offenses for license hashes" do` at line 30.
pub fn ruby_license_arrays_spec_l30_d4_reports(args ...ruby.Value) ruby.Value {
	analysis := license_arrays_spec_analyze('license any_of: ["MIT", "0BSD"]')
	return ruby.bool_value(analysis.offenses.len == 0 && analysis.corrected == license_arrays_spec_formula('license any_of: ["MIT", "0BSD"]'))
}

// Ruby it `it "reports and corrects use of a license array" do` at line 40.
pub fn ruby_license_arrays_spec_l40_d5_reports(args ...ruby.Value) ruby.Value {
	source := license_arrays_spec_formula('license ["MIT", "0BSD"]')
	corrected := license_arrays_spec_formula('license any_of: ["MIT", "0BSD"]')
	analysis := license_arrays_spec_analyze('license ["MIT", "0BSD"]')
	return ruby.bool_value(analysis.offenses.len == 1 && analysis.offenses[0].message == 'Use `license any_of: ["MIT", "0BSD"]` instead of `license ["MIT", "0BSD"]`' && analysis.offenses[0].replacement == 'license any_of: ["MIT", "0BSD"]' && source[analysis.offenses[0].begin_pos..analysis.offenses[0].end_pos] == 'license ["MIT", "0BSD"]' && analysis.corrected == corrected)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LicenseArrays do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing license arrays" do
// 10:     it "reports no offenses for license strings" do
// 11:       expect_no_offenses(<<~RUBY)
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           license "MIT"
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "reports no offenses for license symbols" do
// 21:       expect_no_offenses(<<~RUBY)
// 22:         class Foo < Formula
// 23:           desc "foo"
// 24:           url 'https://brew.sh/foo-1.0.tgz'
// 25:           license :public_domain
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports no offenses for license hashes" do
// 31:       expect_no_offenses(<<~RUBY)
// 32:         class Foo < Formula
// 33:           desc "foo"
// 34:           url 'https://brew.sh/foo-1.0.tgz'
// 35:           license any_of: ["MIT", "0BSD"]
// 36:         end
// 37:       RUBY
// 38:     end
// 39:
// 40:     it "reports and corrects use of a license array" do
// 41:       expect_offense(<<~RUBY)
// 42:         class Foo < Formula
// 43:           desc "foo"
// 44:           url 'https://brew.sh/foo-1.0.tgz'
// 45:           license ["MIT", "0BSD"]
// 46:           ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/LicenseArrays: Use `license any_of: ["MIT", "0BSD"]` instead of `license ["MIT", "0BSD"]`
// 47:         end
// 48:       RUBY
// 49:
// 50:       expect_correction(<<~RUBY)
// 51:         class Foo < Formula
// 52:           desc "foo"
// 53:           url 'https://brew.sh/foo-1.0.tgz'
// 54:           license any_of: ["MIT", "0BSD"]
// 55:         end
// 56:       RUBY
// 57:     end
// 58:   end
// 59: end
