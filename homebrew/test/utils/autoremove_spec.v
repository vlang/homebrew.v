module utils

import ruby
import homebrew.utils as autoremove_core

// Translated from Homebrew/brew `test/utils/autoremove_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn autoremove_spec_tab(poured_from_bottle bool, installed_present bool,
	installed_on_request bool, runtime_present bool, runtime_dependencies []string) autoremove_core.AutoremoveTab {
	return autoremove_core.AutoremoveTab{
		poured_from_bottle: poured_from_bottle
		installed_on_request_present: installed_present
		installed_on_request: installed_on_request
		runtime_dependencies_present: runtime_present
		runtime_dependencies: runtime_dependencies
	}
}

fn autoremove_spec_formula(name string, runtime []string, build []string,
	tab autoremove_core.AutoremoveTab) autoremove_core.AutoremoveFormula {
	return autoremove_core.AutoremoveFormula{
		name: name
		possible_names: [name]
		installed_runtime_dependencies: runtime
		build_dependencies: build
		tab_present: true
		tab: tab
	}
}

fn autoremove_spec_formulae(poured_from_bottle bool, installed_present bool,
	installed_on_request bool, runtime_present bool) []autoremove_core.AutoremoveFormula {
	shared_tab := autoremove_spec_tab(poured_from_bottle, installed_present, installed_on_request, runtime_present, [
		'one',
		'two',
	])
	empty_tab := autoremove_spec_tab(poured_from_bottle, installed_present, installed_on_request, runtime_present, []string{})
	return [
		autoremove_spec_formula('zero', ['one', 'two'], ['three'], shared_tab),
		autoremove_spec_formula('one', ['two'], []string{}, if runtime_present {
			shared_tab
		} else {
			empty_tab
		}),
		autoremove_spec_formula('two', []string{}, []string{}, empty_tab),
		autoremove_spec_formula('three', []string{}, []string{}, empty_tab),
	]
}

fn autoremove_spec_formulae_value(formulae []autoremove_core.AutoremoveFormula) ruby.Value {
	return ruby.array_value(formulae.map(autoremove_core.autoremove_formula_value(it)))
}

fn autoremove_spec_cask(name string, dependencies []string) autoremove_core.AutoremoveCask {
	return autoremove_core.AutoremoveCask{
		name: name
		formula_dependencies: dependencies
	}
}

fn autoremove_spec_casks_value(casks []autoremove_core.AutoremoveCask) ruby.Value {
	return ruby.array_value(casks.map(autoremove_core.autoremove_cask_value(it)))
}

fn autoremove_spec_names(formulae []autoremove_core.AutoremoveFormula) []string {
	return formulae.map(it.name)
}

fn autoremove_spec_same_names(mut actual []string, mut expected []string) bool {
	actual.sort()
	expected.sort()
	return actual == expected
}

// Ruby let `let(:formula_with_deps) do` at line 8.
pub fn ruby_autoremove_spec_l8_d1_formula_with_deps(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_formula_value(autoremove_spec_formulae(true, true, false, false)[0])
}

// Ruby let `let(:first_formula_dep) do` at line 17.
pub fn ruby_autoremove_spec_l17_d2_first_formula_dep(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_formula_value(autoremove_spec_formulae(true, true, false, false)[1])
}

// Ruby let `let(:second_formula_dep) do` at line 24.
pub fn ruby_autoremove_spec_l24_d3_second_formula_dep(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_formula_value(autoremove_spec_formulae(true, true, false, false)[2])
}

// Ruby let `let(:formula_is_build_dep) do` at line 31.
pub fn ruby_autoremove_spec_l31_d4_formula_is_build_dep(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_formula_value(autoremove_spec_formulae(true, true, false, false)[3])
}

// Ruby let `let(:formulae) do` at line 38.
pub fn ruby_autoremove_spec_l38_d5_formulae(args ...ruby.Value) ruby.Value {
	return autoremove_spec_formulae_value(autoremove_spec_formulae(true, true, false, false))
}

// Ruby let `let(:tab_from_keg) { instance_double(Tab) }` at line 47.
pub fn ruby_autoremove_spec_l47_d6_tab_from_keg(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Tab', 'tab', {
		'poured_from_bottle': 'true'
	})
}

