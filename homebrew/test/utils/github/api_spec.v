module github

import ruby
import homebrew.utils.github as github_api

// Translated from Homebrew/brew `test/utils/github/api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "sleeps for at least 1 second even if the rate limit has already reset" do` at line 8.
pub fn ruby_api_spec_l8_d1_sleeps(args ...ruby.Value) ruby.Value {
	now := if args.len > 0 {
		args[0].as_int() or { i64(1_700_000_000) }
	} else {
		i64(1_700_000_000)
	}
	exception := github_api.github_api_new_rate_limit_error('API rate limit exceeded', now - 10, 'core', 5000, 'token', now)
	mut sleep_state := github_api.GitHubApiSleepState{}
	slept := github_api.github_api_sleep_for_rate_limit(exception, now, mut sleep_state)
	return ruby.bool_value(slept == 1 && sleep_state.slept_seconds == [1] && sleep_state.warnings == [
		'GitHub rate limit exceeded, sleeping for 1 seconds...',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/github"
// 5:
// 6: RSpec.describe GitHub::API do
// 7:   describe "::sleep_for_rate_limit" do
// 8:     it "sleeps for at least 1 second even if the rate limit has already reset" do
// 9:       exception = GitHub::API::RateLimitExceededError.new(
// 10:         "API rate limit exceeded", reset: Time.now.to_i - 10, resource: "core", limit: 5000
// 11:       )
// 12:       expect(described_class).to receive(:sleep).with(1)
// 13:       described_class.sleep_for_rate_limit(exception)
// 14:     end
// 15:   end
// 16: end
