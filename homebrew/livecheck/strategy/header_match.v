module strategy

import ruby
import json2
import regex

// Translated from Homebrew/brew `livecheck/strategy/header_match.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type HeaderMatchBlock = fn(HeaderMatchHeaders, []HeaderMatchHeaders, ?GithubReleasesRegex) GithubReleasesBlockValue

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

pub type HeaderMatchFetcher = fn(string) ![]HeaderMatchHeaders

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

// Ruby method `self.match?(url)` at line 32.
pub fn ruby_header_match_l32_d1_self_match(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(header_match_matches_url(args[0].as_string()))
}

// Ruby method `self.versions_from_content(headers, regex = nil, &block)` at line 49.
pub fn ruby_header_match_l49_d2_self_versions_from_content(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	content := args[0].as_string()
	headers := header_match_headers_from_json(content) or {
		return ruby.object_value('JsonError', err.msg())
	}
	match_regex := if args.len > 1 && args[1].as_string() != '' {
		?GithubReleasesRegex(GithubReleasesRegex{ pattern: args[1].as_string() })
	} else {
		none
	}
	versions := header_match_versions_from_content(HeaderMatchVersionsRequest{
		headers: headers
		regex: match_regex
	}) or { return ruby.object_value('Error', err.msg()) }
	return ruby.string_array_value(versions)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 98.
pub fn ruby_header_match_l98_d3_self_find_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := header_match_find_versions(HeaderMatchFindRequest{
		url: args[0].as_string()
		content: content
	}, header_match_empty_fetcher) or { return ruby.object_value('Error', err.msg()) }
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.string_value(version)
	}
	mut values := {
		'matches': ruby.map_value(matches)
		'url':     ruby.string_value(result.url)
	}
	if match_regex := result.regex {
		values['regex'] = ruby.string_value(match_regex.pattern)
	} else {
		values['regex'] = ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if result.has_cached {
		values['cached'] = ruby.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = ruby.string_value(result.content)
	}
	return ruby.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategic"
// 5:
// 6: module Homebrew
// 7:   module Livecheck
// 8:     module Strategy
// 9:       # The {HeaderMatch} strategy follows all URL redirections and scans
// 10:       # the resulting headers for matching text using the provided regex.
// 11:       #
// 12:       # This strategy is not applied automatically and it's necessary to use
// 13:       # `strategy :header_match` in a `livecheck` block to apply it.
// 14:       class HeaderMatch
// 15:         extend Strategic
// 16:
// 17:         # A priority of zero causes livecheck to skip the strategy. We do this
// 18:         # for {HeaderMatch} so we can selectively apply it when appropriate.
// 19:         PRIORITY = 0
// 20:
// 21:         # The `Regexp` used to determine if the strategy applies to the URL.
// 22:         URL_MATCH_REGEX = %r{^https?://}i
// 23:
// 24:         # The header fields to check when a `strategy` block isn't provided.
// 25:         DEFAULT_HEADERS_TO_CHECK = ["content-disposition", "location"].freeze
// 26:
// 27:         # Whether the strategy can be applied to the provided URL.
// 28:         #
// 29:         # @param url [String] the URL to match against
// 30:         # @return [Boolean]
// 31:         sig { override.params(url: String).returns(T::Boolean) }
// 32:         def self.match?(url)
// 33:           URL_MATCH_REGEX.match?(url)
// 34:         end
// 35:
// 36:         # Identify versions from HTTP headers.
// 37:         #
// 38:         # @param headers [Array<Hash<String, String>>] an array of response HTTP
// 39:         #   header hashes to check for versions
// 40:         # @param regex [Regexp, nil] a regex for matching versions in content
// 41:         # @return [Array]
// 42:         sig {
// 43:           params(
// 44:             headers: T::Array[T::Hash[String, T.any(String, T::Array[String])]],
// 45:             regex:   T.nilable(Regexp),
// 46:             block:   T.nilable(Proc),
// 47:           ).returns(T::Array[String])
// 48:         }
// 49:         def self.versions_from_content(headers, regex = nil, &block)
// 50:           # Merge the last value of each header from all responses into one hash
// 51:           # for convenience
// 52:           merged_headers = T.cast(headers.reduce(&:merge), T::Hash[String, T.any(String, T::Array[String])])
// 53:
// 54:           if block
// 55:             block_return_value = case block.parameters[0]
// 56:             when [:opt, :headers], [:req, :headers], [:rest], [:req]
// 57:               regex.present? ? yield(merged_headers, regex) : yield(merged_headers)
// 58:             when [:opt, :all_headers], [:req, :all_headers]
// 59:               regex.present? ? yield(headers, regex) : yield(headers)
// 60:             else
// 61:               raise ArgumentError,
// 62:                     "First argument of #{Utils.demodulize(name)} `strategy` block must be `headers` or `all_headers`"
// 63:             end
// 64:             return Strategy.handle_block_return(block_return_value)
// 65:           end
// 66:
// 67:           DEFAULT_HEADERS_TO_CHECK.filter_map do |header_name|
// 68:             header_value = merged_headers[header_name]
// 69:             header_value = header_value.last if header_value.is_a?(Array)
// 70:             next if header_value.blank?
// 71:
// 72:             if regex
// 73:               header_value[regex, 1]
// 74:             else
// 75:               v = Version.parse(header_value, detected_from_url: true)
// 76:               v.null? ? nil : v.to_s
// 77:             end
// 78:           end.uniq
// 79:         end
// 80:
// 81:         # Checks the final URL for new versions after following all redirections,
// 82:         # using the provided regex for matching.
// 83:         #
// 84:         # @param url [String] the URL to fetch
// 85:         # @param regex [Regexp, nil] a regex for matching versions
// 86:         # @param content [String, nil] content to check instead of fetching
// 87:         # @param options [Options] options to modify behavior
// 88:         # @return [Hash]
// 89:         sig {
// 90:           override.params(
// 91:             url:     String,
// 92:             regex:   T.nilable(Regexp),
// 93:             content: T.nilable(String),
// 94:             options: Options,
// 95:             block:   T.nilable(Proc),
// 96:           ).returns(T::Hash[Symbol, T.anything])
// 97:         }
// 98:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 99:           match_data = { matches: {}, regex:, url: }
// 100:           match_data[:cached] = true if content
// 101:           return match_data if url.blank?
// 102:
// 103:           content = if content
// 104:             Json.parse_json(content)
// 105:           else
// 106:             match_data[:content] = Strategy.page_headers(url, options:)
// 107:           end
// 108:           return match_data if content.blank?
// 109:
// 110:           versions_from_content(content, regex, &block).each do |version_text|
// 111:             match_data[:matches][version_text] = Version.new(version_text)
// 112:           end
// 113:
// 114:           require "json"
// 115:           match_data[:content] = JSON.generate(match_data[:content]) unless match_data[:cached]
// 116:           match_data
// 117:         end
// 118:       end
// 119:     end
// 120:   end
// 121: end
