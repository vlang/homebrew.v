module text

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/miscellaneous_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn miscellaneous_spec_formula(body string) string {
	indented := body.split('\n').map('  ${it}').join('\n')
	return 'class Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\n${indented}\nend'
}

fn miscellaneous_spec_reports_source(source string, expected []string) bool {
	analysis := line_cops.audit_lines_miscellaneous(line_cops.LinesContext{
		source: source
	})
	if analysis.offenses.len != expected.len || analysis.corrected != source {
		return false
	}
	for index, message in expected {
		if analysis.offenses[index].message != message {
			return false
		}
	}
	return true
}

fn miscellaneous_spec_reports(body string, expected []string) bool {
	return miscellaneous_spec_reports_source(miscellaneous_spec_formula(body), expected)
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_miscellaneous_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Miscellaneous', 'Miscellaneous')
}

// Ruby it `it "reports an offense for unneeded `FileUtils` usage" do` at line 10.
pub fn ruby_miscellaneous_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('FileUtils.mv "hello"', [
		'No need for `FileUtils.` before `mv`',
	]))
}

// Ruby it `it "reports an offense for long `inreplace` block variable names" do` at line 21.
pub fn ruby_miscellaneous_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('inreplace "foo" do |longvar|\n  somerandomCall(longvar)\nend', [
		'`inreplace <filenames> do |s|` is preferred over `|longvar|`.',
	]))
}

// Ruby it `it "reports an offense for invalid `rebuild` numbers" do` at line 34.
pub fn ruby_miscellaneous_spec_l34_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('bottle do\n  rebuild 0\n  sha256 "fe0679b932dd43a87fd415b609a7fbac7a069d117642ae8ebaac46ae1fb9f0b3" => :sonoma\nend', [
		'`rebuild 0` should be removed',
	]))
}

// Ruby it `it "reports an offense when a useless `fails_with :llvm` is used" do` at line 48.
pub fn ruby_miscellaneous_spec_l48_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	body := 'bottle do\n  sha256 "fe0679b932dd43a87fd415b609a7fbac7a069d117642ae8ebaac46ae1fb9f0b3" => :sonoma\nend\nfails_with :llvm do\n  build 2335\n  cause "foo"\nend'
	return brew_runtime.bool_value(miscellaneous_spec_reports(body, [
		'`fails_with :llvm` is now a no-op and should be removed',
	]))
}

// Ruby it `it "reports an offense when `def test` is used" do` at line 65.
pub fn ruby_miscellaneous_spec_l65_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def test\n  assert_equals "1", "1"\nend', [
		'Use new-style test definitions (`test do`)',
	]))
}

// Ruby method `test` at line 71.
pub fn ruby_miscellaneous_spec_l71_d7_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def test\n  assert_equals "1", "1"\nend')
}

// Ruby it `it "reports an offense when `skip_clean` is used" do` at line 79.
pub fn ruby_miscellaneous_spec_l79_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('skip_clean :all', [
		'`skip_clean :all` is deprecated; brew no longer strips symbols. Pass explicit paths to prevent Homebrew from removing empty folders.',
	]))
}

// Ruby it `it "reports an offense when `install_name_tool` is called" do` at line 90.
pub fn ruby_miscellaneous_spec_l90_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('system "install_name_tool", "-id"', [
		'Use ruby-macho instead of calling "install_name_tool"',
	]))
}

// Ruby it `it "reports an offense when `depends_on` is called with an instance" do` at line 101.
pub fn ruby_miscellaneous_spec_l101_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('depends_on FOO::BAR.new', [
		'`depends_on` can take requirement classes instead of instances',
	]))
}

// Ruby it `it "reports an offense when `Dir` is called without a globbing argument" do` at line 112.
pub fn ruby_miscellaneous_spec_l112_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	body := 'rm_rf Dir["src/{llvm,test,librustdoc,etc/snapshot.pyc}"]\nrm_rf Dir["src/snapshot.pyc"]'
	return brew_runtime.bool_value(miscellaneous_spec_reports(body, [
		'`Dir(["src/snapshot.pyc"])` is unnecessary; just use `src/snapshot.pyc`',
	]))
}

// Ruby it `it "reports an offense when executing a system command for which there is a Ruby FileUtils equivalent" do` at line 124.
pub fn ruby_miscellaneous_spec_l124_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('system "mkdir", "foo"', [
		'Use the `mkdir` Ruby method instead of `system "mkdir", "foo"`',
	]))
}

