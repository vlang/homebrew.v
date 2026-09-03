module test

import brew_runtime
import homebrew
import homebrew.api

// Translated from Homebrew/brew `test/dependencies_helpers_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "#dependents" do` at line 7.
pub fn ruby_dependencies_helpers_spec_l7_d1_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	foo := homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: 'foo'
			full_name: 'foo'
			stable_version: '1.0'
			source_url: 'foo'
		}
	}) or { return brew_runtime.bool_value(false) }
	bar := homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: 'bar'
			full_name: 'bar'
			stable_version: '1.0'
			source_url: 'bar-url'
		}
	}) or { return brew_runtime.bool_value(false) }
	inputs := [
		homebrew.formula_dependent_input(foo),
		homebrew.cask_dependent_input(homebrew.CaskDependentCask{
			token: 'foo_cask'
			full_name: 'foo_cask'
		}, homebrew.CaskDependentGraph{}),
		homebrew.formula_dependent_input(bar),
		homebrew.cask_dependent_input(homebrew.CaskDependentCask{
			token: 'bar-cask'
			full_name: 'bar-cask'
		}, homebrew.CaskDependentGraph{}),
	]
	dependents := homebrew.dependents(inputs) or { return brew_runtime.bool_value(false) }
	methods := ['name', 'full_name', 'runtime_dependencies', 'deps', 'requirements',
		'recursive_dependencies', 'recursive_requirements', 'any_version_installed?']
	if dependents.len != 4 || dependents.map(it.name()) != ['foo', 'foo_cask', 'bar', 'bar-cask'] {
		return brew_runtime.bool_value(false)
	}
	for dependent in dependents {
		if !methods.all(dependent.responds_to(it)) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependencies_helpers"
// 5:
// 6: RSpec.describe DependenciesHelpers do
// 7:   specify "#dependents" do
// 8:     foo = formula "foo" do
// 9:       T.bind(self, T.class_of(Formula))
// 10:       url "foo"
// 11:       version "1.0"
// 12:     end
// 13:
// 14:     foo_cask = Cask::CaskLoader.load(+<<-RUBY)
// 15:       cask "foo_cask" do
// 16:       end
// 17:     RUBY
// 18:
// 19:     bar = formula "bar" do
// 20:       T.bind(self, T.class_of(Formula))
// 21:       url "bar-url"
// 22:       version "1.0"
// 23:     end
// 24:
// 25:     bar_cask = Cask::CaskLoader.load(+<<-RUBY)
// 26:       cask "bar-cask" do
// 27:       end
// 28:     RUBY
// 29:
// 30:     methods = [
// 31:       :name,
// 32:       :full_name,
// 33:       :runtime_dependencies,
// 34:       :deps,
// 35:       :requirements,
// 36:       :recursive_dependencies,
// 37:       :recursive_requirements,
// 38:       :any_version_installed?,
// 39:     ]
// 40:
// 41:     dependents = Class.new.extend(described_class).dependents([foo, foo_cask, bar, bar_cask])
// 42:
// 43:     dependents.each do |dependent|
// 44:       methods.each do |method|
// 45:         expect(dependent.respond_to?(method))
// 46:           .to be true
// 47:       end
// 48:     end
// 49:   end
// 50: end
