module cask

import homebrew.rubocops.cask as unsigned_reason_core

// Translated from Homebrew/brew `test/rubocops/cask/deprecate_disable_unsigned_reason_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "flags and autocorrects deprecate! with :unsigned" do` at line 7.
pub fn ruby_deprecate_disable_unsigned_reason_spec_l7_d1_flags() bool {
	source := 'cask "foo" do\n  deprecate! date: "2024-01-01", because: :unsigned\nend'
	expected := 'cask "foo" do\n  deprecate! date: "2024-01-01", because: :fails_gatekeeper_check\nend'
	offenses := unsigned_reason_core.audit_deprecate_disable_unsigned_reason(source)
	return offenses.len == 1 && offenses[0].stanza == 'deprecate!' && unsigned_reason_core.correct_deprecate_disable_unsigned_reason(source) == expected
}

// Ruby it `it "flags and autocorrects disable! with :unsigned" do` at line 22.
pub fn ruby_deprecate_disable_unsigned_reason_spec_l22_d2_flags() bool {
	source := 'cask "bar" do\n  disable! because: :unsigned\nend'
	expected := 'cask "bar" do\n  disable! because: :fails_gatekeeper_check\nend'
	offenses := unsigned_reason_core.audit_deprecate_disable_unsigned_reason(source)
	return offenses.len == 1 && offenses[0].stanza == 'disable!' && unsigned_reason_core.correct_deprecate_disable_unsigned_reason(source) == expected
}

// Ruby it `it "ignores other reasons" do` at line 37.
pub fn ruby_deprecate_disable_unsigned_reason_spec_l37_d3_ignores() bool {
	source := 'cask "baz" do\n  deprecate! date: "2024-01-01", because: :discontinued\n  disable! because: :no_longer_available\nend'
	return unsigned_reason_core.audit_deprecate_disable_unsigned_reason(source).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::DeprecateDisableUnsignedReason, :config do
// 7:   it "flags and autocorrects deprecate! with :unsigned" do
// 8:     expect_offense <<~CASK
// 9:       cask "foo" do
// 10:         deprecate! date: "2024-01-01", because: :unsigned
// 11:                                                 ^^^^^^^^^ Use `:fails_gatekeeper_check` instead of `:unsigned` for deprecate!/disable! reason.
// 12:       end
// 13:     CASK
// 14:
// 15:     expect_correction <<~CASK
// 16:       cask "foo" do
// 17:         deprecate! date: "2024-01-01", because: :fails_gatekeeper_check
// 18:       end
// 19:     CASK
// 20:   end
// 21:
// 22:   it "flags and autocorrects disable! with :unsigned" do
// 23:     expect_offense <<~CASK
// 24:       cask "bar" do
// 25:         disable! because: :unsigned
// 26:                           ^^^^^^^^^ Use `:fails_gatekeeper_check` instead of `:unsigned` for deprecate!/disable! reason.
// 27:       end
// 28:     CASK
// 29:
// 30:     expect_correction <<~CASK
// 31:       cask "bar" do
// 32:         disable! because: :fails_gatekeeper_check
// 33:       end
// 34:     CASK
// 35:   end
// 36:
// 37:   it "ignores other reasons" do
// 38:     expect_no_offenses <<~CASK
// 39:       cask "baz" do
// 40:         deprecate! date: "2024-01-01", because: :discontinued
// 41:         disable! because: :no_longer_available
// 42:       end
// 43:     CASK
// 44:   end
// 45: end
