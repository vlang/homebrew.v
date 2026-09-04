module analytics

import homebrew.analytics.subcommand
import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dispatch(args)` at line 16.
pub fn subcommand_dispatch(arguments []string, mut state utils.AnalyticsState) !string {
	if arguments.len > 1 {
		return error('analytics accepts at most one named argument')
	}
	name := if arguments.len == 0 { 'state' } else { arguments[0] }
	match name {
		'on' {
			subcommand.enable_analytics(mut state)
			return ''
		}
		'off' {
			subcommand.disable_analytics(mut state)
			return ''
		}
		'state' {
			return subcommand.analytics_state_message(state)
		}
		'regenerate-uuid' {
			return subcommand.regenerate_analytics_uuid()
		}
		else {
			return error('unknown analytics subcommand: ${name}')
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "cli/parser"
// 6:
// 7: Dir["#{__dir__}/subcommand/*.rb"].each do |subcommand|
// 8:   require "analytics/subcommand/#{File.basename(subcommand, ".rb")}"
// 9: end
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class Analytics < Homebrew::AbstractCommand
// 14:       class << self
// 15:         sig { params(args: T.untyped).void }
// 16:         def dispatch(args)
// 17:           subcommand_class = Homebrew::AbstractSubcommand
// 18:                              .subcommands_for(Homebrew::Cmd::Analytics)
// 19:                              .find do |candidate|
// 20:             candidate.subcommand_name == args.subcommand
// 21:           end
// 22:           T.must(subcommand_class).new(args).run
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
