module rubocops

import ruby
import homebrew.rubocops as homepage_core

// Translated from Homebrew/brew `test/rubocops/homepage_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_homepage_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::Homepage', 'FormulaAudit/Homepage')
}

// Ruby it `it "reports an offense when there is no homepage" do` at line 10.
pub fn ruby_homepage_spec_l10_d2_reports() bool {
	return homepage_core.audit_formula_homepage("class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\nend").map(it.kind) == [
		'missing',
	]
}

// Ruby it `it "reports an offense when the homepage is not HTTP or HTTPS" do` at line 19.
pub fn ruby_homepage_spec_l19_d3_reports() bool {
	return homepage_core.audit_formula_homepage('class Foo < Formula\n  homepage "ftp://brew.sh/foo"\nend').map(it.kind) == [
		'protocol',
	]
}

// Ruby it `it "reports an offense for freedesktop.org wiki pages" do` at line 29.
pub fn ruby_homepage_spec_l29_d4_reports() bool {
	problems := homepage_core.audit_formula_homepage('class Foo < Formula\n  homepage "http://www.freedesktop.org/wiki/bar"\nend')
	return problems.map(it.kind) == ['freedesktop_style'] && problems[0].message.ends_with('https://wiki.freedesktop.org/project_name')
}

// Ruby it `it "reports an offense for freedesktop.org software wiki pages" do` at line 39.
pub fn ruby_homepage_spec_l39_d5_reports() bool {
	problems := homepage_core.audit_formula_homepage('class Foo < Formula\n  homepage "http://www.freedesktop.org/wiki/Software/baz"\nend')
	return problems.map(it.kind) == ['freedesktop_style'] && problems[0].message.ends_with('https://wiki.freedesktop.org/www/Software/project_name')
}

// Ruby it `it "reports and corrects Google Code homepages" do` at line 49.
pub fn ruby_homepage_spec_l49_d6_reports() bool {
	source := 'class Foo < Formula\n  homepage "https://code.google.com/p/qux"\nend'
	return homepage_core.audit_formula_homepage(source).map(it.kind) == [
		'google_code_slash',
	] && homepage_core.correct_formula_homepage(source).contains('homepage "https://code.google.com/p/qux/"')
}

// Ruby it `it "reports and corrects GitHub homepages" do` at line 66.
pub fn ruby_homepage_spec_l66_d7_reports() bool {
	source := 'class Foo < Formula\n  homepage "https://github.com/foo/bar.git"\nend'
	return homepage_core.audit_formula_homepage(source).map(it.kind) == [
		'github_dot_git',
	] && homepage_core.correct_formula_homepage(source).contains('homepage "https://github.com/foo/bar"')
}

// Ruby let `let(:correct_formula) do` at line 84.
pub fn ruby_homepage_spec_l84_d8_correct_formula() string {
	return 'class Foo < Formula\n  homepage "https://foo.sourceforge.io/"\n  url "https://brew.sh/foo-1.0.tgz"\nend\n'
}

fn homepage_sourceforge_spec(source_url string) bool {
	source := 'class Foo < Formula\n  homepage "${source_url}"\n  url "https://brew.sh/foo-1.0.tgz"\nend\n'
	return homepage_core.audit_formula_homepage(source).map(it.kind) == [
		'sourceforge_style',
	] && homepage_core.correct_formula_homepage(source) == ruby_homepage_spec_l84_d8_correct_formula()
}

// Ruby it `it "reports and corrects [1]" do` at line 93.
pub fn ruby_homepage_spec_l93_d9_reports() bool {
	return homepage_sourceforge_spec('http://foo.sourceforge.net/')
}

// Ruby it `it "reports and corrects [2]" do` at line 105.
pub fn ruby_homepage_spec_l105_d10_reports() bool {
	return homepage_sourceforge_spec('http://foo.sourceforge.net')
}

// Ruby it `it "reports and corrects [3]" do` at line 117.
pub fn ruby_homepage_spec_l117_d11_reports() bool {
	return homepage_sourceforge_spec('http://foo.sf.net/')
}

