module cmd

// Translated from Homebrew/brew `cmd/formulae.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaListing {
pub:
	full_name string
	name      string
}

pub fn formula_lines(formulae []FormulaListing) []string {
	mut lines := []string{cap: formulae.len * 2}
	for formula in formulae {
		lines << formula.full_name
		lines << formula.name
	}
	return sorted_distinct_strings(lines)
}

// Ruby method `run` at line 15.
pub fn ruby_formulae_l15_d1_run(formulae []FormulaListing) []string {
	return formula_lines(formulae)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Formulae < AbstractCommand
// 9:       # Used when the Bash implementation falls back to Ruby for tap trust filtering.
// 10:       cmd_args do
// 11:         description "List all locally installable formulae including short names."
// 12:       end
// 13:
// 14:       sig { override.void }
// 15:       def run
// 16:         require "formula"
// 17:
// 18:         puts Formula.all(eval_all: true).flat_map { |formula| [formula.full_name, formula.name] }.uniq.sort
// 19:       end
// 20:     end
// 21:   end
// 22: end
