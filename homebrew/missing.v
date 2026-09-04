module homebrew

import ruby

// Translated from Homebrew/brew `missing.rb`.
pub struct MissingDependency {
pub:
	full_name string
}

pub struct MissingFormula {
pub:
	full_name            string
	display_name         string
	missing_dependencies []string
}

pub struct MissingCask {
pub:
	full_name            string
	display_name         string
	runtime_dependencies map[string][]MissingDependency
}

fn missing_dependency_name(full_name string) string {
	parts := full_name.split('/')
	return parts.last()
}

pub fn missing_cask_dependencies(cask MissingCask, hide []string, installed_formulae []string,
	installed_casks []string) []string {
	mut missing := []string{}
	for dependency_type, dependencies in cask.runtime_dependencies {
		for dependency in dependencies {
			if dependency.full_name.trim_space() == '' {
				continue
			}
			name := missing_dependency_name(dependency.full_name)
			installed := match dependency_type {
				'cask' { name in installed_casks }
				'formula' { name in installed_formulae }
				else { true }
			}
			if name !in hide && installed {
				continue
			}
			missing << dependency.full_name
		}
	}
	missing.sort()
	return missing
}

pub fn missing_dependencies(formulae []MissingFormula, casks []MissingCask, hide []string,
	installed_formulae []string, installed_casks []string) map[string][]string {
	mut missing := map[string][]string{}
	for formula in formulae {
		if formula.missing_dependencies.len > 0 {
			missing[formula.full_name] = formula.missing_dependencies.clone()
		}
	}
	for cask in casks {
		dependencies := missing_cask_dependencies(cask, hide, installed_formulae, installed_casks)
		if dependencies.len > 0 {
			missing[cask.full_name] = dependencies
		}
	}
	return missing
}

fn missing_formulae_from_value(value ruby.Value) []MissingFormula {
	return value.array_data.map(MissingFormula{
		full_name: it.attributes['full_name'] or { it.as_string() }
		display_name: it.attributes['display_name'] or { it.as_string() }
		missing_dependencies: (it.attributes['missing_dependencies'] or { '' }).split(',').filter(it != '')
	})
}

fn missing_cask_from_value(value ruby.Value) MissingCask {
	mut dependencies := map[string][]MissingDependency{}
	for dependency_type, list in value.map_data {
		dependencies[dependency_type] = list.array_data.map(MissingDependency{
			full_name: it.attributes['full_name'] or { it.as_string() }
		})
	}
	return MissingCask{
		full_name: value.attributes['full_name'] or { value.as_string() }
		display_name: value.attributes['display_name'] or { value.as_string() }
		runtime_dependencies: dependencies
	}
}

fn missing_casks_from_value(value ruby.Value) []MissingCask {
	return value.array_data.map(missing_cask_from_value(it))
}

fn missing_map_value(values map[string][]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for name, dependencies in values {
		result[name] = ruby.string_array_value(dependencies)
	}
	return ruby.map_value(result)
}
