module download_strategy

import crypto.sha256
import os

// Translated from Homebrew/brew `download_strategy/curl_github_packages_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :resolved_basename` at line 9.
pub fn ruby_curl_github_packages_download_strategy_l9_d1_resolved_basename(mut strategy CurlGitHubPackagesDownloadStrategy, resolved_basename string) string {
	strategy.set_resolved_basename(resolved_basename)
	return resolved_basename
}

// Ruby method `initialize(url, name, version, **meta)` at line 12.
pub fn ruby_curl_github_packages_download_strategy_l12_d2_initialize(url string, name string, version string, meta DownloadMeta, bottle bool) CurlGitHubPackagesDownloadStrategy {
	return new_curl_github_packages_download_strategy(url, name, version, meta, bottle)
}

// Ruby method `cached_location` at line 29.
pub fn ruby_curl_github_packages_download_strategy_l29_d3_cached_location(mut strategy CurlGitHubPackagesDownloadStrategy) string {
	return strategy.cached_location()
}

// Ruby method `immutable_bottle_blob?` at line 39.
pub fn ruby_curl_github_packages_download_strategy_l39_d4_immutable_bottle_blob(strategy &CurlGitHubPackagesDownloadStrategy) bool {
	return strategy.immutable_bottle_blob()
}

// Ruby method `bottle_blob_sha256` at line 48.
pub fn ruby_curl_github_packages_download_strategy_l48_d5_bottle_blob_sha256(strategy &CurlGitHubPackagesDownloadStrategy) ?string {
	return strategy.bottle_blob_sha256()
}

// Ruby method `resolve_url_basename_time_file_size(url, timeout: nil)` at line 55.
pub fn ruby_curl_github_packages_download_strategy_l55_d6_resolve_url_basename_time_file_size(mut strategy CurlGitHubPackagesDownloadStrategy, url string, timeout ?f64) UrlMetadata {
	return strategy.resolve_url_basename_time_file_size(url, timeout)
}

pub struct CurlGitHubPackagesDownloadStrategy {
pub mut:
	curl              CurlDownloadStrategy
	resolved_basename string
	bottle            bool
}

pub fn new_curl_github_packages_download_strategy(url string, name string, version string, source_meta DownloadMeta, bottle bool) CurlGitHubPackagesDownloadStrategy {
	mut meta := source_meta
	authorization := os.getenv('HOMEBREW_GITHUB_PACKAGES_AUTH').trim_space()
	artifact_domain := if meta.artifact_domain != '' {
		meta.artifact_domain
	} else {
		os.getenv('HOMEBREW_ARTIFACT_DOMAIN')
	}
	has_registry_auth := os.getenv('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN').trim_space() != '' || os.getenv('HOMEBREW_DOCKER_REGISTRY_TOKEN').trim_space() != ''
	if authorization != '' && (artifact_domain.trim_space() == '' || has_registry_auth) {
		meta.headers << 'Authorization: ${authorization}'
	}
	return CurlGitHubPackagesDownloadStrategy{
		curl: new_curl_download_strategy(url, name, version, meta)
		bottle: bottle
	}
}

pub fn (mut strategy CurlGitHubPackagesDownloadStrategy) set_resolved_basename(resolved_basename string) {
	strategy.resolved_basename = resolved_basename
}

pub fn (mut strategy CurlGitHubPackagesDownloadStrategy) cached_location() string {
	if !strategy.immutable_bottle_blob() {
		return strategy.curl.cached_location()
	}
	if strategy.curl.file.cached_location_value != '' {
		return strategy.curl.file.cached_location_value
	}
	digest := sha256.sum256(strategy.curl.file.base.url.bytes()).hex()
	strategy.curl.file.cached_location_value = os.join_path(default_homebrew_cache(), 'downloads', '${digest}--${safe_filename(strategy.resolved_basename)}')
	return strategy.curl.file.cached_location_value
}

