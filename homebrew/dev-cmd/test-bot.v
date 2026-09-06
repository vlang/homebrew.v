module dev_cmd

// Translated from Homebrew/brew `dev-cmd/test-bot.rb`.

pub struct TestBotCommandOptions {
pub:
	github_actions           bool
	only_cleanup_before      bool
	only_setup               bool
	only_tap_syntax          bool
	only_formulae            bool
	only_formulae_detect     bool
	only_formulae_dependents bool
	only_bottles_fetch       bool
	only_cleanup_after       bool
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
