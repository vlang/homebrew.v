module lines

import ruby
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/lines/class_inheritance_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_class_inheritance_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::ClassInheritance', 'ClassInheritance')
}

// Ruby it `it "reports an offense when not using spaces for class inheritance" do` at line 10.
pub fn ruby_class_inheritance_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	source := 'class Foo<Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\nend'
	analysis := line_cops.audit_lines_class_inheritance(line_cops.LinesContext{ source: source, tap: 'homebrew-core', formula_name: 'foo' })
	return ruby.bool_value(analysis.offenses.len == 1 && analysis.offenses[0].message == 'Use a space in class inheritance: class Foo < Formula')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ClassInheritance do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula class inheritance" do
// 10:     it "reports an offense when not using spaces for class inheritance" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo<Formula
// 13:                   ^^^^^^^ FormulaAudit/ClassInheritance: Use a space in class inheritance: class Foo < Formula
// 14:           desc "foo"
// 15:           url 'https://brew.sh/foo-1.0.tgz'
// 16:         end
// 17:       RUBY
// 18:     end
// 19:   end
// 20: end
