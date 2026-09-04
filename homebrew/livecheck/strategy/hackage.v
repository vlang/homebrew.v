module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/hackage.rb`.
pub struct HackageInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct HackageFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn hackage_package_name(url string) ?string {
	file_name := url.all_after_last('/')
	for index := 0; index + 1 < file_name.len; index++ {
		if file_name[index] == `-` && file_name[index + 1].is_digit() && index > 0 {
			return file_name[..index]
		}
	}
	return none
}

fn hackage_regex_escape(value string) string {
	mut escaped := value
	for character in ['\\', '.', '+', '*', '?', '^', '\$', '(', ')', '[', ']', '{', '}', '|'] {
		escaped = escaped.replace(character, '\\${character}')
	}
	return escaped.replace('\\-', '-')
}

pub fn hackage_matches_url(url string) bool {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://hackage.haskell.org/') {
		'https://hackage.haskell.org/'.len
	} else if lower.starts_with('http://hackage.haskell.org/') {
		'http://hackage.haskell.org/'.len
	} else if lower.starts_with('https://downloads.haskell.org/') {
		'https://downloads.haskell.org/'.len
	} else if lower.starts_with('http://downloads.haskell.org/') {
		'http://downloads.haskell.org/'.len
	} else {
		return false
	}
	return url[prefix_length..].contains('/') && hackage_package_name(url) != none
}

pub fn hackage_generate_input_values(url string) HackageInputValues {
	package_name := hackage_package_name(url) or { return HackageInputValues{} }
	regex_name := hackage_regex_escape(package_name)
	return HackageInputValues{
		present: true
		url: 'https://hackage.haskell.org/package/${package_name}/src/'
		regex: PageMatchRegex{
			pattern: '<h3>${regex_name}-(.*?)/?</h3>'
			case_insensitive: true
		}
	}
}

pub fn hackage_find_versions(request HackageFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := hackage_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	return page_match_find_versions(PageMatchFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)
}

fn hackage_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn hackage_match_data_value(result PageMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.object_value('Version', version)
	}
	regex_value := result.regex or { PageMatchRegex{} }
	mut values := {
		'matches': ruby.map_value(matches)
		'regex':   if regex_value.pattern == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.object_value('Regexp', regex_value.pattern)
		}
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
