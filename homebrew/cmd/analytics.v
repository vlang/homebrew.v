module cmd

import homebrew.analytics
import homebrew.utils

// Translated from Homebrew/brew `cmd/analytics.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_analytics_l23_d1_run(arguments []string, mut state utils.AnalyticsState) !string {
	return analytics.ruby_subcommand_l16_dispatch(arguments, mut state)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Analytics < AbstractCommand
// 9:       require "analytics/subcommand"
// 10:
// 11:       cmd_args do
// 12:         usage_banner <<~EOS
// 13:           `analytics` [<subcommand>]
// 14:
// 15:           Control Homebrew's anonymous aggregate user behaviour analytics.
// 16:           Read more at <https://docs.brew.sh/Analytics>.
// 17:         EOS
// 18:
// 19:         Homebrew::AbstractSubcommand.define_all(self, command: Homebrew::Cmd::Analytics)
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         Homebrew::Cmd::Analytics.dispatch(args)
// 25:       end
// 26:     end
// 27:   end
// 28: end
