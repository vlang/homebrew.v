module rubocops

import ruby
import homebrew.rubocops as desc_core

// Translated from Homebrew/brew `test/rubocops/desc_spec.rb`.
// The original source is retained below for line-level provenance.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_desc_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::Desc', 'FormulaAudit/Desc')
}

// Ruby it `it "reports an offense when there is no `desc`" do` at line 10.
pub fn ruby_desc_spec_l10_d2_reports() bool {
	source := "class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['missing'] && source[problems[0].begin_pos..problems[0].end_pos] == 'class Foo < Formula'
}

// Ruby it `it "reports an offense when `desc` is an empty string" do` at line 19.
pub fn ruby_desc_spec_l19_d3_reports() bool {
	source := "class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\n  desc ''\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['empty'] && source[problems[0].begin_pos..problems[0].end_pos] == "desc ''"
}

// Ruby it `it "reports an offense when `desc` is too long" do` at line 29.
pub fn ruby_desc_spec_l29_d4_reports() bool {
	description := 'Bar' + 'bar'.repeat(29)
	source := "class Foo < Formula\n  desc '${description}'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['too_long'] && problems[0].description.runes().len == 90 && problems[0].message.ends_with('The current length is 90.')
}

// Ruby it `it "reports an offense when `desc` is a multiline string" do` at line 39.
pub fn ruby_desc_spec_l39_d5_reports() bool {
	first := 'Bar' + 'bar'.repeat(9)
	second := 'foo'.repeat(21)
	source := "class Foo < Formula\n  desc '${first}'\\\n    '${second}'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['too_long'] && problems[0].description.runes().len == 93 && problems[0].message.ends_with('The current length is 93.')
}

// Ruby it `it "reports an offense when the description starts with a leading space" do` at line 52.
pub fn ruby_desc_spec_l52_d6_reports() bool {
	source := "class Foo < Formula\n  desc ' Description with a leading space'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['leading_space'] && source[problems[0].begin_pos..problems[0].end_pos] == ' '
}

// Ruby it `it "reports an offense when the description ends with a trailing space" do` at line 62.
pub fn ruby_desc_spec_l62_d7_reports() bool {
	source := "class Foo < Formula\n  desc 'Description with a trailing space '\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['trailing_space'] && source[problems[0].begin_pos..problems[0].end_pos] == ' '
}

// Ruby it `it "reports an offense when \"command-line\" is incorrectly spelled in the description" do` at line 72.
pub fn ruby_desc_spec_l72_d8_reports() bool {
	source := "class Foo < Formula\n  desc 'command line'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['command_line', 'lowercase'] && problems[0].message == 'Description should use "command-line" instead of "command line".' && source[problems[0].begin_pos..problems[0].end_pos] == 'command line'
}

// Ruby it `it "reports an offense when an article is used in the description" do` at line 83.
pub fn ruby_desc_spec_l83_d9_reports() bool {
	a_source := "class Foo < Formula\n  desc 'An aardvark'\nend"
	the_source := "class Foo < Formula\n  desc 'The aardvark'\nend"
	a_problems := desc_core.audit_formula_desc(a_source, 'foo')
	the_problems := desc_core.audit_formula_desc(the_source, 'foo')
	return a_problems.map(it.kind) == ['article'] && a_source[a_problems[0].begin_pos..a_problems[0].end_pos] == 'An' && the_problems.map(it.kind) == [
		'article',
	] && the_source[the_problems[0].begin_pos..the_problems[0].end_pos] == 'The'
}

// Ruby it `it "reports an offense when the description starts with a lowercase letter" do` at line 101.
pub fn ruby_desc_spec_l101_d10_reports() bool {
	source := "class Foo < Formula\n  desc 'bar'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['lowercase'] && source[problems[0].begin_pos..problems[0].end_pos] == 'b'
}

// Ruby it `it "reports an offense when the description starts with the formula name" do` at line 111.
pub fn ruby_desc_spec_l111_d11_reports() bool {
	source := "class Foo < Formula\n  desc 'Foo is a foobar'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['name'] && source[problems[0].begin_pos..problems[0].end_pos] == 'Foo'
}

