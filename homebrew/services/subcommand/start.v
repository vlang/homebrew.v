module subcommand

import ruby

// Translated from Homebrew/brew `services/subcommand/start.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 24.
pub fn ruby_start_l24_d1_run(args ...ruby.Value) ruby.Value {
	request := service_subcommand_request_from_args(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := service_simple_operation('start', request) or {
		return ruby.object_value('UsageError', err.msg())
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
// 10:       class StartSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args aliases: %w[launch load s l] do
// 12:           usage_banner <<~EOS
// 13:             [`sudo`] `brew services start` (<formula>|`--all`) [`--file=`]:
// 14:             Start the service <formula> immediately and register it to launch at login (or boot).
// 15:           EOS
// 16:           named_args :service
// 17:           flag "--file=",
// 18:                description: "Use the service file from this location to `start` the service."
// 19:           switch "--all",
// 20:                  description: "Start all services and register them to launch at login (or boot)."
// 21:         end
// 22:
// 23:         sig { override.void }
// 24:         def run
// 25:           Homebrew::Services::Cli.check!(targets)
// 26:           Homebrew::Services::Cli.start(targets, args.file, verbose: args.verbose?)
// 27:         end
// 28:       end
// 29:     end
// 30:   end
// 31: end
