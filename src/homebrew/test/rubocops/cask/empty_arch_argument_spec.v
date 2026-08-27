module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/empty_arch_argument_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports an offense when a trailing `arch` argument is an empty string" do` at line 7.
pub fn ruby_empty_arch_argument_spec_l7_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when a leading `arch` argument is an empty string" do` at line 22.
pub fn ruby_empty_arch_argument_spec_l22_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when every `arch` argument is an empty string" do` at line 37.
pub fn ruby_empty_arch_argument_spec_l37_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when the only `arch` argument is an empty string" do` at line 53.
pub fn ruby_empty_arch_argument_spec_l53_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense without crashing when an `arch` argument key is not a literal" do` at line 69.
pub fn ruby_empty_arch_argument_spec_l69_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses when no `arch` argument is an empty string" do` at line 84.
pub fn ruby_empty_arch_argument_spec_l84_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::EmptyArchArgument, :config do
// 7:   it "reports an offense when a trailing `arch` argument is an empty string" do
// 8:     expect_offense(<<~CASK)
// 9:       cask "foo" do
// 10:         arch arm: "-arm64", intel: ""
// 11:                             ^^^^^^^^^ Remove the empty `intel:` argument from the `arch` stanza.
// 12:       end
// 13:     CASK
// 14:
// 15:     expect_correction(<<~CASK)
// 16:       cask "foo" do
// 17:         arch arm: "-arm64"
// 18:       end
// 19:     CASK
// 20:   end
// 21:
// 22:   it "reports an offense when a leading `arch` argument is an empty string" do
// 23:     expect_offense(<<~CASK)
// 24:       cask "foo" do
// 25:         arch arm: "", intel: "intel"
// 26:              ^^^^^^^ Remove the empty `arm:` argument from the `arch` stanza.
// 27:       end
// 28:     CASK
// 29:
// 30:     expect_correction(<<~CASK)
// 31:       cask "foo" do
// 32:         arch intel: "intel"
// 33:       end
// 34:     CASK
// 35:   end
// 36:
// 37:   it "reports an offense when every `arch` argument is an empty string" do
// 38:     expect_offense(<<~CASK)
// 39:       cask "foo" do
// 40:         arch arm: "", intel: ""
// 41:         ^^^^^^^^^^^^^^^^^^^^^^^ Remove the `arch` stanza as all its arguments are empty.
// 42:         url "https://example.com/foo.zip"
// 43:       end
// 44:     CASK
// 45:
// 46:     expect_correction(<<~CASK)
// 47:       cask "foo" do
// 48:         url "https://example.com/foo.zip"
// 49:       end
// 50:     CASK
// 51:   end
// 52:
// 53:   it "reports an offense when the only `arch` argument is an empty string" do
// 54:     expect_offense(<<~CASK)
// 55:       cask "foo" do
// 56:         arch arm: ""
// 57:         ^^^^^^^^^^^^ Remove the `arch` stanza as all its arguments are empty.
// 58:         url "https://example.com/foo.zip"
// 59:       end
// 60:     CASK
// 61:
// 62:     expect_correction(<<~CASK)
// 63:       cask "foo" do
// 64:         url "https://example.com/foo.zip"
// 65:       end
// 66:     CASK
// 67:   end
// 68:
// 69:   it "reports an offense without crashing when an `arch` argument key is not a literal" do
// 70:     expect_offense(<<~CASK)
// 71:       cask "foo" do
// 72:         arch arm: "-arm64", some_method => ""
// 73:                             ^^^^^^^^^^^^^^^^^ Remove the empty `some_method:` argument from the `arch` stanza.
// 74:       end
// 75:     CASK
// 76:
// 77:     expect_correction(<<~CASK)
// 78:       cask "foo" do
// 79:         arch arm: "-arm64"
// 80:       end
// 81:     CASK
// 82:   end
// 83:
// 84:   it "reports no offenses when no `arch` argument is an empty string" do
// 85:     expect_no_offenses(<<~CASK)
// 86:       cask "foo" do
// 87:         arch arm: "-arm64", intel: "-intel"
// 88:       end
// 89:     CASK
// 90:   end
// 91: end
