module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--caskroom.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn caskroom_output(caskroom string, tokens []string) string {
	lines := if tokens.len == 0 { [caskroom] } else { tokens.map('${caskroom}/${it}') }
	return '${lines.join('\n')}\n'
}

// Ruby method `self.command_name = "--caskroom"` at line 10.
pub fn ruby_caskroom_l10_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('--caskroom')
}

// Ruby method `run` at line 24.
pub fn ruby_caskroom_l24_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', '--caskroom#run requires the Caskroom path')
	}
	caskroom := args[0].as_string()
	mut tokens := []string{}
	if args.len > 1 {
		tokens = args[1].as_string_array() or { args[1..].map(it.as_string()) }
	}
	return brew_runtime.string_value(caskroom_output(caskroom, tokens))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Caskroom < AbstractCommand
// 9:       sig { override.returns(String) }
// 10:       def self.command_name = "--caskroom"
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Display Homebrew's Caskroom path.
// 15:
// 16:           If <cask> is provided, display the location in the Caskroom where <cask>
// 17:           would be installed, without any sort of versioned directory as the last path.
// 18:         EOS
// 19:
// 20:         named_args :cask
// 21:       end
// 22:
// 23:       sig { override.void }
// 24:       def run
// 25:         if args.named.to_casks.blank?
// 26:           puts Cask::Caskroom.path
// 27:         else
// 28:           args.named.to_casks.each do |cask|
// 29:             puts "#{Cask::Caskroom.path}/#{cask.token}"
// 30:           end
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
