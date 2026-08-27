module cmd

// Translated from Homebrew/brew `cmd/as-console-user.rb`.
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
// 9:     class AsConsoleUser < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         usage_banner <<~EOS
// 14:           `as-console-user` <command> [<args> ...]
// 15:
// 16:           Run a Homebrew command as the active macOS console user.
// 17:
// 18:           This is intended for MDM, Munki and Jamf workflows where `brew` is
// 19:           invoked as root but Homebrew operations should run as the logged-in
// 20:           console user. The nested command is always dispatched through
// 21:           `HOMEBREW_BREW_FILE`.
// 22:         EOS
// 23:
// 24:         named_args min: 1
// 25:       end
// 26:     end
// 27:   end
// 28: end
