module cmd

import ruby

// Translated from Homebrew/brew `cmd/autoremove.rb`.
pub struct AutoremoveFormula {
pub:
	name                 string
	installed            bool
	installed_on_request bool
}

pub struct AutoremoveResult {
pub:
	removed  []string
	retained []string
	dry_run  bool
	output   string
}

pub type AutoremoveRunner = fn (bool) !AutoremoveResult

pub fn autoremove_formulae(formulae []AutoremoveFormula, dry_run bool) AutoremoveResult {
	mut removed := []string{}
	mut retained := []string{}
	for formula in formulae {
		if !formula.installed {
			continue
		}
		if formula.installed_on_request {
			retained << formula.name
		} else {
			removed << formula.name
		}
	}
	verb := if dry_run { 'Would autoremove' } else { 'Autoremoving' }
	output := if removed.len > 0 { '${verb} ${removed.join(', ')}\n' } else { '' }
	return AutoremoveResult{
		removed: removed
		retained: retained
		dry_run: dry_run
		output: output
	}
}

pub fn run_autoremove_command(dry_run bool, runner AutoremoveRunner) !AutoremoveResult {
	return runner(dry_run)
}

fn autoremove_formula_from_value(value ruby.Value) AutoremoveFormula {
	return AutoremoveFormula{
		name: value.attributes['name'] or { value.as_string() }
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
		installed_on_request: (value.attributes['installed_on_request'] or { 'false' }) == 'true'
	}
}

pub fn autoremove_formula_to_value(formula AutoremoveFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':                 formula.name
		'installed':            formula.installed.str()
		'installed_on_request': formula.installed_on_request.str()
	})
}

pub fn autoremove_result_to_value(result AutoremoveResult) ruby.Value {
	return ruby.map_value({
		'removed':  ruby.string_array_value(result.removed)
		'retained': ruby.string_array_value(result.retained)
		'dry_run':  ruby.bool_value(result.dry_run)
		'output':   ruby.string_value(result.output)
	})
}
