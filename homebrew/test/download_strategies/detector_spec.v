module download_strategies

import brew_runtime

// Translated from Homebrew/brew `test/download_strategies/detector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy_detector) { described_class.detect(url, strategy) }` at line 8.
pub fn ruby_detector_spec_l8_d1_strategy_detector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy_detector', ...args)
}

// Ruby let `let(:url) { "invalidurl" }` at line 10.
pub fn ruby_detector_spec_l10_d2_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:strategy) { nil }` at line 11.
pub fn ruby_detector_spec_l11_d3_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby let `let(:url) { "git://example.com/foo.git" }` at line 14.
pub fn ruby_detector_spec_l14_d4_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby it `it { is_expected.to eq(GitDownloadStrategy) }` at line 16.
pub fn ruby_detector_spec_l16_d5_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:url) { "ssh://git@example.com/foo.git" }` at line 20.
pub fn ruby_detector_spec_l20_d6_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby it `it { is_expected.to eq(GitDownloadStrategy) }` at line 22.
pub fn ruby_detector_spec_l22_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:url) { "https://github.com/homebrew/brew.git" }` at line 26.
pub fn ruby_detector_spec_l26_d8_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby it `it { is_expected.to eq(GitHubGitDownloadStrategy) }` at line 28.
pub fn ruby_detector_spec_l28_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:url) do` at line 32.
pub fn ruby_detector_spec_l32_d10_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby it `it { is_expected.to eq(PyPIDownloadStrategy) }` at line 36.
pub fn ruby_detector_spec_l36_d11_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it "defaults to curl" do` at line 39.
pub fn ruby_detector_spec_l39_d12_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('defaults', ...args)
}

// Ruby it `it "raises an error when passed an unrecognized strategy" do` at line 43.
pub fn ruby_detector_spec_l43_d13_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe DownloadStrategyDetector do
// 7:   describe "::detect" do
// 8:     subject(:strategy_detector) { described_class.detect(url, strategy) }
// 9:
// 10:     let(:url) { "invalidurl" }
// 11:     let(:strategy) { nil }
// 12:
// 13:     context "when given Git URL" do
// 14:       let(:url) { "git://example.com/foo.git" }
// 15:
// 16:       it { is_expected.to eq(GitDownloadStrategy) }
// 17:     end
// 18:
// 19:     context "when given SSH Git URL" do
// 20:       let(:url) { "ssh://git@example.com/foo.git" }
// 21:
// 22:       it { is_expected.to eq(GitDownloadStrategy) }
// 23:     end
// 24:
// 25:     context "when given a GitHub Git URL" do
// 26:       let(:url) { "https://github.com/homebrew/brew.git" }
// 27:
// 28:       it { is_expected.to eq(GitHubGitDownloadStrategy) }
// 29:     end
// 30:
// 31:     context "when given a PyPI URL" do
// 32:       let(:url) do
// 33:         "https://files.pythonhosted.org/packages/ab/cd/efg/example-package-1.2.3.tar.gz"
// 34:       end
// 35:
// 36:       it { is_expected.to eq(PyPIDownloadStrategy) }
// 37:     end
// 38:
// 39:     it "defaults to curl" do
// 40:       expect(strategy_detector).to eq(CurlDownloadStrategy)
// 41:     end
// 42:
// 43:     it "raises an error when passed an unrecognized strategy" do
// 44:       expect do
// 45:         described_class.detect("foo", Class.new)
// 46:       end.to raise_error(TypeError)
// 47:     end
// 48:   end
// 49: end
