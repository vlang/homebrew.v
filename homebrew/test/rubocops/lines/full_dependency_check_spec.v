module lines

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/lines/full_dependency_check_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_full_dependency_check_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::FullDependencyCheck', 'FullDependencyCheck')
}

fn full_dependency_spec(source string, tap string, count int, dependency string) bool {
	analysis := line_cops.audit_lines_full_dependencies(line_cops.LinesContext{ source: source, tap: tap, formula_name: 'foo' })
	return analysis.offenses.len == count && (count == 0 || analysis.offenses[0].message == 'Formulae in homebrew/core should not depend on `${dependency}`.')
}

// Ruby it `it "reports an offense when a formula depends on a -full formula" do` at line 10.
pub fn ruby_full_dependency_check_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(full_dependency_spec('depends_on "bar-full"', 'homebrew-core', 1, 'bar-full'))
}

// Ruby it `it "reports an offense when a formula uses a -full build dependency" do` at line 22.
pub fn ruby_full_dependency_check_spec_l22_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(full_dependency_spec('depends_on "baz-full" => :build', 'homebrew-core', 1, 'baz-full'))
}

// Ruby it `it "reports no offenses for -full dependencies" do` at line 36.
pub fn ruby_full_dependency_check_spec_l36_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(full_dependency_spec('depends_on "bar-full"', 'homebrew-cask', 0, ''))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::FullDependencyCheck do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing -full dependencies in homebrew/core" do
// 10:     it "reports an offense when a formula depends on a -full formula" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:
// 16:           depends_on "bar-full"
// 17:           ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/FullDependencyCheck: Formulae in homebrew/core should not depend on `bar-full`.
// 18:         end
// 19:       RUBY
// 20:     end
// 21:
// 22:     it "reports an offense when a formula uses a -full build dependency" do
// 23:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 24:         class Foo < Formula
// 25:           desc "foo"
// 26:           url 'https://brew.sh/foo-1.0.tgz'
// 27:
// 28:           depends_on "baz-full" => :build
// 29:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/FullDependencyCheck: Formulae in homebrew/core should not depend on `baz-full`.
// 30:         end
// 31:       RUBY
// 32:     end
// 33:   end
// 34:
// 35:   context "when auditing outside homebrew/core" do
// 36:     it "reports no offenses for -full dependencies" do
// 37:       expect_no_offenses(<<~RUBY, "/homebrew-cask/Formula/foo.rb")
// 38:         class Foo < Formula
// 39:           desc "foo"
// 40:           url 'https://brew.sh/foo-1.0.tgz'
// 41:
// 42:           depends_on "bar-full"
// 43:         end
// 44:       RUBY
// 45:     end
// 46:   end
// 47: end
