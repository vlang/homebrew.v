module strategy

import homebrew.livecheck
import regex

// Translated from Homebrew/brew `livecheck/strategy/page_match.rb`.
pub const page_match_priority = 0

pub struct PageMatchRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type PageMatchVersionsBlock = fn (string, ?PageMatchRegex) !livecheck.StrategyBlockValue

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
