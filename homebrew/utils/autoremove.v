module utils

import ruby

// Translated from Homebrew/brew `utils/autoremove.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AutoremoveTab {
pub:
	runtime_dependencies_present bool
	runtime_dependencies         []string
	poured_from_bottle           bool
	installed_on_request_present bool
	installed_on_request         bool
}

pub struct AutoremoveFormula {
pub:
	name                           string
	possible_names                 []string
	installed_runtime_dependencies []string
	build_dependencies             []string
	tab_present                    bool
	tab                            AutoremoveTab
}

pub struct AutoremoveCask {
pub:
	name                 string
	formula_dependencies []string
}

fn autoremove_base_name(name string) string {
	return name.all_after_last('/')
}

fn autoremove_possible_names(formula AutoremoveFormula) []string {
	if formula.possible_names.len > 0 {
		return formula.possible_names.clone()
	}
	return [formula.name]
}

fn autoremove_intersects(names map[string]bool, formula AutoremoveFormula) bool {
	return autoremove_possible_names(formula).any(it in names)
}

fn autoremove_runtime_dependencies(formula AutoremoveFormula) []string {
	if formula.tab_present && formula.tab.runtime_dependencies_present {
		return formula.tab.runtime_dependencies.map(autoremove_base_name(it))
	}
	return formula.installed_runtime_dependencies.map(autoremove_base_name(it))
}

pub fn cask_dependent_formula_names(casks []AutoremoveCask,
	formulae []AutoremoveFormula) []string {
	mut by_name := map[string]AutoremoveFormula{}
	for formula in formulae {
		by_name[formula.name] = formula
	}
	mut names := map[string]bool{}
	for cask in casks {
		for dependency in cask.formula_dependencies {
			base := autoremove_base_name(dependency)
			formula := by_name[base] or { continue }
			names[base] = true
			for runtime_dependency in autoremove_runtime_dependencies(formula) {
				names[runtime_dependency] = true
			}
		}
	}
	mut result := names.keys()
	result.sort()
	return result
}

pub fn bottled_formulae_with_no_formula_dependents(formulae []AutoremoveFormula) []AutoremoveFormula {
	mut names_to_keep := map[string]bool{}
	for formula in formulae {
		for dependency in autoremove_runtime_dependencies(formula) {
			names_to_keep[dependency] = true
		}
		if formula.tab_present && formula.tab.poured_from_bottle {
			continue
		}
		if formula.tab_present {
			names_to_keep[formula.name] = true
		}
		for dependency in formula.build_dependencies {
			names_to_keep[autoremove_base_name(dependency)] = true
		}
	}
	return formulae.filter(!autoremove_intersects(names_to_keep, it))
}

pub fn unused_formulae_with_no_formula_dependents(formulae []AutoremoveFormula) []AutoremoveFormula {
	mut remaining := formulae.clone()
	mut unused := []AutoremoveFormula{}
	for {
		leaves := bottled_formulae_with_no_formula_dependents(remaining).filter(it.tab_present && it.tab.installed_on_request_present && !it.tab.installed_on_request)
		if leaves.len == 0 {
			break
		}
		unused << leaves
		leaf_names := leaves.map(it.name)
		remaining = remaining.filter(it.name !in leaf_names)
	}
	return unused
}

pub fn removable_formulae(formulae []AutoremoveFormula, casks []AutoremoveCask) []AutoremoveFormula {
	unused := unused_formulae_with_no_formula_dependents(formulae)
	cask_dependencies := cask_dependent_formula_names(casks, formulae)
	mut protected := map[string]bool{}
	for name in cask_dependencies {
		protected[name] = true
	}
	return unused.filter(!autoremove_intersects(protected, it))
}

pub fn autoremove_formula_value(formula AutoremoveFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.name
		attributes: {
			'name':                         formula.name
			'tab_present':                  formula.tab_present.str()
			'poured_from_bottle':           formula.tab.poured_from_bottle.str()
			'installed_on_request_present': formula.tab.installed_on_request_present.str()
			'installed_on_request':         formula.tab.installed_on_request.str()
			'runtime_dependencies_present': formula.tab.runtime_dependencies_present.str()
		}
		map_data: {
			'possible_names':                 ruby.string_array_value(autoremove_possible_names(formula))
			'installed_runtime_dependencies': ruby.string_array_value(formula.installed_runtime_dependencies)
			'runtime_dependencies':           ruby.string_array_value(formula.tab.runtime_dependencies)
			'build_dependencies':             ruby.string_array_value(formula.build_dependencies)
		}
	}
}

