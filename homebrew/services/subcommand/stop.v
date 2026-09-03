module subcommand

import brew_runtime

// Translated from Homebrew/brew `services/subcommand/stop.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 31.
pub fn ruby_stop_l31_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	request := service_subcommand_request_from_args(args) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := service_simple_operation('stop', request) or {
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
// 10:       class StopSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args aliases: %w[unload terminate term t u] do
// 12:           usage_banner <<~EOS
// 13:             [`sudo`] `brew services stop` [`--keep`] [`--no-wait`|`--max-wait=`] (<formula>|`--all`):
// 14:             Stop the service <formula> immediately and unregister it from launching at login (or boot),
// 15:             unless `--keep` is specified.
// 16:           EOS
// 17:           named_args :service
// 18:           flag   "--max-wait=",
// 19:                  description: "Wait at most this many seconds for `stop` to finish stopping a service. " \
// 20:                               "Defaults to 60. Set this to zero (0) seconds to wait indefinitely."
// 21:           switch "--no-wait",
// 22:                  description: "Don't wait for `stop` to finish stopping the service."
// 23:           switch "--keep",
// 24:                  description: "When stopped, don't unregister the service from launching at login (or boot)."
// 25:           switch "--all",
// 26:                  description: "Stop all services and unregister them from launching at login (or boot), " \
// 27:                               "unless `--keep` is specified."
// 28:         end
// 29:
// 30:         sig { override.void }
// 31:         def run
// 32:           Homebrew::Services::Cli.check!(targets)
// 33:           Homebrew::Services::Cli.stop(
// 34:             targets,
// 35:             verbose:  args.verbose?,
// 36:             no_wait:  args.no_wait?,
// 37:             max_wait: args.max_wait&.to_f || 60.0,
// 38:             keep:     args.keep?,
// 39:           )
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
