module livecheck

import ruby
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/regex_if_page_match_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_regex_if_page_match_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LivecheckRegexIfPageMatch', 'FormulaAudit/LivecheckRegexIfPageMatch')
}

// Ruby it `it "reports an offense when there is no `regex` for `strategy :page_match`" do` at line 9.
pub fn ruby_regex_if_page_match_spec_l9_d2_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  strategy :page_match\nend'
	problems := livecheck_core.audit_livecheck_regex_if_page_match(source)
	return ruby.bool_value(problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == source && problems[0].message == 'A `regex` is required if `strategy :page_match` is present.')
}

// Ruby it `it "reports no offenses when a `regex` is specified for `strategy :page_match`" do` at line 23.
pub fn ruby_regex_if_page_match_spec_l23_d3_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  strategy :page_match\n  regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_regex_if_page_match(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckRegexIfPageMatch do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when there is no `regex` for `strategy :page_match`" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:         ^^^^^^^^^^^^ FormulaAudit/LivecheckRegexIfPageMatch: A `regex` is required if `strategy :page_match` is present.
// 16:           url :stable
// 17:           strategy :page_match
// 18:         end
// 19:       end
// 20:     RUBY
// 21:   end
// 22:
// 23:   it "reports no offenses when a `regex` is specified for `strategy :page_match`" do
// 24:     expect_no_offenses(<<~RUBY)
// 25:       class Foo < Formula
// 26:         url "https://brew.sh/foo-1.0.tgz"
// 27:
// 28:         livecheck do
// 29:           url :stable
// 30:           strategy :page_match
// 31:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i)
// 32:         end
// 33:       end
// 34:     RUBY
// 35:   end
// 36: end
