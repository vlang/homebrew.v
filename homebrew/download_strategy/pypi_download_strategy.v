module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/pypi_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `source_modified_time` at line 9.
pub fn ruby_pypi_download_strategy_l9_d1_source_modified_time(mut strategy CurlDownloadStrategy, directory string) !i64 {
	return pypi_source_modified_time(mut strategy, directory)
}

pub fn new_pypi_download_strategy(url string, name string, version string, meta DownloadMeta) CurlDownloadStrategy {
	return new_curl_download_strategy(url, name, version, meta)
}

// PyPI preserves the response Last-Modified timestamp on the cached archive.
// Its source mtime must therefore never move backwards to an older file inside
// the extracted sdist.
pub fn pypi_source_modified_time(mut strategy CurlDownloadStrategy, directory string) !i64 {
	cached := strategy.cached_location()
	last_modified := if os.exists(cached) { os.file_last_mod_unix(cached) } else { i64(0) }
	source_modified := strategy.file.base.source_modified_time(directory)!
	if last_modified == 0 || source_modified > last_modified {
		return source_modified
	}
	return last_modified
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading files from PyPI.
// 5: #
// 6: # @api public
// 7: class PyPIDownloadStrategy < CurlDownloadStrategy
// 8:   sig { override.returns(Time) }
// 9:   def source_modified_time
// 10:     last_modified = cached_location.mtime if cached_location.exist?
// 11:     source_modified_time = super
// 12:     return source_modified_time if last_modified.nil? || source_modified_time > last_modified
// 13:
// 14:     last_modified
// 15:   end
// 16: end
