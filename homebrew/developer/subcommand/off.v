module subcommand

// Translated from Homebrew/brew `developer/subcommand/off.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 22.
pub fn disable_developer_mode(mut state DeveloperState) string {
	state.devcmdrun = false
	if state.developer_environment {
		return 'To fully disable developer mode, you must unset HOMEBREW_DEVELOPER.\n'
	}
	return ''
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
// 12:       class OffSubcommand < Homebrew::AbstractSubcommand
// 13:         subcommand_args do
// 14:           usage_banner <<~EOS
// 15:             `brew developer off`:
// 16:             Turn Homebrew's developer mode off.
// 17:           EOS
// 18:           named_args :none
// 19:         end
// 20:
// 21:         sig { override.void }
// 22:         def run
// 23:           Homebrew::Settings.delete "devcmdrun"
// 24:           return unless Homebrew::EnvConfig.developer?
// 25:
// 26:           puts "To fully disable developer mode, you must unset #{Tty.bold}HOMEBREW_DEVELOPER#{Tty.reset}."
// 27:         end
// 28:       end
// 29:     end
// 30:   end
// 31: end
