module api

import brew_runtime

// Translated from Homebrew/brew `api/json_download.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fetch(timeout: nil)` at line 10.
pub fn ruby_json_download_l10_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch', ...args)
}

// Ruby method `fetched_size` at line 18.
pub fn ruby_json_download_l18_fetched_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetched_size', ...args)
}

// Ruby method `cached_location` at line 23.
pub fn ruby_json_download_l23_cached_location(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_location', ...args)
}

// Ruby method `initialize(url, target:, stale_seconds:)` at line 32.
pub fn ruby_json_download_l32_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `downloader` at line 38.
pub fn ruby_json_download_l38_downloader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloader', ...args)
}

// Ruby method `download_queue_type = "JSON API"` at line 43.
pub fn ruby_json_download_l43_download_queue_type() string {
	return 'JSON API'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "downloadable"
// 5:
// 6: module Homebrew
// 7:   module API
// 8:     class JSONDownloadStrategy < AbstractDownloadStrategy
// 9:       sig { override.params(timeout: T.nilable(T.any(Integer, Float))).returns(Pathname) }
// 10:       def fetch(timeout: nil)
// 11:         with_context quiet: quiet? do
// 12:           Homebrew::API.fetch_json_api_file(url, target: cached_location, stale_seconds: meta[:stale_seconds])
// 13:         end
// 14:         cached_location
// 15:       end
// 16:
// 17:       sig { override.returns(T.nilable(Integer)) }
// 18:       def fetched_size
// 19:         File.size?(cached_location)
// 20:       end
// 21:
// 22:       sig { override.returns(Pathname) }
// 23:       def cached_location
// 24:         meta.fetch(:target)
// 25:       end
// 26:     end
// 27:
// 28:     class JSONDownload
// 29:       include Downloadable
// 30:
// 31:       sig { params(url: String, target: Pathname, stale_seconds: T.nilable(Integer)).void }
// 32:       def initialize(url, target:, stale_seconds:)
// 33:         super()
// 34:         @url = T.let(URL.new(url, using: API::JSONDownloadStrategy, target:, stale_seconds:), URL)
// 35:       end
// 36:
// 37:       sig { override.returns(API::JSONDownloadStrategy) }
// 38:       def downloader
// 39:         T.cast(super, API::JSONDownloadStrategy)
// 40:       end
// 41:
// 42:       sig { override.returns(String) }
// 43:       def download_queue_type = "JSON API"
// 44:     end
// 45:   end
// 46: end
