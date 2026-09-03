module lines

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/lines/quictls_check_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_quictls_check_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::QuicTLSCheck', 'QuicTLSCheck')
}

// Ruby it `it "reports an offense when a formula depends on `quictls`" do` at line 10.
pub fn ruby_quictls_check_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	analysis := line_cops.audit_lines_quictls(line_cops.LinesContext{ source: 'depends_on "quictls"', tap: 'homebrew-core', formula_name: 'foo' })
	return brew_runtime.bool_value(analysis.offenses.len == 1 && analysis.corrected == 'depends_on "openssl@3"' && analysis.offenses[0].message == 'Formulae in homebrew/core should use `depends_on "openssl@3"` instead of `depends_on "quictls"`.')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::QuicTLSCheck do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula dependencies" do
// 10:     it "reports an offense when a formula depends on `quictls`" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:
// 16:           depends_on "quictls"
// 17:           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/QuicTLSCheck: Formulae in homebrew/core should use `depends_on "openssl@3"` instead of `depends_on "quictls"`.
// 18:         end
// 19:       RUBY
// 20:     end
// 21:   end
// 22: end
