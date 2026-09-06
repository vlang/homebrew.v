module homebrew

// Translated from Homebrew/brew `cask_dependent.rb`.
pub struct CaskDependentArch {
pub:
	kind string
	bits int = 64
}

pub struct CaskDependentDependency {
pub:
	name string
}

pub struct CaskDependentRequirement {
pub:
	kind string
	name string
	cask string
}

pub struct CaskDependentFormula {
pub:
	name                 string
	dependencies         []string
	runtime_dependencies []string
	requirements         []CaskDependentRequirement
}

pub type CaskDependentRuntimeResolver = fn (string, bool, bool) []string

pub struct CaskDependentCask {
pub:
	token                string
	full_name            string
	installed            bool
	formula_dependencies []string
	cask_dependencies    []string
	arch                 []CaskDependentArch
	linux                bool
	macos                bool
	maximum_macos        bool
}

pub struct CaskDependentGraph {
pub:
	formulae         map[string]CaskDependentFormula
	installed_casks  []string
	runtime_resolver ?CaskDependentRuntimeResolver
}

pub struct CaskDependent {
pub:
	cask  CaskDependentCask
	graph CaskDependentGraph
}

pub fn new_cask_dependent(cask CaskDependentCask, graph CaskDependentGraph) CaskDependent {
	return CaskDependent{
		cask: cask
		graph: graph
	}
}

pub fn (dependent CaskDependent) name() string {
	return dependent.cask.token
}

pub fn (dependent CaskDependent) full_name() string {
	return if dependent.cask.full_name != '' {
		dependent.cask.full_name
	} else {
		dependent.cask.token
	}
}

pub fn (dependent CaskDependent) deps() []CaskDependentDependency {
	return dependent.cask.formula_dependencies.map(CaskDependentDependency{
		name: it
	})
}

fn cask_dependent_arch_name(arch CaskDependentArch) string {
	if arch.bits == 64 {
		return if arch.kind == 'intel' { 'x86_64' } else { '${arch.kind}64' }
	}
	if arch.kind == 'intel' && arch.bits == 32 {
		return 'i386'
	}
	return arch.kind
}

pub fn (dependent CaskDependent) requirements() []CaskDependentRequirement {
	mut result := []CaskDependentRequirement{}
	for arch in dependent.cask.arch {
		result << CaskDependentRequirement{
			kind: 'arch'
			name: cask_dependent_arch_name(arch)
		}
	}
	for token in dependent.cask.cask_dependencies {
		result << CaskDependentRequirement{
			kind: 'cask'
			name: token
			cask: token
		}
	}
	if dependent.cask.linux {
		result << CaskDependentRequirement{
			kind: 'linux'
			name: 'linux'
		}
	}
	if dependent.cask.macos {
		result << CaskDependentRequirement{
			kind: 'macos'
			name: 'macos'
		}
	}
	if dependent.cask.maximum_macos {
		result << CaskDependentRequirement{
			kind: 'maximum_macos'
			name: 'macos'
		}
	}
	return result
}

fn cask_dependent_append_formula_dependencies(name string, graph CaskDependentGraph,
	mut visiting []string, mut result []string) {
	if name in visiting || name in result {
		return
	}
	visiting << name
	formula := graph.formulae[name] or {
		CaskDependentFormula{
			name: name
		}
	}
	for child in formula.dependencies {
		cask_dependent_append_formula_dependencies(child, graph, mut visiting, mut result)
	}
	visiting.delete(visiting.index(name))
	if name !in result {
		result << name
	}
}

pub fn (dependent CaskDependent) runtime_dependencies(read_from_tab bool,
	undeclared bool) []CaskDependentDependency {
	mut result := []string{}
	for dependency in dependent.cask.formula_dependencies {
		if dependency !in result {
			result << dependency
		}
		formula := dependent.graph.formulae[dependency] or {
			CaskDependentFormula{
				name: dependency
			}
		}
		runtime := if resolver := dependent.graph.runtime_resolver {
			resolver(dependency, read_from_tab, undeclared)
		} else {
			formula.runtime_dependencies
		}
		for child in runtime {
			if child !in result {
				result << child
			}
		}
	}
	return result.map(CaskDependentDependency{
		name: it
	})
}

pub fn (dependent CaskDependent) recursive_dependencies() []CaskDependentDependency {
	mut names := []string{}
	mut visiting := []string{}
	for dependency in dependent.cask.formula_dependencies {
		cask_dependent_append_formula_dependencies(dependency, dependent.graph, mut visiting, mut names)
	}
	return names.map(CaskDependentDependency{
		name: it
	})
}

fn cask_dependent_requirement_key(requirement CaskDependentRequirement) string {
	return '${requirement.kind}:${requirement.name}:${requirement.cask}'
}

fn cask_dependent_append_formula_requirements(name string, graph CaskDependentGraph,
	mut visiting []string, mut seen []string, mut result []CaskDependentRequirement) {
	if name in visiting {
		return
	}
	visiting << name
	formula := graph.formulae[name] or {
		CaskDependentFormula{
			name: name
		}
	}
	for child in formula.dependencies {
		cask_dependent_append_formula_requirements(child, graph, mut visiting, mut seen, mut result)
	}
	for requirement in formula.requirements {
		key := cask_dependent_requirement_key(requirement)
		if key !in seen {
			seen << key
			result << requirement
		}
	}
	visiting.delete(visiting.index(name))
}

pub fn (dependent CaskDependent) recursive_requirements() []CaskDependentRequirement {
	mut result := []CaskDependentRequirement{}
	mut seen := []string{}
	mut visiting := []string{}
	for dependency in dependent.cask.formula_dependencies {
		cask_dependent_append_formula_requirements(dependency, dependent.graph, mut visiting, mut seen, mut result)
	}
	for requirement in dependent.requirements() {
		key := cask_dependent_requirement_key(requirement)
		if key !in seen {
			seen << key
			result << requirement
		}
	}
	return result
}

pub fn (dependent CaskDependent) any_version_installed() bool {
	return dependent.cask.installed
}

pub fn (dependent CaskDependent) requirement_satisfied(requirement CaskDependentRequirement) bool {
	return requirement.kind != 'cask' || requirement.cask in dependent.graph.installed_casks
}
