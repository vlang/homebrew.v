module homebrew

import brew_runtime
import crypto.sha256
import os

// Translated from Homebrew/brew `retryable_download.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum RetryableFailure {
	none
	network
	checksum
	bottle_manifest
	other
}

pub struct RetryableAttempt {
pub:
	path    string
	is_file bool
	failure RetryableFailure
	message string
	digest  string
}

@[heap]
pub struct RetryableDownloadable {
pub:
	url_value           string
	checksum_value      string
	mirrors_value       []string
	download_queue_name string
	download_queue_type string
	cached_download     string
	version_value       string
	download_strategy   string
	downloader_value    string
	is_resource         bool
	is_json_download    bool
	attempts            []RetryableAttempt
pub mut:
	already_downloaded bool
	downloading_calls  int
	downloaded_calls   int
	clear_cache_calls  int
	verify_calls       []string
	fetch_index        int
	skip_patches       []bool
	timeouts           []f64
	quiet_values       []bool
	touched            []string
}

@[heap]
pub struct RetryableDownload {
pub:
	downloadable &RetryableDownloadable
	tries        int
pub mut:
	try_count int
	output    []string
	waits     []i64
}

pub fn new_retryable_download(downloadable &RetryableDownloadable, tries int) &RetryableDownload {
	return &RetryableDownload{
		downloadable: downloadable
		tries: if tries > 0 { tries } else { 1 }
	}
}

pub fn (download RetryableDownload) url() ?string {
	return if download.downloadable.url_value == '' {
		none
	} else {
		download.downloadable.url_value
	}
}

pub fn (download RetryableDownload) checksum() ?string {
	return if download.downloadable.checksum_value == '' {
		none
	} else {
		download.downloadable.checksum_value
	}
}

pub fn (download RetryableDownload) mirrors() []string {
	return download.downloadable.mirrors_value.clone()
}

pub fn (download RetryableDownload) download_queue_name() string {
	return download.downloadable.download_queue_name
}

pub fn (download RetryableDownload) download_queue_type() string {
	return download.downloadable.download_queue_type
}

pub fn (download RetryableDownload) cached_download() string {
	return download.downloadable.cached_download
}

pub fn (download RetryableDownload) clear_cache() {
	mut downloadable := download.downloadable
	downloadable.clear_cache_calls++
}

pub fn (download RetryableDownload) version() ?string {
	return if download.downloadable.version_value == '' {
		none
	} else {
		download.downloadable.version_value
	}
}

pub fn (download RetryableDownload) download_strategy() string {
	return download.downloadable.download_strategy
}

pub fn (download RetryableDownload) downloader() string {
	return download.downloadable.downloader_value
}

pub fn (download RetryableDownload) verify_download_integrity(filename string) {
	mut downloadable := download.downloadable
	downloadable.verify_calls << filename
}

fn retryable_digest(attempt RetryableAttempt) string {
	if attempt.digest != '' {
		return attempt.digest
	}
	if attempt.is_file && os.is_file(attempt.path) {
		return sha256.sum256(os.read_bytes(attempt.path) or { [] }).hex()
	}
	return ''
}

fn retryable_error(attempt RetryableAttempt) IError {
	message := if attempt.message != '' { attempt.message } else { 'download failed' }
	return error(message)
}

pub fn (mut download RetryableDownload) fetch(verify_download_integrity bool, timeout ?f64,
	quiet bool) !string {
	for {
		download.try_count++
		mut downloadable := download.downloadable
		downloadable.downloading_calls++
		already_downloaded := downloadable.already_downloaded
		attempt := downloadable.attempts[downloadable.fetch_index] or {
			return error('no download attempt configured')
		}
		downloadable.fetch_index++
		downloadable.skip_patches << downloadable.is_resource
		downloadable.timeouts << timeout or { 0.0 }
		downloadable.quiet_values << quiet
		if attempt.failure == .none {
			downloadable.downloaded_calls++
			downloadable.already_downloaded = true
			if !attempt.is_file {
				return attempt.path
			}
			if !quiet {
				if !already_downloaded {
					download.output << 'Downloaded to: ${attempt.path}'
				}
				download.output << 'SHA-256: ${retryable_digest(attempt)}'
			}
			if verify_download_integrity && !downloadable.is_json_download {
				download.verify_download_integrity(attempt.path)
			}
			if downloadable.is_json_download {
				downloadable.touched << attempt.path
			}
			return attempt.path
		}
		if attempt.failure == .other {
			return retryable_error(attempt)
		}
		tries_remaining := download.tries - download.try_count
		if tries_remaining == 0 {
			return retryable_error(attempt)
		}
		wait := i64(1 << download.try_count)
		download.waits << wait
		if !quiet {
			what := if tries_remaining == 1 { 'try' } else { 'tries' }
			download.output << 'Retrying download in ${wait}s... (${tries_remaining} ${what} left)'
		}
		if attempt.failure != .network {
			downloadable.clear_cache_calls++
		}
	}
	return error('download failed')
}

