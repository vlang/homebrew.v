module rubocops

import brew_runtime
import homebrew.rubocops as lines

// Translated from Homebrew/brew `test/rubocops/lines_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_lines_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Lines', 'Lines')
}

fn lines_spec_dependency(symbol string, message string) bool {
	source := "class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\n  depends_on :${symbol}\nend"
	analysis := lines.audit_lines_deprecated_dependencies(lines.LinesContext{ source: source })
	return analysis.offenses.len == 1 && analysis.offenses[0].message == message && analysis.corrected == source
}

// Ruby it `it "reports an offense when using depends_on :automake" do` at line 10.
pub fn ruby_lines_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lines_spec_dependency('automake', ':automake is deprecated. Usage should be "automake".'))
}

// Ruby it `it "reports an offense when using depends_on :autoconf" do` at line 20.
pub fn ruby_lines_spec_l20_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lines_spec_dependency('autoconf', ':autoconf is deprecated. Usage should be "autoconf".'))
}

// Ruby it `it "reports an offense when using depends_on :libtool" do` at line 30.
pub fn ruby_lines_spec_l30_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lines_spec_dependency('libtool', ':libtool is deprecated. Usage should be "libtool".'))
}

// Ruby it `it "reports an offense when using depends_on :apr" do` at line 40.
pub fn ruby_lines_spec_l40_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lines_spec_dependency('apr', ':apr is deprecated. Usage should be "apr-util".'))
}

// Ruby it `it "reports an offense when using depends_on :tex" do` at line 50.
pub fn ruby_lines_spec_l50_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lines_spec_dependency('tex', ':tex is deprecated.'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Lines do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing deprecated special dependencies" do
// 10:     it "reports an offense when using depends_on :automake" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           depends_on :automake
// 15:           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Lines: :automake is deprecated. Usage should be "automake".
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "reports an offense when using depends_on :autoconf" do
// 21:       expect_offense(<<~RUBY)
// 22:         class Foo < Formula
// 23:           url 'https://brew.sh/foo-1.0.tgz'
// 24:           depends_on :autoconf
// 25:           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Lines: :autoconf is deprecated. Usage should be "autoconf".
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports an offense when using depends_on :libtool" do
// 31:       expect_offense(<<~RUBY)
// 32:         class Foo < Formula
// 33:           url 'https://brew.sh/foo-1.0.tgz'
// 34:           depends_on :libtool
// 35:           ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Lines: :libtool is deprecated. Usage should be "libtool".
// 36:         end
// 37:       RUBY
// 38:     end
// 39:
// 40:     it "reports an offense when using depends_on :apr" do
// 41:       expect_offense(<<~RUBY)
// 42:         class Foo < Formula
// 43:           url 'https://brew.sh/foo-1.0.tgz'
// 44:           depends_on :apr
// 45:           ^^^^^^^^^^^^^^^ FormulaAudit/Lines: :apr is deprecated. Usage should be "apr-util".
// 46:         end
// 47:       RUBY
// 48:     end
// 49:
// 50:     it "reports an offense when using depends_on :tex" do
// 51:       expect_offense(<<~RUBY)
// 52:         class Foo < Formula
// 53:           url 'https://brew.sh/foo-1.0.tgz'
// 54:           depends_on :tex
// 55:           ^^^^^^^^^^^^^^^ FormulaAudit/Lines: :tex is deprecated.
// 56:         end
// 57:       RUBY
// 58:     end
// 59:   end
// 60: end
