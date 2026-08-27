module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/discontinued_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports no offenses when there is no `caveats` stanza" do` at line 7.
pub fn ruby_discontinued_spec_l7_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses when there is a `caveats` stanza without `discontinued`" do` at line 15.
pub fn ruby_discontinued_spec_l15_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when there is a `caveats` stanza with `discontinued` and other caveats" do` at line 27.
pub fn ruby_discontinued_spec_l27_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "corrects `caveats { discontinued }` to `deprecate!`" do` at line 41.
pub fn ruby_discontinued_spec_l41_d4_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::Discontinued, :config do
// 7:   it "reports no offenses when there is no `caveats` stanza" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask "foo" do
// 10:         url "https://example.com/download/foo-v1.2.0.dmg"
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "reports no offenses when there is a `caveats` stanza without `discontinued`" do
// 16:     expect_no_offenses <<~CASK
// 17:       cask "foo" do
// 18:         url "https://example.com/download/foo-v1.2.0.dmg"
// 19:
// 20:         caveats do
// 21:           files_in_usr_local
// 22:         end
// 23:       end
// 24:     CASK
// 25:   end
// 26:
// 27:   it "reports an offense when there is a `caveats` stanza with `discontinued` and other caveats" do
// 28:     expect_offense <<~CASK
// 29:       cask "foo" do
// 30:         url "https://example.com/download/foo-v1.2.0.dmg"
// 31:
// 32:         caveats do
// 33:           discontinued
// 34:           ^^^^^^^^^^^^ Use `deprecate!` instead of `caveats { discontinued }`.
// 35:           files_in_usr_local
// 36:         end
// 37:       end
// 38:     CASK
// 39:   end
// 40:
// 41:   it "corrects `caveats { discontinued }` to `deprecate!`" do
// 42:     expect_offense <<~CASK
// 43:       cask "foo" do
// 44:         url "https://example.com/download/foo-v1.2.0.dmg"
// 45:
// 46:         caveats do
// 47:         ^^^^^^^^^^ Use `deprecate!` instead of `caveats { discontinued }`.
// 48:           discontinued
// 49:         end
// 50:       end
// 51:     CASK
// 52:
// 53:     expect_correction <<~CASK
// 54:       cask "foo" do
// 55:         url "https://example.com/download/foo-v1.2.0.dmg"
// 56:
// 57:         deprecate! date: "#{Date.today}", because: :discontinued
// 58:       end
// 59:     CASK
// 60:   end
// 61: end
