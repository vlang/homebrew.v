module cmd

// Translated from Homebrew/brew `cmd/update.rb`.
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
// 9:     class Update < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Fetch the newest version of Homebrew and all formulae from GitHub using `git`(1) and perform any necessary migrations.
// 15:         EOS
// 16:         switch "--merge",
// 17:                description: "Use `git merge` to apply updates (rather than `git rebase`).",
// 18:                odeprecated: true
// 19:         switch "--auto-update",
// 20:                description: "Run on auto-updates (e.g. before `brew install`). Skips some slower steps."
// 21:         switch "-f", "--force",
// 22:                description: "Always do a slower, full update check (even if unnecessary)."
// 23:         switch "-q", "--quiet",
// 24:                description: "Make some output more quiet."
// 25:         switch "-v", "--verbose",
// 26:                description: "Print the directories checked and `git` operations performed."
// 27:         switch "-d", "--debug",
// 28:                description: "Display a trace of all shell commands as they are executed."
// 29:       end
// 30:     end
// 31:   end
// 32: end
