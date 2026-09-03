module rubocops

import homebrew.rubocops as full_name_split_core

// Translated from Homebrew/brew `test/rubocops/full_name_split_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers and corrects an offense when using `name.split(\"/\").last`" do` at line 7.
pub fn ruby_full_name_split_spec_l7_d1_registers() bool {
	source := 'name.split("/").last\n'
	offenses := full_name_split_core.audit_full_name_split(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 20 && offenses[0].message == full_name_split_core.full_name_split_message && full_name_split_core.correct_full_name_split(source) == '::Utils.name_from_full_name(name)\n'
}

// Ruby it `it "registers and corrects an offense when using `token.split(\"/\").fetch(-1)`" do` at line 18.
pub fn ruby_full_name_split_spec_l18_d2_registers() bool {
	source := 'token.split("/").fetch(-1)\n'
	offenses := full_name_split_core.audit_full_name_split(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 26 && full_name_split_core.correct_full_name_split(source) == '::Utils.name_from_full_name(token)\n'
}

// Ruby it `it "registers and corrects an offense when using a safe navigation split" do` at line 29.
pub fn ruby_full_name_split_spec_l29_d3_registers() bool {
	source := 'dep["full_name"]&.split("/")&.last\n'
	offenses := full_name_split_core.audit_full_name_split(source)
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 34 && offenses[0].call.safe_navigation && full_name_split_core.correct_full_name_split(source) == 'dep["full_name"]&.then { ::Utils.name_from_full_name(it) }\n'
}

// Ruby it `it "registers and corrects an offense for known full-name variables" do` at line 40.
pub fn ruby_full_name_split_spec_l40_d4_registers() bool {
	source := 'dep_name.split("/").last\nfull_name.split("/").last\n'
	offenses := full_name_split_core.audit_full_name_split(source)
	return offenses.len == 2 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'dep_name.split("/").last' && source[offenses[1].begin_pos..offenses[1].end_pos] == 'full_name.split("/").last' && full_name_split_core.correct_full_name_split(source) == '::Utils.name_from_full_name(dep_name)\n::Utils.name_from_full_name(full_name)\n'
}

// Ruby it `it "does not register an offense for URL or path component parsing" do` at line 54.
pub fn ruby_full_name_split_spec_l54_d5_does() bool {
	source := 'url.split("/").last\nline.split("/").fetch(-1)\nfile_name.split("/").last\n'
	return full_name_split_core.audit_full_name_split(source).len == 0
}

// Ruby it `it "does not register an offense for two-part tap full names" do` at line 62.
pub fn ruby_full_name_split_spec_l62_d6_does() bool {
	source := 'user, repo = tap.full_name.split("/")\ntap.full_name.split("/").last\nformula.tap.full_name.split("/").last\ntap_name.split("/").last\n'
	return full_name_split_core.audit_full_name_split(source).len == 0
}

// Ruby it `it "does not register an offense for mixed safe navigation" do` at line 71.
pub fn ruby_full_name_split_spec_l71_d7_does() bool {
	source := 'name&.split("/").last\nname.split("/")&.last\n'
	return full_name_split_core.audit_full_name_split(source).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/full_name_split"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::FullNameSplit, :config do
// 7:   it "registers and corrects an offense when using `name.split(\"/\").last`" do
// 8:     expect_offense(<<~RUBY)
// 9:       name.split("/").last
// 10:       ^^^^^^^^^^^^^^^^^^^^ Use `Utils.name_from_full_name` instead of splitting formula or cask full names.
// 11:     RUBY
// 12:
// 13:     expect_correction(<<~RUBY)
// 14:       ::Utils.name_from_full_name(name)
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "registers and corrects an offense when using `token.split(\"/\").fetch(-1)`" do
// 19:     expect_offense(<<~RUBY)
// 20:       token.split("/").fetch(-1)
// 21:       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils.name_from_full_name` instead of splitting formula or cask full names.
// 22:     RUBY
// 23:
// 24:     expect_correction(<<~RUBY)
// 25:       ::Utils.name_from_full_name(token)
// 26:     RUBY
// 27:   end
// 28:
// 29:   it "registers and corrects an offense when using a safe navigation split" do
// 30:     expect_offense(<<~RUBY)
// 31:       dep["full_name"]&.split("/")&.last
// 32:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils.name_from_full_name` instead of splitting formula or cask full names.
// 33:     RUBY
// 34:
// 35:     expect_correction(<<~RUBY)
// 36:       dep["full_name"]&.then { ::Utils.name_from_full_name(it) }
// 37:     RUBY
// 38:   end
// 39:
// 40:   it "registers and corrects an offense for known full-name variables" do
// 41:     expect_offense(<<~RUBY)
// 42:       dep_name.split("/").last
// 43:       ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils.name_from_full_name` instead of splitting formula or cask full names.
// 44:       full_name.split("/").last
// 45:       ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils.name_from_full_name` instead of splitting formula or cask full names.
// 46:     RUBY
// 47:
// 48:     expect_correction(<<~RUBY)
// 49:       ::Utils.name_from_full_name(dep_name)
// 50:       ::Utils.name_from_full_name(full_name)
// 51:     RUBY
// 52:   end
// 53:
// 54:   it "does not register an offense for URL or path component parsing" do
// 55:     expect_no_offenses(<<~RUBY)
// 56:       url.split("/").last
// 57:       line.split("/").fetch(-1)
// 58:       file_name.split("/").last
// 59:     RUBY
// 60:   end
// 61:
// 62:   it "does not register an offense for two-part tap full names" do
// 63:     expect_no_offenses(<<~RUBY)
// 64:       user, repo = tap.full_name.split("/")
// 65:       tap.full_name.split("/").last
// 66:       formula.tap.full_name.split("/").last
// 67:       tap_name.split("/").last
// 68:     RUBY
// 69:   end
// 70:
// 71:   it "does not register an offense for mixed safe navigation" do
// 72:     expect_no_offenses(<<~RUBY)
// 73:       name&.split("/").last
// 74:       name.split("/")&.last
// 75:     RUBY
// 76:   end
// 77: end
