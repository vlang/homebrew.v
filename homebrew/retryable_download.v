module homebrew

import brew_runtime

// Translated from Homebrew/brew `retryable_download.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `url = downloadable.url` at line 14.
pub fn ruby_retryable_download_l14_d1_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby method `checksum = downloadable.checksum` at line 17.
pub fn ruby_retryable_download_l17_d2_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checksum', ...args)
}

// Ruby method `mirrors = downloadable.mirrors` at line 20.
pub fn ruby_retryable_download_l20_d3_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mirrors', ...args)
}

// Ruby method `initialize(downloadable, tries:)` at line 23.
pub fn ruby_retryable_download_l23_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `download_queue_name = downloadable.download_queue_name` at line 32.
pub fn ruby_retryable_download_l32_d5_download_queue_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_queue_name', ...args)
}

// Ruby method `download_queue_type = downloadable.download_queue_type` at line 35.
pub fn ruby_retryable_download_l35_d6_download_queue_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_queue_type', ...args)
}

// Ruby method `cached_download = downloadable.cached_download` at line 38.
pub fn ruby_retryable_download_l38_d7_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_download', ...args)
}

// Ruby method `clear_cache = downloadable.clear_cache` at line 41.
pub fn ruby_retryable_download_l41_d8_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_cache', ...args)
}

// Ruby method `version = downloadable.version` at line 44.
pub fn ruby_retryable_download_l44_d9_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `download_strategy = downloadable.download_strategy` at line 47.
pub fn ruby_retryable_download_l47_d10_download_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_strategy', ...args)
}

// Ruby method `downloader = downloadable.downloader` at line 50.
pub fn ruby_retryable_download_l50_d11_downloader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloader', ...args)
}

// Ruby method `fetch(verify_download_integrity: true, timeout: nil, quiet: false)` at line 59.
pub fn ruby_retryable_download_l59_d12_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch', ...args)
}

// Ruby method `verify_download_integrity(filename) = downloadable.verify_download_integrity(filename)` at line 106.
pub fn ruby_retryable_download_l106_d13_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_download_integrity', ...args)
}

// Ruby attr_reader `attr_reader :downloadable` at line 111.
pub fn ruby_retryable_download_l111_d14_downloadable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloadable', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bottle"
// 5: require "api/json_download"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   class RetryableDownload
// 10:     include Downloadable
// 11:     include Utils::Output::Mixin
// 12:
// 13:     sig { override.returns(T.nilable(T.any(String, URL))) }
// 14:     def url = downloadable.url
// 15:
// 16:     sig { override.returns(T.nilable(Checksum)) }
// 17:     def checksum = downloadable.checksum
// 18:
// 19:     sig { override.returns(T::Array[String]) }
// 20:     def mirrors = downloadable.mirrors
// 21:
// 22:     sig { params(downloadable: Downloadable, tries: Integer).void }
// 23:     def initialize(downloadable, tries:)
// 24:       super()
// 25:
// 26:       @downloadable = downloadable
// 27:       @try = T.let(0, Integer)
// 28:       @tries = tries
// 29:     end
// 30:
// 31:     sig { override.returns(String) }
// 32:     def download_queue_name = downloadable.download_queue_name
// 33:
// 34:     sig { override.returns(String) }
// 35:     def download_queue_type = downloadable.download_queue_type
// 36:
// 37:     sig { override.returns(Pathname) }
// 38:     def cached_download = downloadable.cached_download
// 39:
// 40:     sig { override.void }
// 41:     def clear_cache = downloadable.clear_cache
// 42:
// 43:     sig { override.returns(T.nilable(Version)) }
// 44:     def version = downloadable.version
// 45:
// 46:     sig { override.returns(T::Class[AbstractDownloadStrategy]) }
// 47:     def download_strategy = downloadable.download_strategy
// 48:
// 49:     sig { override.returns(AbstractDownloadStrategy) }
// 50:     def downloader = downloadable.downloader
// 51:
// 52:     sig {
// 53:       override.params(
// 54:         verify_download_integrity: T::Boolean,
// 55:         timeout:                   T.nilable(T.any(Integer, Float)),
// 56:         quiet:                     T::Boolean,
// 57:       ).returns(Pathname)
// 58:     }
// 59:     def fetch(verify_download_integrity: true, timeout: nil, quiet: false)
// 60:       @try += 1
// 61:
// 62:       downloadable.downloading!
// 63:
// 64:       already_downloaded = downloadable.downloaded?
// 65:
// 66:       download = if downloadable.is_a?(Resource) && (resource = T.cast(downloadable, Resource))
// 67:         resource.fetch(verify_download_integrity: false, timeout:, quiet:, skip_patches: true)
// 68:       else
// 69:         downloadable.fetch(verify_download_integrity: false, timeout:, quiet:)
// 70:       end
// 71:
// 72:       downloadable.downloaded!
// 73:
// 74:       return download unless download.file?
// 75:
// 76:       unless quiet
// 77:         puts "Downloaded to: #{download}" unless already_downloaded
// 78:         puts "SHA-256: #{download.sha256}"
// 79:       end
// 80:
// 81:       json_download = downloadable.is_a?(API::JSONDownload)
// 82:       downloadable.verify_download_integrity(download) if verify_download_integrity && !json_download
// 83:
// 84:       FileUtils.touch(download, mtime: Time.now) if json_download
// 85:
// 86:       download
// 87:     rescue DownloadError, ChecksumMismatchError, Resource::BottleManifest::Error => e
// 88:       tries_remaining = @tries - @try
// 89:       raise if tries_remaining.zero?
// 90:
// 91:       Utils.exponential_backoff_sleep(@try) do |wait|
// 92:         next if quiet
// 93:
// 94:         what = Utils.pluralize("try", tries_remaining)
// 95:         ohai "Retrying download in #{wait}s... (#{tries_remaining} #{what} left)"
// 96:       end
// 97:
// 98:       # Preserve the partial `.incomplete` file on network errors so the next
// 99:       # attempt can resume via `--continue-at`. Clear the cache only when the
// 100:       # fully-downloaded file is known-bad (checksum or manifest mismatch).
// 101:       downloadable.clear_cache unless e.is_a?(DownloadError)
// 102:       retry
// 103:     end
// 104:
// 105:     sig { override.params(filename: Pathname).void }
// 106:     def verify_download_integrity(filename) = downloadable.verify_download_integrity(filename)
// 107:
// 108:     private
// 109:
// 110:     sig { returns(Downloadable) }
// 111:     attr_reader :downloadable
// 112:   end
// 113: end
