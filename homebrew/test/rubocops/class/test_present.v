module class

import ruby
import homebrew.rubocops as class_core

// Translated from Homebrew/brew `test/rubocops/class/test_present.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { RuboCop::Cop::FormulaAuditStrict::TestPresent.new }` at line 7.
pub fn ruby_test_present_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAuditStrict::TestPresent', 'FormulaAuditStrict/TestPresent')
}

// Ruby it `it "reports an offense when there is no test block" do` at line 9.
pub fn ruby_test_present_l9_d2_reports() bool {
	return class_core.audit_formula_test_present("class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\nend").map(it.kind) == [
		'missing_test',
	]
}

// Ruby it `it "reports no offenses when there is no test block and formula is disabled" do` at line 18.
pub fn ruby_test_present_l18_d3_reports() bool {
	source := 'class Foo < Formula\n  url \'https://brew.sh/foo-1.0.tgz\'\n  disable! date: "2024-07-03", because: :unsupported\nend'
	return class_core.audit_formula_test_present(source).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/class"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAuditStrict::TestPresent do
// 7:   subject(:cop) { RuboCop::Cop::FormulaAuditStrict::TestPresent.new }
// 8:
// 9:   it "reports an offense when there is no test block" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:       ^^^^^^^^^^^^^^^^^^^ A `test do` test block should be added
// 13:         url 'https://brew.sh/foo-1.0.tgz'
// 14:       end
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "reports no offenses when there is no test block and formula is disabled" do
// 19:     expect_no_offenses(<<~RUBY)
// 20:       class Foo < Formula
// 21:         url 'https://brew.sh/foo-1.0.tgz'
// 22:
// 23:         disable! date: "2024-07-03", because: :unsupported
// 24:       end
// 25:     RUBY
// 26:   end
// 27: end
