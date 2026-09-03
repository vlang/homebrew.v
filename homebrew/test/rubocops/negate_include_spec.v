module rubocops

import homebrew.rubocops as negate_include_core

// Translated from Homebrew/brew `test/rubocops/negate_include_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects when using `!include?`" do` at line 7.
pub fn ruby_negate_include_spec_l7_d1_registers() bool {
	source := '!array.include?(2)\n'
	analysis := negate_include_core.analyze_negate_includes(source)
	return analysis.offenses.len == 1 && analysis.offenses[0].begin_pos == 0 && analysis.offenses[0].end_pos == '!array.include?(2)'.len && analysis.offenses[0].message == negate_include_core.negate_include_message && analysis.corrected == 'array.exclude?(2)\n'
}

// Ruby it `it "does not register an offense when using `!include?` without receiver" do` at line 18.
pub fn ruby_negate_include_spec_l18_d2_does() bool {
	return negate_include_core.analyze_negate_includes('!include?(2)\n').offenses.len == 0
}

// Ruby it `it "does not register an offense when using `include?` or `exclude?`" do` at line 24.
pub fn ruby_negate_include_spec_l24_d3_does() bool {
	source := 'array.include?(2)\narray.exclude?(2)\n'
	return negate_include_core.analyze_negate_includes(source).offenses.len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/negate_include"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::NegateInclude, :config do
// 7:   it "registers an offense and corrects when using `!include?`" do
// 8:     expect_offense(<<~RUBY)
// 9:       !array.include?(2)
// 10:       ^^^^^^^^^^^^^^^^^^ Use `.exclude?` and remove the negation part.
// 11:     RUBY
// 12:
// 13:     expect_correction(<<~RUBY)
// 14:       array.exclude?(2)
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "does not register an offense when using `!include?` without receiver" do
// 19:     expect_no_offenses(<<~RUBY)
// 20:       !include?(2)
// 21:     RUBY
// 22:   end
// 23:
// 24:   it "does not register an offense when using `include?` or `exclude?`" do
// 25:     expect_no_offenses(<<~RUBY)
// 26:       array.include?(2)
// 27:       array.exclude?(2)
// 28:     RUBY
// 29:   end
// 30: end
