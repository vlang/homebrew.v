module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/home.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 26.
pub fn ruby_home_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `name_of(formula_or_cask)` at line 45.
pub fn ruby_home_l45_d2_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name_of', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Home < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Open a <formula> or <cask>'s homepage in a browser, or open
// 13:           Homebrew's own homepage if no argument is provided.
// 14:         EOS
// 15:         switch "--formula", "--formulae",
// 16:                description: "Treat all named arguments as formulae."
// 17:         switch "--cask", "--casks",
// 18:                description: "Treat all named arguments as casks."
// 19:
// 20:         conflicts "--formula", "--cask"
// 21:
// 22:         named_args [:formula, :cask]
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         if args.no_named?
// 28:           exec_browser HOMEBREW_WWW
// 29:           return
// 30:         end
// 31:
// 32:         # to_formulae_and_casks is typed to possibly return Kegs (but won't without explicitly asking)
// 33:         formulae_or_casks = T.cast(args.named.to_formulae_and_casks, T::Array[T.any(Formula, Cask::Cask)])
// 34:         homepages = formulae_or_casks.map do |formula_or_cask|
// 35:           puts "Opening homepage for #{name_of(formula_or_cask)}"
// 36:           formula_or_cask.homepage
// 37:         end
// 38:
// 39:         exec_browser(*homepages)
// 40:       end
// 41:
// 42:       private
// 43:
// 44:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(String) }
// 45:       def name_of(formula_or_cask)
// 46:         if formula_or_cask.is_a? Formula
// 47:           "Formula #{formula_or_cask.name}"
// 48:         else
// 49:           "Cask #{formula_or_cask.token}"
// 50:         end
// 51:       end
// 52:     end
// 53:   end
// 54: end
