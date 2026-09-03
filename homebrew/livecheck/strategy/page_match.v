module strategy

import homebrew.livecheck
import regex

// Translated from Homebrew/brew `livecheck/strategy/page_match.rb`.
// The original source is retained below until every stub has a typed V body.
pub const page_match_priority = 0

pub struct PageMatchRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type PageMatchVersionsBlock = fn(string, ?PageMatchRegex) !livecheck.StrategyBlockValue

pub struct PageMatchVersionsRequest {
pub:
	content   string
	regex     ?PageMatchRegex
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

pub struct PageMatchFindVersionsRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

pub struct PageMatchData {
pub:
	matches       map[string]string
	regex         ?PageMatchRegex
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

pub fn page_match_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

fn page_match_regex_pattern(pattern string) string {
	// V's regex parser requires a trailing hyphen to appear first in a character
	// class and uses the greedy form for Ruby's lazy wildcard in these patterns.
	return pattern.replace('[._-]', '[-._]').replace('[.-]', '[-.]').replace('[_-]', '[-_]').replace('.*?', '.*')
}

pub fn page_match_scan(content string, match_regex PageMatchRegex) ![]string {
	mut expression := regex.regex_opt(page_match_regex_pattern(match_regex.pattern))!
	if match_regex.case_insensitive {
		expression.flag |= regex.f_ci
	}
	mut matches := []string{}
	mut offset := 0
	for offset <= content.len {
		start, end := expression.find_from(content, offset)
		if start < 0 {
			break
		}
		if expression.group_count > 0 {
			value := expression.get_group_by_id(content, 0)
			if value != '' && value !in matches {
				matches << value
			}
		} else {
			value := content[start..end]
			if value !in matches {
				matches << value
			}
		}
		if end > start {
			offset = end
		} else {
			offset = start + 1
		}
	}
	return matches
}

pub fn page_match_versions_from_content(request PageMatchVersionsRequest) ![]string {
	if request.has_block {
		return livecheck.strategy_handle_block_return(request.block(request.content, request.regex)!)
	}
	match_regex := request.regex or { return []string{} }
	return page_match_scan(request.content, match_regex)
}

pub fn page_match_find_versions(request PageMatchFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	if request.regex == none && !request.has_block {
		return error('PageMatch requires a regex or `strategy` block')
	}
	mut match_data := PageMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied := request.content {
		match_data = PageMatchData{
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
		match_data = PageMatchData{
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
	versions := page_match_versions_from_content(PageMatchVersionsRequest{
		content: content
		regex: request.regex
		has_block: request.has_block
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return PageMatchData{
		...match_data
		matches: matches
	}
}

// Ruby method `self.match?(url)` at line 38.
pub fn ruby_page_match_l38_d1_self_match(url string) bool {
	return page_match_matches(url)
}

// Ruby method `self.versions_from_content(content, regex, &block)` at line 56.
pub fn ruby_page_match_l56_d2_self_versions_from_content(request PageMatchVersionsRequest) ![]string {
	return page_match_versions_from_content(request)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 95.
pub fn ruby_page_match_l95_d3_self_find_versions(request PageMatchFindVersionsRequest,
	state_fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	return page_match_find_versions(request, state_fetcher)
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
// 9:       # The {PageMatch} strategy fetches content at a URL and scans it for
// 10:       # matching text using the provided regex.
// 11:       #
// 12:       # This strategy can be used in a `livecheck` block when no specific
// 13:       # strategies apply to a given URL. Though {PageMatch} will technically
// 14:       # match any HTTP URL, the strategy also requires a regex to function.
// 15:       #
// 16:       # The {find_versions} method can be used within other strategies, to
// 17:       # handle the process of identifying version text in content.
// 18:       #
// 19:       # @api public
// 20:       class PageMatch
// 21:         extend Strategic
// 22:
// 23:         # A priority of zero causes livecheck to skip the strategy. We do this
// 24:         # for {PageMatch} so we can selectively apply it only when a regex is
// 25:         # provided in a `livecheck` block.
// 26:         PRIORITY = 0
// 27:
// 28:         # The `Regexp` used to determine if the strategy applies to the URL.
// 29:         URL_MATCH_REGEX = %r{^https?://}i
// 30:
// 31:         # Whether the strategy can be applied to the provided URL.
// 32:         # {PageMatch} will technically match any HTTP URL but is only
// 33:         # usable with a `livecheck` block containing a regex.
// 34:         #
// 35:         # @param url [String] the URL to match against
// 36:         # @return [Boolean]
// 37:         sig { override.params(url: String).returns(T::Boolean) }
// 38:         def self.match?(url)
// 39:           URL_MATCH_REGEX.match?(url)
// 40:         end
// 41:
// 42:         # Uses the regex to match text in the content or, if a block is
// 43:         # provided, passes the content to the block to handle matching. With
// 44:         # either approach, an array of unique matches is returned.
// 45:         #
// 46:         # @param content [String] the content to check
// 47:         # @param regex [Regexp, nil] a regex for matching versions in content
// 48:         # @return [Array]
// 49:         sig {
// 50:           params(
// 51:             content: String,
// 52:             regex:   T.nilable(Regexp),
// 53:             block:   T.nilable(Proc),
// 54:           ).returns(T::Array[String])
// 55:         }
// 56:         def self.versions_from_content(content, regex, &block)
// 57:           if block
// 58:             block_return_value = regex.present? ? yield(content, regex) : yield(content)
// 59:             return Strategy.handle_block_return(block_return_value)
// 60:           end
// 61:
// 62:           return [] if regex.blank?
// 63:
// 64:           content.scan(regex).filter_map do |match|
// 65:             case match
// 66:             when String
// 67:               match
// 68:             when Array
// 69:               match.first
// 70:             else
// 71:               # simplecov:disable
// 72:               T.absurd(match)
// 73:               # simplecov:enable
// 74:             end
// 75:           end.uniq
// 76:         end
// 77:
// 78:         # Checks the content at the URL for new versions, using the provided
// 79:         # regex for matching.
// 80:         #
// 81:         # @param url [String] the URL of the content to check
// 82:         # @param regex [Regexp, nil] a regex for matching versions in content
// 83:         # @param content [String, nil] content to check instead of fetching
// 84:         # @param options [Options] options to modify behavior
// 85:         # @return [Hash]
// 86:         sig {
// 87:           override.params(
// 88:             url:     String,
// 89:             regex:   T.nilable(Regexp),
// 90:             content: T.nilable(String),
// 91:             options: Options,
// 92:             block:   T.nilable(Proc),
// 93:           ).returns(T::Hash[Symbol, T.untyped])
// 94:         }
// 95:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 96:           if regex.blank? && !block_given?
// 97:             raise ArgumentError, "#{Utils.demodulize(name)} requires a regex or `strategy` block"
// 98:           end
// 99:
// 100:           match_data = { matches: {}, regex:, url: }
// 101:           match_data[:cached] = true if content
// 102:           return match_data if url.blank?
// 103:
// 104:           unless match_data[:cached]
// 105:             match_data.merge!(Strategy.page_content(url, options:))
// 106:             content = match_data[:content]
// 107:           end
// 108:           return match_data if content.blank?
// 109:
// 110:           versions_from_content(content, regex, &block).each do |match_text|
// 111:             match_data[:matches][match_text] = Version.new(match_text)
// 112:           end
// 113:
// 114:           match_data
// 115:         end
// 116:       end
// 117:     end
// 118:   end
// 119: end
