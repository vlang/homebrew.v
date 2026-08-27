module lines

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/lines/class_inheritance_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_class_inheritance_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense when not using spaces for class inheritance" do` at line 10.
pub fn ruby_class_inheritance_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
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
