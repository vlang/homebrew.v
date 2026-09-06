module mac

import homebrew

pub fn mac_missing_formula_disallowed_reason(name string) homebrew.MissingFormulaReason {
	if name.to_lower() == 'xcode' {
		return homebrew.MissingFormulaReason{
			present: true
			text: 'Xcode can be installed from the App Store.\n'
		}
	}
	return homebrew.missing_formula_disallowed_reason(name)
}

pub fn mac_missing_formula_cask_reason(name string, silent bool, show_info bool,
	cask homebrew.MissingFormulaCask) homebrew.MissingFormulaReason {
	return homebrew.missing_formula_cask_reason(name, silent, show_info, cask)
}

pub fn mac_missing_formula_suggest_command(name string, command string,
	cask homebrew.MissingFormulaCask) homebrew.MissingFormulaReason {
	return homebrew.missing_formula_suggest_command(name, command, cask)
}

// Translated from Homebrew/brew `extend/os/mac/missing_formula.rb`.
