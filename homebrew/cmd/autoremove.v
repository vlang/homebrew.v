module cmd

import ruby

// Translated from Homebrew/brew `cmd/autoremove.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type AutoremoveRunner = fn(bool) !AutoremoveResult

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

// Ruby method `run` at line 21.
pub fn ruby_autoremove_l21_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return autoremove_result_to_value(autoremove_formulae([]AutoremoveFormula{}, false))
	}
	options := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	dry_run := if value := options['dry_run'] { value.as_bool() or { false } } else { false }
	formula_values := if value := options['formulae'] {
		value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return autoremove_result_to_value(autoremove_formulae(formula_values.map(autoremove_formula_from_value(it)), dry_run))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cleanup"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Autoremove < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Uninstall formulae that were only installed as a dependency of another formula and are now no longer needed.
// 13:         EOS
// 14:         switch "-n", "--dry-run",
// 15:                description: "List what would be uninstalled, but do not actually uninstall anything."
// 16:
// 17:         named_args :none
// 18:       end
// 19:
// 20:       sig { override.void }
// 21:       def run
// 22:         Cleanup.autoremove(dry_run: args.dry_run?)
// 23:       end
// 24:     end
// 25:   end
// 26: end
