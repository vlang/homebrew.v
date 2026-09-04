module homebrew

import crypto.sha256
import homebrew.download_strategy
import os
import sync

// Translated from Homebrew/brew `downloadable.rb`.
pub enum DownloadablePhase {
	preparing
	downloading
	downloaded
	verifying
	verified
	extracting
}

pub enum DownloadableFetchFailureKind {
	none
	error_during_execution
	curl_download_strategy
	other
}

pub struct DownloadableFetchFailure {
pub:
	kind    DownloadableFetchFailureKind
	message string
}

pub fn (failure DownloadableFetchFailure) msg() string {
	return failure.message
}

pub fn (_ DownloadableFetchFailure) code() int {
	return 1
}

pub struct DownloadableDownloadError {
pub:
	download_queue_name string
	cause               DownloadableFetchFailure
}

pub fn (download_error DownloadableDownloadError) msg() string {
	return 'Failed to download resource "${download_error.download_queue_name}"\n${download_error.cause.message}\n'
}

pub fn (_ DownloadableDownloadError) code() int {
	return 1
}

pub struct DownloadableDownloaderRequest {
pub:
	strategy    download_strategy.DownloadStrategy
	primary_url string
	name        string
	version     ?Version
	mirrors     []string
	cache       string
	specs       map[string]string
}

// This is the injected AbstractDownloadStrategy boundary. Fetching is an
// external effect, so the collaborator supplies its outcome while this value
// records the exact calls Downloadable makes.
pub struct DownloadableDownloader {
pub:
	request DownloadableDownloaderRequest
pub mut:
	cached_location_value           string
	fetched_size_value              i64
	has_fetched_size                bool
	total_size_value                i64
	has_total_size                  bool
	fetch_failure                   DownloadableFetchFailure
	clear_cache_failure             string
	quiet_value                     bool
	deferred_environment_expansion  bool
	fetch_calls                     int
	clear_cache_calls               int
	last_timeout                    f64
	has_last_timeout                bool
	remove_cached_location_on_clear bool
}

pub fn (downloader &DownloadableDownloader) cached_location() string {
	return downloader.cached_location_value
}

pub fn (mut downloader DownloadableDownloader) quiet() {
	downloader.quiet_value = true
}

pub fn (mut downloader DownloadableDownloader) allow_deferred_environment_expansion() {
	downloader.deferred_environment_expansion = true
}

pub fn (mut downloader DownloadableDownloader) fetch(timeout ?f64) ?DownloadableFetchFailure {
	downloader.fetch_calls++
	if value := timeout {
		downloader.last_timeout = value
		downloader.has_last_timeout = true
	} else {
		downloader.last_timeout = 0
		downloader.has_last_timeout = false
	}
	if downloader.fetch_failure.kind != .none {
		return downloader.fetch_failure
	}
	return none
}

pub fn (mut downloader DownloadableDownloader) clear_cache() ! {
	downloader.clear_cache_calls++
	if downloader.clear_cache_failure != '' {
		return error(downloader.clear_cache_failure)
	}
	path := downloader.cached_location_value
	if downloader.remove_cached_location_on_clear && (os.exists(path) || os.is_link(path)) {
		if os.is_dir(path) && !os.is_link(path) {
			os.rmdir_all(path)!
		} else {
			os.rm(path)!
		}
	}
}

pub fn (downloader &DownloadableDownloader) fetched_size() ?i64 {
	if downloader.has_fetched_size {
		return downloader.fetched_size_value
	}
	return none
}

pub fn (downloader &DownloadableDownloader) total_size() ?i64 {
	if downloader.has_total_size {
		return downloader.total_size_value
	}
	return none
}

pub type DownloadableDownloaderFactory = fn (DownloadableDownloaderRequest) !DownloadableDownloader

@[heap]
pub struct DownloadableVerificationCache {
pub mut:
	verified       map[string]bool
	verbose        bool
	debug_messages []string
	info_messages  []string
	mutex          sync.Mutex
}

@[heap]
pub struct DownloadableContext {
pub mut:
	verification_cache DownloadableVerificationCache
}

pub struct DownloadableVerificationResult {
pub:
	skipped bool
	key     string
	has_key bool
}

// DownloadableSize preserves Ruby's nilable Integer without relying on V's
// unsupported Result-of-Option combination.
pub struct DownloadableSize {
pub:
	value     i64
	has_value bool
}

