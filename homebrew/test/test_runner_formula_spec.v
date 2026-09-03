module test

import homebrew

// Translated from Homebrew/brew `test/test_runner_formula_spec.rb`.
fn test_runner_spec_setup_formula(name string, dependencies []string,
	rules []homebrew.TestRunnerDependencyRule) homebrew.TestRunnerFormulaDefinition {
	mut requirements := []homebrew.TestRunnerRequirement{}
	mut formula_dependencies := []string{}
	mut supports_macos := true
	mut supports_linux := true
	for dependency in dependencies {
		match dependency {
			'macos' {
				requirements << homebrew.TestRunnerRequirement{ kind: .macos }
				supports_linux = false
			}
			'linux' {
				requirements << homebrew.TestRunnerRequirement{ kind: .linux }
				supports_macos = false
			}
			'x86_64', 'arm64' {
				requirements << homebrew.TestRunnerRequirement{
					kind: .arch
					arch: dependency
				}
			}
			else { formula_dependencies << dependency }
		}
	}
	for rule in rules {
		if rule.name == 'macos:ventura' {
			requirements << homebrew.TestRunnerRequirement{
				kind: .macos
				version: '13'
				version_specified: true
			}
			supports_linux = false
		}
	}
	return homebrew.TestRunnerFormulaDefinition{
		name: name
		supports_macos: supports_macos
		supports_linux: supports_linux
		requirements: requirements
		dependencies: formula_dependencies
		conditional_deps: rules.filter(it.name != 'macos:ventura')
	}
}

fn test_runner_spec_wrap(formula homebrew.TestRunnerFormulaDefinition) homebrew.TestRunnerFormula {
	return homebrew.new_test_runner_formula(formula, false)
}

// Ruby let `let(:testball) { Testball.new }` at line 8.
pub fn ruby_test_runner_formula_spec_l8_d1_testball() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball', [], [])
}

// Ruby let `let(:xcode_helper) { setup_test_runner_formula("xcode-helper", [:macos]) }` at line 9.
pub fn ruby_test_runner_formula_spec_l9_d2_xcode_helper() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('xcode-helper', ['macos'], [])
}

// Ruby let `let(:linux_kernel_requirer) { setup_test_runner_formula("linux-kernel-requirer", [:linux]) }` at line 10.
pub fn ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('linux-kernel-requirer', ['linux'], [])
}

// Ruby let `let(:old_non_portable_software) { setup_test_runner_formula("old-non-portable-software", [{ arch: :x86_64 }]) }` at line 11.
pub fn ruby_test_runner_formula_spec_l11_d4_old_non_portable_software() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('old-non-portable-software', ['x86_64'], [])
}

// Ruby let `let(:fancy_new_software) { setup_test_runner_formula("fancy-new-software", [{ arch: :arm64 }]) }` at line 12.
pub fn ruby_test_runner_formula_spec_l12_d5_fancy_new_software() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('fancy-new-software', ['arm64'], [])
}

// Ruby let `let(:needs_modern_compiler) { setup_test_runner_formula("needs-modern-compiler", [{ macos: :ventura }]) }` at line 13.
pub fn ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('needs-modern-compiler', [], [
		homebrew.TestRunnerDependencyRule{ name: 'macos:ventura' },
	])
}

// Ruby it `it "enables the Formulary factory cache" do` at line 16.
pub fn ruby_test_runner_formula_spec_l16_d7_enables() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l8_d1_testball()).factory_cache_enabled
}

// Ruby it `it "returns the wrapped Formula's name" do` at line 23.
pub fn ruby_test_runner_formula_spec_l23_d8_returns() bool {
	formula := ruby_test_runner_formula_spec_l8_d1_testball()
	return test_runner_spec_wrap(formula).name == formula.name
}

// Ruby specify `specify do` at line 29.
pub fn ruby_test_runner_formula_spec_l29_d9_do() bool {
	formula := ruby_test_runner_formula_spec_l8_d1_testball()
	return !homebrew.new_test_runner_formula(formula, false).eval_all && homebrew.new_test_runner_formula(formula, true).eval_all
}

// Ruby it `it "returns the wrapped Formula" do` at line 36.
pub fn ruby_test_runner_formula_spec_l36_d10_returns() bool {
	formula := ruby_test_runner_formula_spec_l8_d1_testball()
	return test_runner_spec_wrap(formula).formula == formula
}

// Ruby it `it "returns true" do` at line 43.
pub fn ruby_test_runner_formula_spec_l43_d11_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l9_d2_xcode_helper()).macos_only()
}

