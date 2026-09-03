module test_bot

import brew_runtime

pub struct TapSyntaxInput {
pub:
	tap_name          string
	tap_path          string
	installed         bool
	official          bool
	typed             bool
	stable            bool
	has_formula_files bool
	has_cask_files    bool
}

pub struct TapSyntaxStep {
pub:
	command     []string
	removed_env []string
}

pub struct TapSyntaxRun {
pub:
	header string
	steps  []TapSyntaxStep
}

// Translated from Homebrew/brew `test_bot/tap_syntax.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 8.
pub fn ruby_tap_syntax_l8_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	input := TapSyntaxInput{
		tap_name: if args.len > 0 { args[0].as_string() } else { '' }
		tap_path: if args.len > 1 { args[1].as_string() } else { '' }
		installed: args.len > 2 && args[2].bool_data
		official: args.len > 3 && args[3].bool_data
		typed: args.len > 4 && args[4].bool_data
		stable: args.len > 5 && args[5].bool_data
		has_formula_files: args.len > 6 && args[6].bool_data
		has_cask_files: args.len > 7 && args[7].bool_data
	}
	run := tap_syntax_run(input)
	return brew_runtime.map_value({
		'header':      brew_runtime.string_value(run.header)
		'commands':    brew_runtime.array_value(run.steps.map(brew_runtime.string_array_value(it.command)))
		'removed_env': brew_runtime.array_value(run.steps.map(brew_runtime.string_array_value(it.removed_env)))
	})
}

pub fn tap_syntax_run(input TapSyntaxInput) TapSyntaxRun {
	mut steps := []TapSyntaxStep{}
	if !input.installed {
		return TapSyntaxRun{ header: 'Running TapSyntax#run!' }
	}
	if !input.stable {
		if input.official && input.typed {
			steps << TapSyntaxStep{ command: ['brew', 'typecheck', input.tap_name] }
		}
		steps << TapSyntaxStep{ command: ['brew', 'style', input.tap_name] }
	}
	if !input.has_formula_files && !input.has_cask_files {
		return TapSyntaxRun{
			header: 'Running TapSyntax#run!'
			steps: steps
		}
	}
	without_recursive_sorbet := ['HOMEBREW_SORBET_RECURSIVE']
	steps << TapSyntaxStep{
		command: ['brew', 'readall', '--aliases', '--os=all', '--arch=all', input.tap_name]
		removed_env: without_recursive_sorbet
	}
	if !input.stable {
		steps << TapSyntaxStep{
			command: ['brew', 'audit', '--except=installed', '--tap=${input.tap_name}']
			removed_env: without_recursive_sorbet
		}
	}
	return TapSyntaxRun{
		header: 'Running TapSyntax#run!'
		steps: steps
	}
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