pub fn (strategy &CurlGitHubPackagesDownloadStrategy) immutable_bottle_blob() bool {
	return strategy.bottle && strategy.curl.mirrors.len == 0 && strategy.resolved_basename.trim_space() != '' && strategy.bottle_blob_sha256() != none
}

pub fn (strategy &CurlGitHubPackagesDownloadStrategy) bottle_blob_sha256() ?string {
	lower_url := strategy.curl.file.base.url.to_lower()
	marker := '/blobs/sha256:'
	marker_index := lower_url.index(marker) or { return none }
	start := marker_index + marker.len
	if start + 64 > lower_url.len {
		return none
	}
	digest := lower_url[start..start + 64]
	if !digest.bytes().all(it.is_hex_digit()) {
		return none
	}
	if start + 64 < lower_url.len && lower_url[start + 64] !in [`?`, `#`] {
		return none
	}
	return digest
}

pub fn (mut strategy CurlGitHubPackagesDownloadStrategy) resolve_url_basename_time_file_size(url string, timeout ?f64) UrlMetadata {
	if strategy.resolved_basename.trim_space() == '' {
		return strategy.curl.resolve_url_basename_time_file_size(url, timeout)
	}
	return UrlMetadata{
		url: url
		basename: strategy.resolved_basename
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a file from an GitHub Packages URL.
// 5: #
// 6: # @api public
// 7: class CurlGitHubPackagesDownloadStrategy < CurlDownloadStrategy
// 8:   sig { params(resolved_basename: String).returns(T.nilable(String)) }
// 9:   attr_writer :resolved_basename
// 10:
// 11:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 12:   def initialize(url, name, version, **meta)
// 13:     meta[:headers] ||= []
// 14:     # GitHub Packages authorization header.
// 15:     # HOMEBREW_GITHUB_PACKAGES_AUTH set in brew.sh
// 16:     # If using a private GHCR mirror with no Authentication set or HOMEBREW_GITHUB_PACKAGES_AUTH is empty
// 17:     # then do not add the header. In all other cases add it.
// 18:     if HOMEBREW_GITHUB_PACKAGES_AUTH.presence && (
// 19:       !Homebrew::EnvConfig.artifact_domain.presence ||
// 20:       Homebrew::EnvConfig.docker_registry_basic_auth_token.presence ||
// 21:       Homebrew::EnvConfig.docker_registry_token.presence
// 22:     )
// 23:       meta[:headers] << "Authorization: #{HOMEBREW_GITHUB_PACKAGES_AUTH}"
// 24:     end
// 25:     super
// 26:   end
// 27:
// 28:   sig { override.returns(Pathname) }
// 29:   def cached_location
// 30:     return super unless immutable_bottle_blob?
// 31:
// 32:     cached_location = @cached_location
// 33:     return cached_location unless cached_location.nil?
// 34:
// 35:     @cached_location = HOMEBREW_CACHE/"downloads/#{Digest::SHA256.hexdigest(url)}--#{Utils.safe_filename(@resolved_basename.to_s)}"
// 36:   end
// 37:
// 38:   sig { returns(T::Boolean) }
// 39:   def immutable_bottle_blob?
// 40:     return false if meta[:bottle] != true
// 41:     return false unless mirrors.empty?
// 42:     return false if @resolved_basename.blank?
// 43:
// 44:     !bottle_blob_sha256.nil?
// 45:   end
// 46:
// 47:   sig { returns(T.nilable(String)) }
// 48:   def bottle_blob_sha256
// 49:     url[%r{/blobs/sha256:([0-9a-f]{64})(?:[?#]|$)}i, 1]&.downcase
// 50:   end
// 51:
// 52:   private
// 53:
// 54:   sig { override.params(url: String, timeout: T.nilable(T.any(Float, Integer))).returns(URLMetadata) }
// 55:   def resolve_url_basename_time_file_size(url, timeout: nil)
// 56:     return super if @resolved_basename.blank?
// 57:
// 58:     [url, @resolved_basename, nil, nil, nil, false]
// 59:   end
// 60: end