fn retryable_downloadable_value(downloadable &RetryableDownloadable) brew_runtime.Value {
	return brew_runtime.structured_value('Downloadable', downloadable.url_value, {
		'retryable_downloadable_address': u64(voidptr(downloadable)).str()
	})
}

fn retryable_downloadable_from_value(value brew_runtime.Value) &RetryableDownloadable {
	address := value.attributes['retryable_downloadable_address'] or {
		panic('invalid retryable downloadable')
	}
	return unsafe { &RetryableDownloadable(voidptr(address.u64())) }
}

pub fn retryable_downloadable_boundary(downloadable &RetryableDownloadable) brew_runtime.Value {
	return retryable_downloadable_value(downloadable)
}

fn retryable_download_value(download &RetryableDownload) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::RetryableDownload', '', {
		'retryable_download_address': u64(voidptr(download)).str()
	})
}

fn retryable_download_from_value(value brew_runtime.Value) &RetryableDownload {
	address := value.attributes['retryable_download_address'] or { panic('invalid retryable download') }
	return unsafe { &RetryableDownload(voidptr(address.u64())) }
}

// Ruby method `url = downloadable.url` at line 14.
pub fn ruby_retryable_download_l14_d1_url(args ...brew_runtime.Value) brew_runtime.Value {
	return if value := retryable_download_from_value(args[0]).url() {
		brew_runtime.string_value(value)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `checksum = downloadable.checksum` at line 17.
pub fn ruby_retryable_download_l17_d2_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return if value := retryable_download_from_value(args[0]).checksum() {
		brew_runtime.object_value('Checksum', value)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `mirrors = downloadable.mirrors` at line 20.
pub fn ruby_retryable_download_l20_d3_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(retryable_download_from_value(args[0]).mirrors())
}

// Ruby method `initialize(downloadable, tries:)` at line 23.
pub fn ruby_retryable_download_l23_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'downloadable and tries are required')
	}
	return retryable_download_value(new_retryable_download(retryable_downloadable_from_value(args[0]), int(args[1].as_int() or { 1 })))
}

// Ruby method `download_queue_name = downloadable.download_queue_name` at line 32.
pub fn ruby_retryable_download_l32_d5_download_queue_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(retryable_download_from_value(args[0]).download_queue_name())
}

// Ruby method `download_queue_type = downloadable.download_queue_type` at line 35.
pub fn ruby_retryable_download_l35_d6_download_queue_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(retryable_download_from_value(args[0]).download_queue_type())
}

// Ruby method `cached_download = downloadable.cached_download` at line 38.
pub fn ruby_retryable_download_l38_d7_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', retryable_download_from_value(args[0]).cached_download())
}

// Ruby method `clear_cache = downloadable.clear_cache` at line 41.
pub fn ruby_retryable_download_l41_d8_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	retryable_download_from_value(args[0]).clear_cache()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `version = downloadable.version` at line 44.
pub fn ruby_retryable_download_l44_d9_version(args ...brew_runtime.Value) brew_runtime.Value {
	return if value := retryable_download_from_value(args[0]).version() {
		brew_runtime.object_value('Version', value)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `download_strategy = downloadable.download_strategy` at line 47.
pub fn ruby_retryable_download_l47_d10_download_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Class', retryable_download_from_value(args[0]).download_strategy())
}

// Ruby method `downloader = downloadable.downloader` at line 50.
pub fn ruby_retryable_download_l50_d11_downloader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('AbstractDownloadStrategy', retryable_download_from_value(args[0]).downloader())
}

// Ruby method `fetch(verify_download_integrity: true, timeout: nil, quiet: false)` at line 59.
pub fn ruby_retryable_download_l59_d12_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'retryable download is required')
	}
	mut download := retryable_download_from_value(args[0])
	verify := args.len < 2 || args[1].bool_data
	timeout := if args.len > 2 && args[2].type_name != 'NilClass' {
		?f64(args[2].as_float() or { 0.0 })
	} else {
		none
	}
	quiet := args.len > 3 && args[3].bool_data
	path := download.fetch(verify, timeout, quiet) or {
		return brew_runtime.object_value('DownloadError', err.msg())
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `verify_download_integrity(filename) = downloadable.verify_download_integrity(filename)` at line 106.
pub fn ruby_retryable_download_l106_d13_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	retryable_download_from_value(args[0]).verify_download_integrity(args[1].as_string())
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby attr_reader `attr_reader :downloadable` at line 111.
pub fn ruby_retryable_download_l111_d14_downloadable(args ...brew_runtime.Value) brew_runtime.Value {
	return retryable_downloadable_value(retryable_download_from_value(args[0]).downloadable)
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
