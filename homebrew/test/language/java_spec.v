module language

import ruby
import homebrew.language as java_language

// Translated from Homebrew/brew `test/language/java_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const java_spec_opt_libexec = '/opt/homebrew/opt/openjdk/libexec'

pub fn java_spec_formula() java_language.OpenJdkFormula {
	return java_language.OpenJdkFormula{
		name: 'openjdk'
		installed: true
		installed_version: '15.0.1'
		opt_libexec: java_spec_opt_libexec
	}
}

pub fn java_spec_expected_home() string {
	return java_language.java_current_platform_home(java_spec_opt_libexec)
}

fn java_spec_version(args []ruby.Value) string {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ''
	}
	return args[0].as_string()
}

fn java_spec_formula_value(formula java_language.OpenJdkFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':              formula.name
		'installed':         formula.installed.str()
		'installed_version': formula.installed_version
		'opt_libexec':       formula.opt_libexec
	})
}

// Ruby let `let(:f) do` at line 7.
pub fn ruby_java_spec_l7_d1_f(args ...ruby.Value) ruby.Value {
	return java_spec_formula_value(java_spec_formula())
}

// Ruby let `let(:expected_home) do` at line 15.
pub fn ruby_java_spec_l15_d2_expected_home(args ...ruby.Value) ruby.Value {
	return ruby.string_value(java_spec_expected_home())
}

// Ruby it `it "returns valid JAVA_HOME if version is specified" do` at line 29.
pub fn ruby_java_spec_l29_d3_returns(args ...ruby.Value) ruby.Value {
	version := if args.len == 0 { '1.8+' } else { java_spec_version(args) }
	home := java_language.java_home_for_current_platform(version, [
		java_spec_formula(),
	]) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(home == java_spec_expected_home())
}

// Ruby it `it "returns valid JAVA_HOME if version is not specified" do` at line 34.
pub fn ruby_java_spec_l34_d4_returns(args ...ruby.Value) ruby.Value {
	home := java_language.java_home_for_current_platform('', [java_spec_formula()]) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(home == java_spec_expected_home())
}

// Ruby it `it "returns java_home path if version specified" do` at line 41.
pub fn ruby_java_spec_l41_d5_returns(args ...ruby.Value) ruby.Value {
	version := if args.len == 0 { '1.8+' } else { java_spec_version(args) }
	environment := java_language.java_home_env(version, [java_spec_formula()], java_language.java_current_platform_home)
	return ruby.bool_value(environment['JAVA_HOME'] == java_spec_expected_home())
}

// Ruby it `it "returns java_home path if version is not specified" do` at line 46.
pub fn ruby_java_spec_l46_d6_returns(args ...ruby.Value) ruby.Value {
	environment := java_language.java_home_env('', [java_spec_formula()], java_language.java_current_platform_home)
	return ruby.bool_value(environment['JAVA_HOME'] == java_spec_expected_home())
}

// Ruby it `it "returns java_home path if version specified" do` at line 53.
pub fn ruby_java_spec_l53_d7_returns(args ...ruby.Value) ruby.Value {
	version := if args.len == 0 { '1.8+' } else { java_spec_version(args) }
	environment := java_language.overridable_java_home_env(version, [
		java_spec_formula(),
	], java_language.java_current_platform_home)
	return ruby.bool_value(environment['JAVA_HOME'] == '\${JAVA_HOME:-${java_spec_expected_home()}}')
}

// Ruby it `it "returns java_home path if version is not specified" do` at line 58.
pub fn ruby_java_spec_l58_d8_returns(args ...ruby.Value) ruby.Value {
	environment := java_language.overridable_java_home_env('', [java_spec_formula()], java_language.java_current_platform_home)
	return ruby.bool_value(environment['JAVA_HOME'] == '\${JAVA_HOME:-${java_spec_expected_home()}}')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/java"
// 5:
// 6: RSpec.describe Language::Java do
// 7:   let(:f) do
// 8:     formula("openjdk") do
// 9:       T.bind(self, T.class_of(Formula))
// 10:       url "openjdk"
// 11:       version "15.0.1"
// 12:     end
// 13:   end
// 14:
// 15:   let(:expected_home) do
// 16:     if OS.mac?
// 17:       f.opt_libexec/"openjdk.jdk/Contents/Home"
// 18:     else
// 19:       f.opt_libexec
// 20:     end
// 21:   end
// 22:
// 23:   before do
// 24:     allow(Formula).to receive(:[]).and_return(f)
// 25:     allow(f).to receive_messages(any_version_installed?: true, any_installed_version: f.version)
// 26:   end
// 27:
// 28:   describe "::java_home" do
// 29:     it "returns valid JAVA_HOME if version is specified" do
// 30:       java_home = described_class.java_home("1.8+")
// 31:       expect(java_home).to eql(expected_home)
// 32:     end
// 33:
// 34:     it "returns valid JAVA_HOME if version is not specified" do
// 35:       java_home = described_class.java_home
// 36:       expect(java_home).to eql(expected_home)
// 37:     end
// 38:   end
// 39:
// 40:   describe "::java_home_env" do
// 41:     it "returns java_home path if version specified" do
// 42:       java_home_env = described_class.java_home_env("1.8+")
// 43:       expect(java_home_env[:JAVA_HOME]).to eql(expected_home.to_s)
// 44:     end
// 45:
// 46:     it "returns java_home path if version is not specified" do
// 47:       java_home_env = described_class.java_home_env
// 48:       expect(java_home_env[:JAVA_HOME]).to eql(expected_home.to_s)
// 49:     end
// 50:   end
// 51:
// 52:   describe "::overridable_java_home_env" do
// 53:     it "returns java_home path if version specified" do
// 54:       overridable_java_home_env = described_class.overridable_java_home_env("1.8+")
// 55:       expect(overridable_java_home_env[:JAVA_HOME]).to eql("${JAVA_HOME:-#{expected_home}}")
// 56:     end
// 57:
// 58:     it "returns java_home path if version is not specified" do
// 59:       overridable_java_home_env = described_class.overridable_java_home_env
// 60:       expect(overridable_java_home_env[:JAVA_HOME]).to eql("${JAVA_HOME:-#{expected_home}}")
// 61:     end
// 62:   end
// 63: end
