module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/url_legacy_comma_separators_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts a simple `version` interpolation" do` at line 7.
pub fn ruby_url_legacy_comma_separators_spec_l7_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts an interpolation using `version.csv`" do` at line 16.
pub fn ruby_url_legacy_comma_separators_spec_l16_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "reports an offense for an interpolation using `version.before_comma`" do` at line 25.
pub fn ruby_url_legacy_comma_separators_spec_l25_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for an interpolation using `version.after_comma`" do` at line 42.
pub fn ruby_url_legacy_comma_separators_spec_l42_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::UrlLegacyCommaSeparators, :config do
// 7:   it "accepts a simple `version` interpolation" do
// 8:     expect_no_offenses <<~'CASK'
// 9:       cask 'foo' do
// 10:         version '1.1'
// 11:         url 'https://foo.brew.sh/foo-#{version}.dmg'
// 12:       end
// 13:     CASK
// 14:   end
// 15:
// 16:   it "accepts an interpolation using `version.csv`" do
// 17:     expect_no_offenses <<~'CASK'
// 18:       cask 'foo' do
// 19:         version '1.1,111'
// 20:         url 'https://foo.brew.sh/foo-#{version.csv.first}.dmg'
// 21:       end
// 22:     CASK
// 23:   end
// 24:
// 25:   it "reports an offense for an interpolation using `version.before_comma`" do
// 26:     expect_offense <<~'CASK'
// 27:       cask 'foo' do
// 28:         version '1.1,111'
// 29:         url 'https://foo.brew.sh/foo-#{version.before_comma}.dmg'
// 30:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `version.csv.first` instead of `version.before_comma` and `version.csv.second` instead of `version.after_comma`.
// 31:       end
// 32:     CASK
// 33:
// 34:     expect_correction <<~'CASK'
// 35:       cask 'foo' do
// 36:         version '1.1,111'
// 37:         url 'https://foo.brew.sh/foo-#{version.csv.first}.dmg'
// 38:       end
// 39:     CASK
// 40:   end
// 41:
// 42:   it "reports an offense for an interpolation using `version.after_comma`" do
// 43:     expect_offense <<~'CASK'
// 44:       cask 'foo' do
// 45:         version '1.1,111'
// 46:         url 'https://foo.brew.sh/foo-#{version.after_comma}.dmg'
// 47:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `version.csv.first` instead of `version.before_comma` and `version.csv.second` instead of `version.after_comma`.
// 48:       end
// 49:     CASK
// 50:
// 51:     expect_correction <<~'CASK'
// 52:       cask 'foo' do
// 53:         version '1.1,111'
// 54:         url 'https://foo.brew.sh/foo-#{version.csv.second}.dmg'
// 55:       end
// 56:     CASK
// 57:   end
// 58: end
