module subcommand

import brew_runtime

// Translated from Homebrew/brew `developer/subcommand/on.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 22.
pub fn ruby_on_l22_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "env_config"
// 6: require "settings"
// 7: require "utils/tty"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Developer < Homebrew::AbstractCommand
// 12:       class OnSubcommand < Homebrew::AbstractSubcommand
// 13:         subcommand_args do
// 14:           usage_banner <<~EOS
// 15:             `brew developer on`:
// 16:             Turn Homebrew's developer mode on.
// 17:           EOS
// 18:           named_args :none
// 19:         end
// 20:
// 21:         sig { override.void }
// 22:         def run
// 23:           Homebrew::Settings.write "devcmdrun", true
// 24:           return unless Homebrew::EnvConfig.update_to_tag?
// 25:
// 26:           puts "To fully enable developer mode, you must unset #{Tty.bold}HOMEBREW_UPDATE_TO_TAG#{Tty.reset}."
// 27:         end
// 28:       end
// 29:     end
// 30:   end
// 31: end
