module strategy

import ruby

// Translated from Homebrew/brew `livecheck/strategy/github_latest.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.match?(url)` at line 45.
pub fn ruby_github_latest_l45_d1_self_match(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(github_latest_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 57.
pub fn ruby_github_latest_l57_d2_self_generate_input_values(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	values := github_latest_generate_input_values(args[0].as_string())
	if !values.present {
		return ruby.map_value({})
	}
	return ruby.map_value({
		'url':        ruby.string_value(values.url)
		'username':   ruby.string_value(values.username)
		'repository': ruby.string_value(values.repository)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 87.
pub fn ruby_github_latest_l87_d3_self_find_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := github_latest_find_versions(GithubLatestFindRequest{
		url: args[0].as_string()
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
// 9:       # The {GithubLatest} strategy identifies versions of software at
// 10:       # github.com by checking a repository's "latest" release using the
// 11:       # GitHub API.
// 12:       #
// 13:       # GitHub URLs take a few different formats:
// 14:       #
// 15:       # * `https://github.com/example/example/releases/download/1.2.3/example-1.2.3.tar.gz`
// 16:       # * `https://github.com/example/example/archive/v1.2.3.tar.gz`
// 17:       # * `https://github.com/downloads/example/example/example-1.2.3.tar.gz`
// 18:       #
// 19:       # {GithubLatest} should only be used when the upstream repository has a
// 20:       # "latest" release for a suitable version and the strategy is necessary
// 21:       # or appropriate (e.g. the formula/cask uses a release asset or the
// 22:       # {Git} strategy returns an unreleased version). The strategy can only
// 23:       # be applied by using `strategy :github_latest` in a `livecheck` block.
// 24:       #
// 25:       # The default regex identifies versions like `1.2.3`/`v1.2.3` in a
// 26:       # release's tag or title. This is a common tag format but a modified
// 27:       # regex can be provided in a `livecheck` block to override the default
// 28:       # if a repository uses a different format (e.g. `1.2.3d`, `1.2.3-4`,
// 29:       # etc.).
// 30:       #
// 31:       # @api public
// 32:       class GithubLatest
// 33:         extend Strategic
// 34:
// 35:         # A priority of zero causes livecheck to skip the strategy. We do this
// 36:         # for {GithubLatest} so we can selectively apply the strategy using
// 37:         # `strategy :github_latest` in a `livecheck` block.
// 38:         PRIORITY = 0
// 39:
// 40:         # Whether the strategy can be applied to the provided URL.
// 41:         #
// 42:         # @param url [String] the URL to match against
// 43:         # @return [Boolean]
// 44:         sig { override.params(url: String).returns(T::Boolean) }
// 45:         def self.match?(url)
// 46:           GithubReleases.match?(url)
// 47:         end
// 48:
// 49:         # Extracts information from a provided URL and uses it to generate
// 50:         # various input values used by the strategy to check for new versions.
// 51:         # Some of these values act as defaults and can be overridden in a
// 52:         # `livecheck` block.
// 53:         #
// 54:         # @param url [String] the URL used to generate values
// 55:         # @return [Hash]
// 56:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 57:         def self.generate_input_values(url)
// 58:           values = {}
// 59:
// 60:           match = url.delete_suffix(".git").match(GithubReleases::URL_MATCH_REGEX)
// 61:           return values if match.blank?
// 62:
// 63:           values[:url] = "#{GitHub::API_URL}/repos/#{match[:username]}/#{match[:repository]}/releases/latest"
// 64:           values[:username] = match[:username]
// 65:           values[:repository] = match[:repository]
// 66:
// 67:           values
// 68:         end
// 69:
// 70:         # Generates the GitHub API URL for the repository's "latest" release
// 71:         # and identifies the version from the JSON response.
// 72:         #
// 73:         # @param url [String] the URL of the content to check
// 74:         # @param regex [Regexp] a regex for matching versions in content
// 75:         # @param content [Hash, nil] content to check instead of fetching
// 76:         # @param options [Options] options to modify behavior
// 77:         # @return [Hash]
// 78:         sig {
// 79:           override.params(
// 80:             url:     String,
// 81:             regex:   T.nilable(Regexp),
// 82:             content: T.nilable(String),
// 83:             options: Options,
// 84:             block:   T.nilable(Proc),
// 85:           ).returns(T::Hash[Symbol, T.anything])
// 86:         }
// 87:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 88:           regex ||= GithubReleases::DEFAULT_REGEX
// 89:           match_data = { matches: {}, regex:, url: }
// 90:           match_data[:cached] = true if content
// 91:
// 92:           generated = generate_input_values(url)
// 93:           return match_data if generated.blank?
// 94:
// 95:           match_data[:url] = generated[:url]
// 96:
// 97:           unless match_data[:cached]
// 98:             match_data[:content] = GitHub::API.open_rest(generated[:url], parse_json: false)
// 99:             content = match_data[:content]
// 100:           end
// 101:           return match_data if content.blank?
// 102:
// 103:           GithubReleases.versions_from_content(content, regex, &block).each do |match_text|
// 104:             match_data[:matches][match_text] = Version.new(match_text)
// 105:           end
// 106:
// 107:           match_data
// 108:         end
// 109:       end
// 110:     end
// 111:   end
// 112: end
