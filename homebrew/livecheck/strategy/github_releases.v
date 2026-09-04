module strategy

import ruby
import json2
import regex

// Translated from Homebrew/brew `livecheck/strategy/github_releases.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type GithubReleasesBlock = fn([]GithubRelease, GithubReleasesRegex) GithubReleasesBlockValue

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

pub type GithubReleasesFetcher = fn(string) !string

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

// Ruby method `self.match?(url)` at line 57.
pub fn ruby_github_releases_l57_d1_self_match(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(github_releases_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 69.
pub fn ruby_github_releases_l69_d2_self_generate_input_values(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	values := github_releases_generate_input_values(args[0].as_string())
	if !values.present {
		return ruby.map_value({})
	}
	return ruby.map_value({
		'url':        ruby.string_value(values.url)
		'username':   ruby.string_value(values.username)
		'repository': ruby.string_value(values.repository)
	})
}

// Ruby method `self.versions_from_content(content, regex, &block)` at line 96.
pub fn ruby_github_releases_l96_d3_self_versions_from_content(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	pattern := if args.len > 1 && args[1].as_string() != '' {
		args[1].as_string()
	} else {
		github_releases_default_pattern
	}
	versions := github_releases_versions_from_content(GithubReleasesVersionsRequest{
		content: args[0].as_string()
		regex: GithubReleasesRegex{ pattern: pattern }
	}) or { return ruby.object_value('JsonError', err.msg()) }
	return ruby.string_array_value(versions)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 132.
pub fn ruby_github_releases_l132_d4_self_find_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	url := args[0].as_string()
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := github_releases_find_versions(GithubReleasesFindRequest{
		url: url
		content: content
	}, github_releases_empty_fetcher) or { return ruby.object_value('Error', err.msg()) }
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.string_value(version)
	}
	mut values := {
		'matches': ruby.map_value(matches)
		'regex':   ruby.string_value(result.regex.pattern)
		'url':     ruby.string_value(result.url)
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
// 9:       # The {GithubReleases} strategy identifies versions of software at
// 10:       # github.com by checking a repository's recent releases using the
// 11:       # GitHub API.
// 12:       #
// 13:       # GitHub URLs take a few different formats:
// 14:       #
// 15:       # * `https://github.com/example/example/releases/download/1.2.3/example-1.2.3.tar.gz`
// 16:       # * `https://github.com/example/example/archive/v1.2.3.tar.gz`
// 17:       # * `https://github.com/downloads/example/example/example-1.2.3.tar.gz`
// 18:       #
// 19:       # {GithubReleases} should only be used when the upstream repository has
// 20:       # releases for suitable versions and the strategy is necessary or
// 21:       # appropriate (e.g. the formula/cask uses a release asset and the
// 22:       # {GithubLatest} strategy isn't sufficient to identify the newest version.
// 23:       # The strategy can only be applied by using `strategy :github_releases`
// 24:       # in a `livecheck` block.
// 25:       #
// 26:       # The default regex identifies versions like `1.2.3`/`v1.2.3` in each
// 27:       # release's tag or title. This is a common tag format but a modified
// 28:       # regex can be provided in a `livecheck` block to override the default
// 29:       # if a repository uses a different format (e.g. `1.2.3d`, `1.2.3-4`,
// 30:       # etc.).
// 31:       #
// 32:       # @api public
// 33:       class GithubReleases
// 34:         extend Strategic
// 35:
// 36:         # A priority of zero causes livecheck to skip the strategy. We do this
// 37:         # for {GithubReleases} so we can selectively apply the strategy using
// 38:         # `strategy :github_releases` in a `livecheck` block.
// 39:         PRIORITY = 0
// 40:
// 41:         # The `Regexp` used to determine if the strategy applies to the URL.
// 42:         URL_MATCH_REGEX = %r{
// 43:           ^https?://github\.com
// 44:           /(?:downloads/)?(?<username>[^/]+) # The GitHub username
// 45:           /(?<repository>[^/]+)              # The GitHub repository name
// 46:         }ix
// 47:
// 48:         # The default regex used to identify a version from a tag when a regex
// 49:         # isn't provided.
// 50:         DEFAULT_REGEX = /v?(\d+(?:\.\d+)+)/i
// 51:
// 52:         # Whether the strategy can be applied to the provided URL.
// 53:         #
// 54:         # @param url [String] the URL to match against
// 55:         # @return [Boolean]
// 56:         sig { override.params(url: String).returns(T::Boolean) }
// 57:         def self.match?(url)
// 58:           URL_MATCH_REGEX.match?(url)
// 59:         end
// 60:
// 61:         # Extracts information from a provided URL and uses it to generate
// 62:         # various input values used by the strategy to check for new versions.
// 63:         # Some of these values act as defaults and can be overridden in a
// 64:         # `livecheck` block.
// 65:         #
// 66:         # @param url [String] the URL used to generate values
// 67:         # @return [Hash]
// 68:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 69:         def self.generate_input_values(url)
// 70:           values = {}
// 71:
// 72:           match = url.delete_suffix(".git").match(URL_MATCH_REGEX)
// 73:           return values if match.blank?
// 74:
// 75:           values[:url] = "#{GitHub::API_URL}/repos/#{match[:username]}/#{match[:repository]}/releases"
// 76:           values[:username] = match[:username]
// 77:           values[:repository] = match[:repository]
// 78:
// 79:           values
// 80:         end
// 81:
// 82:         # Uses a regex to match versions from release JSON or, if a block is
// 83:         # provided, passes the JSON to the block to handle matching. With
// 84:         # either approach, an array of unique matches is returned.
// 85:         #
// 86:         # @param content [Array, Hash] an array of releases or a single release
// 87:         # @param regex [Regexp] a regex for matching versions in content
// 88:         # @return [Array]
// 89:         sig {
// 90:           params(
// 91:             content: String,
// 92:             regex:   Regexp,
// 93:             block:   T.nilable(Proc),
// 94:           ).returns(T::Array[String])
// 95:         }
// 96:         def self.versions_from_content(content, regex, &block)
// 97:           return [] if content.blank?
// 98:
// 99:           json = Json.parse_json(content)
// 100:           return [] if json.blank?
// 101:
// 102:           if block.present?
// 103:             block_return_value = yield(json, regex)
// 104:             return Strategy.handle_block_return(block_return_value)
// 105:           end
// 106:
// 107:           json = [json] unless json.is_a?(Array)
// 108:           json.compact_blank.filter_map do |release|
// 109:             next if release["draft"] || release["prerelease"]
// 110:
// 111:             release["tag_name"]&.[](regex, 1)
// 112:           end.uniq
// 113:         end
// 114:
// 115:         # Generates the GitHub API URL for the repository's recent releases
// 116:         # and identifies versions from the JSON response.
// 117:         #
// 118:         # @param url [String] the URL of the content to check
// 119:         # @param regex [Regexp] a regex for matching versions in content
// 120:         # @param content [Hash, nil] content to check instead of fetching
// 121:         # @param options [Options] options to modify behavior
// 122:         # @return [Hash]
// 123:         sig {
// 124:           override.params(
// 125:             url:     String,
// 126:             regex:   T.nilable(Regexp),
// 127:             content: T.nilable(String),
// 128:             options: Options,
// 129:             block:   T.nilable(Proc),
// 130:           ).returns(T::Hash[Symbol, T.anything])
// 131:         }
// 132:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 133:           regex ||= DEFAULT_REGEX
// 134:           match_data = { matches: {}, regex:, url: }
// 135:           match_data[:cached] = true if content
// 136:
// 137:           generated = generate_input_values(url)
// 138:           return match_data if generated.blank?
// 139:
// 140:           match_data[:url] = generated[:url]
// 141:
// 142:           unless match_data[:cached]
// 143:             match_data[:content] = GitHub::API.open_rest(generated[:url], parse_json: false)
// 144:             content = match_data[:content]
// 145:           end
// 146:           return match_data if content.blank?
// 147:
// 148:           versions_from_content(content, regex, &block).each do |match_text|
// 149:             match_data[:matches][match_text] = Version.new(match_text)
// 150:           end
// 151:
// 152:           match_data
// 153:         end
// 154:       end
// 155:     end
// 156:     GitHubReleases = Homebrew::Livecheck::Strategy::GithubReleases
// 157:   end
// 158: end
