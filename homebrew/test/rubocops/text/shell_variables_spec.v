module text

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/text/shell_variables_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_shell_variables_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports and corrects unexpanded shell variables in `Utils.popen`" do` at line 10.
pub fn ruby_shell_variables_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 13.
pub fn ruby_shell_variables_spec_l13_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 22.
pub fn ruby_shell_variables_spec_l22_d4_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects unexpanded shell variables in `Utils.safe_popen_read`" do` at line 29.
pub fn ruby_shell_variables_spec_l29_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 32.
pub fn ruby_shell_variables_spec_l32_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 41.
pub fn ruby_shell_variables_spec_l41_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects unexpanded shell variables in `Utils.safe_popen_write`" do` at line 48.
pub fn ruby_shell_variables_spec_l48_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 51.
pub fn ruby_shell_variables_spec_l51_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 60.
pub fn ruby_shell_variables_spec_l60_d10_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it "reports and corrects unexpanded shell variables while preserving string interpolation" do` at line 67.
pub fn ruby_shell_variables_spec_l67_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 70.
pub fn ruby_shell_variables_spec_l70_d12_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 79.
pub fn ruby_shell_variables_spec_l79_d13_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ShellVariables do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing shell variables" do
// 10:     it "reports and corrects unexpanded shell variables in `Utils.popen`" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           def install
// 14:             Utils.popen "SHELL=bash foo"
// 15:                         ^^^^^^^^^^^^^^^^ FormulaAudit/ShellVariables: Use `Utils.popen({ "SHELL" => "bash" }, "foo")` instead of `Utils.popen "SHELL=bash foo"`
// 16:           end
// 17:         end
// 18:       RUBY
// 19:
// 20:       expect_correction(<<~RUBY)
// 21:         class Foo < Formula
// 22:           def install
// 23:             Utils.popen({ "SHELL" => "bash" }, "foo")
// 24:           end
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports and corrects unexpanded shell variables in `Utils.safe_popen_read`" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           def install
// 33:             Utils.safe_popen_read "SHELL=bash foo"
// 34:                                   ^^^^^^^^^^^^^^^^ FormulaAudit/ShellVariables: Use `Utils.safe_popen_read({ "SHELL" => "bash" }, "foo")` instead of `Utils.safe_popen_read "SHELL=bash foo"`
// 35:           end
// 36:         end
// 37:       RUBY
// 38:
// 39:       expect_correction(<<~RUBY)
// 40:         class Foo < Formula
// 41:           def install
// 42:             Utils.safe_popen_read({ "SHELL" => "bash" }, "foo")
// 43:           end
// 44:         end
// 45:       RUBY
// 46:     end
// 47:
// 48:     it "reports and corrects unexpanded shell variables in `Utils.safe_popen_write`" do
// 49:       expect_offense(<<~RUBY)
// 50:         class Foo < Formula
// 51:           def install
// 52:             Utils.safe_popen_write "SHELL=bash foo"
// 53:                                    ^^^^^^^^^^^^^^^^ FormulaAudit/ShellVariables: Use `Utils.safe_popen_write({ "SHELL" => "bash" }, "foo")` instead of `Utils.safe_popen_write "SHELL=bash foo"`
// 54:           end
// 55:         end
// 56:       RUBY
// 57:
// 58:       expect_correction(<<~RUBY)
// 59:         class Foo < Formula
// 60:           def install
// 61:             Utils.safe_popen_write({ "SHELL" => "bash" }, "foo")
// 62:           end
// 63:         end
// 64:       RUBY
// 65:     end
// 66:
// 67:     it "reports and corrects unexpanded shell variables while preserving string interpolation" do
// 68:       expect_offense(<<~'RUBY')
// 69:         class Foo < Formula
// 70:           def install
// 71:             Utils.popen "SHELL=bash #{bin}/foo"
// 72:                         ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/ShellVariables: Use `Utils.popen({ "SHELL" => "bash" }, "#{bin}/foo")` instead of `Utils.popen "SHELL=bash #{bin}/foo"`
// 73:           end
// 74:         end
// 75:       RUBY
// 76:
// 77:       expect_correction(<<~'RUBY')
// 78:         class Foo < Formula
// 79:           def install
// 80:             Utils.popen({ "SHELL" => "bash" }, "#{bin}/foo")
// 81:           end
// 82:         end
// 83:       RUBY
// 84:     end
// 85:   end
// 86: end
