module subcommand

// Translated from Homebrew/brew `developer/subcommand/state.rb`.
// The original source is retained below until every stub has a typed V body.

// DeveloperState is the process-independent form of EnvConfig's three inputs
// used by the developer subcommands. Keeping the setting mutable models the
// devcmdrun Settings.write/delete calls without hiding state in globals.
pub struct DeveloperState {
pub mut:
	developer_environment bool
	devcmdrun             bool
	update_to_tag         bool
}

// Ruby method `run` at line 21.
pub fn ruby_state_l21_d1_run(state DeveloperState) string {
	mut lines := []string{}
	if state.developer_environment {
		lines << 'Developer mode is enabled because HOMEBREW_DEVELOPER is set.'
	} else if state.devcmdrun {
		lines << 'Developer mode is enabled because a developer command or `brew developer on` was run.'
	} else {
		lines << 'Developer mode is disabled.'
	}

	if state.developer_environment || state.devcmdrun {
		if state.update_to_tag {
			lines << 'However, `brew update` will update to the latest stable tag because HOMEBREW_UPDATE_TO_TAG is set.'
		} else {
			lines << '`brew update` will update to the latest commit on the `main` branch.'
		}
	} else {
		lines << '`brew update` will update to the latest stable tag.'
	}
	return lines.join('\n') + '\n'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "env_config"
// 6: require "utils/tty"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Developer < Homebrew::AbstractCommand
// 11:       class StateSubcommand < Homebrew::AbstractSubcommand
// 12:         subcommand_args default: true do
// 13:           usage_banner <<~EOS
// 14:             `brew developer` [`state`]:
// 15:             Display the current state of Homebrew's developer mode.
// 16:           EOS
// 17:           named_args :none
// 18:         end
// 19:
// 20:         sig { override.void }
// 21:         def run
// 22:           if Homebrew::EnvConfig.developer?
// 23:             puts "Developer mode is enabled because #{Tty.bold}HOMEBREW_DEVELOPER#{Tty.reset} is set."
// 24:           elsif Homebrew::EnvConfig.devcmdrun?
// 25:             puts "Developer mode is enabled because a developer command or `brew developer on` was run."
// 26:           else
// 27:             puts "Developer mode is disabled."
// 28:           end
// 29:
// 30:           if Homebrew::EnvConfig.developer? || Homebrew::EnvConfig.devcmdrun?
// 31:             if Homebrew::EnvConfig.update_to_tag?
// 32:               puts "However, `brew update` will update to the latest stable tag because " \
// 33:                    "#{Tty.bold}HOMEBREW_UPDATE_TO_TAG#{Tty.reset} is set."
// 34:             else
// 35:               puts "`brew update` will update to the latest commit on the `main` branch."
// 36:             end
// 37:           else
// 38:             puts "`brew update` will update to the latest stable tag."
// 39:           end
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
