module rubocops

import homebrew.rubocops as blank_core

// Translated from Homebrew/brew `test/rubocops/blank_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects" do` at line 8.
pub fn ruby_blank_spec_l8_d1_registers() bool {
	sources := [
		'foo.nil? || foo.empty?',
		'nil? || empty?',
		'foo == nil || foo.empty?',
		'nil == foo || foo.empty?',
		'!foo || foo.empty?',
		'foo.nil? || !!foo.empty?',
		'foo == nil || !!foo.empty?',
		'nil == foo || !!foo.empty?',
		'foo.bar.nil? || foo.bar.empty?',
		'FOO.nil? || FOO.empty?',
		'Foo.nil? || Foo.empty?',
		'Foo::Bar.nil? || Foo::Bar.empty?',
		'@foo.nil? || @foo.empty?',
		'\$foo.nil? || \$foo.empty?',
		'@@foo.nil? || @@foo.empty?',
		'foo[bar].nil? || foo[bar].empty?',
		'foo(bar).nil? || foo(bar).empty?',
	]
	corrections := [
		'foo.blank?',
		'blank?',
		'foo.blank?',
		'foo.blank?',
		'foo.blank?',
		'foo.blank?',
		'foo.blank?',
		'foo.blank?',
		'foo.bar.blank?',
		'FOO.blank?',
		'Foo.blank?',
		'Foo::Bar.blank?',
		'@foo.blank?',
		'\$foo.blank?',
		'@@foo.blank?',
		'foo[bar].blank?',
		'foo(bar).blank?',
	]
	for index, source in sources {
		offenses := blank_core.audit_blank(source)
		if offenses.len != 1 || offenses[0].begin_pos != 0 || offenses[0].end_pos != source.len || offenses[0].message != 'Use `${corrections[index]}` instead of `${source}`.' || blank_core.correct_blank(source) != corrections[index] {
			return false
		}
	}
	return true
}

// Ruby it `it "accepts checking nil?" do` at line 20.
pub fn ruby_blank_spec_l20_d2_accepts() bool {
	return blank_core.audit_blank('foo.nil?').len == 0
}

// Ruby it `it "accepts checking empty?" do` at line 24.
pub fn ruby_blank_spec_l24_d3_accepts() bool {
	return blank_core.audit_blank('foo.empty?').len == 0
}

// Ruby it `it "accepts checking nil? || empty? on different objects" do` at line 28.
pub fn ruby_blank_spec_l28_d4_accepts() bool {
	return blank_core.audit_blank('foo.nil? || bar.empty?').len == 0
}

// Ruby it `it "does not break when RHS of `or` is a naked falsiness check" do` at line 33.
pub fn ruby_blank_spec_l33_d5_does() bool {
	return blank_core.audit_blank('foo.empty? || bar').len == 0
}

// Ruby it `it "does not break when LHS of `or` is a naked falsiness check" do` at line 37.
pub fn ruby_blank_spec_l37_d6_does() bool {
	return blank_core.audit_blank('bar || foo.empty?').len == 0
}

