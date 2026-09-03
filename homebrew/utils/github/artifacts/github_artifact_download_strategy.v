module artifacts

import crypto.sha256
import homebrew.download_strategy
import os

// Translated from Homebrew/brew `utils/github/artifacts/github_artifact_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

const github_artifact_resolved_basename = 'artifact.zip'

// GitHubArtifactDownloadRequest is the exact curl boundary produced by fetch.
// Keeping the boundary injectable makes authentication and timeout handling
// testable without making a network request.
pub struct GitHubArtifactDownloadRequest {
pub:
	url         string
	destination string
	header      string
	secrets     []string
	timeout     ?f64
}

pub type GitHubArtifactDownloader = fn (request GitHubArtifactDownloadRequest) !

pub struct GitHubArtifactFetchResult {
pub:
	cached_location      string
	temporary_path       string
	symlink_location     string
	symlink_target       string
	download_request     GitHubArtifactDownloadRequest
	has_download_request bool
	downloaded           bool
	already_downloaded   bool
	messages             []string
}

// GitHubArtifactDownloadStrategy retains the abstract file strategy state used
// for its readable cache alias. Completed files deliberately remain in the
// global downloads cache, matching AbstractFileDownloadStrategy in Ruby.
pub struct GitHubArtifactDownloadStrategy {
pub mut:
	file                  download_strategy.AbstractFileDownloadStrategy
	cached_location_value string
pub:
	homebrew_cache string
	token          string
}

pub fn new_github_artifact_download_strategy(url string, artifact_id string, token string) GitHubArtifactDownloadStrategy {
	default_file := download_strategy.new_abstract_file_download_strategy(url, 'artifact', artifact_id, download_strategy.DownloadMeta{})
	return new_github_artifact_download_strategy_with_cache(url, artifact_id, token, default_file.base.cache)
}

pub fn new_github_artifact_download_strategy_with_cache(url string, artifact_id string, token string, homebrew_cache string) GitHubArtifactDownloadStrategy {
	mut file := download_strategy.new_abstract_file_download_strategy(url, 'artifact', artifact_id, download_strategy.DownloadMeta{
		cache: os.join_path(homebrew_cache, 'gh-actions-artifact')
	})
	// This subclass resolves every Actions artifact to a zip, independently of
	// the extension (or lack of one) in the API URL.
	file.resolved_url_value = url
	file.resolved_basename_value = github_artifact_resolved_basename
	file.has_resolved_url_basename = true
	return GitHubArtifactDownloadStrategy{
		file: file
		homebrew_cache: homebrew_cache
		token: token
	}
}

pub fn (mut strategy GitHubArtifactDownloadStrategy) cached_location() string {
	if strategy.cached_location_value != '' {
		return strategy.cached_location_value
	}
	digest := sha256.sum256(strategy.file.base.url.bytes()).hex()
	downloads_directory := os.join_path(strategy.homebrew_cache, 'downloads')
	mut matches := []string{}
	if os.is_dir(downloads_directory) {
		for entry in os.ls(downloads_directory) or { [] } {
			if entry.starts_with('${digest}--') && !entry.ends_with('.incomplete') {
				matches << os.join_path(downloads_directory, entry)
			}
		}
	}
	strategy.cached_location_value = if matches.len == 1 {
		matches[0]
	} else {
		os.join_path(downloads_directory, '${digest}--${github_artifact_resolved_basename}')
	}
	return strategy.cached_location_value
}

pub fn (mut strategy GitHubArtifactDownloadStrategy) temporary_path() string {
	return '${strategy.cached_location()}.incomplete'
}

pub fn (strategy &GitHubArtifactDownloadStrategy) symlink_location() string {
	return strategy.file.symlink_location()
}

pub fn (strategy &GitHubArtifactDownloadStrategy) download_request(temporary_path string, timeout ?f64) GitHubArtifactDownloadRequest {
	return GitHubArtifactDownloadRequest{
		url: strategy.file.base.url
		destination: temporary_path
		header: 'Authorization: token ${strategy.token}'
		secrets: [strategy.token]
		timeout: timeout
	}
}

fn github_artifact_symlink_target(cached_location string) string {
	return os.join_path('..', 'downloads', os.file_name(cached_location))
}

