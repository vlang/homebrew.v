module api

import os

// Translated from Homebrew/brew `api/source_download.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "downloadable"
// 5:
// 6: module Homebrew
// 7:   module API
// 8:     class SourceDownloadStrategy < CurlDownloadStrategy
// 9:       sig { override.returns(Pathname) }
// 10:       def symlink_location
// 11:         cache/name
// 12:       end
// 13:     end
// 14:
// 15:     class SourceDownload
// 16:       include Downloadable
// 17:
// 18:       sig {
// 19:         params(
// 20:           url:      String,
// 21:           checksum: T.nilable(Checksum),
// 22:           mirrors:  T::Array[String],
// 23:           cache:    T.nilable(Pathname),
// 24:         ).void
// 25:       }
// 26:       def initialize(url, checksum, mirrors: [], cache: nil)
// 27:         super()
// 28:         @url = T.let(URL.new(url, using: API::SourceDownloadStrategy), URL)
// 29:         @checksum = checksum
// 30:         @mirrors = mirrors
// 31:         @cache = cache
// 32:       end
// 33:
// 34:       sig { override.returns(API::SourceDownloadStrategy) }
// 35:       def downloader
// 36:         T.cast(super, API::SourceDownloadStrategy)
// 37:       end
// 38:
// 39:       sig { override.returns(String) }
// 40:       def download_queue_type = "API Source"
// 41:
// 42:       sig { override.returns(Pathname) }
// 43:       def cache
// 44:         @cache || super
// 45:       end
// 46:
// 47:       sig { returns(Pathname) }
// 48:       def symlink_location
// 49:         downloader.symlink_location
// 50:       end
// 51:     end
// 52:   end
// 53: end