// Ruby it `it "does not break when LHS of `or` is a send node with an argument" do` at line 42.
pub fn ruby_blank_spec_l42_d7_does() bool {
	return blank_core.audit_blank('x(1) || something').len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/blank"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::Blank, :config do
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
// 32:   # Bug: https://github.com/rubocop/rubocop/issues/4171
// 33:   it "does not break when RHS of `or` is a naked falsiness check" do
// 34:     expect_no_offenses("foo.empty? || bar")
// 35:   end
// 36:
// 37:   it "does not break when LHS of `or` is a naked falsiness check" do
// 38:     expect_no_offenses("bar || foo.empty?")
// 39:   end
// 40:
// 41:   # Bug: https://github.com/rubocop/rubocop/issues/4814
// 42:   it "does not break when LHS of `or` is a send node with an argument" do
// 43:     expect_no_offenses("x(1) || something")
// 44:   end
// 45:
// 46:   context "when nil or empty" do
// 47:     it_behaves_like "offense", "foo.nil? || foo.empty?",
// 48:                     "foo.blank?",
// 49:                     "Use `foo.blank?` instead of `foo.nil? || foo.empty?`."
// 50:     it_behaves_like "offense", "nil? || empty?", "blank?", "Use `blank?` instead of `nil? || empty?`."
// 51:     it_behaves_like "offense", "foo == nil || foo.empty?",
// 52:                     "foo.blank?",
// 53:                     "Use `foo.blank?` instead of `foo == nil || foo.empty?`."
// 54:     it_behaves_like "offense", "nil == foo || foo.empty?",
// 55:                     "foo.blank?",
// 56:                     "Use `foo.blank?` instead of `nil == foo || foo.empty?`."
// 57:     it_behaves_like "offense", "!foo || foo.empty?", "foo.blank?",
// 58:                     "Use `foo.blank?` instead of `!foo || foo.empty?`."
// 59:
// 60:     it_behaves_like "offense", "foo.nil? || !!foo.empty?",
// 61:                     "foo.blank?",
// 62:                     "Use `foo.blank?` instead of `foo.nil? || !!foo.empty?`."
// 63:     it_behaves_like "offense", "foo == nil || !!foo.empty?",
// 64:                     "foo.blank?",
// 65:                     "Use `foo.blank?` instead of " \
// 66:                     "`foo == nil || !!foo.empty?`."
// 67:     it_behaves_like "offense", "nil == foo || !!foo.empty?",
// 68:                     "foo.blank?",
// 69:                     "Use `foo.blank?` instead of " \
// 70:                     "`nil == foo || !!foo.empty?`."
// 71:   end
// 72:
// 73:   context "when checking all variable types" do
// 74:     it_behaves_like "offense", "foo.bar.nil? || foo.bar.empty?",
// 75:                     "foo.bar.blank?",
// 76:                     "Use `foo.bar.blank?` instead of " \
// 77:                     "`foo.bar.nil? || foo.bar.empty?`."
// 78:     it_behaves_like "offense", "FOO.nil? || FOO.empty?",
// 79:                     "FOO.blank?",
// 80:                     "Use `FOO.blank?` instead of `FOO.nil? || FOO.empty?`."
// 81:     it_behaves_like "offense", "Foo.nil? || Foo.empty?",
// 82:                     "Foo.blank?",
// 83:                     "Use `Foo.blank?` instead of `Foo.nil? || Foo.empty?`."
// 84:     it_behaves_like "offense", "Foo::Bar.nil? || Foo::Bar.empty?",
// 85:                     "Foo::Bar.blank?",
// 86:                     "Use `Foo::Bar.blank?` instead of " \
// 87:                     "`Foo::Bar.nil? || Foo::Bar.empty?`."
// 88:     it_behaves_like "offense", "@foo.nil? || @foo.empty?",
// 89:                     "@foo.blank?",
// 90:                     "Use `@foo.blank?` instead of `@foo.nil? || @foo.empty?`."
// 91:     it_behaves_like "offense", "$foo.nil? || $foo.empty?",
// 92:                     "$foo.blank?",
// 93:                     "Use `$foo.blank?` instead of `$foo.nil? || $foo.empty?`."
// 94:     it_behaves_like "offense", "@@foo.nil? || @@foo.empty?",
// 95:                     "@@foo.blank?",
// 96:                     "Use `@@foo.blank?` instead of " \
// 97:                     "`@@foo.nil? || @@foo.empty?`."
// 98:     it_behaves_like "offense", "foo[bar].nil? || foo[bar].empty?",
// 99:                     "foo[bar].blank?",
// 100:                     "Use `foo[bar].blank?` instead of " \
// 101:                     "`foo[bar].nil? || foo[bar].empty?`."
// 102:     it_behaves_like "offense", "foo(bar).nil? || foo(bar).empty?",
// 103:                     "foo(bar).blank?",
// 104:                     "Use `foo(bar).blank?` instead of " \
// 105:                     "`foo(bar).nil? || foo(bar).empty?`."
// 106:   end
// 107: end
