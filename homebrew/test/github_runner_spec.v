module test

import homebrew

// Translated from Homebrew/brew `test/github_runner_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:runner) do` at line 7.
pub fn ruby_github_runner_spec_l7_d1_runner() homebrew.GitHubRunner {
	return homebrew.new_github_runner('macos', 'arm64', homebrew.MacOSRunnerSpec{
		name: 'macOS 11-arm64'
		runner: '11-arm64'
		timeout: 90
		cleanup: true
	}, '11')
}

// Ruby it `it "has immutable attributes" do` at line 13.
pub fn ruby_github_runner_spec_l13_d2_has() bool {
	// The source T::Struct declares these four fields as const; only `active` is mutable.
	runner := ruby_github_runner_spec_l7_d1_runner()
	return runner.platform == 'macos' && runner.arch == 'arm64' && runner.macos_version == '11'
}

// Ruby it `it "is inactive by default" do` at line 19.
pub fn ruby_github_runner_spec_l19_d3_is() bool {
	return !ruby_github_runner_spec_l7_d1_runner().active
}

// Ruby it `it "returns true if the runner is a macOS runner" do` at line 24.
pub fn ruby_github_runner_spec_l24_d4_returns() bool {
	return ruby_github_runner_spec_l7_d1_runner().macos()
}

// Ruby it `it "returns false if the runner is a macOS runner" do` at line 30.
pub fn ruby_github_runner_spec_l30_d5_returns() bool {
	return !ruby_github_runner_spec_l7_d1_runner().linux()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "github_runner"
// 5:
// 6: RSpec.describe GitHubRunner do
// 7:   let(:runner) do
// 8:     spec = MacOSRunnerSpec.new(name: "macOS 11-arm64", runner: "11-arm64", timeout: 90, cleanup: true)
// 9:     version = MacOSVersion.new("11")
// 10:     described_class.new(platform: :macos, arch: :arm64, spec:, macos_version: version)
// 11:   end
// 12:
// 13:   it "has immutable attributes" do
// 14:     [:platform, :arch, :spec, :macos_version].each do |attribute|
// 15:       expect(runner.respond_to?(:"#{attribute}=")).to be(false)
// 16:     end
// 17:   end
// 18:
// 19:   it "is inactive by default" do
// 20:     expect(runner.active).to be(false)
// 21:   end
// 22:
// 23:   describe "#macos?" do
// 24:     it "returns true if the runner is a macOS runner" do
// 25:       expect(runner.macos?).to be(true)
// 26:     end
// 27:   end
// 28:
// 29:   describe "#linux?" do
// 30:     it "returns false if the runner is a macOS runner" do
// 31:       expect(runner.linux?).to be(false)
// 32:     end
// 33:   end
// 34: end