// Ruby it `it "returns false" do` at line 49.
pub fn ruby_test_runner_formula_spec_l49_d12_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software()] {
		if test_runner_spec_wrap(formula).macos_only() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 58.
pub fn ruby_test_runner_formula_spec_l58_d13_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).macos_only()
}

// Ruby it `it "returns true" do` at line 66.
pub fn ruby_test_runner_formula_spec_l66_d14_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software()] {
		if !test_runner_spec_wrap(formula).macos_compatible() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false" do` at line 75.
pub fn ruby_test_runner_formula_spec_l75_d15_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).macos_compatible()
}

// Ruby it `it "returns false" do` at line 81.
pub fn ruby_test_runner_formula_spec_l81_d16_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer()).macos_compatible()
}

// Ruby it `it "returns true" do` at line 89.
pub fn ruby_test_runner_formula_spec_l89_d17_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer()).linux_only()
}

// Ruby it `it "returns false" do` at line 95.
pub fn ruby_test_runner_formula_spec_l95_d18_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if test_runner_spec_wrap(formula).linux_only() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 107.
pub fn ruby_test_runner_formula_spec_l107_d19_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software()] {
		if !test_runner_spec_wrap(formula).linux_compatible() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false" do` at line 116.
pub fn ruby_test_runner_formula_spec_l116_d20_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l9_d2_xcode_helper()).linux_compatible() && !test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).linux_compatible()
}

// Ruby it `it "returns true" do` at line 125.
pub fn ruby_test_runner_formula_spec_l125_d21_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l11_d4_old_non_portable_software()).x86_64_only()
}

// Ruby it `it "returns false" do` at line 131.
pub fn ruby_test_runner_formula_spec_l131_d22_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l12_d5_fancy_new_software()).x86_64_only()
}

// Ruby it `it "returns false" do` at line 137.
pub fn ruby_test_runner_formula_spec_l137_d23_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if test_runner_spec_wrap(formula).x86_64_only() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 148.
pub fn ruby_test_runner_formula_spec_l148_d24_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if !test_runner_spec_wrap(formula).x86_64_compatible() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false" do` at line 158.
pub fn ruby_test_runner_formula_spec_l158_d25_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l12_d5_fancy_new_software()).x86_64_compatible()
}

// Ruby it `it "returns true" do` at line 166.
pub fn ruby_test_runner_formula_spec_l166_d26_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l12_d5_fancy_new_software()).arm64_only()
}

// Ruby it `it "returns false" do` at line 172.
pub fn ruby_test_runner_formula_spec_l172_d27_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l11_d4_old_non_portable_software()).arm64_only()
}

// Ruby it `it "returns false" do` at line 178.
pub fn ruby_test_runner_formula_spec_l178_d28_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if test_runner_spec_wrap(formula).arm64_only() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 189.
pub fn ruby_test_runner_formula_spec_l189_d29_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if !test_runner_spec_wrap(formula).arm64_compatible() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false" do` at line 199.
pub fn ruby_test_runner_formula_spec_l199_d30_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l11_d4_old_non_portable_software()).arm64_compatible()
}

// Ruby let `let(:requirement) { described_class.new(needs_modern_compiler).versioned_macos_requirement }` at line 206.
pub fn ruby_test_runner_formula_spec_l206_d31_requirement() ?homebrew.TestRunnerRequirement {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).versioned_macos_requirement()
}

// Ruby it `it "returns a MacOSRequirement with a specified version" do` at line 208.
pub fn ruby_test_runner_formula_spec_l208_d32_returns() bool {
	requirement := ruby_test_runner_formula_spec_l206_d31_requirement() or { return false }
	return requirement.kind == .macos && requirement.version_specified && requirement.version == '13'
}

// Ruby it `it "returns nil" do` at line 214.
pub fn ruby_test_runner_formula_spec_l214_d33_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l9_d2_xcode_helper()).versioned_macos_requirement() == none
}

