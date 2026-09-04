module cmd

import ruby

// Translated from Homebrew/brew `cmd/leaves.rb`.
pub enum LeavesFilter {
	all
	installed_on_request
	installed_as_dependency
}

pub struct LeavesFormula {
pub:
	full_name                      string
	possible_names                 []string
	has_tab_runtime_dependencies   bool
	tab_runtime_dependencies       []string
	installed_runtime_dependencies []string
	installed_on_request           bool
}

fn leaf_dependency_name(full_name string) string {
	return full_name.all_after_last('/')
}

pub fn installed_on_request(formula LeavesFormula) bool {
	return formula.installed_on_request
}

pub fn formula_leaves(installed []LeavesFormula, cask_dependencies []string, filter LeavesFilter) []string {
	mut dependency_names := map[string]bool{}
	for formula in installed {
		dependencies := if formula.has_tab_runtime_dependencies {
			formula.tab_runtime_dependencies
		} else {
			formula.installed_runtime_dependencies
		}
		for dependency in dependencies {
			if dependency != '' {
				dependency_names[leaf_dependency_name(dependency)] = true
			}
		}
	}
	for dependency in cask_dependencies {
		if dependency != '' {
			dependency_names[leaf_dependency_name(dependency)] = true
		}
	}
	mut leaves := []string{}
	for formula in installed {
		if formula.possible_names.any(it in dependency_names) {
			continue
		}
		if filter == .installed_on_request && !installed_on_request(formula) {
			continue
		}
		if filter == .installed_as_dependency && installed_on_request(formula) {
			continue
		}
		leaves << formula.full_name
	}
	leaves.sort()
	return leaves
}

pub fn leaves_formula_value(formula LeavesFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'full_name':                    formula.full_name
			'has_tab_runtime_dependencies': formula.has_tab_runtime_dependencies.str()
			'installed_on_request':         formula.installed_on_request.str()
		}
		map_data: {
			'possible_names':                 ruby.string_array_value(formula.possible_names)
			'tab_runtime_dependencies':       ruby.string_array_value(formula.tab_runtime_dependencies)
			'installed_runtime_dependencies': ruby.string_array_value(formula.installed_runtime_dependencies)
		}
	}
}

fn leaves_formula_from_value(value ruby.Value) LeavesFormula {
	return LeavesFormula{
		full_name: value.attribute('full_name') or { value.as_string() }
		possible_names: (value.map_data['possible_names'] or {
			ruby.string_array_value([
				value.as_string(),
			])
		}).as_string_array() or { [value.as_string()] }
		has_tab_runtime_dependencies: (value.attribute('has_tab_runtime_dependencies') or { 'false' }) == 'true'
		tab_runtime_dependencies: (value.map_data['tab_runtime_dependencies'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		installed_runtime_dependencies: (value.map_data['installed_runtime_dependencies'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		installed_on_request: (value.attribute('installed_on_request') or { 'false' }) == 'true'
	}
}

fn leaves_filter_from_string(value string) LeavesFilter {
	return match value {
		'installed_on_request' { .installed_on_request }
		'installed_as_dependency' { .installed_as_dependency }
		else { .all }
	}
}
