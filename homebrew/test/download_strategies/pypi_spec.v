module download_strategies

import ruby
import homebrew.download_strategy
import os
import time

// Translated from Homebrew/brew `test/download_strategies/pypi_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, "foo", "1.2.3") }` at line 7.
pub fn ruby_pypi_spec_l7_d1_strategy(args ...ruby.Value) ruby.Value {
	url := if args.len > 0 { args[0].as_string() } else { ruby_pypi_spec_l9_d2_url().as_string() }
	return ruby.structured_value('PyPIDownloadStrategy', url, {
		'url':     url
		'name':    'foo'
		'version': '1.2.3'
	})
}

// Ruby let `let(:url) { "https://files.pythonhosted.org/packages/ab/cd/efg/foo-1.2.3.tar.gz" }` at line 9.
pub fn ruby_pypi_spec_l9_d2_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://files.pythonhosted.org/packages/ab/cd/efg/foo-1.2.3.tar.gz')
}

// Ruby let `let(:last_modified) { Time.utc(2026, 5, 6, 13, 43, 5) }` at line 10.
pub fn ruby_pypi_spec_l10_d3_last_modified(args ...ruby.Value) ruby.Value {
	return ruby.int_value(1_778_074_985)
}

// Ruby it `it "uses the PyPI last modified time set on cached file when archive contents are older" do` at line 23.
pub fn ruby_pypi_spec_l23_d4_uses(args ...ruby.Value) ruby.Value {
	root := os.join_path(os.temp_dir(), 'brew-v-pypi-spec-${os.getpid()}-${time.now().unix_micro()}')
	cached := os.join_path(root, 'foo-1.2.3.tar.gz')
	stage := os.join_path(root, 'stage')
	os.mkdir_all(stage) or { return ruby.bool_value(false) }
	defer { os.rmdir_all(root) or {} }
	os.write_file(cached, 'archive') or { return ruby.bool_value(false) }
	source := os.join_path(stage, 'foo.py')
	os.write_file(source, 'source') or { return ruby.bool_value(false) }
	last_modified := ruby_pypi_spec_l10_d3_last_modified().as_int() or {
		return ruby.bool_value(false)
	}
	os.utime(cached, last_modified, last_modified) or { return ruby.bool_value(false) }
	os.utime(source, 1_580_601_600, 1_580_601_600) or { return ruby.bool_value(false) }
	mut strategy := download_strategy.new_pypi_download_strategy(ruby_pypi_spec_l9_d2_url().as_string(), 'foo', '1.2.3', download_strategy.DownloadMeta{
		cache: root
	})
	strategy.file.cached_location_value = cached
	modified := download_strategy.pypi_source_modified_time(mut strategy, stage) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(modified == last_modified)
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
