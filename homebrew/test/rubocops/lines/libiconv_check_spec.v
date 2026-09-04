module lines

import ruby
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/lines/libiconv_check_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_libiconv_check_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LibiconvCheck', 'LibiconvCheck')
}

// Ruby it `it "reports an offense when a formula depends on `libiconv`" do` at line 10.
pub fn ruby_libiconv_check_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	analysis := line_cops.audit_lines_libiconv(line_cops.LinesContext{ source: 'depends_on "libiconv"', tap: 'homebrew-core', formula_name: 'foo' })
	return ruby.bool_value(analysis.offenses.len == 1 && analysis.offenses[0].message == 'Formulae in homebrew/core should not use `depends_on "libiconv"`.')
}

// Ruby it `it "reports no offenses for `neomutt`" do` at line 22.
pub fn ruby_libiconv_check_spec_l22_d3_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(line_cops.audit_lines_libiconv(line_cops.LinesContext{ source: 'depends_on "libiconv"', tap: 'homebrew-core', formula_name: 'neomutt' }).offenses.len == 0)
}

// Ruby it `it "reports no offenses for libiconv dependencies" do` at line 35.
pub fn ruby_libiconv_check_spec_l35_d4_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(line_cops.audit_lines_libiconv(line_cops.LinesContext{ source: 'depends_on "libiconv"', tap: 'homebrew-cask', formula_name: 'foo' }).offenses.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LibiconvCheck do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing libiconv dependencies in homebrew/core" do
// 10:     it "reports an offense when a formula depends on `libiconv`" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:
// 16:           depends_on "libiconv"
// 17:           ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/LibiconvCheck: Formulae in homebrew/core should not use `depends_on "libiconv"`.
// 18:         end
// 19:       RUBY
// 20:     end
// 21:
// 22:     it "reports no offenses for `neomutt`" do
// 23:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/n/neomutt.rb")
// 24:         class Neomutt < Formula
// 25:           desc "neomutt"
// 26:           url 'https://brew.sh/neomutt-1.0.tgz'
// 27:
// 28:           depends_on "libiconv"
// 29:         end
// 30:       RUBY
// 31:     end
// 32:   end
// 33:
// 34:   context "when auditing outside homebrew/core" do
// 35:     it "reports no offenses for libiconv dependencies" do
// 36:       expect_no_offenses(<<~RUBY, "/homebrew-cask/Formula/foo.rb")
// 37:         class Foo < Formula
// 38:           desc "foo"
// 39:           url 'https://brew.sh/foo-1.0.tgz'
// 40:
// 41:           depends_on "libiconv"
// 42:         end
// 43:       RUBY
// 44:     end
// 45:   end
// 46: end
