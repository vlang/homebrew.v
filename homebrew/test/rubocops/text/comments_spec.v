module text

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/comments_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn comments_spec_formula(comments string) string {
	indented := comments.split('\n').map('  ${it}').join('\n')
	return 'class Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\n${indented}\nend'
}

fn comments_spec_messages(source string, tap string, expected []string) bool {
	analysis := line_cops.audit_lines_comments(line_cops.LinesContext{
		source: source
		tap: tap
	})
	return analysis.offenses.map(it.message) == expected && analysis.corrected == source
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_comments_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Comments', 'Comments')
}

// Ruby it `it "reports an offense when commented cmake calls exist" do` at line 10.
pub fn ruby_comments_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := comments_spec_formula('# system "cmake", ".", *std_cmake_args')
	return brew_runtime.bool_value(comments_spec_messages(source, '', [
		'Please remove default template comments',
	]))
}

// Ruby it `it "reports an offense when default template comments exist" do` at line 21.
pub fn ruby_comments_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'class Foo < Formula\n  # PLEASE REMOVE\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\nend'
	return brew_runtime.bool_value(comments_spec_messages(source, '', [
		'Please remove default template comments',
	]))
}

// Ruby it `it "reports an offense when `depends_on` is commented" do` at line 32.
pub fn ruby_comments_spec_l32_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := comments_spec_formula('# depends_on "foo"')
	return brew_runtime.bool_value(comments_spec_messages(source, '', [
		'Commented-out dependency "foo"',
	]))
}

// Ruby it `it "reports an offense if citation tags are present" do` at line 43.
pub fn ruby_comments_spec_l43_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := comments_spec_formula('# cite Howell_2009:\n# doi "10.111/222.x"\n# tag "software"')
	return brew_runtime.bool_value(comments_spec_messages(source, 'homebrew-core', [
		'Formulae in homebrew/core should not use `cite` comments',
		'Formulae in homebrew/core should not use `doi` comments',
		'Formulae in homebrew/core should not use `tag` comments',
	]))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Comments do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing comment text" do
// 10:     it "reports an offense when commented cmake calls exist" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           # system "cmake", ".", *std_cmake_args
// 16:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Comments: Please remove default template comments
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports an offense when default template comments exist" do
// 22:       expect_offense(<<~RUBY)
// 23:         class Foo < Formula
// 24:           # PLEASE REMOVE
// 25:           ^^^^^^^^^^^^^^^ FormulaAudit/Comments: Please remove default template comments
// 26:           desc "foo"
// 27:           url 'https://brew.sh/foo-1.0.tgz'
// 28:         end
// 29:       RUBY
// 30:     end
// 31:
// 32:     it "reports an offense when `depends_on` is commented" do
// 33:       expect_offense(<<~RUBY)
// 34:         class Foo < Formula
// 35:           desc "foo"
// 36:           url 'https://brew.sh/foo-1.0.tgz'
// 37:           # depends_on "foo"
// 38:           ^^^^^^^^^^^^^^^^^^ FormulaAudit/Comments: Commented-out dependency "foo"
// 39:         end
// 40:       RUBY
// 41:     end
// 42:
// 43:     it "reports an offense if citation tags are present" do
// 44:       expect_offense(<<~RUBY, "/homebrew-core/")
// 45:         class Foo < Formula
// 46:           desc "foo"
// 47:           url 'https://brew.sh/foo-1.0.tgz'
// 48:           # cite Howell_2009:
// 49:           ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Comments: Formulae in homebrew/core should not use `cite` comments
// 50:           # doi "10.111/222.x"
// 51:           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Comments: Formulae in homebrew/core should not use `doi` comments
// 52:           # tag "software"
// 53:           ^^^^^^^^^^^^^^^^ FormulaAudit/Comments: Formulae in homebrew/core should not use `tag` comments
// 54:         end
// 55:       RUBY
// 56:     end
// 57:   end
// 58: end
