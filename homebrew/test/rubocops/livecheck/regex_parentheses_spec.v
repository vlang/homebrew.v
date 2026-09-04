module livecheck

import ruby
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/regex_parentheses_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_regex_parentheses_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LivecheckRegexParentheses', 'FormulaAudit/LivecheckRegexParentheses')
}

// Ruby it `it "reports an offense when the `regex` call in the `livecheck` block does not use parentheses" do` at line 9.
pub fn ruby_regex_parentheses_spec_l9_d2_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  regex %r{formula-(\\d+(?:\\.\\d+)+)\\.t}i\nend'
	problems := livecheck_core.audit_livecheck_regex_parentheses(source)
	return ruby.bool_value(problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'regex %r{formula-(\\d+(?:\\.\\d+)+)\\.t}i' && livecheck_core.correct_livecheck(source, problems).contains('regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)'))
}

// Ruby it `it "reports no offenses when the `regex` call in the `livecheck` block uses parentheses" do` at line 34.
pub fn ruby_regex_parentheses_spec_l34_d3_reports(args ...ruby.Value) ruby.Value {
	source := 'livecheck do\n  url :stable\n  regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_regex_parentheses(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckRegexParentheses do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when the `regex` call in the `livecheck` block does not use parentheses" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:           url :stable
// 16:           regex %r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i
// 17:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/LivecheckRegexParentheses: The `regex` call should always use parentheses.
// 18:         end
// 19:       end
// 20:     RUBY
// 21:
// 22:     expect_correction(<<~RUBY)
// 23:       class Foo < Formula
// 24:         url "https://brew.sh/foo-1.0.tgz"
// 25:
// 26:         livecheck do
// 27:           url :stable
// 28:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i)
// 29:         end
// 30:       end
// 31:     RUBY
// 32:   end
// 33:
// 34:   it "reports no offenses when the `regex` call in the `livecheck` block uses parentheses" do
// 35:     expect_no_offenses(<<~RUBY)
// 36:       class Foo < Formula
// 37:         url "https://brew.sh/foo-1.0.tgz"
// 38:
// 39:         livecheck do
// 40:           url :stable
// 41:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.t}i)
// 42:         end
// 43:       end
// 44:     RUBY
// 45:   end
// 46: end
