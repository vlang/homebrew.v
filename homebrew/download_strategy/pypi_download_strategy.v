module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/pypi_download_strategy.rb`.

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
