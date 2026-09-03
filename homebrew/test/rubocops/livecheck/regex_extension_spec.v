module livecheck

import brew_runtime
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/regex_extension_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_regex_extension_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::LivecheckRegexExtension', 'FormulaAudit/LivecheckRegexExtension')
}

// Ruby it `it "reports an offense when the `regex` does not use `\\.t` for archive file extensions" do` at line 9.
pub fn ruby_regex_extension_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'livecheck do\n  url :stable\n  regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.tgz}i)\nend'
	problems := livecheck_core.audit_livecheck_regex_extension(source)
	return brew_runtime.bool_value(problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == '%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.tgz}i' && problems[0].message == 'Use `\\.t` instead of `\\.tgz`' && livecheck_core.correct_livecheck(source, problems).contains('\\.t}i)'))
}

// Ruby it `it "reports no offenses when the `regex` uses `\\.t` for archive file extensions" do` at line 34.
pub fn ruby_regex_extension_spec_l34_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'livecheck do\n  url :stable\n  regex(%r{formula-(\\d+(?:\\.\\d+)+)\\.t}i)\nend'
	return brew_runtime.bool_value(livecheck_core.audit_livecheck_regex_extension(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckRegexExtension do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when the `regex` does not use `\\.t` for archive file extensions" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:           url :stable
// 16:           regex(%r{href=.*?/formula[._-]v?(\\d+(?:\\.\\d+)+)\\.tgz}i)
// 17:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/LivecheckRegexExtension: Use `\\.t` instead of `\\.tgz`
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
// 34:   it "reports no offenses when the `regex` uses `\\.t` for archive file extensions" do
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
