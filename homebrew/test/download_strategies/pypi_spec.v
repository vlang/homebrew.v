module download_strategies

import brew_runtime

// Translated from Homebrew/brew `test/download_strategies/pypi_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, "foo", "1.2.3") }` at line 7.
pub fn ruby_pypi_spec_l7_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby let `let(:url) { "https://files.pythonhosted.org/packages/ab/cd/efg/foo-1.2.3.tar.gz" }` at line 9.
pub fn ruby_pypi_spec_l9_d2_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:last_modified) { Time.utc(2026, 5, 6, 13, 43, 5) }` at line 10.
pub fn ruby_pypi_spec_l10_d3_last_modified(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('last_modified', ...args)
}

// Ruby it `it "uses the PyPI last modified time set on cached file when archive contents are older" do` at line 23.
pub fn ruby_pypi_spec_l23_d4_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe PyPIDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, "foo", "1.2.3") }
// 8:
// 9:   let(:url) { "https://files.pythonhosted.org/packages/ab/cd/efg/foo-1.2.3.tar.gz" }
// 10:   let(:last_modified) { Time.utc(2026, 5, 6, 13, 43, 5) }
// 11:
// 12:   before do
// 13:     allow(Homebrew::EnvConfig).to receive(:artifact_domain).and_return(nil)
// 14:     allow(strategy).to receive(:resolve_url_basename_time_file_size)
// 15:       .and_return([url, "foo-1.2.3.tar.gz", last_modified, 1024, "application/gzip", false])
// 16:     allow(strategy).to receive(:_fetch)
// 17:     strategy.clear_cache
// 18:     strategy.temporary_path.dirname.mkpath
// 19:     FileUtils.touch strategy.temporary_path, mtime: last_modified
// 20:   end
// 21:
// 22:   describe "#source_modified_time" do
// 23:     it "uses the PyPI last modified time set on cached file when archive contents are older" do
// 24:       strategy.fetch
// 25:
// 26:       mktmpdir("mtime").cd do
// 27:         FileUtils.touch "foo.py", mtime: Time.utc(2020, 2, 2)
// 28:
// 29:         expect(strategy.source_modified_time).to eq(last_modified)
// 30:       end
// 31:     end
// 32:   end
// 33: end