// Ruby it `it "reports an offense when top-level functions are defined outside of a class body" do` at line 135.
pub fn ruby_miscellaneous_spec_l135_d13_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'def test\n   nil\nend\nclass Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/foo-1.0.tgz\'\nend'
	return brew_runtime.bool_value(miscellaneous_spec_reports_source(source, [
		'Define method `test` in the class body, not at the top-level',
	]))
}

// Ruby method `test` at line 137.
pub fn ruby_miscellaneous_spec_l137_d14_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def test\n   nil\nend')
}

// Ruby it `it 'reports an offense when `man+"man8"` is used' do` at line 148.
pub fn ruby_miscellaneous_spec_l148_d15_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  man1.install man+"man8" => "faad.1"\nend', [
		'`man+"man8"` should be `man8`',
	]))
}

// Ruby method `install` at line 153.
pub fn ruby_miscellaneous_spec_l153_d16_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  man1.install man+"man8" => "faad.1"\nend')
}

// Ruby it `it "reports an offense when a hard-coded `gcc` is referenced" do` at line 161.
pub fn ruby_miscellaneous_spec_l161_d17_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  system "/usr/bin/gcc", "foo"\nend', [
		'Use `#{ENV.cc}` instead of hard-coding `gcc`',
	]))
}

// Ruby method `install` at line 166.
pub fn ruby_miscellaneous_spec_l166_d18_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  system "/usr/bin/gcc", "foo"\nend')
}

// Ruby it `it "reports an offense when a hard-coded `g++` is referenced" do` at line 174.
pub fn ruby_miscellaneous_spec_l174_d19_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  system "/usr/bin/g++", "-o", "foo", "foo.cc"\nend', [
		'Use `#{ENV.cxx}` instead of hard-coding `g++`',
	]))
}

// Ruby method `install` at line 179.
pub fn ruby_miscellaneous_spec_l179_d20_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  system "/usr/bin/g++", "-o", "foo", "foo.cc"\nend')
}

// Ruby it `it "reports an offense when a hard-coded `c++` is set as COMPILER_PATH" do` at line 187.
pub fn ruby_miscellaneous_spec_l187_d21_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  ENV["COMPILER_PATH"] = "/usr/bin/c++"\nend', [
		'Use `#{ENV.cxx}` instead of hard-coding `c++`',
	]))
}

// Ruby method `install` at line 192.
pub fn ruby_miscellaneous_spec_l192_d22_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  ENV["COMPILER_PATH"] = "/usr/bin/c++"\nend')
}

// Ruby it `it "reports an offense when a hard-coded `gcc` is set as COMPILER_PATH" do` at line 200.
pub fn ruby_miscellaneous_spec_l200_d23_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  ENV["COMPILER_PATH"] = "/usr/bin/gcc"\nend', [
		'Use `#{ENV.cc}` instead of hard-coding `gcc`',
	]))
}

// Ruby method `install` at line 205.
pub fn ruby_miscellaneous_spec_l205_d24_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  ENV["COMPILER_PATH"] = "/usr/bin/gcc"\nend')
}

// Ruby it `it "reports an offense when the formula path shortcut `man` could be used" do` at line 213.
pub fn ruby_miscellaneous_spec_l213_d25_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  mv "#{share}/man", share\nend', [
		'`#{share}/man` should be `#{man}`',
	]))
}

// Ruby method `install` at line 218.
pub fn ruby_miscellaneous_spec_l218_d26_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  mv "#{share}/man", share\nend')
}

// Ruby it `it "reports an offense when the formula path shortcut `libexec` could be used" do` at line 226.
pub fn ruby_miscellaneous_spec_l226_d27_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  mv "#{prefix}/libexec", share\nend', [
		'`#{prefix}/libexec` should be `#{libexec}`',
	]))
}

// Ruby method `install` at line 231.
pub fn ruby_miscellaneous_spec_l231_d28_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  mv "#{prefix}/libexec", share\nend')
}

// Ruby it `it "reports an offense when the formula path shortcut `info` could be used" do` at line 239.
pub fn ruby_miscellaneous_spec_l239_d29_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  system "./configure", "--INFODIR=#{prefix}/share/info"\nend', [
		'`#{prefix}/share/info` should be `#{info}`',
	]))
}

