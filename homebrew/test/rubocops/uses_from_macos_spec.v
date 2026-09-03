module rubocops

import brew_runtime
import homebrew.rubocops as uses_from_macos_core

// Translated from Homebrew/brew `test/rubocops/uses_from_macos_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_uses_from_macos_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::UsesFromMacos', 'FormulaAudit/UsesFromMacos')
}

// Ruby it `it "reports an offense when used on non-macOS dependency" do` at line 10.
pub fn ruby_uses_from_macos_spec_l10_d2_reports() bool {
	problems := uses_from_macos_core.audit_uses_from_macos('uses_from_macos "postgresql"')
	return problems.len == 1 && problems[0].dependency == 'postgresql'
}

// Ruby it `it "reports offenses for multiple non-macOS dependencies and none for valid macOS dependencies" do` at line 22.
pub fn ruby_uses_from_macos_spec_l22_d3_reports() bool {
	source := 'uses_from_macos "boost"\nuses_from_macos "bzip2"\nuses_from_macos "postgresql"\nuses_from_macos "zlib"'
	problems := uses_from_macos_core.audit_uses_from_macos(source)
	return problems.len == 2 && problems.map(it.dependency) == ['boost', 'postgresql']
}

// Ruby it `it "reports an offense when used in `depends_on :linux` formula" do` at line 38.
pub fn ruby_uses_from_macos_spec_l38_d4_reports() bool {
	problems := uses_from_macos_core.audit_uses_from_macos('depends_on :linux\nuses_from_macos "zlib"')
	return problems.len == 1 && problems[0].kind == 'linux_required'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/uses_from_macos"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::UsesFromMacos do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing `uses_from_macos` dependencies" do
// 10:     it "reports an offense when used on non-macOS dependency" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url "https://brew.sh/foo-1.0.tgz"
// 14:           homepage "https://brew.sh"
// 15:
// 16:           uses_from_macos "postgresql"
// 17:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/UsesFromMacos: `uses_from_macos` should only be used for macOS dependencies, not 'postgresql'.
// 18:         end
// 19:       RUBY
// 20:     end
// 21:
// 22:     it "reports offenses for multiple non-macOS dependencies and none for valid macOS dependencies" do
// 23:       expect_offense(<<~RUBY)
// 24:         class Foo < Formula
// 25:           url "https://brew.sh/foo-1.0.tgz"
// 26:           homepage "https://brew.sh"
// 27:
// 28:           uses_from_macos "boost"
// 29:           ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/UsesFromMacos: `uses_from_macos` should only be used for macOS dependencies, not 'boost'.
// 30:           uses_from_macos "bzip2"
// 31:           uses_from_macos "postgresql"
// 32:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/UsesFromMacos: `uses_from_macos` should only be used for macOS dependencies, not 'postgresql'.
// 33:           uses_from_macos "zlib"
// 34:         end
// 35:       RUBY
// 36:     end
// 37:
// 38:     it "reports an offense when used in `depends_on :linux` formula" do
// 39:       expect_offense(<<~RUBY)
// 40:         class Foo < Formula
// 41:           url "https://brew.sh/foo-1.0.tgz"
// 42:           homepage "https://brew.sh"
// 43:
// 44:           depends_on :linux
// 45:           uses_from_macos "zlib"
// 46:           ^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/UsesFromMacos: `uses_from_macos` should not be used when Linux is required.
// 47:         end
// 48:       RUBY
// 49:     end
// 50:   end
// 51:
// 52:   include_examples "formulae exist", RuboCop::Cop::FormulaAudit::UsesFromMacos::ALLOWED_USES_FROM_MACOS_DEPS
// 53: end
