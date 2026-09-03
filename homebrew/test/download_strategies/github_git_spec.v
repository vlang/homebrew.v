module download_strategies

import brew_runtime
import homebrew.download_strategy

// Translated from Homebrew/brew `test/download_strategies/github_git_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, name, version) }` at line 7.
pub fn ruby_github_git_spec_l7_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	url := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_github_git_spec_l10_d3_url().as_string()
	}
	name := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby_github_git_spec_l9_d2_name().as_string()
	}
	version := if args.len > 2 && args[2].type_name != 'NilClass' {
		args[2].as_string()
	} else {
		''
	}
	strategy := download_strategy.new_github_git_download_strategy(url, name, version, download_strategy.VCSDownloadMeta{})
	return brew_runtime.structured_value('GitHubGitDownloadStrategy', url, {
		'url':     url
		'name':    name
		'version': version
		'user':    strategy.user() or { '' }
		'repo':    strategy.repo() or { '' }
	})
}

// Ruby let `let(:name) { "brew" }` at line 9.
pub fn ruby_github_git_spec_l9_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('brew')
}

// Ruby let `let(:url) { "https://github.com/homebrew/brew.git" }` at line 10.
pub fn ruby_github_git_spec_l10_d3_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('https://github.com/homebrew/brew.git')
}

// Ruby let `let(:version) { nil }` at line 11.
pub fn ruby_github_git_spec_l11_d4_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby it `it "parses the URL and sets the corresponding instance variables" do` at line 13.
pub fn ruby_github_git_spec_l13_d5_parses(args ...brew_runtime.Value) brew_runtime.Value {
	strategy := download_strategy.new_github_git_download_strategy(ruby_github_git_spec_l10_d3_url().as_string(), ruby_github_git_spec_l9_d2_name().as_string(), '', download_strategy.VCSDownloadMeta{})
	return brew_runtime.bool_value((strategy.user() or { '' }) == 'homebrew'
		&& (strategy.repo() or { '' }) == 'brew')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe GitHubGitDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, name, version) }
// 8:
// 9:   let(:name) { "brew" }
// 10:   let(:url) { "https://github.com/homebrew/brew.git" }
// 11:   let(:version) { nil }
// 12:
// 13:   it "parses the URL and sets the corresponding instance variables" do
// 14:     expect(strategy.user).to eq("homebrew")
// 15:     expect(strategy.repo).to eq("brew")
// 16:   end
// 17: end
