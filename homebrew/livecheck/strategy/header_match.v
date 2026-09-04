module strategy

import ruby
import json2
import regex

// Translated from Homebrew/brew `livecheck/strategy/header_match.rb`.
pub const header_match_priority = 0

pub struct HeaderMatchValue {
pub:
	values []string
}

pub type HeaderMatchHeaders = map[string]HeaderMatchValue

pub enum HeaderMatchBlockArgument {
	headers
	all_headers
	invalid
}

pub type HeaderMatchBlock = fn (HeaderMatchHeaders, []HeaderMatchHeaders, ?GithubReleasesRegex) GithubReleasesBlockValue

pub struct HeaderMatchVersionsRequest {
pub:
	headers        []HeaderMatchHeaders
	regex          ?GithubReleasesRegex
	has_block      bool
	block_argument HeaderMatchBlockArgument = .headers
	block          HeaderMatchBlock = unsafe { nil }
}

pub struct HeaderMatchFindRequest {
pub:
	url            string
	regex          ?GithubReleasesRegex
	content        ?string
	has_block      bool
	block_argument HeaderMatchBlockArgument = .headers
	block          HeaderMatchBlock = unsafe { nil }
}

pub struct HeaderMatchData {
pub:
	matches     map[string]string
	regex       ?GithubReleasesRegex
	url         string
	cached      bool
	has_cached  bool
	content     string
	has_content bool
}

pub type HeaderMatchFetcher = fn (string) ![]HeaderMatchHeaders

pub fn header_match_matches_url(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

pub fn header_match_string(value string) HeaderMatchValue {
	return HeaderMatchValue{ values: [value] }
}

pub fn header_match_strings(values []string) HeaderMatchValue {
	return HeaderMatchValue{ values: values.clone() }
}

fn header_match_capture(value string, match_regex GithubReleasesRegex) ?string {
	pattern := match_regex.pattern.replace('[._-]', '[-._]').replace('[.-]', '[-.]').replace('[_-]', '[-_]').replace('.*?', '.*')
	mut expression := regex.regex_opt(pattern) or { return none }
	if match_regex.case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	return expression.get_group_by_id(value, 0)
}

pub fn header_match_capture_version(value string, match_regex GithubReleasesRegex) ?string {
	return header_match_capture(value, match_regex)
}

fn header_match_detect_version(value string) ?string {
	return header_match_capture(value, GithubReleasesRegex{
		pattern: r'v?(\d+(?:\.\d+)+)'
		case_insensitive: true
	})
}

pub fn header_match_merge_headers(headers []HeaderMatchHeaders) HeaderMatchHeaders {
	mut merged := HeaderMatchHeaders{}
	for response in headers {
		for name, value in response {
			merged[name.to_lower()] = HeaderMatchValue{ values: value.values.clone() }
		}
	}
	return merged
}

pub fn header_match_versions_from_content(request HeaderMatchVersionsRequest) ![]string {
	merged := header_match_merge_headers(request.headers)
	if request.has_block {
		if request.block_argument == .invalid {
			return error('First argument of HeaderMatch `strategy` block must be `headers` or `all_headers`')
		}
		return github_releases_handle_block(request.block(merged, request.headers, request.regex))
	}
	mut versions := []string{}
	for name in ['content-disposition', 'location'] {
		header := merged[name] or { continue }
		if header.values.len == 0 {
			continue
		}
		value := header.values.last().trim_space()
		if value == '' {
			continue
		}
		version := if match_regex := request.regex {
			header_match_capture(value, match_regex) or { continue }
		} else {
			header_match_detect_version(value) or { continue }
		}
		if version !in versions {
			versions << version
		}
	}
	return versions
}

pub fn header_match_headers_from_json(content string) ![]HeaderMatchHeaders {
	decoded := json2.decode[json2.Any](content)!
	mut responses := []HeaderMatchHeaders{}
	match decoded {
		[]json2.Any {
			for raw_response in decoded {
				match raw_response {
					map[string]json2.Any {
						mut response := HeaderMatchHeaders{}
						for name, raw_value in raw_response {
							match raw_value {
								string {
									response[name] = header_match_string(raw_value)
								}
								[]json2.Any {
									mut values := []string{}
									for item in raw_value {
										if item is string {
											values << item
										}
									}
									response[name] = header_match_strings(values)
								}
								else {}
							}
						}
						responses << response
					}
					else {}
				}
			}
		}
		else {}
	}
	return responses
}

pub fn header_match_headers_json(headers []HeaderMatchHeaders) string {
	mut responses := []json2.Any{}
	for response in headers {
		mut values := map[string]json2.Any{}
		for name, value in response {
			if value.values.len == 1 {
				values[name] = json2.Any(value.values[0])
			} else {
				values[name] = json2.Any(value.values.map(json2.Any(it)))
			}
		}
		responses << json2.Any(values)
	}
	return json2.encode(responses)
}

pub fn header_match_find_versions(request HeaderMatchFindRequest, fetcher HeaderMatchFetcher) !HeaderMatchData {
	mut result := HeaderMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut headers := []HeaderMatchHeaders{}
	if supplied_content := request.content {
		result = HeaderMatchData{
			...result
			cached: true
			has_cached: true
		}
		if request.url == '' {
			return result
		}
		headers = header_match_headers_from_json(supplied_content)!
	} else {
		if request.url == '' {
			return result
		}
		headers = fetcher(request.url)!
		result = HeaderMatchData{
			...result
			content: header_match_headers_json(headers)
			has_content: true
		}
	}
	if headers.len == 0 || headers.all(it.len == 0) {
		return result
	}
	versions := header_match_versions_from_content(HeaderMatchVersionsRequest{
		headers: headers
		regex: request.regex
		has_block: request.has_block
		block_argument: request.block_argument
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return HeaderMatchData{
		...result
		matches: matches
	}
}

fn header_match_empty_fetcher(url string) ![]HeaderMatchHeaders {
	return []HeaderMatchHeaders{}
}
