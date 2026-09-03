module subcommand

import homebrew.utils

// Translated from Homebrew/brew `analytics/subcommand/off.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 20.
pub fn ruby_off_l20_run(mut state utils.AnalyticsState) {
	state.disable()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "utils/analytics"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Analytics < Homebrew::AbstractCommand
// 10:       class OffSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args do
// 12:           usage_banner <<~EOS
// 13:             `brew analytics off`:
// 14:             Turn Homebrew's analytics off.
// 15:           EOS
// 16:           named_args :none
// 17:         end
// 18:
// 19:         sig { override.void }
// 20:         def run
// 21:           Utils::Analytics.disable!
// 22:         end
// 23:       end
// 24:     end
// 25:   end
// 26: end
