module test

import brew_runtime
import homebrew
import homebrew.compilers as compiler_model

// Translated from Homebrew/brew `test/compiler_selector_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn compiler_selector_spec_version(value string) homebrew.Version {
	return homebrew.new_version(value) or { panic(err) }
}

fn compiler_selector_spec_versions_model() compiler_model.StaticCompilerVersions {
	return compiler_model.StaticCompilerVersions{
		gcc_versions: {
			'gcc-12': compiler_selector_spec_version('12.1')
			'gcc-11': compiler_selector_spec_version('11.1')
			'gcc-10': compiler_selector_spec_version('10.1')
			'gcc-9':  compiler_selector_spec_version('9.1')
		}
		build_versions: {
			'clang': compiler_selector_spec_version('600')
		}
	}
}

fn compiler_selector_spec_versions_value() brew_runtime.Value {
	return brew_runtime.map_value({
		'gcc-12':              brew_runtime.object_value('Version', '12.1')
		'gcc-11':              brew_runtime.object_value('Version', '11.1')
		'gcc-10':              brew_runtime.object_value('Version', '10.1')
		'gcc-9':               brew_runtime.object_value('Version', '9.1')
		'clang_build_version': brew_runtime.object_value('Version', '600')
	})
}

fn compiler_selector_spec_formula() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'SoftwareSpec'
		repr: '#<SoftwareSpec>'
		map_data: {
			'compiler_failures': brew_runtime.array_value([])
		}
	}
}

fn compiler_selector_spec_symbol_failure(compiler_type string) &compiler_model.CompilerFailure {
	return compiler_model.create_symbol_failure(compiler_type) or { panic(err) }
}

fn compiler_selector_spec_gcc_failure(major string, version_override string) &compiler_model.CompilerFailure {
	mut failure := compiler_model.create_gcc_failure(major) or { panic(err) }
	if version_override != '' {
		failure.set_version(version_override) or { panic(err) }
	}
	return failure
}

fn compiler_selector_spec_selector(failures []&compiler_model.CompilerFailure, preferred string,
	preferred_exists bool) &compiler_model.CompilerSelector {
	return compiler_model.new_compiler_selector(compiler_selector_spec_formula(), failures, compiler_selector_spec_versions_model(), [
		'clang',
		'gnu',
	], preferred, preferred_exists)
}

fn compiler_selector_spec_select(failures []&compiler_model.CompilerFailure, preferred string,
	preferred_exists bool) ?string {
	selector := compiler_selector_spec_selector(failures, preferred, preferred_exists)
	return selector.compiler() or { return none }
}

fn compiler_selector_spec_result(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Ruby subject `subject(:selector) { described_class.new(software_spec, versions, compilers) }` at line 8.
pub fn ruby_compiler_selector_spec_l8_d1_selector(args ...brew_runtime.Value) brew_runtime.Value {
	return compiler_model.ruby_compiler_selector_l57_initialize(compiler_selector_spec_formula(), compiler_selector_spec_versions_value(), brew_runtime.string_array_value([
		'clang',
		'gnu',
	]))
}

// Ruby let `let(:compilers) { [:clang, :gnu] }` at line 10.
pub fn ruby_compiler_selector_spec_l10_d2_compilers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(['clang', 'gnu'])
}

// Ruby let `let(:software_spec) { SoftwareSpec.new }` at line 11.
pub fn ruby_compiler_selector_spec_l11_d3_software_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return compiler_selector_spec_formula()
}

// Ruby let `let(:cc) { :clang }` at line 12.
pub fn ruby_compiler_selector_spec_l12_d4_cc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'clang')
}

// Ruby let `let(:versions) { class_double(DevelopmentTools, clang_build_version: Version.new("600")) }` at line 13.
pub fn ruby_compiler_selector_spec_l13_d5_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return compiler_selector_spec_versions_value()
}

// Ruby it `it "defaults to cc" do` at line 28.
pub fn ruby_compiler_selector_spec_l28_d6_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([], '', false) or {
		return compiler_selector_spec_result(false)
	}
	return compiler_selector_spec_result(selected == 'clang')
}

// Ruby it `it "returns clang if it fails with non-Apple gcc" do` at line 32.
pub fn ruby_compiler_selector_spec_l32_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_gcc_failure('12', ''),
	], '', false) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'clang')
}

