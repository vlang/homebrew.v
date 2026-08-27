module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/tap_syntax.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 8.
pub fn ruby_tap_syntax_l8_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class TapSyntax < Test
// 7:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 8:       def run!(args:)
// 9:         test_header(:TapSyntax)
// 10:         tapped = T.must(tap)
// 11:         return unless tapped.installed?
// 12:
// 13:         unless args.stable?
// 14:           # Run `brew typecheck` if this tap is typed.
// 15:           # TODO: consider in future if we want to allow unsupported taps here.
// 16:           if tapped.official? && quiet_system(git, "-C", tapped.path.to_s, "grep", "-qE",
// 17:                                               "^# typed: (true|strict|strong)$")
// 18:             test "brew", "typecheck", tapped.name
// 19:           end
// 20:
// 21:           test "brew", "style", tapped.name
// 22:         end
// 23:
// 24:         return if tapped.formula_files.blank? && tapped.cask_files.blank?
// 25:
// 26:         # Recursive runtime checks are too slow for full-tap `readall` and `audit`.
// 27:         without_recursive_sorbet = { "HOMEBREW_SORBET_RECURSIVE" => nil }
// 28:         test "brew", "readall", "--aliases", "--os=all", "--arch=all", tapped.name, env: without_recursive_sorbet
// 29:         return if args.stable?
// 30:
// 31:         test "brew", "audit", "--except=installed", "--tap=#{tapped.name}", env: without_recursive_sorbet
// 32:       end
// 33:     end
// 34:   end
// 35: end
