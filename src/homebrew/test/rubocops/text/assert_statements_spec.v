module text

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/text/assert_statements_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_assert_statements_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense when assert ... include is used" do` at line 10.
pub fn ruby_assert_statements_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when assert ... exist? is used without a negation" do` at line 21.
pub fn ruby_assert_statements_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when assert ... exist? is used with a negation" do` at line 32.
pub fn ruby_assert_statements_spec_l32_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when assert ... executable? is used without a negation" do` at line 43.
pub fn ruby_assert_statements_spec_l43_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::AssertStatements do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula assertions" do
// 10:     it "reports an offense when assert ... include is used" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           assert File.read("inbox").include?("Sample message 1")
// 16:                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/AssertStatements: Use `assert_match` instead of `assert ...include?`
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports an offense when assert ... exist? is used without a negation" do
// 22:       expect_offense(<<~RUBY)
// 23:         class Foo < Formula
// 24:           desc "foo"
// 25:           url 'https://brew.sh/foo-1.0.tgz'
// 26:           assert File.exist? "default.ini"
// 27:                  ^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/AssertStatements: Use `assert_path_exists <path_to_file>` instead of `assert File.exist? "default.ini"`
// 28:         end
// 29:       RUBY
// 30:     end
// 31:
// 32:     it "reports an offense when assert ... exist? is used with a negation" do
// 33:       expect_offense(<<~RUBY)
// 34:         class Foo < Formula
// 35:           desc "foo"
// 36:           url 'https://brew.sh/foo-1.0.tgz'
// 37:           assert !File.exist?("default.ini")
// 38:                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/AssertStatements: Use `refute_path_exists <path_to_file>` instead of `assert !File.exist?("default.ini")`
// 39:         end
// 40:       RUBY
// 41:     end
// 42:
// 43:     it "reports an offense when assert ... executable? is used without a negation" do
// 44:       expect_offense(<<~RUBY)
// 45:         class Foo < Formula
// 46:           desc "foo"
// 47:           url 'https://brew.sh/foo-1.0.tgz'
// 48:           assert File.executable? f
// 49:                  ^^^^^^^^^^^^^^^^^^ FormulaAudit/AssertStatements: Use `assert_predicate <path_to_file>, :executable?` instead of `assert File.executable? f`
// 50:         end
// 51:       RUBY
// 52:     end
// 53:   end
// 54: end
