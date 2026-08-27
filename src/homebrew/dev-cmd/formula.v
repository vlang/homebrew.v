module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 19.
pub fn ruby_formula_l19_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
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
