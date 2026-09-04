module homebrew

// Translated from Homebrew/brew `test_runner_formula.rb`.
pub enum TestRunnerRequirementKind {
	arch
	macos
	linux
}

pub struct TestRunnerRequirement {
pub:
	kind              TestRunnerRequirementKind
	arch              string
	version           string
	comparator        string = '>='
	version_specified bool
}

pub struct TestRunnerDependencyRule {
pub:
	name          string
	platform      string
	arch          string
	macos_version string
}

pub struct TestRunnerFormulaDefinition {
pub:
	name             string
	supports_macos   bool = true
	supports_linux   bool = true
	requirements     []TestRunnerRequirement
	dependencies     []string
	conditional_deps []TestRunnerDependencyRule
	installed        bool
	disabled         bool
	deprecated       bool
}

pub struct TestRunnerFormula {
pub:
	name                  string
	formula               TestRunnerFormulaDefinition
	eval_all              bool
	factory_cache_enabled bool
}

pub struct TestRunnerSystem {
pub:
	platform      string
	arch          string
	macos_version string
}

pub fn new_test_runner_formula(formula TestRunnerFormulaDefinition,
	eval_all bool) TestRunnerFormula {
	return TestRunnerFormula{
		name: formula.name
		formula: formula
		eval_all: eval_all
		factory_cache_enabled: true
	}
}

pub fn (wrapper TestRunnerFormula) macos_only() bool {
	return !wrapper.linux_compatible()
}

pub fn (wrapper TestRunnerFormula) macos_compatible() bool {
	return wrapper.formula.supports_macos
}

pub fn (wrapper TestRunnerFormula) linux_only() bool {
	return !wrapper.macos_compatible()
}

pub fn (wrapper TestRunnerFormula) linux_compatible() bool {
	return wrapper.formula.supports_linux
}

pub fn (wrapper TestRunnerFormula) x86_64_only() bool {
	return wrapper.formula.requirements.any(it.kind == .arch && it.arch == 'x86_64')
}

pub fn (wrapper TestRunnerFormula) x86_64_compatible() bool {
	return !wrapper.arm64_only()
}

pub fn (wrapper TestRunnerFormula) arm64_only() bool {
	return wrapper.formula.requirements.any(it.kind == .arch && it.arch == 'arm64')
}

pub fn (wrapper TestRunnerFormula) arm64_compatible() bool {
	return !wrapper.x86_64_only()
}

pub fn (wrapper TestRunnerFormula) versioned_macos_requirement() ?TestRunnerRequirement {
	for requirement in wrapper.formula.requirements {
		if requirement.kind == .macos && requirement.version_specified {
			return requirement
		}
	}
	return none
}

fn test_runner_version_parts(version string) []int {
	mut parts := []int{}
	for part in version.split('.') {
		parts << (part.int())
	}
	return parts
}

fn test_runner_compare_versions(left string, right string) int {
	left_parts := test_runner_version_parts(left)
	right_parts := test_runner_version_parts(right)
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

pub fn (wrapper TestRunnerFormula) compatible_with(macos_version string) bool {
	requirement := wrapper.versioned_macos_requirement() or { return true }
	comparison := test_runner_compare_versions(macos_version, requirement.version)
	return match requirement.comparator {
		'>' { comparison > 0 }
		'<=' { comparison <= 0 }
		'<' { comparison < 0 }
		'==' { comparison == 0 }
		else { comparison >= 0 }
	}
}

fn test_runner_rule_active(rule TestRunnerDependencyRule, system TestRunnerSystem) bool {
	if rule.platform != '' && rule.platform != system.platform {
		return false
	}
	if rule.arch != '' && rule.arch != system.arch {
		return false
	}
	if rule.macos_version != '' {
		return system.platform == 'macos' && system.macos_version == rule.macos_version
	}
	return true
}

fn test_runner_active_dependencies(formula TestRunnerFormulaDefinition,
	system TestRunnerSystem) []string {
	mut dependencies := formula.dependencies.clone()
	for rule in formula.conditional_deps {
		if test_runner_rule_active(rule, system) {
			dependencies << rule.name
		}
	}
	return dependencies
}

pub fn (wrapper TestRunnerFormula) dependents(candidates []TestRunnerFormulaDefinition,
	system TestRunnerSystem) []TestRunnerFormula {
	mut result := []TestRunnerFormula{}
	for candidate in candidates {
		if !wrapper.eval_all && !candidate.installed {
			continue
		}
		if wrapper.name in test_runner_active_dependencies(candidate, system) {
			result << new_test_runner_formula(candidate, wrapper.eval_all)
		}
	}
	return result
}
