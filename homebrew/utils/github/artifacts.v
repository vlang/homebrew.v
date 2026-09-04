module github

import ruby

// Translated from Homebrew/brew `utils/github/artifacts.rb`.

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

pub type ArtifactFetchBoundary = fn (mut runtime ArtifactDownloadRuntime, url string, artifact_id string, token string) !

pub type ArtifactStageBoundary = fn (mut runtime ArtifactDownloadRuntime, artifact_id string) !

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
