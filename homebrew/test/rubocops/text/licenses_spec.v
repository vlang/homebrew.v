module text

import ruby
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/licenses_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn licenses_spec_formula(declaration string) string {
	indented := declaration.split('\n').map('  ${it}').join('\n')
	return 'class Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\n${indented}\nend'
}

fn licenses_spec_accepts(declaration string) bool {
	source := licenses_spec_formula(declaration)
	analysis := line_cops.audit_lines_licenses(line_cops.LinesContext{
		source: source
	})
	return analysis.offenses.len == 0 && analysis.corrected == source
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_licenses_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::Licenses', 'Licenses')
}

// Ruby it `it "reports no offenses for license strings" do` at line 10.
pub fn ruby_licenses_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(licenses_spec_accepts('license "MIT"'))
}

// Ruby it `it "reports no offenses for license symbols" do` at line 20.
pub fn ruby_licenses_spec_l20_d3_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(licenses_spec_accepts('license :public_domain'))
}

// Ruby it `it "reports no offenses for license hashes" do` at line 30.
pub fn ruby_licenses_spec_l30_d4_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(licenses_spec_accepts('license any_of: ["MIT", "0BSD"]'))
}

// Ruby it `it "reports no offenses for license exceptions" do` at line 40.
pub fn ruby_licenses_spec_l40_d5_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(licenses_spec_accepts('license "MIT" => { with: "LLVM-exception" }'))
}

// Ruby it `it "reports no offenses for multiline nested license hashes" do` at line 50.
pub fn ruby_licenses_spec_l50_d6_reports(args ...ruby.Value) ruby.Value {
	declaration := 'license any_of: [\n  "MIT",\n  all_of: ["0BSD", "Zlib"],\n]'
	return ruby.bool_value(licenses_spec_accepts(declaration))
}

// Ruby it `it "reports no offenses for multiline nested license hashes with exceptions" do` at line 63.
pub fn ruby_licenses_spec_l63_d7_reports(args ...ruby.Value) ruby.Value {
	declaration := 'license any_of: [\n  "MIT",\n  all_of: ["0BSD", "Zlib"],\n  "GPL-2.0-only" => { with: "LLVM-exception" },\n]'
	return ruby.bool_value(licenses_spec_accepts(declaration))
}

// Ruby it `it "reports an offense for nested license hashes on a single line" do` at line 77.
pub fn ruby_licenses_spec_l77_d8_reports(args ...ruby.Value) ruby.Value {
	source := licenses_spec_formula('license any_of: ["MIT", all_of: ["0BSD", "Zlib"]]')
	analysis := line_cops.audit_lines_licenses(line_cops.LinesContext{
		source: source
	})
	return ruby.bool_value(analysis.offenses.len == 1 && analysis.offenses[0].message == 'Split nested license declarations onto multiple lines' && source[analysis.offenses[0].begin_pos..analysis.offenses[0].end_pos] == 'license any_of: ["MIT", all_of: ["0BSD", "Zlib"]]' && analysis.corrected == source)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Licenses do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing licenses" do
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
// 40:     it "reports no offenses for license exceptions" do
// 41:       expect_no_offenses(<<~RUBY)
// 42:         class Foo < Formula
// 43:           desc "foo"
// 44:           url 'https://brew.sh/foo-1.0.tgz'
// 45:           license "MIT" => { with: "LLVM-exception" }
// 46:         end
// 47:       RUBY
// 48:     end
// 49:
// 50:     it "reports no offenses for multiline nested license hashes" do
// 51:       expect_no_offenses(<<~RUBY)
// 52:         class Foo < Formula
// 53:           desc "foo"
// 54:           url 'https://brew.sh/foo-1.0.tgz'
// 55:           license any_of: [
// 56:             "MIT",
// 57:             all_of: ["0BSD", "Zlib"],
// 58:           ]
// 59:         end
// 60:       RUBY
// 61:     end
// 62:
// 63:     it "reports no offenses for multiline nested license hashes with exceptions" do
// 64:       expect_no_offenses(<<~RUBY)
// 65:         class Foo < Formula
// 66:           desc "foo"
// 67:           url 'https://brew.sh/foo-1.0.tgz'
// 68:           license any_of: [
// 69:             "MIT",
// 70:             all_of: ["0BSD", "Zlib"],
// 71:             "GPL-2.0-only" => { with: "LLVM-exception" },
// 72:           ]
// 73:         end
// 74:       RUBY
// 75:     end
// 76:
// 77:     it "reports an offense for nested license hashes on a single line" do
// 78:       expect_offense(<<~RUBY)
// 79:         class Foo < Formula
// 80:           desc "foo"
// 81:           url 'https://brew.sh/foo-1.0.tgz'
// 82:           license any_of: ["MIT", all_of: ["0BSD", "Zlib"]]
// 83:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Licenses: Split nested license declarations onto multiple lines
// 84:         end
// 85:       RUBY
// 86:     end
// 87:   end
// 88: end
