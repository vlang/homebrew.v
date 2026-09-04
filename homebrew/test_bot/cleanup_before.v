module test_bot

import ruby

pub struct CleanupBeforeInput {
pub:
	shared             CleanupSharedInput
	tap_name           string
	core_tap_name      string = 'homebrew/core'
	core_tap_path      string
	core_tap_installed bool
	bottle_artifacts   []string
	github_actions     bool
	self_hosted        bool
	untrusted_taps     []CleanupTap
}

pub fn cleanup_github_actions_hosted_runner_plan() []CleanupAction {
	// This hook is intentionally empty in the pinned platform-independent class.
	// OS extensions can add actions while callers retain the same ordering point.
	return []CleanupAction{}
}

pub fn untap_untrusted_taps_plan(current_tap string, untrusted_taps []CleanupTap) []CleanupAction {
	names := untrusted_taps.filter(it.name != current_tap).map(it.name)
	if names.len == 0 {
		return []CleanupAction{}
	}
	return [CleanupAction{
		kind: 'command'
		command: cleanup_append_strings(['brew', 'untap'], names)
	}]
}

pub fn cleanup_before_plan(input CleanupBeforeInput) CleanupPlan {
	mut actions := [CleanupAction{
		kind: 'test_header'
		paths: ['CleanupBefore']
	}]
	if input.tap_name != input.core_tap_name && input.core_tap_installed {
		core_state := cleanup_repository_state(input.shared, input.core_tap_path)
		actions << reset_if_needed_plan(core_state, input.shared.git)
	}
	if input.bottle_artifacts.len > 0 {
		actions << CleanupAction{
			kind: 'remove_file'
			paths: input.bottle_artifacts.clone()
		}
	}
	if input.github_actions && !input.self_hosted {
		actions << cleanup_github_actions_hosted_runner_plan()
		actions << untap_untrusted_taps_plan(input.tap_name, input.untrusted_taps)
		actions << CleanupAction{
			kind: 'command'
			command: ['brew', 'cleanup', '--prune-prefix']
		}
	}
	shared_plan := cleanup_shared_plan(input.shared)
	actions << shared_plan.actions
	// `trust_test_tap!` deliberately follows shared cleanup, which may remove the
	// user trust file while purging the prefix.
	actions << CleanupAction{
		kind: 'trust_tap'
		paths: [input.tap_name]
	}
	return CleanupPlan{
		actions: actions
		paths_to_purge: shared_plan.paths_to_purge
	}
}

// Translated from Homebrew/brew `test_bot/cleanup_before.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 10.
pub fn ruby_cleanup_before_l10_d1_run(args ...ruby.Value) ruby.Value {
	tap_name := cleanup_value_string(args, 0, '')
	core_path := cleanup_value_string(args, 2, '')
	github_actions := cleanup_value_bool(args, 5, false)
	self_hosted := cleanup_value_bool(args, 6, false)
	untrusted_taps := cleanup_value_strings(args, 7).map(CleanupTap{
		name: it
	})
	return cleanup_plan_value(cleanup_before_plan(CleanupBeforeInput{
		shared: CleanupSharedInput{
			repository: core_path
			homebrew_repository: core_path
			homebrew_prefix: core_path
			homebrew_cellar: '${core_path}/Cellar'
			has_tap: tap_name != ''
			tap_name: tap_name
			github_actions: github_actions
			self_hosted: self_hosted
			repositories: [CleanupRepositoryState{
				repository: core_path
				origin_head: 'origin/main'
				current_branch: 'main'
			}]
		}
		tap_name: tap_name
		core_tap_name: cleanup_value_string(args, 1, 'homebrew/core')
		core_tap_path: core_path
		core_tap_installed: cleanup_value_bool(args, 3, false)
		bottle_artifacts: cleanup_value_strings(args, 4)
		github_actions: github_actions
		self_hosted: self_hosted
		untrusted_taps: untrusted_taps
	}))
}

// Ruby method `cleanup_github_actions_hosted_runner; end` at line 33.
pub fn ruby_cleanup_before_l33_d2_cleanup_github_actions_hosted_runner(args ...ruby.Value) ruby.Value {
	return cleanup_actions_value(cleanup_github_actions_hosted_runner_plan())
}

// Ruby method `untap_untrusted_taps` at line 36.
pub fn ruby_cleanup_before_l36_d3_untap_untrusted_taps(args ...ruby.Value) ruby.Value {
	current_tap := cleanup_value_string(args, 0, '')
	taps := cleanup_value_strings(args, 1).map(CleanupTap{
		name: it
	})
	return cleanup_actions_value(untap_untrusted_taps_plan(current_tap, taps))
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
