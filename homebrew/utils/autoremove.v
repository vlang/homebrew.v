module utils

import ruby

// Translated from Homebrew/brew `utils/autoremove.rb`.
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
