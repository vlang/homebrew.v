module cask

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/cask/never_sudo_system_command.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.run(command, **options)` at line 7.
pub fn ruby_never_sudo_system_command_l7_d1_self_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: class NeverSudoSystemCommand < SystemCommand
// 7:   def self.run(command, **options)
// 8:     super(command, **options.merge(sudo: false, sudo_as_root: false))
// 9:   end
// 10: end