// Ruby it `it "report and corrects an offense when the description ends with a full stop" do` at line 121.
pub fn ruby_desc_spec_l121_d12_report() bool {
	source := "class Foo < Formula\n  desc 'Description with a full stop at the end.'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['full_stop'] && source[problems[0].begin_pos..problems[0].end_pos] == '.' && desc_core.correct_formula_desc(source, 'foo') == "class Foo < Formula\n  desc 'Description with a full stop at the end'\nend"
}

// Ruby it `it "reports and corrects an offense when the description contains Unicode So characters" do` at line 138.
pub fn ruby_desc_spec_l138_d13_reports() bool {
	source := "class Foo < Formula\n  desc 'Description with a 🍺 symbol'\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['symbol'] && source[problems[0].begin_pos..problems[0].end_pos] == '🍺' && desc_core.correct_formula_desc(source, 'foo') == "class Foo < Formula\n  desc 'Description with a symbol'\nend"
}

// Ruby it `it "does not report an offense when the description ends with 'etc.'" do` at line 155.
pub fn ruby_desc_spec_l155_d14_does() bool {
	source := "class Foo < Formula\n  desc 'Description of a thing and some more things and some more etc.'\nend"
	return desc_core.audit_formula_desc(source, 'foo').len == 0
}

// Ruby it `it "reports and corrects all rules for description text" do` at line 164.
pub fn ruby_desc_spec_l164_d15_reports() bool {
	source := "class Foo < Formula\n  desc ' an bar: commandline foo '\nend"
	problems := desc_core.audit_formula_desc(source, 'foo')
	return problems.map(it.kind) == ['leading_space', 'trailing_space', 'command_line'] && desc_core.correct_formula_desc(source, 'foo') == "class Foo < Formula\n  desc 'Bar: command-line'\nend"
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/desc"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Desc do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula `desc` methods" do
// 10:     it "reports an offense when there is no `desc`" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:         ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Desc: Formula should have a `desc` (description).
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:         end
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "reports an offense when `desc` is an empty string" do
// 20:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 21:         class Foo < Formula
// 22:           url 'https://brew.sh/foo-1.0.tgz'
// 23:           desc ''
// 24:           ^^^^^^^ FormulaAudit/Desc: The `desc` (description) should not be an empty string.
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports an offense when `desc` is too long" do
// 30:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 31:         class Foo < Formula
// 32:           url 'https://brew.sh/foo-1.0.tgz'
// 33:           desc 'Bar#{"bar" * 29}'
// 34:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Desc: Description is too long. It should be less than 80 characters. The current length is 90.
// 35:         end
// 36:       RUBY
// 37:     end
// 38:
// 39:     it "reports an offense when `desc` is a multiline string" do
// 40:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 41:         class Foo < Formula
// 42:           url 'https://brew.sh/foo-1.0.tgz'
// 43:           desc 'Bar#{"bar" * 9}'\
// 44:             '#{"foo" * 21}'
// 45:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Desc: Description is too long. It should be less than 80 characters. The current length is 93.
// 46:         end
// 47:       RUBY
// 48:     end
// 49:   end
// 50:
// 51:   context "when auditing formula description texts" do
// 52:     it "reports an offense when the description starts with a leading space" do
// 53:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 54:         class Foo < Formula
// 55:           url 'https://brew.sh/foo-1.0.tgz'
// 56:           desc ' Description with a leading space'
// 57:                 ^ FormulaAudit/Desc: Description shouldn't have leading spaces.
// 58:         end
// 59:       RUBY
// 60:     end
// 61:
// 62:     it "reports an offense when the description ends with a trailing space" do
// 63:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 64:         class Foo < Formula
// 65:           url 'https://brew.sh/foo-1.0.tgz'
// 66:           desc 'Description with a trailing space '
// 67:                                                  ^ FormulaAudit/Desc: Description shouldn't have trailing spaces.
// 68:         end
// 69:       RUBY
// 70:     end
// 71:
// 72:     it "reports an offense when \"command-line\" is incorrectly spelled in the description" do
// 73:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 74:         class Foo < Formula
// 75:           url 'https://brew.sh/foo-1.0.tgz'
// 76:           desc 'command line'
// 77:                 ^ FormulaAudit/Desc: Description should start with a capital letter.
// 78:                 ^^^^^^^^^^^^ FormulaAudit/Desc: Description should use "command-line" instead of "command line".
// 79:         end
// 80:       RUBY
// 81:     end
// 82:
// 83:     it "reports an offense when an article is used in the description" do
// 84:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 85:         class Foo < Formula
// 86:           url 'https://brew.sh/foo-1.0.tgz'
// 87:           desc 'An aardvark'
// 88:                 ^^ FormulaAudit/Desc: Description shouldn't start with an article.
// 89:         end
// 90:       RUBY
// 91:
// 92:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 93:         class Foo < Formula
// 94:           url 'https://brew.sh/foo-1.0.tgz'
// 95:           desc 'The aardvark'
// 96:                 ^^^ FormulaAudit/Desc: Description shouldn't start with an article.
// 97:         end
// 98:       RUBY
// 99:     end
// 100:
// 101:     it "reports an offense when the description starts with a lowercase letter" do
// 102:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 103:         class Foo < Formula
// 104:           url 'https://brew.sh/foo-1.0.tgz'
// 105:           desc 'bar'
// 106:                 ^ FormulaAudit/Desc: Description should start with a capital letter.
// 107:         end
// 108:       RUBY
// 109:     end
// 110:
// 111:     it "reports an offense when the description starts with the formula name" do
// 112:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 113:         class Foo < Formula
// 114:           url 'https://brew.sh/foo-1.0.tgz'
// 115:           desc 'Foo is a foobar'
// 116:                 ^^^ FormulaAudit/Desc: Description shouldn't start with the formula name.
// 117:         end
// 118:       RUBY
// 119:     end
// 120:
// 121:     it "report and corrects an offense when the description ends with a full stop" do
// 122:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 123:         class Foo < Formula
// 124:           url 'https://brew.sh/foo-1.0.tgz'
// 125:           desc 'Description with a full stop at the end.'
// 126:                                                        ^ FormulaAudit/Desc: Description shouldn't end with a full stop.
// 127:         end
// 128:       RUBY
// 129:
// 130:       expect_correction(<<~RUBY)
// 131:         class Foo < Formula
// 132:           url 'https://brew.sh/foo-1.0.tgz'
// 133:           desc 'Description with a full stop at the end'
// 134:         end
// 135:       RUBY
// 136:     end
// 137:
// 138:     it "reports and corrects an offense when the description contains Unicode So characters" do
// 139:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 140:         class Foo < Formula
// 141:           url 'https://brew.sh/foo-1.0.tgz'
// 142:           desc 'Description with a 🍺 symbol'
// 143:                                    ^ FormulaAudit/Desc: Description shouldn't contain Unicode emojis or symbols.
// 144:         end
// 145:       RUBY
// 146:
// 147:       expect_correction(<<~RUBY)
// 148:         class Foo < Formula
// 149:           url 'https://brew.sh/foo-1.0.tgz'
// 150:           desc 'Description with a symbol'
// 151:         end
// 152:       RUBY
// 153:     end
// 154:
// 155:     it "does not report an offense when the description ends with 'etc.'" do
// 156:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 157:         class Foo < Formula
// 158:           url 'https://brew.sh/foo-1.0.tgz'
// 159:           desc 'Description of a thing and some more things and some more etc.'
// 160:         end
// 161:       RUBY
// 162:     end
// 163:
// 164:     it "reports and corrects all rules for description text" do
// 165:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 166:         class Foo < Formula
// 167:           url 'https://brew.sh/foo-1.0.tgz'
// 168:           desc ' an bar: commandline foo '
// 169:                                         ^ FormulaAudit/Desc: Description shouldn't have trailing spaces.
// 170:                          ^^^^^^^^^^^ FormulaAudit/Desc: Description should use "command-line" instead of "commandline".
// 171:                 ^ FormulaAudit/Desc: Description shouldn't have leading spaces.
// 172:         end
// 173:       RUBY
// 174:
// 175:       expect_correction(<<~RUBY)
// 176:         class Foo < Formula
// 177:           url 'https://brew.sh/foo-1.0.tgz'
// 178:           desc 'Bar: command-line'
// 179:         end
// 180:       RUBY
// 181:     end
// 182:   end
// 183: end
