module cmd

import homebrew.completions
import homebrew.completions.subcommand

// Translated from Homebrew/brew `cmd/completions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 24.
pub fn ruby_completions_l24_d1_run(arguments []string, mut state subcommand.CompletionsState) !string {
	return completions.ruby_subcommand_l16_dispatch(arguments, mut state)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "completions"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class CompletionsCmd < AbstractCommand
// 10:       require "completions/subcommand"
// 11:
// 12:       cmd_args do
// 13:         usage_banner <<~EOS
// 14:           `completions` [<subcommand>]
// 15:
// 16:           Control whether Homebrew automatically links external tap shell completion files.
// 17:           Read more at <https://docs.brew.sh/Shell-Completion>.
// 18:         EOS
// 19:
// 20:         Homebrew::AbstractSubcommand.define_all(self, command: Homebrew::Cmd::CompletionsCmd)
// 21:       end
// 22:
// 23:       sig { override.void }
// 24:       def run
// 25:         Homebrew::Cmd::CompletionsCmd.dispatch(args)
// 26:       end
// 27:     end
// 28:   end
// 29: end
