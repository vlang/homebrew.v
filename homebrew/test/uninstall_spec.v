module test

import ruby
import homebrew as uninstall_core

// Translated from Homebrew/brew `test/uninstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn uninstall_spec_dependency_record() uninstall_core.InstalledDependentDependency {
	return uninstall_core.InstalledDependentDependency{
		full_name: 'dependency'
	}
}

fn uninstall_spec_dependency_formula() uninstall_core.InstalledDependentFormula {
	return uninstall_core.InstalledDependentFormula{
		name: 'dependency'
		tap: 'homebrew/core'
		display_name: 'dependency'
		has_runtime_dependencies: true
		reliable_tab: true
	}
}

fn uninstall_spec_dependent_formula_record() uninstall_core.InstalledDependentFormula {
	return uninstall_core.InstalledDependentFormula{
		name: 'dependent_formula'
		tap: 'homebrew/core'
		display_name: 'dependent_formula'
		runtime_dependencies: [uninstall_spec_dependency_record()]
		has_runtime_dependencies: true
		reliable_tab: true
	}
}

fn uninstall_spec_dependent_cask_record() uninstall_core.InstalledDependentCask {
	return uninstall_core.InstalledDependentCask{
		token: 'dependent_cask'
		display_name: 'dependent_cask'
		runtime_dependencies: [uninstall_spec_dependency_record()]
	}
}

fn uninstall_spec_keg() uninstall_core.InstalledDependentKeg {
	return uninstall_core.InstalledDependentKeg{
		id: '/Cellar/dependency/1'
		name: 'dependency'
		version: '1'
		optlinked: true
		formula_resolved: true
		formula_name: 'dependency'
		formula_tap: 'homebrew/core'
		tab_tap: 'homebrew/core'
	}
}

fn uninstall_spec_context() uninstall_core.InstalledDependentsContext {
	return uninstall_core.InstalledDependentsContext{
		kegs: [uninstall_spec_keg()]
		installed_formulae: [uninstall_spec_dependent_formula_record()]
		installed_casks: [uninstall_spec_dependent_cask_record()]
	}
}

// Ruby let `let(:dependency) do` at line 7.
pub fn ruby_uninstall_spec_l7_d1_dependency(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_core.installed_dependent_formula_value(uninstall_spec_dependency_formula())
}

// Ruby let `let(:dependent_formula) do` at line 14.
pub fn ruby_uninstall_spec_l14_d2_dependent_formula(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_core.installed_dependent_formula_value(uninstall_spec_dependent_formula_record())
}

// Ruby let `let(:dependent_cask) do` at line 22.
pub fn ruby_uninstall_spec_l22_d3_dependent_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return uninstall_core.installed_dependent_cask_value(uninstall_spec_dependent_cask_record())
}

// Ruby let `let(:kegs_by_rack) { { dependency.rack => [Keg.new(dependency.latest_installed_prefix)] } }` at line 33.
pub fn ruby_uninstall_spec_l33_d4_kegs_by_rack(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'/Cellar/dependency': ruby.array_value([
			uninstall_core.installed_dependent_keg_value(uninstall_spec_keg()),
		])
	})
}

// Ruby specify `specify "when `ignore_dependencies` is false" do` at line 57.
pub fn ruby_uninstall_spec_l57_d5_when(args ...ruby.Value) ruby.Value {
	_ = args
	result := uninstall_core.handle_uninstall_unsatisfied_dependents(uninstall_spec_context(), false, []string{}, false)
	return ruby.bool_value(result.failed && result.output.contains('Error:')
		&& result.output.contains('dependent_formula') && result.output.contains('dependent_cask'))
}

// Ruby specify `specify "when `ignore_dependencies` is true" do` at line 65.
pub fn ruby_uninstall_spec_l65_d6_when(args ...ruby.Value) ruby.Value {
	_ = args
	result := uninstall_core.handle_uninstall_unsatisfied_dependents(uninstall_spec_context(), true, []string{}, false)
	return ruby.bool_value(!result.failed && result.output == '')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "uninstall"
// 5:
// 6: RSpec.describe Homebrew::Uninstall do
// 7:   let(:dependency) do
// 8:     formula("dependency") do
// 9:       T.bind(self, T.class_of(Formula))
// 10:       url "f-1"
// 11:     end
// 12:   end
// 13:
// 14:   let(:dependent_formula) do
// 15:     formula("dependent_formula") do
// 16:       T.bind(self, T.class_of(Formula))
// 17:       url "f-1"
// 18:       depends_on "dependency"
// 19:     end
// 20:   end
// 21:
// 22:   let(:dependent_cask) do
// 23:     Cask::CaskLoader.load(+<<-RUBY)
// 24:       cask "dependent_cask" do
// 25:         version "1.0.0"
// 26:
// 27:         url "c-1"
// 28:         depends_on formula: "dependency"
// 29:       end
// 30:     RUBY
// 31:   end
// 32:
// 33:   let(:kegs_by_rack) { { dependency.rack => [Keg.new(dependency.latest_installed_prefix)] } }
// 34:
// 35:   before do
// 36:     [dependency, dependent_formula].each do |f|
// 37:       f.latest_installed_prefix.mkpath
// 38:       Keg.new(f.latest_installed_prefix).optlink
// 39:     end
// 40:
// 41:     tab = Tab.empty
// 42:     tab.homebrew_version = "1.1.6"
// 43:     tab.tabfile = dependent_formula.latest_installed_prefix/AbstractTab::FILENAME
// 44:     tab.runtime_dependencies = [
// 45:       { "full_name" => "dependency", "version" => "1" },
// 46:     ]
// 47:     tab.write
// 48:
// 49:     Cask::Caskroom.path.join("dependent_cask", dependent_cask.version).mkpath
// 50:
// 51:     stub_formula_loader dependency
// 52:     stub_formula_loader dependent_formula
// 53:     stub_cask_loader dependent_cask
// 54:   end
// 55:
// 56:   describe "::handle_unsatisfied_dependents" do
// 57:     specify "when `ignore_dependencies` is false" do
// 58:       expect do
// 59:         described_class.handle_unsatisfied_dependents(kegs_by_rack)
// 60:       end.to output(/Error/).to_stderr
// 61:
// 62:       expect(Homebrew).to have_failed
// 63:     end
// 64:
// 65:     specify "when `ignore_dependencies` is true" do
// 66:       expect do
// 67:         described_class.handle_unsatisfied_dependents(kegs_by_rack, ignore_dependencies: true)
// 68:       end.not_to output.to_stderr
// 69:
// 70:       expect(Homebrew).not_to have_failed
// 71:     end
// 72:   end
// 73: end
