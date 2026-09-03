module strategy

import homebrew.livecheck
import yaml

// Translated from Homebrew/brew `livecheck/strategy/yaml.rb`.
// The original source is retained below until every stub has a typed V body.
pub const yaml_priority = 0

pub struct YamlRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type YamlVersionsBlock = fn(yaml.Any, ?YamlRegex) !livecheck.StrategyBlockValue

pub struct YamlVersionsRequest {
pub:
	content     string
	regex       ?YamlRegex
	has_block   bool
	block_arity int
	block       YamlVersionsBlock = unsafe { nil }
}

pub struct YamlFindVersionsRequest {
pub:
	url         string
	regex       ?YamlRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int
	block       YamlVersionsBlock = unsafe { nil }
}

pub struct YamlMatchData {
pub:
	matches       map[string]string
	regex         ?YamlRegex
	url           string
	cached        bool
	has_cached    bool
	content       string
	has_content   bool
	final_url     string
	has_final_url bool
	messages      []string
	has_messages  bool
}

pub fn yaml_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

fn yaml_invalid_block_scalar_header(content string) bool {
	for line in content.split_into_lines() {
		mut candidate := line.trim_space()
		if colon := candidate.index(':') {
			candidate = candidate[colon + 1..].trim_space()
		}
		if candidate.len < 2 || candidate[0] !in [`>`, `|`] {
			continue
		}
		mut saw_chomp := false
		mut saw_indent := false
		for character in candidate[1..] {
			if character.is_space() || character == `#` {
				break
			}
			if character in [`+`, `-`] && !saw_chomp {
				saw_chomp = true
			} else if character >= `1` && character <= `9` && !saw_indent {
				saw_indent = true
			} else {
				return true
			}
		}
	}
	return false
}

pub fn yaml_parse_yaml(content string) !yaml.Any {
	if yaml_invalid_block_scalar_header(content) {
		return error('Content could not be parsed as YAML.')
	}
	document := yaml.parse_text(content) or { return error('Content could not be parsed as YAML.') }
	return document.to_any()
}

pub fn yaml_versions_from_content(request YamlVersionsRequest) ![]string {
	if request.content.trim_space() == '' || !request.has_block {
		return []string{}
	}
	document := yaml_parse_yaml(request.content)!
	if regex := request.regex {
		if regex.pattern.trim_space() != '' {
			return livecheck.strategy_handle_block_return(request.block(document, regex)!)
		}
	}
	if request.block_arity == 2 {
		return error('Two arguments found in `strategy` block but no regex provided.')
	}
	return livecheck.strategy_handle_block_return(request.block(document, none)!)
}

