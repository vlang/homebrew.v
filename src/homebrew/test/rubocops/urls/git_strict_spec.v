module urls

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/urls/git_strict_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_git_strict_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports no offenses with both a tag and a revision" do` at line 10.
pub fn ruby_git_strict_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses with both a tag, revision and `shallow` before" do` at line 21.
pub fn ruby_git_strict_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses with both a tag, revision and `shallow` after" do` at line 33.
pub fn ruby_git_strict_spec_l33_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense with no `tag`" do` at line 45.
pub fn ruby_git_strict_spec_l45_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense with no `tag` and `shallow`" do` at line 56.
pub fn ruby_git_strict_spec_l56_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses with missing arguments in `head`" do` at line 68.
pub fn ruby_git_strict_spec_l68_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for non-core taps" do` at line 80.
pub fn ruby_git_strict_spec_l80_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/urls"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAuditStrict::GitUrls do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when a git URL is used" do
// 10:     it "reports no offenses with both a tag and a revision" do
// 11:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url "https://github.com/foo/bar.git",
// 15:               tag:      "v1.0.0",
// 16:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports no offenses with both a tag, revision and `shallow` before" do
// 22:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 23:         class Foo < Formula
// 24:           desc "foo"
// 25:           url "https://github.com/foo/bar.git",
// 26:               shallow:  false,
// 27:               tag:      "v1.0.0",
// 28:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 29:         end
// 30:       RUBY
// 31:     end
// 32:
// 33:     it "reports no offenses with both a tag, revision and `shallow` after" do
// 34:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 35:         class Foo < Formula
// 36:           desc "foo"
// 37:           url "https://github.com/foo/bar.git",
// 38:               tag:      "v1.0.0",
// 39:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 40:               shallow:  false
// 41:         end
// 42:       RUBY
// 43:     end
// 44:
// 45:     it "reports an offense with no `tag`" do
// 46:       expect_offense(<<~RUBY, "/homebrew-core/")
// 47:         class Foo < Formula
// 48:           desc "foo"
// 49:           url "https://github.com/foo/bar.git",
// 50:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAuditStrict/GitUrls: Formulae in homebrew/core should specify a tag for Git URLs
// 51:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "reports an offense with no `tag` and `shallow`" do
// 57:       expect_offense(<<~RUBY, "/homebrew-core/")
// 58:         class Foo < Formula
// 59:           desc "foo"
// 60:           url "https://github.com/foo/bar.git",
// 61:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAuditStrict/GitUrls: Formulae in homebrew/core should specify a tag for Git URLs
// 62:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 63:               shallow:  false
// 64:         end
// 65:       RUBY
// 66:     end
// 67:
// 68:     it "reports no offenses with missing arguments in `head`" do
// 69:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 70:         class Foo < Formula
// 71:           desc "foo"
// 72:           url "https://foo.com"
// 73:           head do
// 74:             url "https://github.com/foo/bar.git"
// 75:           end
// 76:         end
// 77:       RUBY
// 78:     end
// 79:
// 80:     it "reports no offenses for non-core taps" do
// 81:       expect_no_offenses(<<~RUBY)
// 82:         class Foo < Formula
// 83:           desc "foo"
// 84:           url "https://github.com/foo/bar.git"
// 85:         end
// 86:       RUBY
// 87:     end
// 88:   end
// 89: end
