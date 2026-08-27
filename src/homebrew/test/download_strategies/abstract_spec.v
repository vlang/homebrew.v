module download_strategies

import brew_runtime

// Translated from Homebrew/brew `test/download_strategies/abstract_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { Class.new(described_class).new(url, name, version, **specs) }` at line 7.
pub fn ruby_abstract_spec_l7_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby let `let(:specs) { {} }` at line 9.
pub fn ruby_abstract_spec_l9_d2_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby let `let(:name) { "foo" }` at line 10.
pub fn ruby_abstract_spec_l10_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 11.
pub fn ruby_abstract_spec_l11_d4_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:version) { nil }` at line 12.
pub fn ruby_abstract_spec_l12_d5_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby specify `specify "#source_modified_time" do` at line 14.
pub fn ruby_abstract_spec_l14_d6_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#source_modified_time', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe AbstractDownloadStrategy do
// 7:   subject(:strategy) { Class.new(described_class).new(url, name, version, **specs) }
// 8:
// 9:   let(:specs) { {} }
// 10:   let(:name) { "foo" }
// 11:   let(:url) { "https://example.com/foo.tar.gz" }
// 12:   let(:version) { nil }
// 13:
// 14:   specify "#source_modified_time" do
// 15:     mktmpdir("mtime").cd do
// 16:       FileUtils.touch "foo", mtime: Time.now - 10
// 17:       FileUtils.touch "bar", mtime: Time.now - 100
// 18:       FileUtils.ln_s "not-exist", "baz"
// 19:       expect(strategy.source_modified_time).to eq(File.mtime("foo"))
// 20:     end
// 21:   end
// 22: end
