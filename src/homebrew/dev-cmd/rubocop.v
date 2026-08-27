module dev_cmd

// Translated from Homebrew/brew `dev-cmd/rubocop.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Rubocop < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Installs, configures and runs Homebrew's `rubocop`.
// 15:         EOS
// 16:       end
// 17:     end
// 18:   end
// 19: end