pub fn yaml_find_versions(request YamlFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !YamlMatchData {
	if !request.has_block {
		return error('Yaml requires a `strategy` block')
	}
	mut match_data := YamlMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied := request.content {
		match_data = YamlMatchData{
			...match_data
			cached: true
			has_cached: true
		}
		content = supplied
	}
	if request.url.trim_space() == '' {
		return match_data
	}
	if !match_data.has_cached {
		page := livecheck.strategy_page_content(request.url, request.options, fetcher)!
		match_data = YamlMatchData{
			...match_data
			content: page.content
			has_content: page.has_content
			final_url: page.final_url
			has_final_url: page.has_final_url
			messages: page.messages.clone()
			has_messages: page.has_messages
		}
		content = page.content
	}
	if content.trim_space() == '' {
		return match_data
	}
	versions := yaml_versions_from_content(YamlVersionsRequest{
		content: content
		regex: request.regex
		has_block: true
		block_arity: request.block_arity
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return YamlMatchData{
		...match_data
		matches: matches
	}
}

// Ruby method `self.match?(url)` at line 45.
pub fn ruby_yaml_l45_d1_self_match(url string) bool {
	return yaml_matches(url)
}

// Ruby method `self.parse_yaml(content)` at line 52.
pub fn ruby_yaml_l52_d2_self_parse_yaml(content string) !yaml.Any {
	return yaml_parse_yaml(content)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 75.
pub fn ruby_yaml_l75_d3_self_versions_from_content(request YamlVersionsRequest) ![]string {
	return yaml_versions_from_content(request)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 106.
pub fn ruby_yaml_l106_d4_self_find_versions(request YamlFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !YamlMatchData {
	return yaml_find_versions(request, fetcher)
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
// 9:       # The {Yaml} strategy fetches content at a URL, parses it as YAML and
// 10:       # provides the parsed data to a `strategy` block. If a regex is present
// 11:       # in the `livecheck` block, it should be passed as the second argument to
// 12:       # the `strategy` block.
// 13:       #
// 14:       # This is a generic strategy that doesn't contain any logic for finding
// 15:       # versions, as the structure of YAML data varies. Instead, a `strategy`
// 16:       # block must be used to extract version information from the YAML data.
// 17:       #
// 18:       # This strategy is not applied automatically and it is necessary to use
// 19:       # `strategy :yaml` in a `livecheck` block (in conjunction with a
// 20:       # `strategy` block) to use it.
// 21:       #
// 22:       # This strategy's {find_versions} method can be used in other strategies
// 23:       # that work with YAML content, so it should only be necessary to write
// 24:       # the version-finding logic that works with the parsed YAML data.
// 25:       #
// 26:       # @api public
// 27:       class Yaml
// 28:         extend Strategic
// 29:
// 30:         # A priority of zero causes livecheck to skip the strategy. We do this
// 31:         # for {Yaml} so we can selectively apply it only when a strategy block
// 32:         # is provided in a `livecheck` block.
// 33:         PRIORITY = 0
// 34:
// 35:         # The `Regexp` used to determine if the strategy applies to the URL.
// 36:         URL_MATCH_REGEX = %r{^https?://}i
// 37:
// 38:         # Whether the strategy can be applied to the provided URL.
// 39:         # {Yaml} will technically match any HTTP URL but is only usable with
// 40:         # a `livecheck` block containing a `strategy` block.
// 41:         #
// 42:         # @param url [String] the URL to match against
// 43:         # @return [Boolean]
// 44:         sig { override.params(url: String).returns(T::Boolean) }
// 45:         def self.match?(url)
// 46:           URL_MATCH_REGEX.match?(url)
// 47:         end
// 48:
// 49:         # Parses YAML text and returns the parsed data.
// 50:         # @param content [String] the YAML text to parse
// 51:         sig { params(content: String).returns(T.untyped) }
// 52:         def self.parse_yaml(content)
// 53:           require "yaml"
// 54:
// 55:           begin
// 56:             YAML.safe_load(content, permitted_classes: [Date, Time])
// 57:           rescue Psych::SyntaxError
// 58:             raise "Content could not be parsed as YAML."
// 59:           end
// 60:         end
// 61:
// 62:         # Parses YAML text and identifies versions using a `strategy` block.
// 63:         # If a regex is provided, it will be passed as the second argument to
// 64:         # the `strategy` block (after the parsed YAML data).
// 65:         # @param content [String] the YAML text to parse and check
// 66:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 67:         # @return [Array]
// 68:         sig {
// 69:           params(
// 70:             content: String,
// 71:             regex:   T.nilable(Regexp),
// 72:             block:   T.nilable(Proc),
// 73:           ).returns(T::Array[String])
// 74:         }
// 75:         def self.versions_from_content(content, regex = nil, &block)
// 76:           return [] if content.blank? || !block_given?
// 77:
// 78:           yaml = parse_yaml(content)
// 79:           block_return_value = if regex.present?
// 80:             yield(yaml, regex)
// 81:           elsif block.arity == 2
// 82:             raise "Two arguments found in `strategy` block but no regex provided."
// 83:           else
// 84:             yield(yaml)
// 85:           end
// 86:           Strategy.handle_block_return(block_return_value)
// 87:         end
// 88:
// 89:         # Checks the YAML content at the URL for versions, using the provided
// 90:         # `strategy` block to extract version information.
// 91:         #
// 92:         # @param url [String] the URL of the content to check
// 93:         # @param regex [Regexp, nil] a regex for matching versions in content
// 94:         # @param content [String, nil] content to check instead of fetching
// 95:         # @param options [Options] options to modify behavior
// 96:         # @return [Hash]
// 97:         sig {
// 98:           override.params(
// 99:             url:     String,
// 100:             regex:   T.nilable(Regexp),
// 101:             content: T.nilable(String),
// 102:             options: Options,
// 103:             block:   T.nilable(Proc),
// 104:           ).returns(T::Hash[Symbol, T.anything])
// 105:         }
// 106:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 107:           raise ArgumentError, "#{Utils.demodulize(name)} requires a `strategy` block" unless block_given?
// 108:
// 109:           match_data = { matches: {}, regex:, url: }
// 110:           match_data[:cached] = true if content
// 111:           return match_data if url.blank?
// 112:
// 113:           unless match_data[:cached]
// 114:             match_data.merge!(Strategy.page_content(url, options:))
// 115:             content = match_data[:content]
// 116:           end
// 117:           return match_data if content.blank?
// 118:
// 119:           versions_from_content(content, regex, &block).each do |match_text|
// 120:             match_data[:matches][match_text] = Version.new(match_text)
// 121:           end
// 122:
// 123:           match_data
// 124:         end
// 125:       end
// 126:     end
// 127:   end
// 128: end
