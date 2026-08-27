module text

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/text/safe_popen_commands_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_safe_popen_commands_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports and corrects `Utils.popen_read` usage" do` at line 10.
pub fn ruby_safe_popen_commands_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 13.
pub fn ruby_safe_popen_commands_spec_l13_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 22.
pub fn ruby_safe_popen_commands_spec_l22_d4_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects `Utils.popen_write` usage" do` at line 29.
pub fn ruby_safe_popen_commands_spec_l29_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 32.
pub fn ruby_safe_popen_commands_spec_l32_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 41.
pub fn ruby_safe_popen_commands_spec_l41_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "does not report an offense when `Utils.popen_read` is used in a test block" do` at line 48.
pub fn ruby_safe_popen_commands_spec_l48_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby method `install; end` at line 51.
pub fn ruby_safe_popen_commands_spec_l51_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::SafePopenCommands do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing popen commands" do
// 10:     it "reports and corrects `Utils.popen_read` usage" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           def install
// 14:             Utils.popen_read "foo"
// 15:             ^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/SafePopenCommands: Use `Utils.safe_popen_read` instead of `Utils.popen_read`
// 16:           end
// 17:         end
// 18:       RUBY
// 19:
// 20:       expect_correction(<<~RUBY)
// 21:         class Foo < Formula
// 22:           def install
// 23:             Utils.safe_popen_read "foo"
// 24:           end
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports and corrects `Utils.popen_write` usage" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           def install
// 33:             Utils.popen_write "foo"
// 34:             ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/SafePopenCommands: Use `Utils.safe_popen_write` instead of `Utils.popen_write`
// 35:           end
// 36:         end
// 37:       RUBY
// 38:
// 39:       expect_correction(<<~RUBY)
// 40:         class Foo < Formula
// 41:           def install
// 42:             Utils.safe_popen_write "foo"
// 43:           end
// 44:         end
// 45:       RUBY
// 46:     end
// 47:
// 48:     it "does not report an offense when `Utils.popen_read` is used in a test block" do
// 49:       expect_no_offenses(<<~RUBY)
// 50:         class Foo < Formula
// 51:           def install; end
// 52:           test do
// 53:             Utils.popen_read "foo"
// 54:           end
// 55:         end
// 56:       RUBY
// 57:     end
// 58:   end
// 59: end
