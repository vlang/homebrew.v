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
