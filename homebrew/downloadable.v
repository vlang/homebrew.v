module homebrew

import crypto.sha256
import hash.fnv1a
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

// Ruby method `initialize` at line 25.
pub fn ruby_downloadable_l25_d1_initialize() DownloadableVerificationCache {
	return DownloadableVerificationCache{
		verified: map[string]bool{}
	}
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

// Ruby method `verification_cache` at line 65.
pub fn ruby_downloadable_l65_d4_verification_cache(mut context DownloadableContext) &DownloadableVerificationCache {
	return &context.verification_cache
}

// Ruby attr_reader `attr_reader :url` at line 71.
pub fn ruby_downloadable_l71_d5_url(downloadable &Downloadable) ?Url {
	if downloadable.has_url {
		return downloadable.url_value
	}
	return none
}

// Ruby attr_reader `attr_reader :checksum` at line 74.
pub fn downloadable_checksum(downloadable &Downloadable) ?Checksum {
	if downloadable.has_checksum {
		return downloadable.checksum_value
	}
	return none
}

// Ruby attr_reader `attr_reader :mirrors` at line 77.
pub fn ruby_downloadable_l77_d7_mirrors(downloadable &Downloadable) []string {
	return downloadable.mirrors.clone()
}

// Ruby attr_accessor `attr_accessor :phase` at line 80.
pub fn ruby_downloadable_l80_d8_phase(downloadable &Downloadable) DownloadablePhase {
	return downloadable.phase
}

// Ruby attr_accessor `attr_accessor :phase` at line 80.
pub fn ruby_downloadable_l80_d9_phase(mut downloadable Downloadable, phase DownloadablePhase) DownloadablePhase {
	downloadable.phase = phase
	return phase
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

// Ruby method `extracting! = (@phase = :extracting)` at line 91.
pub fn ruby_downloadable_l91_d14_extracting(mut downloadable Downloadable) {
	downloadable.phase = .extracting
}

// Ruby method `initialize` at line 94.
pub fn ruby_downloadable_l94_d15_initialize() Downloadable {
	return new_downloadable()
}

// Ruby method `initialize_dup(other)` at line 106.
pub fn ruby_downloadable_l106_d16_initialize_dup(other Downloadable) Downloadable {
	mut duplicate := other
	duplicate.mirrors = other.mirrors.clone()
	duplicate.frozen = false
	duplicate.checksum_frozen = false
	duplicate.mirrors_frozen = false
	duplicate.version_frozen = false
	return duplicate
}

// Ruby method `freeze` at line 114.
pub fn ruby_downloadable_l114_d17_freeze(mut downloadable Downloadable) Downloadable {
	downloadable.checksum_frozen = true
	downloadable.mirrors_frozen = true
	downloadable.version_frozen = true
	downloadable.frozen = true
	return downloadable
}

// Ruby method `download_queue_name = download_name` at line 122.
pub fn downloadable_download_queue_name(mut downloadable Downloadable) string {
	return downloadable_download_name(mut downloadable)
}

// Ruby method `download_queue_type; end` at line 125.
pub fn downloadable_download_queue_type(downloadable &Downloadable) string {
	return downloadable.download_queue_type_value
}

// Ruby method `download_queue_message` at line 128.
pub fn ruby_downloadable_l128_d20_download_queue_message(mut downloadable Downloadable) string {
	return '${downloadable_download_queue_type(downloadable)} ${downloadable_download_queue_name(mut downloadable)}'
}

// Ruby method `downloaded?` at line 133.
pub fn ruby_downloadable_l133_d21_downloaded(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !bool {
	path := downloadable_cached_download(mut downloadable, factory)!
	return os.exists(path)
}

// Ruby method `downloaded_and_valid?` at line 138.
pub fn ruby_downloadable_l138_d22_downloaded_and_valid(mut downloadable Downloadable,
	mut context DownloadableContext, factory DownloadableDownloaderFactory) !bool {
	path := downloadable_cached_download(mut downloadable, factory)!
	if !os.is_file(path) || downloadable_checksum_is_blank(downloadable) {
		return false
	}
	was_verbose := context.verification_cache.verbose
	context.verification_cache.verbose = false
	downloadable_verify_download_integrity(mut downloadable, mut context, path) or {
		context.verification_cache.verbose = was_verbose
		if err.msg().starts_with('ChecksumMismatchError:') {
			return false
		}
		return error(err.msg())
	}
	context.verification_cache.verbose = was_verbose
	return true
}

// Ruby method `cached_download` at line 149.
pub fn downloadable_cached_download(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !string {
	downloader := downloadable_downloader(mut downloadable, factory)!
	return downloader.cached_location()
}

// Ruby method `clear_cache` at line 154.
pub fn ruby_downloadable_l154_d24_clear_cache(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) ! {
	mut downloader := downloadable_downloader(mut downloadable, factory)!
	downloader.clear_cache()!
}

// Ruby method `fetched_size` at line 160.
pub fn ruby_downloadable_l160_d25_fetched_size(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !DownloadableSize {
	downloader := downloadable_downloader(mut downloadable, factory)!
	if value := downloader.fetched_size() {
		return DownloadableSize{
			value: value
			has_value: true
		}
	}
	return DownloadableSize{}
}

// Ruby method `total_size` at line 166.
pub fn ruby_downloadable_l166_d26_total_size(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !DownloadableSize {
	if downloadable.has_total_size {
		return DownloadableSize{
			value: downloadable.total_size_value
			has_value: true
		}
	}
	downloader := downloadable_downloader(mut downloadable, factory)!
	value := downloader.total_size() or { return DownloadableSize{} }
	downloadable.total_size_value = value
	downloadable.has_total_size = true
	return DownloadableSize{
		value: value
		has_value: true
	}
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

// Ruby method `fetch(verify_download_integrity: true, timeout: nil, quiet: false)` at line 206.
pub fn ruby_downloadable_l206_d30_fetch(mut downloadable Downloadable, mut context DownloadableContext,
	verify_download_integrity bool, timeout ?f64, quiet bool,
	factory DownloadableDownloaderFactory) !string {
	downloadable_downloading(mut downloadable)
	os.mkdir_all(downloadable_cache(downloadable))!
	mut downloader := downloadable_downloader(mut downloadable, factory)!
	if quiet {
		downloader.quiet()
	}
	if failure := downloader.fetch(timeout) {
		if failure.kind in [.error_during_execution, .curl_download_strategy] {
			return DownloadableDownloadError{
				download_queue_name: downloadable_download_queue_name(mut downloadable)
				cause: failure
			}
		}
		return failure
	}
	downloadable_downloaded(mut downloadable)
	download := downloadable_cached_download(mut downloadable, factory)!
	if verify_download_integrity {
		downloadable_verify_download_integrity(mut downloadable, mut context, download)!
	}
	return download
}

// Ruby method `stage_from_download_queue?(_download, pour:)` at line 226.
pub fn ruby_downloadable_l226_d31_stage_from_download_queue(_ string, _ bool) bool {
	return false
}

// Ruby method `stage_from_download_queue(_download, pour:); end` at line 231.
pub fn ruby_downloadable_l231_d32_stage_from_download_queue(_ string, _ bool) {
	// The base hook is intentionally empty in downloadable.rb; subclasses stage.
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

// Ruby method `hash` at line 253.
pub fn ruby_downloadable_l253_d34_hash(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !u64 {
	path := downloadable_cached_download(mut downloadable, factory)!
	return fnv1a.sum64_string('${downloadable.class_name}:${path}')
}

// Ruby method `eql?(other)` at line 258.
pub fn ruby_downloadable_l258_d35_eql(mut downloadable Downloadable, mut other Downloadable,
	factory DownloadableDownloaderFactory) !bool {
	if downloadable.class_name != other.class_name {
		return false
	}
	left := downloadable_cached_download(mut downloadable, factory)!
	right := downloadable_cached_download(mut other, factory)!
	return left == right
}

// Ruby method `to_s` at line 266.
pub fn ruby_downloadable_l266_d36_to_s(mut downloadable Downloadable,
	factory DownloadableDownloaderFactory) !string {
	path := downloadable_cached_download(mut downloadable, factory)!
	prefix := os.join_path(downloadable_cache(downloadable), 'downloads') + os.path_separator
	short_path := if path.starts_with(prefix) { path[prefix.len..] } else { path }
	return '#<${downloadable.class_name}: ${short_path}>'
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

// Ruby method `silence_checksum_missing_error?` at line 280.
pub fn ruby_downloadable_l280_d38_silence_checksum_missing_error(downloadable &Downloadable) bool {
	return downloadable.silence_checksum_missing
}

// Ruby method `determine_url` at line 285.
pub fn ruby_downloadable_l285_d39_determine_url(downloadable &Downloadable) ?Url {
	return downloadable_url(downloadable)
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "url"
// 5: require "checksum"
// 6: require "download_strategy"
// 7: require "utils/output"
// 8:
// 9: module Downloadable
// 10:   include Context
// 11:   include Utils::Output::Mixin
// 12:   extend T::Helpers
// 13:
// 14:   abstract!
// 15:   requires_ancestor { Kernel }
// 16:
// 17:   # Remembers which files have already been checksum-verified in this process,
// 18:   # so the same unchanged file is not hashed once per download object that
// 19:   # references it.
// 20:   class VerificationCache
// 21:     include Context
// 22:     include Utils::Output::Mixin
// 23:
// 24:     sig { void }
// 25:     def initialize
// 26:       require "concurrent/set"
// 27:
// 28:       @verified = T.let(Concurrent::Set.new, Concurrent::Set)
// 29:     end
// 30:
// 31:     # Verifies the file against the checksum unless this file, in this
// 32:     # state, has already been verified against it in this process.
// 33:     sig { params(filename: Pathname, checksum: T.nilable(Checksum)).void }
// 34:     def verify(filename, checksum)
// 35:       key = key_for(filename, checksum)
// 36:
// 37:       if key && @verified.include?(key)
// 38:         odebug "Skipping checksum verification for '#{filename.basename}' (already verified in this run)"
// 39:         return
// 40:       end
// 41:
// 42:       ohai "Verifying checksum for '#{filename.basename}'" if verbose?
// 43:       filename.verify_checksum(checksum)
// 44:
// 45:       @verified.add(key) if key
// 46:     end
// 47:
// 48:     private
// 49:
// 50:     # The size and modification time ensure a file downloaded again to the
// 51:     # same path (e.g. after `--force` cleared the cache) is verified again.
// 52:     sig { params(filename: Pathname, checksum: T.nilable(Checksum)).returns(T.nilable(String)) }
// 53:     def key_for(filename, checksum)
// 54:       return if checksum.nil?
// 55:
// 56:       stat = filename.stat
// 57:       "#{filename.expand_path}|#{checksum.hexdigest}|#{stat.size}|#{stat.mtime.to_f}"
// 58:     rescue SystemCallError
// 59:       nil
// 60:     end
// 61:   end
// 62:
// 63:   class << self
// 64:     sig { returns(VerificationCache) }
// 65:     def verification_cache
// 66:       @verification_cache ||= T.let(VerificationCache.new, T.nilable(VerificationCache))
// 67:     end
// 68:   end
// 69:
// 70:   sig { overridable.returns(T.nilable(T.any(String, URL))) }
// 71:   attr_reader :url
// 72:
// 73:   sig { overridable.returns(T.nilable(Checksum)) }
// 74:   attr_reader :checksum
// 75:
// 76:   sig { overridable.returns(T::Array[String]) }
// 77:   attr_reader :mirrors
// 78:
// 79:   sig { overridable.returns(Symbol) }
// 80:   attr_accessor :phase
// 81:
// 82:   sig { void }
// 83:   def downloading! = (@phase = :downloading)
// 84:   sig { void }
// 85:   def downloaded! = (@phase = :downloaded)
// 86:   sig { void }
// 87:   def verifying! = (@phase = :verifying)
// 88:   sig { void }
// 89:   def verified! = (@phase = :verified)
// 90:   sig { void }
// 91:   def extracting! = (@phase = :extracting)
// 92:
// 93:   sig { void }
// 94:   def initialize
// 95:     @url = T.let(nil, T.nilable(URL))
// 96:     @checksum = T.let(nil, T.nilable(Checksum))
// 97:     @mirrors = T.let([], T::Array[String])
// 98:     @version = T.let(nil, T.nilable(Version))
// 99:     @download_strategy = T.let(nil, T.nilable(T::Class[AbstractDownloadStrategy]))
// 100:     @downloader = T.let(nil, T.nilable(AbstractDownloadStrategy))
// 101:     @download_name = T.let(nil, T.nilable(String))
// 102:     @phase = T.let(:preparing, Symbol)
// 103:   end
// 104:
// 105:   sig { overridable.params(other: Downloadable).void }
// 106:   def initialize_dup(other)
// 107:     super
// 108:     @checksum = @checksum.dup
// 109:     @mirrors = @mirrors.dup
// 110:     @version = @version.dup
// 111:   end
// 112:
// 113:   sig { overridable.returns(T.self_type) }
// 114:   def freeze
// 115:     @checksum.freeze
// 116:     @mirrors.freeze
// 117:     @version.freeze
// 118:     super
// 119:   end
// 120:
// 121:   sig { returns(String) }
// 122:   def download_queue_name = download_name
// 123:
// 124:   sig { abstract.returns(String) }
// 125:   def download_queue_type; end
// 126:
// 127:   sig(:final) { returns(String) }
// 128:   def download_queue_message
// 129:     "#{download_queue_type} #{download_queue_name}"
// 130:   end
// 131:
// 132:   sig(:final) { returns(T::Boolean) }
// 133:   def downloaded?
// 134:     cached_download.exist?
// 135:   end
// 136:
// 137:   sig { overridable.returns(T::Boolean) }
// 138:   def downloaded_and_valid?
// 139:     return false unless cached_download.file?
// 140:     return false if checksum.blank?
// 141:
// 142:     with_context(quiet: true) { verify_download_integrity(cached_download) }
// 143:     true
// 144:   rescue ChecksumMismatchError
// 145:     false
// 146:   end
// 147:
// 148:   sig { overridable.returns(Pathname) }
// 149:   def cached_download
// 150:     downloader.cached_location
// 151:   end
// 152:
// 153:   sig { overridable.void }
// 154:   def clear_cache
// 155:     downloader.clear_cache
// 156:   end
// 157:
// 158:   # Total bytes downloaded if available.
// 159:   sig { overridable.returns(T.nilable(Integer)) }
// 160:   def fetched_size
// 161:     downloader.fetched_size
// 162:   end
// 163:
// 164:   # Total download size if available.
// 165:   sig { overridable.returns(T.nilable(Integer)) }
// 166:   def total_size
// 167:     @total_size ||= T.let(downloader.total_size, T.nilable(Integer))
// 168:   end
// 169:
// 170:   sig { overridable.returns(T.nilable(Version)) }
// 171:   def version
// 172:     return @version if @version && !@version.null?
// 173:
// 174:     version = determine_url&.version
// 175:     version unless version&.null?
// 176:   end
// 177:
// 178:   sig { overridable.returns(T::Class[AbstractDownloadStrategy]) }
// 179:   def download_strategy
// 180:     @download_strategy ||= T.must(determine_url).download_strategy
// 181:   end
// 182:
// 183:   sig { overridable.returns(AbstractDownloadStrategy) }
// 184:   def downloader
// 185:     @downloader ||= begin
// 186:       primary_url, *mirrors = determine_url_mirrors
// 187:       raise ArgumentError, "attempted to use a `Downloadable` without a URL!" if primary_url.blank?
// 188:
// 189:       download_strategy.new(primary_url, download_name, version,
// 190:                             mirrors:, cache:, **T.must(@url).specs).tap do |downloader|
// 191:         if downloader.is_a?(CurlDownloadStrategy) &&
// 192:            AbstractDownloadStrategy.expand_deferred_environment_for?(downloader)
// 193:           downloader.allow_deferred_environment_expansion!
// 194:         end
// 195:       end
// 196:     end
// 197:   end
// 198:
// 199:   sig {
// 200:     overridable.params(
// 201:       verify_download_integrity: T::Boolean,
// 202:       timeout:                   T.nilable(T.any(Integer, Float)),
// 203:       quiet:                     T::Boolean,
// 204:     ).returns(Pathname)
// 205:   }
// 206:   def fetch(verify_download_integrity: true, timeout: nil, quiet: false)
// 207:     downloading!
// 208:
// 209:     cache.mkpath
// 210:
// 211:     begin
// 212:       downloader.quiet! if quiet
// 213:       downloader.fetch(timeout:)
// 214:     rescue ErrorDuringExecution, CurlDownloadStrategyError => e
// 215:       raise DownloadError.new(self, e)
// 216:     end
// 217:
// 218:     downloaded!
// 219:
// 220:     download = cached_download
// 221:     verify_download_integrity(download) if verify_download_integrity
// 222:     download
// 223:   end
// 224:
// 225:   sig { overridable.params(_download: Pathname, pour: T::Boolean).returns(T::Boolean) }
// 226:   def stage_from_download_queue?(_download, pour:)
// 227:     false
// 228:   end
// 229:
// 230:   sig { overridable.params(_download: Pathname, pour: T::Boolean).void }
// 231:   def stage_from_download_queue(_download, pour:); end
// 232:
// 233:   sig { overridable.params(filename: Pathname).void }
// 234:   def verify_download_integrity(filename)
// 235:     verifying!
// 236:
// 237:     if filename.file?
// 238:       Downloadable.verification_cache.verify(filename, checksum)
// 239:       verified!
// 240:     end
// 241:   rescue ChecksumMissingError
// 242:     return if silence_checksum_missing_error?
// 243:
// 244:     opoo <<~EOS
// 245:       Cannot verify integrity of '#{filename.basename}'.
// 246:       No checksum was provided.
// 247:       For your reference, the checksum is:
// 248:         sha256 "#{filename.sha256}"
// 249:     EOS
// 250:   end
// 251:
// 252:   sig { returns(Integer) }
// 253:   def hash
// 254:     [self.class, cached_download].hash
// 255:   end
// 256:
// 257:   sig { params(other: Object).returns(T::Boolean) }
// 258:   def eql?(other)
// 259:     return false if self.class != other.class
// 260:
// 261:     other = T.cast(other, Downloadable)
// 262:     cached_download == other.cached_download
// 263:   end
// 264:
// 265:   sig { returns(String) }
// 266:   def to_s
// 267:     short_cached_download = cached_download.to_s
// 268:                                            .delete_prefix("#{HOMEBREW_CACHE}/downloads/")
// 269:     "#<#{self.class}: #{short_cached_download}>"
// 270:   end
// 271:
// 272:   private
// 273:
// 274:   sig { overridable.returns(String) }
// 275:   def download_name
// 276:     @download_name ||= File.basename(determine_url.to_s).freeze
// 277:   end
// 278:
// 279:   sig { overridable.returns(T::Boolean) }
// 280:   def silence_checksum_missing_error?
// 281:     false
// 282:   end
// 283:
// 284:   sig { overridable.returns(T.nilable(URL)) }
// 285:   def determine_url
// 286:     @url
// 287:   end
// 288:
// 289:   sig { overridable.returns(T::Array[String]) }
// 290:   def determine_url_mirrors
// 291:     [determine_url.to_s, *mirrors].uniq
// 292:   end
// 293:
// 294:   sig { overridable.returns(Pathname) }
// 295:   def cache
// 296:     HOMEBREW_CACHE
// 297:   end
// 298: end
