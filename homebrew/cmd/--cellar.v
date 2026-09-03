module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--cellar.rb`.
// The original source is retained below until every stub has a typed V body.

// cellar_output renders the command's stdout after named formulae have been
// resolved to their rack paths. An empty rack list selects HOMEBREW_CELLAR.
pub fn cellar_output(cellar string, formula_racks []string) string {
	lines := if formula_racks.len == 0 { [cellar] } else { formula_racks }
	return '${lines.join('\n')}\n'
}

// Ruby method `self.command_name = "--cellar"` at line 10.
pub fn ruby_cellar_l10_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('--cellar')
}

// Ruby method `run` at line 25.
pub fn ruby_cellar_l25_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', '--cellar#run requires the Cellar path')
	}
	cellar := args[0].as_string()
	mut racks := []string{}
	if args.len > 1 {
		racks = args[1].as_string_array() or { args[1..].map(it.as_string()) }
	}
	return brew_runtime.string_value(cellar_output(cellar, racks))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Cellar < AbstractCommand
// 9:       sig { override.returns(String) }
// 10:       def self.command_name = "--cellar"
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Display Homebrew's Cellar path. *Default:* `$(brew --prefix)/Cellar`, or if
// 15:           that directory doesn't exist, `$(brew --repository)/Cellar`.
// 16:
// 17:           If <formula> is provided, display the location in the Cellar where <formula>
// 18:           would be installed, without any sort of versioned directory as the last path.
// 19:         EOS
// 20:
// 21:         named_args :formula
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         if args.no_named?
// 27:           puts HOMEBREW_CELLAR
// 28:         else
// 29:           puts args.named.to_resolved_formulae.map(&:rack)
// 30:         end
// 31:       end
// 32:     end
// 33:   end
// 34: end
