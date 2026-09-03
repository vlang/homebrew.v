module subcommand

import brew_runtime

// Translated from Homebrew/brew `services/subcommand/kill.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 22.
pub fn ruby_kill_l22_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	request := service_subcommand_request_from_args(args) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := service_simple_operation('kill', request) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return service_subcommand_result_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "services/cli"
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Services < Homebrew::AbstractCommand
// 10:       class KillSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args aliases: ["k"] do
// 12:           usage_banner <<~EOS
// 13:             [`sudo`] `brew services kill` (<formula>|`--all`):
// 14:             Stop the service <formula> immediately but keep it registered to launch at login (or boot).
// 15:           EOS
// 16:           named_args :service
// 17:           switch "--all",
// 18:                  description: "Stop all services immediately but keep them registered to launch at login (or boot)."
// 19:         end
// 20:
// 21:         sig { override.void }
// 22:         def run
// 23:           Homebrew::Services::Cli.check!(targets)
// 24:           Homebrew::Services::Cli.kill(targets, verbose: args.verbose?)
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