pub fn autoremove_cask_value(cask AutoremoveCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask'
		repr: cask.name
		attributes: {
			'name': cask.name
		}
		map_data: {
			'formula_dependencies': ruby.string_array_value(cask.formula_dependencies)
		}
	}
}

fn autoremove_strings(value ruby.Value, key string) []string {
	return if item := value.map_data[key] {
		item.as_string_array() or { []string{} }
	} else {
		[]string{}
	}
}

pub fn autoremove_formula_from_value(value ruby.Value) AutoremoveFormula {
	return AutoremoveFormula{
		name: value.attributes['name'] or { value.as_string() }
		possible_names: autoremove_strings(value, 'possible_names')
		installed_runtime_dependencies: autoremove_strings(value, 'installed_runtime_dependencies')
		build_dependencies: autoremove_strings(value, 'build_dependencies')
		tab_present: (value.attributes['tab_present'] or { 'false' }) == 'true'
		tab: AutoremoveTab{
			runtime_dependencies_present: (value.attributes['runtime_dependencies_present'] or { 'false' }) == 'true'
			runtime_dependencies: autoremove_strings(value, 'runtime_dependencies')
			poured_from_bottle: (value.attributes['poured_from_bottle'] or { 'false' }) == 'true'
			installed_on_request_present: (value.attributes['installed_on_request_present'] or { 'false' }) == 'true'
			installed_on_request: (value.attributes['installed_on_request'] or { 'false' }) == 'true'
		}
	}
}

pub fn autoremove_cask_from_value(value ruby.Value) AutoremoveCask {
	return AutoremoveCask{
		name: value.attributes['name'] or { value.as_string() }
		formula_dependencies: autoremove_strings(value, 'formula_dependencies')
	}
}

fn autoremove_formulae_from_boundary(value ruby.Value) []AutoremoveFormula {
	values := value.as_array() or { return []AutoremoveFormula{} }
	return values.map(autoremove_formula_from_value(it))
}

fn autoremove_casks_from_boundary(value ruby.Value) []AutoremoveCask {
	values := value.as_array() or { return []AutoremoveCask{} }
	return values.map(autoremove_cask_from_value(it))
}

fn autoremove_formulae_value(formulae []AutoremoveFormula) ruby.Value {
	return ruby.array_value(formulae.map(autoremove_formula_value(it)))
}

// Ruby method `removable_formulae(formulae, casks)` at line 15.
pub fn ruby_autoremove_l15_d1_removable_formulae(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return autoremove_formulae_value(removable_formulae(autoremove_formulae_from_boundary(args[0]), autoremove_casks_from_boundary(args[1])))
}

// Ruby method `cask_dependent_formula_names(casks, formulae)` at line 25.
pub fn ruby_autoremove_l25_d2_cask_dependent_formula_names(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_array_value([]string{})
	}
	return ruby.string_array_value(cask_dependent_formula_names(autoremove_casks_from_boundary(args[0]), autoremove_formulae_from_boundary(args[1])))
}

// Ruby method `bottled_formulae_with_no_formula_dependents(formulae)` at line 56.
pub fn ruby_autoremove_l56_d3_bottled_formulae_with_no_formula_dependents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	return autoremove_formulae_value(bottled_formulae_with_no_formula_dependents(autoremove_formulae_from_boundary(args[0])))
}

