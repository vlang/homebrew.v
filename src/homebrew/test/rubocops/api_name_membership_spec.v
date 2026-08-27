module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/api_name_membership_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects when scanning `formula_names` with `include?`" do` at line 7.
pub fn ruby_api_name_membership_spec_l7_d1_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers an offense and corrects when scanning `cask_tokens` with `exclude?`" do` at line 18.
pub fn ruby_api_name_membership_spec_l18_d2_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "does not register an offense for membership checks on other receivers" do` at line 29.
pub fn ruby_api_name_membership_spec_l29_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/api_name_membership"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::ApiNameMembership, :config do
// 7:   it "registers an offense and corrects when scanning `formula_names` with `include?`" do
// 8:     expect_offense(<<~RUBY)
// 9:       Homebrew::API.formula_names.include?(name)
// 10:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Homebrew::API.formula_name?` instead of scanning `Homebrew::API.formula_names`.
// 11:     RUBY
// 12:
// 13:     expect_correction(<<~RUBY)
// 14:       Homebrew::API.formula_name?(name)
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "registers an offense and corrects when scanning `cask_tokens` with `exclude?`" do
// 19:     expect_offense(<<~RUBY)
// 20:       Homebrew::API.cask_tokens.exclude?(token)
// 21:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Homebrew::API.cask_token?` instead of scanning `Homebrew::API.cask_tokens`.
// 22:     RUBY
// 23:
// 24:     expect_correction(<<~RUBY)
// 25:       !Homebrew::API.cask_token?(token)
// 26:     RUBY
// 27:   end
// 28:
// 29:   it "does not register an offense for membership checks on other receivers" do
// 30:     expect_no_offenses(<<~RUBY)
// 31:       tap.formula_names.include?(name)
// 32:       formula_names.include?(name)
// 33:       Homebrew::API.formula_aliases.exclude?(name)
// 34:     RUBY
// 35:   end
// 36: end
