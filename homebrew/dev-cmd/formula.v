module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/formula.rb`.
pub fn run_formula_command(formula_paths []string, cask_paths []string) !string {
	existing_formulae := formula_paths.filter(os.exists(it))
	if existing_formulae.len == 0 && cask_paths.any(os.exists(it)) {
		return error('Found casks but did not find formulae!')
	}
	return if existing_formulae.len == 0 { '' } else { '${existing_formulae.join('\n')}\n' }
}
