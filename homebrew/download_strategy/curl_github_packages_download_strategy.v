module download_strategy

import crypto.sha256
import os

// Translated from Homebrew/brew `download_strategy/curl_github_packages_download_strategy.rb`.

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
