module test_bot

import brew_runtime

// Translated from Homebrew/brew `test/test_bot/test_formulae_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:test_formulae) do` at line 8.
pub fn ruby_test_formulae_spec_l8_d1_test_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_formulae', ...args)
}

// Ruby it `it "does not raise KeyError when accessing downloaded_artifacts for a new SHA" do` at line 13.
pub fn ruby_test_formulae_spec_l13_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5: require "utils/github/artifacts"
// 6:
// 7: RSpec.describe Homebrew::TestBot::TestFormulae do
// 8:   subject(:test_formulae) do
// 9:     described_class.new(tap: nil, git: nil, dry_run: false, fail_fast: false, verbose: false)
// 10:   end
// 11:
// 12:   describe "#download_artifacts_from_previous_run!" do
// 13:     it "does not raise KeyError when accessing downloaded_artifacts for a new SHA" do
// 14:       # Regression test: @downloaded_artifacts uses a hash with a default block, so we must use
// 15:       # [] (not .fetch) when accessing by SHA. Using .fetch(sha) would raise KeyError for new SHAs.
// 16:       new_sha = "8e624f21ac73d02a609cfec1ce620ccfee3aa97c"
// 17:       allow(GitHub).to receive(:pull_request_labels).with("owner", "repo", 1).and_return([])
// 18:       allow(GitHub::API).to receive_messages(credentials_type: :pat, open_graphql: { "repository" => {
// 19:         "object" => {
// 20:           "checkSuites" => {
// 21:             "nodes" => [
// 22:               {
// 23:                 "status"      => "COMPLETED",
// 24:                 "updatedAt"   => "2024-01-01T00:00:00Z",
// 25:                 "workflowRun" => { "databaseId" => 1, "event" => "pull_request", "workflow" => { "name" => "CI" } },
// 26:                 "checkRuns"   => { "nodes" => [{ "name" => "conclusion", "status" => "COMPLETED" }] },
// 27:               },
// 28:             ],
// 29:           },
// 30:         },
// 31:       } })
// 32:       allow(test_formulae).to receive_messages(
// 33:         previous_github_sha:  new_sha,
// 34:         github_event_payload: { "pull_request" => { "number" => 1 } },
// 35:         artifact_metadata:    [
// 36:           {
// 37:             "name"                 => "bottles",
// 38:             "archive_download_url" => "https://example.com/artifact",
// 39:             "id"                   => 1,
// 40:           },
// 41:         ],
// 42:       )
// 43:       allow(GitHub).to receive(:download_artifact)
// 44:
// 45:       Dir.mktmpdir do |tmpdir|
// 46:         Dir.chdir(tmpdir) do
// 47:           with_env("GITHUB_REPOSITORY" => "owner/repo") do
// 48:             test_formulae.download_artifacts_from_previous_run!("bottles*", dry_run: false)
// 49:           end
// 50:         end
// 51:       end
// 52:
// 53:       # Proves we passed the @downloaded_artifacts[sha] access for a new SHA without KeyError.
// 54:       expect(test_formulae.downloaded_artifacts[new_sha]).to include("bottles")
// 55:     end
// 56:   end
// 57: end
