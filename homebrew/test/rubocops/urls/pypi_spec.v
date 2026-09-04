module urls

import ruby
import homebrew.rubocops as urls_core

// Translated from Homebrew/brew `test/rubocops/urls/pypi_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn pypi_spec_audit(url string) urls_core.FormulaUrlsAnalysis {
	source := 'class Foo < Formula\n  desc "foo"\n  url "${url}"\nend'
	return urls_core.audit_formula_pypi_urls(urls_core.FormulaUrlsContext{ source: source })
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_pypi_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::PyPiUrls', 'FormulaAudit/PyPiUrls')
}

// Ruby it `it "reports an offense for pypi.python.org urls" do` at line 10.
pub fn ruby_pypi_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	offenses := pypi_spec_audit('https://pypi.python.org/packages/source/foo/foo-0.1.tar.gz').offenses
	return ruby.bool_value(offenses.len == 1 && offenses[0].message == 'Use the "Source" URL found on the PyPI downloads page (https://pypi.org/project/foo/#files)')
}

// Ruby it `it "reports an offense for short file.pythonhosted.org urls" do` at line 20.
pub fn ruby_pypi_spec_l20_d3_reports(args ...ruby.Value) ruby.Value {
	offenses := pypi_spec_audit('https://files.pythonhosted.org/packages/source/f/foo/foo-0.1.tar.gz').offenses
	return ruby.bool_value(offenses.len == 1 && offenses[0].message == 'Use the "Source" URL found on the PyPI downloads page (https://pypi.org/project/foo/#files)')
}

// Ruby it `it "reports no offenses for long file.pythonhosted.org urls" do` at line 30.
pub fn ruby_pypi_spec_l30_d4_reports(args ...ruby.Value) ruby.Value {
	url := 'https://files.pythonhosted.org/packages/a0/b1/a01b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f/foo-0.1.tar.gz'
	return ruby.bool_value(pypi_spec_audit(url).offenses.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/urls"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::PyPiUrls do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when a pypi URL is used" do
// 10:     it "reports an offense for pypi.python.org urls" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url "https://pypi.python.org/packages/source/foo/foo-0.1.tar.gz"
// 15:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/PyPiUrls: Use the "Source" URL found on the PyPI downloads page (https://pypi.org/project/foo/#files)
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "reports an offense for short file.pythonhosted.org urls" do
// 21:       expect_offense(<<~RUBY)
// 22:         class Foo < Formula
// 23:           desc "foo"
// 24:           url "https://files.pythonhosted.org/packages/source/f/foo/foo-0.1.tar.gz"
// 25:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/PyPiUrls: Use the "Source" URL found on the PyPI downloads page (https://pypi.org/project/foo/#files)
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports no offenses for long file.pythonhosted.org urls" do
// 31:       expect_no_offenses(<<~RUBY)
// 32:         class Foo < Formula
// 33:           desc "foo"
// 34:           url "https://files.pythonhosted.org/packages/a0/b1/a01b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f/foo-0.1.tar.gz"
// 35:         end
// 36:       RUBY
// 37:     end
// 38:   end
// 39: end
