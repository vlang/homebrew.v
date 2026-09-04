module livecheck

import ruby
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/url_provided_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_url_provided_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LivecheckUrlProvided', 'FormulaAudit/LivecheckUrlProvided')
}

// Ruby it `it "reports an offense when a `url` is not specified in a `livecheck` block" do` at line 9.
pub fn ruby_url_provided_spec_l9_d2_reports(args ...ruby.Value) ruby.Value {
	regex_source := 'livecheck do\n  regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)\nend'
	strategy_source := 'livecheck do\n  strategy :page_match\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_url_provided(regex_source).len == 1 && livecheck_core.audit_livecheck_url_provided(strategy_source).len == 1)
}

// Ruby it `it "reports no offenses when a `url` and `regex` are specified in the `livecheck` block" do` at line 33.
pub fn ruby_url_provided_spec_l33_d3_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_url_provided(source).len == 0)
}

// Ruby it `it "reports no offenses when a `url` and `strategy` are specified in the `livecheck` block" do` at line 46.
pub fn ruby_url_provided_spec_l46_d4_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  strategy :page_match\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_url_provided(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckUrlProvided do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when a `url` is not specified in a `livecheck` block" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:         ^^^^^^^^^^^^ FormulaAudit/LivecheckUrlProvided: A `url` should be provided when `regex` or `strategy` are used.
// 16:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i)
// 17:         end
// 18:       end
// 19:     RUBY
// 20:
// 21:     expect_offense(<<~RUBY)
// 22:       class Foo < Formula
// 23:         url "https://brew.sh/foo-1.0.tgz"
// 24:
// 25:         livecheck do
// 26:         ^^^^^^^^^^^^ FormulaAudit/LivecheckUrlProvided: A `url` should be provided when `regex` or `strategy` are used.
// 27:           strategy :page_match
// 28:         end
// 29:       end
// 30:     RUBY
// 31:   end
// 32:
// 33:   it "reports no offenses when a `url` and `regex` are specified in the `livecheck` block" do
// 34:     expect_no_offenses(<<~RUBY)
// 35:       class Foo < Formula
// 36:         url "https://brew.sh/foo-1.0.tgz"
// 37:
// 38:         livecheck do
// 39:           url :stable
// 40:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i)
// 41:         end
// 42:       end
// 43:     RUBY
// 44:   end
// 45:
// 46:   it "reports no offenses when a `url` and `strategy` are specified in the `livecheck` block" do
// 47:     expect_no_offenses(<<~RUBY)
// 48:       class Foo < Formula
// 49:         url "https://brew.sh/foo-1.0.tgz"
// 50:
// 51:         livecheck do
// 52:           url :stable
// 53:           strategy :page_match
// 54:         end
// 55:       end
// 56:     RUBY
// 57:   end
// 58: end
