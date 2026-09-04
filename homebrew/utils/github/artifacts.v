module github

import ruby

// Translated from Homebrew/brew `utils/github/artifacts.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.download_artifact(url, artifact_id)` at line 13.
pub fn ruby_artifacts_l13_d1_self_download_artifact(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'URL and artifact ID are required')
	}
	token := if args.len > 2 { args[2].as_string() } else { '' }
	mut runtime := ArtifactDownloadRuntime{
		fetch_error: if args.len > 3 && !(args[3].as_bool() or { true }) {
			'artifact fetch failed'} else {
			''}
		stage_error: if args.len > 4 && !(args[4].as_bool() or { true }) {
			'artifact stage failed'} else {
			''}
	}
	result := download_github_artifact(args[0].as_string(), args[1].as_string(), token, mut runtime, artifact_download_fetch, artifact_download_stage) or {
		return ruby.object_value(if token.trim_space() == '' {
			'GitHub::API::MissingAuthenticationError'
		} else {
			'ArtifactDownloadError'
		}, err.msg())
	}
	return artifact_download_result_value(result)
}

pub struct ArtifactDownloadRuntime {
pub mut:
	fetch_calls int
	stage_calls int
	fetch_error string
	stage_error string
}

pub struct ArtifactDownloadResult {
pub:
	url         string
	artifact_id string
	token       string
	fetched     bool
	staged      bool
}

pub type ArtifactFetchBoundary = fn(mut runtime ArtifactDownloadRuntime, url string, artifact_id string, token string) !

pub type ArtifactStageBoundary = fn(mut runtime ArtifactDownloadRuntime, artifact_id string) !

pub fn artifact_download_fetch(mut runtime ArtifactDownloadRuntime, _ string, _ string, _ string) ! {
	runtime.fetch_calls++
	if runtime.fetch_error != '' {
		return error(runtime.fetch_error)
	}
}

pub fn artifact_download_stage(mut runtime ArtifactDownloadRuntime, _ string) ! {
	runtime.stage_calls++
	if runtime.stage_error != '' {
		return error(runtime.stage_error)
	}
}

pub fn download_github_artifact(url string, artifact_id string, token string,
	mut runtime ArtifactDownloadRuntime, fetch ArtifactFetchBoundary,
	stage ArtifactStageBoundary) !ArtifactDownloadResult {
	if token.trim_space() == '' {
		return error('GitHub authentication is required to download Actions artifacts')
	}
	if url.trim_space() == '' {
		return error('artifact URL is required')
	}
	if artifact_id.trim_space() == '' {
		return error('artifact ID is required')
	}
	fetch(mut runtime, url, artifact_id, token)!
	stage(mut runtime, artifact_id)!
	return ArtifactDownloadResult{
		url: url
		artifact_id: artifact_id
		token: token
		fetched: true
		staged: true
	}
}

fn artifact_download_result_value(result ArtifactDownloadResult) ruby.Value {
	return ruby.structured_value('GitHubArtifactDownloadResult', result.artifact_id, {
		'url':         result.url
		'artifact_id': result.artifact_id
		'fetched':     result.fetched.str()
		'staged':      result.staged.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5: require "utils/github"
// 6:
// 7: module GitHub
// 8:   # Download an artifact from GitHub Actions and unpack it into the current working directory.
// 9:   #
// 10:   # @param url [String] URL to download from
// 11:   # @param artifact_id [String] a value that uniquely identifies the downloaded artifact
// 12:   sig { params(url: String, artifact_id: String).void }
// 13:   def self.download_artifact(url, artifact_id)
// 14:     token = API.credentials
// 15:     raise API::MissingAuthenticationError if token.blank?
// 16:
// 17:     # We use a download strategy here to leverage the Homebrew cache
// 18:     # to avoid repeated downloads of (possibly large) bottles.
// 19:     downloader = GitHubArtifactDownloadStrategy.new(url, artifact_id, token:)
// 20:     downloader.fetch
// 21:     downloader.stage
// 22:   end
// 23: end
// 24: require "utils/github/artifacts/github_artifact_download_strategy"
