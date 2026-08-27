module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/pypi_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `source_modified_time` at line 9.
pub fn ruby_pypi_download_strategy_l9_d1_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_modified_time', ...args)
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
