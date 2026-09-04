module text

import ruby
import homebrew.rubocops as mpi_core

// Translated from Homebrew/brew `test/rubocops/text/mpi_check_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_mpi_check_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::MpiCheck', 'FormulaAudit/MpiCheck')
}

// Ruby it `it "reports and corrects an offense when using depends_on \"mpich\" in homebrew/core" do` at line 10.
pub fn ruby_mpi_check_spec_l10_d2_reports() bool {
	source := 'class Foo < Formula\n  depends_on "mpich"\nend'
	analysis := mpi_core.audit_lines_mpi(mpi_core.LinesContext{
		source: source
		tap: 'homebrew-core'
	})
	return analysis.offenses.len == 1 && analysis.corrected == 'class Foo < Formula\n  depends_on "open-mpi"\nend'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::MpiCheck do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing MPI dependencies" do
// 10:     it "reports and corrects an offense when using depends_on \"mpich\" in homebrew/core" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           depends_on "mpich"
// 16:           ^^^^^^^^^^^^^^^^^^ FormulaAudit/MpiCheck: Formulae in homebrew/core should use `depends_on "open-mpi"` instead of `depends_on "mpich"`.
// 17:         end
// 18:       RUBY
// 19:
// 20:       expect_correction(<<~RUBY)
// 21:         class Foo < Formula
// 22:           desc "foo"
// 23:           url 'https://brew.sh/foo-1.0.tgz'
// 24:           depends_on "open-mpi"
// 25:         end
// 26:       RUBY
// 27:     end
// 28:   end
// 29: end
