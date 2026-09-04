module strategy

import ruby

// Translated from Homebrew/brew `livecheck/strategy/github_latest.rb`.
pub const github_latest_priority = 0

pub struct GithubLatestFindRequest {
pub:
	url       string
	regex     GithubReleasesRegex = GithubReleasesRegex{}
	content   ?string
	has_block bool
	block     GithubReleasesBlock = unsafe { nil }
}

pub fn github_latest_matches_url(url string) bool {
	return github_releases_matches_url(url)
}

pub fn github_latest_generate_input_values(url string) GithubReleasesInputValues {
	generated := github_releases_generate_input_values(url)
	if !generated.present {
		return generated
	}
	return GithubReleasesInputValues{
		...generated
		url: '${generated.url}/latest'
	}
}

pub fn github_latest_find_versions(request GithubLatestFindRequest, fetcher GithubReleasesFetcher) !GithubReleasesMatchData {
	mut result := GithubReleasesMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied_content := request.content {
		result = GithubReleasesMatchData{
			...result
			cached: true
			has_cached: true
		}
		content = supplied_content
	}
	generated := github_latest_generate_input_values(request.url)
	if !generated.present {
		return result
	}
	result = GithubReleasesMatchData{
		...result
		url: generated.url
	}
	if !result.has_cached {
		content = fetcher(generated.url)!
		result = GithubReleasesMatchData{
			...result
			content: content
			has_content: true
		}
	}
	if content.trim_space() == '' {
		return result
	}
	versions := github_releases_versions_from_content(GithubReleasesVersionsRequest{
		content: content
		regex: request.regex
		has_block: request.has_block
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return GithubReleasesMatchData{
		...result
		matches: matches
	}
}