@[heap]
pub struct Downloadable {
pub mut:
	class_name                  string
	download_queue_type_value   string
	url_value                   Url
	has_url                     bool
	determined_url_value        Url
	has_determined_url_override bool
	checksum_value              Checksum
	has_checksum                bool
	mirrors                     []string
	version_value               Version
	has_version                 bool
	download_strategy_value     download_strategy.DownloadStrategy
	has_download_strategy       bool
	downloader_value            DownloadableDownloader
	has_downloader              bool
	download_name_value         string
	has_download_name           bool
	phase                       DownloadablePhase
	total_size_value            i64
	has_total_size              bool
	cache_path                  string
	silence_checksum_missing    bool
	frozen                      bool
	checksum_frozen             bool
	mirrors_frozen              bool
	version_frozen              bool
	warnings                    []string
}

fn downloadable_default_cache() string {
	if cache := os.getenv_opt('HOMEBREW_CACHE') {
		if cache != '' {
			return cache
		}
	}
	$if macos {
		return os.join_path(os.home_dir(), 'Library/Caches/Homebrew')
	} $else {
		base := os.getenv('XDG_CACHE_HOME')
		return os.join_path(if base != '' { base } else { os.join_path(os.home_dir(), '.cache') }, 'Homebrew')
	}
}

pub fn new_downloadable() Downloadable {
	return Downloadable{
		class_name: 'Downloadable'
		phase: .preparing
		cache_path: downloadable_default_cache()
	}
}

pub fn new_downloadable_context() DownloadableContext {
	return DownloadableContext{
		verification_cache: DownloadableVerificationCache{
			verified: map[string]bool{}
		}
	}
}

fn downloadable_url(downloadable &Downloadable) ?Url {
	if downloadable.has_determined_url_override {
		return downloadable.determined_url_value
	}
	if downloadable.has_url {
		return downloadable.url_value
	}
	return none
}

fn downloadable_url_text(downloadable &Downloadable) string {
	if url := downloadable_url(downloadable) {
		return url.to_s()
	}
	return ''
}

fn downloadable_checksum_is_blank(downloadable &Downloadable) bool {
	return !downloadable.has_checksum || downloadable.checksum_value.is_empty()
}

fn downloadable_verify_checksum(filename string, checksum Checksum) ! {
	actual := sha256.sum256(os.read_bytes(filename)!).hex()
	if actual != checksum.hexdigest {
		return error('ChecksumMismatchError: SHA-256 mismatch for ${filename}: expected ${checksum.hexdigest}, got ${actual}')
	}
}

fn downloadable_curl_derived(strategy download_strategy.DownloadStrategy) bool {
	return strategy in [.curl_apache_mirror, .curl, .curl_github_packages, .curl_post, .homebrew_curl,
		.no_unzip_curl, .pypi]
}

// Ruby method `verify(filename, checksum)` at line 34.
pub fn downloadable_verify(mut cache DownloadableVerificationCache, filename string,
	checksum ?Checksum) !DownloadableVerificationResult {
	key := downloadable_key_for(filename, checksum)
	if value := key {
		cache.mutex.lock()
		already_verified := cache.verified[value]
		cache.mutex.unlock()
		if already_verified {
			cache.debug_messages << "Skipping checksum verification for '${os.file_name(filename)}' (already verified in this run)"
			return DownloadableVerificationResult{
				skipped: true
				key: value
				has_key: true
			}
		}
	}
	if cache.verbose {
		cache.info_messages << "Verifying checksum for '${os.file_name(filename)}'"
	}
	digest := checksum or { return error('ChecksumMissingError') }
	downloadable_verify_checksum(filename, digest)!
	if value := key {
		cache.mutex.lock()
		cache.verified[value] = true
		cache.mutex.unlock()
		return DownloadableVerificationResult{
			key: value
			has_key: true
		}
	}
	return DownloadableVerificationResult{}
}

// Ruby method `key_for(filename, checksum)` at line 53.
pub fn downloadable_key_for(filename string, checksum ?Checksum) ?string {
	digest := checksum or { return none }
	if !os.exists(filename) {
		return none
	}
	size := os.file_size(filename)
	modified := os.file_last_mod_unix(filename)
	return '${os.abs_path(filename)}|${digest.hexdigest}|${size}|${f64(modified)}'
}

// Ruby attr_reader `attr_reader :checksum` at line 74.
pub fn downloadable_checksum(downloadable &Downloadable) ?Checksum {
	if downloadable.has_checksum {
		return downloadable.checksum_value
	}
	return none
}

// Ruby method `downloading! = (@phase = :downloading)` at line 83.
pub fn downloadable_downloading(mut downloadable Downloadable) {
	downloadable.phase = .downloading
}

// Ruby method `downloaded! = (@phase = :downloaded)` at line 85.
pub fn downloadable_downloaded(mut downloadable Downloadable) {
	downloadable.phase = .downloaded
}

