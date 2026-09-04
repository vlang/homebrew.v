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
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 8.
pub fn ruby_cleanup_after_l8_d1_run(args ...ruby.Value) ruby.Value {
	github_actions := cleanup_value_bool(args, 0, false)
	self_hosted := cleanup_value_bool(args, 1, false)
	cellar := cleanup_value_string(args, 4, '')
	return cleanup_after_plan_value(cleanup_after_plan(CleanupAfterInput{
		shared: CleanupSharedInput{
			homebrew_repository: cellar
			homebrew_prefix: cellar
			homebrew_cellar: cellar
			github_actions: github_actions
			self_hosted: self_hosted
		}
		github_actions: github_actions
		self_hosted: self_hosted
		test_default_formula: cleanup_value_bool(args, 2, false)
		local: cleanup_value_bool(args, 3, false)
		homebrew_home: cleanup_value_string(args, 5, '')
		homebrew_logs: cleanup_value_string(args, 6, '')
		pkill: PkillInput{
			homebrew_cellar: cellar
			first_pgrep_matches: cleanup_value_bool(args, 7, false)
			second_pgrep_matches: cleanup_value_bool(args, 8, false)
			final_pgrep_matches: cleanup_value_bool(args, 9, false)
		}
	}))
}

// Ruby method `pkill_if_needed` at line 32.
pub fn ruby_cleanup_after_l32_d2_pkill_if_needed(args ...ruby.Value) ruby.Value {
	return cleanup_actions_value(pkill_if_needed_plan(PkillInput{
		homebrew_cellar: cleanup_value_string(args, 0, '')
		first_pgrep_matches: cleanup_value_bool(args, 1, false)
		second_pgrep_matches: cleanup_value_bool(args, 2, false)
		final_pgrep_matches: cleanup_value_bool(args, 3, false)
	}))
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
