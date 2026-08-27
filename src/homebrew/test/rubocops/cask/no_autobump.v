module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports no offenses if `reason` is acceptable" do` at line 7.
pub fn ruby_no_autobump_l7_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if `reason` is acceptable as a symbol" do` at line 15.
pub fn ruby_no_autobump_l15_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if `reason` is absent" do` at line 23.
pub fn ruby_no_autobump_l23_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense is `reason` should not be set manually" do` at line 32.
pub fn ruby_no_autobump_l32_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense if `reason` starts with 'it'" do` at line 41.
pub fn ruby_no_autobump_l41_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense if `reason` ends with a period" do` at line 56.
pub fn ruby_no_autobump_l56_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense if `reason` ends with an exclamation point" do` at line 71.
pub fn ruby_no_autobump_l71_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense if `reason` ends with a question mark" do` at line 86.
pub fn ruby_no_autobump_l86_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::NoAutobump, :config do
// 7:   it "reports no offenses if `reason` is acceptable" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask 'foo' do
// 10:         no_autobump! because: "some reason"
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "reports no offenses if `reason` is acceptable as a symbol" do
// 16:     expect_no_offenses <<~CASK
// 17:       cask 'foo' do
// 18:         no_autobump! because: :bumped_by_upstream
// 19:       end
// 20:     CASK
// 21:   end
// 22:
// 23:   it "reports an offense if `reason` is absent" do
// 24:     expect_offense <<~CASK
// 25:       cask 'foo' do
// 26:         no_autobump!
// 27:         ^^^^^^^^^^^ Add a reason for exclusion from autobump: `no_autobump! because: "..."`
// 28:       end
// 29:     CASK
// 30:   end
// 31:
// 32:   it "reports an offense is `reason` should not be set manually" do
// 33:     expect_offense <<~CASK
// 34:       cask 'foo' do
// 35:         no_autobump! because: :extract_plist
// 36:                               ^^^^^^^^^^^^^^ `:extract_plist` reason should not be used directly
// 37:       end
// 38:     CASK
// 39:   end
// 40:
// 41:   it "reports and corrects an offense if `reason` starts with 'it'" do
// 42:     expect_offense <<~CASK
// 43:       cask 'foo' do
// 44:         no_autobump! because: "it does something"
// 45:                               ^^^^^^^^^^^^^^^^^^^ Do not start the reason with `it`
// 46:       end
// 47:     CASK
// 48:
// 49:     expect_correction <<~CASK
// 50:       cask 'foo' do
// 51:         no_autobump! because: "does something"
// 52:       end
// 53:     CASK
// 54:   end
// 55:
// 56:   it "reports and corrects an offense if `reason` ends with a period" do
// 57:     expect_offense <<~CASK
// 58:       cask 'foo' do
// 59:         no_autobump! because: "does something."
// 60:                               ^^^^^^^^^^^^^^^^^ Do not end the reason with a punctuation mark
// 61:       end
// 62:     CASK
// 63:
// 64:     expect_correction <<~CASK
// 65:       cask 'foo' do
// 66:         no_autobump! because: "does something"
// 67:       end
// 68:     CASK
// 69:   end
// 70:
// 71:   it "reports and corrects an offense if `reason` ends with an exclamation point" do
// 72:     expect_offense <<~CASK
// 73:       cask 'foo' do
// 74:         no_autobump! because: "does something!"
// 75:                               ^^^^^^^^^^^^^^^^^ Do not end the reason with a punctuation mark
// 76:       end
// 77:     CASK
// 78:
// 79:     expect_correction <<~CASK
// 80:       cask 'foo' do
// 81:         no_autobump! because: "does something"
// 82:       end
// 83:     CASK
// 84:   end
// 85:
// 86:   it "reports and corrects an offense if `reason` ends with a question mark" do
// 87:     expect_offense <<~CASK
// 88:       cask 'foo' do
// 89:         no_autobump! because: "does something?"
// 90:                               ^^^^^^^^^^^^^^^^^ Do not end the reason with a punctuation mark
// 91:       end
// 92:     CASK
// 93:
// 94:     expect_correction <<~CASK
// 95:       cask 'foo' do
// 96:         no_autobump! because: "does something"
// 97:       end
// 98:     CASK
// 99:   end
// 100: end
