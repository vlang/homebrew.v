module cask

import homebrew.rubocops.cask as desc_core

// Translated from Homebrew/brew `test/rubocops/cask/desc_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "does not start with an article" do` at line 7.
pub fn ruby_desc_spec_l7_d1_does() bool {
	accepted := 'cask "foo" do\n  desc "Bar program"\nend'
	a_source := "cask 'foo' do\n  desc 'A bar program'\nend"
	the_source := "cask 'foo' do\n  desc 'The bar program'\nend"
	a_offenses := desc_core.audit_cask_desc(a_source)
	the_offenses := desc_core.audit_cask_desc(the_source)
	return desc_core.audit_cask_desc(accepted).len == 0 && a_offenses.len == 1 && a_source[a_offenses[0].begin_pos..a_offenses[0].end_pos] == 'A' && a_offenses[0].message == desc_core.cask_desc_article_message && the_offenses.len == 1 && the_source[the_offenses[0].begin_pos..the_offenses[0].end_pos] == 'The' && desc_core.correct_cask_desc(the_source) == "cask 'foo' do\n  desc 'Bar program'\nend"
}

// Ruby it `it "does not start with the cask name" do` at line 35.
pub fn ruby_desc_spec_l35_d2_does() bool {
	cases := {
		'foobar':  ['Foo bar program', 'Foo-Bar program']
		'foo-bar': ['Foo bar program', 'Foo-Bar program', 'Foo Bar']
	}
	for cask_name, descriptions in cases {
		for description in descriptions {
			source := "cask '${cask_name}' do\n  desc '${description}'\nend"
			offenses := desc_core.audit_cask_desc(source)
			if offenses.len != 1 || offenses[0].message != desc_core.cask_desc_name_message || source[offenses[0].begin_pos..offenses[0].end_pos] != description.all_before(' program') {
				return false
			}
		}
	}
	return true
}

// Ruby it `it "does not contain the platform" do` at line 72.
pub fn ruby_desc_spec_l72_d3_does() bool {
	cases := {
		'macOS status bar monitor':                                 'macOS'
		'Toggles dark mode on macOS Catalina':                      'macOS'
		'Better input source switcher for OS X':                    'OS X'
		'Media Manager for Mac OS X':                               'Mac OS X'
		'Application for managing macOS virtual machines on macOS': 'macOS'
	}
	for description, platform in cases {
		source := "cask 'foo' do\n  desc '${description}'\nend"
		offenses := desc_core.audit_cask_desc(source)
		if offenses.len != 1 || offenses[0].message != desc_core.cask_desc_platform_message || source[offenses[0].begin_pos..offenses[0].end_pos] != platform {
			return false
		}
	}
	virtual_machines := "cask 'foo' do\n  desc 'Application for managing macOS virtual machines'\nend"
	mac_address := "cask 'foo' do\n  desc 'MAC address changer'\nend"
	emoji := "cask 'foo' do\n  desc 'Description with a 🍺 symbol'\nend"
	emoji_offenses := desc_core.audit_cask_desc(emoji)
	return desc_core.audit_cask_desc(virtual_machines).len == 0 && desc_core.audit_cask_desc(mac_address).len == 0 && emoji_offenses.len == 1 && emoji_offenses[0].message == desc_core.cask_desc_symbol_message && emoji[emoji_offenses[0].begin_pos..emoji_offenses[0].end_pos] == '🍺'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::Desc, :config do
// 7:   it "does not start with an article" do
// 8:     expect_no_offenses <<~RUBY
// 9:       cask "foo" do
// 10:         desc "Bar program"
// 11:       end
// 12:     RUBY
// 13:
// 14:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 15:       cask 'foo' do
// 16:         desc 'A bar program'
// 17:               ^ Description shouldn't start with an article.
// 18:       end
// 19:     RUBY
// 20:
// 21:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 22:       cask 'foo' do
// 23:         desc 'The bar program'
// 24:               ^^^ Description shouldn't start with an article.
// 25:       end
// 26:     RUBY
// 27:
// 28:     expect_correction <<~RUBY
// 29:       cask 'foo' do
// 30:         desc 'Bar program'
// 31:       end
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "does not start with the cask name" do
// 36:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 37:       cask 'foobar' do
// 38:         desc 'Foo bar program'
// 39:               ^^^^^^^ Description shouldn't start with the cask name.
// 40:       end
// 41:     RUBY
// 42:
// 43:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 44:       cask 'foobar' do
// 45:         desc 'Foo-Bar program'
// 46:               ^^^^^^^ Description shouldn't start with the cask name.
// 47:       end
// 48:     RUBY
// 49:
// 50:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 51:       cask 'foo-bar' do
// 52:         desc 'Foo bar program'
// 53:               ^^^^^^^ Description shouldn't start with the cask name.
// 54:       end
// 55:     RUBY
// 56:
// 57:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 58:       cask 'foo-bar' do
// 59:         desc 'Foo-Bar program'
// 60:               ^^^^^^^ Description shouldn't start with the cask name.
// 61:       end
// 62:     RUBY
// 63:
// 64:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 65:       cask 'foo-bar' do
// 66:         desc 'Foo Bar'
// 67:               ^^^^^^^ Description shouldn't start with the cask name.
// 68:       end
// 69:     RUBY
// 70:   end
// 71:
// 72:   it "does not contain the platform" do
// 73:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 74:       cask 'foo-bar' do
// 75:         desc 'macOS status bar monitor'
// 76:               ^^^^^ Description shouldn't contain the platform.
// 77:       end
// 78:     RUBY
// 79:
// 80:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 81:       cask 'foo-bar' do
// 82:         desc 'Toggles dark mode on macOS Catalina'
// 83:                                    ^^^^^ Description shouldn't contain the platform.
// 84:       end
// 85:     RUBY
// 86:
// 87:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 88:       cask 'foo-bar' do
// 89:         desc 'Better input source switcher for OS X'
// 90:                                                ^^^^ Description shouldn't contain the platform.
// 91:       end
// 92:     RUBY
// 93:
// 94:     expect_offense <<~RUBY, "/homebrew-cask/Casks/foo.rb"
// 95:       cask 'foo-bar' do
// 96:         desc 'Media Manager for Mac OS X'
// 97:                                 ^^^^^^^^ Description shouldn't contain the platform.
// 98:       end
// 99:     RUBY
// 100:
// 101:     expect_no_offenses <<~RUBY
// 102:       cask 'foo' do
// 103:         desc 'Application for managing macOS virtual machines'
// 104:       end
// 105:     RUBY
// 106:
// 107:     expect_offense <<~RUBY
// 108:       cask 'foo' do
// 109:         desc 'Application for managing macOS virtual machines on macOS'
// 110:                                                                  ^^^^^ Description shouldn't contain the platform.
// 111:       end
// 112:     RUBY
// 113:
// 114:     expect_offense <<~RUBY
// 115:       cask 'foo' do
// 116:         desc 'Description with a 🍺 symbol'
// 117:                                  ^ Description shouldn't contain Unicode emojis or symbols.
// 118:       end
// 119:     RUBY
// 120:
// 121:     expect_no_offenses <<~RUBY
// 122:       cask 'foo' do
// 123:         desc 'MAC address changer'
// 124:       end
// 125:     RUBY
// 126:   end
// 127: end
