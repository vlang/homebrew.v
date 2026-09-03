module text

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/std_npm_args_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn std_npm_args_spec_install(command string) string {
	return 'def install\n  ${command}\nend'
}

fn std_npm_args_spec_formula(command string) string {
	return 'class Foo < Formula\n  def install\n    ${command}\n  end\nend'
}

fn std_npm_args_spec_reports(command string, message string, correction string) bool {
	source := std_npm_args_spec_formula(command)
	analysis := line_cops.audit_lines_std_npm_args(line_cops.LinesContext{
		source: source
	})
	corrected := if correction == '' { source } else { std_npm_args_spec_formula(correction) }
	return analysis.offenses.len == 1 && analysis.offenses[0].message == message && analysis.corrected == corrected
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_std_npm_args_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::StdNpmArgs', 'StdNpmArgs')
}

// Ruby it `it "reports an offense when `npm install` is called without std_npm_args arguments" do` at line 10.
pub fn ruby_std_npm_args_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(std_npm_args_spec_reports('system "npm", "install"', 'Use `std_npm_args` for npm install', ''))
}

// Ruby method `install` at line 13.
pub fn ruby_std_npm_args_spec_l13_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install"'))
}

// Ruby it `it "reports and corrects an offense when using local_npm_install_args" do` at line 21.
pub fn ruby_std_npm_args_spec_l21_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(std_npm_args_spec_reports('system "npm", "install", *Language::Node.local_npm_install_args, "--production"', 'Use `std_npm_args` instead of `local_npm_install_args`.', 'system "npm", "install", *std_npm_args(prefix: false), "--production"'))
}

// Ruby method `install` at line 24.
pub fn ruby_std_npm_args_spec_l24_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *Language::Node.local_npm_install_args, "--production"'))
}

// Ruby method `install` at line 33.
pub fn ruby_std_npm_args_spec_l33_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *std_npm_args(prefix: false), "--production"'))
}

// Ruby it `it "reports and corrects an offense when using std_npm_install_args with libexec" do` at line 40.
pub fn ruby_std_npm_args_spec_l40_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(std_npm_args_spec_reports('system "npm", "install", *Language::Node.std_npm_install_args(libexec), "--production"', 'Use `std_npm_args` instead of `std_npm_install_args`.', 'system "npm", "install", *std_npm_args, "--production"'))
}

// Ruby method `install` at line 43.
pub fn ruby_std_npm_args_spec_l43_d8_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *Language::Node.std_npm_install_args(libexec), "--production"'))
}

// Ruby method `install` at line 52.
pub fn ruby_std_npm_args_spec_l52_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *std_npm_args, "--production"'))
}

// Ruby it `it "reports and corrects an offense when using std_npm_install_args without libexec" do` at line 59.
pub fn ruby_std_npm_args_spec_l59_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(std_npm_args_spec_reports('system "npm", "install", *Language::Node.std_npm_install_args(buildpath), "--production"', 'Use `std_npm_args` instead of `std_npm_install_args`.', 'system "npm", "install", *std_npm_args(prefix: buildpath), "--production"'))
}

// Ruby method `install` at line 62.
pub fn ruby_std_npm_args_spec_l62_d11_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *Language::Node.std_npm_install_args(buildpath), "--production"'))
}

// Ruby method `install` at line 71.
pub fn ruby_std_npm_args_spec_l71_d12_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *std_npm_args(prefix: buildpath), "--production"'))
}

// Ruby it `it "does not report an offense when using std_npm_args" do` at line 78.
pub fn ruby_std_npm_args_spec_l78_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := std_npm_args_spec_formula('system "npm", "install", *std_npm_args')
	analysis := line_cops.audit_lines_std_npm_args(line_cops.LinesContext{
		source: source
	})
	return brew_runtime.bool_value(analysis.offenses.len == 0 && analysis.corrected == source)
}

// Ruby method `install` at line 81.
pub fn ruby_std_npm_args_spec_l81_d14_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(std_npm_args_spec_install('system "npm", "install", *std_npm_args'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::StdNpmArgs do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing node formulae" do
// 10:     it "reports an offense when `npm install` is called without std_npm_args arguments" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           def install
// 14:             system "npm", "install"
// 15:             ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/StdNpmArgs: Use `std_npm_args` for npm install
// 16:           end
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports and corrects an offense when using local_npm_install_args" do
// 22:       expect_offense(<<~RUBY)
// 23:         class Foo < Formula
// 24:           def install
// 25:             system "npm", "install", *Language::Node.local_npm_install_args, "--production"
// 26:                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/StdNpmArgs: Use `std_npm_args` instead of `local_npm_install_args`.
// 27:           end
// 28:         end
// 29:       RUBY
// 30:
// 31:       expect_correction(<<~RUBY)
// 32:         class Foo < Formula
// 33:           def install
// 34:             system "npm", "install", *std_npm_args(prefix: false), "--production"
// 35:           end
// 36:         end
// 37:       RUBY
// 38:     end
// 39:
// 40:     it "reports and corrects an offense when using std_npm_install_args with libexec" do
// 41:       expect_offense(<<~RUBY)
// 42:         class Foo < Formula
// 43:           def install
// 44:             system "npm", "install", *Language::Node.std_npm_install_args(libexec), "--production"
// 45:                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/StdNpmArgs: Use `std_npm_args` instead of `std_npm_install_args`.
// 46:           end
// 47:         end
// 48:       RUBY
// 49:
// 50:       expect_correction(<<~RUBY)
// 51:         class Foo < Formula
// 52:           def install
// 53:             system "npm", "install", *std_npm_args, "--production"
// 54:           end
// 55:         end
// 56:       RUBY
// 57:     end
// 58:
// 59:     it "reports and corrects an offense when using std_npm_install_args without libexec" do
// 60:       expect_offense(<<~RUBY)
// 61:         class Foo < Formula
// 62:           def install
// 63:             system "npm", "install", *Language::Node.std_npm_install_args(buildpath), "--production"
// 64:                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/StdNpmArgs: Use `std_npm_args` instead of `std_npm_install_args`.
// 65:           end
// 66:         end
// 67:       RUBY
// 68:
// 69:       expect_correction(<<~RUBY)
// 70:         class Foo < Formula
// 71:           def install
// 72:             system "npm", "install", *std_npm_args(prefix: buildpath), "--production"
// 73:           end
// 74:         end
// 75:       RUBY
// 76:     end
// 77:
// 78:     it "does not report an offense when using std_npm_args" do
// 79:       expect_no_offenses(<<~RUBY)
// 80:         class Foo < Formula
// 81:           def install
// 82:             system "npm", "install", *std_npm_args
// 83:           end
// 84:         end
// 85:       RUBY
// 86:     end
// 87:   end
// 88: end
