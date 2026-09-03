module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils
import net.urllib
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/npm.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct NpmInputValues {
pub:
	present bool
	url     string
}

pub struct NpmFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

pub fn npm_matches_url(url string) bool {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://registry.npmjs.org/') {
		'https://registry.npmjs.org/'.len
	} else if lower.starts_with('http://registry.npmjs.org/') {
		'http://registry.npmjs.org/'.len
	} else {
		return false
	}
	separator_index := url[prefix_length..].index('/-/') or { return false }
	return separator_index > 0
}

pub fn npm_generate_input_values(url string) NpmInputValues {
	if !npm_matches_url(url) {
		return NpmInputValues{}
	}
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://') {
		'https://registry.npmjs.org/'.len
	} else {
		'http://registry.npmjs.org/'.len
	}
	path := url[prefix_length..]
	package_name := path.all_before('/-/')
	if package_name == '' {
		return NpmInputValues{}
	}
	return NpmInputValues{
		present: true
		url: 'https://registry.npmjs.org/${urllib.query_escape(package_name)}/latest'
	}
}

fn npm_default_block(document json2.Any, _ ?JsonRegex) !livecheck.StrategyBlockValue {
	if document is map[string]json2.Any {
		version := document['version'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if version is string {
			return livecheck.StrategyBlockValue{
				kind: .string_value
				value: version
			}
		}
	}
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

pub fn npm_find_versions(request NpmFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := npm_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
			cached: request.content != none
			has_cached: request.content != none
		}
	}
	return json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: request.regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 1 }
		block: if request.has_block { request.block } else { npm_default_block }
	}, fetcher)
}

fn npm_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

// Ruby method `self.match?(url)` at line 40.
pub fn ruby_npm_l40_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(npm_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 50.
pub fn ruby_npm_l50_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := npm_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url': brew_runtime.string_value(generated.url)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 76.
pub fn ruby_npm_l76_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := npm_find_versions(NpmFindRequest{
		url: args[0].as_string()
		content: content
	}, npm_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	mut matches := map[string]brew_runtime.Value{}
	for version in result.matches.keys() {
		matches[version] = brew_runtime.string_value(version)
	}
	mut values := {
		'matches': brew_runtime.map_value(matches)
		'regex':   brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
		'url':     brew_runtime.string_value(result.url)
	}
	if result.has_cached {
		values['cached'] = brew_runtime.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = brew_runtime.string_value(result.content)
	}
	return brew_runtime.map_value(values)
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
// 9:       # The {Npm} strategy identifies versions of software at
// 10:       # registry.npmjs.org by checking the latest version for a package.
// 11:       #
// 12:       # npm URLs take one of the following formats:
// 13:       #
// 14:       # * `https://registry.npmjs.org/example/-/example-1.2.3.tgz`
// 15:       # * `https://registry.npmjs.org/@example/example/-/example-1.2.3.tgz`
// 16:       #
// 17:       # @api public
// 18:       class Npm
// 19:         extend Strategic
// 20:
// 21:         # The default `strategy` block used to extract version information when
// 22:         # a `strategy` block isn't provided.
// 23:         DEFAULT_BLOCK = T.let(proc do |json|
// 24:           json["version"]
// 25:         end.freeze, T.proc.params(
// 26:           arg0: T::Hash[String, T.anything],
// 27:         ).returns(T.any(String, T::Array[String])))
// 28:
// 29:         # The `Regexp` used to determine if the strategy applies to the URL.
// 30:         URL_MATCH_REGEX = %r{
// 31:           ^https?://registry\.npmjs\.org
// 32:           /(?<package_name>.+?)/-/ # The npm package name
// 33:         }ix
// 34:
// 35:         # Whether the strategy can be applied to the provided URL.
// 36:         #
// 37:         # @param url [String] the URL to match against
// 38:         # @return [Boolean]
// 39:         sig { override.params(url: String).returns(T::Boolean) }
// 40:         def self.match?(url)
// 41:           URL_MATCH_REGEX.match?(url)
// 42:         end
// 43:
// 44:         # Extracts information from a provided URL and uses it to generate
// 45:         # various input values used by the strategy to check for new versions.
// 46:         #
// 47:         # @param url [String] the URL used to generate values
// 48:         # @return [Hash]
// 49:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 50:         def self.generate_input_values(url)
// 51:           values = {}
// 52:           return values unless (match = url.match(URL_MATCH_REGEX))
// 53:
// 54:           values[:url] = "https://registry.npmjs.org/#{URI.encode_www_form_component(match[:package_name])}/latest"
// 55:
// 56:           values
// 57:         end
// 58:
// 59:         # Generates a URL and checks the content at the URL for new versions
// 60:         # using {Json.versions_from_content}.
// 61:         #
// 62:         # @param url [String] the URL of the content to check
// 63:         # @param regex [Regexp, nil] a regex for matching versions in content
// 64:         # @param content [String, nil] content to check instead of fetching
// 65:         # @param options [Options] options to modify behavior
// 66:         # @return [Hash]
// 67:         sig {
// 68:           override.params(
// 69:             url:     String,
// 70:             regex:   T.nilable(Regexp),
// 71:             content: T.nilable(String),
// 72:             options: Options,
// 73:             block:   T.nilable(Proc),
// 74:           ).returns(T::Hash[Symbol, T.anything])
// 75:         }
// 76:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 77:           match_data = { matches: {}, regex:, url: }
// 78:           match_data[:cached] = true if content
// 79:
// 80:           generated = generate_input_values(url)
// 81:           return match_data if generated.blank?
// 82:
// 83:           match_data[:url] = generated[:url]
// 84:
// 85:           unless match_data[:cached]
// 86:             match_data.merge!(Strategy.page_content(match_data[:url], options:))
// 87:             content = match_data[:content]
// 88:           end
// 89:           return match_data if content.blank?
// 90:
// 91:           Json.versions_from_content(content, regex, &block || DEFAULT_BLOCK).each do |match_text|
// 92:             match_data[:matches][match_text] = Version.new(match_text)
// 93:           end
// 94:
// 95:           match_data
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
