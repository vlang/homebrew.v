module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/homepage_url_styling_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts a homepage URL ending with a slash" do` at line 7.
pub fn ruby_homepage_url_styling_spec_l7_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a homepage URL with a path" do` at line 15.
pub fn ruby_homepage_url_styling_spec_l15_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "reports an offense when the homepage URL does not end with a slash and has no path" do` at line 23.
pub fn ruby_homepage_url_styling_spec_l23_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::HomepageUrlStyling, :config do
// 7:   it "accepts a homepage URL ending with a slash" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask 'foo' do
// 10:         homepage 'https://foo.brew.sh/'
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "accepts a homepage URL with a path" do
// 16:     expect_no_offenses <<~CASK
// 17:       cask 'foo' do
// 18:         homepage 'https://foo.brew.sh/path'
// 19:       end
// 20:     CASK
// 21:   end
// 22:
// 23:   it "reports an offense when the homepage URL does not end with a slash and has no path" do
// 24:     expect_offense <<~CASK
// 25:       cask 'foo' do
// 26:         homepage 'https://foo.brew.sh'
// 27:                  ^^^^^^^^^^^^^^^^^^^^^ 'https://foo.brew.sh' must have a slash after the domain.
// 28:       end
// 29:     CASK
// 30:
// 31:     expect_correction <<~CASK
// 32:       cask 'foo' do
// 33:         homepage 'https://foo.brew.sh/'
// 34:       end
// 35:     CASK
// 36:   end
// 37: end
