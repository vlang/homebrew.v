module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.command_name = "--version"` at line 13.
pub fn ruby_version_l13_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Version < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       sig { override.returns(String) }
// 13:       def self.command_name = "--version"
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Print the version numbers of Homebrew, Homebrew/homebrew-core and
// 18:           Homebrew/homebrew-cask (if tapped) to standard output.
// 19:         EOS
// 20:       end
// 21:     end
// 22:   end
// 23: end
