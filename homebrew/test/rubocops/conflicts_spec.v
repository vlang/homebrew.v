module rubocops

import brew_runtime
import homebrew.rubocops as conflicts_core

// Translated from Homebrew/brew `test/rubocops/conflicts_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_conflicts_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Conflicts', 'FormulaAudit/Conflicts')
}

// Ruby it `it "reports and corrects an offense if reason is capitalized" do` at line 10.
pub fn ruby_conflicts_spec_l10_d2_reports() bool {
	source := 'conflicts_with "bar", :because => "Reason"\nconflicts_with "baz", :because => "Foo is the formula name which does not require downcasing"'
	problems := conflicts_core.audit_formula_conflicts(source, 'Foo', false, false)
	return problems.len == 1 && problems[0].kind == 'capitalized_reason' && conflicts_core.correct_formula_conflicts(source, 'Foo', false, false).starts_with('conflicts_with "bar", :because => "reason"')
}

// Ruby it `it "reports and corrects an offense if reason ends with a period" do` at line 29.
pub fn ruby_conflicts_spec_l29_d3_reports() bool {
	source := 'conflicts_with "bar", "baz", :because => "reason."'
	problems := conflicts_core.audit_formula_conflicts(source, 'Foo', false, false)
	return problems.len == 1 && problems[0].kind == 'trailing_period' && conflicts_core.correct_formula_conflicts(source, 'Foo', false, false) == 'conflicts_with "bar", "baz", :because => "reason"'
}

// Ruby it `it "reports an offense if it is present in a versioned formula" do` at line 46.
pub fn ruby_conflicts_spec_l46_d4_reports() bool {
	source := 'conflicts_with "mysql", "mariadb"'
	problems := conflicts_core.audit_formula_conflicts(source, 'Foo', true, false)
	return problems.len == 1 && problems[0].message == conflicts_core.conflicts_versioned_formula_message && conflicts_core.correct_formula_conflicts(source, 'Foo', true, false) == 'keg_only :versioned_formula'
}

// Ruby it `it "reports no offenses if it is not present" do` at line 56.
pub fn ruby_conflicts_spec_l56_d5_reports() bool {
	return conflicts_core.audit_formula_conflicts('homepage "https://brew.sh"', 'Foo', true, false).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/conflicts"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Conflicts do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing `conflicts_with`" do
// 10:     it "reports and corrects an offense if reason is capitalized" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo < Formula
// 13:           url "https://brew.sh/foo-1.0.tgz"
// 14:           conflicts_with "bar", :because => "Reason"
// 15:                                             ^^^^^^^^ FormulaAudit/Conflicts: 'Reason' from the `conflicts_with` reason should be 'reason'.
// 16:           conflicts_with "baz", :because => "Foo is the formula name which does not require downcasing"
// 17:         end
// 18:       RUBY
// 19:
// 20:       expect_correction(<<~RUBY)
// 21:         class Foo < Formula
// 22:           url "https://brew.sh/foo-1.0.tgz"
// 23:           conflicts_with "bar", :because => "reason"
// 24:           conflicts_with "baz", :because => "Foo is the formula name which does not require downcasing"
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports and corrects an offense if reason ends with a period" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           url "https://brew.sh/foo-1.0.tgz"
// 33:           conflicts_with "bar", "baz", :because => "reason."
// 34:                                                    ^^^^^^^^^ FormulaAudit/Conflicts: `conflicts_with` reason should not end with a period.
// 35:         end
// 36:       RUBY
// 37:
// 38:       expect_correction(<<~RUBY)
// 39:         class Foo < Formula
// 40:           url "https://brew.sh/foo-1.0.tgz"
// 41:           conflicts_with "bar", "baz", :because => "reason"
// 42:         end
// 43:       RUBY
// 44:     end
// 45:
// 46:     it "reports an offense if it is present in a versioned formula" do
// 47:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo@2.0.rb")
// 48:         class FooAT20 < Formula
// 49:           url 'https://brew.sh/foo-2.0.tgz'
// 50:           conflicts_with "mysql", "mariadb"
// 51:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Conflicts: Versioned formulae should not use `conflicts_with`. Use `keg_only :versioned_formula` instead.
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "reports no offenses if it is not present" do
// 57:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo@2.0.rb")
// 58:         class FooAT20 < Formula
// 59:           url 'https://brew.sh/foo-2.0.tgz'
// 60:           homepage "https://brew.sh"
// 61:         end
// 62:       RUBY
// 63:     end
// 64:   end
// 65: end
