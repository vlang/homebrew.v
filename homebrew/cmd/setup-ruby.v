module cmd

// Translated from Homebrew/brew `cmd/setup-ruby.rb`.
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
// 9:     class SetupRuby < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Installs and configures Homebrew's Ruby. If `command` is passed, it will only run Bundler if necessary for that command.
// 15:         EOS
// 16:
// 17:         named_args :command
// 18:       end
// 19:     end
// 20:   end
// 21: end
