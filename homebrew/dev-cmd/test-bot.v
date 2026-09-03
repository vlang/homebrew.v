module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/test-bot.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct TestBotCommandOptions {
pub:
	github_actions          bool
	only_cleanup_before     bool
	only_setup              bool
	only_tap_syntax         bool
	only_formulae           bool
	only_formulae_detect    bool
	only_formulae_dependents bool
	only_bottles_fetch      bool
	only_cleanup_after      bool
}

pub struct TestBotCommandResult {
pub:
	environment    map[string]string
	bundler_groups []string
	run_test_bot   bool
}

pub fn run_test_bot_command(options TestBotCommandOptions) TestBotCommandResult {
	mut environment := {
		'HOMEBREW_TEST_BOT': '1'
	}
	if options.github_actions {
		environment['HOMEBREW_COLOR'] = '1'
		environment['HOMEBREW_GITHUB_ACTIONS'] = '1'
	}
	exclusive_mode := options.only_cleanup_before || options.only_setup || options.only_tap_syntax
		|| options.only_formulae_detect || options.only_formulae_dependents
		|| options.only_bottles_fetch || options.only_cleanup_after
	return TestBotCommandResult{
		environment: environment
		bundler_groups: if options.only_formulae || !exclusive_mode { ['ast'] } else { []string{} }
		run_test_bot: true
	}
}

@[heap]
pub struct TestBotCommandInput {
pub:
	options TestBotCommandOptions
}

pub fn test_bot_command_input_boundary(input &TestBotCommandInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::TestBotCmd::Input', '', {
		'test_bot_command_input_address': u64(voidptr(input)).str()
	})
}

fn test_bot_command_input_from_value(value brew_runtime.Value) &TestBotCommandInput {
	address := value.attributes['test_bot_command_input_address'] or {
		panic('invalid TestBotCmd input')
	}
	return unsafe { &TestBotCommandInput(voidptr(address.u64())) }
}

fn test_bot_command_result_value(result TestBotCommandResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in result.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'environment': brew_runtime.map_value(environment)
		'bundler_groups': brew_runtime.string_array_value(result.bundler_groups)
		'run_test_bot': brew_runtime.bool_value(result.run_test_bot)
	})
}

