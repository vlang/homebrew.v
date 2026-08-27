module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/cleanup_after.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 8.
pub fn ruby_cleanup_after_l8_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Ruby method `pkill_if_needed` at line 32.
pub fn ruby_cleanup_after_l32_d2_pkill_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkill_if_needed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class CleanupAfter < TestCleanup
// 7:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 8:       def run!(args:)
// 9:         if ENV["HOMEBREW_GITHUB_ACTIONS"].present? && ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"].blank? &&
// 10:            # don't need to do post-build cleanup unless testing test-bot itself.
// 11:            !args.test_default_formula?
// 12:           return
// 13:         end
// 14:
// 15:         test_header(:CleanupAfter)
// 16:
// 17:         pkill_if_needed
// 18:
// 19:         cleanup_shared
// 20:
// 21:         # Keep all "brew" invocations after cleanup_shared
// 22:         # (which cleans up Homebrew/brew)
// 23:         return unless local?(args)
// 24:
// 25:         FileUtils.rm_rf ENV.fetch("HOMEBREW_HOME")
// 26:         FileUtils.rm_rf ENV.fetch("HOMEBREW_LOGS")
// 27:       end
// 28:
// 29:       private
// 30:
// 31:       sig { void }
// 32:       def pkill_if_needed
// 33:         pgrep = ["pgrep", "-f", HOMEBREW_CELLAR.to_s]
// 34:
// 35:         return unless quiet_system(*pgrep)
// 36:
// 37:         test "pkill", "-f", HOMEBREW_CELLAR.to_s
// 38:
// 39:         return unless quiet_system(*pgrep)
// 40:
// 41:         sleep 1
// 42:         test "pkill", "-9", "-f", HOMEBREW_CELLAR.to_s if system(*pgrep)
// 43:       end
// 44:     end
// 45:   end
// 46: end
