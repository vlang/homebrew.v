module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/ruby_gems.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RubyGemsInputValues {
pub:
	present bool
	url     string
}

pub struct RubyGemsFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn ruby_gems_ascii_alphanumeric(character u8) bool {
	return (character >= `0` && character <= `9`) || (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`)
}

fn ruby_gems_valid_version(value string) bool {
	if value == '' {
		return false
	}
	mut index := 0
	for index < value.len && value[index] >= `0` && value[index] <= `9` {
		index++
	}
	if index == 0 {
		return false
	}
	for index < value.len {
		if value[index] != `.` {
			return false
		}
		index++
		segment_start := index
		for index < value.len && ruby_gems_ascii_alphanumeric(value[index]) {
			index++
		}
		if index == segment_start {
			return false
		}
	}
	return true
}

fn ruby_gems_version_and_platform_valid(value string) bool {
	if platform_separator := value.index('-') {
		return platform_separator > 0 && platform_separator + 1 < value.len && ruby_gems_valid_version(value[..platform_separator])
	}
	return ruby_gems_valid_version(value)
}

fn ruby_gems_filename_gem_name(filename string) ?string {
	candidate := if filename.ends_with('\n') {
		filename[..filename.len - 1]
	} else {
		filename
	}
	if candidate.contains('\n') || candidate.len <= '.gem'.len || !candidate.to_lower().ends_with('.gem') {
		return none
	}
	body := candidate[..candidate.len - '.gem'.len]
	mut separator := body.len - 1
	for separator > 0 {
		if body[separator] == `-` && ruby_gems_version_and_platform_valid(body[separator + 1..]) {
			return body[..separator]
		}
		separator--
	}
	return none
}

fn ruby_gems_url_gem_name(url string) ?string {
	lower := url.to_lower()
	mut path_start := 0
	if lower.starts_with('https://rubygems.org/') {
		path_start = 'https://rubygems.org/'.len
	} else if lower.starts_with('http://rubygems.org/') {
		path_start = 'http://rubygems.org/'.len
	} else {
		return none
	}
	path := url[path_start..]
	lower_path := lower[path_start..]
	if lower_path.starts_with('downloads/') {
		return ruby_gems_filename_gem_name(path['downloads/'.len..])
	}
	if !lower_path.starts_with('gems/') {
		return none
	}
	gems_path := path['gems/'.len..]
	versions_separator := gems_path.index('/') or { return none }
	if versions_separator == 0 {
		return none
	}
	versions_prefix := '/versions/'
	if !gems_path[versions_separator..].to_lower().starts_with(versions_prefix) {
		return none
	}
	filename_start := versions_separator + versions_prefix.len
	return ruby_gems_filename_gem_name(gems_path[filename_start..])
}

fn ruby_gems_encode_www_form_component(value string) string {
	hex := '0123456789ABCDEF'
	mut encoded := []u8{cap: value.len}
	for character in value.bytes() {
		if ruby_gems_ascii_alphanumeric(character) || character in [`*`, `-`, `.`, `_`] {
			encoded << character
		} else if character == ` ` {
			encoded << `+`
		} else {
			encoded << `%`
			encoded << hex[character >> 4]
			encoded << hex[character & 15]
		}
	}
	return encoded.bytestr()
}

pub fn rubygems_matches_url(url string) bool {
	return ruby_gems_url_gem_name(url) != none
}

pub fn rubygems_generate_input_values(url string) RubyGemsInputValues {
	gem_name := ruby_gems_url_gem_name(url) or { return RubyGemsInputValues{} }
	return RubyGemsInputValues{
		present: true
		url: 'https://rubygems.org/api/v1/versions/${ruby_gems_encode_www_form_component(gem_name)}/latest.json'
	}
}

fn ruby_gems_default_block(document json2.Any,
	_ ?JsonRegex) !livecheck.StrategyBlockValue {
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

pub fn rubygems_find_versions(request RubyGemsFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := rubygems_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
		}
	}
	return json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: request.regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 1 }
		block: if request.has_block { request.block } else { ruby_gems_default_block }
	}, fetcher)
}

fn ruby_gems_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

// Ruby method `self.match?(url)` at line 46.
pub fn ruby_ruby_gems_l46_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(rubygems_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 56.
pub fn ruby_ruby_gems_l56_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := rubygems_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url': brew_runtime.string_value(generated.url)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 83.
pub fn ruby_ruby_gems_l83_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := rubygems_find_versions(RubyGemsFindRequest{
		url: args[0].as_string()
		content: content
	}, ruby_gems_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
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
// 9:       # The {RubyGems} strategy identifies the newest version of a RubyGems
// 10:       # package by checking the latest version API endpoint for the gem.
// 11:       #
// 12:       # RubyGems URLs have a standard format:
// 13:       #   `https://rubygems.org/downloads/example-1.2.3.gem`
// 14:       #
// 15:       # @api public
// 16:       class RubyGems
// 17:         extend Strategic
// 18:
// 19:         # The default `strategy` block used to extract version information when
// 20:         # a `strategy` block isn't provided.
// 21:         DEFAULT_BLOCK = T.let(proc do |json|
// 22:           json["version"]
// 23:         end.freeze, T.proc.params(
// 24:           arg0: T::Hash[String, T.anything],
// 25:         ).returns(T.any(String, T::Array[String])))
// 26:
// 27:         FILENAME_REGEX = /
// 28:           (?<gem_name>.+)- # The gem name followed by a hyphen
// 29:           (?<version>\d+(?:\.[0-9A-Za-z]+)*) # The version string
// 30:           (?:-(?<platform>.+))? # The optional platform
// 31:           \.gem$
// 32:         /ix
// 33:
// 34:         # The `Regexp` used to determine if the strategy applies to the URL.
// 35:         URL_MATCH_REGEX = %r{
// 36:           ^https?://rubygems\.org
// 37:           /(?:downloads|gems/[^/]+/versions)
// 38:           /#{FILENAME_REGEX.source.strip} # The gem filename
// 39:         }ix
// 40:
// 41:         # Whether the strategy can be applied to the provided URL.
// 42:         #
// 43:         # @param url [String] the URL to match against
// 44:         # @return [Boolean]
// 45:         sig { override.params(url: String).returns(T::Boolean) }
// 46:         def self.match?(url)
// 47:           URL_MATCH_REGEX.match?(url)
// 48:         end
// 49:
// 50:         # Extracts the gem name from the provided URL and uses it to generate
// 51:         # the RubyGems latest version API URL for the gem.
// 52:         #
// 53:         # @param url [String] the URL used to generate values
// 54:         # @return [Hash]
// 55:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 56:         def self.generate_input_values(url)
// 57:           values = {}
// 58:           return values unless (match = url.match(URL_MATCH_REGEX))
// 59:
// 60:           values[:url] = "https://rubygems.org/api/v1/versions/" \
// 61:                          "#{URI.encode_www_form_component(T.must(match[:gem_name]))}/latest.json"
// 62:
// 63:           values
// 64:         end
// 65:
// 66:         # Generates a RubyGems latest version API URL for the gem and
// 67:         # identifies new versions using {Json#find_versions} with a block.
// 68:         #
// 69:         # @param url [String] the URL of the content to check
// 70:         # @param regex [Regexp, nil] a regex for matching versions in content
// 71:         # @param content [String, nil] content to check instead of fetching
// 72:         # @param options [Options] options to modify behavior
// 73:         # @return [Hash]
// 74:         sig {
// 75:           override.params(
// 76:             url:     String,
// 77:             regex:   T.nilable(Regexp),
// 78:             content: T.nilable(String),
// 79:             options: Options,
// 80:             block:   T.nilable(Proc),
// 81:           ).returns(T::Hash[Symbol, T.anything])
// 82:         }
// 83:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 84:           match_data = { matches: {}, regex:, url: }
// 85:
// 86:           generated = generate_input_values(url)
// 87:           return match_data if generated.blank?
// 88:
// 89:           Json.find_versions(
// 90:             url:     generated[:url],
// 91:             regex:,
// 92:             content:,
// 93:             options:,
// 94:             &block || DEFAULT_BLOCK
// 95:           )
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
