module dev_cmd

// Translated from Homebrew/brew `test/dev-cmd/generate-analytics-api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn generate_analytics_api_spec_generates_environment_configuration() bool {
	return 'homebrew-env-config' in generate_analytics_api_categories
}

// Ruby it `it "generates Homebrew environment configuration analytics" do` at line 10.
pub fn ruby_generate_analytics_api_spec_l10_d1_generates() bool {
	return generate_analytics_api_spec_generates_environment_configuration()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-analytics-api"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateAnalyticsApi do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "generates Homebrew environment configuration analytics" do
// 11:     expect(Homebrew::DevCmd::GenerateAnalyticsApi::CATEGORIES).to include("homebrew-env-config")
// 12:   end
// 13: end