// Ruby it `it "filters out runtime dependencies" do` at line 79.
pub fn ruby_autoremove_spec_l79_d7_filters() bool {
	formulae := autoremove_spec_formulae(true, true, false, false)
	return autoremove_spec_names(autoremove_core.bottled_formulae_with_no_formula_dependents(formulae)) == [
		'zero',
		'three',
	]
}

// Ruby it `it "filters out formulae" do` at line 88.
pub fn ruby_autoremove_spec_l88_d8_filters() bool {
	return autoremove_core.bottled_formulae_with_no_formula_dependents(autoremove_spec_formulae(false, true, false, false)).len == 0
}

// Ruby it `it "uses tab dep names without calling installed_runtime_formula_dependencies" do` at line 97.
pub fn ruby_autoremove_spec_l97_d9_uses() bool {
	formulae := autoremove_spec_formulae(true, true, false, true)
	return autoremove_spec_names(autoremove_core.bottled_formulae_with_no_formula_dependents(formulae)) == [
		'zero',
		'three',
	]
}

// Ruby specify `specify "installed on request" do` at line 118.
pub fn ruby_autoremove_spec_l118_d10_installed() bool {
	return autoremove_core.unused_formulae_with_no_formula_dependents(autoremove_spec_formulae(true, true, true, false)).len == 0
}

// Ruby specify `specify "not installed on request" do` at line 125.
pub fn ruby_autoremove_spec_l125_d11_not() bool {
	actual := autoremove_spec_names(autoremove_core.unused_formulae_with_no_formula_dependents(autoremove_spec_formulae(true, true, false, false)))
	mut expected := ['zero', 'one', 'two', 'three']
	mut sorted_actual := actual.clone()
	return autoremove_spec_same_names(mut sorted_actual, mut expected)
}

// Ruby specify `specify "installed on request is null" do` at line 132.
pub fn ruby_autoremove_spec_l132_d12_installed() bool {
	return autoremove_core.unused_formulae_with_no_formula_dependents(autoremove_spec_formulae(true, false, false, false)).len == 0
}

// Ruby let `let(:cask_one_dep) do` at line 145.
pub fn ruby_autoremove_spec_l145_d13_cask_one_dep(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_cask_value(autoremove_spec_cask('red', ['two']))
}

// Ruby let `let(:cask_multiple_deps) do` at line 153.
pub fn ruby_autoremove_spec_l153_d14_cask_multiple_deps(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_cask_value(autoremove_spec_cask('blue', ['zero']))
}

// Ruby let `let(:first_cask_no_deps) do` at line 161.
pub fn ruby_autoremove_spec_l161_d15_first_cask_no_deps(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_cask_value(autoremove_spec_cask('green', []string{}))
}

// Ruby let `let(:second_cask_no_deps) do` at line 168.
pub fn ruby_autoremove_spec_l168_d16_second_cask_no_deps(args ...ruby.Value) ruby.Value {
	return autoremove_core.autoremove_cask_value(autoremove_spec_cask('purple', []string{}))
}

// Ruby let `let(:casks_no_deps) { [first_cask_no_deps, second_cask_no_deps] }` at line 175.
pub fn ruby_autoremove_spec_l175_d17_casks_no_deps(args ...ruby.Value) ruby.Value {
	return autoremove_spec_casks_value([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
	])
}

// Ruby let `let(:casks_one_dep) { [first_cask_no_deps, second_cask_no_deps, cask_one_dep] }` at line 176.
pub fn ruby_autoremove_spec_l176_d18_casks_one_dep(args ...ruby.Value) ruby.Value {
	return autoremove_spec_casks_value([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
		autoremove_spec_cask('red', ['two']),
	])
}

// Ruby let `let(:casks_multiple_deps) { [first_cask_no_deps, second_cask_no_deps, cask_multiple_deps] }` at line 177.
pub fn ruby_autoremove_spec_l177_d19_casks_multiple_deps(args ...ruby.Value) ruby.Value {
	return autoremove_spec_casks_value([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
		autoremove_spec_cask('blue', ['zero']),
	])
}

// Ruby specify `specify "no dependents" do` at line 183.
pub fn ruby_autoremove_spec_l183_d20_no() bool {
	return autoremove_core.cask_dependent_formula_names([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
	], autoremove_spec_formulae(true, true, false, false)).len == 0
}