// Ruby method `install` at line 244.
pub fn ruby_miscellaneous_spec_l244_d30_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  system "./configure", "--INFODIR=#{prefix}/share/info"\nend')
}

// Ruby it `it "reports an offense when the formula path shortcut `man8` could be used" do` at line 252.
pub fn ruby_miscellaneous_spec_l252_d31_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('def install\n  system "./configure", "--MANDIR=#{prefix}/share/man/man8"\nend', [
		'`#{prefix}/share/man/man8` should be `#{man8}`',
	]))
}

// Ruby method `install` at line 257.
pub fn ruby_miscellaneous_spec_l257_d32_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  system "./configure", "--MANDIR=#{prefix}/share/man/man8"\nend')
}

// Ruby it `it "reports an offense when unvendored lua modules are used" do` at line 265.
pub fn ruby_miscellaneous_spec_l265_d33_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('depends_on "lpeg" => :lua51', [
		'lua modules should be vendored rather than using deprecated `depends_on "lpeg" => :lua51`',
	]))
}

// Ruby it `it "reports an offense when `export` is used to set environment variables" do` at line 276.
pub fn ruby_miscellaneous_spec_l276_d34_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('system "export", "var=value"', [
		'Use `ENV` instead of invoking `export` to modify the environment',
	]))
}

// Ruby it `it "reports an offense when dependencies with invalid options are used" do` at line 287.
pub fn ruby_miscellaneous_spec_l287_d35_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('depends_on "foo" => "with-bar"', [
		"Dependency 'foo' should not use option `with-bar`",
	]))
}

// Ruby it `it "reports an offense when dependencies with invalid options are used in an array" do` at line 298.
pub fn ruby_miscellaneous_spec_l298_d36_reports(args ...brew_runtime.Value) brew_runtime.Value {
	body := 'depends_on "httpd" => [:build, :test]\ndepends_on "foo" => [:optional, "with-bar"]\ndepends_on "icu4c" => [:optional, "c++11"]'
	return brew_runtime.bool_value(miscellaneous_spec_reports(body, [
		"Dependency 'foo' should not use option `with-bar`",
		"Dependency 'icu4c' should not use option `c++11`",
	]))
}

// Ruby it `it "reports an offense when `build.head?` could be used instead of checking `version`" do` at line 312.
pub fn ruby_miscellaneous_spec_l312_d37_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('if version == "HEAD"\n  foo()\nend', [
		'Use `build.head?` instead of inspecting `version`',
	]))
}

// Ruby it `it "reports an offense when `ARGV.include? (--HEAD)` is used" do` at line 325.
pub fn ruby_miscellaneous_spec_l325_d38_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('test do\n  head = ARGV.include? "--HEAD"\nend', [
		'Use `build.with?` or `build.without?` instead of `ARGV` to check options',
		'Use `if build.head?` instead',
	]))
}

// Ruby it `it "reports an offense when `needs :openmp` is used" do` at line 339.
pub fn ruby_miscellaneous_spec_l339_d39_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('needs :openmp', [
		'`needs :openmp` should be replaced with `depends_on "gcc"`',
	]))
}

// Ruby it `it "reports an offense when `MACOS_VERSION` is used" do` at line 350.
pub fn ruby_miscellaneous_spec_l350_d40_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(miscellaneous_spec_reports('test do\n  version = MACOS_VERSION\nend', [
		'Use `MacOS.version` instead of `MACOS_VERSION`',
	]))
}

// Ruby it `it "reports an offense when `build.with?` is used for a conditional dependency" do` at line 363.
pub fn ruby_miscellaneous_spec_l363_d41_reports(args ...brew_runtime.Value) brew_runtime.Value {
	statement := 'depends_on "foo" if build.with? "foo"'
	return brew_runtime.bool_value(miscellaneous_spec_reports(statement, [
		'Replace `${statement}` with `depends_on "foo" => :optional`',
	]))
}

// Ruby it `it "reports an offense when `build.without?` is used for a negated conditional dependency" do` at line 374.
pub fn ruby_miscellaneous_spec_l374_d42_reports(args ...brew_runtime.Value) brew_runtime.Value {
	statement := 'depends_on :foo unless build.without? "foo"'
	return brew_runtime.bool_value(miscellaneous_spec_reports(statement, [
		'Replace `${statement}` with `depends_on :foo => :recommended`',
	]))
}

