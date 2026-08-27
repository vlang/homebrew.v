module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/sh.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 31.
pub fn ruby_sh_l31_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Bundle < Homebrew::AbstractCommand
// 9:       class ShSubcommand < Homebrew::AbstractSubcommand
// 10:         subcommand_args do
// 11:           usage_banner <<~EOS
// 12:             `brew bundle sh` [`--check`] [`--no-secrets`]:
// 13:             Run your shell in a `brew bundle exec` environment.
// 14:           EOS
// 15:           named_args :none
// 16:           switch "--install",
// 17:                  description: "Run `install` before starting the shell."
// 18:           switch "--services",
// 19:                  description: "Temporarily start services while running the shell.",
// 20:                  env:         :bundle_services
// 21:           switch "--check",
// 22:                  description: "Check that all dependencies in the Brewfile are installed before " \
// 23:                               "starting the shell.",
// 24:                  env:         :bundle_check
// 25:           switch "--no-secrets",
// 26:                  description: "Attempt to remove secrets from the environment before starting the shell.",
// 27:                  env:         :bundle_no_secrets
// 28:         end
// 29:
// 30:         sig { override.void }
// 31:         def run
// 32:           ExecSubcommand.run_command("sh", args:, context:)
// 33:         end
// 34:       end
// 35:     end
// 36:   end
// 37: end
