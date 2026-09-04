module api

import os

// Translated from Homebrew/brew `api/source_download.rb`.
pub struct SourceDownloadStrategy {
pub:
	url   string
	cache string
	name  string
}

pub struct SourceDownload {
pub:
	url            string
	checksum       ?string
	mirrors        []string
	cache_override string
	default_cache  string
	downloader     SourceDownloadStrategy
}

pub fn source_download_strategy_symlink_location(strategy SourceDownloadStrategy) string {
	return os.join_path(strategy.cache, strategy.name)
}

pub fn new_source_download(url string, checksum ?string, mirrors []string, cache_override string,
	default_cache string) SourceDownload {
	cache := if cache_override == '' { default_cache } else { cache_override }
	name := os.base(url.split('?')[0])
	return SourceDownload{
		url: url
		checksum: checksum
		mirrors: mirrors.clone()
		cache_override: cache_override
		default_cache: default_cache
		downloader: SourceDownloadStrategy{
			url: url
			cache: cache
			name: name
		}
	}
}

// Ruby method `symlink_location` at line 10.
pub fn ruby_source_download_l10_symlink_location(strategy SourceDownloadStrategy) string {
	return source_download_strategy_symlink_location(strategy)
}

// Ruby method `initialize(url, checksum, mirrors: [], cache: nil)` at line 26.
pub fn ruby_source_download_l26_initialize(url string, checksum ?string, mirrors []string,
	cache_override string, default_cache string) SourceDownload {
	return new_source_download(url, checksum, mirrors, cache_override, default_cache)
}

// Ruby method `downloader` at line 35.
pub fn ruby_source_download_l35_downloader(download SourceDownload) SourceDownloadStrategy {
	return download.downloader
}

// Ruby method `download_queue_type = "API Source"` at line 40.
pub fn ruby_source_download_l40_download_queue_type() string {
	return 'API Source'
}

// Ruby method `cache` at line 43.
pub fn ruby_source_download_l43_cache(download SourceDownload) string {
	return if download.cache_override == '' {
		download.default_cache
	} else {
		download.cache_override
	}
}

// Ruby method `symlink_location` at line 48.
pub fn ruby_source_download_l48_symlink_location(download SourceDownload) string {
	return source_download_strategy_symlink_location(download.downloader)
}