// Ruby it `it "reports an offense when `build.include?` is used for a negated conditional dependency" do` at line 385.
pub fn ruby_miscellaneous_spec_l385_d43_reports(args ...brew_runtime.Value) brew_runtime.Value {
	statement := 'depends_on :foo unless build.include? "without-foo"'
	return brew_runtime.bool_value(miscellaneous_spec_reports(statement, [
		'Replace `${statement}` with `depends_on :foo => :recommended`',
	]))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Miscellaneous do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula miscellany" do
// 10:     it "reports an offense for unneeded `FileUtils` usage" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           FileUtils.mv "hello"
// 16:           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: No need for `FileUtils.` before `mv`
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports an offense for long `inreplace` block variable names" do
// 22:       expect_offense(<<~RUBY)
// 23:         class Foo < Formula
// 24:           desc "foo"
// 25:           url 'https://brew.sh/foo-1.0.tgz'
// 26:           inreplace "foo" do |longvar|
// 27:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `inreplace <filenames> do |s|` is preferred over `|longvar|`.
// 28:             somerandomCall(longvar)
// 29:           end
// 30:         end
// 31:       RUBY
// 32:     end
// 33:
// 34:     it "reports an offense for invalid `rebuild` numbers" do
// 35:       expect_offense(<<~RUBY)
// 36:         class Foo < Formula
// 37:           desc "foo"
// 38:           url 'https://brew.sh/foo-1.0.tgz'
// 39:           bottle do
// 40:             rebuild 0
// 41:             ^^^^^^^^^ FormulaAudit/Miscellaneous: `rebuild 0` should be removed
// 42:             sha256 "fe0679b932dd43a87fd415b609a7fbac7a069d117642ae8ebaac46ae1fb9f0b3" => :sonoma
// 43:           end
// 44:         end
// 45:       RUBY
// 46:     end
// 47:
// 48:     it "reports an offense when a useless `fails_with :llvm` is used" do
// 49:       expect_offense(<<~RUBY)
// 50:         class Foo < Formula
// 51:           desc "foo"
// 52:           url 'https://brew.sh/foo-1.0.tgz'
// 53:           bottle do
// 54:             sha256 "fe0679b932dd43a87fd415b609a7fbac7a069d117642ae8ebaac46ae1fb9f0b3" => :sonoma
// 55:           end
// 56:           fails_with :llvm do
// 57:           ^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `fails_with :llvm` is now a no-op and should be removed
// 58:             build 2335
// 59:             cause "foo"
// 60:           end
// 61:         end
// 62:       RUBY
// 63:     end
// 64:
// 65:     it "reports an offense when `def test` is used" do
// 66:       expect_offense(<<~RUBY)
// 67:         class Foo < Formula
// 68:           desc "foo"
// 69:           url 'https://brew.sh/foo-1.0.tgz'
// 70:
// 71:           def test
// 72:           ^^^^^^^^ FormulaAudit/Miscellaneous: Use new-style test definitions (`test do`)
// 73:             assert_equals "1", "1"
// 74:           end
// 75:         end
// 76:       RUBY
// 77:     end
// 78:
// 79:     it "reports an offense when `skip_clean` is used" do
// 80:       expect_offense(<<~RUBY)
// 81:         class Foo < Formula
// 82:           desc "foo"
// 83:           url 'https://brew.sh/foo-1.0.tgz'
// 84:           skip_clean :all
// 85:           ^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `skip_clean :all` is deprecated; brew no longer strips symbols. Pass explicit paths to prevent Homebrew from removing empty folders.
// 86:         end
// 87:       RUBY
// 88:     end
// 89:
// 90:     it "reports an offense when `install_name_tool` is called" do
// 91:       expect_offense(<<~RUBY)
// 92:         class Foo < Formula
// 93:           desc "foo"
// 94:           url 'https://brew.sh/foo-1.0.tgz'
// 95:           system "install_name_tool", "-id"
// 96:                  ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use ruby-macho instead of calling "install_name_tool"
// 97:         end
// 98:       RUBY
// 99:     end
// 100:
// 101:     it "reports an offense when `depends_on` is called with an instance" do
// 102:       expect_offense(<<~RUBY)
// 103:         class Foo < Formula
// 104:           desc "foo"
// 105:           url 'https://brew.sh/foo-1.0.tgz'
// 106:           depends_on FOO::BAR.new
// 107:                      ^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `depends_on` can take requirement classes instead of instances
// 108:         end
// 109:       RUBY
// 110:     end
// 111:
// 112:     it "reports an offense when `Dir` is called without a globbing argument" do
// 113:       expect_offense(<<~RUBY)
// 114:         class Foo < Formula
// 115:           desc "foo"
// 116:           url 'https://brew.sh/foo-1.0.tgz'
// 117:           rm_rf Dir["src/{llvm,test,librustdoc,etc/snapshot.pyc}"]
// 118:           rm_rf Dir["src/snapshot.pyc"]
// 119:                     ^^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `Dir(["src/snapshot.pyc"])` is unnecessary; just use `src/snapshot.pyc`
// 120:         end
// 121:       RUBY
// 122:     end
// 123:
// 124:     it "reports an offense when executing a system command for which there is a Ruby FileUtils equivalent" do
// 125:       expect_offense(<<~RUBY)
// 126:         class Foo < Formula
// 127:           desc "foo"
// 128:           url 'https://brew.sh/foo-1.0.tgz'
// 129:           system "mkdir", "foo"
// 130:                  ^^^^^^^ FormulaAudit/Miscellaneous: Use the `mkdir` Ruby method instead of `system "mkdir", "foo"`
// 131:         end
// 132:       RUBY
// 133:     end
// 134:
// 135:     it "reports an offense when top-level functions are defined outside of a class body" do
// 136:       expect_offense(<<~RUBY)
// 137:         def test
// 138:         ^^^^^^^^ FormulaAudit/Miscellaneous: Define method `test` in the class body, not at the top-level
// 139:            nil
// 140:         end
// 141:         class Foo < Formula
// 142:           desc "foo"
// 143:           url 'https://brew.sh/foo-1.0.tgz'
// 144:         end
// 145:       RUBY
// 146:     end
// 147:
// 148:     it 'reports an offense when `man+"man8"` is used' do
// 149:       expect_offense(<<~RUBY)
// 150:         class Foo < Formula
// 151:           desc "foo"
// 152:           url 'https://brew.sh/foo-1.0.tgz'
// 153:           def install
// 154:             man1.install man+"man8" => "faad.1"
// 155:                              ^^^^^^ FormulaAudit/Miscellaneous: `man+"man8"` should be `man8`
// 156:           end
// 157:         end
// 158:       RUBY
// 159:     end
// 160:
// 161:     it "reports an offense when a hard-coded `gcc` is referenced" do
// 162:       expect_offense(<<~'RUBY')
// 163:         class Foo < Formula
// 164:           desc "foo"
// 165:           url 'https://brew.sh/foo-1.0.tgz'
// 166:           def install
// 167:             system "/usr/bin/gcc", "foo"
// 168:                    ^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `#{ENV.cc}` instead of hard-coding `gcc`
// 169:           end
// 170:         end
// 171:       RUBY
// 172:     end
// 173:
// 174:     it "reports an offense when a hard-coded `g++` is referenced" do
// 175:       expect_offense(<<~'RUBY')
// 176:         class Foo < Formula
// 177:           desc "foo"
// 178:           url 'https://brew.sh/foo-1.0.tgz'
// 179:           def install
// 180:             system "/usr/bin/g++", "-o", "foo", "foo.cc"
// 181:                    ^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `#{ENV.cxx}` instead of hard-coding `g++`
// 182:           end
// 183:         end
// 184:       RUBY
// 185:     end
// 186:
// 187:     it "reports an offense when a hard-coded `c++` is set as COMPILER_PATH" do
// 188:       expect_offense(<<~'RUBY')
// 189:         class Foo < Formula
// 190:           desc "foo"
// 191:           url 'https://brew.sh/foo-1.0.tgz'
// 192:           def install
// 193:             ENV["COMPILER_PATH"] = "/usr/bin/c++"
// 194:                                    ^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `#{ENV.cxx}` instead of hard-coding `c++`
// 195:           end
// 196:         end
// 197:       RUBY
// 198:     end
// 199:
// 200:     it "reports an offense when a hard-coded `gcc` is set as COMPILER_PATH" do
// 201:       expect_offense(<<~'RUBY')
// 202:         class Foo < Formula
// 203:           desc "foo"
// 204:           url 'https://brew.sh/foo-1.0.tgz'
// 205:           def install
// 206:             ENV["COMPILER_PATH"] = "/usr/bin/gcc"
// 207:                                    ^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `#{ENV.cc}` instead of hard-coding `gcc`
// 208:           end
// 209:         end
// 210:       RUBY
// 211:     end
// 212:
// 213:     it "reports an offense when the formula path shortcut `man` could be used" do
// 214:       expect_offense(<<~'RUBY')
// 215:         class Foo < Formula
// 216:           desc "foo"
// 217:           url 'https://brew.sh/foo-1.0.tgz'
// 218:           def install
// 219:             mv "#{share}/man", share
// 220:                         ^^^^ FormulaAudit/Miscellaneous: `#{share}/man` should be `#{man}`
// 221:           end
// 222:         end
// 223:       RUBY
// 224:     end
// 225:
// 226:     it "reports an offense when the formula path shortcut `libexec` could be used" do
// 227:       expect_offense(<<~'RUBY')
// 228:         class Foo < Formula
// 229:           desc "foo"
// 230:           url 'https://brew.sh/foo-1.0.tgz'
// 231:           def install
// 232:             mv "#{prefix}/libexec", share
// 233:                          ^^^^^^^^ FormulaAudit/Miscellaneous: `#{prefix}/libexec` should be `#{libexec}`
// 234:           end
// 235:         end
// 236:       RUBY
// 237:     end
// 238:
// 239:     it "reports an offense when the formula path shortcut `info` could be used" do
// 240:       expect_offense(<<~'RUBY')
// 241:         class Foo < Formula
// 242:           desc "foo"
// 243:           url 'https://brew.sh/foo-1.0.tgz'
// 244:           def install
// 245:             system "./configure", "--INFODIR=#{prefix}/share/info"
// 246:                                                       ^^^^^^^^^^^ FormulaAudit/Miscellaneous: `#{prefix}/share/info` should be `#{info}`
// 247:           end
// 248:         end
// 249:       RUBY
// 250:     end
// 251:
// 252:     it "reports an offense when the formula path shortcut `man8` could be used" do
// 253:       expect_offense(<<~'RUBY')
// 254:         class Foo < Formula
// 255:           desc "foo"
// 256:           url 'https://brew.sh/foo-1.0.tgz'
// 257:           def install
// 258:             system "./configure", "--MANDIR=#{prefix}/share/man/man8"
// 259:                                                      ^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `#{prefix}/share/man/man8` should be `#{man8}`
// 260:           end
// 261:         end
// 262:       RUBY
// 263:     end
// 264:
// 265:     it "reports an offense when unvendored lua modules are used" do
// 266:       expect_offense(<<~RUBY)
// 267:         class Foo < Formula
// 268:           desc "foo"
// 269:           url 'https://brew.sh/foo-1.0.tgz'
// 270:           depends_on "lpeg" => :lua51
// 271:                                ^^^^^^ FormulaAudit/Miscellaneous: lua modules should be vendored rather than using deprecated `depends_on "lpeg" => :lua51`
// 272:         end
// 273:       RUBY
// 274:     end
// 275:
// 276:     it "reports an offense when `export` is used to set environment variables" do
// 277:       expect_offense(<<~RUBY)
// 278:         class Foo < Formula
// 279:           desc "foo"
// 280:           url 'https://brew.sh/foo-1.0.tgz'
// 281:           system "export", "var=value"
// 282:                  ^^^^^^^^ FormulaAudit/Miscellaneous: Use `ENV` instead of invoking `export` to modify the environment
// 283:         end
// 284:       RUBY
// 285:     end
// 286:
// 287:     it "reports an offense when dependencies with invalid options are used" do
// 288:       expect_offense(<<~RUBY)
// 289:         class Foo < Formula
// 290:           desc "foo"
// 291:           url 'https://brew.sh/foo-1.0.tgz'
// 292:           depends_on "foo" => "with-bar"
// 293:                               ^^^^^^^^^^ FormulaAudit/Miscellaneous: Dependency 'foo' should not use option `with-bar`
// 294:         end
// 295:       RUBY
// 296:     end
// 297:
// 298:     it "reports an offense when dependencies with invalid options are used in an array" do
// 299:       expect_offense(<<~RUBY)
// 300:         class Foo < Formula
// 301:           desc "foo"
// 302:           url 'https://brew.sh/foo-1.0.tgz'
// 303:           depends_on "httpd" => [:build, :test]
// 304:           depends_on "foo" => [:optional, "with-bar"]
// 305:                                           ^^^^^^^^^^ FormulaAudit/Miscellaneous: Dependency 'foo' should not use option `with-bar`
// 306:           depends_on "icu4c" => [:optional, "c++11"]
// 307:                                             ^^^^^^^ FormulaAudit/Miscellaneous: Dependency 'icu4c' should not use option `c++11`
// 308:         end
// 309:       RUBY
// 310:     end
// 311:
// 312:     it "reports an offense when `build.head?` could be used instead of checking `version`" do
// 313:       expect_offense(<<~RUBY)
// 314:         class Foo < Formula
// 315:           desc "foo"
// 316:           url 'https://brew.sh/foo-1.0.tgz'
// 317:           if version == "HEAD"
// 318:              ^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `build.head?` instead of inspecting `version`
// 319:             foo()
// 320:           end
// 321:         end
// 322:       RUBY
// 323:     end
// 324:
// 325:     it "reports an offense when `ARGV.include? (--HEAD)` is used" do
// 326:       expect_offense(<<~RUBY)
// 327:         class Foo < Formula
// 328:           desc "foo"
// 329:           url 'https://brew.sh/foo-1.0.tgz'
// 330:           test do
// 331:             head = ARGV.include? "--HEAD"
// 332:                    ^^^^ FormulaAudit/Miscellaneous: Use `build.with?` or `build.without?` instead of `ARGV` to check options
// 333:                    ^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `if build.head?` instead
// 334:           end
// 335:         end
// 336:       RUBY
// 337:     end
// 338:
// 339:     it "reports an offense when `needs :openmp` is used" do
// 340:       expect_offense(<<~RUBY)
// 341:         class Foo < Formula
// 342:           desc "foo"
// 343:           url 'https://brew.sh/foo-1.0.tgz'
// 344:           needs :openmp
// 345:           ^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: `needs :openmp` should be replaced with `depends_on "gcc"`
// 346:         end
// 347:       RUBY
// 348:     end
// 349:
// 350:     it "reports an offense when `MACOS_VERSION` is used" do
// 351:       expect_offense(<<~RUBY)
// 352:         class Foo < Formula
// 353:           desc "foo"
// 354:           url 'https://brew.sh/foo-1.0.tgz'
// 355:           test do
// 356:             version = MACOS_VERSION
// 357:                       ^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Use `MacOS.version` instead of `MACOS_VERSION`
// 358:           end
// 359:         end
// 360:       RUBY
// 361:     end
// 362:
// 363:     it "reports an offense when `build.with?` is used for a conditional dependency" do
// 364:       expect_offense(<<~RUBY)
// 365:         class Foo < Formula
// 366:           desc "foo"
// 367:           url 'https://brew.sh/foo-1.0.tgz'
// 368:           depends_on "foo" if build.with? "foo"
// 369:           ^^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Replace `depends_on "foo" if build.with? "foo"` with `depends_on "foo" => :optional`
// 370:         end
// 371:       RUBY
// 372:     end
// 373:
// 374:     it "reports an offense when `build.without?` is used for a negated conditional dependency" do
// 375:       expect_offense(<<~RUBY)
// 376:         class Foo < Formula
// 377:           desc "foo"
// 378:           url 'https://brew.sh/foo-1.0.tgz'
// 379:           depends_on :foo unless build.without? "foo"
// 380:           ^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Replace `depends_on :foo unless build.without? "foo"` with `depends_on :foo => :recommended`
// 381:         end
// 382:       RUBY
// 383:     end
// 384:
// 385:     it "reports an offense when `build.include?` is used for a negated conditional dependency" do
// 386:       expect_offense(<<~RUBY)
// 387:         class Foo < Formula
// 388:           desc "foo"
// 389:           url 'https://brew.sh/foo-1.0.tgz'
// 390:           depends_on :foo unless build.include? "without-foo"
// 391:           ^^^^^^^^^^^^^^^ FormulaAudit/Miscellaneous: Replace `depends_on :foo unless build.include? "without-foo"` with `depends_on :foo => :recommended`
// 392:         end
// 393:       RUBY
// 394:     end
// 395:   end
// 396: end
