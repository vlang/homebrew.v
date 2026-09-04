module strategy

import homebrew.livecheck
import yaml

// Translated from Homebrew/brew `livecheck/strategy/yaml.rb`.
pub const yaml_priority = 0

pub struct YamlRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type YamlVersionsBlock = fn (yaml.Any, ?YamlRegex) !livecheck.StrategyBlockValue

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
