module strategy

import homebrew.livecheck
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/json.rb`.
pub const json_priority = 0

pub struct JsonRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type JsonVersionsBlock = fn (json2.Any, ?JsonRegex) !livecheck.StrategyBlockValue

pub struct JsonVersionsRequest {
pub:
	content     string
	regex       ?JsonRegex
	has_block   bool
	block_arity int
	block       JsonVersionsBlock = unsafe { nil }
}

pub struct JsonFindVersionsRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int
	block       JsonVersionsBlock = unsafe { nil }
}

pub struct JsonMatchData {
pub:
	matches       map[string]string
	regex         ?JsonRegex
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

pub fn json_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

pub fn json_parse_json(content string) !json2.Any {
	return json2.decode[json2.Any](content) or {
		return error('Content could not be parsed as JSON.')
	}
}

fn json_value_blank(value json2.Any) bool {
	match value {
		[]json2.Any {
			return value.len == 0
		}
		bool {
			return !value
		}
		map[string]json2.Any {
			return value.len == 0
		}
		string {
			return value.trim_space() == ''
		}
		json2.Null {
			return true
		}
		else {
			return false
		}
	}
}

pub fn json_versions_from_content(request JsonVersionsRequest) ![]string {
	if request.content.trim_space() == '' || !request.has_block {
		return []string{}
	}
	document := json_parse_json(request.content)!
	if json_value_blank(document) {
		return []string{}
	}
	block_return_value := if request.block_arity == 2 {
		request.block(document, request.regex)!
	} else {
		request.block(document, none)!
	}
	return livecheck.strategy_handle_block_return(block_return_value)
}

pub fn json_find_versions(request JsonFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	if !request.has_block {
		return error('Json requires a `strategy` block')
	}
	mut match_data := JsonMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied := request.content {
		match_data = JsonMatchData{
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
		match_data = JsonMatchData{
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
	versions := json_versions_from_content(JsonVersionsRequest{
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
	return JsonMatchData{
		...match_data
		matches: matches
	}
}