// Ruby it `it "returns nil" do` at line 220.
pub fn ruby_test_runner_formula_spec_l220_d34_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software()] {
		if test_runner_spec_wrap(formula).versioned_macos_requirement() != none {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 232.
pub fn ruby_test_runner_formula_spec_l232_d35_returns() bool {
	return test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).compatible_with('13')
}

// Ruby it `it "returns false" do` at line 239.
pub fn ruby_test_runner_formula_spec_l239_d36_returns() bool {
	return !test_runner_spec_wrap(ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()).compatible_with('11')
}

// Ruby it `it "returns true" do` at line 247.
pub fn ruby_test_runner_formula_spec_l247_d37_returns() bool {
	for version in ['10.15', '11', '12', '13', '14', '15'] {
		if !test_runner_spec_wrap(ruby_test_runner_formula_spec_l9_d2_xcode_helper()).compatible_with(version) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns true" do` at line 256.
pub fn ruby_test_runner_formula_spec_l256_d38_returns() bool {
	for version in ['10.15', '11', '12', '13', '14', '15'] {
		for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
			ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
			ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
			ruby_test_runner_formula_spec_l12_d5_fancy_new_software()] {
			if !test_runner_spec_wrap(formula).compatible_with(version) {
				return false
			}
		}
	}
	return true
}

// Ruby let `let(:current_system) do` at line 269.
pub fn ruby_test_runner_formula_spec_l269_d39_current_system() homebrew.TestRunnerSystem {
	return homebrew.TestRunnerSystem{ platform: 'linux', arch: 'x86_64' }
}

// Ruby it `it "returns an empty array" do` at line 288.
pub fn ruby_test_runner_formula_spec_l288_d40_returns() bool {
	for formula in [ruby_test_runner_formula_spec_l8_d1_testball(),
		ruby_test_runner_formula_spec_l9_d2_xcode_helper(),
		ruby_test_runner_formula_spec_l10_d3_linux_kernel_requirer(),
		ruby_test_runner_formula_spec_l11_d4_old_non_portable_software(),
		ruby_test_runner_formula_spec_l12_d5_fancy_new_software(),
		ruby_test_runner_formula_spec_l13_d6_needs_modern_compiler()] {
		if test_runner_spec_wrap(formula).dependents([], ruby_test_runner_formula_spec_l269_d39_current_system()).len != 0 {
			return false
		}
	}
	return true
}

// Ruby let `let(:testball_user) { setup_test_runner_formula("testball_user", ["testball"]) }` at line 299.
pub fn ruby_test_runner_formula_spec_l299_d41_testball_user() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user', ['testball'], [])
}

// Ruby let `let(:recursive_testball_dependent) do` at line 300.
pub fn ruby_test_runner_formula_spec_l300_d42_recursive_testball_dependent() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('recursive_testball_dependent', [
		'testball_user',
	], [])
}

// Ruby it `it "returns an array of direct dependents" do` at line 304.
pub fn ruby_test_runner_formula_spec_l304_d43_returns() bool {
	candidates := [ruby_test_runner_formula_spec_l299_d41_testball_user(),
		ruby_test_runner_formula_spec_l300_d42_recursive_testball_dependent()]
	system := ruby_test_runner_formula_spec_l269_d39_current_system()
	testball_dependents := homebrew.new_test_runner_formula(ruby_test_runner_formula_spec_l8_d1_testball(), true).dependents(candidates, system).map(it.name)
	user_dependents := homebrew.new_test_runner_formula(ruby_test_runner_formula_spec_l299_d41_testball_user(), true).dependents(candidates, system).map(it.name)
	return testball_dependents == ['testball_user'] && user_dependents == [
		'recursive_testball_dependent',
	]
}

// Ruby let `let(:testball_user_intel) { setup_test_runner_formula("testball_user-intel", intel: ["testball"]) }` at line 318.
pub fn ruby_test_runner_formula_spec_l318_d44_testball_user_intel() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user-intel', [], [
		homebrew.TestRunnerDependencyRule{ name: 'testball', arch: 'x86_64' },
	])
}

// Ruby let `let(:testball_user_arm) { setup_test_runner_formula("testball_user-arm", arm: ["testball"]) }` at line 319.
pub fn ruby_test_runner_formula_spec_l319_d45_testball_user_arm() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user-arm', [], [
		homebrew.TestRunnerDependencyRule{ name: 'testball', arch: 'arm64' },
	])
}

// Ruby let `let(:testball_user_macos) { setup_test_runner_formula("testball_user-macos", macos: ["testball"]) }` at line 320.
pub fn ruby_test_runner_formula_spec_l320_d46_testball_user_macos() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user-macos', [], [
		homebrew.TestRunnerDependencyRule{ name: 'testball', platform: 'macos' },
	])
}

// Ruby let `let(:testball_user_linux) { setup_test_runner_formula("testball_user-linux", linux: ["testball"]) }` at line 321.
pub fn ruby_test_runner_formula_spec_l321_d47_testball_user_linux() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user-linux', [], [
		homebrew.TestRunnerDependencyRule{ name: 'testball', platform: 'linux' },
	])
}

// Ruby let `let(:testball_user_ventura) do` at line 322.
pub fn ruby_test_runner_formula_spec_l322_d48_testball_user_ventura() homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula('testball_user-ventura', [], [
		homebrew.TestRunnerDependencyRule{ name: 'testball', platform: 'macos', macos_version: 'ventura' },
	])
}

