module github

import brew_runtime

// Translated from Homebrew/brew `test/utils/github/api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "sleeps for at least 1 second even if the rate limit has already reset" do` at line 8.
pub fn ruby_api_spec_l8_d1_sleeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sleeps', ...args)
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
