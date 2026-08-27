module cmd

// Translated from Homebrew/brew `cmd/update-reset.rb`.
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
// 9:     class UpdateReset < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Fetch and reset Homebrew and all tap repositories (or any specified <repository>) using `git`(1) to their latest `origin/HEAD`.
// 15:
// 16:           *Note:* this will destroy all your uncommitted or committed changes.
// 17:         EOS
// 18:
// 19:         named_args :repository
// 20:       end
// 21:     end
// 22:   end
// 23: end
