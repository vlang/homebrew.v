module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/safe_navigation_with_blank_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense on a single conditional" do` at line 8.
pub fn ruby_safe_navigation_with_blank_spec_l8_d1_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers an offense on chained conditionals" do` at line 19.
pub fn ruby_safe_navigation_with_blank_spec_l19_d2_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "does not register an offense on `.blank?`" do` at line 30.
pub fn ruby_safe_navigation_with_blank_spec_l30_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "registers no offense" do` at line 38.
pub fn ruby_safe_navigation_with_blank_spec_l38_d4_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/safe_navigation_with_blank"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::SafeNavigationWithBlank, :config do
// 7:   context "when in a conditional" do
// 8:     it "registers an offense on a single conditional" do
// 9:       expect_offense(<<~RUBY)
// 10:         do_something unless foo&.blank?
// 11:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid calling `blank?` with the safe navigation operator in conditionals.
// 12:       RUBY
// 13:
// 14:       expect_correction(<<~RUBY)
// 15:         do_something unless foo.blank?
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "registers an offense on chained conditionals" do
// 20:       expect_offense(<<~RUBY)
// 21:         do_something unless foo&.bar&.blank?
// 22:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid calling `blank?` with the safe navigation operator in conditionals.
// 23:       RUBY
// 24:
// 25:       expect_correction(<<~RUBY)
// 26:         do_something unless foo&.bar.blank?
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "does not register an offense on `.blank?`" do
// 31:       expect_no_offenses(<<~RUBY)
// 32:         return if foo.blank?
// 33:       RUBY
// 34:     end
// 35:   end
// 36:
// 37:   context "when outside a conditional" do
// 38:     it "registers no offense" do
// 39:       expect_no_offenses(<<~RUBY)
// 40:         bar = foo&.blank?
// 41:       RUBY
// 42:     end
// 43:   end
// 44: end
