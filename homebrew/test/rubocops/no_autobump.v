module rubocops

import ruby
import homebrew.rubocops as no_autobump_core

// Translated from Homebrew/brew `test/rubocops/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { RuboCop::Cop::FormulaAudit::NoAutobump.new }` at line 7.
pub fn ruby_no_autobump_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::NoAutobump', 'FormulaAudit/NoAutobump')
}

// Ruby it `it "reports no offenses if `reason` is acceptable" do` at line 9.
pub fn ruby_no_autobump_l9_d2_reports() bool {
	return no_autobump_core.audit_formula_no_autobump('no_autobump! because: "some reason"').len == 0
}

// Ruby it `it "reports no offenses if `reason` is acceptable as a symbol" do` at line 18.
pub fn ruby_no_autobump_l18_d3_reports() bool {
	return no_autobump_core.audit_formula_no_autobump('no_autobump! because: :bumped_by_upstream').len == 0
}

// Ruby it `it "reports an offense if `reason` is absent" do` at line 27.
pub fn ruby_no_autobump_l27_d4_reports() bool {
	return no_autobump_core.audit_formula_no_autobump('no_autobump!').map(it.kind) == [
		'missing_reason',
	]
}

// Ruby it `it "reports an offense is `reason` should not be set manually" do` at line 37.
pub fn ruby_no_autobump_l37_d5_reports() bool {
	return no_autobump_core.audit_formula_no_autobump('no_autobump! because: :extract_plist').map(it.kind) == [
		'disallowed_symbol',
	]
}

// Ruby it `it "reports and corrects an offense if `reason` starts with 'it'" do` at line 47.
pub fn ruby_no_autobump_l47_d6_reports() bool {
	source := 'no_autobump! because: "it does something"'
	return no_autobump_core.audit_formula_no_autobump(source).map(it.kind) == [
		'starts_with_it',
	] && no_autobump_core.correct_formula_no_autobump(source) == 'no_autobump! because: "does something"'
}

// Ruby it `it "reports and corrects an offense if `reason` ends with a period" do` at line 64.
pub fn ruby_no_autobump_l64_d7_reports() bool {
	return no_autobump_punctuation_case('.')
}

// Ruby it `it "reports and corrects an offense if `reason` ends with an exclamation point" do` at line 81.
pub fn ruby_no_autobump_l81_d8_reports() bool {
	return no_autobump_punctuation_case('!')
}

// Ruby it `it "reports and corrects an offense if `reason` ends with a question mark" do` at line 98.
pub fn ruby_no_autobump_l98_d9_reports() bool {
	return no_autobump_punctuation_case('?')
}

fn no_autobump_punctuation_case(mark string) bool {
	source := 'no_autobump! because: "does something${mark}"'
	return no_autobump_core.audit_formula_no_autobump(source).map(it.kind) == [
		'trailing_punctuation',
	] && no_autobump_core.correct_formula_no_autobump(source) == 'no_autobump! because: "does something"'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/no_autobump"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::NoAutobump do
// 7:   subject(:cop) { RuboCop::Cop::FormulaAudit::NoAutobump.new }
// 8:
// 9:   it "reports no offenses if `reason` is acceptable" do
// 10:     expect_no_offenses(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url 'https://brew.sh/foo-1.0.tgz'
// 13:         no_autobump! because: "some reason"
// 14:       end
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "reports no offenses if `reason` is acceptable as a symbol" do
// 19:     expect_no_offenses(<<~RUBY)
// 20:       class Foo < Formula
// 21:         url 'https://brew.sh/foo-1.0.tgz'
// 22:         no_autobump! because: :bumped_by_upstream
// 23:       end
// 24:     RUBY
// 25:   end
// 26:
// 27:   it "reports an offense if `reason` is absent" do
// 28:     expect_offense(<<~RUBY)
// 29:       class Foo < Formula
// 30:         url 'https://brew.sh/foo-1.0.tgz'
// 31:         no_autobump!
// 32:         ^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: Add a reason for exclusion from autobump: `no_autobump! because: "..."`
// 33:       end
// 34:     RUBY
// 35:   end
// 36:
// 37:   it "reports an offense is `reason` should not be set manually" do
// 38:     expect_offense(<<~RUBY)
// 39:       class Foo < Formula
// 40:         url 'https://brew.sh/foo-1.0.tgz'
// 41:         no_autobump! because: :extract_plist
// 42:                               ^^^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: `:extract_plist` reason should not be used directly
// 43:       end
// 44:     RUBY
// 45:   end
// 46:
// 47:   it "reports and corrects an offense if `reason` starts with 'it'" do
// 48:     expect_offense(<<~RUBY)
// 49:       class Foo < Formula
// 50:         url 'https://brew.sh/foo-1.0.tgz'
// 51:         no_autobump! because: "it does something"
// 52:                               ^^^^^^^^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: Do not start the reason with `it`
// 53:       end
// 54:     RUBY
// 55:
// 56:     expect_correction(<<~RUBY)
// 57:       class Foo < Formula
// 58:         url 'https://brew.sh/foo-1.0.tgz'
// 59:         no_autobump! because: "does something"
// 60:       end
// 61:     RUBY
// 62:   end
// 63:
// 64:   it "reports and corrects an offense if `reason` ends with a period" do
// 65:     expect_offense(<<~RUBY)
// 66:       class Foo < Formula
// 67:         url 'https://brew.sh/foo-1.0.tgz'
// 68:         no_autobump! because: "does something."
// 69:                               ^^^^^^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: Do not end the reason with a punctuation mark
// 70:       end
// 71:     RUBY
// 72:
// 73:     expect_correction(<<~RUBY)
// 74:       class Foo < Formula
// 75:         url 'https://brew.sh/foo-1.0.tgz'
// 76:         no_autobump! because: "does something"
// 77:       end
// 78:     RUBY
// 79:   end
// 80:
// 81:   it "reports and corrects an offense if `reason` ends with an exclamation point" do
// 82:     expect_offense(<<~RUBY)
// 83:       class Foo < Formula
// 84:         url 'https://brew.sh/foo-1.0.tgz'
// 85:         no_autobump! because: "does something!"
// 86:                               ^^^^^^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: Do not end the reason with a punctuation mark
// 87:       end
// 88:     RUBY
// 89:
// 90:     expect_correction(<<~RUBY)
// 91:       class Foo < Formula
// 92:         url 'https://brew.sh/foo-1.0.tgz'
// 93:         no_autobump! because: "does something"
// 94:       end
// 95:     RUBY
// 96:   end
// 97:
// 98:   it "reports and corrects an offense if `reason` ends with a question mark" do
// 99:     expect_offense(<<~RUBY)
// 100:       class Foo < Formula
// 101:         url 'https://brew.sh/foo-1.0.tgz'
// 102:         no_autobump! because: "does something?"
// 103:                               ^^^^^^^^^^^^^^^^^ FormulaAudit/NoAutobumpReason: Do not end the reason with a punctuation mark
// 104:       end
// 105:     RUBY
// 106:
// 107:     expect_correction(<<~RUBY)
// 108:       class Foo < Formula
// 109:         url 'https://brew.sh/foo-1.0.tgz'
// 110:         no_autobump! because: "does something"
// 111:       end
// 112:     RUBY
// 113:   end
// 114: end
