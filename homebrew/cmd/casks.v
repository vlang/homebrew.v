module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/casks.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 15.
pub fn ruby_casks_l15_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Casks < AbstractCommand
// 9:       # Used when the Bash implementation falls back to Ruby for tap trust filtering.
// 10:       cmd_args do
// 11:         description "List all locally installable casks including short names."
// 12:       end
// 13:
// 14:       sig { override.void }
// 15:       def run
// 16:         require "cask/cask"
// 17:
// 18:         puts Cask::Cask.all(eval_all: true).flat_map { |cask| [cask.full_name, cask.token] }.uniq.sort
// 19:       end
// 20:     end
// 21:   end
// 22: end