fn replace_github_artifact_symlink(location string, target string) ! {
	os.mkdir_all(os.dir(location))!
	if os.exists(location) || os.is_link(location) {
		os.rm(location)!
	}
	os.symlink(target, location)!
}

pub fn (mut strategy GitHubArtifactDownloadStrategy) fetch(timeout ?f64, downloader GitHubArtifactDownloader) !GitHubArtifactFetchResult {
	url := strategy.file.base.url
	cached := strategy.cached_location()
	temporary := strategy.temporary_path()
	location := strategy.symlink_location()
	target := github_artifact_symlink_target(cached)
	mut messages := ['Downloading ${url}']
	mut request := GitHubArtifactDownloadRequest{}
	mut downloaded := false
	mut already_downloaded := false
	mut has_download_request := false
	if os.exists(cached) {
		already_downloaded = true
		messages << 'Already downloaded: ${cached}'
	} else {
		request = strategy.download_request(temporary, timeout)
		has_download_request = true
		os.mkdir_all(os.dir(temporary))!
		downloader(request) or {
			return error('CurlDownloadStrategyError: ${url}')
		}
		os.mkdir_all(os.dir(cached))!
		os.rename(temporary, cached)!
		downloaded = true
	}
	replace_github_artifact_symlink(location, target)!
	return GitHubArtifactFetchResult{
		cached_location: cached
		temporary_path: temporary
		symlink_location: location
		symlink_target: target
		download_request: request
		has_download_request: has_download_request
		downloaded: downloaded
		already_downloaded: already_downloaded
		messages: messages
	}
}

// Ruby method `initialize(url, artifact_id, token:)` at line 7.
pub fn ruby_github_artifact_download_strategy_l7_d1_initialize(url string, artifact_id string, token string, homebrew_cache ...string) GitHubArtifactDownloadStrategy {
	if homebrew_cache.len > 0 {
		return new_github_artifact_download_strategy_with_cache(url, artifact_id, token, homebrew_cache[0])
	}
	return new_github_artifact_download_strategy(url, artifact_id, token)
}

// Ruby method `fetch(timeout: nil)` at line 14.
pub fn ruby_github_artifact_download_strategy_l14_d2_fetch(mut strategy GitHubArtifactDownloadStrategy, timeout ?f64, downloader GitHubArtifactDownloader) !GitHubArtifactFetchResult {
	return strategy.fetch(timeout, downloader)
}

// Ruby method `resolved_basename` at line 38.
pub fn ruby_github_artifact_download_strategy_l38_d3_resolved_basename(_ &GitHubArtifactDownloadStrategy) string {
	return github_artifact_resolved_basename
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading an artifact from GitHub Actions.
// 5: class GitHubArtifactDownloadStrategy < AbstractFileDownloadStrategy
// 6:   sig { params(url: String, artifact_id: String, token: String).void }
// 7:   def initialize(url, artifact_id, token:)
// 8:     super(url, "artifact", artifact_id)
// 9:     @cache = T.let(HOMEBREW_CACHE/"gh-actions-artifact", Pathname)
// 10:     @token = token
// 11:   end
// 12:
// 13:   sig { override.params(timeout: T.nilable(T.any(Float, Integer))).void }
// 14:   def fetch(timeout: nil)
// 15:     ohai "Downloading #{url}"
// 16:     if cached_location.exist?
// 17:       puts "Already downloaded: #{cached_location}"
// 18:     else
// 19:       begin
// 20:         Utils::Curl.curl_download(url, to:      temporary_path,
// 21:                                        header:  "Authorization: token #{@token}",
// 22:                                        secrets: [@token],
// 23:                                        timeout:)
// 24:       rescue ErrorDuringExecution
// 25:         raise CurlDownloadStrategyError, url
// 26:       end
// 27:       cached_location.dirname.mkpath
// 28:       temporary_path.rename(cached_location.to_s)
// 29:     end
// 30:
// 31:     symlink_location.dirname.mkpath
// 32:     FileUtils.ln_s cached_location.relative_path_from(symlink_location.dirname), symlink_location, force: true
// 33:   end
// 34:
// 35:   private
// 36:
// 37:   sig { returns(String) }
// 38:   def resolved_basename
// 39:     "artifact.zip"
// 40:   end
// 41: end
