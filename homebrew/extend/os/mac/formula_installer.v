module mac

// Translated from Homebrew/brew `extend/os/mac/formula_installer.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn mac_fresh_install(developer bool, outdated_release bool, installed_on_request bool,
	any_version_installed bool) bool {
	return !developer && !outdated_release && (installed_on_request || !any_version_installed)
}

// Ruby method `fresh_install?(formula)` at line 12.
pub fn ruby_formula_installer_l12_d1_fresh_install(developer bool, outdated_release bool,
	installed_on_request bool, any_version_installed bool) bool {
	return mac_fresh_install(developer, outdated_release, installed_on_request, any_version_installed)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module FormulaInstaller
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::FormulaInstaller }
// 10:
// 11:       sig { params(formula: Formula).returns(T.nilable(T::Boolean)) }
// 12:       def fresh_install?(formula)
// 13:         !::Homebrew::EnvConfig.developer? && !OS::Mac.version.outdated_release? &&
// 14:           (installed_on_request? || !formula.any_version_installed?)
// 15:       end
// 16:     end
// 17:   end
// 18: end
// 19:
// 20: FormulaInstaller.prepend(OS::Mac::FormulaInstaller)
