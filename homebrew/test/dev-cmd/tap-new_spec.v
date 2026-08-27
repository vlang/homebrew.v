module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/tap-new_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "initializes a new tap with a README file and GitHub Actions CI", :integration_test do` at line 11.
pub fn ruby_tap_new_spec_l11_d1_initializes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initializes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/tap-new"
// 6: require "yaml"
// 7:
// 8: RSpec.describe Homebrew::DevCmd::TapNew do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   it "initializes a new tap with a README file and GitHub Actions CI", :integration_test do
// 12:     # To ensure that Utils::Git.setup_gpg! doesn't raise an error
// 13:     setup_test_formula "gnupg"
// 14:
// 15:     expect { brew "tap-new", "--no-git", "--verbose", "homebrew/foo" }
// 16:       .to be_a_success
// 17:       .and output(%r{homebrew/foo}).to_stdout
// 18:       .and not_to_output.to_stderr
// 19:
// 20:     expect(HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo/README.md").to exist
// 21:     dependabot_yml = (HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo/.github/dependabot.yml").read
// 22:     tests_yml = (HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo/.github/workflows/tests.yml").read
// 23:     publish_yml = (HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo/.github/workflows/publish.yml").read
// 24:     autobump_yml = (HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo/.github/workflows/autobump.yml").read
// 25:     [dependabot_yml, tests_yml, publish_yml].each { YAML.parse(it) }
// 26:     expect(tests_yml).not_to include("HOMEBREW_DEVELOPER")
// 27:     expect(tests_yml).to include("options: --privileged")
// 28:     expect(publish_yml).not_to include("HOMEBREW_DEVELOPER")
// 29:     expect(publish_yml).not_to include("pull_request_target")
// 30:     expect(publish_yml).not_to include("workflow_run")
// 31:     expect(publish_yml).to include("workflow_dispatch:")
// 32:     expect(publish_yml).to include("description: Expected pull request head commit SHA (optional)")
// 33:     expect(publish_yml).not_to include("gh pr view")
// 34:     expect(publish_yml).to include('brew pr-pull --debug --tap="$GITHUB_REPOSITORY" --head-sha="$HEAD_SHA"')
// 35:     expect(publish_yml).to include('brew pr-pull --debug --tap="$GITHUB_REPOSITORY" "$PULL_REQUEST"')
// 36:     expect(autobump_yml).not_to include("HOMEBREW_DEVELOPER")
// 37:     expect(autobump_yml).not_to include("pull_request_target")
// 38:     expect(autobump_yml).not_to include("workflow_run")
// 39:     expect(autobump_yml).not_to include("TAP_NEW_")
// 40:     expect(autobump_yml).not_to include("cron: \"1 1 1 1 1\"")
// 41:     expect(autobump_yml).not_to include("# this will be changed later and randomised by brew tap-new")
// 42:     expect(autobump_yml).to include("- main")
// 43:     expect(autobump_yml).to include('brew bump --no-fork --open-pr --formulae --bump-synced --tap="$TAP_NAME"')
// 44:   end
// 45: end
