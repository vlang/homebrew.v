module rubocops

import homebrew.rubocops as present_core

// Translated from Homebrew/brew `test/rubocops/present_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects" do` at line 8.
pub fn ruby_present_spec_l8_d1_registers() bool {
	sources := [
		'foo && !foo.empty?',
		'!foo.nil? && !foo.empty?',
		'!nil? && !empty?',
		'foo != nil && !foo.empty?',
		'!!foo && !foo.empty?',
		'!foo.nil? && !foo.empty?',
		'!foo.bar.nil? && !foo.bar.empty?',
		'!FOO.nil? && !FOO.empty?',
		'!Foo.nil? && !Foo.empty?',
		'!@foo.nil? && !@foo.empty?',
		'!\$foo.nil? && !\$foo.empty?',
		'!@@foo.nil? && !@@foo.empty?',
		'!foo[bar].nil? && !foo[bar].empty?',
		'!Foo::Bar.nil? && !Foo::Bar.empty?',
		'!foo(bar).nil? && !foo(bar).empty?',
	]
	corrections := [
		'foo.present?',
		'foo.present?',
		'present?',
		'foo.present?',
		'foo.present?',
		'foo.present?',
		'foo.bar.present?',
		'FOO.present?',
		'Foo.present?',
		'@foo.present?',
		'\$foo.present?',
		'@@foo.present?',
		'foo[bar].present?',
		'Foo::Bar.present?',
		'foo(bar).present?',
	]
	for index, source in sources {
		offenses := present_core.audit_present(source)
		if offenses.len != 1 || offenses[0].begin_pos != 0 || offenses[0].end_pos != source.len || offenses[0].message != 'Use `${corrections[index]}` instead of `${source}`.' || present_core.correct_present(source) != corrections[index] {
			return false
		}
	}
	return true
}

// Ruby it `it "accepts checking nil?" do` at line 20.
pub fn ruby_present_spec_l20_d2_accepts() bool {
	return present_core.audit_present('foo.nil?').len == 0
}

// Ruby it `it "accepts checking empty?" do` at line 24.
pub fn ruby_present_spec_l24_d3_accepts() bool {
	return present_core.audit_present('foo.empty?').len == 0
}

// Ruby it `it "accepts checking nil? || empty? on different objects" do` at line 28.
pub fn ruby_present_spec_l28_d4_accepts() bool {
	return present_core.audit_present('foo.nil? || bar.empty?').len == 0
}

// Ruby it `it "accepts checking existence && not empty? on different objects" do` at line 32.
pub fn ruby_present_spec_l32_d5_accepts() bool {
	return present_core.audit_present('foo && !bar.empty?').len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/present"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::Present, :config do
// 7:   shared_examples "offense" do |source, correction, message|
// 8:     it "registers an offense and corrects" do
// 9:       expect_offense(<<~RUBY, source:, message:)
// 10:         #{source}
// 11:         ^{source} #{message}
// 12:       RUBY
// 13:
// 14:       expect_correction(<<~RUBY)
// 15:         #{correction}
// 16:       RUBY
// 17:     end
// 18:   end
// 19:
// 20:   it "accepts checking nil?" do
// 21:     expect_no_offenses("foo.nil?")
// 22:   end
// 23:
// 24:   it "accepts checking empty?" do
// 25:     expect_no_offenses("foo.empty?")
// 26:   end
// 27:
// 28:   it "accepts checking nil? || empty? on different objects" do
// 29:     expect_no_offenses("foo.nil? || bar.empty?")
// 30:   end
// 31:
// 32:   it "accepts checking existence && not empty? on different objects" do
// 33:     expect_no_offenses("foo && !bar.empty?")
// 34:   end
// 35:
// 36:   it_behaves_like "offense", "foo && !foo.empty?",
// 37:                   "foo.present?",
// 38:                   "Use `foo.present?` instead of `foo && !foo.empty?`."
// 39:   it_behaves_like "offense", "!foo.nil? && !foo.empty?",
// 40:                   "foo.present?",
// 41:                   "Use `foo.present?` instead of `!foo.nil? && !foo.empty?`."
// 42:   it_behaves_like "offense", "!nil? && !empty?", "present?",
// 43:                   "Use `present?` instead of `!nil? && !empty?`."
// 44:   it_behaves_like "offense", "foo != nil && !foo.empty?",
// 45:                   "foo.present?",
// 46:                   "Use `foo.present?` instead of `foo != nil && !foo.empty?`."
// 47:   it_behaves_like "offense", "!!foo && !foo.empty?",
// 48:                   "foo.present?",
// 49:                   "Use `foo.present?` instead of `!!foo && !foo.empty?`."
// 50:
// 51:   context "when checking all variable types" do
// 52:     it_behaves_like "offense", "!foo.nil? && !foo.empty?",
// 53:                     "foo.present?",
// 54:                     "Use `foo.present?` instead of " \
// 55:                     "`!foo.nil? && !foo.empty?`."
// 56:     it_behaves_like "offense", "!foo.bar.nil? && !foo.bar.empty?",
// 57:                     "foo.bar.present?",
// 58:                     "Use `foo.bar.present?` instead of " \
// 59:                     "`!foo.bar.nil? && !foo.bar.empty?`."
// 60:     it_behaves_like "offense", "!FOO.nil? && !FOO.empty?",
// 61:                     "FOO.present?",
// 62:                     "Use `FOO.present?` instead of " \
// 63:                     "`!FOO.nil? && !FOO.empty?`."
// 64:     it_behaves_like "offense", "!Foo.nil? && !Foo.empty?",
// 65:                     "Foo.present?",
// 66:                     "Use `Foo.present?` instead of " \
// 67:                     "`!Foo.nil? && !Foo.empty?`."
// 68:     it_behaves_like "offense", "!@foo.nil? && !@foo.empty?",
// 69:                     "@foo.present?",
// 70:                     "Use `@foo.present?` instead of " \
// 71:                     "`!@foo.nil? && !@foo.empty?`."
// 72:     it_behaves_like "offense", "!$foo.nil? && !$foo.empty?",
// 73:                     "$foo.present?",
// 74:                     "Use `$foo.present?` instead of " \
// 75:                     "`!$foo.nil? && !$foo.empty?`."
// 76:     it_behaves_like "offense", "!@@foo.nil? && !@@foo.empty?",
// 77:                     "@@foo.present?",
// 78:                     "Use `@@foo.present?` instead of " \
// 79:                     "`!@@foo.nil? && !@@foo.empty?`."
// 80:     it_behaves_like "offense", "!foo[bar].nil? && !foo[bar].empty?",
// 81:                     "foo[bar].present?",
// 82:                     "Use `foo[bar].present?` instead of " \
// 83:                     "`!foo[bar].nil? && !foo[bar].empty?`."
// 84:     it_behaves_like "offense", "!Foo::Bar.nil? && !Foo::Bar.empty?",
// 85:                     "Foo::Bar.present?",
// 86:                     "Use `Foo::Bar.present?` instead of " \
// 87:                     "`!Foo::Bar.nil? && !Foo::Bar.empty?`."
// 88:     it_behaves_like "offense", "!foo(bar).nil? && !foo(bar).empty?",
// 89:                     "foo(bar).present?",
// 90:                     "Use `foo(bar).present?` instead of " \
// 91:                     "`!foo(bar).nil? && !foo(bar).empty?`."
// 92:   end
// 93: end
