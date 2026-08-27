module download_strategies

import brew_runtime

// Translated from Homebrew/brew `test/download_strategies/vcs_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:url) { "https://example.com/bar" }` at line 7.
pub fn ruby_vcs_spec_l7_d1_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:version) { nil }` at line 8.
pub fn ruby_vcs_spec_l8_d2_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby it `it "returns the path of the cached resource" do` at line 11.
pub fn ruby_vcs_spec_l11_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe VCSDownloadStrategy do
// 7:   let(:url) { "https://example.com/bar" }
// 8:   let(:version) { nil }
// 9:
// 10:   describe "#cached_location" do
// 11:     it "returns the path of the cached resource" do
// 12:       allow_any_instance_of(described_class).to receive(:cache_tag).and_return("foo")
// 13:       downloader = Class.new(described_class).new(url, "baz", version)
// 14:       expect(downloader.cached_location).to eq(HOMEBREW_CACHE/"baz--foo")
// 15:     end
// 16:   end
// 17: end
