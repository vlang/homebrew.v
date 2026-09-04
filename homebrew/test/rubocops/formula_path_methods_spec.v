module rubocops

import ruby
import homebrew.rubocops as formula_path_core

// Translated from Homebrew/brew `test/rubocops/formula_path_methods_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn formula_path_spec_correction(source string, expected string) bool {
	problems := formula_path_core.audit_formula_path_methods(source)
	return problems.len == 1 && problems[0].message == 'Use `${problems[0].preferred}` instead of `${problems[0].current}`.' && formula_path_core.correct_formula_path_methods(source) == expected
}

// Ruby it `it "registers an offense and corrects `Formula[]` opt path calls" do` at line 7.
pub fn ruby_formula_path_methods_spec_l7_d1_registers(args ...ruby.Value) ruby.Value {
	source := 'Formula["foo"].opt_bin/"foo"'
	expected := 'Utils::Path.formula_opt_bin("foo")/"foo"'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects `Formula[]` opt path calls in formulae" do` at line 18.
pub fn ruby_formula_path_methods_spec_l18_d2_registers(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  def install\n    Formula["foo"].opt_bin/"foo"\n  end\nend'
	expected := 'class Foo < Formula\n  def install\n    formula_opt_bin("foo")/"foo"\n  end\nend'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby method `install` at line 21.
pub fn ruby_formula_path_methods_spec_l21_d3_install(args ...ruby.Value) ruby.Value {
	return ruby.string_value('Formula["foo"].opt_bin/"foo"')
}

// Ruby method `install` at line 30.
pub fn ruby_formula_path_methods_spec_l30_d4_install(args ...ruby.Value) ruby.Value {
	return ruby.string_value('formula_opt_bin("foo")/"foo"')
}

// Ruby it `it "registers an offense and corrects `Formula[]` opt path calls in casks" do` at line 37.
pub fn ruby_formula_path_methods_spec_l37_d5_registers(args ...ruby.Value) ruby.Value {
	source := 'cask "foo" do\n  postflight do\n    Formula["foo"].opt_bin/"foo"\n  end\nend'
	expected := 'cask "foo" do\n  postflight do\n    formula_opt_bin("foo")/"foo"\n  end\nend'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects scoped formula helpers in service blocks" do` at line 56.
pub fn ruby_formula_path_methods_spec_l56_d6_registers(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  service do\n    Utils::Path.formula_opt_bin("foo")/"foo"\n  end\nend'
	expected := 'class Foo < Formula\n  service do\n    formula_opt_bin("foo")/"foo"\n  end\nend'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects `Formulary.factory` opt path calls" do` at line 75.
pub fn ruby_formula_path_methods_spec_l75_d7_registers(args ...ruby.Value) ruby.Value {
	source := 'Formulary.factory("foo").opt_prefix/"bin/foo"'
	expected := 'Utils::Path.formula_opt_prefix("foo")/"bin/foo"'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects dynamic formula names" do` at line 86.
pub fn ruby_formula_path_methods_spec_l86_d8_registers(args ...ruby.Value) ruby.Value {
	source := 'Formula[python_dep].opt_libexec/"bin/python"'
	expected := 'Utils::Path.formula_opt_libexec(python_dep)/"bin/python"'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects formula installed checks" do` at line 97.
pub fn ruby_formula_path_methods_spec_l97_d9_registers(args ...ruby.Value) ruby.Value {
	source := 'Formula["foo"].any_version_installed?'
	expected := 'Utils::Path.formula_any_version_installed?("foo")'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects formula installed checks in formulae" do` at line 108.
pub fn ruby_formula_path_methods_spec_l108_d10_registers(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  def install\n    Formula["foo"].any_version_installed?\n  end\nend'
	expected := 'class Foo < Formula\n  def install\n    formula_any_version_installed?("foo")\n  end\nend'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby method `install` at line 111.
pub fn ruby_formula_path_methods_spec_l111_d11_install(args ...ruby.Value) ruby.Value {
	return ruby.string_value('Formula["foo"].any_version_installed?')
}

// Ruby method `install` at line 120.
pub fn ruby_formula_path_methods_spec_l120_d12_install(args ...ruby.Value) ruby.Value {
	return ruby.string_value('formula_any_version_installed?("foo")')
}

// Ruby it `it "registers an offense and corrects cask installed checks" do` at line 127.
pub fn ruby_formula_path_methods_spec_l127_d13_registers(args ...ruby.Value) ruby.Value {
	source := 'Cask::Cask.new(cask_token).installed?'
	expected := 'Cask::Caskroom.cask_installed?(cask_token)'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects cask any-version installed checks" do` at line 138.
pub fn ruby_formula_path_methods_spec_l138_d14_registers(args ...ruby.Value) ruby.Value {
	source := 'Cask::Cask.new(cask_token).any_version_installed?'
	expected := 'Cask::Caskroom.cask_installed?(cask_token)'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "registers an offense and corrects cask installed version checks" do` at line 149.
pub fn ruby_formula_path_methods_spec_l149_d15_registers(args ...ruby.Value) ruby.Value {
	source := 'Cask::Cask.new(name, config: config).installed_version'
	expected := 'Cask::Caskroom.cask_installed_version(name)'
	return ruby.bool_value(formula_path_spec_correction(source, expected))
}

// Ruby it `it "does not register an offense for formula methods that require a formula instance" do` at line 160.
pub fn ruby_formula_path_methods_spec_l160_d16_does(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_path_core.audit_formula_path_methods('Formula["foo"].keg_only?').len == 0)
}

// Ruby it `it "does not register an offense for dynamic formula installed checks that may need alias metadata" do` at line 166.
pub fn ruby_formula_path_methods_spec_l166_d17_does(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_path_core.audit_formula_path_methods('Formula[dependency].any_version_installed?').len == 0)
}

// Ruby it `it "does not register an offense for cask loader methods that may need DSL metadata" do` at line 172.
pub fn ruby_formula_path_methods_spec_l172_d18_does(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_path_core.audit_formula_path_methods('Cask::CaskLoader.load(cask_token).installed?').len == 0)
}

// Ruby it `it "does not register an offense when `Formula[]` is used for error handling" do` at line 178.
pub fn ruby_formula_path_methods_spec_l178_d19_does(args ...ruby.Value) ruby.Value {
	source := 'begin\n  Formula[dependency].any_version_installed?\nrescue FormulaUnavailableError\n  false\nend'
	return ruby.bool_value(formula_path_core.audit_formula_path_methods(source).len == 0)
}

// Ruby it `it "does not register an offense for scoped formula helpers outside service blocks" do` at line 188.
pub fn ruby_formula_path_methods_spec_l188_d20_does(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  on_linux do\n    Utils::Path.formula_any_version_installed?("glibc")\n  end\nend'
	return ruby.bool_value(formula_path_core.audit_formula_path_methods(source).len == 0)
}

// Ruby it `it "does not register an offense for formula path calls used for error handling" do` at line 198.
pub fn ruby_formula_path_methods_spec_l198_d21_does(args ...ruby.Value) ruby.Value {
	source := 'begin\n  Formula["foo"].opt_bin/"foo"\nrescue FormulaUnavailableError\n  nil\nend'
	return ruby.bool_value(formula_path_core.audit_formula_path_methods(source).len == 0)
}

// Ruby it `it "does not register an offense for `Formulary.factory` with additional arguments" do` at line 208.
pub fn ruby_formula_path_methods_spec_l208_d22_does(args ...ruby.Value) ruby.Value {
	source := 'Formulary.factory("foo", spec: :stable).opt_prefix'
	return ruby.bool_value(formula_path_core.audit_formula_path_methods(source).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/formula_path_methods"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::FormulaPathMethods, :config do
// 7:   it "registers an offense and corrects `Formula[]` opt path calls" do
// 8:     expect_offense(<<~RUBY)
// 9:       Formula["foo"].opt_bin/"foo"
// 10:       ^^^^^^^^^^^^^^^^^^^^^^ Use `Utils::Path.formula_opt_bin("foo")` instead of `Formula["foo"].opt_bin`.
// 11:     RUBY
// 12:
// 13:     expect_correction(<<~RUBY)
// 14:       Utils::Path.formula_opt_bin("foo")/"foo"
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "registers an offense and corrects `Formula[]` opt path calls in formulae" do
// 19:     expect_offense(<<~RUBY)
// 20:       class Foo < Formula
// 21:         def install
// 22:           Formula["foo"].opt_bin/"foo"
// 23:           ^^^^^^^^^^^^^^^^^^^^^^ Use `formula_opt_bin("foo")` instead of `Formula["foo"].opt_bin`.
// 24:         end
// 25:       end
// 26:     RUBY
// 27:
// 28:     expect_correction(<<~RUBY)
// 29:       class Foo < Formula
// 30:         def install
// 31:           formula_opt_bin("foo")/"foo"
// 32:         end
// 33:       end
// 34:     RUBY
// 35:   end
// 36:
// 37:   it "registers an offense and corrects `Formula[]` opt path calls in casks" do
// 38:     expect_offense(<<~RUBY)
// 39:       cask "foo" do
// 40:         postflight do
// 41:           Formula["foo"].opt_bin/"foo"
// 42:           ^^^^^^^^^^^^^^^^^^^^^^ Use `formula_opt_bin("foo")` instead of `Formula["foo"].opt_bin`.
// 43:         end
// 44:       end
// 45:     RUBY
// 46:
// 47:     expect_correction(<<~RUBY)
// 48:       cask "foo" do
// 49:         postflight do
// 50:           formula_opt_bin("foo")/"foo"
// 51:         end
// 52:       end
// 53:     RUBY
// 54:   end
// 55:
// 56:   it "registers an offense and corrects scoped formula helpers in service blocks" do
// 57:     expect_offense(<<~RUBY)
// 58:       class Foo < Formula
// 59:         service do
// 60:           Utils::Path.formula_opt_bin("foo")/"foo"
// 61:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `formula_opt_bin("foo")` instead of `Utils::Path.formula_opt_bin("foo")`.
// 62:         end
// 63:       end
// 64:     RUBY
// 65:
// 66:     expect_correction(<<~RUBY)
// 67:       class Foo < Formula
// 68:         service do
// 69:           formula_opt_bin("foo")/"foo"
// 70:         end
// 71:       end
// 72:     RUBY
// 73:   end
// 74:
// 75:   it "registers an offense and corrects `Formulary.factory` opt path calls" do
// 76:     expect_offense(<<~RUBY)
// 77:       Formulary.factory("foo").opt_prefix/"bin/foo"
// 78:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils::Path.formula_opt_prefix("foo")` instead of `Formulary.factory("foo").opt_prefix`.
// 79:     RUBY
// 80:
// 81:     expect_correction(<<~RUBY)
// 82:       Utils::Path.formula_opt_prefix("foo")/"bin/foo"
// 83:     RUBY
// 84:   end
// 85:
// 86:   it "registers an offense and corrects dynamic formula names" do
// 87:     expect_offense(<<~RUBY)
// 88:       Formula[python_dep].opt_libexec/"bin/python"
// 89:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils::Path.formula_opt_libexec(python_dep)` instead of `Formula[python_dep].opt_libexec`.
// 90:     RUBY
// 91:
// 92:     expect_correction(<<~RUBY)
// 93:       Utils::Path.formula_opt_libexec(python_dep)/"bin/python"
// 94:     RUBY
// 95:   end
// 96:
// 97:   it "registers an offense and corrects formula installed checks" do
// 98:     expect_offense(<<~RUBY)
// 99:       Formula["foo"].any_version_installed?
// 100:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Utils::Path.formula_any_version_installed?("foo")` instead of `Formula["foo"].any_version_installed?`.
// 101:     RUBY
// 102:
// 103:     expect_correction(<<~RUBY)
// 104:       Utils::Path.formula_any_version_installed?("foo")
// 105:     RUBY
// 106:   end
// 107:
// 108:   it "registers an offense and corrects formula installed checks in formulae" do
// 109:     expect_offense(<<~RUBY)
// 110:       class Foo < Formula
// 111:         def install
// 112:           Formula["foo"].any_version_installed?
// 113:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `formula_any_version_installed?("foo")` instead of `Formula["foo"].any_version_installed?`.
// 114:         end
// 115:       end
// 116:     RUBY
// 117:
// 118:     expect_correction(<<~RUBY)
// 119:       class Foo < Formula
// 120:         def install
// 121:           formula_any_version_installed?("foo")
// 122:         end
// 123:       end
// 124:     RUBY
// 125:   end
// 126:
// 127:   it "registers an offense and corrects cask installed checks" do
// 128:     expect_offense(<<~RUBY)
// 129:       Cask::Cask.new(cask_token).installed?
// 130:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Cask::Caskroom.cask_installed?(cask_token)` instead of `Cask::Cask.new(cask_token).installed?`.
// 131:     RUBY
// 132:
// 133:     expect_correction(<<~RUBY)
// 134:       Cask::Caskroom.cask_installed?(cask_token)
// 135:     RUBY
// 136:   end
// 137:
// 138:   it "registers an offense and corrects cask any-version installed checks" do
// 139:     expect_offense(<<~RUBY)
// 140:       Cask::Cask.new(cask_token).any_version_installed?
// 141:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Cask::Caskroom.cask_installed?(cask_token)` instead of `Cask::Cask.new(cask_token).any_version_installed?`.
// 142:     RUBY
// 143:
// 144:     expect_correction(<<~RUBY)
// 145:       Cask::Caskroom.cask_installed?(cask_token)
// 146:     RUBY
// 147:   end
// 148:
// 149:   it "registers an offense and corrects cask installed version checks" do
// 150:     expect_offense(<<~RUBY)
// 151:       Cask::Cask.new(name, config: config).installed_version
// 152:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Cask::Caskroom.cask_installed_version(name)` instead of `Cask::Cask.new(name, config: config).installed_version`.
// 153:     RUBY
// 154:
// 155:     expect_correction(<<~RUBY)
// 156:       Cask::Caskroom.cask_installed_version(name)
// 157:     RUBY
// 158:   end
// 159:
// 160:   it "does not register an offense for formula methods that require a formula instance" do
// 161:     expect_no_offenses(<<~RUBY)
// 162:       Formula["foo"].keg_only?
// 163:     RUBY
// 164:   end
// 165:
// 166:   it "does not register an offense for dynamic formula installed checks that may need alias metadata" do
// 167:     expect_no_offenses(<<~RUBY)
// 168:       Formula[dependency].any_version_installed?
// 169:     RUBY
// 170:   end
// 171:
// 172:   it "does not register an offense for cask loader methods that may need DSL metadata" do
// 173:     expect_no_offenses(<<~RUBY)
// 174:       Cask::CaskLoader.load(cask_token).installed?
// 175:     RUBY
// 176:   end
// 177:
// 178:   it "does not register an offense when `Formula[]` is used for error handling" do
// 179:     expect_no_offenses(<<~RUBY)
// 180:       begin
// 181:         Formula[dependency].any_version_installed?
// 182:       rescue FormulaUnavailableError
// 183:         false
// 184:       end
// 185:     RUBY
// 186:   end
// 187:
// 188:   it "does not register an offense for scoped formula helpers outside service blocks" do
// 189:     expect_no_offenses(<<~RUBY)
// 190:       class Foo < Formula
// 191:         on_linux do
// 192:           Utils::Path.formula_any_version_installed?("glibc")
// 193:         end
// 194:       end
// 195:     RUBY
// 196:   end
// 197:
// 198:   it "does not register an offense for formula path calls used for error handling" do
// 199:     expect_no_offenses(<<~RUBY)
// 200:       begin
// 201:         Formula["foo"].opt_bin/"foo"
// 202:       rescue FormulaUnavailableError
// 203:         nil
// 204:       end
// 205:     RUBY
// 206:   end
// 207:
// 208:   it "does not register an offense for `Formulary.factory` with additional arguments" do
// 209:     expect_no_offenses(<<~RUBY)
// 210:       Formulary.factory("foo", spec: :stable).opt_prefix
// 211:     RUBY
// 212:   end
// 213: end
