module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `test/dev-cmd/tap-new_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn tap_new_spec_tests_template() string {
	return '# brew tap-new uses this file to generate a PR test workflow for the new tap\n' + 'name: tap-new tests template\n\n' + 'on:\n' + '  workflow_dispatch:\n\n' + 'permissions: {}\n\n' + 'jobs:\n' + '  test-bot:\n' + "    if: github.repository == ''\n" + '    strategy:\n' + '      matrix:\n' + '        os: [ macos-26 ]\n' + '        include:\n' + '          - os: ubuntu-latest\n' + '            container:\n' + '              image: ghcr.io/homebrew/brew:main\n' + '              options: --privileged\n' + '    permissions:\n' + '      # tap-new-github-packages-start\n' + '      packages: read\n' + '      # tap-new-github-packages-end\n' + '      pull-requests: read\n' + '    steps:\n' + '      - run: brew test-bot --only-formulaeTAP_NEW_ROOT_URL_ARGUMENT\n' + '        # tap-new-github-packages-start\n' + '        env:\n' + '          HOMEBREW_DOCKER_REGISTRY_TOKEN: token\n' + '        # tap-new-github-packages-end\n'
}

pub fn tap_new_spec_publish_template() string {
	return '# brew tap-new uses this file to generate a bottle publish workflow for the new tap\n' + 'name: tap-new publish template\n\n' + 'on:\n' + '  workflow_dispatch:\n' + '    inputs:\n' + '      pull_request:\n' + '        description: Pull request number\n' + '      head_sha:\n' + '        description: Expected pull request head commit SHA (optional)\n\n' + 'jobs:\n' + '  pr-pull:\n' + "    if: github.repository == ''\n" + '    permissions:\n' + '      # tap-new-github-packages-start\n' + '      packages: write\n' + '      # tap-new-github-packages-end\n' + '      pull-requests: write\n' + '    steps:\n' + '      - name: Pull bottles\n' + '        # tap-new-github-packages-start\n' + '        env:\n' + '          HOMEBREW_GITHUB_PACKAGES_TOKEN: token\n' + '        # tap-new-github-packages-end\n' + '        run: |\n' + '          if [[ -n "\$HEAD_SHA" ]]\n' + '          then\n' + '            brew pr-pull --debug --tap="\$GITHUB_REPOSITORY" --head-sha="\$HEAD_SHA" "\$PULL_REQUEST"\n' + '          else\n' + '            brew pr-pull --debug --tap="\$GITHUB_REPOSITORY" "\$PULL_REQUEST"\n' + '          fi\n' + '      - name: Push commits\n' + '        with:\n' + '          branch: TAP_NEW_BRANCH\n'
}

pub fn tap_new_spec_autobump_template() string {
	return '# brew tap-new uses this file to generate an autobump workflow for the new tap\n' + 'name: tap-new autobump template\n\n' + 'on:\n' + '  push:\n' + '    branches:\n' + '      - TAP_NEW_BRANCH\n' + '  schedule:\n' + '    # this will be changed later and randomised by brew tap-new\n' + '    - cron: "1 1 1 1 1"\n\n' + 'jobs:\n' + '  autobump:\n' + "    if: github.repository == ''\n" + '    steps:\n' + '      - name: Bump formulae\n' + '        run: brew bump --no-fork --open-pr --formulae --bump-synced --tap="\$TAP_NAME"\n'
}

pub fn tap_new_spec_templates() map[string]string {
	return {
		'tap-new-tests.yml':    tap_new_spec_tests_template()
		'tap-new-publish.yml':  tap_new_spec_publish_template()
		'tap-new-autobump.yml': tap_new_spec_autobump_template()
	}
}

pub fn tap_new_spec_initializes(root string) !bool {
	path := os.join_path(root, 'Taps', 'homebrew', 'homebrew-foo')
	result := run_tap_new(TapNewOptions{
		tap: TapNewTap{
			user: 'homebrew'
			repository: 'foo'
			path: path
		}
		no_git: true
		workflow_templates: tap_new_spec_templates()
		random_hour: 7
		random_minute: 35
	})!
	readme := os.read_file(os.join_path(path, 'README.md'))!
	dependabot_yml := os.read_file(os.join_path(path, '.github', 'dependabot.yml'))!
	tests_yml := os.read_file(os.join_path(path, '.github', 'workflows', 'tests.yml'))!
	publish_yml := os.read_file(os.join_path(path, '.github', 'workflows', 'publish.yml'))!
	autobump_yml := os.read_file(os.join_path(path, '.github', 'workflows', 'autobump.yml'))!
	return result.tap == 'homebrew/foo' && result.git_commands.len == 0
		&& result.stdout.contains('homebrew-foo') && readme.starts_with('# Homebrew Foo\n')
		&& dependabot_yml.starts_with('version: 2\n')
		&& !tests_yml.contains('HOMEBREW_DEVELOPER')
		&& tests_yml.contains('options: --privileged')
		&& !publish_yml.contains('HOMEBREW_DEVELOPER')
		&& !publish_yml.contains('pull_request_target')
		&& !publish_yml.contains('workflow_run')
		&& publish_yml.contains('workflow_dispatch:')
		&& publish_yml.contains('description: Expected pull request head commit SHA (optional)')
		&& !publish_yml.contains('gh pr view')
		&& publish_yml.contains('brew pr-pull --debug --tap="\$GITHUB_REPOSITORY" --head-sha="\$HEAD_SHA"')
		&& publish_yml.contains('brew pr-pull --debug --tap="\$GITHUB_REPOSITORY" "\$PULL_REQUEST"')
		&& !autobump_yml.contains('HOMEBREW_DEVELOPER')
		&& !autobump_yml.contains('pull_request_target')
		&& !autobump_yml.contains('workflow_run') && !autobump_yml.contains('TAP_NEW_')
		&& !autobump_yml.contains('cron: "1 1 1 1 1"')
		&& !autobump_yml.contains('# this will be changed later and randomised by brew tap-new')
		&& autobump_yml.contains('- main')
		&& autobump_yml.contains('brew bump --no-fork --open-pr --formulae --bump-synced --tap="\$TAP_NAME"')
}

// Ruby it `it "initializes a new tap with a README file and GitHub Actions CI", :integration_test do` at line 11.
pub fn ruby_tap_new_spec_l11_d1_initializes(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-tap-new-spec-${os.getpid()}')
	}
	created_temporary_root := args.len == 0
	if created_temporary_root {
		os.rmdir_all(root) or {}
	}
	result := tap_new_spec_initializes(root) or {
		if created_temporary_root {
			os.rmdir_all(root) or {}
		}
		return ruby.object_value('Error', err.msg())
	}
	if created_temporary_root {
		os.rmdir_all(root) or {}
	}
	return ruby.bool_value(result)
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