// Ruby method `verifying! = (@phase = :verifying)` at line 87.
pub fn downloadable_verifying(mut downloadable Downloadable) {
	downloadable.phase = .verifying
}

// Ruby method `verified! = (@phase = :verified)` at line 89.
pub fn downloadable_verified(mut downloadable Downloadable) {
	downloadable.phase = .verified
}

// Ruby method `download_queue_name = download_name` at line 122.
pub fn downloadable_download_queue_name(mut downloadable Downloadable) string {
	return downloadable_download_name(mut downloadable)
}

// Ruby method `download_queue_type; end` at line 125.
pub fn downloadable_download_queue_type(downloadable &Downloadable) string {
	return downloadable.download_queue_type_value
}

// Ruby method `cached_download` at line 149.
pub fn downloadable_cached_download(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !string {
	downloader := downloadable_downloader(mut downloadable, factory)!
	return downloader.cached_location()
}

// Ruby method `version` at line 171.
pub fn downloadable_version(downloadable &Downloadable) ?Version {
	if downloadable.has_version && !downloadable.version_value.is_null() {
		return downloadable.version_value
	}
	if url := downloadable_url(downloadable) {
		version := url.version()
		if !version.is_null() {
			return version
		}
	}
	return none
}

// Ruby method `download_strategy` at line 179.
pub fn downloadable_download_strategy(mut downloadable Downloadable) !download_strategy.DownloadStrategy {
	if downloadable.has_download_strategy {
		return downloadable.download_strategy_value
	}
	url := downloadable_url(downloadable) or { return error('Downloadable URL is nil') }
	downloadable.download_strategy_value = url.download_strategy()!
	downloadable.has_download_strategy = true
	return downloadable.download_strategy_value
}

// Ruby method `downloader` at line 184.
pub fn downloadable_downloader(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !&DownloadableDownloader {
	if downloadable.has_downloader {
		return &downloadable.downloader_value
	}
	urls := downloadable_determine_url_mirrors(downloadable)
	primary_url := if urls.len > 0 { urls[0] } else { '' }
	if primary_url.trim_space() == '' {
		return error('attempted to use a `Downloadable` without a URL!')
	}
	strategy := downloadable_download_strategy(mut downloadable)!
	request := DownloadableDownloaderRequest{
		strategy: strategy
		primary_url: primary_url
		name: downloadable_download_name(mut downloadable)
		version: downloadable_version(downloadable)
		mirrors: if urls.len > 1 { urls[1..].clone() } else { [] }
		cache: downloadable_cache(downloadable)
		specs: if downloadable.has_url {
			downloadable.url_value.specs.clone()
		} else {
			map[string]string{}
		}
	}
	downloadable.downloader_value = factory(request)!
	if downloadable_curl_derived(strategy) && download_strategy.expand_deferred_environment_for(strategy) {
		downloadable.downloader_value.allow_deferred_environment_expansion()
	}
	downloadable.has_downloader = true
	return &downloadable.downloader_value
}

// Ruby method `verify_download_integrity(filename)` at line 234.
pub fn downloadable_verify_download_integrity(mut downloadable Downloadable,
	mut context DownloadableContext, filename string) ! {
	downloadable_verifying(mut downloadable)
	if !os.is_file(filename) {
		return
	}
	checksum := downloadable_checksum(downloadable)
	downloadable_verify(mut context.verification_cache, filename, checksum) or {
		if !err.msg().starts_with('ChecksumMissingError') {
			return error(err.msg())
		}
		if downloadable.silence_checksum_missing {
			return
		}
		actual := sha256.sum256(os.read_bytes(filename)!).hex()
		downloadable.warnings << 'Cannot verify integrity of \'${os.file_name(filename)}\'.\nNo checksum was provided.\nFor your reference, the checksum is:\n  sha256 "${actual}"\n'
		return
	}
	downloadable_verified(mut downloadable)
}

// Ruby method `download_name` at line 275.
pub fn downloadable_download_name(mut downloadable Downloadable) string {
	if !downloadable.has_download_name {
		raw := downloadable_url_text(downloadable).trim_right('/')
		downloadable.download_name_value = os.file_name(raw)
		downloadable.has_download_name = true
	}
	return downloadable.download_name_value
}

// Ruby method `determine_url_mirrors` at line 290.
pub fn downloadable_determine_url_mirrors(downloadable &Downloadable) []string {
	mut urls := [downloadable_url_text(downloadable)]
	urls << downloadable.mirrors
	mut unique := []string{}
	for url in urls {
		if url !in unique {
			unique << url
		}
	}
	return unique
}

// Ruby method `cache` at line 295.
pub fn downloadable_cache(downloadable &Downloadable) string {
	return downloadable.cache_path
}
