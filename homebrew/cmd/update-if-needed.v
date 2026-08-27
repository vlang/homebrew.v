module cmd

// Translated from Homebrew/brew `cmd/update-if-needed.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class UpdateIfNeeded < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Runs `brew update --auto-update` only if needed.
// 15:           This is a good replacement for `brew update` in scripts where you want
// 16:           the no-op case to be both possible and really fast.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:       end
// 21:     end
// 22:   end
// 23: end
