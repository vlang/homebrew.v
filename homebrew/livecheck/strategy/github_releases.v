module strategy

import ruby
import json2
import regex

// Translated from Homebrew/brew `livecheck/strategy/github_releases.rb`.
pub const github_releases_priority = 0
pub const github_releases_default_pattern = r'v?(\d+(?:\.\d+)+)'

pub struct GithubReleasesRegex {
pub:
	pattern          string = github_releases_default_pattern
	case_insensitive bool = true
}

pub struct GithubReleasesInputValues {
pub:
	present    bool
	url        string
	username   string
	repository string
}

pub struct GithubRelease {
pub:
	tag_name   string
	name       string
	draft      bool
	prerelease bool
}

pub enum GithubReleasesBlockKind {
	string_value
	array
	nil_value
	invalid
}

pub struct GithubReleasesBlockValue {
pub:
	kind   GithubReleasesBlockKind
	value  string
	values []string
}

pub type GithubReleasesBlock = fn ([]GithubRelease, GithubReleasesRegex) GithubReleasesBlockValue

pub struct GithubReleasesVersionsRequest {
pub:
	content   string
	regex     GithubReleasesRegex = GithubReleasesRegex{}
	has_block bool
	block     GithubReleasesBlock = unsafe { nil }
}

pub struct GithubReleasesFindRequest {
pub:
	url       string
	regex     GithubReleasesRegex = GithubReleasesRegex{}
	content   ?string
	has_block bool
	block     GithubReleasesBlock = unsafe { nil }
}

pub struct GithubReleasesMatchData {
pub:
	matches     map[string]string
	regex       GithubReleasesRegex
	url         string
	cached      bool
	has_cached  bool
	content     string
	has_content bool
}

pub type GithubReleasesFetcher = fn (string) !string

fn github_releases_owner_repository(url string) GithubReleasesInputValues {
	trimmed := if url.ends_with('.git') { url[..url.len - 4] } else { url }
	lower := trimmed.to_lower()
	prefix_length := if lower.starts_with('https://github.com/') {
		'https://github.com/'.len
	} else if lower.starts_with('http://github.com/') {
		'http://github.com/'.len
	} else {
		return GithubReleasesInputValues{}
	}
	mut path := trimmed[prefix_length..]
	if path.to_lower().starts_with('downloads/') {
		path = path['downloads/'.len..]
	}
	parts := path.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return GithubReleasesInputValues{}
	}
	return GithubReleasesInputValues{
		present: true
		url: 'https://api.github.com/repos/${parts[0]}/${parts[1]}/releases'
		username: parts[0]
		repository: parts[1]
	}
}

pub fn github_releases_matches_url(url string) bool {
	return github_releases_owner_repository(url).present
}

pub fn github_releases_generate_input_values(url string) GithubReleasesInputValues {
	return github_releases_owner_repository(url)
}

fn github_releases_json_bool(value json2.Any) bool {
	return if value is bool { value } else { false }
}

fn github_releases_json_string(value json2.Any) string {
	return if value is string { value } else { '' }
}

fn github_releases_parse_content(content string) ![]GithubRelease {
	if content.trim_space() == '' {
		return []GithubRelease{}
	}
	decoded := json2.decode[json2.Any](content)!
	mut raw_releases := []json2.Any{}
	match decoded {
		[]json2.Any {
			raw_releases = decoded.clone()
		}
		map[string]json2.Any { raw_releases << json2.Any(decoded.clone()) }
		else {
			return []GithubRelease{}
		}
	}
	mut releases := []GithubRelease{}
	for raw_release in raw_releases {
		if raw_release is map[string]json2.Any {
			values := raw_release.clone()
			releases << GithubRelease{
				tag_name: github_releases_json_string(values['tag_name'] or { json2.Any('') })
				name: github_releases_json_string(values['name'] or { json2.Any('') })
				draft: github_releases_json_bool(values['draft'] or { json2.Any(false) })
				prerelease: github_releases_json_bool(values['prerelease'] or { json2.Any(false) })
			}
		}
	}
	return releases
}

fn github_releases_capture(value string, match_regex GithubReleasesRegex) ?string {
	mut expression := regex.regex_opt(match_regex.pattern) or { return none }
	if match_regex.case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	return expression.get_group_by_id(value, 0)
}

fn github_releases_handle_block(value GithubReleasesBlockValue) ![]string {
	match value.kind {
		.string_value {
			return [value.value]
		}
		.array {
			mut versions := []string{}
			for item in value.values {
				if item != '' && item !in versions {
					versions << item
				}
			}
			return versions
		}
		.nil_value {
			return []string{}
		}
		.invalid {
			return error('Return value of a strategy block must be a string or array of strings.')
		}
	}
}

pub fn github_releases_versions_from_content(request GithubReleasesVersionsRequest) ![]string {
	releases := github_releases_parse_content(request.content)!
	if releases.len == 0 {
		return []string{}
	}
	if request.has_block {
		return github_releases_handle_block(request.block(releases, request.regex))
	}
	mut versions := []string{}
	for release in releases {
		if release.draft || release.prerelease || release.tag_name == '' {
			continue
		}
		version := github_releases_capture(release.tag_name, request.regex) or { continue }
		if version !in versions {
			versions << version
		}
	}
	return versions
}

pub fn github_releases_find_versions(request GithubReleasesFindRequest, fetcher GithubReleasesFetcher) !GithubReleasesMatchData {
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
	generated := github_releases_generate_input_values(request.url)
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

fn github_releases_empty_fetcher(url string) !string {
	return ''
}