// Ruby method `run` at line 124.
pub fn ruby_test_bot_l124_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return test_bot_command_result_value(run_test_bot_command(test_bot_command_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "test_bot"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class TestBotCmd < AbstractCommand
// 10:       cmd_args do
// 11:         usage_banner <<~EOS
// 12:           `test-bot` [<options>] [<formula>]
// 13:
// 14:           Tests the full lifecycle of a Homebrew change to a tap (Git repository). For example, for a GitHub Actions pull request that changes a formula `brew test-bot` will ensure the system is cleaned and set up to test the formula, install the formula, run various tests and checks on it, bottle (package) the binaries and test formulae that depend on it to ensure they aren't broken by these changes.
// 15:
// 16:           Only supports GitHub Actions as a CI provider. This is because Homebrew uses GitHub Actions and it's freely available for public and private use with macOS and Linux workers.
// 17:         EOS
// 18:
// 19:         switch "--dry-run",
// 20:                description: "Print what would be done rather than doing it."
// 21:         switch "--cleanup",
// 22:                description: "Clean all state from the Homebrew directory. Use with care!"
// 23:         switch "--skip-setup",
// 24:                description: "Don't check if the local system is set up correctly."
// 25:         switch "--build-from-source",
// 26:                description: "Build from source rather than building bottles."
// 27:         switch "--build-dependents-from-source",
// 28:                description: "Build dependents from source rather than testing bottles."
// 29:         switch "--junit",
// 30:                description: "generate a JUnit XML test results file."
// 31:         switch "--keep-old",
// 32:                description: "Run `brew bottle --keep-old` to build new bottles for a single platform."
// 33:         switch "--skip-relocation",
// 34:                description: "Run `brew bottle --skip-relocation` to build new bottles that don't require relocation."
// 35:         switch "--only-json-tab",
// 36:                description: "Run `brew bottle --only-json-tab` to build new bottles that do not contain a tab."
// 37:         switch "--local",
// 38:                description: "Ask Homebrew to write verbose logs under `./logs/` and set `$HOME` to `./home/`"
// 39:         flag   "--tap=",
// 40:                description: "Use the Git repository of the given tap. Defaults to the core tap for syntax checking."
// 41:         switch "--fail-fast",
// 42:                description: "Immediately exit on a failing step."
// 43:         switch "-v", "--verbose",
// 44:                description: "Print test step output in real time. Has the side effect of " \
// 45:                             "passing output as raw bytes instead of re-encoding in UTF-8."
// 46:         switch "--test-default-formula",
// 47:                description: "Use a default testing formula when not building " \
// 48:                             "a tap and no other formulae are specified."
// 49:         flag   "--root-url=",
// 50:                description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
// 51:         flag   "--git-name=",
// 52:                description: "Set the Git author/committer names to the given name."
// 53:         flag   "--git-email=",
// 54:                description: "Set the Git author/committer email to the given email."
// 55:         switch "--publish",
// 56:                description: "Publish the uploaded bottles."
// 57:         switch "--skip-online-checks",
// 58:                description: "Don't pass `--online` to `brew audit` and skip `brew livecheck`."
// 59:         switch "--skip-new",
// 60:                description: "Don't pass `--new` to `brew audit` for new formulae."
// 61:         switch "--skip-new-strict",
// 62:                depends_on:  "--skip-new",
// 63:                description: "Don't pass `--strict` to `brew audit` for new formulae."
// 64:         switch "--skip-dependents",
// 65:                description: "Don't test any dependents."
// 66:         switch "--skip-livecheck",
// 67:                description: "Don't test livecheck."
// 68:         switch "--[no-]skip-recursive-dependents",
// 69:                description: "Only test the direct dependents (default: enabled).",
// 70:                replacement: "the default behaviour",
// 71:                odeprecated: true
// 72:         switch "--skip-checksum-only-audit",
// 73:                description: "Don't audit checksum-only changes."
// 74:         switch "--skip-stable-version-audit",
// 75:                description: "Don't audit the stable version."
// 76:         switch "--skip-revision-audit",
// 77:                description: "Don't audit the revision."
// 78:         switch "--only-cleanup-before",
// 79:                description: "Only run the pre-cleanup step. Needs `--cleanup`, except in GitHub Actions."
// 80:         switch "--only-setup",
// 81:                description: "Only run the local system setup check step."
// 82:         switch "--only-tap-syntax",
// 83:                description: "Only run the tap syntax check step."
// 84:         switch "--stable",
// 85:                depends_on:  "--only-tap-syntax",
// 86:                description: "Only run the tap syntax checks needed on stable brew."
// 87:         switch "--only-formulae",
// 88:                description: "Only run the formulae steps."
// 89:         switch "--only-formulae-detect",
// 90:                description: "Only run the formulae detection steps."
// 91:         switch "--only-formulae-dependents",
// 92:                description: "Only run the formulae dependents steps."
// 93:         switch "--only-bottles-fetch",
// 94:                description: "Only run the bottles fetch steps. This optional post-upload test checks that all " \
// 95:                             "the bottles were uploaded correctly. It is not run unless requested and only needs " \
// 96:                             "to be run on a single machine. The bottle commit to be tested must be on the tested " \
// 97:                             "branch."
// 98:         switch "--only-cleanup-after",
// 99:                description: "Only run the post-cleanup step. Needs `--cleanup`, except in GitHub Actions."
// 100:         comma_array "--testing-formulae=",
// 101:                     description: "Use these testing formulae rather than running the formulae detection steps."
// 102:         comma_array "--added-formulae=",
// 103:                     description: "Use these added formulae rather than running the formulae detection steps."
// 104:         comma_array "--deleted-formulae=",
// 105:                     description: "Use these deleted formulae rather than running the formulae detection steps."
// 106:         comma_array "--skipped-or-failed-formulae=",
// 107:                     description: "Use these skipped or failed formulae from formulae steps for a " \
// 108:                                  "formulae dependents step."
// 109:         comma_array "--tested-formulae=",
// 110:                     description: "Use these tested formulae from formulae steps for a formulae dependents step."
// 111:         flag   "--formulae-dependents-shard=",
// 112:                description: "Only test the formulae dependents in the given <SHARD/TOTAL>.",
// 113:                hidden:      true
// 114:         conflicts "--only-formulae-detect", "--testing-formulae"
// 115:         conflicts "--only-formulae-detect", "--added-formulae"
// 116:         conflicts "--only-formulae-detect", "--deleted-formulae"
// 117:         conflicts "--skip-dependents", "--only-formulae-dependents"
// 118:         conflicts "--only-cleanup-before", "--only-setup", "--only-tap-syntax",
// 119:                   "--only-formulae", "--only-formulae-detect", "--only-formulae-dependents",
// 120:                   "--only-cleanup-after", "--skip-setup"
// 121:       end
// 122:
// 123:       sig { override.void }
// 124:       def run
// 125:         if GitHub::Actions.env_set?
// 126:           ENV["HOMEBREW_COLOR"] = "1"
// 127:           ENV["HOMEBREW_GITHUB_ACTIONS"] = "1"
// 128:         end
// 129:         ENV["HOMEBREW_TEST_BOT"] = "1"
// 130:
// 131:         Homebrew.install_bundler_gems!(groups: ["ast"]) if args.only_formulae? || [
// 132:           args.only_cleanup_before?,
// 133:           args.only_setup?,
// 134:           args.only_tap_syntax?,
// 135:           args.only_formulae_detect?,
// 136:           args.only_formulae_dependents?,
// 137:           args.only_bottles_fetch?,
// 138:           args.only_cleanup_after?,
// 139:         ].none?
// 140:
// 141:         TestBot.run!(args)
// 142:       end
// 143:     end
// 144:   end
// 145: end
