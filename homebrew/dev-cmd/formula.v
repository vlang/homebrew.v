module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/formula.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn run_formula_command(formula_paths []string, cask_paths []string) !string {
	existing_formulae := formula_paths.filter(os.exists(it))
	if existing_formulae.len == 0 && cask_paths.any(os.exists(it)) {
		return error('Found casks but did not find formulae!')
	}
	return if existing_formulae.len == 0 { '' } else { '${existing_formulae.join('\n')}\n' }
}

// Ruby method `run` at line 19.
pub fn ruby_formula_l19_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula paths are required')
	}
	formula_paths := args[0].as_string_array() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	cask_paths := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return brew_runtime.string_value(run_formula_command(formula_paths, cask_paths) or {
		return brew_runtime.object_value('FatalError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class FormulaCmd < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Display the path where <formula> is located.
// 13:         EOS
// 14:
// 15:         named_args :formula, min: 1, without_api: true
// 16:       end
// 17:
// 18:       sig { override.void }
// 19:       def run
// 20:         formula_paths = args.named.to_paths(only: :formula).select(&:exist?)
// 21:         if formula_paths.blank? && args.named
// 22:                                        .to_paths(only: :cask)
// 23:                                        .any?(&:exist?)
// 24:           odie "Found casks but did not find formulae!"
// 25:         end
// 26:         formula_paths.each { puts it }
// 27:       end
// 28:     end
// 29:   end
// 30: end
