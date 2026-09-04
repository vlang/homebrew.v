module download_strategy

import homebrew.unpack_strategy

// Translated from Homebrew/brew `download_strategy/no_unzip_curl_download_strategy.rb`.

pub struct NoUnzipCurlDownloadStrategy {
pub mut:
	curl    CurlDownloadStrategy
	verbose bool
}

pub fn new_no_unzip_curl_download_strategy(url string, name string, version string, meta DownloadMeta, verbose bool) NoUnzipCurlDownloadStrategy {
	return NoUnzipCurlDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
		verbose: verbose
	}
}

pub fn (mut strategy NoUnzipCurlDownloadStrategy) stage(destination string) ! {
	cached := strategy.curl.cached_location()
	basename := strategy.curl.file.basename()
	uncompressed := unpack_strategy.Strategy{
		kind: .uncompressed
		path: cached
	}
	uncompressed.extract(unpack_strategy.ExtractOptions{
		destination: destination
		basename: basename
		verbose: strategy.verbose && !strategy.curl.file.base.is_quiet()
	})!
}
