module homebrew

import brew_runtime

// Translated from Homebrew/brew `test_runner_formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :name` at line 8.
pub fn ruby_test_runner_formula_l8_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :formula` at line 11.
pub fn ruby_test_runner_formula_l11_d2_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby attr_reader `attr_reader :eval_all` at line 14.
pub fn ruby_test_runner_formula_l14_d3_eval_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eval_all', ...args)
}

// Ruby method `initialize(formula, eval_all: false)` at line 17.
pub fn ruby_test_runner_formula_l17_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `macos_only?` at line 27.
pub fn ruby_test_runner_formula_l27_d5_macos_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_only?', ...args)
}

// Ruby method `macos_compatible?` at line 32.
pub fn ruby_test_runner_formula_l32_d6_macos_compatible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_compatible?', ...args)
}

// Ruby method `linux_only?` at line 37.
pub fn ruby_test_runner_formula_l37_d7_linux_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_only?', ...args)
}

// Ruby method `linux_compatible?` at line 42.
pub fn ruby_test_runner_formula_l42_d8_linux_compatible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_compatible?', ...args)
}

// Ruby method `x86_64_only?` at line 47.
pub fn ruby_test_runner_formula_l47_d9_x86_64_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64_only?', ...args)
}

// Ruby method `x86_64_compatible?` at line 52.
pub fn ruby_test_runner_formula_l52_d10_x86_64_compatible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64_compatible?', ...args)
}

// Ruby method `arm64_only?` at line 57.
pub fn ruby_test_runner_formula_l57_d11_arm64_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm64_only?', ...args)
}

// Ruby method `arm64_compatible?` at line 62.
pub fn ruby_test_runner_formula_l62_d12_arm64_compatible(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm64_compatible?', ...args)
}

// Ruby method `versioned_macos_requirement` at line 67.
pub fn ruby_test_runner_formula_l67_d13_versioned_macos_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_macos_requirement', ...args)
}

// Ruby method `compatible_with?(macos_version)` at line 72.
pub fn ruby_test_runner_formula_l72_d14_compatible_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compatible_with?', ...args)
}

// Ruby method `dependents(platform:, arch:, macos_version:)` at line 87.
pub fn ruby_test_runner_formula_l87_d15_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependents', ...args)
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
