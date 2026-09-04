module urls

import ruby
import homebrew.rubocops as urls_core

// Translated from Homebrew/brew `test/rubocops/urls/git_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn git_spec_formula(body string) string {
	return 'class Foo < Formula\n  desc "foo"\n${body}\nend'
}

fn git_spec_audit(body string, tap string) urls_core.FormulaUrlsAnalysis {
	return urls_core.audit_formula_git_urls(urls_core.FormulaUrlsContext{
		source: git_spec_formula(body)
		formula_tap: tap
	})
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_git_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::GitUrls', 'FormulaAudit/GitUrls')
}

// Ruby it `it "reports no offenses with a non-git URL" do` at line 10.
pub fn ruby_git_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(git_spec_audit('  url "https://foo.com"', 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses with both a tag and a revision" do` at line 19.
pub fn ruby_git_spec_l19_d3_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      tag:      "v1.0.0",\n      revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses with both a tag, revision and `shallow` before" do` at line 30.
pub fn ruby_git_spec_l30_d4_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      shallow:  false,\n      tag:      "v1.0.0",\n      revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses with both a tag, revision and `shallow` after" do` at line 42.
pub fn ruby_git_spec_l42_d5_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      tag:      "v1.0.0",\n      revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",\n      shallow:  false'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports an offense with no `revision`" do` at line 54.
pub fn ruby_git_spec_l54_d6_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      tag: "v1.0.0"'
	offenses := git_spec_audit(body, 'homebrew-core').offenses
	return ruby.bool_value(offenses.len == 1 && offenses[0].message == 'Formulae in homebrew/core should specify a revision for Git URLs')
}

// Ruby it `it "reports an offense with no `revision` and `shallow`" do` at line 65.
pub fn ruby_git_spec_l65_d7_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      shallow: false,\n      tag:     "v1.0.0"'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 1)
}

// Ruby it `it "reports no offenses with no `tag`" do` at line 77.
pub fn ruby_git_spec_l77_d8_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses with no `tag` and `shallow`" do` at line 87.
pub fn ruby_git_spec_l87_d9_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://github.com/foo/bar.git",\n      revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",\n      shallow:  false'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses with missing arguments in `head`" do` at line 98.
pub fn ruby_git_spec_l98_d10_reports(args ...ruby.Value) ruby.Value {
	body := '  url "https://foo.com"\n  head do\n    url "https://github.com/foo/bar.git"\n  end'
	return ruby.bool_value(git_spec_audit(body, 'homebrew-core').offenses.len == 0)
}

// Ruby it `it "reports no offenses for non-core taps" do` at line 110.
pub fn ruby_git_spec_l110_d11_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(git_spec_audit('  url "https://github.com/foo/bar.git"', '').offenses.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/urls"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::GitUrls do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when a git URL is used" do
// 10:     it "reports no offenses with a non-git URL" do
// 11:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url "https://foo.com"
// 15:         end
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "reports no offenses with both a tag and a revision" do
// 20:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 21:         class Foo < Formula
// 22:           desc "foo"
// 23:           url "https://github.com/foo/bar.git",
// 24:               tag:      "v1.0.0",
// 25:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports no offenses with both a tag, revision and `shallow` before" do
// 31:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 32:         class Foo < Formula
// 33:           desc "foo"
// 34:           url "https://github.com/foo/bar.git",
// 35:               shallow:  false,
// 36:               tag:      "v1.0.0",
// 37:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 38:         end
// 39:       RUBY
// 40:     end
// 41:
// 42:     it "reports no offenses with both a tag, revision and `shallow` after" do
// 43:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 44:         class Foo < Formula
// 45:           desc "foo"
// 46:           url "https://github.com/foo/bar.git",
// 47:               tag:      "v1.0.0",
// 48:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 49:               shallow:  false
// 50:         end
// 51:       RUBY
// 52:     end
// 53:
// 54:     it "reports an offense with no `revision`" do
// 55:       expect_offense(<<~RUBY, "/homebrew-core/")
// 56:         class Foo < Formula
// 57:           desc "foo"
// 58:           url "https://github.com/foo/bar.git",
// 59:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GitUrls: Formulae in homebrew/core should specify a revision for Git URLs
// 60:               tag: "v1.0.0"
// 61:         end
// 62:       RUBY
// 63:     end
// 64:
// 65:     it "reports an offense with no `revision` and `shallow`" do
// 66:       expect_offense(<<~RUBY, "/homebrew-core/")
// 67:         class Foo < Formula
// 68:           desc "foo"
// 69:           url "https://github.com/foo/bar.git",
// 70:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GitUrls: Formulae in homebrew/core should specify a revision for Git URLs
// 71:               shallow: false,
// 72:               tag:     "v1.0.0"
// 73:         end
// 74:       RUBY
// 75:     end
// 76:
// 77:     it "reports no offenses with no `tag`" do
// 78:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 79:         class Foo < Formula
// 80:           desc "foo"
// 81:           url "https://github.com/foo/bar.git",
// 82:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 83:         end
// 84:       RUBY
// 85:     end
// 86:
// 87:     it "reports no offenses with no `tag` and `shallow`" do
// 88:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 89:         class Foo < Formula
// 90:           desc "foo"
// 91:           url "https://github.com/foo/bar.git",
// 92:               revision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 93:               shallow:  false
// 94:         end
// 95:       RUBY
// 96:     end
// 97:
// 98:     it "reports no offenses with missing arguments in `head`" do
// 99:       expect_no_offenses(<<~RUBY, "/homebrew-core/")
// 100:         class Foo < Formula
// 101:           desc "foo"
// 102:           url "https://foo.com"
// 103:           head do
// 104:             url "https://github.com/foo/bar.git"
// 105:           end
// 106:         end
// 107:       RUBY
// 108:     end
// 109:
// 110:     it "reports no offenses for non-core taps" do
// 111:       expect_no_offenses(<<~RUBY)
// 112:         class Foo < Formula
// 113:           desc "foo"
// 114:           url "https://github.com/foo/bar.git"
// 115:         end
// 116:       RUBY
// 117:     end
// 118:   end
// 119: end
