module test_bot

import ruby

pub struct SetupStep {
pub:
	command []string
	verbose bool
	passed  bool = true
}

pub struct SetupRun {
pub:
	header string
	steps  []SetupStep
}

// Translated from Homebrew/brew `test_bot/setup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run!(args:)` at line 8.
pub fn ruby_setup_l8_d1_run(args ...ruby.Value) ruby.Value {
	verbose_doctor := if args.len > 0 {
		args[0].bool_data
	} else {
		ruby.environment_value('HOMEBREW_TEST_BOT_VERBOSE_DOCTOR') != ''
	}
	run := setup_run(verbose_doctor)
	return ruby.map_value({
		'header':   ruby.string_value(run.header)
		'commands': ruby.array_value(run.steps.map(ruby.string_array_value(it.command)))
		'verbose':  ruby.array_value(run.steps.map(ruby.bool_value(it.verbose)))
		'passed':   ruby.bool_value(run.steps.last().passed)
	})
}

pub fn setup_run(verbose_doctor bool) SetupRun {
	return SetupRun{
		header: 'Running Setup#run!'
		steps: [
			SetupStep{
				command: ['brew', 'install-bundler-gems',
					'--add-groups=ast,audit,bottle,formula_test,livecheck,style']
			},
			SetupStep{
				command: ['brew', 'config']
				verbose: true
			},
			SetupStep{
				command: if verbose_doctor {
					['brew', 'doctor', '--debug']
				} else {
					['brew', 'doctor']
				}
				verbose: verbose_doctor
			},
		]
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class Setup < Test
// 7:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(Step) }
// 8:       def run!(args:)
// 9:         test_header(:Setup)
// 10:
// 11:         test "brew", "install-bundler-gems", "--add-groups=ast,audit,bottle,formula_test,livecheck,style"
// 12:
// 13:         # Always output `brew config` output even when it doesn't fail.
// 14:         test "brew", "config", verbose: true
// 15:
// 16:         if ENV["HOMEBREW_TEST_BOT_VERBOSE_DOCTOR"]
// 17:           test "brew", "doctor", "--debug", verbose: true
// 18:         else
// 19:           test "brew", "doctor"
// 20:         end
// 21:       end
// 22:     end
// 23:   end
// 24: end