// Ruby let `let(:testball_and_dependents) do` at line 325.
pub fn ruby_test_runner_formula_spec_l325_d49_testball_and_dependents() []homebrew.TestRunnerFormulaDefinition {
	return [ruby_test_runner_formula_spec_l299_d41_testball_user(),
		ruby_test_runner_formula_spec_l318_d44_testball_user_intel(),
		ruby_test_runner_formula_spec_l319_d45_testball_user_arm(),
		ruby_test_runner_formula_spec_l320_d46_testball_user_macos(),
		ruby_test_runner_formula_spec_l321_d47_testball_user_linux(),
		ruby_test_runner_formula_spec_l322_d48_testball_user_ventura()]
}

fn test_runner_spec_dependent_names(system homebrew.TestRunnerSystem) []string {
	mut names := homebrew.new_test_runner_formula(ruby_test_runner_formula_spec_l8_d1_testball(), true).dependents(ruby_test_runner_formula_spec_l325_d49_testball_and_dependents(), system).map(it.name)
	names.sort()
	return names
}

// Ruby it `it "returns only the dependents for the requested platform and architecture" do` at line 337.
pub fn ruby_test_runner_formula_spec_l337_d50_returns() bool {
	return test_runner_spec_dependent_names(homebrew.TestRunnerSystem{ platform: 'linux', arch: 'x86_64' }) == [
		'testball_user',
		'testball_user-intel',
		'testball_user-linux',
	]
}

// Ruby it `it "returns only the dependents for the requested platform and architecture" do` at line 349.
pub fn ruby_test_runner_formula_spec_l349_d51_returns() bool {
	return test_runner_spec_dependent_names(homebrew.TestRunnerSystem{ platform: 'macos', arch: 'x86_64' }) == [
		'testball_user',
		'testball_user-intel',
		'testball_user-macos',
	]
}

// Ruby it `it "returns only the dependents for the requested platform and architecture" do` at line 361.
pub fn ruby_test_runner_formula_spec_l361_d52_returns() bool {
	return test_runner_spec_dependent_names(homebrew.TestRunnerSystem{ platform: 'macos', arch: 'arm64' }) == [
		'testball_user',
		'testball_user-arm',
		'testball_user-macos',
	]
}

// Ruby it `it "returns only the dependents for the requested platform and architecture" do` at line 373.
pub fn ruby_test_runner_formula_spec_l373_d53_returns() bool {
	return test_runner_spec_dependent_names(homebrew.TestRunnerSystem{ platform: 'macos', arch: 'x86_64', macos_version: 'sonoma' }) == [
		'testball_user',
		'testball_user-intel',
		'testball_user-macos',
	]
}

// Ruby it `it "returns only the dependents for the requested platform and architecture" do` at line 385.
pub fn ruby_test_runner_formula_spec_l385_d54_returns() bool {
	return test_runner_spec_dependent_names(homebrew.TestRunnerSystem{ platform: 'macos', arch: 'arm64', macos_version: 'ventura' }) == [
		'testball_user',
		'testball_user-arm',
		'testball_user-macos',
		'testball_user-ventura',
	]
}

