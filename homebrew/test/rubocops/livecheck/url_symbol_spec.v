module livecheck

import ruby
import homebrew.rubocops as livecheck_core

// Translated from Homebrew/brew `test/rubocops/livecheck/url_symbol_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_url_symbol_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::LivecheckUrlSymbol', 'FormulaAudit/LivecheckUrlSymbol')
}

// Ruby it `it "reports an offense when the `url` specified in the `livecheck` block is identical to a formula URL" do` at line 9.
pub fn ruby_url_symbol_spec_l9_d2_reports(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  livecheck do\n    url "https://brew.sh/foo-1.0.tgz"\n  end\nend'
	problems := livecheck_core.audit_livecheck_url_symbol(source)
	return ruby.bool_value(problems.len == 1 && problems[0].message == 'Use `url :stable`' && livecheck_core.correct_livecheck(source, problems).contains('livecheck do\n    url :stable\n'))
}

// Ruby it `it "reports no offenses when the `url` specified in the `livecheck` block is not identical to a formula URL" do` at line 32.
pub fn ruby_url_symbol_spec_l32_d3_reports(args ...ruby.Value) ruby.Value {
	source := 'url "https://brew.sh/foo-1.0.tgz"\nlivecheck do\n  url "https://brew.sh/foo/releases/"\nend'
	return ruby.bool_value(livecheck_core.audit_livecheck_url_symbol(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/livecheck"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::LivecheckUrlSymbol do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when the `url` specified in the `livecheck` block is identical to a formula URL" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         livecheck do
// 15:           url "https://brew.sh/foo-1.0.tgz"
// 16:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/LivecheckUrlSymbol: Use `url :stable`
// 17:         end
// 18:       end
// 19:     RUBY
// 20:
// 21:     expect_correction(<<~RUBY)
// 22:       class Foo < Formula
// 23:         url "https://brew.sh/foo-1.0.tgz"
// 24:
// 25:         livecheck do
// 26:           url :stable
// 27:         end
// 28:       end
// 29:     RUBY
// 30:   end
// 31:
// 32:   it "reports no offenses when the `url` specified in the `livecheck` block is not identical to a formula URL" do
// 33:     expect_no_offenses(<<~RUBY)
// 34:       class Foo < Formula
// 35:         url "https://brew.sh/foo-1.0.tgz"
// 36:
// 37:         livecheck do
// 38:           url "https://brew.sh/foo/releases/"
// 39:         end
// 40:       end
// 41:     RUBY
// 42:   end
// 43: end