// Ruby specify `specify "one dependent" do` at line 188.
pub fn ruby_autoremove_spec_l188_d21_one() bool {
	return autoremove_core.cask_dependent_formula_names([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
		autoremove_spec_cask('red', ['two']),
	], autoremove_spec_formulae(true, true, false, false)) == ['two']
}

// Ruby specify `specify "multiple dependents" do` at line 193.
pub fn ruby_autoremove_spec_l193_d22_multiple() bool {
	return autoremove_core.cask_dependent_formula_names([
		autoremove_spec_cask('green', []string{}),
		autoremove_spec_cask('purple', []string{}),
		autoremove_spec_cask('blue', ['zero']),
	], autoremove_spec_formulae(true, true, false, false)) == ['one', 'two', 'zero']
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/autoremove"
// 5:
// 6: RSpec.describe Utils::Autoremove do
// 7:   shared_context "with formulae for dependency testing" do
// 8:     let(:formula_with_deps) do
// 9:       formula "zero" do
// 10:         T.bind(self, T.class_of(Formula))
// 11:         url "zero-1.0"
// 12:
// 13:         depends_on "three" => :build
// 14:       end
// 15:     end
// 16:
// 17:     let(:first_formula_dep) do
// 18:       formula "one" do
// 19:         T.bind(self, T.class_of(Formula))
// 20:         url "one-1.1"
// 21:       end
// 22:     end
// 23:
// 24:     let(:second_formula_dep) do
// 25:       formula "two" do
// 26:         T.bind(self, T.class_of(Formula))
// 27:         url "two-1.1"
// 28:       end
// 29:     end
// 30:
// 31:     let(:formula_is_build_dep) do
// 32:       formula "three" do
// 33:         T.bind(self, T.class_of(Formula))
// 34:         url "three-1.1"
// 35:       end
// 36:     end
// 37:
// 38:     let(:formulae) do
// 39:       [
// 40:         formula_with_deps,
// 41:         first_formula_dep,
// 42:         second_formula_dep,
// 43:         formula_is_build_dep,
// 44:       ]
// 45:     end
// 46:
// 47:     let(:tab_from_keg) { instance_double(Tab) }
// 48:
// 49:     before do
// 50:       allow(tab_from_keg).to receive(:runtime_dependencies).and_return(nil)
// 51:       allow(formula_with_deps).to receive_messages(
// 52:         installed_runtime_formula_dependencies: [first_formula_dep, second_formula_dep],
// 53:         any_installed_keg:                      instance_double(Keg, tab: tab_from_keg),
// 54:       )
// 55:       allow(first_formula_dep).to receive_messages(
// 56:         installed_runtime_formula_dependencies: [second_formula_dep],
// 57:         any_installed_keg:                      instance_double(Keg, tab: tab_from_keg),
// 58:       )
// 59:       allow(second_formula_dep).to receive_messages(
// 60:         installed_runtime_formula_dependencies: [],
// 61:         any_installed_keg:                      instance_double(Keg, tab: tab_from_keg),
// 62:       )
// 63:       allow(formula_is_build_dep).to receive_messages(
// 64:         installed_runtime_formula_dependencies: [],
// 65:         any_installed_keg:                      instance_double(Keg, tab: tab_from_keg),
// 66:       )
// 67:     end
// 68:   end
// 69:
// 70:   describe "::bottled_formulae_with_no_formula_dependents" do
// 71:     include_context "with formulae for dependency testing"
// 72:
// 73:     before do
// 74:       allow(Formulary).to receive(:factory).with("three", { warn: false })
// 75:                                            .and_return(formula_is_build_dep)
// 76:     end
// 77:
// 78:     context "when formulae are bottles" do
// 79:       it "filters out runtime dependencies" do
// 80:         allow(tab_from_keg).to receive(:poured_from_bottle).and_return(true)
// 81:
// 82:         expect(described_class.bottled_formulae_with_no_formula_dependents(formulae))
// 83:           .to eq([formula_with_deps, formula_is_build_dep])
// 84:       end
// 85:     end
// 86:
// 87:     context "when formulae are built from source" do
// 88:       it "filters out formulae" do
// 89:         allow(tab_from_keg).to receive(:poured_from_bottle).and_return(false)
// 90:
// 91:         expect(described_class.bottled_formulae_with_no_formula_dependents(formulae))
// 92:           .to eq([])
// 93:       end
// 94:     end
// 95:
// 96:     context "when tab has runtime_dependencies data" do
// 97:       it "uses tab dep names without calling installed_runtime_formula_dependencies" do
// 98:         allow(tab_from_keg).to receive_messages(
// 99:           runtime_dependencies: [{ "full_name" => "one" }, { "full_name" => "two" }], poured_from_bottle: true,
// 100:         )
// 101:
// 102:         expect(formula_with_deps).not_to receive(:installed_runtime_formula_dependencies)
// 103:         expect(first_formula_dep).not_to receive(:installed_runtime_formula_dependencies)
// 104:
// 105:         expect(described_class.bottled_formulae_with_no_formula_dependents(formulae))
// 106:           .to eq([formula_with_deps, formula_is_build_dep])
// 107:       end
// 108:     end
// 109:   end
// 110:
// 111:   describe "::unused_formulae_with_no_formula_dependents" do
// 112:     include_context "with formulae for dependency testing"
// 113:
// 114:     before do
// 115:       allow(tab_from_keg).to receive(:poured_from_bottle).and_return(true)
// 116:     end
// 117:
// 118:     specify "installed on request" do
// 119:       allow(tab_from_keg).to receive_messages(installed_on_request: true, installed_on_request_present?: true)
// 120:
// 121:       expect(described_class.unused_formulae_with_no_formula_dependents(formulae))
// 122:         .to eq([])
// 123:     end
// 124:
// 125:     specify "not installed on request" do
// 126:       allow(tab_from_keg).to receive_messages(installed_on_request: false, installed_on_request_present?: true)
// 127:
// 128:       expect(described_class.unused_formulae_with_no_formula_dependents(formulae))
// 129:         .to match_array(formulae)
// 130:     end
// 131:
// 132:     specify "installed on request is null" do
// 133:       allow(tab_from_keg).to receive_messages(installed_on_request: false, installed_on_request_present?: false)
// 134:
// 135:       expect(described_class.unused_formulae_with_no_formula_dependents(formulae))
// 136:         .to eq([])
// 137:     end
// 138:   end
// 139:
// 140:   shared_context "with formulae and casks for dependency testing" do
// 141:     include_context "with formulae for dependency testing"
// 142:
// 143:     require "cask/cask_loader"
// 144:
// 145:     let(:cask_one_dep) do
// 146:       Cask::CaskLoader.load(+<<-RUBY)
// 147:         cask "red" do
// 148:           depends_on formula: "two"
// 149:         end
// 150:       RUBY
// 151:     end
// 152:
// 153:     let(:cask_multiple_deps) do
// 154:       Cask::CaskLoader.load(+<<-RUBY)
// 155:         cask "blue" do
// 156:           depends_on formula: "zero"
// 157:         end
// 158:       RUBY
// 159:     end
// 160:
// 161:     let(:first_cask_no_deps) do
// 162:       Cask::CaskLoader.load(+<<-RUBY)
// 163:         cask "green" do
// 164:         end
// 165:       RUBY
// 166:     end
// 167:
// 168:     let(:second_cask_no_deps) do
// 169:       Cask::CaskLoader.load(+<<-RUBY)
// 170:         cask "purple" do
// 171:         end
// 172:       RUBY
// 173:     end
// 174:
// 175:     let(:casks_no_deps) { [first_cask_no_deps, second_cask_no_deps] }
// 176:     let(:casks_one_dep) { [first_cask_no_deps, second_cask_no_deps, cask_one_dep] }
// 177:     let(:casks_multiple_deps) { [first_cask_no_deps, second_cask_no_deps, cask_multiple_deps] }
// 178:   end
// 179:
// 180:   describe "::cask_dependent_formula_names" do
// 181:     include_context "with formulae and casks for dependency testing"
// 182:
// 183:     specify "no dependents" do
// 184:       expect(described_class.cask_dependent_formula_names(casks_no_deps, formulae))
// 185:         .to eq(Set.new)
// 186:     end
// 187:
// 188:     specify "one dependent" do
// 189:       expect(described_class.cask_dependent_formula_names(casks_one_dep, formulae))
// 190:         .to contain_exactly("two")
// 191:     end
// 192:
// 193:     specify "multiple dependents" do
// 194:       expect(described_class.cask_dependent_formula_names(casks_multiple_deps, formulae))
// 195:         .to contain_exactly("zero", "one", "two")
// 196:     end
// 197:   end
// 198: end
