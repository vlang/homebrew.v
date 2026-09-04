module strategy

import ruby
import homebrew.livecheck
import homebrew.utils
import net.urllib
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/npm.rb`.
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
