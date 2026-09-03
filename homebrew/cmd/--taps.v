module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--taps.rb`.
// The original source is retained below until every stub has a typed V body.

// taps_path translates the shell command paired with this Ruby command class.
// HOMEBREW_LIBRARY is set by brew.sh in Homebrew.
pub fn taps_path(library string) string {
	return '${library}/Taps'
}

pub fn taps_path_from_environment() string {
	mut library := brew_runtime.environment_value('HOMEBREW_LIBRARY')
	if library == '' {
		// `Library/Homebrew` maps to the top-level `homebrew` module in this
		// translation, so the module's parent is the translated library root.
		library = @VMODROOT
	}
	return taps_path(library)
}

// Ruby method `self.command_name = "--taps"` at line 13.
pub fn ruby_taps_l13_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('--taps')
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
// 9:     class Taps < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       sig { override.returns(String) }
// 13:       def self.command_name = "--taps"
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Display the path to Homebrew’s Taps directory.
// 18:         EOS
// 19:       end
// 20:     end
// 21:   end
// 22: end
