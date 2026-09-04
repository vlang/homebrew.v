module subcommand

// Translated from Homebrew/brew `analytics/subcommand/regenerate_uuid.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 21.
pub fn regenerate_analytics_uuid() !string {
	return error('brew analytics regenerate-uuid has been disabled')
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
// 10:       class RegenerateUuidSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args do
// 12:           usage_banner <<~EOS
// 13:             `brew analytics regenerate-uuid`:
// 14:             Delete Homebrew's legacy analytics UUID.
// 15:           EOS
// 16:           named_args :none
// 17:           hide_from_man_page!
// 18:         end
// 19:
// 20:         sig { override.void }
// 21:         def run
// 22:           odisabled "brew analytics regenerate-uuid"
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
