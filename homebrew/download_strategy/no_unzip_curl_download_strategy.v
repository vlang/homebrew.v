module download_strategy

import homebrew.unpack_strategy

// Translated from Homebrew/brew `download_strategy/no_unzip_curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `stage(&_block)` at line 10.
pub fn ruby_no_unzip_curl_download_strategy_l10_d1_stage(mut strategy NoUnzipCurlDownloadStrategy, destination string) ! {
	strategy.stage(destination)!
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading archives without automatically extracting them.
// 5: # (Useful for downloading `.jar` files.)
// 6: #
// 7: # @api public
// 8: class NoUnzipCurlDownloadStrategy < CurlDownloadStrategy
// 9:   sig { override.params(_block: T.nilable(T.proc.void)).void }
// 10:   def stage(&_block)
// 11:     UnpackStrategy::Uncompressed.new(cached_location)
// 12:                                 .extract(basename:,
// 13:                                          verbose:  verbose? && !quiet?)
// 14:     yield if block_given?
// 15:   end
// 16: end
