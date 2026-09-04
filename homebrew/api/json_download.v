module api

import os

// Translated from Homebrew/brew `api/json_download.rb`.
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

pub type JSONApiFileFetcher = fn (string, string, ?int) !

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
