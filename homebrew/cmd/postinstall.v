module cmd

// Translated from Homebrew/brew `cmd/postinstall.rb`.
pub struct PostinstallFormula {
pub:
	name                       string
	post_install_steps_defined bool
	post_install_defined       bool
}

pub struct PostinstallOptions {
pub:
	debug   bool
	quiet   bool
	verbose bool
}

pub struct PostinstallResult {
pub:
	actions  []string
	warnings []string
}

pub fn run_postinstall_command(formulae []PostinstallFormula, options PostinstallOptions) PostinstallResult {
	mut actions := []string{}
	mut warnings := []string{}
	for formula in formulae {
		actions << 'Postinstalling ${formula.name}'
		actions << 'install_etc_var:${formula.name}'
		if formula.post_install_steps_defined || formula.post_install_defined {
			actions << 'FormulaInstaller.new:${formula.name}:debug=${options.debug}:quiet=${options.quiet}:verbose=${options.verbose}'
			actions << 'FormulaInstaller.post_install:${formula.name}'
		} else {
			warnings << '${formula.name}: no `post_install` method was defined in the formula!'
		}
	}
	return PostinstallResult{
		actions: actions
		warnings: warnings
	}
}