// Ruby method `setup_test_runner_formula(name, dependencies = [], **kwargs)` at line 399.
pub fn ruby_test_runner_formula_spec_l399_d55_setup_test_runner_formula(name string,
	dependencies []string, rules []homebrew.TestRunnerDependencyRule) homebrew.TestRunnerFormulaDefinition {
	return test_runner_spec_setup_formula(name, dependencies, rules)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_runner_formula"
// 5: require "test/support/fixtures/testball"
// 6:
// 7: RSpec.describe TestRunnerFormula do
// 8:   let(:testball) { Testball.new }
// 9:   let(:xcode_helper) { setup_test_runner_formula("xcode-helper", [:macos]) }
// 10:   let(:linux_kernel_requirer) { setup_test_runner_formula("linux-kernel-requirer", [:linux]) }
// 11:   let(:old_non_portable_software) { setup_test_runner_formula("old-non-portable-software", [{ arch: :x86_64 }]) }
// 12:   let(:fancy_new_software) { setup_test_runner_formula("fancy-new-software", [{ arch: :arm64 }]) }
// 13:   let(:needs_modern_compiler) { setup_test_runner_formula("needs-modern-compiler", [{ macos: :ventura }]) }
// 14:
// 15:   describe "#initialize" do
// 16:     it "enables the Formulary factory cache" do
// 17:       described_class.new(testball)
// 18:       expect(Formulary.factory_cached?).to be(true)
// 19:     end
// 20:   end
// 21:
// 22:   describe "#name" do
// 23:     it "returns the wrapped Formula's name" do
// 24:       expect(described_class.new(testball).name).to eq(testball.name)
// 25:     end
// 26:   end
// 27:
// 28:   describe "#eval_all" do
// 29:     specify do
// 30:       expect(described_class.new(testball).eval_all).to be(false)
// 31:       expect(described_class.new(testball, eval_all: true).eval_all).to be(true)
// 32:     end
// 33:   end
// 34:
// 35:   describe "#formula" do
// 36:     it "returns the wrapped Formula" do
// 37:       expect(described_class.new(testball).formula).to eq(testball)
// 38:     end
// 39:   end
// 40:
// 41:   describe "#macos_only?" do
// 42:     context "when a formula requires macOS" do
// 43:       it "returns true" do
// 44:         expect(described_class.new(xcode_helper).macos_only?).to be(true)
// 45:       end
// 46:     end
// 47:
// 48:     context "when a formula does not require macOS" do
// 49:       it "returns false" do
// 50:         expect(described_class.new(testball).macos_only?).to be(false)
// 51:         expect(described_class.new(linux_kernel_requirer).macos_only?).to be(false)
// 52:         expect(described_class.new(old_non_portable_software).macos_only?).to be(false)
// 53:         expect(described_class.new(fancy_new_software).macos_only?).to be(false)
// 54:       end
// 55:     end
// 56:
// 57:     context "when a formula requires only a minimum version of macOS" do
// 58:       it "returns true" do
// 59:         expect(described_class.new(needs_modern_compiler).macos_only?).to be(true)
// 60:       end
// 61:     end
// 62:   end
// 63:
// 64:   describe "#macos_compatible?" do
// 65:     context "when a formula is compatible with macOS" do
// 66:       it "returns true" do
// 67:         expect(described_class.new(testball).macos_compatible?).to be(true)
// 68:         expect(described_class.new(xcode_helper).macos_compatible?).to be(true)
// 69:         expect(described_class.new(old_non_portable_software).macos_compatible?).to be(true)
// 70:         expect(described_class.new(fancy_new_software).macos_compatible?).to be(true)
// 71:       end
// 72:     end
// 73:
// 74:     context "when a formula requires only a minimum version of macOS" do
// 75:       it "returns false" do
// 76:         expect(described_class.new(needs_modern_compiler).macos_compatible?).to be(true)
// 77:       end
// 78:     end
// 79:
// 80:     context "when a formula is not compatible with macOS" do
// 81:       it "returns false" do
// 82:         expect(described_class.new(linux_kernel_requirer).macos_compatible?).to be(false)
// 83:       end
// 84:     end
// 85:   end
// 86:
// 87:   describe "#linux_only?" do
// 88:     context "when a formula requires Linux" do
// 89:       it "returns true" do
// 90:         expect(described_class.new(linux_kernel_requirer).linux_only?).to be(true)
// 91:       end
// 92:     end
// 93:
// 94:     context "when a formula does not require Linux" do
// 95:       it "returns false" do
// 96:         expect(described_class.new(testball).linux_only?).to be(false)
// 97:         expect(described_class.new(xcode_helper).linux_only?).to be(false)
// 98:         expect(described_class.new(old_non_portable_software).linux_only?).to be(false)
// 99:         expect(described_class.new(fancy_new_software).linux_only?).to be(false)
// 100:         expect(described_class.new(needs_modern_compiler).linux_only?).to be(false)
// 101:       end
// 102:     end
// 103:   end
// 104:
// 105:   describe "#linux_compatible?" do
// 106:     context "when a formula is compatible with Linux" do
// 107:       it "returns true" do
// 108:         expect(described_class.new(testball).linux_compatible?).to be(true)
// 109:         expect(described_class.new(linux_kernel_requirer).linux_compatible?).to be(true)
// 110:         expect(described_class.new(old_non_portable_software).linux_compatible?).to be(true)
// 111:         expect(described_class.new(fancy_new_software).linux_compatible?).to be(true)
// 112:       end
// 113:     end
// 114:
// 115:     context "when a formula is not compatible with Linux" do
// 116:       it "returns false" do
// 117:         expect(described_class.new(xcode_helper).linux_compatible?).to be(false)
// 118:         expect(described_class.new(needs_modern_compiler).linux_compatible?).to be(false)
// 119:       end
// 120:     end
// 121:   end
// 122:
// 123:   describe "#x86_64_only?" do
// 124:     context "when a formula requires an Intel architecture" do
// 125:       it "returns true" do
// 126:         expect(described_class.new(old_non_portable_software).x86_64_only?).to be(true)
// 127:       end
// 128:     end
// 129:
// 130:     context "when a formula requires a non-Intel architecture" do
// 131:       it "returns false" do
// 132:         expect(described_class.new(fancy_new_software).x86_64_only?).to be(false)
// 133:       end
// 134:     end
// 135:
// 136:     context "when a formula does not require a specific architecture" do
// 137:       it "returns false" do
// 138:         expect(described_class.new(testball).x86_64_only?).to be(false)
// 139:         expect(described_class.new(xcode_helper).x86_64_only?).to be(false)
// 140:         expect(described_class.new(linux_kernel_requirer).x86_64_only?).to be(false)
// 141:         expect(described_class.new(needs_modern_compiler).x86_64_only?).to be(false)
// 142:       end
// 143:     end
// 144:   end
// 145:
// 146:   describe "#x86_64_compatible?" do
// 147:     context "when a formula is compatible with the Intel architecture" do
// 148:       it "returns true" do
// 149:         expect(described_class.new(testball).x86_64_compatible?).to be(true)
// 150:         expect(described_class.new(xcode_helper).x86_64_compatible?).to be(true)
// 151:         expect(described_class.new(linux_kernel_requirer).x86_64_compatible?).to be(true)
// 152:         expect(described_class.new(old_non_portable_software).x86_64_compatible?).to be(true)
// 153:         expect(described_class.new(needs_modern_compiler).x86_64_compatible?).to be(true)
// 154:       end
// 155:     end
// 156:
// 157:     context "when a formula is not compatible with the Intel architecture" do
// 158:       it "returns false" do
// 159:         expect(described_class.new(fancy_new_software).x86_64_compatible?).to be(false)
// 160:       end
// 161:     end
// 162:   end
// 163:
// 164:   describe "#arm64_only?" do
// 165:     context "when a formula requires an ARM64 architecture" do
// 166:       it "returns true" do
// 167:         expect(described_class.new(fancy_new_software).arm64_only?).to be(true)
// 168:       end
// 169:     end
// 170:
// 171:     context "when a formula requires a non-ARM64 architecture" do
// 172:       it "returns false" do
// 173:         expect(described_class.new(old_non_portable_software).arm64_only?).to be(false)
// 174:       end
// 175:     end
// 176:
// 177:     context "when a formula does not require a specific architecture" do
// 178:       it "returns false" do
// 179:         expect(described_class.new(testball).arm64_only?).to be(false)
// 180:         expect(described_class.new(xcode_helper).arm64_only?).to be(false)
// 181:         expect(described_class.new(linux_kernel_requirer).arm64_only?).to be(false)
// 182:         expect(described_class.new(needs_modern_compiler).arm64_only?).to be(false)
// 183:       end
// 184:     end
// 185:   end
// 186:
// 187:   describe "#arm64_compatible?" do
// 188:     context "when a formula is compatible with an ARM64 architecture" do
// 189:       it "returns true" do
// 190:         expect(described_class.new(testball).arm64_compatible?).to be(true)
// 191:         expect(described_class.new(xcode_helper).arm64_compatible?).to be(true)
// 192:         expect(described_class.new(linux_kernel_requirer).arm64_compatible?).to be(true)
// 193:         expect(described_class.new(fancy_new_software).arm64_compatible?).to be(true)
// 194:         expect(described_class.new(needs_modern_compiler).arm64_compatible?).to be(true)
// 195:       end
// 196:     end
// 197:
// 198:     context "when a formula is not compatible with an ARM64 architecture" do
// 199:       it "returns false" do
// 200:         expect(described_class.new(old_non_portable_software).arm64_compatible?).to be(false)
// 201:       end
// 202:     end
// 203:   end
// 204:
// 205:   describe "#versioned_macos_requirement" do
// 206:     let(:requirement) { described_class.new(needs_modern_compiler).versioned_macos_requirement }
// 207:
// 208:     it "returns a MacOSRequirement with a specified version" do
// 209:       expect(requirement).to be_a(MacOSRequirement)
// 210:       expect(requirement.version_specified?).to be(true)
// 211:     end
// 212:
// 213:     context "when a formula has an unversioned MacOSRequirement" do
// 214:       it "returns nil" do
// 215:         expect(described_class.new(xcode_helper).versioned_macos_requirement).to be_nil
// 216:       end
// 217:     end
// 218:
// 219:     context "when a formula has no declared MacOSRequirement" do
// 220:       it "returns nil" do
// 221:         expect(described_class.new(testball).versioned_macos_requirement).to be_nil
// 222:         expect(described_class.new(linux_kernel_requirer).versioned_macos_requirement).to be_nil
// 223:         expect(described_class.new(old_non_portable_software).versioned_macos_requirement).to be_nil
// 224:         expect(described_class.new(fancy_new_software).versioned_macos_requirement).to be_nil
// 225:       end
// 226:     end
// 227:   end
// 228:
// 229:   describe "#compatible_with?" do
// 230:     context "when a formula has a versioned MacOSRequirement" do
// 231:       context "when passed a compatible macOS version" do
// 232:         it "returns true" do
// 233:           expect(described_class.new(needs_modern_compiler).compatible_with?(MacOSVersion.new("13")))
// 234:             .to be(true)
// 235:         end
// 236:       end
// 237:
// 238:       context "when passed an incompatible macOS version" do
// 239:         it "returns false" do
// 240:           expect(described_class.new(needs_modern_compiler).compatible_with?(MacOSVersion.new("11")))
// 241:             .to be(false)
// 242:         end
// 243:       end
// 244:     end
// 245:
// 246:     context "when a formula has an unversioned MacOSRequirement" do
// 247:       it "returns true" do
// 248:         MacOSVersion::SYMBOLS.each_value do |v|
// 249:           version = MacOSVersion.new(v)
// 250:           expect(described_class.new(xcode_helper).compatible_with?(version)).to be(true)
// 251:         end
// 252:       end
// 253:     end
// 254:
// 255:     context "when a formula has no declared MacOSRequirement" do
// 256:       it "returns true" do
// 257:         MacOSVersion::SYMBOLS.each_value do |v|
// 258:           version = MacOSVersion.new(v)
// 259:           expect(described_class.new(testball).compatible_with?(version)).to be(true)
// 260:           expect(described_class.new(linux_kernel_requirer).compatible_with?(version)).to be(true)
// 261:           expect(described_class.new(old_non_portable_software).compatible_with?(version)).to be(true)
// 262:           expect(described_class.new(fancy_new_software).compatible_with?(version)).to be(true)
// 263:         end
// 264:       end
// 265:     end
// 266:   end
// 267:
// 268:   describe "#dependents" do
// 269:     let(:current_system) do
// 270:       current_arch = case Homebrew::SimulateSystem.current_arch
// 271:       when :arm then :arm64
// 272:       when :intel then :x86_64
// 273:       end
// 274:
// 275:       current_platform = case Homebrew::SimulateSystem.current_os
// 276:       when :generic then :linux
// 277:       else Homebrew::SimulateSystem.current_os
// 278:       end
// 279:
// 280:       {
// 281:         platform:      current_platform,
// 282:         arch:          current_arch,
// 283:         macos_version: nil,
// 284:       }
// 285:     end
// 286:
// 287:     context "when a formula has no dependents" do
// 288:       it "returns an empty array" do
// 289:         expect(described_class.new(testball).dependents(**current_system)).to eq([])
// 290:         expect(described_class.new(xcode_helper).dependents(**current_system)).to eq([])
// 291:         expect(described_class.new(linux_kernel_requirer).dependents(**current_system)).to eq([])
// 292:         expect(described_class.new(old_non_portable_software).dependents(**current_system)).to eq([])
// 293:         expect(described_class.new(fancy_new_software).dependents(**current_system)).to eq([])
// 294:         expect(described_class.new(needs_modern_compiler).dependents(**current_system)).to eq([])
// 295:       end
// 296:     end
// 297:
// 298:     context "when a formula has dependents" do
// 299:       let(:testball_user) { setup_test_runner_formula("testball_user", ["testball"]) }
// 300:       let(:recursive_testball_dependent) do
// 301:         setup_test_runner_formula("recursive_testball_dependent", ["testball_user"])
// 302:       end
// 303:
// 304:       it "returns an array of direct dependents" do
// 305:         allow(Formula).to receive(:all).with(eval_all: true)
// 306:                                        .and_return([testball_user, recursive_testball_dependent])
// 307:
// 308:         expect(
// 309:           described_class.new(testball, eval_all: true).dependents(**current_system).map(&:name),
// 310:         ).to eq(["testball_user"])
// 311:
// 312:         expect(
// 313:           described_class.new(testball_user, eval_all: true).dependents(**current_system).map(&:name),
// 314:         ).to eq(["recursive_testball_dependent"])
// 315:       end
// 316:
// 317:       context "when called with arguments" do
// 318:         let(:testball_user_intel) { setup_test_runner_formula("testball_user-intel", intel: ["testball"]) }
// 319:         let(:testball_user_arm) { setup_test_runner_formula("testball_user-arm", arm: ["testball"]) }
// 320:         let(:testball_user_macos) { setup_test_runner_formula("testball_user-macos", macos: ["testball"]) }
// 321:         let(:testball_user_linux) { setup_test_runner_formula("testball_user-linux", linux: ["testball"]) }
// 322:         let(:testball_user_ventura) do
// 323:           setup_test_runner_formula("testball_user-ventura", ventura: ["testball"])
// 324:         end
// 325:         let(:testball_and_dependents) do
// 326:           [
// 327:             testball_user,
// 328:             testball_user_intel,
// 329:             testball_user_arm,
// 330:             testball_user_macos,
// 331:             testball_user_linux,
// 332:             testball_user_ventura,
// 333:           ]
// 334:         end
// 335:
// 336:         context "when given { platform: :linux, arch: :x86_64 }" do
// 337:           it "returns only the dependents for the requested platform and architecture" do
// 338:             allow(Formula).to receive(:all).and_wrap_original { testball_and_dependents }
// 339:
// 340:             expect(
// 341:               described_class.new(testball, eval_all: true).dependents(
// 342:                 platform: :linux, arch: :x86_64, macos_version: nil,
// 343:               ).map(&:name).sort,
// 344:             ).to eq(["testball_user", "testball_user-intel", "testball_user-linux"].sort)
// 345:           end
// 346:         end
// 347:
// 348:         context "when given { platform: :macos, arch: :x86_64 }" do
// 349:           it "returns only the dependents for the requested platform and architecture" do
// 350:             allow(Formula).to receive(:all).and_wrap_original { testball_and_dependents }
// 351:
// 352:             expect(
// 353:               described_class.new(testball, eval_all: true).dependents(
// 354:                 platform: :macos, arch: :x86_64, macos_version: nil,
// 355:               ).map(&:name).sort,
// 356:             ).to eq(["testball_user", "testball_user-intel", "testball_user-macos"].sort)
// 357:           end
// 358:         end
// 359:
// 360:         context "when given `{ platform: :macos, arch: :arm64 }`" do
// 361:           it "returns only the dependents for the requested platform and architecture" do
// 362:             allow(Formula).to receive(:all).and_wrap_original { testball_and_dependents }
// 363:
// 364:             expect(
// 365:               described_class.new(testball, eval_all: true).dependents(
// 366:                 platform: :macos, arch: :arm64, macos_version: nil,
// 367:               ).map(&:name).sort,
// 368:             ).to eq(["testball_user", "testball_user-arm", "testball_user-macos"].sort)
// 369:           end
// 370:         end
// 371:
// 372:         context "when given `{ platform: :macos, arch: :x86_64, macos_version: :sonoma }`" do
// 373:           it "returns only the dependents for the requested platform and architecture" do
// 374:             allow(Formula).to receive(:all).and_wrap_original { testball_and_dependents }
// 375:
// 376:             expect(
// 377:               described_class.new(testball, eval_all: true).dependents(
// 378:                 platform: :macos, arch: :x86_64, macos_version: :sonoma,
// 379:               ).map(&:name).sort,
// 380:             ).to eq(["testball_user", "testball_user-intel", "testball_user-macos"].sort)
// 381:           end
// 382:         end
// 383:
// 384:         context "when given `{ platform: :macos, arch: :arm64, macos_version: :ventura }`" do
// 385:           it "returns only the dependents for the requested platform and architecture" do
// 386:             allow(Formula).to receive(:all).and_wrap_original { testball_and_dependents }
// 387:
// 388:             expect(
// 389:               described_class.new(testball, eval_all: true).dependents(
// 390:                 platform: :macos, arch: :arm64, macos_version: :ventura,
// 391:               ).map(&:name).sort,
// 392:             ).to eq(%w[testball_user testball_user-arm testball_user-macos testball_user-ventura].sort)
// 393:           end
// 394:         end
// 395:       end
// 396:     end
// 397:   end
// 398:
// 399:   def setup_test_runner_formula(name, dependencies = [], **kwargs)
// 400:     formula name do
// 401:       T.bind(self, T.class_of(Formula))
// 402:       url "https://brew.sh/#{name}-1.0.tar.gz"
// 403:       dependencies.each { |dependency| depends_on dependency }
// 404:
// 405:       kwargs.each do |k, v|
// 406:         public_send(:"on_#{k}") do
// 407:           v.each do |dep|
// 408:             depends_on dep
// 409:           end
// 410:         end
// 411:       end
// 412:     end
// 413:   end
// 414: end
