module subcommand

// Translated from Homebrew/brew `completions/subcommand/state.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CompletionsState {
pub mut:
	linked bool
}

// Ruby method `run` at line 20.
pub fn completions_state_message(state CompletionsState) string {
	return if state.linked {
		'Completions are linked.\n'
	} else {
		'Completions are not linked.\n'
	}
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
// 10:       class StateSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args default: true do
// 12:           usage_banner <<~EOS
// 13:             `brew completions` [`state`]:
// 14:             Display the current state of Homebrew's completions.
// 15:           EOS
// 16:           named_args :none
// 17:         end
// 18:
// 19:         sig { override.void }
// 20:         def run
// 21:           if Completions.link_completions?
// 22:             puts "Completions are linked."
// 23:           else
// 24:             puts "Completions are not linked."
// 25:           end
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
