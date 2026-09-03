module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/git_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:repo) do` at line 7.
pub fn ruby_git_spec_l7_d1_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(spec_git_fixture())
}

// Ruby let `let(:path) { repo }` at line 16.
pub fn ruby_git_spec_l16_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { ruby_git_spec_l7_d1_repo() }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Git do
// 7:   let(:repo) do
// 8:     mktmpdir.tap do |repo|
// 9:       system "git", "-C", repo, "init"
// 10:
// 11:       FileUtils.touch repo/"test"
// 12:       system "git", "-C", repo, "add", "test"
// 13:       system "git", "-C", repo, "commit", "-m", "Add `test` file."
// 14:     end
// 15:   end
// 16:   let(:path) { repo }
// 17:
// 18:   include_examples "UnpackStrategy::detect"
// 19:   include_examples "#extract", children: [".git", "test"]
// 20: end
