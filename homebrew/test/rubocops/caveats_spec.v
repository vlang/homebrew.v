module rubocops

import brew_runtime
import homebrew.rubocops as caveats_core

// Translated from Homebrew/brew `test/rubocops/caveats_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_caveats_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Caveats', 'FormulaAudit/Caveats')
}

// Ruby it `it "reports an offense if `setuid` is mentioned" do` at line 10.
pub fn ruby_caveats_spec_l10_d2_reports() bool {
	return caveats_core.audit_formula_caveats('def caveats\n  "setuid"\nend', '').map(it.kind) == [
		'setuid',
	]
}

// Ruby method `caveats` at line 15.
pub fn ruby_caveats_spec_l15_d3_caveats() string {
	return 'setuid'
}

// Ruby it `it "reports an offense if an escape character is present" do` at line 23.
pub fn ruby_caveats_spec_l23_d4_reports() bool {
	first := caveats_core.audit_formula_caveats('def caveats\n  "\\x1B"\nend', '')
	second := caveats_core.audit_formula_caveats('def caveats\n  "\\u001b"\nend', '')
	return first.map(it.kind) == ['ansi_escape'] && second.map(it.kind) == [
		'ansi_escape',
	]
}

// Ruby method `caveats` at line 28.
pub fn ruby_caveats_spec_l28_d5_caveats() string {
	return '\x1b'
}

// Ruby method `caveats` at line 39.
pub fn ruby_caveats_spec_l39_d6_caveats() string {
	return '\x1b'
}

// Ruby it `it "reports an offense if dynamic logic (if/else/unless) is used in caveats" do` at line 47.
pub fn ruby_caveats_spec_l47_d7_reports() bool {
	if_source := 'def caveats\n  if true\n    "foo"\n  else\n    "bar"\n  end\nend'
	unless_source := 'def caveats\n  unless false\n    "foo"\n  end\nend'
	return caveats_core.audit_formula_caveats(if_source, 'homebrew-core').map(it.kind) == [
		'dynamic_logic',
	] && caveats_core.audit_formula_caveats(unless_source, 'homebrew-core').map(it.kind) == [
		'dynamic_logic',
	]
}

// Ruby method `caveats` at line 52.
pub fn ruby_caveats_spec_l52_d8_caveats() string {
	return 'if true\n  "foo"\nelse\n  "bar"\nend'
}

// Ruby method `caveats` at line 67.
pub fn ruby_caveats_spec_l67_d9_caveats() string {
	return 'unless false\n  "foo"\nend'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/caveats"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Caveats do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing `caveats`" do
// 10:     it "reports an offense if `setuid` is mentioned" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           homepage "https://brew.sh/foo"
// 14:           url "https://brew.sh/foo-1.0.tgz"
// 15:            def caveats
// 16:             "setuid"
// 17:             ^^^^^^^^ FormulaAudit/Caveats: Instead of recommending `setuid` in the caveats, suggest `sudo`.
// 18:           end
// 19:         end
// 20:       RUBY
// 21:     end
// 22:
// 23:     it "reports an offense if an escape character is present" do
// 24:       expect_offense(<<~RUBY)
// 25:         class Foo < Formula
// 26:           homepage "https://brew.sh/foo"
// 27:           url "https://brew.sh/foo-1.0.tgz"
// 28:            def caveats
// 29:             "\\x1B"
// 30:             ^^^^^^ FormulaAudit/Caveats: Don't use ANSI escape codes in the caveats.
// 31:           end
// 32:         end
// 33:       RUBY
// 34:
// 35:       expect_offense(<<~RUBY)
// 36:         class Foo < Formula
// 37:           homepage "https://brew.sh/foo"
// 38:           url "https://brew.sh/foo-1.0.tgz"
// 39:            def caveats
// 40:             "\\u001b"
// 41:             ^^^^^^^^ FormulaAudit/Caveats: Don't use ANSI escape codes in the caveats.
// 42:           end
// 43:         end
// 44:       RUBY
// 45:     end
// 46:
// 47:     it "reports an offense if dynamic logic (if/else/unless) is used in caveats" do
// 48:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 49:         class Foo < Formula
// 50:           homepage "https://brew.sh/foo"
// 51:           url "https://brew.sh/foo-1.0.tgz"
// 52:           def caveats
// 53:             if true
// 54:             ^^^^^^^ FormulaAudit/Caveats: Don't use dynamic logic (if/else/unless) in caveats.
// 55:               "foo"
// 56:             else
// 57:               "bar"
// 58:             end
// 59:           end
// 60:         end
// 61:       RUBY
// 62:
// 63:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 64:         class Foo < Formula
// 65:           homepage "https://brew.sh/foo"
// 66:           url "https://brew.sh/foo-1.0.tgz"
// 67:           def caveats
// 68:             unless false
// 69:             ^^^^^^^^^^^^ FormulaAudit/Caveats: Don't use dynamic logic (if/else/unless) in caveats.
// 70:               "foo"
// 71:             end
// 72:           end
// 73:         end
// 74:       RUBY
// 75:     end
// 76:   end
// 77: end
