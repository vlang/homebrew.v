module homebrew

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `retryable_download.rb`.
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

fn retryable_downloadable_value(downloadable &RetryableDownloadable) ruby.Value {
	return ruby.structured_value('Downloadable', downloadable.url_value, {
		'retryable_downloadable_address': u64(voidptr(downloadable)).str()
	})
}

fn retryable_downloadable_from_value(value ruby.Value) &RetryableDownloadable {
	address := value.attributes['retryable_downloadable_address'] or {
		panic('invalid retryable downloadable')
	}
	return unsafe { &RetryableDownloadable(voidptr(address.u64())) }
}

pub fn retryable_downloadable_boundary(downloadable &RetryableDownloadable) ruby.Value {
	return retryable_downloadable_value(downloadable)
}

fn retryable_download_value(download &RetryableDownload) ruby.Value {
	return ruby.structured_value('Homebrew::RetryableDownload', '', {
		'retryable_download_address': u64(voidptr(download)).str()
	})
}

fn retryable_download_from_value(value ruby.Value) &RetryableDownload {
	address := value.attributes['retryable_download_address'] or { panic('invalid retryable download') }
	return unsafe { &RetryableDownload(voidptr(address.u64())) }
}