// Ruby method `unused_formulae_with_no_formula_dependents(formulae)` at line 94.
pub fn ruby_autoremove_l94_d4_unused_formulae_with_no_formula_dependents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	return autoremove_formulae_value(unused_formulae_with_no_formula_dependents(autoremove_formulae_from_boundary(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper function for finding autoremovable formulae.
// 6:   #
// 7:   # @private
// 8:   module Autoremove
// 9:     class << self
// 10:       # An array of {Formula} without {Formula} or {Cask}
// 11:       # dependents that weren't installed on request and without
// 12:       # build dependencies for {Formula} installed from source.
// 13:       # @private
// 14:       sig { params(formulae: T::Array[Formula], casks: T::Array[Cask::Cask]).returns(T::Array[Formula]) }
// 15:       def removable_formulae(formulae, casks)
// 16:         unused_formulae = unused_formulae_with_no_formula_dependents(formulae)
// 17:         cask_dep_names = cask_dependent_formula_names(casks, formulae)
// 18:         unused_formulae.reject { |f| cask_dep_names.intersect?(f.possible_names) }
// 19:       end
// 20:
// 21:       # A set of names for all installed {Formula} objects that are {Cask} formula
// 22:       # dependencies (direct or transitive).
// 23:       # @private
// 24:       sig { params(casks: T::Array[Cask::Cask], formulae: T::Array[Formula]).returns(T::Set[String]) }
// 25:       def cask_dependent_formula_names(casks, formulae)
// 26:         formulae_by_name = formulae.to_h { |f| [f.name, f] }
// 27:         names = casks.flat_map { |cask| cask.depends_on.formula }.flat_map do |name|
// 28:           base = Utils.name_from_full_name(name)
// 29:           f = formulae_by_name[base]
// 30:           next [] unless f
// 31:
// 32:           tab = f.any_installed_keg&.tab
// 33:           dep_names = if (tab_deps = T.cast(tab&.runtime_dependencies,
// 34:                                             T.nilable(T::Array[T::Hash[String, T.untyped]])))
// 35:             # Use tab data to avoid Formulary.resolve for each dependency.
// 36:             tab_deps.filter_map do |dep|
// 37:               full_name = dep["full_name"]
// 38:               next unless full_name
// 39:
// 40:               Utils.name_from_full_name(full_name)
// 41:             end
// 42:           else
// 43:             # Fallback for pre-1.1.6 installations without tab runtime_dependencies.
// 44:             f.installed_runtime_formula_dependencies.map(&:name)
// 45:           end
// 46:           [base, *dep_names]
// 47:         end
// 48:         names.to_set
// 49:       end
// 50:
// 51:       # An array of all installed bottled {Formula} without runtime {Formula}
// 52:       # dependents for bottles and without build {Formula} dependents
// 53:       # for those built from source.
// 54:       # @private
// 55:       sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 56:       def bottled_formulae_with_no_formula_dependents(formulae)
// 57:         names_to_keep = T.let(Set.new, T::Set[String])
// 58:         formulae.each do |formula|
// 59:           tab = formula.any_installed_keg&.tab
// 60:           if (tab_deps = T.cast(tab&.runtime_dependencies, T.nilable(T::Array[T::Hash[String, T.untyped]])))
// 61:             # Use tab data to avoid Formulary.resolve for each dependency.
// 62:             tab_deps.each do |dep|
// 63:               full_name = dep["full_name"]
// 64:               next unless full_name
// 65:
// 66:               names_to_keep.add(Utils.name_from_full_name(full_name))
// 67:             end
// 68:           else
// 69:             # Fallback for pre-1.1.6 installations without tab runtime_dependencies.
// 70:             formula.installed_runtime_formula_dependencies.each { |f| names_to_keep.add(f.name) }
// 71:           end
// 72:
// 73:           if tab
// 74:             # Ignore build dependencies when the formula is a bottle
// 75:             next if tab.poured_from_bottle
// 76:
// 77:             # Keep the formula if it was built from source
// 78:             names_to_keep.add(formula.name)
// 79:           end
// 80:
// 81:           formula.deps.select(&:build?).each do |dep|
// 82:             names_to_keep.add(dep.to_formula.name)
// 83:           rescue FormulaUnavailableError
// 84:             # do nothing
// 85:           end
// 86:         end
// 87:         formulae.reject { |f| names_to_keep.intersect?(f.possible_names) }
// 88:       end
// 89:
// 90:       # Recursive function that returns an array of {Formula} without
// 91:       # {Formula} dependents that weren't installed on request.
// 92:       # @private
// 93:       sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 94:       def unused_formulae_with_no_formula_dependents(formulae)
// 95:         unused_formulae = bottled_formulae_with_no_formula_dependents(formulae).select do |f|
// 96:           tab = f.any_installed_keg&.tab
// 97:           next unless tab
// 98:           next unless tab.installed_on_request_present?
// 99:
// 100:           tab.installed_on_request == false
// 101:         end
// 102:
// 103:         unless unused_formulae.empty?
// 104:           unused_formulae += unused_formulae_with_no_formula_dependents(formulae - unused_formulae)
// 105:         end
// 106:
// 107:         unused_formulae
// 108:       end
// 109:     end
// 110:   end
// 111: end
