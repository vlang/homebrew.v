module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/cleanup_before.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 10.
pub fn ruby_cleanup_before_l10_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Ruby method `cleanup_github_actions_hosted_runner; end` at line 33.
pub fn ruby_cleanup_before_l33_d2_cleanup_github_actions_hosted_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_github_actions_hosted_runner', ...args)
}

// Ruby method `untap_untrusted_taps` at line 36.
pub fn ruby_cleanup_before_l36_d3_untap_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('untap_untrusted_taps', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "trust"
// 5:
// 6: module Homebrew
// 7:   module TestBot
// 8:     class CleanupBefore < TestCleanup
// 9:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 10:       def run!(args:)
// 11:         test_header(:CleanupBefore)
// 12:
// 13:         if tap.to_s != CoreTap.instance.name && CoreTap.instance.installed?
// 14:           reset_if_needed(CoreTap.instance.path.to_s)
// 15:         end
// 16:
// 17:         Pathname.glob("*.bottle*.*").each(&:unlink)
// 18:
// 19:         if ENV["HOMEBREW_GITHUB_ACTIONS"] && !ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"]
// 20:           # minimally fix brew doctor failures (a full clean takes ~5m)
// 21:           cleanup_github_actions_hosted_runner
// 22:           untap_untrusted_taps
// 23:           test "brew", "cleanup", "--prune-prefix"
// 24:         end
// 25:
// 26:         # Keep all "brew" invocations after cleanup_shared
// 27:         # (which cleans up Homebrew/brew)
// 28:         cleanup_shared
// 29:         Homebrew::TestBot.trust_test_tap!(tap)
// 30:       end
// 31:
// 32:       sig { void }
// 33:       def cleanup_github_actions_hosted_runner; end
// 34:
// 35:       sig { void }
// 36:       def untap_untrusted_taps
// 37:         taps_to_untap = Homebrew::Trust.untrusted_taps.reject { |untrusted_tap| untrusted_tap.name == tap&.name }
// 38:         return if taps_to_untap.empty?
// 39:
// 40:         test "brew", "untap", *taps_to_untap.map(&:name)
// 41:       end
// 42:     end
// 43:   end
// 44: end
