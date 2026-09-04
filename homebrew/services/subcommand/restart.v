module subcommand

import ruby

// Translated from Homebrew/brew `services/subcommand/restart.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 24.
pub fn ruby_restart_l24_d1_run(args ...ruby.Value) ruby.Value {
	request := service_subcommand_request_from_args(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := service_restart(request) or {
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
// 10:       class RestartSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args aliases: %w[relaunch reload r] do
// 12:           usage_banner <<~EOS
// 13:             [`sudo`] `brew services restart` (<formula>|`--all`) [`--file=`]:
// 14:             Stop (if necessary) and start the service <formula> immediately and register it to launch at login (or boot).
// 15:           EOS
// 16:           named_args :service
// 17:           flag "--file=",
// 18:                description: "Use the service file from this location to `start` the service."
// 19:           switch "--all",
// 20:                  description: "Restart all services."
// 21:         end
// 22:
// 23:         sig { override.void }
// 24:         def run
// 25:           Homebrew::Services::Cli.check!(targets)
// 26:
// 27:           ran = []
// 28:           started = []
// 29:           targets.each do |service|
// 30:             if service.loaded? && !service.service_file_present?
// 31:               ran << service
// 32:             else
// 33:               # group not-started services with started ones for restart
// 34:               started << service
// 35:             end
// 36:             Homebrew::Services::Cli.stop([service], verbose: args.verbose?) if service.loaded?
// 37:           end
// 38:
// 39:           Homebrew::Services::Cli.run(targets, args.file, verbose: args.verbose?) if ran.present?
// 40:           Homebrew::Services::Cli.start(started, args.file, verbose: args.verbose?) if started.present?
// 41:         end
// 42:
// 43:         # NOTE: The restart command is used to update service files
// 44:         # after a package gets updated through `brew upgrade`.
// 45:         # This works by removing the old file with `brew services stop`
// 46:         # and installing the new one with `brew services start|run`.
// 47:       end
// 48:     end
// 49:   end
// 50: end
