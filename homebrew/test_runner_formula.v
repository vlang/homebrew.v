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

// Ruby attr_reader `attr_reader :name` at line 8.
pub fn ruby_test_runner_formula_l8_d1_name(wrapper TestRunnerFormula) string {
	return wrapper.name
}

// Ruby attr_reader `attr_reader :formula` at line 11.
pub fn ruby_test_runner_formula_l11_d2_formula(wrapper TestRunnerFormula) TestRunnerFormulaDefinition {
	return wrapper.formula
}

// Ruby attr_reader `attr_reader :eval_all` at line 14.
pub fn ruby_test_runner_formula_l14_d3_eval_all(wrapper TestRunnerFormula) bool {
	return wrapper.eval_all
}

// Ruby method `initialize(formula, eval_all: false)` at line 17.
pub fn ruby_test_runner_formula_l17_d4_initialize(formula TestRunnerFormulaDefinition,
	eval_all bool) TestRunnerFormula {
	return new_test_runner_formula(formula, eval_all)
}

// Ruby method `macos_only?` at line 27.
pub fn ruby_test_runner_formula_l27_d5_macos_only(wrapper TestRunnerFormula) bool {
	return wrapper.macos_only()
}

// Ruby method `macos_compatible?` at line 32.
pub fn ruby_test_runner_formula_l32_d6_macos_compatible(wrapper TestRunnerFormula) bool {
	return wrapper.macos_compatible()
}

// Ruby method `linux_only?` at line 37.
pub fn ruby_test_runner_formula_l37_d7_linux_only(wrapper TestRunnerFormula) bool {
	return wrapper.linux_only()
}

// Ruby method `linux_compatible?` at line 42.
pub fn ruby_test_runner_formula_l42_d8_linux_compatible(wrapper TestRunnerFormula) bool {
	return wrapper.linux_compatible()
}

// Ruby method `x86_64_only?` at line 47.
pub fn ruby_test_runner_formula_l47_d9_x86_64_only(wrapper TestRunnerFormula) bool {
	return wrapper.x86_64_only()
}

// Ruby method `x86_64_compatible?` at line 52.
pub fn ruby_test_runner_formula_l52_d10_x86_64_compatible(wrapper TestRunnerFormula) bool {
	return wrapper.x86_64_compatible()
}

// Ruby method `arm64_only?` at line 57.
pub fn ruby_test_runner_formula_l57_d11_arm64_only(wrapper TestRunnerFormula) bool {
	return wrapper.arm64_only()
}

// Ruby method `arm64_compatible?` at line 62.
pub fn ruby_test_runner_formula_l62_d12_arm64_compatible(wrapper TestRunnerFormula) bool {
	return wrapper.arm64_compatible()
}

// Ruby method `versioned_macos_requirement` at line 67.
pub fn ruby_test_runner_formula_l67_d13_versioned_macos_requirement(wrapper TestRunnerFormula) ?TestRunnerRequirement {
	return wrapper.versioned_macos_requirement()
}

// Ruby method `compatible_with?(macos_version)` at line 72.
pub fn ruby_test_runner_formula_l72_d14_compatible_with(wrapper TestRunnerFormula,
	macos_version string) bool {
	return wrapper.compatible_with(macos_version)
}

// Ruby method `dependents(platform:, arch:, macos_version:)` at line 87.
pub fn ruby_test_runner_formula_l87_d15_dependents(wrapper TestRunnerFormula,
	candidates []TestRunnerFormulaDefinition, system TestRunnerSystem) []TestRunnerFormula {
	return wrapper.dependents(candidates, system)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: class TestRunnerFormula
// 7:   sig { returns(String) }
// 8:   attr_reader :name
// 9:
// 10:   sig { returns(Formula) }
// 11:   attr_reader :formula
// 12:
// 13:   sig { returns(T::Boolean) }
// 14:   attr_reader :eval_all
// 15:
// 16:   sig { params(formula: Formula, eval_all: T::Boolean).void }
// 17:   def initialize(formula, eval_all: false)
// 18:     Formulary.enable_factory_cache!
// 19:     @formula = formula
// 20:     @name = T.let(formula.name, String)
// 21:     @dependent_hash = T.let({}, T::Hash[Symbol, T::Array[TestRunnerFormula]])
// 22:     @eval_all = eval_all
// 23:     freeze
// 24:   end
// 25:
// 26:   sig { returns(T::Boolean) }
// 27:   def macos_only?
// 28:     !linux_compatible?
// 29:   end
// 30:
// 31:   sig { returns(T::Boolean) }
// 32:   def macos_compatible?
// 33:     formula.supports_macos?
// 34:   end
// 35:
// 36:   sig { returns(T::Boolean) }
// 37:   def linux_only?
// 38:     !macos_compatible?
// 39:   end
// 40:
// 41:   sig { returns(T::Boolean) }
// 42:   def linux_compatible?
// 43:     formula.supports_linux?
// 44:   end
// 45:
// 46:   sig { returns(T::Boolean) }
// 47:   def x86_64_only?
// 48:     formula.requirements.any? { |r| r.is_a?(ArchRequirement) && (r.arch == :x86_64) }
// 49:   end
// 50:
// 51:   sig { returns(T::Boolean) }
// 52:   def x86_64_compatible?
// 53:     !arm64_only?
// 54:   end
// 55:
// 56:   sig { returns(T::Boolean) }
// 57:   def arm64_only?
// 58:     formula.requirements.any? { |r| r.is_a?(ArchRequirement) && (r.arch == :arm64) }
// 59:   end
// 60:
// 61:   sig { returns(T::Boolean) }
// 62:   def arm64_compatible?
// 63:     !x86_64_only?
// 64:   end
// 65:
// 66:   sig { returns(T.nilable(MacOSRequirement)) }
// 67:   def versioned_macos_requirement
// 68:     formula.requirements.find { |r| r.is_a?(MacOSRequirement) && r.version_specified? }
// 69:   end
// 70:
// 71:   sig { params(macos_version: MacOSVersion).returns(T::Boolean) }
// 72:   def compatible_with?(macos_version)
// 73:     # Assign to a variable to assist type-checking.
// 74:     requirement = versioned_macos_requirement
// 75:     return true if requirement.blank?
// 76:
// 77:     macos_version.public_send(requirement.comparator, requirement.version)
// 78:   end
// 79:
// 80:   sig {
// 81:     params(
// 82:       platform:      Symbol,
// 83:       arch:          Symbol,
// 84:       macos_version: T.nilable(Symbol),
// 85:     ).returns(T::Array[TestRunnerFormula])
// 86:   }
// 87:   def dependents(platform:, arch:, macos_version:)
// 88:     cache_key = :"#{platform}_#{arch}_#{macos_version}"
// 89:
// 90:     @dependent_hash[cache_key] ||= begin
// 91:       os = macos_version || platform
// 92:       arch = Homebrew::SimulateSystem.arch_symbols.fetch(arch)
// 93:
// 94:       Homebrew::SimulateSystem.with(os:, arch:) do
// 95:         (eval_all ? Formula.all(eval_all: true) : Formula.installed)
// 96:           .select { |candidate_f| candidate_f.deps.map(&:name).include?(name) }
// 97:           .map { |f| TestRunnerFormula.new(f, eval_all:) }
// 98:           .freeze
// 99:       end
// 100:     end
// 101:
// 102:     @dependent_hash.fetch(cache_key)
// 103:   end
// 104: end
