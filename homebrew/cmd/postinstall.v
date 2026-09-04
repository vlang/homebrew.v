module cmd

import ruby

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

pub fn postinstall_formula_to_value(formula PostinstallFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':                       formula.name
		'post_install_steps_defined': formula.post_install_steps_defined.str()
		'post_install_defined':       formula.post_install_defined.str()
	})
}

fn postinstall_formula_from_value(value ruby.Value) PostinstallFormula {
	return PostinstallFormula{
		name: value.attributes['name'] or { value.as_string() }
		post_install_steps_defined: (value.attributes['post_install_steps_defined'] or { 'false' }) == 'true'
		post_install_defined: (value.attributes['post_install_defined'] or { 'false' }) == 'true'
	}
}

pub fn postinstall_result_to_value(result PostinstallResult) ruby.Value {
	return ruby.map_value({
		'actions':  ruby.string_array_value(result.actions)
		'warnings': ruby.string_array_value(result.warnings)
	})
}