// Ruby it `it "still returns gcc-12 if it fails with gcc without a specific version" do` at line 37.
pub fn ruby_compiler_selector_spec_l37_d8_still(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
	], '', false) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-12')
}

// Ruby it `it "returns gcc-11 if gcc formula offers gcc-11 on mac", :needs_macos do` at line 42.
pub fn ruby_compiler_selector_spec_l42_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
	], '11.0', true) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-11')
}

// Ruby it `it "returns gcc-10 if gcc formula offers gcc-10 on linux", :needs_linux do` at line 50.
pub fn ruby_compiler_selector_spec_l50_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
	], '10.0', true) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-10')
}

// Ruby it `it "returns gcc-11 if gcc formula offers gcc-10 and fails with gcc-10 and gcc-12 on linux", :needs_linux do` at line 58.
pub fn ruby_compiler_selector_spec_l58_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
		compiler_selector_spec_gcc_failure('10', ''),
		compiler_selector_spec_gcc_failure('12', ''),
	], '10.0', true) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-11')
}

// Ruby it `it "returns gcc-12 if gcc formula offers gcc-11 and fails with gcc <= 11 on linux", :needs_linux do` at line 68.
pub fn ruby_compiler_selector_spec_l68_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut gcc_failure := compiler_selector_spec_symbol_failure('gcc')
	gcc_failure.set_version('11') or { return compiler_selector_spec_result(false) }
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
		gcc_failure,
	], '11.0', true) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-12')
}

// Ruby it `it "returns gcc-12 if gcc-12 is version 12.1 but spec fails with gcc-12 <= 12.0" do` at line 77.
pub fn ruby_compiler_selector_spec_l77_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
		compiler_selector_spec_gcc_failure('12', '12.0'),
	], '', false) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-12')
}

// Ruby it `it "returns gcc-11 if gcc-12 is version 12.1 but spec fails with gcc-12 <= 12.1" do` at line 83.
pub fn ruby_compiler_selector_spec_l83_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	selected := compiler_selector_spec_select([
		compiler_selector_spec_symbol_failure('clang'),
		compiler_selector_spec_gcc_failure('12', '12.1'),
	], '', false) or { return compiler_selector_spec_result(false) }
	return compiler_selector_spec_result(selected == 'gcc-11')
}

// Ruby it `it "raises an error when gcc or llvm is missing (hash syntax)" do` at line 89.
pub fn ruby_compiler_selector_spec_l89_d15_raises(args ...brew_runtime.Value) brew_runtime.Value {
	selector := compiler_selector_spec_selector([
		compiler_selector_spec_symbol_failure('clang'),
		compiler_selector_spec_gcc_failure('12', ''),
		compiler_selector_spec_gcc_failure('11', ''),
		compiler_selector_spec_gcc_failure('10', ''),
		compiler_selector_spec_gcc_failure('9', ''),
	], '', false)
	_ := selector.compiler() or { return compiler_selector_spec_result(true) }
	return compiler_selector_spec_result(false)
}

