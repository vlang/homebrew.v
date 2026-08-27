module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/formula_installer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fresh_install?(formula)` at line 6.
pub fn ruby_formula_installer_l6_d1_fresh_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fresh_install?', ...args)
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
