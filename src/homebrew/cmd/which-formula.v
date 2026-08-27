module cmd

// Translated from Homebrew/brew `cmd/which-formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # License: MIT
// 5: # The license text can be found in Library/Homebrew/command-not-found/LICENSE
// 6:
// 7: require "abstract_command"
// 8: require "api"
// 9: require "shell_command"
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class WhichFormula < AbstractCommand
// 14:       include ShellCommand
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Show which formula(e) provides the given command.
// 19:         EOS
// 20:         switch "--explain",
// 21:                description: "Output explanation of how to get <command> by installing one of the providing formulae."
// 22:         named_args :command, min: 1
// 23:       end
// 24:     end
// 25:   end
// 26: end
