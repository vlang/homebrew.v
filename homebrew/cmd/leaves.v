module cmd

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

fn leaves_filter_from_string(value string) LeavesFilter {
	return match value {
		'installed_on_request' { .installed_on_request }
		'installed_as_dependency' { .installed_as_dependency }
		else { .all }
	}
}
