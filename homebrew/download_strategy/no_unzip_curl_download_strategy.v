module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/no_unzip_curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `stage(&_block)` at line 10.
pub fn ruby_no_unzip_curl_download_strategy_l10_d1_stage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stage', ...args)
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
