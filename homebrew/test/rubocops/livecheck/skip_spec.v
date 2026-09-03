module livecheck

import brew_runtime
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/skip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_skip_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::LivecheckSkip', 'FormulaAudit/LivecheckSkip')
}

// Ruby it `it "reports an offense when a skipped formula's `livecheck` block contains other information" do` at line 9.
pub fn ruby_skip_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'livecheck do\n  skip "Not maintained"\n  url :stable\nend'
	problems := livecheck_core.audit_livecheck_skip(source)
	return brew_runtime.bool_value(problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == source && livecheck_core.correct_livecheck(source, problems) == 'livecheck do\n  skip "Not maintained"\nend')
}

// Ruby it `it "reports no offenses when a skipped formula's `livecheck` block contains no other information" do` at line 33.
pub fn ruby_skip_spec_l33_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(livecheck_core.audit_livecheck_skip('livecheck do\n  skip "Not maintained"\nend').len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckSkip do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when a skipped formula's `livecheck` block contains other information" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:         ^^^^^^^^^^^^ FormulaAudit/LivecheckSkip: Skipped formulae must not contain other livecheck information.
// 16:           skip "Not maintained"
// 17:           url :stable
// 18:         end
// 19:       end
// 20:     RUBY
// 21:
// 22:     expect_correction(<<~RUBY)
// 23:       class Foo < Formula
// 24:         url "https://brew.sh/foo-1.0.tgz"
// 25:
// 26:         livecheck do
// 27:           skip "Not maintained"
// 28:         end
// 29:       end
// 30:     RUBY
// 31:   end
// 32:
// 33:   it "reports no offenses when a skipped formula's `livecheck` block contains no other information" do
// 34:     expect_no_offenses(<<~RUBY)
// 35:       class Foo < Formula
// 36:         url "https://brew.sh/foo-1.0.tgz"
// 37:
// 38:         livecheck do
// 39:           skip "Not maintained"
// 40:         end
// 41:       end
// 42:     RUBY
// 43:   end
// 44: end
