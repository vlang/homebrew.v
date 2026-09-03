module linux

// Translated from Homebrew/brew `extend/os/linux/formula_installer.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn linux_fresh_install(developer bool, installed_on_request bool,
	any_version_installed bool) bool {
	return !developer && (installed_on_request || !any_version_installed)
}

// Ruby method `fresh_install?(formula)` at line 6.
pub fn ruby_formula_installer_l6_d1_fresh_install(developer bool, installed_on_request bool,
	any_version_installed bool) bool {
	return linux_fresh_install(developer, installed_on_request, any_version_installed)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class FormulaInstaller
// 5:   sig { params(formula: Formula).returns(T.nilable(T::Boolean)) }
// 6:   def fresh_install?(formula)
// 7:     !Homebrew::EnvConfig.developer? &&
// 8:       (installed_on_request? || !formula.any_version_installed?)
// 9:   end
// 10: end
