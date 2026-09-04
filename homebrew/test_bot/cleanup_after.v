module test_bot

import ruby

pub struct PkillInput {
pub:
	homebrew_cellar      string
	first_pgrep_matches  bool
	second_pgrep_matches bool
	final_pgrep_matches  bool
}

pub struct CleanupAfterInput {
pub:
	shared               CleanupSharedInput
	github_actions       bool
	self_hosted          bool
	test_default_formula bool
	local                bool
	homebrew_home        string
	homebrew_logs        string
	pkill                PkillInput
}

pub struct CleanupAfterPlan {
pub:
	skipped        bool
	actions        []CleanupAction
	paths_to_purge []string
}

pub fn pkill_if_needed_plan(input PkillInput) []CleanupAction {
	if !input.first_pgrep_matches {
		return []CleanupAction{}
	}
	mut actions := [CleanupAction{
		kind: 'command'
		command: ['pkill', '-f', input.homebrew_cellar]
	}]
	if !input.second_pgrep_matches {
		return actions
	}
	actions << CleanupAction{
		kind: 'sleep'
		seconds: 1
	}
	if input.final_pgrep_matches {
		actions << CleanupAction{
			kind: 'command'
			command: ['pkill', '-9', '-f', input.homebrew_cellar]
		}
	}
	return actions
}

pub fn cleanup_after_plan(input CleanupAfterInput) CleanupAfterPlan {
	if input.github_actions && !input.self_hosted && !input.test_default_formula {
		return CleanupAfterPlan{
			skipped: true
		}
	}
	mut actions := [CleanupAction{
		kind: 'test_header'
		paths: ['CleanupAfter']
	}]
	actions << pkill_if_needed_plan(input.pkill)
	shared_plan := cleanup_shared_plan(input.shared)
	actions << shared_plan.actions
	if input.local {
		actions << CleanupAction{
			kind: 'remove_tree'
			paths: [input.homebrew_home]
		}
		actions << CleanupAction{
			kind: 'remove_tree'
			paths: [input.homebrew_logs]
		}
	}
	return CleanupAfterPlan{
		actions: actions
		paths_to_purge: shared_plan.paths_to_purge
	}
}

fn cleanup_after_plan_value(plan CleanupAfterPlan) ruby.Value {
	return ruby.map_value({
		'skipped':        ruby.bool_value(plan.skipped)
		'actions':        cleanup_actions_value(plan.actions)
		'paths_to_purge': ruby.string_array_value(plan.paths_to_purge)
	})
}

// Translated from Homebrew/brew `test_bot/cleanup_after.rb`.
