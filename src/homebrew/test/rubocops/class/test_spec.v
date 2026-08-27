module class

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/class/test_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_test_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports and corrects an offense when /usr/local/bin is found in test calls" do` at line 9.
pub fn ruby_test_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense when passing 0 as the second parameter to shell_output" do` at line 32.
pub fn ruby_test_spec_l32_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when there is an empty test block" do` at line 55.
pub fn ruby_test_spec_l55_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when test is falsely true" do` at line 67.
pub fn ruby_test_spec_l67_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/class"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Test do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports and corrects an offense when /usr/local/bin is found in test calls" do
// 10:     expect_offense(<<~'RUBY')
// 11:       class Foo < Formula
// 12:         url 'https://brew.sh/foo-1.0.tgz'
// 13:
// 14:         test do
// 15:           system "/usr/local/bin/test"
// 16:                  ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Test: Use `#{bin}` instead of `/usr/local/bin` in `system`
// 17:         end
// 18:       end
// 19:     RUBY
// 20:
// 21:     expect_correction(<<~'RUBY')
// 22:       class Foo < Formula
// 23:         url 'https://brew.sh/foo-1.0.tgz'
// 24:
// 25:         test do
// 26:           system "#{bin}/test"
// 27:         end
// 28:       end
// 29:     RUBY
// 30:   end
// 31:
// 32:   it "reports and corrects an offense when passing 0 as the second parameter to shell_output" do
// 33:     expect_offense(<<~'RUBY')
// 34:       class Foo < Formula
// 35:         url 'https://brew.sh/foo-1.0.tgz'
// 36:
// 37:         test do
// 38:           shell_output("#{bin}/test", 0)
// 39:                                       ^ FormulaAudit/Test: Passing 0 to `shell_output` is redundant
// 40:         end
// 41:       end
// 42:     RUBY
// 43:
// 44:     expect_correction(<<~'RUBY')
// 45:       class Foo < Formula
// 46:         url 'https://brew.sh/foo-1.0.tgz'
// 47:
// 48:         test do
// 49:           shell_output("#{bin}/test")
// 50:         end
// 51:       end
// 52:     RUBY
// 53:   end
// 54:
// 55:   it "reports an offense when there is an empty test block" do
// 56:     expect_offense(<<~RUBY)
// 57:       class Foo < Formula
// 58:         url 'https://brew.sh/foo-1.0.tgz'
// 59:
// 60:         test do
// 61:         ^^^^^^^ FormulaAudit/Test: `test do` should not be empty
// 62:         end
// 63:       end
// 64:     RUBY
// 65:   end
// 66:
// 67:   it "reports an offense when test is falsely true" do
// 68:     expect_offense(<<~RUBY)
// 69:       class Foo < Formula
// 70:         url 'https://brew.sh/foo-1.0.tgz'
// 71:
// 72:         test do
// 73:         ^^^^^^^ FormulaAudit/Test: `test do` should contain a real test
// 74:           true
// 75:         end
// 76:       end
// 77:     RUBY
// 78:   end
// 79: end