// Ruby it `it "raises an error when gcc or llvm is missing (symbol syntax)" do` at line 99.
pub fn ruby_compiler_selector_spec_l99_d16_raises(args ...brew_runtime.Value) brew_runtime.Value {
	selector := compiler_selector_spec_selector([
		compiler_selector_spec_symbol_failure('clang'),
		compiler_selector_spec_symbol_failure('gcc'),
	], '', false)
	_ := selector.compiler() or { return compiler_selector_spec_result(true) }
	return compiler_selector_spec_result(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5: require "software_spec"
// 6:
// 7: RSpec.describe CompilerSelector do
// 8:   subject(:selector) { described_class.new(software_spec, versions, compilers) }
// 9:
// 10:   let(:compilers) { [:clang, :gnu] }
// 11:   let(:software_spec) { SoftwareSpec.new }
// 12:   let(:cc) { :clang }
// 13:   let(:versions) { class_double(DevelopmentTools, clang_build_version: Version.new("600")) }
// 14:
// 15:   before do
// 16:     allow(versions).to receive(:gcc_version) do |name|
// 17:       case name
// 18:       when "gcc-12" then Version.new("12.1")
// 19:       when "gcc-11" then Version.new("11.1")
// 20:       when "gcc-10" then Version.new("10.1")
// 21:       when "gcc-9" then Version.new("9.1")
// 22:       else Version::NULL
// 23:       end
// 24:     end
// 25:   end
// 26:
// 27:   describe "#compiler", :no_api do
// 28:     it "defaults to cc" do
// 29:       expect(selector.compiler).to eq(cc)
// 30:     end
// 31:
// 32:     it "returns clang if it fails with non-Apple gcc" do
// 33:       software_spec.fails_with(gcc: "12")
// 34:       expect(selector.compiler).to eq(:clang)
// 35:     end
// 36:
// 37:     it "still returns gcc-12 if it fails with gcc without a specific version" do
// 38:       software_spec.fails_with(:clang)
// 39:       expect(selector.compiler).to eq("gcc-12")
// 40:     end
// 41:
// 42:     it "returns gcc-11 if gcc formula offers gcc-11 on mac", :needs_macos do
// 43:       software_spec.fails_with(:clang)
// 44:       allow(Formulary).to receive(:factory)
// 45:         .with("gcc")
// 46:         .and_return(instance_double(Formula, version: Version.new("11.0")))
// 47:       expect(selector.compiler).to eq("gcc-11")
// 48:     end
// 49:
// 50:     it "returns gcc-10 if gcc formula offers gcc-10 on linux", :needs_linux do
// 51:       software_spec.fails_with(:clang)
// 52:       allow(Formulary).to receive(:factory)
// 53:         .with(OS::LINUX_PREFERRED_GCC_COMPILER_FORMULA)
// 54:         .and_return(instance_double(Formula, version: Version.new("10.0")))
// 55:       expect(selector.compiler).to eq("gcc-10")
// 56:     end
// 57:
// 58:     it "returns gcc-11 if gcc formula offers gcc-10 and fails with gcc-10 and gcc-12 on linux", :needs_linux do
// 59:       software_spec.fails_with(:clang)
// 60:       software_spec.fails_with(gcc: "10")
// 61:       software_spec.fails_with(gcc: "12")
// 62:       allow(Formulary).to receive(:factory)
// 63:         .with(OS::LINUX_PREFERRED_GCC_COMPILER_FORMULA)
// 64:         .and_return(instance_double(Formula, version: Version.new("10.0")))
// 65:       expect(selector.compiler).to eq("gcc-11")
// 66:     end
// 67:
// 68:     it "returns gcc-12 if gcc formula offers gcc-11 and fails with gcc <= 11 on linux", :needs_linux do
// 69:       software_spec.fails_with(:clang)
// 70:       software_spec.fails_with(:gcc) { version "11" }
// 71:       allow(Formulary).to receive(:factory)
// 72:         .with(OS::LINUX_PREFERRED_GCC_COMPILER_FORMULA)
// 73:         .and_return(instance_double(Formula, version: Version.new("11.0")))
// 74:       expect(selector.compiler).to eq("gcc-12")
// 75:     end
// 76:
// 77:     it "returns gcc-12 if gcc-12 is version 12.1 but spec fails with gcc-12 <= 12.0" do
// 78:       software_spec.fails_with(:clang)
// 79:       software_spec.fails_with(gcc: "12") { version "12.0" }
// 80:       expect(selector.compiler).to eq("gcc-12")
// 81:     end
// 82:
// 83:     it "returns gcc-11 if gcc-12 is version 12.1 but spec fails with gcc-12 <= 12.1" do
// 84:       software_spec.fails_with(:clang)
// 85:       software_spec.fails_with(gcc: "12") { version "12.1" }
// 86:       expect(selector.compiler).to eq("gcc-11")
// 87:     end
// 88:
// 89:     it "raises an error when gcc or llvm is missing (hash syntax)" do
// 90:       software_spec.fails_with(:clang)
// 91:       software_spec.fails_with(gcc: "12")
// 92:       software_spec.fails_with(gcc: "11")
// 93:       software_spec.fails_with(gcc: "10")
// 94:       software_spec.fails_with(gcc: "9")
// 95:
// 96:       expect { selector.compiler }.to raise_error(CompilerSelectionError)
// 97:     end
// 98:
// 99:     it "raises an error when gcc or llvm is missing (symbol syntax)" do
// 100:       software_spec.fails_with(:clang)
// 101:       software_spec.fails_with(:gcc)
// 102:
// 103:       expect { selector.compiler }.to raise_error(CompilerSelectionError)
// 104:     end
// 105:   end
// 106: end
