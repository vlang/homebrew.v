module api

import os

// Translated from Homebrew/brew `api/json_download.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct JSONDownloadStrategy {
pub:
	url           string
	target        string
	stale_seconds ?int
	quiet         bool
}

pub struct JSONDownload {
pub:
	url        string
	downloader JSONDownloadStrategy
}

pub type JSONApiFileFetcher = fn(string, string, ?int) !

pub fn json_download_fetch(strategy JSONDownloadStrategy, _ ?f64,
	fetcher JSONApiFileFetcher) !string {
	fetcher(strategy.url, strategy.target, strategy.stale_seconds)!
	return strategy.target
}

pub fn json_download_fetched_size(strategy JSONDownloadStrategy) ?i64 {
	if !os.is_file(strategy.target) || os.file_size(strategy.target) == 0 {
		return none
	}
	return i64(os.file_size(strategy.target))
}

pub fn new_json_download(url string, target string, stale_seconds ?int) JSONDownload {
	return JSONDownload{
		url: url
		downloader: JSONDownloadStrategy{
			url: url
			target: target
			stale_seconds: stale_seconds
		}
	}
}

// Ruby method `fetch(timeout: nil)` at line 10.
pub fn ruby_json_download_l10_fetch(strategy JSONDownloadStrategy, timeout ?f64,
	fetcher JSONApiFileFetcher) !string {
	return json_download_fetch(strategy, timeout, fetcher)!
}

// Ruby method `fetched_size` at line 18.
pub fn ruby_json_download_l18_fetched_size(strategy JSONDownloadStrategy) ?i64 {
	return json_download_fetched_size(strategy)
}

// Ruby method `cached_location` at line 23.
pub fn ruby_json_download_l23_cached_location(strategy JSONDownloadStrategy) string {
	return strategy.target
}

// Ruby method `initialize(url, target:, stale_seconds:)` at line 32.
pub fn ruby_json_download_l32_initialize(url string, target string,
	stale_seconds ?int) JSONDownload {
	return new_json_download(url, target, stale_seconds)
}

// Ruby method `downloader` at line 38.
pub fn ruby_json_download_l38_downloader(download JSONDownload) JSONDownloadStrategy {
	return download.downloader
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