// Ruby it `it "reports and corrects readthedocs.org pages" do` at line 130.
pub fn ruby_homepage_spec_l130_d12_reports() bool {
	source := 'class Foo < Formula\n  homepage "https://foo.readthedocs.org"\nend'
	return homepage_core.audit_formula_homepage(source).map(it.kind) == [
		'readthedocs_domain',
	] && homepage_core.correct_formula_homepage(source).contains('homepage "https://foo.readthedocs.io"')
}

// Ruby it `it "reports an offense for HTTP homepages" do` at line 147.
pub fn ruby_homepage_spec_l147_d13_reports() bool {
	homepages := [
		'http://foo.sourceforge.io/',
		'http://savannah.nongnu.org/corge',
		'http://grault.github.io/',
		'http://www.gnome.org/garply',
		'http://www.gnu.org/waldo',
		'http://github.com/quux',
	]
	for homepage in homepages {
		problems := homepage_core.audit_formula_homepage('class Foo < Formula\n  homepage "${homepage}"\nend')
		if problems.map(it.kind) != ['https'] || problems[0].message != 'Please use https:// for ${homepage}' {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/homepage"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Homepage do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing homepage" do
// 10:     it "reports an offense when there is no homepage" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:         ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: Formula should have a homepage.
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:         end
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "reports an offense when the homepage is not HTTP or HTTPS" do
// 20:       expect_offense(<<~RUBY)
// 21:         class Foo < Formula
// 22:           homepage "ftp://brew.sh/foo"
// 23:                    ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: The `homepage` should start with http or https.
// 24:           url "https://brew.sh/foo-1.0.tgz"
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports an offense for freedesktop.org wiki pages" do
// 30:       expect_offense(<<~RUBY)
// 31:         class Foo < Formula
// 32:           homepage "http://www.freedesktop.org/wiki/bar"
// 33:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: Freedesktop homepages should be styled: https://wiki.freedesktop.org/project_name
// 34:           url "https://brew.sh/foo-1.0.tgz"
// 35:         end
// 36:       RUBY
// 37:     end
// 38:
// 39:     it "reports an offense for freedesktop.org software wiki pages" do
// 40:       expect_offense(<<~RUBY)
// 41:         class Foo < Formula
// 42:           homepage "http://www.freedesktop.org/wiki/Software/baz"
// 43:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: Freedesktop homepages should be styled: https://wiki.freedesktop.org/www/Software/project_name
// 44:           url "https://brew.sh/foo-1.0.tgz"
// 45:         end
// 46:       RUBY
// 47:     end
// 48:
// 49:     it "reports and corrects Google Code homepages" do
// 50:       expect_offense(<<~RUBY)
// 51:         class Foo < Formula
// 52:           homepage "https://code.google.com/p/qux"
// 53:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: Google Code homepages should end with a slash
// 54:           url "https://brew.sh/foo-1.0.tgz"
// 55:         end
// 56:       RUBY
// 57:
// 58:       expect_correction(<<~RUBY)
// 59:         class Foo < Formula
// 60:           homepage "https://code.google.com/p/qux/"
// 61:           url "https://brew.sh/foo-1.0.tgz"
// 62:         end
// 63:       RUBY
// 64:     end
// 65:
// 66:     it "reports and corrects GitHub homepages" do
// 67:       expect_offense(<<~RUBY)
// 68:         class Foo < Formula
// 69:           homepage "https://github.com/foo/bar.git"
// 70:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: GitHub homepages should not end with .git
// 71:           url "https://brew.sh/foo-1.0.tgz"
// 72:         end
// 73:       RUBY
// 74:
// 75:       expect_correction(<<~RUBY)
// 76:         class Foo < Formula
// 77:           homepage "https://github.com/foo/bar"
// 78:           url "https://brew.sh/foo-1.0.tgz"
// 79:         end
// 80:       RUBY
// 81:     end
// 82:
// 83:     describe "for SourceForge" do
// 84:       let(:correct_formula) do
// 85:         <<~RUBY
// 86:           class Foo < Formula
// 87:             homepage "https://foo.sourceforge.io/"
// 88:             url "https://brew.sh/foo-1.0.tgz"
// 89:           end
// 90:         RUBY
// 91:       end
// 92:
// 93:       it "reports and corrects [1]" do
// 94:         expect_offense(<<~RUBY)
// 95:           class Foo < Formula
// 96:             homepage "http://foo.sourceforge.net/"
// 97:                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: SourceForge homepages should be: https://foo.sourceforge.io/
// 98:             url "https://brew.sh/foo-1.0.tgz"
// 99:           end
// 100:         RUBY
// 101:
// 102:         expect_correction(correct_formula)
// 103:       end
// 104:
// 105:       it "reports and corrects [2]" do
// 106:         expect_offense(<<~RUBY)
// 107:           class Foo < Formula
// 108:             homepage "http://foo.sourceforge.net"
// 109:                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: SourceForge homepages should be: https://foo.sourceforge.io/
// 110:             url "https://brew.sh/foo-1.0.tgz"
// 111:           end
// 112:         RUBY
// 113:
// 114:         expect_correction(correct_formula)
// 115:       end
// 116:
// 117:       it "reports and corrects [3]" do
// 118:         expect_offense(<<~RUBY)
// 119:           class Foo < Formula
// 120:             homepage "http://foo.sf.net/"
// 121:                      ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: SourceForge homepages should be: https://foo.sourceforge.io/
// 122:             url "https://brew.sh/foo-1.0.tgz"
// 123:           end
// 124:         RUBY
// 125:
// 126:         expect_correction(correct_formula)
// 127:       end
// 128:     end
// 129:
// 130:     it "reports and corrects readthedocs.org pages" do
// 131:       expect_offense(<<~RUBY)
// 132:         class Foo < Formula
// 133:           homepage "https://foo.readthedocs.org"
// 134:                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Homepage: Readthedocs homepages should be: https://foo.readthedocs.io
// 135:           url "https://brew.sh/foo-1.0.tgz"
// 136:         end
// 137:       RUBY
// 138:
// 139:       expect_correction(<<~RUBY)
// 140:         class Foo < Formula
// 141:           homepage "https://foo.readthedocs.io"
// 142:           url "https://brew.sh/foo-1.0.tgz"
// 143:         end
// 144:       RUBY
// 145:     end
// 146:
// 147:     it "reports an offense for HTTP homepages" do
// 148:       formula_homepages = {
// 149:         "sf"     => "http://foo.sourceforge.io/",
// 150:         "corge"  => "http://savannah.nongnu.org/corge",
// 151:         "grault" => "http://grault.github.io/",
// 152:         "garply" => "http://www.gnome.org/garply",
// 153:         "waldo"  => "http://www.gnu.org/waldo",
// 154:         "dotgit" => "http://github.com/quux",
// 155:       }
// 156:
// 157:       formula_homepages.each do |name, homepage|
// 158:         source = <<~RUBY
// 159:           class #{name.capitalize} < Formula
// 160:             homepage "#{homepage}"
// 161:             url "https://brew.sh/#{name}-1.0.tgz"
// 162:           end
// 163:         RUBY
// 164:
// 165:         expected_offenses = [{
// 166:           message:  "FormulaAudit/Homepage: Please use https:// for #{homepage}",
// 167:           severity: :convention,
// 168:           line:     2,
// 169:           column:   11,
// 170:           source:,
// 171:         }]
// 172:
// 173:         expected_offenses.zip([inspect_source(source).last]).each do |expected, actual|
// 174:           expect(actual.message).to eq(expected[:message])
// 175:           expect(actual.severity).to eq(expected[:severity])
// 176:           expect(actual.line).to eq(expected[:line])
// 177:           expect(actual.column).to eq(expected[:column])
// 178:         end
// 179:       end
// 180:     end
// 181:   end
// 182: end
