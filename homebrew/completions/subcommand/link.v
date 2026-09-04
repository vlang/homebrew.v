module subcommand

// Translated from Homebrew/brew `completions/subcommand/link.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 20.
pub fn link_completions(mut state CompletionsState) string {
	state.linked = true
	return 'Completions are now linked.\n'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "completions"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class CompletionsCmd < Homebrew::AbstractCommand
// 10:       class LinkSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args do
// 12:           usage_banner <<~EOS
// 13:             `brew completions link`:
// 14:             Link Homebrew's completions.
// 15:           EOS
// 16:           named_args :none
// 17:         end
// 18:
// 19:         sig { override.void }
// 20:         def run
// 21:           Completions.link!
// 22:           puts "Completions are now linked."
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
